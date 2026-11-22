<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpKernel\Exception\ServiceUnavailableHttpException;
use Throwable;

/**
 * Extracts structured Indonesian/English receipt data from images using free AI Vision providers:
 * Google Gemini (primary) with automatic Groq Vision fallback.
 */
class AiReceiptScannerService
{
    private const REQUEST_TIMEOUT_SECONDS = 25;

    /**
     * @param  array<int, string>  $categories
     * @return array<string, mixed>
     */
    public function scanReceipt(UploadedFile $image, array $categories = []): array
    {
        $realPath = $image->getRealPath();
        $rawBytes = $realPath !== false ? @file_get_contents($realPath) : false;

        if ($rawBytes === false || $rawBytes === '') {
            throw new ServiceUnavailableHttpException(
                null,
                'Gagal membaca isi file gambar struk.'
            );
        }

        if (strlen($rawBytes) > ReceiptService::MAX_FILE_SIZE_BYTES) {
            throw new ServiceUnavailableHttpException(
                null,
                'Ukuran gambar struk melebihi batas maksimal 5 MB.'
            );
        }

        $mimeType = $this->resolveMimeType($image, $rawBytes);
        $base64Image = base64_encode($rawBytes);
        $prompt = $this->buildExtractionPrompt($categories);

        $geminiKey = trim((string) config('services.gemini.key', ''));
        $geminiModel = trim((string) config('services.gemini.model', 'gemini-flash-lite-latest')) ?: 'gemini-flash-lite-latest';
        $geminiBaseUrl = rtrim((string) config('services.gemini.base_url', 'https://generativelanguage.googleapis.com/v1beta'), '/');

        $groqKey = trim((string) config('services.groq.key', ''));
        $groqModel = trim((string) config('services.groq.vision_model', 'qwen/qwen3.8-27b'))
            ?: 'qwen/qwen3.8-27b';
        $groqBaseUrl = rtrim((string) config('services.groq.base_url', 'https://api.groq.com/openai/v1'), '/');

        if ($geminiKey === '' && $groqKey === '') {
            throw new ServiceUnavailableHttpException(
                null,
                'API key AI Vision (Gemini/Groq) belum diatur di server. Gunakan pengaturan AI Key di aplikasi.'
            );
        }

        $errors = [];

        if ($geminiKey !== '') {
            try {
                $decoded = $this->callGemini(
                    apiKey: $geminiKey,
                    model: $geminiModel,
                    baseUrl: $geminiBaseUrl,
                    mimeType: $mimeType,
                    base64Image: $base64Image,
                    prompt: $prompt,
                );

                return $this->normalizeExtraction(
                    decoded: $decoded,
                    provider: 'gemini',
                    model: $geminiModel,
                    fallbackUsed: false,
                );
            } catch (Throwable $e) {
                $errors[] = 'Gemini: '.$e->getMessage();
                Log::warning('Gemini AI receipt scan failed, attempting Groq fallback', [
                    'model' => $geminiModel,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        if ($groqKey !== '') {
            try {
                $decoded = $this->callGroq(
                    apiKey: $groqKey,
                    model: $groqModel,
                    baseUrl: $groqBaseUrl,
                    mimeType: $mimeType,
                    base64Image: $base64Image,
                    prompt: $prompt,
                );

                return $this->normalizeExtraction(
                    decoded: $decoded,
                    provider: 'groq',
                    model: $groqModel,
                    fallbackUsed: $geminiKey !== '',
                );
            } catch (Throwable $e) {
                $errors[] = 'Groq: '.$e->getMessage();
                Log::warning('Groq AI receipt scan failed', [
                    'model' => $groqModel,
                    'error' => $e->getMessage(),
                ]);
            }
        }

        throw new ServiceUnavailableHttpException(
            null,
            'Pemindaian AI gagal sementara ('.implode(' | ', $errors).').'
        );
    }

    /**
     * @return array<string, mixed>
     */
    private function callGemini(
        string $apiKey,
        string $model,
        string $baseUrl,
        string $mimeType,
        string $base64Image,
        string $prompt,
    ): array {
        $url = sprintf('%s/models/%s:generateContent?key=%s', $baseUrl, rawurlencode($model), rawurlencode($apiKey));

        $response = Http::timeout(self::REQUEST_TIMEOUT_SECONDS)
            ->acceptJson()
            ->post($url, [
                'contents' => [
                    [
                        'parts' => [
                            ['text' => $prompt],
                            [
                                'inline_data' => [
                                    'mime_type' => $mimeType,
                                    'data' => $base64Image,
                                ],
                            ],
                        ],
                    ],
                ],
                'generationConfig' => [
                    'temperature' => 0.1,
                    'responseMimeType' => 'application/json',
                ],
            ]);

        if (! $response->successful()) {
            $apiMsg = (string) ($response->json('error.message') ?? '');
            throw new \RuntimeException('HTTP '.$response->status().($apiMsg !== '' ? " ($apiMsg)" : ''));
        }

        $text = (string) ($response->json('candidates.0.content.parts.0.text') ?? '');
        $decoded = self::decodeJsonPayload($text);

        if ($decoded === null) {
            throw new \RuntimeException('Respon Gemini bukan JSON valid.');
        }

        return $decoded;
    }

    /**
     * @return array<string, mixed>
     */
    private function callGroq(
        string $apiKey,
        string $model,
        string $baseUrl,
        string $mimeType,
        string $base64Image,
        string $prompt,
    ): array {
        $url = sprintf('%s/chat/completions', $baseUrl);

        $response = Http::withToken($apiKey)
            ->timeout(self::REQUEST_TIMEOUT_SECONDS)
            ->acceptJson()
            ->post($url, [
                'model' => $model,
                'temperature' => 0.1,
                'response_format' => ['type' => 'json_object'],
                'messages' => [
                    [
                        'role' => 'user',
                        'content' => [
                            [
                                'type' => 'text',
                                'text' => $prompt,
                            ],
                            [
                                'type' => 'image_url',
                                'image_url' => [
                                    'url' => sprintf('data:%s;base64,%s', $mimeType, $base64Image),
                                ],
                            ],
                        ],
                    ],
                ],
            ]);

        if (! $response->successful()) {
            $apiMsg = (string) ($response->json('error.message') ?? '');
            throw new \RuntimeException('HTTP '.$response->status().($apiMsg !== '' ? " ($apiMsg)" : ''));
        }

        $text = (string) ($response->json('choices.0.message.content') ?? '');
        $decoded = self::decodeJsonPayload($text);

        if ($decoded === null) {
            throw new \RuntimeException('Respon Groq bukan JSON valid.');
        }

        return $decoded;
    }

    /**
     * @param  array<int, string>  $categories
     */
    private function buildExtractionPrompt(array $categories): string
    {
        $cleanCategories = array_values(array_unique(array_filter(array_map(
            static fn ($c) => trim((string) $c),
            $categories,
        ), static fn ($c) => $c !== '')));

        $categoryInstruction = count($cleanCategories) > 0
            ? 'Pilih nilai suggested_category paling cocok dari daftar berikut: '.implode(', ', $cleanCategories).'.'
            : 'Pilih suggested_category singkat berbahasa Indonesia (contoh: Makanan, Belanja, Transportasi, Kesehatan, Tagihan, Hiburan, Lainnya).';

        return <<<PROMPT
Kamu adalah AI pembaca nota/struk belanja Indonesia & internasional yang sangat akurat.
Ekstrak informasi dari foto struk ini ke JSON valid dengan struktur PERSIS berikut (tanpa penjelasan tambahan):
{
  "merchant_name": "string nama toko/merchant/restoran atau null",
  "total_amount": integer grand total yang dibayar (Rupiah bulat tanpa titik/koma, abaikan Tunai/Cash/Kembalian/Change),
  "transaction_date": "string ISO YYYY-MM-DD HH:MM:SS atau YYYY-MM-DD atau null",
  "suggested_category": "string kategori pengeluaran atau null",
  "line_items": ["string ringkas item dan harganya, maksimal 15 item"],
  "raw_text": "string ringkasan transkrip teks utama struk"
}
Aturan penting:
1. Untuk struk Indonesia seperti Rp 25.000 atau 25.000,00 -> total_amount harus integer 25000 (abaikan ,00/.00 desimal di akhir).
2. Utamakan GRAND TOTAL / TOTAL BAYAR / TOTAL TAGIHAN / TOTAL BELANJA. Jangan ambil uang Tunai/Cash atau Kembalian.
3. {$categoryInstruction}
PROMPT;
    }

    /**
     * @return array<string, mixed>|null
     */
    public static function decodeJsonPayload(string $rawText): ?array
    {
        $trimmed = trim($rawText);
        if ($trimmed === '') {
            return null;
        }

        if (preg_match('/```(?:json)?\s*([\s\S]*?)```/i', $trimmed, $matches) === 1) {
            $trimmed = trim($matches[1]);
        }

        $decoded = json_decode($trimmed, true);
        if (is_array($decoded)) {
            return $decoded;
        }

        $firstBrace = strpos($trimmed, '{');
        $lastBrace = strrpos($trimmed, '}');
        if ($firstBrace !== false && $lastBrace !== false && $lastBrace > $firstBrace) {
            $slice = substr($trimmed, $firstBrace, $lastBrace - $firstBrace + 1);
            $decoded = json_decode($slice, true);
            if (is_array($decoded)) {
                return $decoded;
            }
        }

        return null;
    }

    /**
     * @param  array<string, mixed>  $decoded
     * @return array<string, mixed>
     */
    private function normalizeExtraction(
        array $decoded,
        string $provider,
        string $model,
        bool $fallbackUsed,
    ): array {
        $merchant = isset($decoded['merchant_name']) && is_string($decoded['merchant_name'])
            ? trim($decoded['merchant_name'])
            : null;
        if ($merchant === '') {
            $merchant = null;
        }

        $rawAmount = $decoded['total_amount'] ?? ($decoded['detected_amount'] ?? null);
        $detectedAmount = $this->parseAmount($rawAmount);

        $rawDate = $decoded['transaction_date'] ?? ($decoded['detected_date'] ?? null);
        $detectedDate = is_string($rawDate) && trim($rawDate) !== '' ? trim($rawDate) : null;

        $suggestedCategory = isset($decoded['suggested_category']) && is_string($decoded['suggested_category'])
            ? trim($decoded['suggested_category'])
            : null;
        if ($suggestedCategory === '') {
            $suggestedCategory = null;
        }

        $lineItems = [];
        if (isset($decoded['line_items']) && is_array($decoded['line_items'])) {
            foreach ($decoded['line_items'] as $item) {
                $str = trim((string) $item);
                if ($str !== '') {
                    $lineItems[] = $str;
                }
                if (count($lineItems) >= 20) {
                    break;
                }
            }
        }

        $rawText = isset($decoded['raw_text']) && is_string($decoded['raw_text'])
            ? trim($decoded['raw_text'])
            : '';

        if ($rawText === '') {
            $parts = array_filter([
                $merchant,
                $detectedDate,
                ...$lineItems,
                $detectedAmount !== null ? 'TOTAL '.$detectedAmount : null,
            ]);
            $rawText = implode("\n", $parts);
        }

        return [
            'provider' => $provider,
            'model' => $model,
            'fallback_used' => $fallbackUsed,
            'merchant_name' => $merchant,
            'detected_amount' => $detectedAmount,
            'detected_date' => $detectedDate,
            'suggested_category' => $suggestedCategory,
            'line_items' => $lineItems,
            'raw_text' => $rawText,
        ];
    }

    private function parseAmount(mixed $value): ?int
    {
        if (is_int($value)) {
            return $value > 0 ? $value : null;
        }
        if (is_float($value)) {
            $rounded = (int) round($value);

            return $rounded > 0 ? $rounded : null;
        }
        if (! is_string($value)) {
            return null;
        }

        $clean = preg_replace('/[^\d.,]/', '', trim($value)) ?? '';
        if ($clean === '') {
            return null;
        }

        if (preg_match('/[.,]\d{2}$/', $clean) === 1 && preg_match('/^\d+[.,]\d{3}$/', $clean) !== 1) {
            $clean = substr($clean, 0, -3);
        }

        $digits = preg_replace('/\D/', '', $clean) ?? '';
        if ($digits === '') {
            return null;
        }

        $amount = (int) $digits;

        return $amount > 0 ? $amount : null;
    }

    private function resolveMimeType(UploadedFile $image, string $rawBytes): string
    {
        $allowed = ['image/jpeg', 'image/png', 'image/webp'];
        $finfo = new \finfo(FILEINFO_MIME_TYPE);
        $detected = $finfo->buffer($rawBytes);
        if (is_string($detected) && in_array($detected, $allowed, true)) {
            return $detected;
        }

        $clientMime = $image->getMimeType();
        if (is_string($clientMime) && in_array($clientMime, $allowed, true)) {
            return $clientMime;
        }

        return 'image/jpeg';
    }
}


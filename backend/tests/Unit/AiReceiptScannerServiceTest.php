<?php

namespace Tests\Unit;

use App\Services\AiReceiptScannerService;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Http;
use Symfony\Component\HttpKernel\Exception\ServiceUnavailableHttpException;
use Tests\TestCase;

class AiReceiptScannerServiceTest extends TestCase
{
    public function test_scan_receipt_uses_gemini_primary_when_available(): void
    {
        config([
            'services.gemini.key' => 'test-gemini-key',
            'services.gemini.model' => 'gemini-2.5-flash',
            'services.groq.key' => 'test-groq-key',
        ]);

        Http::fake([
            'generativelanguage.googleapis.com/*' => Http::response([
                'candidates' => [
                    [
                        'content' => [
                            'parts' => [
                                [
                                    'text' => json_encode([
                                        'merchant_name' => 'INDOMARET SUDIRMAN',
                                        'total_amount' => 'Rp 23.500,00',
                                        'transaction_date' => '2026-11-21 14:25:00',
                                        'suggested_category' => 'Belanja',
                                        'line_items' => ['Air Mineral 4.500', 'Roti Tawar 19.000'],
                                        'raw_text' => "INDOMARET SUDIRMAN\nTOTAL Rp 23.500",
                                    ], JSON_THROW_ON_ERROR),
                                ],
                            ],
                        ],
                    ],
                ],
            ], 200),
        ]);

        $service = new AiReceiptScannerService();
        $image = UploadedFile::fake()->image('struk.jpg', 400, 600);
        $result = $service->scanReceipt($image, ['Makanan', 'Belanja']);

        $this->assertSame('gemini', $result['provider']);
        $this->assertFalse($result['fallback_used']);
        $this->assertSame('INDOMARET SUDIRMAN', $result['merchant_name']);
        $this->assertSame(23500, $result['detected_amount']);
        $this->assertSame('Belanja', $result['suggested_category']);
        $this->assertCount(2, $result['line_items']);
        Http::assertSentCount(1);
    }

    public function test_scan_receipt_falls_back_to_groq_when_gemini_fails(): void
    {
        config([
            'services.gemini.key' => 'test-gemini-key',
            'services.gemini.model' => 'gemini-2.5-flash',
            'services.groq.key' => 'test-groq-key',
            'services.groq.vision_model' => 'meta-llama/llama-4-scout-17b-16e-instruct',
        ]);

        Http::fake([
            'generativelanguage.googleapis.com/*' => Http::response([
                'error' => ['message' => 'Resource exhausted'],
            ], 429),
            'api.groq.com/*' => Http::response([
                'choices' => [
                    [
                        'message' => [
                            'content' => "```json\n".json_encode([
                                'merchant_name' => 'WARUNG KOPI NUSANTARA',
                                'total_amount' => 48000,
                                'transaction_date' => '2026-11-21',
                                'suggested_category' => 'Makanan',
                                'line_items' => ['Kopi Susu 22.000', 'Croissant 26.000'],
                                'raw_text' => "WARUNG KOPI NUSANTARA\nTOTAL 48.000",
                            ], JSON_THROW_ON_ERROR)."\n```",
                        ],
                    ],
                ],
            ], 200),
        ]);

        $service = new AiReceiptScannerService();
        $image = UploadedFile::fake()->image('struk_kopi.jpg', 400, 600);
        $result = $service->scanReceipt($image, ['Makanan', 'Belanja']);

        $this->assertSame('groq', $result['provider']);
        $this->assertTrue($result['fallback_used']);
        $this->assertSame('WARUNG KOPI NUSANTARA', $result['merchant_name']);
        $this->assertSame(48000, $result['detected_amount']);
        $this->assertSame('Makanan', $result['suggested_category']);
        Http::assertSentCount(2);
    }

    public function test_scan_receipt_throws_service_unavailable_when_keys_missing(): void
    {
        config([
            'services.gemini.key' => '',
            'services.groq.key' => '',
        ]);

        $service = new AiReceiptScannerService();
        $image = UploadedFile::fake()->image('struk.jpg', 300, 400);

        $this->expectException(ServiceUnavailableHttpException::class);
        $service->scanReceipt($image);
    }
}


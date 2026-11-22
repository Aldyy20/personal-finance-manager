<?php

namespace Tests\Feature\Api\V1;

use App\Models\User;
use App\Services\AiReceiptScannerService;
use App\Services\UserBootstrapService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class AiReceiptScanTest extends TestCase
{
    use RefreshDatabase;

    public function test_ai_receipt_scan_requires_authentication(): void
    {
        $image = UploadedFile::fake()->image('struk.jpg', 300, 500);

        $this->postJson('/api/v1/receipts/scan-ai', [
            'file' => $image,
        ])->assertStatus(401)->assertJson(['code' => 'UNAUTHENTICATED']);
    }

    public function test_ai_receipt_scan_uses_gemini_as_primary_provider(): void
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

        [, $token] = $this->createUserWithToken('ai_gemini@example.com');
        $image = UploadedFile::fake()->image('struk_indo.jpg', 400, 600);

        $this->withToken($token)
            ->post('/api/v1/receipts/scan-ai', [
                'file' => $image,
                'categories' => ['Makanan', 'Belanja', 'Transportasi'],
            ], ['Accept' => 'application/json'])
            ->assertStatus(200)
            ->assertJsonPath('data.provider', 'gemini')
            ->assertJsonPath('data.fallback_used', false)
            ->assertJsonPath('data.merchant_name', 'INDOMARET SUDIRMAN')
            ->assertJsonPath('data.detected_amount', 23500)
            ->assertJsonPath('data.suggested_category', 'Belanja')
            ->assertJsonCount(2, 'data.line_items');

        Http::assertSentCount(1);
    }

    public function test_ai_receipt_scan_falls_back_to_groq_when_gemini_fails(): void
    {
        config([
            'services.gemini.key' => 'test-gemini-key',
            'services.gemini.model' => 'gemini-2.5-flash',
            'services.groq.key' => 'test-groq-key',
            'services.groq.vision_model' => 'meta-llama/llama-4-scout-17b-16e-instruct',
        ]);

        Http::fake([
            'generativelanguage.googleapis.com/*' => Http::response([
                'error' => ['message' => 'Resource has been exhausted (e.g. check quota).'],
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

        [, $token] = $this->createUserWithToken('ai_fallback@example.com');
        $image = UploadedFile::fake()->image('struk_kopi.jpg', 400, 600);

        $this->withToken($token)
            ->post('/api/v1/receipts/scan-ai', [
                'file' => $image,
                'categories' => ['Makanan', 'Transportasi'],
            ], ['Accept' => 'application/json'])
            ->assertStatus(200)
            ->assertJsonPath('data.provider', 'groq')
            ->assertJsonPath('data.fallback_used', true)
            ->assertJsonPath('data.merchant_name', 'WARUNG KOPI NUSANTARA')
            ->assertJsonPath('data.detected_amount', 48000)
            ->assertJsonPath('data.suggested_category', 'Makanan');

        Http::assertSentCount(2);
    }

    public function test_ai_receipt_scan_returns_503_when_no_provider_keys_configured(): void
    {
        config([
            'services.gemini.key' => '',
            'services.groq.key' => '',
        ]);

        [, $token] = $this->createUserWithToken('ai_nokey@example.com');
        $image = UploadedFile::fake()->image('struk.jpg', 300, 400);

        $this->withToken($token)
            ->post('/api/v1/receipts/scan-ai', [
                'file' => $image,
            ], ['Accept' => 'application/json'])
            ->assertStatus(503);
    }

    public function test_decode_json_payload_handles_fences_and_surrounding_text(): void
    {
        $raw = "Berikut hasil analisis nota:\n```json\n{\"merchant_name\":\"APOTEK K24\",\"total_amount\":65000}\n```";
        $decoded = AiReceiptScannerService::decodeJsonPayload($raw);

        $this->assertNotNull($decoded);
        $this->assertSame('APOTEK K24', $decoded['merchant_name']);
        $this->assertSame(65000, $decoded['total_amount']);
    }

    /**
     * @return array{0: User, 1: string}
     */
    private function createUserWithToken(string $email): array
    {
        $user = User::factory()->create(['email' => $email]);
        app(UserBootstrapService::class)->bootstrapNewUser($user);
        $token = $user->createToken('test-device')->plainTextToken;

        return [$user->fresh(), $token];
    }
}


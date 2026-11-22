<?php

namespace Tests;

use App\Models\EmailOtpCode;
use App\Services\EmailOtpService;
use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Illuminate\Support\Facades\Hash;

abstract class TestCase extends BaseTestCase
{
    protected function issueOtpForTest(
        string $email,
        string $purpose = EmailOtpService::PURPOSE_REGISTER,
        string $otpCode = '123456',
    ): string {
        EmailOtpCode::query()->create([
            'email' => strtolower(trim($email)),
            'purpose' => $purpose,
            'code_hash' => Hash::make($otpCode),
            'attempts' => 0,
            'expires_at' => now()->addMinutes(10),
            'used_at' => null,
            'created_at' => now(),
        ]);

        return $otpCode;
    }
}

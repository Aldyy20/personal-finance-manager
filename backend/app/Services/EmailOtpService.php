<?php

namespace App\Services;

use App\Exceptions\FinancialValidationException;
use App\Mail\AuthOtpMail;
use App\Models\EmailOtpCode;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Symfony\Component\HttpKernel\Exception\ServiceUnavailableHttpException;
use Throwable;

class EmailOtpService
{
    public const PURPOSE_REGISTER = 'register';

    public const PURPOSE_PASSWORD_RESET = 'password_reset';

    public const OTP_TTL_MINUTES = 10;

    public const MAX_VERIFY_ATTEMPTS = 5;

    public const RESEND_COOLDOWN_SECONDS = 60;

    /**
     * Generates and sends a 6-digit OTP to the given email with resend cooldown protection.
     *
     * @return array{expires_in_seconds: int, resend_cooldown_seconds: int}
     */
    public function sendOtp(string $email, string $purpose): array
    {
        $normalizedEmail = strtolower(trim($email));
        $now = now();

        $latest = EmailOtpCode::query()
            ->where('email', $normalizedEmail)
            ->where('purpose', $purpose)
            ->whereNull('used_at')
            ->latest('created_at')
            ->first();

        if ($latest !== null && $latest->created_at !== null && $latest->expires_at->isFuture()) {
            $elapsed = $now->getTimestamp() - $latest->created_at->getTimestamp();
            if ($elapsed >= 0 && $elapsed < self::RESEND_COOLDOWN_SECONDS) {
                $remaining = max(1, self::RESEND_COOLDOWN_SECONDS - $elapsed);
                $message = "Tunggu {$remaining} detik sebelum mengirim ulang kode OTP.";
                throw new FinancialValidationException($message, ['email' => [$message]]);
            }
        }

        // Invalidate previous active OTPs for the same email and purpose
        EmailOtpCode::query()
            ->where('email', $normalizedEmail)
            ->where('purpose', $purpose)
            ->whereNull('used_at')
            ->update(['used_at' => $now]);

        $otpCode = str_pad((string) random_int(0, 999999), 6, '0', STR_PAD_LEFT);

        $record = EmailOtpCode::query()->create([
            'email' => $normalizedEmail,
            'purpose' => $purpose,
            'code_hash' => Hash::make($otpCode),
            'attempts' => 0,
            'expires_at' => $now->copy()->addMinutes(self::OTP_TTL_MINUTES),
            'used_at' => null,
            'created_at' => $now,
        ]);

        try {
            Mail::to($normalizedEmail)->send(
                new AuthOtpMail($otpCode, $purpose, self::OTP_TTL_MINUTES)
            );
        } catch (Throwable $e) {
            // Allow immediate retry once mail transport recovers
            $record->used_at = now();
            $record->save();

            Log::error('Failed to send auth OTP email', [
                'email' => $normalizedEmail,
                'purpose' => $purpose,
                'error' => $e->getMessage(),
            ]);

            throw new ServiceUnavailableHttpException(
                null,
                'Gagal mengirim email OTP. Silakan coba lagi nanti.',
                $e
            );
        }

        return [
            'expires_in_seconds' => self::OTP_TTL_MINUTES * 60,
            'resend_cooldown_seconds' => self::RESEND_COOLDOWN_SECONDS,
        ];
    }

    /**
     * Validates an OTP against the latest unused code, enforcing TTL and attempt limits.
     */
    public function verifyOtp(
        string $email,
        string $purpose,
        string $otpCode,
        bool $consume = false,
    ): EmailOtpCode {
        $normalizedEmail = strtolower(trim($email));
        $normalizedOtp = trim($otpCode);

        $latest = EmailOtpCode::query()
            ->where('email', $normalizedEmail)
            ->where('purpose', $purpose)
            ->whereNull('used_at')
            ->latest('created_at')
            ->first();

        if ($latest === null || $latest->expires_at->isPast() || $latest->attempts >= self::MAX_VERIFY_ATTEMPTS) {
            throw new FinancialValidationException(
                'Kode OTP tidak valid atau sudah kedaluwarsa.',
                ['otp_code' => ['Kode OTP tidak valid atau sudah kedaluwarsa.']]
            );
        }

        if (! Hash::check($normalizedOtp, $latest->code_hash)) {
            $latest->attempts = $latest->attempts + 1;
            if ($latest->attempts >= self::MAX_VERIFY_ATTEMPTS) {
                $latest->used_at = now();
            }
            $latest->save();

            throw new FinancialValidationException(
                'Kode OTP tidak valid atau sudah kedaluwarsa.',
                ['otp_code' => ['Kode OTP tidak valid atau sudah kedaluwarsa.']]
            );
        }

        if ($consume) {
            $latest->used_at = now();
            $latest->save();
        }

        return $latest;
    }
}


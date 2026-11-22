<?php

namespace App\Mail;

use App\Services\EmailOtpService;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class AuthOtpMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public readonly string $otpCode,
        public readonly string $purpose,
        public readonly int $ttlMinutes = EmailOtpService::OTP_TTL_MINUTES,
    ) {}

    public function envelope(): Envelope
    {
        $subject = $this->purpose === EmailOtpService::PURPOSE_REGISTER
            ? 'Kode OTP Pendaftaran - Personal Finance Manager'
            : 'Kode OTP Reset Kata Sandi - Personal Finance Manager';

        return new Envelope(subject: $subject);
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.auth-otp',
        );
    }
}


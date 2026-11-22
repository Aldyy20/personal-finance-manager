<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <title>Kode Verifikasi OTP</title>
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f4f6fb; margin: 0; padding: 24px; color: #0f172a;">
    <table width="100%" cellpadding="0" cellspacing="0" role="presentation" style="max-width: 520px; margin: 0 auto; background-color: #ffffff; border-radius: 14px; overflow: hidden; border: 1px solid #e2e8f0;">
        <tr>
            <td style="background: linear-gradient(135deg, #0b2545 0%, #1d4ed8 100%); padding: 24px 28px; color: #ffffff;">
                <h1 style="margin: 0; font-size: 18px; font-weight: 700;">Personal Finance Manager</h1>
                <p style="margin: 6px 0 0; font-size: 13px; color: #dbeafe;">
                    {{ $purpose === \App\Services\EmailOtpService::PURPOSE_REGISTER ? 'Verifikasi Pendaftaran Akun' : 'Verifikasi Reset Kata Sandi' }}
                </p>
            </td>
        </tr>
        <tr>
            <td style="padding: 28px;">
                <p style="margin: 0 0 14px; font-size: 14px; line-height: 1.6;">
                    Halo, gunakan kode verifikasi satu kali (OTP) berikut untuk melanjutkan
                    {{ $purpose === \App\Services\EmailOtpService::PURPOSE_REGISTER ? 'pendaftaran akun baru Anda' : 'pembuatan kata sandi baru Anda' }}:
                </p>

                <div style="margin: 22px 0; padding: 18px; background-color: #f1f5f9; border-radius: 12px; text-align: center; border: 1px dashed #94a3b8;">
                    <span style="font-size: 32px; font-weight: 800; letter-spacing: 8px; color: #0f172a; font-family: 'Courier New', monospace;">
                        {{ $otpCode }}
                    </span>
                </div>

                <p style="margin: 0 0 12px; font-size: 13px; color: #475569; line-height: 1.5;">
                    Kode ini berlaku selama <strong>{{ $ttlMinutes }} menit</strong> dan hanya dapat digunakan satu kali.
                </p>
                <p style="margin: 0; font-size: 12px; color: #b91c1c; line-height: 1.5;">
                    Demi keamanan akun Anda, jangan pernah membagikan kode OTP ini kepada siapa pun.
                </p>
            </td>
        </tr>
    </table>
</body>
</html>


<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Kode OTP Reset Password</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: #f4f4f4;
            margin: 0;
            padding: 20px;
        }

        .container {
            max-width: 480px;
            margin: 0 auto;
            background: #fff;
            border-radius: 12px;
            padding: 32px;
        }

        .logo {
            text-align: center;
            margin-bottom: 24px;
        }

        h2 {
            color: #1e3a5f;
            text-align: center;
        }

        .otp-box {
            background: #f0f4ff;
            border: 2px dashed #4a7fc1;
            border-radius: 8px;
            text-align: center;
            padding: 20px;
            margin: 24px 0;
        }

        .otp-code {
            font-size: 40px;
            font-weight: bold;
            letter-spacing: 8px;
            color: #1e3a5f;
        }

        .note {
            color: #666;
            font-size: 13px;
            text-align: center;
        }

        .footer {
            margin-top: 32px;
            border-top: 1px solid #eee;
            padding-top: 16px;
            color: #999;
            font-size: 12px;
            text-align: center;
        }
    </style>
</head>

<body>
    <div class="container">
        <div class="logo">🎓</div>
        <h2>Smart Campus Assistant</h2>
        <p>Gunakan kode OTP berikut untuk mereset password Anda:</p>
        <div class="otp-box">
            <div class="otp-code">{{ $otp }}</div>
        </div>
        <p class="note">
            Kode ini berlaku selama <strong>{{ config('auth.otp_expire_minutes', 15) }} menit</strong>.<br>
            Jangan bagikan kode ini kepada siapapun.
        </p>
        <p class="note">Jika Anda tidak meminta reset password, abaikan email ini.</p>
        <div class="footer">© {{ date('Y') }} Smart Campus Assistant</div>
    </div>
</body>

</html>
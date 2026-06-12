<?php

return [
    /*
    |----------------------------------------------------------------------
    | OTP Password Reset Configuration
    |----------------------------------------------------------------------
    */
    'expire_minutes'  => env('OTP_EXPIRE_MINUTES', 15),
    'max_attempts'    => env('OTP_MAX_ATTEMPTS', 5),
    'lockout_minutes' => env('OTP_LOCKOUT_MINUTES', 30),
];

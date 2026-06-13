<?php
// app/Http/Middleware/EnsureRole.php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureRole
{
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        if (!in_array($request->user()?->role, $roles, true)) {
            return response()->json([
                'success' => false,
                'message' => 'Akses ditolak. Role tidak sesuai.',
                'code'    => 'FORBIDDEN',
            ], 403);
        }

        return $next($request);
    }
}

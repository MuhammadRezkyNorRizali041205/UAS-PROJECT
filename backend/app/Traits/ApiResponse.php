<?php

namespace App\Traits;

use Illuminate\Http\JsonResponse;

trait ApiResponse
{
    /**
     * Return a standard success JSON response.
     */
    protected function success(
        mixed $data = null,
        string $message = 'OK',
        int $code = 200,
        array $meta = []
    ): JsonResponse {
        $response = [
            'success' => true,
            'message' => $message,
            'data'    => $data,
        ];

        if (!empty($meta)) {
            $response['meta'] = $meta;
        }

        return response()->json($response, $code);
    }

    /**
     * Return a standard error JSON response.
     */
    protected function error(
        string $message = 'Error',
        int $code = 400,
        array $errors = [],
        string $errorCode = ''
    ): JsonResponse {
        $response = [
            'success' => false,
            'message' => $message,
        ];

        if (!empty($errors)) {
            $response['errors'] = $errors;
        }

        if ($errorCode) {
            $response['code'] = $errorCode;
        }

        return response()->json($response, $code);
    }

    /**
     * Return paginated response with meta.
     */
    protected function paginated(mixed $paginator, mixed $data, string $message = 'OK'): JsonResponse
    {
        return $this->success($data, $message, 200, [
            'current_page' => $paginator->currentPage(),
            'per_page'     => $paginator->perPage(),
            'total'        => $paginator->total(),
            'last_page'    => $paginator->lastPage(),
            'next_cursor'  => $paginator->currentPage() < $paginator->lastPage()
                ? $paginator->currentPage() + 1
                : null,
        ]);
    }
}

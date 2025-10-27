<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

class ApiController extends Controller
{
    protected function respond($data = null, int $status = 200, array $headers = []): JsonResponse
    {
        return response()->json($data, $status, $headers);
    }
}

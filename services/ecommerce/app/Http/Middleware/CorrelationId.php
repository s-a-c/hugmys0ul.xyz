<?php
namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class CorrelationId
{
    public function handle(Request $request, Closure $next)
    {
        $id = $request->headers->get('X-Correlation-ID', (string) Str::ulid());
        $request->headers->set('X-Correlation-ID', $id);
        $response = $next($request);
        $response->headers->set('X-Correlation-ID', $id);
        return $response;
    }
}

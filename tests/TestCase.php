<?php

namespace Tests;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\TestCase as BaseTestCase;
use Tymon\JWTAuth\Contracts\JWTSubject;
use Tymon\JWTAuth\Facades\JWTAuth;

abstract class TestCase extends BaseTestCase
{
    use RefreshDatabase;

    /**
     * Build the default headers for authenticated API requests.
     *
     * @param  JWTSubject  $user
     * @param  array<string, string>  $extra
     * @return array<string, string>
     */
    protected function apiHeadersFor(JWTSubject $user, array $extra = []): array
    {
        $token = JWTAuth::fromUser($user);

        return [
            'Accept' => 'application/json',
            'Authorization' => 'Bearer '.$token,
            ...$extra,
        ];
    }
}

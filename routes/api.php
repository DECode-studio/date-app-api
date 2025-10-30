<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\PeopleController;
use Illuminate\Support\Facades\Route;

Route::prefix('auth')->group(function (): void {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);

    Route::middleware('auth:api')->group(function (): void {
        Route::get('me', [AuthController::class, 'me']);
        Route::post('logout', [AuthController::class, 'logout']);
        Route::post('refresh', [AuthController::class, 'refresh']);
    });
});

Route::middleware('auth:api')->group(function (): void {
    Route::get('people', [PeopleController::class, 'index']);
    Route::get('people/liked', [PeopleController::class, 'liked']);
    Route::post('people/{person}/like', [PeopleController::class, 'like']);
    Route::post('people/{person}/dislike', [PeopleController::class, 'dislike']);
});

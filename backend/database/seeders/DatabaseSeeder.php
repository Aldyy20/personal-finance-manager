<?php

namespace Database\Seeders;

use App\Models\User;
use App\Services\UserBootstrapService;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $demoEmail = 'demo@personalfinance.test';

        if (User::query()->where('email', $demoEmail)->exists()) {
            return;
        }

        $user = User::query()->create([
            'name' => 'Demo User',
            'email' => $demoEmail,
            'password' => Hash::make('password123'),
            'email_verified_at' => now()->utc(),
        ]);

        app(UserBootstrapService::class)->bootstrapNewUser($user, [
            'name' => 'Demo Android Phone',
            'platform' => 'android',
            'app_version' => '1.0.0',
        ]);
    }
}

<?php

namespace Tests\Feature\Api\V1;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class HealthCheckTest extends TestCase
{
    use RefreshDatabase;

    public function test_health_endpoint_returns_standard_success_envelope(): void
    {
        $response = $this->getJson('/api/v1/health');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'status',
                    'version',
                    'database',
                    'timestamp',
                ],
                'meta',
            ])
            ->assertJson([
                'success' => true,
                'data' => [
                    'status' => 'ok',
                    'version' => 'v1',
                    'database' => 'connected',
                ],
            ]);
    }

    public function test_unknown_api_endpoint_returns_standard_404_error_envelope(): void
    {
        $response = $this->getJson('/api/v1/non-existent-endpoint');

        $response->assertStatus(404)
            ->assertJsonStructure([
                'success',
                'message',
                'errors',
                'code',
            ])
            ->assertJson([
                'success' => false,
                'code' => 'NOT_FOUND',
            ]);
    }

    public function test_unauthenticated_protected_endpoint_returns_standard_401_error_envelope(): void
    {
        $response = $this->getJson('/api/v1/auth/me');

        $response->assertStatus(401)
            ->assertJsonStructure([
                'success',
                'message',
                'errors',
                'code',
            ])
            ->assertJson([
                'success' => false,
                'code' => 'UNAUTHENTICATED',
            ]);
    }

    public function test_authenticated_user_with_uuid_can_access_me_endpoint_via_sanctum(): void
    {
        $user = User::factory()->create();
        Sanctum::actingAs($user);

        $response = $this->getJson('/api/v1/auth/me');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                ],
            ]);
    }
}


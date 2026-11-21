<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('devices', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('device_name', 100);
            $table->string('platform', 20)->default('android');
            $table->string('app_version', 30)->nullable();
            $table->dateTime('last_sync_at', 3)->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps(3);

            $table->unique(['id', 'user_id'], 'devices_id_user_unique');
            $table->index(['user_id', 'is_active'], 'devices_user_active_index');
        });

        Schema::create('user_settings', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->string('theme_mode', 20)->default('system');
            $table->char('currency', 3)->default('IDR');
            $table->string('timezone', 50)->default('Asia/Jakarta');
            $table->unsignedTinyInteger('budget_warning_percent')->default(80);
            $table->boolean('notifications_enabled')->default(true);
            $table->unsignedInteger('version')->default(1);
            $table->timestamps(3);
        });

        Schema::create('sync_sequences', function (Blueprint $table) {
            $table->uuid('user_id')->primary();
            $table->unsignedBigInteger('last_sequence')->default(0);

            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sync_sequences');
        Schema::dropIfExists('user_settings');
        Schema::dropIfExists('devices');
    }
};


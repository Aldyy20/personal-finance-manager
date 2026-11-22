<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('email_otp_codes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->string('email', 191)->index();
            $table->string('purpose', 32);
            $table->string('code_hash', 255);
            $table->unsignedTinyInteger('attempts')->default(0);
            $table->dateTime('expires_at', 3);
            $table->dateTime('used_at', 3)->nullable();
            $table->dateTime('created_at', 3)->nullable();

            $table->index(['email', 'purpose', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('email_otp_codes');
    }
};


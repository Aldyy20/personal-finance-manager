<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transaction_revisions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('transaction_id');
            $table->foreignUuid('user_id')->constrained('users')->restrictOnDelete();
            $table->unsignedInteger('revision_number');
            $table->string('action', 20);
            $table->json('before_data')->nullable();
            $table->json('after_data')->nullable();
            $table->string('reason', 255)->nullable();
            $table->uuid('device_id')->nullable();
            $table->dateTime('created_at', 3);

            $table->unique(['transaction_id', 'revision_number'], 'revisions_tx_number_unique');
            $table->index(['user_id', 'transaction_id'], 'revisions_user_tx_index');

            $table->foreign(['transaction_id', 'user_id'], 'revisions_tx_composite_fk')
                ->references(['id', 'user_id'])
                ->on('transactions')
                ->restrictOnDelete();

            $table->foreign(['device_id', 'user_id'], 'revisions_device_composite_fk')
                ->references(['id', 'user_id'])
                ->on('devices')
                ->restrictOnDelete();
        });

        Schema::create('receipts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('transaction_id');
            $table->foreignUuid('user_id')->constrained('users')->restrictOnDelete();
            $table->string('file_path', 500);
            $table->string('file_name', 255)->nullable();
            $table->string('mime_type', 100);
            $table->unsignedBigInteger('file_size');
            $table->string('checksum', 64)->nullable();
            $table->longText('ocr_text')->nullable();
            $table->json('extracted_data')->nullable();
            $table->unsignedInteger('version')->default(1);
            $table->timestamps(3);
            $table->softDeletes('deleted_at', 3);

            $table->index(['user_id', 'transaction_id'], 'receipts_user_tx_index');

            $table->foreign(['transaction_id', 'user_id'], 'receipts_tx_composite_fk')
                ->references(['id', 'user_id'])
                ->on('transactions')
                ->restrictOnDelete();
        });

        Schema::create('budgets', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->restrictOnDelete();
            $table->string('name', 100);
            $table->string('period_type', 20)->default('monthly');
            $table->date('start_date');
            $table->date('end_date');
            $table->unsignedBigInteger('total_limit')->nullable();
            $table->unsignedTinyInteger('warning_percent')->default(80);
            $table->boolean('is_active')->default(true);
            $table->unsignedInteger('version')->default(1);
            $table->timestamps(3);
            $table->softDeletes('deleted_at', 3);

            $table->unique(['id', 'user_id'], 'budgets_id_user_unique');
            $table->index(['user_id', 'start_date', 'end_date', 'is_active'], 'budgets_lookup_index');
        });

        Schema::create('budget_categories', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->restrictOnDelete();
            $table->uuid('budget_id');
            $table->uuid('category_id');
            $table->string('category_type', 20)->default('expense');
            $table->unsignedBigInteger('amount_limit');
            $table->unsignedInteger('version')->default(1);
            $table->timestamps(3);
            $table->softDeletes('deleted_at', 3);

            $table->unique(['budget_id', 'category_id'], 'budget_categories_unique');

            $table->foreign(['budget_id', 'user_id'], 'budget_categories_budget_fk')
                ->references(['id', 'user_id'])
                ->on('budgets')
                ->cascadeOnDelete();

            $table->foreign(['category_id', 'user_id', 'category_type'], 'budget_categories_category_fk')
                ->references(['id', 'user_id', 'type'])
                ->on('categories')
                ->restrictOnDelete();
        });

        Schema::create('sync_operations', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->uuid('device_id');
            $table->uuid('operation_id');
            $table->string('entity_type', 50);
            $table->uuid('entity_id');
            $table->string('operation_type', 20);
            $table->string('status', 20);
            $table->json('response_data')->nullable();
            $table->dateTime('created_at', 3);

            $table->unique(['user_id', 'operation_id'], 'sync_operations_idempotency_unique');
            $table->index(['user_id', 'device_id', 'created_at'], 'sync_operations_device_index');

            $table->foreign(['device_id', 'user_id'], 'sync_operations_device_fk')
                ->references(['id', 'user_id'])
                ->on('devices')
                ->restrictOnDelete();
        });

        Schema::create('sync_cursors', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->cascadeOnDelete();
            $table->uuid('device_id');
            $table->unsignedBigInteger('last_cursor')->default(0);
            $table->dateTime('last_sync_at', 3)->nullable();
            $table->timestamps(3);

            $table->unique(['user_id', 'device_id'], 'sync_cursors_user_device_unique');

            $table->foreign(['device_id', 'user_id'], 'sync_cursors_device_fk')
                ->references(['id', 'user_id'])
                ->on('devices')
                ->cascadeOnDelete();
        });

        Schema::create('sync_changes', function (Blueprint $table) {
            $table->uuid('user_id');
            $table->unsignedBigInteger('sequence');
            $table->string('entity_type', 50);
            $table->uuid('entity_id');
            $table->string('operation', 20);
            $table->unsignedInteger('entity_version');
            $table->dateTime('created_at', 3);

            $table->primary(['user_id', 'sequence'], 'sync_changes_pk');
            $table->index(['user_id', 'entity_type', 'entity_id'], 'sync_changes_entity_index');

            $table->foreign('user_id', 'sync_changes_user_fk')
                ->references('id')
                ->on('users')
                ->cascadeOnDelete();
        });

        if (in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
            DB::statement("ALTER TABLE budgets ADD CONSTRAINT chk_budgets_date_range CHECK (end_date >= start_date)");
            DB::statement("ALTER TABLE budget_categories ADD CONSTRAINT chk_budget_categories_expense_only CHECK (category_type = 'expense')");
            DB::statement("ALTER TABLE budget_categories ADD CONSTRAINT chk_budget_categories_limit_positive CHECK (amount_limit > 0)");
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('sync_changes');
        Schema::dropIfExists('sync_cursors');
        Schema::dropIfExists('sync_operations');
        Schema::dropIfExists('budget_categories');
        Schema::dropIfExists('budgets');
        Schema::dropIfExists('receipts');
        Schema::dropIfExists('transaction_revisions');
    }
};


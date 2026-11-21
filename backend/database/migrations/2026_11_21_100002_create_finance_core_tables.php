<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('accounts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->restrictOnDelete();
            $table->string('name', 100);
            $table->string('account_type', 20);
            $table->string('institution_name', 100)->nullable();
            $table->string('account_number', 50)->nullable();
            $table->bigInteger('opening_balance')->default(0);
            $table->date('opening_balance_date');
            $table->bigInteger('balance_cache')->default(0);
            $table->string('icon', 50)->nullable();
            $table->string('color', 20)->nullable();
            $table->boolean('is_active')->default(true);
            $table->unsignedInteger('version')->default(1);
            $table->timestamps(3);
            $table->softDeletes('deleted_at', 3);

            $table->unique(['id', 'user_id'], 'accounts_id_user_unique');
            $table->index(['user_id', 'is_active'], 'accounts_user_active_index');
        });

        Schema::create('categories', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->restrictOnDelete();
            $table->string('name', 100);
            $table->string('type', 20);
            $table->string('icon', 50)->nullable();
            $table->string('color', 20)->nullable();
            $table->boolean('is_default')->default(false);
            $table->boolean('is_active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->unsignedInteger('version')->default(1);
            $table->timestamps(3);
            $table->softDeletes('deleted_at', 3);

            $table->unique(['id', 'user_id'], 'categories_id_user_unique');
            $table->unique(['id', 'user_id', 'type'], 'categories_id_user_type_unique');
            $table->index(['user_id', 'type', 'is_active', 'sort_order'], 'categories_lookup_index');
        });

        Schema::create('transactions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->restrictOnDelete();
            $table->string('type', 20);
            $table->uuid('category_id')->nullable();
            $table->string('category_type', 20)->nullable();
            $table->unsignedBigInteger('amount');
            $table->dateTime('transaction_date', 3);
            $table->string('description', 255)->nullable();
            $table->text('notes')->nullable();
            $table->string('status', 20)->default('posted');
            $table->uuid('created_by_device_id')->nullable();
            $table->unsignedInteger('version')->default(1);
            $table->timestamps(3);
            $table->softDeletes('deleted_at', 3);

            $table->unique(['id', 'user_id'], 'transactions_id_user_unique');
            $table->index(['user_id', 'transaction_date'], 'transactions_user_date_index');
            $table->index(['user_id', 'type', 'status', 'transaction_date'], 'transactions_filter_index');
            $table->index(['user_id', 'category_id', 'transaction_date'], 'transactions_category_date_index');

            $table->foreign(['category_id', 'user_id', 'category_type'], 'transactions_category_composite_fk')
                ->references(['id', 'user_id', 'type'])
                ->on('categories')
                ->restrictOnDelete();

            $table->foreign(['created_by_device_id', 'user_id'], 'transactions_device_composite_fk')
                ->references(['id', 'user_id'])
                ->on('devices')
                ->restrictOnDelete();
        });

        Schema::create('account_adjustments', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->restrictOnDelete();
            $table->uuid('account_id');
            $table->bigInteger('amount_signed');
            $table->string('reason', 255);
            $table->uuid('created_by_device_id')->nullable();
            $table->dateTime('created_at', 3);

            $table->unique(['id', 'user_id'], 'account_adjustments_id_user_unique');
            $table->index(['user_id', 'account_id', 'created_at'], 'account_adjustments_lookup_index');

            $table->foreign(['account_id', 'user_id'], 'adjustments_account_composite_fk')
                ->references(['id', 'user_id'])
                ->on('accounts')
                ->restrictOnDelete();

            $table->foreign(['created_by_device_id', 'user_id'], 'adjustments_device_composite_fk')
                ->references(['id', 'user_id'])
                ->on('devices')
                ->restrictOnDelete();
        });

        Schema::create('account_movements', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('user_id')->constrained('users')->restrictOnDelete();
            $table->uuid('account_id');
            $table->uuid('transaction_id')->nullable();
            $table->uuid('adjustment_id')->nullable();
            $table->uuid('posting_group_id');
            $table->string('movement_type', 20);
            $table->bigInteger('amount_signed');
            $table->uuid('reversal_of_id')->nullable()->unique('account_movements_reversal_unique');
            $table->dateTime('created_at', 3);

            $table->index(['user_id', 'account_id', 'created_at'], 'movements_user_account_date_index');
            $table->index(['transaction_id'], 'movements_transaction_index');
            $table->index(['posting_group_id'], 'movements_posting_group_index');

            $table->foreign(['account_id', 'user_id'], 'movements_account_composite_fk')
                ->references(['id', 'user_id'])
                ->on('accounts')
                ->restrictOnDelete();

            $table->foreign(['transaction_id', 'user_id'], 'movements_transaction_composite_fk')
                ->references(['id', 'user_id'])
                ->on('transactions')
                ->restrictOnDelete();

            $table->foreign(['adjustment_id', 'user_id'], 'movements_adjustment_composite_fk')
                ->references(['id', 'user_id'])
                ->on('account_adjustments')
                ->restrictOnDelete();

            $table->foreign('reversal_of_id', 'movements_reversal_self_fk')
                ->references('id')
                ->on('account_movements')
                ->restrictOnDelete();
        });

        if (in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
            DB::statement("ALTER TABLE transactions ADD CONSTRAINT chk_transactions_amount_positive CHECK (amount > 0)");
            DB::statement("ALTER TABLE transactions ADD CONSTRAINT chk_transactions_category_rule CHECK ((type = 'transfer' AND category_id IS NULL AND category_type IS NULL) OR (type IN ('income', 'expense') AND category_id IS NOT NULL AND category_type = type))");
            DB::statement("ALTER TABLE account_adjustments ADD CONSTRAINT chk_adjustments_nonzero CHECK (amount_signed <> 0)");
            DB::statement("ALTER TABLE account_movements ADD CONSTRAINT chk_movements_amount_rule CHECK (movement_type = 'opening' OR amount_signed <> 0)");
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('account_movements');
        Schema::dropIfExists('account_adjustments');
        Schema::dropIfExists('transactions');
        Schema::dropIfExists('categories');
        Schema::dropIfExists('accounts');
    }
};


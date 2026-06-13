<?php
// database/migrations/2026_06_13_000015_create_organization_members_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('organization_members', function (Blueprint $table) {
            $table->uuid('id')->primary()->default(DB::raw('(UUID())'));
            $table->uuid('organization_id');
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->enum('role', ['leader', 'vice_leader', 'secretary', 'treasurer', 'member'])->default('member');
            $table->timestamp('joined_at')->useCurrent();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->foreign('organization_id')
                ->references('id')
                ->on('organizations')
                ->cascadeOnDelete();

            $table->unique(['organization_id', 'user_id']);
            $table->index('user_id');
            $table->index('organization_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('organization_members');
    }
};

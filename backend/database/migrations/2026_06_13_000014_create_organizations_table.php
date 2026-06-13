<?php
// database/migrations/2026_06_13_000014_create_organizations_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('organizations', function (Blueprint $table) {
            $table->uuid('id')->primary()->default(DB::raw('(UUID())'));
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('logo_url')->nullable();
            $table->enum('category', ['hima', 'bem', 'ukm', 'community', 'other'])->default('other');
            $table->foreignId('leader_id')->constrained('users')->cascadeOnDelete();
            $table->boolean('is_verified')->default(false);
            $table->unsignedInteger('member_count')->default(0);
            $table->timestamps();
            $table->softDeletes();

            $table->index('leader_id');
            $table->index('category');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('organizations');
    }
};

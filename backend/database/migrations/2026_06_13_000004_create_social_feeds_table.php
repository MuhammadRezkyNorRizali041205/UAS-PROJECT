<?php
// database/migrations/2026_06_13_000004_create_social_feeds_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('social_feeds', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->enum('type', ['task_completed', 'streak_milestone', 'badge_earned', 'level_up']);
            $table->string('title');
            $table->string('description');
            $table->json('achievement_data');
            $table->enum('visibility', ['public', 'friends'])->default('public');
            $table->unsignedInteger('likes_count')->default(0);
            $table->timestamps();

            $table->index('user_id');
            $table->index(['visibility', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('social_feeds');
    }
};

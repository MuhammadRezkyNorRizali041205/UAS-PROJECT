<?php
// database/migrations/2026_06_13_000005_create_feed_likes_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('feed_likes', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->uuid('feed_id');
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->timestamp('created_at')->useCurrent();

            $table->foreign('feed_id')
                ->references('id')
                ->on('social_feeds')
                ->cascadeOnDelete();

            $table->unique(['feed_id', 'user_id']);
            $table->index('feed_id');
            $table->index('user_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('feed_likes');
    }
};

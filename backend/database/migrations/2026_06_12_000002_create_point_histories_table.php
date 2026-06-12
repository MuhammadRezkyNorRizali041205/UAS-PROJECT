<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('point_histories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->integer('points'); // Positive = earn, negative = spend
            $table->enum('type', ['earn', 'spend'])->default('earn');
            $table->string('activity_type', 50); // login, view_schedule, complete_task, etc.
            $table->string('description')->nullable();
            $table->json('meta')->nullable(); // Extra context (quest_key, achievement_key, etc.)
            $table->timestamp('created_at')->useCurrent(); // Immutable history, no updated_at

            $table->index(['user_id', 'created_at']);
            $table->index(['user_id', 'activity_type']); // Needed for daily cap checks
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('point_histories');
    }
};

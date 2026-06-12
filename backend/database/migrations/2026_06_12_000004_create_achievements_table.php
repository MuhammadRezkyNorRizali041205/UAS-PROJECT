<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('achievements', function (Blueprint $table) {
            $table->id();
            $table->string('key', 60)->unique();   // e.g. 'streak_7', 'task_master_10'
            $table->string('title');
            $table->string('description');
            $table->string('icon', 10)->default('🏆');       // Emoji or icon name
            $table->string('badge_color', 7)->default('#6366F1'); // Hex color
            $table->enum('category', ['engagement', 'academic', 'social'])->default('engagement');
            $table->string('condition_type', 50);  // streak_days, task_count, login_count, etc.
            $table->unsignedInteger('condition_value');
            $table->unsignedSmallInteger('points_reward')->default(0);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('achievements');
    }
};

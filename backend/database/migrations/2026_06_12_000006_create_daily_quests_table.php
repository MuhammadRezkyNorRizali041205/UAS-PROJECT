<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('daily_quests', function (Blueprint $table) {
            $table->id();
            $table->string('key', 60)->unique();          // e.g. 'daily_login', 'view_schedule_once'
            $table->string('title');
            $table->string('description');
            $table->string('icon', 10)->default('⭐');
            $table->string('activity_type', 50);          // Must match UserActivity::type
            $table->unsignedSmallInteger('target_count')->default(1); // How many times needed
            $table->unsignedSmallInteger('points_reward');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('daily_quests');
    }
};

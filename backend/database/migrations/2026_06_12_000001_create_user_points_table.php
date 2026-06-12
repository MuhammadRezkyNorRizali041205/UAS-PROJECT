<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_points', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->unsignedInteger('total_points')->default(0);
            $table->enum('level', ['bronze', 'silver', 'gold', 'platinum', 'diamond'])->default('bronze');
            $table->unsignedInteger('current_level_points')->default(0);
            $table->unsignedInteger('next_level_threshold')->default(500);
            $table->timestamps();

            $table->index('total_points'); // Needed for fast leaderboard ORDER BY
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_points');
    }
};

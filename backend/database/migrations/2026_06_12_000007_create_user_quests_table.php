<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_quests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('quest_id')->constrained('daily_quests')->cascadeOnDelete();
            $table->date('quest_date');
            $table->unsignedSmallInteger('progress')->default(0);
            $table->boolean('is_completed')->default(false);
            $table->timestamp('completed_at')->nullable();
            $table->timestamp('created_at')->useCurrent();
            $table->timestamp('updated_at')->useCurrent()->useCurrentOnUpdate();

            $table->unique(['user_id', 'quest_id', 'quest_date']); // One progress record per user per quest per day
            $table->index(['user_id', 'quest_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_quests');
    }
};

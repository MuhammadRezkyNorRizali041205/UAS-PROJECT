<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notification_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('type', 50);
            $table->string('title');
            $table->text('body');
            $table->jsonb('data')->nullable();
            $table->timestamp('sent_at')->useCurrent();
            $table->timestamp('read_at')->nullable();
            $table->string('fcm_message_id')->nullable();

            $table->index(['user_id', 'sent_at']);
        });

        Schema::create('user_activities', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('type', 50);
            $table->jsonb('meta')->nullable();
            $table->date('activity_date');
            $table->timestamp('created_at')->useCurrent();

            $table->index(['user_id', 'activity_date']);
            $table->index('activity_date');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_activities');
        Schema::dropIfExists('notification_logs');
    }
};

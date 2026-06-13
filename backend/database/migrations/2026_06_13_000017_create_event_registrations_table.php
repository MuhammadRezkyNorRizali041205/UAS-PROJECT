<?php
// database/migrations/2026_06_13_000017_create_event_registrations_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('event_registrations', function (Blueprint $table) {
            $table->uuid('id')->primary()->default(DB::raw('(UUID())'));
            $table->uuid('event_id');
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->timestamp('registered_at')->useCurrent();
            $table->enum('status', ['registered', 'attended', 'cancelled'])->default('registered');
            $table->timestamps();

            $table->foreign('event_id')
                ->references('id')
                ->on('organization_events')
                ->cascadeOnDelete();

            $table->unique(['event_id', 'user_id']);
            $table->index('user_id');
            $table->index('event_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('event_registrations');
    }
};

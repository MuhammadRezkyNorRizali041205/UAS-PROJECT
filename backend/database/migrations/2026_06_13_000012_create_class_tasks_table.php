<?php
// database/migrations/2026_06_13_000012_create_class_tasks_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('class_tasks', function (Blueprint $table) {
            $table->uuid('id')->primary()->default(DB::raw('(UUID())'));
            $table->uuid('class_id');
            $table->foreignId('created_by')->constrained('users')->cascadeOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->dateTime('deadline');
            $table->unsignedSmallInteger('max_score')->default(100);
            $table->string('attachment_url')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->foreign('class_id')
                ->references('id')
                ->on('classes')
                ->cascadeOnDelete();

            $table->index('class_id');
            $table->index('deadline');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('class_tasks');
    }
};

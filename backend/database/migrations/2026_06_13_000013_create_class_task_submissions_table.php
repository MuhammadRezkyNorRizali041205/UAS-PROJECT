<?php
// database/migrations/2026_06_13_000013_create_class_task_submissions_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('class_task_submissions', function (Blueprint $table) {
            $table->uuid('id')->primary()->default(DB::raw('(UUID())'));
            $table->uuid('class_task_id');
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->text('content')->nullable();
            $table->string('attachment_url')->nullable();
            $table->unsignedSmallInteger('score')->nullable();
            $table->text('feedback')->nullable();
            $table->enum('status', ['pending', 'submitted', 'graded', 'late'])->default('pending');
            $table->timestamp('submitted_at')->nullable();
            $table->timestamp('graded_at')->nullable();
            $table->timestamps();

            $table->foreign('class_task_id')
                ->references('id')
                ->on('class_tasks')
                ->cascadeOnDelete();

            $table->index('student_id');
            $table->index('class_task_id');
            $table->index('status');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('class_task_submissions');
    }
};

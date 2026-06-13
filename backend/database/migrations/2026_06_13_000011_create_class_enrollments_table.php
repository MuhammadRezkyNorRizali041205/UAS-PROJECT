<?php
// database/migrations/2026_06_13_000011_create_class_enrollments_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('class_enrollments', function (Blueprint $table) {
            $table->uuid('id')->primary()->default(DB::raw('(UUID())'));
            $table->uuid('class_id');
            $table->foreignId('student_id')->constrained('users')->cascadeOnDelete();
            $table->timestamp('enrolled_at')->useCurrent();
            $table->enum('status', ['active', 'dropped', 'completed'])->default('active');
            $table->timestamps();

            $table->foreign('class_id')
                ->references('id')
                ->on('classes')
                ->cascadeOnDelete();

            $table->unique(['class_id', 'student_id']);
            $table->index('student_id');
            $table->index('class_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('class_enrollments');
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->enum('category', ['kuliah', 'praktikum', 'seminar', 'organisasi', 'tugas', 'ujian', 'custom']);
            $table->tinyInteger('day_of_week'); // 0=Sun, 1=Mon ... 6=Sat
            $table->time('start_time');
            $table->time('end_time');
            $table->string('room', 100)->nullable();
            $table->string('lecturer')->nullable();
            $table->enum('recurrence', ['once', 'weekly', 'biweekly'])->default('weekly');
            $table->date('start_date');
            $table->date('end_date')->nullable();
            $table->string('color_tag', 7)->default('#6C63FF');
            $table->boolean('is_active')->default(true);
            $table->timestamps();
            $table->softDeletes();

            $table->index(['user_id', 'day_of_week']);
            $table->index(['user_id', 'start_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('schedules');
    }
};

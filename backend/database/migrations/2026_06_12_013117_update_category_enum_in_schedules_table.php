<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Rename existing Indonesian values to English before changing the ENUM
        DB::statement("UPDATE schedules SET category = 'lecture'      WHERE category = 'kuliah'");
        DB::statement("UPDATE schedules SET category = 'practicum'    WHERE category = 'praktikum'");
        DB::statement("UPDATE schedules SET category = 'organization' WHERE category = 'organisasi'");
        DB::statement("UPDATE schedules SET category = 'task'         WHERE category = 'tugas'");
        DB::statement("UPDATE schedules SET category = 'exam'         WHERE category = 'ujian'");

        DB::statement("ALTER TABLE schedules MODIFY COLUMN category ENUM('lecture','practicum','seminar','organization','task','exam','custom') NOT NULL");
    }

    public function down(): void
    {
        DB::statement("UPDATE schedules SET category = 'kuliah'      WHERE category = 'lecture'");
        DB::statement("UPDATE schedules SET category = 'praktikum'   WHERE category = 'practicum'");
        DB::statement("UPDATE schedules SET category = 'organisasi'  WHERE category = 'organization'");
        DB::statement("UPDATE schedules SET category = 'tugas'       WHERE category = 'task'");
        DB::statement("UPDATE schedules SET category = 'ujian'       WHERE category = 'exam'");

        DB::statement("ALTER TABLE schedules MODIFY COLUMN category ENUM('kuliah','praktikum','seminar','organisasi','tugas','ujian','custom') NOT NULL");
    }
};

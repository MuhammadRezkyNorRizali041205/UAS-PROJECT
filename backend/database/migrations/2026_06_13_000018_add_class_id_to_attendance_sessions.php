<?php
// database/migrations/2026_06_13_000018_add_class_id_to_attendance_sessions.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('attendance_sessions', function (Blueprint $table) {
            $table->string('class_id', 36)->nullable()->after('creator_id');
            $table->index('class_id');
        });
    }

    public function down(): void
    {
        Schema::table('attendance_sessions', function (Blueprint $table) {
            $table->dropIndex(['class_id']);
            $table->dropColumn('class_id');
        });
    }
};

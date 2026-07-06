<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('kelas_mata_kuliah', function (Blueprint $table) {
            $table->timestamp('deadline')->nullable()->after('dosen_id');
            $table->string('judul_tugas')->nullable()->after('deadline');
        });
    }

    public function down(): void
    {
        Schema::table('kelas_mata_kuliah', function (Blueprint $table) {
            $table->dropColumn(['deadline', 'judul_tugas']);
        });
    }
};

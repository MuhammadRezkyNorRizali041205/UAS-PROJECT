<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tugas', function (Blueprint $table) {
            $table->id();
            $table->foreignId('mahasiswa_id')->constrained('mahasiswas')->cascadeOnDelete();
            $table->foreignId('kelas_mata_kuliah_id')->constrained('kelas_mata_kuliah')->cascadeOnDelete();
            $table->string('judul_project', 255);
            $table->string('file_database', 512)->nullable(); // path to .sql file
            $table->string('file_laporan', 512)->nullable();  // path to .doc/.docx file
            $table->string('link_gdrive', 512)->nullable();
            $table->string('link_github', 512)->nullable();
            $table->string('link_youtube', 512)->nullable();
            $table->enum('status', ['dikumpulkan', 'terlambat', 'belum'])->default('dikumpulkan');
            $table->timestamp('submitted_at')->nullable();
            $table->timestamps();

            $table->unique(['mahasiswa_id', 'kelas_mata_kuliah_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tugas');
    }
};

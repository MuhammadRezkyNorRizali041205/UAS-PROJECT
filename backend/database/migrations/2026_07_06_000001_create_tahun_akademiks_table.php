<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tahun_akademiks', function (Blueprint $table) {
            $table->id();
            $table->string('nama', 20); // e.g. "2025/2026"
            $table->boolean('status_aktif')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tahun_akademiks');
    }
};

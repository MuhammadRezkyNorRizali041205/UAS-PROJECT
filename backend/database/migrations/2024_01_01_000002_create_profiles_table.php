<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->string('avatar_url', 512)->nullable();
            $table->text('bio')->nullable();
            $table->string('phone', 20)->nullable();
            $table->string('faculty')->nullable();
            $table->string('major')->nullable();
            $table->string('student_id', 50)->nullable();
            $table->smallInteger('year_entry')->nullable();
            $table->jsonb('notification_prefs')->default('{"schedule":true,"task":true,"announcement":true,"attendance":true}');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('profiles');
    }
};

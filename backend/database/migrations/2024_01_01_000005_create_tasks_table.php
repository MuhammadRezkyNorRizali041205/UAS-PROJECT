<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('task_categories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name', 100);
            $table->string('color', 7)->default('#6C63FF');
            $table->string('icon', 50)->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->index('user_id');
        });

        Schema::create('tasks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->foreignId('category_id')->nullable()->constrained('task_categories')->nullOnDelete();
            $table->string('title');
            $table->text('description')->nullable();
            $table->enum('priority', ['low', 'medium', 'high', 'critical'])->default('medium');
            $table->enum('status', ['pending', 'in_progress', 'completed', 'overdue'])->default('pending');
            $table->timestamp('deadline')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->boolean('reminder_sent')->default(false);
            $table->timestamps();
            $table->softDeletes();

            $table->index(['user_id', 'status']);
            $table->index(['user_id', 'deadline']);
            $table->index('deadline');
        });

        Schema::create('task_labels', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('name', 50);
            $table->string('color', 7)->default('#94A3B8');
        });

        Schema::create('task_label_pivot', function (Blueprint $table) {
            $table->foreignId('task_id')->constrained('tasks')->cascadeOnDelete();
            $table->foreignId('label_id')->constrained('task_labels')->cascadeOnDelete();
            $table->primary(['task_id', 'label_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('task_label_pivot');
        Schema::dropIfExists('task_labels');
        Schema::dropIfExists('tasks');
        Schema::dropIfExists('task_categories');
    }
};

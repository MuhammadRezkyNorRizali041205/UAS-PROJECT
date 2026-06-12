<?php
// app/Jobs/MarkOverdueTasks.php

namespace App\Jobs;

use App\Models\Task;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class MarkOverdueTasks implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function handle(): void
    {
        Task::whereNotIn('status', ['completed', 'overdue'])
            ->whereNotNull('deadline')
            ->where('deadline', '<', now())
            ->update(['status' => 'overdue']);
    }
}

<?php
// routes/console.php

use App\Jobs\MarkOverdueTasks;
use Illuminate\Support\Facades\Schedule;

// Run every hour to update overdue tasks
Schedule::job(new MarkOverdueTasks)->hourly();

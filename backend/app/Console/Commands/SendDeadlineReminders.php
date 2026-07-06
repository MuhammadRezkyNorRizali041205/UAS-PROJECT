<?php

namespace App\Console\Commands;

use App\Models\KelasMataKuliah;
use App\Models\Mahasiswa;
use App\Models\NotificationLog;
use App\Models\Tugas;
use Illuminate\Console\Command;

class SendDeadlineReminders extends Command
{
    protected $signature   = 'notifications:send-deadline-reminders';
    protected $description = 'Kirim pengingat deadline tugas UAS yang akan habis dalam 24 jam';

    public function handle(): void
    {
        $threshold = [now(), now()->addHours(24)];

        // kelas_mata_kuliah yang deadlinenya dalam 24 jam ke depan
        $kmks = KelasMataKuliah::with(['kelas', 'mataKuliah'])
            ->whereBetween('deadline', $threshold)
            ->get();

        if ($kmks->isEmpty()) {
            $this->info('Tidak ada deadline dalam 24 jam ke depan.');
            return;
        }

        $now = now();
        $inserted = 0;

        foreach ($kmks as $kmk) {
            $namaMk  = $kmk->mataKuliah?->nama_mk ?? 'Mata Kuliah';
            $deadline = $kmk->deadline->locale('id')->isoFormat('D MMMM YYYY, HH:mm');
            $hoursLeft = (int) now()->diffInHours($kmk->deadline, false);
            $label   = $hoursLeft <= 1 ? 'kurang dari 1 jam' : "$hoursLeft jam lagi";

            // Hanya mahasiswa yang belum mengumpulkan
            $sudahKumpul = Tugas::where('kelas_mata_kuliah_id', $kmk->id)
                ->whereIn('status', ['dikumpulkan', 'terlambat'])
                ->pluck('mahasiswa_id');

            $mahasiswas = Mahasiswa::where('kelas_id', $kmk->kelas_id)
                ->whereNotIn('id', $sudahKumpul)
                ->get();

            foreach ($mahasiswas as $mhs) {
                // Jangan duplikat — cek apakah sudah ada reminder hari ini
                $exists = NotificationLog::where('user_id', $mhs->user_id)
                    ->where('type', 'deadline_reminder')
                    ->whereRaw("data::jsonb->>'kelas_mata_kuliah_id' = ?", [$kmk->id])
                    ->whereDate('sent_at', today())
                    ->exists();

                if ($exists) continue;

                NotificationLog::create([
                    'user_id' => $mhs->user_id,
                    'type'    => 'deadline_reminder',
                    'title'   => "Deadline Segera: $namaMk",
                    'body'    => "Segera kumpulkan tugas \"$namaMk\"! Deadline $deadline ($label).",
                    'data'    => [
                        'kelas_mata_kuliah_id' => $kmk->id,
                        'nama_mk'  => $namaMk,
                        'deadline' => $kmk->deadline->toIso8601String(),
                        'hours_left' => $hoursLeft,
                    ],
                    'sent_at' => $now,
                ]);
                $inserted++;
            }
        }

        $this->info("Berhasil mengirim $inserted notifikasi pengingat deadline.");
    }
}

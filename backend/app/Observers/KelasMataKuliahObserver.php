<?php

namespace App\Observers;

use App\Models\KelasMataKuliah;
use App\Models\Mahasiswa;
use App\Models\NotificationLog;

class KelasMataKuliahObserver
{
    public function created(KelasMataKuliah $kmk): void
    {
        $kmk->load(['kelas', 'mataKuliah', 'dosen.user']);

        $namaMk  = $kmk->mataKuliah?->nama_mk ?? 'Mata Kuliah';
        $namaDosen = $kmk->dosen?->user?->name ?? 'Dosen';
        $judul   = $kmk->judul_tugas ?? "Tugas UAS $namaMk";
        $deadline = $kmk->deadline
            ? $kmk->deadline->locale('id')->isoFormat('D MMMM YYYY, HH:mm')
            : null;

        $body = $deadline
            ? "Dosen $namaDosen membuka pengumpulan \"$judul\". Deadline: $deadline."
            : "Dosen $namaDosen membuka pengumpulan \"$judul\".";

        // Notify all mahasiswas in the kelas
        $mahasiswaIds = Mahasiswa::where('kelas_id', $kmk->kelas_id)
            ->pluck('user_id');

        $now = now();
        $rows = $mahasiswaIds->map(fn ($uid) => [
            'user_id' => $uid,
            'type'    => 'new_assignment',
            'title'   => "Tugas Baru: $namaMk",
            'body'    => $body,
            'data'    => json_encode([
                'kelas_mata_kuliah_id' => $kmk->id,
                'nama_mk'  => $namaMk,
                'deadline' => $kmk->deadline?->toIso8601String(),
            ]),
            'sent_at' => $now,
        ])->all();

        NotificationLog::insert($rows);
    }

    public function updated(KelasMataKuliah $kmk): void
    {
        // Notify only if deadline changed
        if (! $kmk->wasChanged('deadline') || ! $kmk->deadline) {
            return;
        }

        $kmk->load(['kelas', 'mataKuliah', 'dosen.user']);

        $namaMk  = $kmk->mataKuliah?->nama_mk ?? 'Mata Kuliah';
        $deadline = $kmk->deadline->locale('id')->isoFormat('D MMMM YYYY, HH:mm');
        $body    = "Deadline pengumpulan \"$namaMk\" diperbarui menjadi $deadline.";

        $mahasiswaIds = Mahasiswa::where('kelas_id', $kmk->kelas_id)->pluck('user_id');
        $now = now();

        $rows = $mahasiswaIds->map(fn ($uid) => [
            'user_id' => $uid,
            'type'    => 'deadline_updated',
            'title'   => "Deadline Diperbarui: $namaMk",
            'body'    => $body,
            'data'    => json_encode([
                'kelas_mata_kuliah_id' => $kmk->id,
                'nama_mk'  => $namaMk,
                'deadline' => $kmk->deadline->toIso8601String(),
            ]),
            'sent_at' => $now,
        ])->all();

        NotificationLog::insert($rows);
    }
}

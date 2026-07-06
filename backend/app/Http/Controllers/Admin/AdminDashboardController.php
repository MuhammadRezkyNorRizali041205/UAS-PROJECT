<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Dosen;
use App\Models\Kelas;
use App\Models\Mahasiswa;
use App\Models\Tugas;

class AdminDashboardController extends Controller
{
    public function __invoke()
    {
        return view('admin.dashboard', [
            'counts' => [
                'mahasiswa' => Mahasiswa::count(),
                'dosen'     => Dosen::count(),
                'kelas'     => Kelas::count(),
                'tugas'     => Tugas::count(),
            ],
            'recentTugas' => Tugas::with([
                'mahasiswa.user',
                'kelasMataKuliah.mataKuliah',
            ])->latest()->limit(10)->get(),
        ]);
    }
}

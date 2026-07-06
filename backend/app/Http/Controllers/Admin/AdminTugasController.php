<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Tugas;

class AdminTugasController extends Controller
{
    public function index()
    {
        return view('admin.tugas.index', [
            'items' => Tugas::with([
                'mahasiswa.user',
                'kelasMataKuliah.mataKuliah',
                'kelasMataKuliah.kelas',
                'kelasMataKuliah.dosen.user',
            ])->latest()->get(),
        ]);
    }

    public function show(Tugas $tugas)
    {
        $tugas->load([
            'mahasiswa.user',
            'kelasMataKuliah.mataKuliah',
            'kelasMataKuliah.kelas',
            'kelasMataKuliah.dosen.user',
        ]);
        return view('admin.tugas.show', ['item' => $tugas]);
    }
}

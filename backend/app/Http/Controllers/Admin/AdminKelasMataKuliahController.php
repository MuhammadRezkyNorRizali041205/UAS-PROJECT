<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Dosen;
use App\Models\Kelas;
use App\Models\KelasMataKuliah;
use App\Models\MataKuliah;
use Illuminate\Http\Request;

class AdminKelasMataKuliahController extends Controller
{
    public function index()
    {
        return view('admin.kelas_mata_kuliah.index', [
            'items' => KelasMataKuliah::with([
                'kelas.tahunAkademik',
                'mataKuliah',
                'dosen.user',
            ])->withCount('tugas')->latest()->get(),
        ]);
    }

    public function create()
    {
        return view('admin.kelas_mata_kuliah.form', [
            'kelasList'   => Kelas::with('tahunAkademik')->get(),
            'mataKuliahs' => MataKuliah::all(),
            'dosens'      => Dosen::with('user')->get(),
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'kelas_id'       => 'required|exists:kelas,id',
            'mata_kuliah_id' => 'required|exists:mata_kuliahs,id',
            'dosen_id'       => 'required|exists:dosens,id',
        ]);
        KelasMataKuliah::create($data);
        return redirect()->route('admin.kelas-mata-kuliah.index')->with('success', 'Berhasil ditambahkan.');
    }

    public function edit(KelasMataKuliah $kelasMataKuliah)
    {
        return view('admin.kelas_mata_kuliah.form', [
            'item'        => $kelasMataKuliah,
            'kelasList'   => Kelas::with('tahunAkademik')->get(),
            'mataKuliahs' => MataKuliah::all(),
            'dosens'      => Dosen::with('user')->get(),
        ]);
    }

    public function update(Request $request, KelasMataKuliah $kelasMataKuliah)
    {
        $data = $request->validate([
            'kelas_id'       => 'required|exists:kelas,id',
            'mata_kuliah_id' => 'required|exists:mata_kuliahs,id',
            'dosen_id'       => 'required|exists:dosens,id',
        ]);
        $kelasMataKuliah->update($data);
        return redirect()->route('admin.kelas-mata-kuliah.index')->with('success', 'Berhasil diperbarui.');
    }

    public function destroy(KelasMataKuliah $kelasMataKuliah)
    {
        $kelasMataKuliah->delete();
        return back()->with('success', 'Berhasil dihapus.');
    }
}

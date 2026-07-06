<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Kelas;
use App\Models\ProgramStudi;
use App\Models\TahunAkademik;
use Illuminate\Http\Request;

class AdminKelasController extends Controller
{
    public function index()
    {
        return view('admin.kelas.index', [
            'items' => Kelas::with(['tahunAkademik', 'programStudi'])
                ->withCount('mahasiswas')
                ->latest()->get(),
        ]);
    }

    public function create()
    {
        return view('admin.kelas.form', [
            'tahunAkademiks' => TahunAkademik::all(),
            'programStudis'  => ProgramStudi::all(),
        ]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama_kelas'        => 'required|string|max:50',
            'tahun_akademik_id' => 'required|exists:tahun_akademiks,id',
            'program_studi_id'  => 'required|exists:program_studis,id',
        ]);
        Kelas::create($data);
        return redirect()->route('admin.kelas.index')->with('success', 'Kelas berhasil ditambahkan.');
    }

    public function edit(Kelas $kelas)
    {
        return view('admin.kelas.form', [
            'item'           => $kelas,
            'tahunAkademiks' => TahunAkademik::all(),
            'programStudis'  => ProgramStudi::all(),
        ]);
    }

    public function update(Request $request, Kelas $kelas)
    {
        $data = $request->validate([
            'nama_kelas'        => 'required|string|max:50',
            'tahun_akademik_id' => 'required|exists:tahun_akademiks,id',
            'program_studi_id'  => 'required|exists:program_studis,id',
        ]);
        $kelas->update($data);
        return redirect()->route('admin.kelas.index')->with('success', 'Berhasil diperbarui.');
    }

    public function destroy(Kelas $kelas)
    {
        $kelas->delete();
        return back()->with('success', 'Berhasil dihapus.');
    }
}

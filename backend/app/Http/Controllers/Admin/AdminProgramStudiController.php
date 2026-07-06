<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ProgramStudi;
use Illuminate\Http\Request;

class AdminProgramStudiController extends Controller
{
    public function index()
    {
        return view('admin.program_studis.index', ['items' => ProgramStudi::latest()->get()]);
    }

    public function create()
    {
        return view('admin.program_studis.form');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama_prodi' => 'required|string|max:100',
            'kode_prodi' => 'required|string|max:20|unique:program_studis',
        ]);
        ProgramStudi::create($data);
        return redirect()->route('admin.program-studi.index')->with('success', 'Program studi berhasil ditambahkan.');
    }

    public function edit(ProgramStudi $programStudi)
    {
        return view('admin.program_studis.form', ['item' => $programStudi]);
    }

    public function update(Request $request, ProgramStudi $programStudi)
    {
        $data = $request->validate([
            'nama_prodi' => 'required|string|max:100',
            'kode_prodi' => 'required|string|max:20|unique:program_studis,kode_prodi,' . $programStudi->id,
        ]);
        $programStudi->update($data);
        return redirect()->route('admin.program-studi.index')->with('success', 'Berhasil diperbarui.');
    }

    public function destroy(ProgramStudi $programStudi)
    {
        $programStudi->delete();
        return back()->with('success', 'Berhasil dihapus.');
    }
}

<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\MataKuliah;
use Illuminate\Http\Request;

class AdminMataKuliahController extends Controller
{
    public function index()
    {
        return view('admin.mata_kuliahs.index', ['items' => MataKuliah::latest()->get()]);
    }

    public function create()
    {
        return view('admin.mata_kuliahs.form');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama_mk' => 'required|string|max:100',
            'kode_mk' => 'required|string|max:20|unique:mata_kuliahs',
            'sks'     => 'required|integer|min:1|max:6',
        ]);
        MataKuliah::create($data);
        return redirect()->route('admin.mata-kuliah.index')->with('success', 'Mata kuliah berhasil ditambahkan.');
    }

    public function edit(MataKuliah $mataKuliah)
    {
        return view('admin.mata_kuliahs.form', ['item' => $mataKuliah]);
    }

    public function update(Request $request, MataKuliah $mataKuliah)
    {
        $data = $request->validate([
            'nama_mk' => 'required|string|max:100',
            'kode_mk' => 'required|string|max:20|unique:mata_kuliahs,kode_mk,' . $mataKuliah->id,
            'sks'     => 'required|integer|min:1|max:6',
        ]);
        $mataKuliah->update($data);
        return redirect()->route('admin.mata-kuliah.index')->with('success', 'Berhasil diperbarui.');
    }

    public function destroy(MataKuliah $mataKuliah)
    {
        $mataKuliah->delete();
        return back()->with('success', 'Berhasil dihapus.');
    }
}

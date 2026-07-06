<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\TahunAkademik;
use Illuminate\Http\Request;

class AdminTahunAkademikController extends Controller
{
    public function index()
    {
        return view('admin.tahun_akademiks.index', ['items' => TahunAkademik::latest()->get()]);
    }

    public function create()
    {
        return view('admin.tahun_akademiks.form');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'nama'         => 'required|string|max:20',
            'status_aktif' => 'nullable',
        ]);
        $data['status_aktif'] = $request->boolean('status_aktif');
        TahunAkademik::create($data);
        return redirect()->route('admin.tahun-akademik.index')->with('success', 'Tahun akademik berhasil ditambahkan.');
    }

    public function edit(TahunAkademik $tahunAkademik)
    {
        return view('admin.tahun_akademiks.form', ['item' => $tahunAkademik]);
    }

    public function update(Request $request, TahunAkademik $tahunAkademik)
    {
        $data = $request->validate([
            'nama'         => 'required|string|max:20',
            'status_aktif' => 'nullable',
        ]);
        $data['status_aktif'] = $request->boolean('status_aktif');
        $tahunAkademik->update($data);
        return redirect()->route('admin.tahun-akademik.index')->with('success', 'Berhasil diperbarui.');
    }

    public function destroy(TahunAkademik $tahunAkademik)
    {
        $tahunAkademik->delete();
        return back()->with('success', 'Berhasil dihapus.');
    }
}

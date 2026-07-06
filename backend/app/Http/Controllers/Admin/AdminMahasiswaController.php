<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Kelas;
use App\Models\Mahasiswa;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AdminMahasiswaController extends Controller
{
    public function index()
    {
        return view('admin.mahasiswas.index', [
            'items' => Mahasiswa::with(['user', 'kelas'])->latest()->get(),
        ]);
    }

    public function create()
    {
        return view('admin.mahasiswas.form', [
            'kelasList' => Kelas::with(['programStudi', 'tahunAkademik'])->get(),
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|email|unique:users',
            'password' => 'required|min:8',
            'nim'      => 'required|string|max:20|unique:mahasiswas',
            'no_hp'    => 'nullable|string|max:20',
            'kelas_id' => 'nullable|exists:kelas,id',
        ]);

        DB::transaction(function () use ($request) {
            $user = User::create([
                'name'     => $request->name,
                'email'    => $request->email,
                'password' => Hash::make($request->password),
                'role'     => 'student',
            ]);
            Mahasiswa::create([
                'user_id'  => $user->id,
                'nim'      => $request->nim,
                'no_hp'    => $request->no_hp,
                'kelas_id' => $request->kelas_id,
            ]);
        });

        return redirect()->route('admin.mahasiswa.index')->with('success', 'Mahasiswa berhasil ditambahkan.');
    }

    public function edit(Mahasiswa $mahasiswa)
    {
        return view('admin.mahasiswas.form', [
            'item'      => $mahasiswa->load('user'),
            'kelasList' => Kelas::with(['programStudi', 'tahunAkademik'])->get(),
        ]);
    }

    public function update(Request $request, Mahasiswa $mahasiswa)
    {
        $request->validate([
            'nim'      => 'required|string|max:20|unique:mahasiswas,nim,' . $mahasiswa->id,
            'no_hp'    => 'nullable|string|max:20',
            'kelas_id' => 'nullable|exists:kelas,id',
        ]);
        $mahasiswa->update([
            'nim'      => $request->nim,
            'no_hp'    => $request->no_hp,
            'kelas_id' => $request->kelas_id,
        ]);
        return redirect()->route('admin.mahasiswa.index')->with('success', 'Berhasil diperbarui.');
    }

    public function destroy(Mahasiswa $mahasiswa)
    {
        $mahasiswa->user->delete();
        return back()->with('success', 'Berhasil dihapus.');
    }
}

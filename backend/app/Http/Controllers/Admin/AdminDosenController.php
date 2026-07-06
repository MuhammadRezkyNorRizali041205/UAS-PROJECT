<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Dosen;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AdminDosenController extends Controller
{
    public function index()
    {
        return view('admin.dosens.index', [
            'items' => Dosen::with('user')->latest()->get(),
        ]);
    }

    public function create()
    {
        return view('admin.dosens.form');
    }

    public function store(Request $request)
    {
        $request->validate([
            'name'     => 'required|string|max:255',
            'email'    => 'required|email|unique:users',
            'password' => 'required|min:8',
            'nip_nidn' => 'nullable|string|max:30',
            'no_hp'    => 'nullable|string|max:20',
        ]);

        DB::transaction(function () use ($request) {
            $user = User::create([
                'name'     => $request->name,
                'email'    => $request->email,
                'password' => Hash::make($request->password),
                'role'     => 'lecturer',
            ]);
            Dosen::create([
                'user_id'  => $user->id,
                'nip_nidn' => $request->nip_nidn,
                'no_hp'    => $request->no_hp,
            ]);
        });

        return redirect()->route('admin.dosen.index')->with('success', 'Dosen berhasil ditambahkan.');
    }

    public function edit(Dosen $dosen)
    {
        return view('admin.dosens.form', ['item' => $dosen->load('user')]);
    }

    public function update(Request $request, Dosen $dosen)
    {
        $request->validate([
            'nip_nidn' => 'nullable|string|max:30',
            'no_hp'    => 'nullable|string|max:20',
        ]);
        $dosen->update([
            'nip_nidn' => $request->nip_nidn,
            'no_hp'    => $request->no_hp,
        ]);
        return redirect()->route('admin.dosen.index')->with('success', 'Berhasil diperbarui.');
    }

    public function destroy(Dosen $dosen)
    {
        $dosen->user->delete();
        return back()->with('success', 'Berhasil dihapus.');
    }
}

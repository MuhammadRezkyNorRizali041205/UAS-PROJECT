<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\KelasMataKuliah;
use App\Models\Mahasiswa;
use App\Models\Tugas;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class TugasController extends Controller
{
    use ApiResponse;

    public function mataKuliahSaya(Request $request): JsonResponse
    {
        $mahasiswa = Mahasiswa::where('user_id', $request->user()->id)->first();

        if (!$mahasiswa) {
            return $this->error('Data mahasiswa tidak ditemukan.', 404);
        }

        if (!$mahasiswa->kelas_id) {
            return $this->success(data: [], message: 'Belum terdaftar di kelas.');
        }

        $kelasMataKuliah = KelasMataKuliah::where('kelas_id', $mahasiswa->kelas_id)
            ->with(['mataKuliah', 'dosen.user', 'kelas.tahunAkademik'])
            ->get();

        $result = $kelasMataKuliah->map(function ($kmk) use ($mahasiswa) {
            $tugas = Tugas::where('mahasiswa_id', $mahasiswa->id)
                ->where('kelas_mata_kuliah_id', $kmk->id)
                ->first();

            return [
                'kelas_mata_kuliah_id' => $kmk->id,
                'nama_mk'              => $kmk->mataKuliah->nama_mk,
                'kode_mk'              => $kmk->mataKuliah->kode_mk,
                'sks'                  => $kmk->mataKuliah->sks,
                'nama_dosen'           => $kmk->dosen->user->name ?? '-',
                'tahun_akademik'       => $kmk->kelas->tahunAkademik->nama ?? '-',
                'sudah_dikumpulkan'    => $tugas !== null,
                'status_tugas'         => $tugas?->status,
                'tugas_id'             => $tugas?->id,
                'judul_project'        => $tugas?->judul_project,
                'submitted_at'         => $tugas?->submitted_at?->toIso8601String(),
            ];
        });

        return $this->success(data: $result);
    }

    public function store(Request $request): JsonResponse
    {
        $mahasiswa = Mahasiswa::where('user_id', $request->user()->id)->first();
        if (!$mahasiswa) {
            return $this->error('Data mahasiswa tidak ditemukan.', 404);
        }

        $data = $request->validate([
            'kelas_mata_kuliah_id' => 'required|exists:kelas_mata_kuliah,id',
            'judul_project'        => 'required|string|max:255',
            'file_database'        => 'nullable|file|mimes:sql,txt|max:10240',
            'file_laporan'         => 'nullable|file|mimes:doc,docx|max:10240',
            'link_gdrive'          => 'nullable|url|max:512',
            'link_github'          => 'nullable|url|max:512',
            'link_youtube'         => 'nullable|url|max:512',
        ]);

        // Verify this kelas_mata_kuliah belongs to student's class
        $kmk = KelasMataKuliah::findOrFail($data['kelas_mata_kuliah_id']);
        if ($kmk->kelas_id !== $mahasiswa->kelas_id) {
            return $this->error('Mata kuliah tidak sesuai kelas Anda.', 403);
        }

        $fileDatabasePath = null;
        $fileLaporanPath  = null;

        if ($request->hasFile('file_database')) {
            $fileDatabasePath = $request->file('file_database')
                ->store("tugas/{$mahasiswa->nim}/database", 'public');
        }
        if ($request->hasFile('file_laporan')) {
            $fileLaporanPath = $request->file('file_laporan')
                ->store("tugas/{$mahasiswa->nim}/laporan", 'public');
        }

        $tugas = Tugas::updateOrCreate(
            [
                'mahasiswa_id'         => $mahasiswa->id,
                'kelas_mata_kuliah_id' => $data['kelas_mata_kuliah_id'],
            ],
            [
                'judul_project' => $data['judul_project'],
                'file_database' => $fileDatabasePath,
                'file_laporan'  => $fileLaporanPath,
                'link_gdrive'   => $data['link_gdrive'] ?? null,
                'link_github'   => $data['link_github'] ?? null,
                'link_youtube'  => $data['link_youtube'] ?? null,
                'status'        => 'dikumpulkan',
                'submitted_at'  => now(),
            ]
        );

        return $this->success(data: $tugas, message: 'Tugas berhasil dikumpulkan.', code: 201);
    }

    public function riwayat(Request $request): JsonResponse
    {
        $mahasiswa = Mahasiswa::where('user_id', $request->user()->id)->first();
        if (!$mahasiswa) {
            return $this->success(data: []);
        }

        $tugas = Tugas::where('mahasiswa_id', $mahasiswa->id)
            ->with(['kelasMataKuliah.mataKuliah', 'kelasMataKuliah.dosen.user'])
            ->latest('submitted_at')
            ->get()
            ->map(fn ($t) => [
                'id'             => $t->id,
                'nama_mk'        => $t->kelasMataKuliah->mataKuliah->nama_mk ?? '-',
                'nama_dosen'     => $t->kelasMataKuliah->dosen->user->name ?? '-',
                'judul_project'  => $t->judul_project,
                'status'         => $t->status,
                'submitted_at'   => $t->submitted_at?->toIso8601String(),
                'link_gdrive'    => $t->link_gdrive,
                'link_github'    => $t->link_github,
                'link_youtube'   => $t->link_youtube,
                'has_file_db'    => (bool) $t->file_database,
                'has_file_lap'   => (bool) $t->file_laporan,
            ]);

        return $this->success(data: $tugas);
    }

    public function show(Request $request, Tugas $tugas): JsonResponse
    {
        $mahasiswa = Mahasiswa::where('user_id', $request->user()->id)->first();
        if (!$mahasiswa || $tugas->mahasiswa_id !== $mahasiswa->id) {
            return $this->error('Tidak ditemukan.', 404);
        }

        $tugas->load(['kelasMataKuliah.mataKuliah', 'kelasMataKuliah.dosen.user']);

        return $this->success(data: [
            'id'             => $tugas->id,
            'nama_mk'        => $tugas->kelasMataKuliah->mataKuliah->nama_mk ?? '-',
            'nama_dosen'     => $tugas->kelasMataKuliah->dosen->user->name ?? '-',
            'judul_project'  => $tugas->judul_project,
            'status'         => $tugas->status,
            'submitted_at'   => $tugas->submitted_at?->toIso8601String(),
            'link_gdrive'    => $tugas->link_gdrive,
            'link_github'    => $tugas->link_github,
            'link_youtube'   => $tugas->link_youtube,
            'file_database_url' => $tugas->file_database
                ? Storage::url($tugas->file_database) : null,
            'file_laporan_url'  => $tugas->file_laporan
                ? Storage::url($tugas->file_laporan) : null,
        ]);
    }

    public function profilMahasiswa(Request $request): JsonResponse
    {
        $mahasiswa = Mahasiswa::where('user_id', $request->user()->id)
            ->with(['user', 'kelas.programStudi', 'kelas.tahunAkademik'])
            ->first();

        if (!$mahasiswa) {
            return $this->error('Data mahasiswa tidak ditemukan.', 404);
        }

        return $this->success(data: [
            'name'           => $mahasiswa->user->name,
            'email'          => $mahasiswa->user->email,
            'nim'            => $mahasiswa->nim,
            'no_hp'          => $mahasiswa->no_hp,
            'nama_kelas'     => $mahasiswa->kelas?->nama_kelas,
            'nama_prodi'     => $mahasiswa->kelas?->programStudi?->nama_prodi,
            'tahun_akademik' => $mahasiswa->kelas?->tahunAkademik?->nama,
        ]);
    }
}

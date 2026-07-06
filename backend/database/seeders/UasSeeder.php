<?php

namespace Database\Seeders;

use App\Models\Dosen;
use App\Models\Kelas;
use App\Models\KelasMataKuliah;
use App\Models\Mahasiswa;
use App\Models\MataKuliah;
use App\Models\ProgramStudi;
use App\Models\TahunAkademik;
use App\Models\Tugas;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UasSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Tahun Akademik
        $ta = TahunAkademik::create(['nama' => '2025/2026', 'status_aktif' => true]);

        // 2. Program Studi
        $prodi = ProgramStudi::create(['nama_prodi' => 'Teknik Informatika', 'kode_prodi' => 'TI']);

        // 3. Kelas
        $kelas = Kelas::create([
            'nama_kelas'        => '4A TI',
            'tahun_akademik_id' => $ta->id,
            'program_studi_id'  => $prodi->id,
        ]);

        // 4. Mata Kuliah
        $mk1 = MataKuliah::create(['nama_mk' => 'Pemrograman Mobile (Flutter)', 'kode_mk' => 'MK-TI-01', 'sks' => 3]);
        $mk2 = MataKuliah::create(['nama_mk' => 'Rekayasa Perangkat Lunak', 'kode_mk' => 'MK-TI-02', 'sks' => 3]);

        // 5. Dosen
        $userDosen1 = User::create([
            'name'     => 'Budi Hartono, M.T.',
            'email'    => 'budi.hartono@poliban.ac.id',
            'password' => Hash::make('password123'),
            'role'     => 'lecturer',
        ]);
        $dosen1 = Dosen::create([
            'user_id'  => $userDosen1->id,
            'nip_nidn' => '0012345678',
            'no_hp'    => '0812345678',
        ]);

        $userDosen2 = User::create([
            'name'     => 'Siti Aminah, M.Kom.',
            'email'    => 'siti.aminah@poliban.ac.id',
            'password' => Hash::make('password123'),
            'role'     => 'lecturer',
        ]);
        $dosen2 = Dosen::create([
            'user_id'  => $userDosen2->id,
            'nip_nidn' => '0087654321',
            'no_hp'    => '0898765432',
        ]);

        // 6. Kelas Mata Kuliah
        $kmk1 = KelasMataKuliah::create([
            'kelas_id'       => $kelas->id,
            'mata_kuliah_id' => $mk1->id,
            'dosen_id'       => $dosen1->id,
        ]);
        $kmk2 = KelasMataKuliah::create([
            'kelas_id'       => $kelas->id,
            'mata_kuliah_id' => $mk2->id,
            'dosen_id'       => $dosen2->id,
        ]);

        // 7. Admin user
        User::firstOrCreate(
            ['email' => 'admin@poliban.ac.id'],
            [
                'name'     => 'Admin Poliban',
                'password' => Hash::make('admin123'),
                'role'     => 'admin',
            ]
        );

        // 8. Sample Mahasiswa
        $userMhs = User::create([
            'name'     => 'Muhammad Rezky Nor Rizali',
            'email'    => 'c050424037@mahasiswa.poliban.ac.id',
            'password' => Hash::make('password123'),
            'role'     => 'student',
        ]);
        $mhs = Mahasiswa::create([
            'user_id'  => $userMhs->id,
            'nim'      => 'C050424037',
            'no_hp'    => '0812345001',
            'kelas_id' => $kelas->id,
        ]);

        // 9. Sample Tugas
        Tugas::create([
            'mahasiswa_id'         => $mhs->id,
            'kelas_mata_kuliah_id' => $kmk1->id,
            'judul_project'        => 'Aplikasi SI Tugas Poliban',
            'link_github'          => 'https://github.com/example/si-tugas-poliban',
            'link_youtube'         => 'https://youtube.com/watch?v=example',
            'status'               => 'dikumpulkan',
            'submitted_at'         => now(),
        ]);
    }
}

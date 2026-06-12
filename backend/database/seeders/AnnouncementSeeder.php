<?php
// database/seeders/AnnouncementSeeder.php

namespace Database\Seeders;

use App\Models\Announcement;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AnnouncementSeeder extends Seeder
{
    public function run(): void
    {
        $author = User::where('email', 'test@ulm.ac.id')->first();
        if (!$author) return;

        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
        Announcement::truncate();
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        $announcements = [
            [
                'title'        => 'Pengumuman Ujian Akhir Semester Genap 2025/2026',
                'body'         => "Diberitahukan kepada seluruh mahasiswa Fakultas Teknik bahwa Ujian Akhir Semester (UAS) Genap Tahun Akademik 2025/2026 akan dilaksanakan mulai tanggal 23 Juni 2026 sampai dengan 4 Juli 2026.\n\nJadwal ujian dapat dilihat melalui portal akademik mahasiswa di portal.ulm.ac.id. Mahasiswa diwajibkan membawa:\n1. Kartu Tanda Mahasiswa (KTM) yang masih berlaku\n2. Kartu Ujian yang telah divalidasi oleh dosen wali\n3. Alat tulis masing-masing\n\nMahasiswa yang tidak dapat mengikuti ujian karena sakit atau keperluan mendesak wajib melaporkan ke bagian akademik maksimal 1x24 jam setelah ujian berlangsung dengan disertai surat keterangan yang sah.\n\nDemikian pengumuman ini disampaikan. Atas perhatiannya diucapkan terima kasih.",
                'category'     => 'academic',
                'is_urgent'    => true,
                'is_published' => true,
                'published_at' => now()->subDays(2),
                'expires_at'   => now()->addDays(30),
            ],
            [
                'title'        => 'Seminar Nasional Kecerdasan Buatan & IoT 2026',
                'body'         => "Program Studi Teknik Informatika Universitas Lambung Mangkurat dengan bangga mengundang seluruh mahasiswa, dosen, dan masyarakat umum untuk menghadiri Seminar Nasional bertema \"Kecerdasan Buatan dan Internet of Things dalam Transformasi Digital\" yang akan diselenggarakan pada:\n\nHari/Tanggal : Sabtu, 20 Juni 2026\nWaktu        : 08.00 - 17.00 WITA\nTempat       : Aula Utama Gedung Rektorat\n\nPembicara utama:\n• Prof. Dr. Bambang Nugroho (Universitas Indonesia) - \"AI dalam Pendidikan Masa Depan\"\n• Dr. Eng. Maya Sari (ITS Surabaya) - \"Smart Campus Implementation\"\n• Ir. Andi Wijaya (Google Indonesia) - \"Career in Tech: From Campus to Industry\"\n\nPendaftaran gratis untuk mahasiswa ULM. Sertifikat diberikan kepada peserta yang mengikuti seluruh rangkaian acara.\n\nDaftarkan diri Anda melalui link: bit.ly/semnas-ti-2026",
                'category'     => 'seminar',
                'is_urgent'    => false,
                'is_published' => true,
                'published_at' => now()->subDays(5),
                'expires_at'   => now()->addDays(8),
            ],
            [
                'title'        => 'Libur Hari Tahun Baru Islam 1448 H',
                'body'         => "Berdasarkan Surat Edaran Rektor Universitas Lambung Mangkurat Nomor 012/UN8/SE/2026, diberitahukan bahwa sehubungan dengan perayaan Tahun Baru Islam 1 Muharram 1448 H, kampus akan libur pada:\n\nHari/Tanggal : Senin, 16 Juni 2026\n\nSeluruh kegiatan akademik, administrasi, dan pelayanan kampus ditiadakan pada hari tersebut. Kegiatan belajar mengajar dapat dilanjutkan kembali pada hari Selasa, 17 Juni 2026.\n\nBagi mahasiswa yang memiliki jadwal kuliah atau praktikum pada hari Senin, silakan berkoordinasi dengan dosen pengampu untuk penjadwalan ulang.\n\nHarap maklum dan terima kasih atas perhatiannya.",
                'category'     => 'general',
                'is_urgent'    => false,
                'is_published' => true,
                'published_at' => now()->subDays(1),
                'expires_at'   => now()->addDays(14),
            ],
            [
                'title'        => 'Pendaftaran Beasiswa Prestasi Akademik 2026',
                'body'         => "Bagian Kemahasiswaan membuka pendaftaran Beasiswa Prestasi Akademik untuk Tahun Akademik 2026/2027. Beasiswa ini diperuntukkan bagi mahasiswa aktif semester 3-7 yang memiliki IPK minimal 3.50 dan aktif berorganisasi.\n\nDokumen yang diperlukan:\n1. Transkrip nilai terbaru (dilegalisir)\n2. Surat keterangan aktif mahasiswa\n3. Surat rekomendasi dari dosen wali\n4. Bukti keaktifan organisasi\n5. Essay motivasi (500-1000 kata)\n\nPendaftaran dibuka: 10 - 30 Juni 2026\nPengumuman hasil: 15 Juli 2026\n\nInformasi lebih lanjut hubungi Bagian Kemahasiswaan di Gedung Rektorat Lt. 2 atau email: kemahasiswaan@ulm.ac.id",
                'category'     => 'academic',
                'is_urgent'    => false,
                'is_published' => true,
                'published_at' => now()->subHours(6),
                'expires_at'   => now()->addDays(18),
            ],
        ];

        foreach ($announcements as $a) {
            Announcement::create(array_merge($a, ['author_id' => $author->id]));
        }
    }
}

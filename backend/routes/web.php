<?php

use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Admin\AdminDosenController;
use App\Http\Controllers\Admin\AdminKelasController;
use App\Http\Controllers\Admin\AdminKelasMataKuliahController;
use App\Http\Controllers\Admin\AdminMahasiswaController;
use App\Http\Controllers\Admin\AdminMataKuliahController;
use App\Http\Controllers\Admin\AdminProgramStudiController;
use App\Http\Controllers\Admin\AdminTahunAkademikController;
use App\Http\Controllers\Admin\AdminTugasController;
use Illuminate\Support\Facades\Route;

// ─── Admin Auth ───────────────────────────────────────────────────────────────
Route::get('/admin/login', [AdminAuthController::class, 'showLogin'])->name('admin.login');
Route::post('/admin/login', [AdminAuthController::class, 'login'])->name('admin.login.post');
Route::post('/admin/logout', [AdminAuthController::class, 'logout'])->name('admin.logout');

// ─── Admin (protected) ────────────────────────────────────────────────────────
Route::prefix('admin')->name('admin.')->middleware(['auth', 'admin.role'])->group(function () {

    Route::get('/', AdminDashboardController::class)->name('dashboard');

    // Tahun Akademik
    Route::resource('tahun-akademik', AdminTahunAkademikController::class)
        ->names('tahun-akademik')
        ->parameters(['tahun-akademik' => 'tahunAkademik']);

    // Program Studi
    Route::resource('program-studi', AdminProgramStudiController::class)
        ->names('program-studi')
        ->parameters(['program-studi' => 'programStudi']);

    // Mata Kuliah
    Route::resource('mata-kuliah', AdminMataKuliahController::class)
        ->names('mata-kuliah')
        ->parameters(['mata-kuliah' => 'mataKuliah']);

    // Dosen
    Route::resource('dosen', AdminDosenController::class)->names('dosen');

    // Kelas
    Route::resource('kelas', AdminKelasController::class)->names('kelas')->parameters(['kelas' => 'kelas']);

    // Kelas – Mata Kuliah
    Route::resource('kelas-mata-kuliah', AdminKelasMataKuliahController::class)
        ->names('kelas-mata-kuliah')
        ->parameters(['kelas-mata-kuliah' => 'kelasMataKuliah']);

    // Mahasiswa
    Route::resource('mahasiswa', AdminMahasiswaController::class)->names('mahasiswa');

    // Tugas (read-only)
    Route::get('tugas', [AdminTugasController::class, 'index'])->name('tugas.index');
    Route::get('tugas/{tugas}', [AdminTugasController::class, 'show'])->name('tugas.show');
});

// Default redirect
Route::get('/', fn () => redirect('/admin/login'));

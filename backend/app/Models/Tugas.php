<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Tugas extends Model
{
    protected $table = 'tugas';

    protected $fillable = [
        'mahasiswa_id',
        'kelas_mata_kuliah_id',
        'judul_project',
        'file_database',
        'file_laporan',
        'link_gdrive',
        'link_github',
        'link_youtube',
        'status',
        'submitted_at',
    ];

    protected function casts(): array
    {
        return ['submitted_at' => 'datetime'];
    }

    public function mahasiswa(): BelongsTo
    {
        return $this->belongsTo(Mahasiswa::class);
    }

    public function kelasMataKuliah(): BelongsTo
    {
        return $this->belongsTo(KelasMataKuliah::class);
    }
}

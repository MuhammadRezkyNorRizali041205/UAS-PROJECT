<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class KelasMataKuliah extends Model
{
    protected $table = 'kelas_mata_kuliah';

    protected $fillable = ['kelas_id', 'mata_kuliah_id', 'dosen_id', 'deadline', 'judul_tugas'];

    protected function casts(): array
    {
        return ['deadline' => 'datetime'];
    }

    public function kelas(): BelongsTo
    {
        return $this->belongsTo(Kelas::class);
    }

    public function mataKuliah(): BelongsTo
    {
        return $this->belongsTo(MataKuliah::class);
    }

    public function dosen(): BelongsTo
    {
        return $this->belongsTo(Dosen::class);
    }

    public function tugas(): HasMany
    {
        return $this->hasMany(Tugas::class);
    }
}

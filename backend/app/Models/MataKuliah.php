<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class MataKuliah extends Model
{
    protected $table = 'mata_kuliahs';

    protected $fillable = ['nama_mk', 'kode_mk', 'sks'];

    public function kelasMataKuliah(): HasMany
    {
        return $this->hasMany(KelasMataKuliah::class);
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class ProgramStudi extends Model
{
    protected $fillable = ['nama_prodi', 'kode_prodi'];

    public function kelas(): HasMany
    {
        return $this->hasMany(Kelas::class, 'program_studi_id');
    }
}

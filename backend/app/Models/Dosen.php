<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Dosen extends Model
{
    protected $table = 'dosens';

    protected $fillable = ['user_id', 'nip_nidn', 'no_hp'];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function kelasMataKuliah(): HasMany
    {
        return $this->hasMany(KelasMataKuliah::class);
    }
}

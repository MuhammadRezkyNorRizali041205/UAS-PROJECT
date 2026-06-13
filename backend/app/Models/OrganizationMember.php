<?php
// app/Models/OrganizationMember.php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class OrganizationMember extends Model
{
    use HasUuid;

    protected $fillable = [
        'organization_id', 'user_id', 'role', 'joined_at', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'joined_at' => 'datetime',
            'is_active' => 'boolean',
        ];
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

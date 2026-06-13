<?php
// app/Models/Organization.php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Organization extends Model
{
    use HasUuid, SoftDeletes;

    protected $fillable = [
        'name', 'description', 'logo_url', 'category',
        'leader_id', 'is_verified', 'member_count',
    ];

    protected function casts(): array
    {
        return [
            'is_verified'  => 'boolean',
            'member_count' => 'integer',
        ];
    }

    public function leader(): BelongsTo
    {
        return $this->belongsTo(User::class, 'leader_id');
    }

    public function members(): HasMany
    {
        return $this->hasMany(OrganizationMember::class);
    }

    public function activeMembers(): HasMany
    {
        return $this->hasMany(OrganizationMember::class)->where('is_active', true);
    }

    public function events(): HasMany
    {
        return $this->hasMany(OrganizationEvent::class);
    }

    public function upcomingEvents(): HasMany
    {
        return $this->hasMany(OrganizationEvent::class)
            ->where('status', 'published')
            ->where('event_date', '>', now())
            ->orderBy('event_date');
    }
}

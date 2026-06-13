<?php
// app/Models/OrganizationEvent.php

namespace App\Models;

use App\Traits\HasUuid;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class OrganizationEvent extends Model
{
    use HasUuid, SoftDeletes;

    protected $fillable = [
        'organization_id', 'created_by', 'title', 'description',
        'event_date', 'end_date', 'location', 'banner_url',
        'max_participants', 'registration_deadline', 'status',
    ];

    protected function casts(): array
    {
        return [
            'event_date'            => 'datetime',
            'end_date'              => 'datetime',
            'registration_deadline' => 'datetime',
            'max_participants'      => 'integer',
        ];
    }

    public function organization(): BelongsTo
    {
        return $this->belongsTo(Organization::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function registrations(): HasMany
    {
        return $this->hasMany(EventRegistration::class, 'event_id');
    }

    public function getRegistrationCountAttribute(): int
    {
        return $this->registrations()->where('status', '!=', 'cancelled')->count();
    }

    public function getIsFullAttribute(): bool
    {
        if (!$this->max_participants) return false;
        return $this->registration_count >= $this->max_participants;
    }
}

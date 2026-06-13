<?php
// app/Services/OrganizationService.php

namespace App\Services;

use App\Models\Organization;
use App\Models\OrganizationEvent;
use App\Models\OrganizationMember;
use App\Models\EventRegistration;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class OrganizationService
{
    public function getOrganizationForUser(User $user): ?Organization
    {
        return Organization::where('leader_id', $user->id)
            ->orWhereHas('members', fn ($q) => $q->where('user_id', $user->id)->where('is_active', true))
            ->with(['leader', 'activeMembers.user.profile'])
            ->first();
    }

    public function getDashboardStats(Organization $org): array
    {
        $activeEvents   = $org->events()->where('status', 'published')
            ->where('event_date', '>', now())->count();
        $ongoingEvents  = $org->events()->where('status', 'ongoing')->count();
        $totalReg       = EventRegistration::whereIn(
            'event_id', $org->events()->pluck('id')
        )->where('status', '!=', 'cancelled')->count();

        $recentActivity = $org->events()
            ->whereIn('status', ['published', 'completed'])
            ->orderByDesc('updated_at')
            ->limit(5)
            ->get()
            ->map(fn ($e) => [
                'type'       => 'event_' . $e->status,
                'title'      => $e->title,
                'event_date' => $e->event_date->toIso8601String(),
                'updated_at' => $e->updated_at->toIso8601String(),
            ]);

        return [
            'total_members'       => $org->activeMembers()->count(),
            'active_events'       => $activeEvents + $ongoingEvents,
            'upcoming_events'     => $activeEvents,
            'total_registrations' => $totalReg,
            'recent_activity'     => $recentActivity,
        ];
    }

    public function getOrganizationDetail(Organization $org): array
    {
        return [
            'id'           => $org->id,
            'name'         => $org->name,
            'description'  => $org->description,
            'logo_url'     => $org->logo_url,
            'category'     => $org->category,
            'is_verified'  => $org->is_verified,
            'member_count' => $org->activeMembers()->count(),
            'leader'       => [
                'id'   => $org->leader->id,
                'name' => $org->leader->name,
            ],
        ];
    }

    public function getEvents(Organization $org, ?string $status = null): Collection
    {
        $q = $org->events()->orderByDesc('event_date');
        if ($status) $q->where('status', $status);
        return $q->get()->each(fn ($e) => $e->append('registration_count'));
    }

    public function createEvent(Organization $org, User $creator, array $data): OrganizationEvent
    {
        return $org->events()->create(array_merge($data, [
            'created_by' => $creator->id,
            'status'     => $data['status'] ?? 'draft',
        ]));
    }

    public function publishEvent(OrganizationEvent $event): void
    {
        $event->update(['status' => 'published']);
    }

    public function getEventRegistrations(OrganizationEvent $event): Collection
    {
        return $event->registrations()->with('user.profile')->get();
    }

    public function getMembers(Organization $org): Collection
    {
        return $org->members()->with('user.profile')->orderBy('role')->get();
    }

    public function addMember(Organization $org, string $identifier, string $role = 'member'): OrganizationMember
    {
        $user = User::where('email', $identifier)
            ->orWhereHas('profile', fn ($q) => $q->where('student_id', $identifier))
            ->firstOrFail();

        return OrganizationMember::firstOrCreate(
            ['organization_id' => $org->id, 'user_id' => $user->id],
            ['role' => $role, 'joined_at' => now(), 'is_active' => true]
        );
    }

    public function updateMemberRole(OrganizationMember $member, string $role): void
    {
        $member->update(['role' => $role]);
    }

    public function removeMember(OrganizationMember $member): void
    {
        $member->update(['is_active' => false]);
    }
}

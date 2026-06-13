<?php
// app/Http/Controllers/Api/V1/Organization/OrganizationEventController.php

namespace App\Http\Controllers\Api\V1\Organization;

use App\Http\Controllers\Controller;
use App\Models\OrganizationEvent;
use App\Services\OrganizationService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrganizationEventController extends Controller
{
    use ApiResponse;

    public function __construct(private OrganizationService $service) {}

    private function getOrg(Request $request)
    {
        $org = $this->service->getOrganizationForUser($request->user());
        if (!$org) abort(404, 'Organisasi tidak ditemukan.');
        return $org;
    }

    public function index(Request $request): JsonResponse
    {
        $org    = $this->getOrg($request);
        $status = $request->query('status');
        $events = $this->service->getEvents($org, $status ?: null);
        return $this->success(data: $events);
    }

    public function store(Request $request): JsonResponse
    {
        $org  = $this->getOrg($request);
        $data = $request->validate([
            'title'                 => 'required|string|max:255',
            'description'           => 'required|string',
            'event_date'            => 'required|date|after:now',
            'end_date'              => 'nullable|date|after:event_date',
            'location'              => 'nullable|string|max:255',
            'banner_url'            => 'nullable|url',
            'max_participants'      => 'nullable|integer|min:1',
            'registration_deadline' => 'nullable|date|before:event_date',
            'status'                => 'nullable|in:draft,published',
        ]);

        $event = $this->service->createEvent($org, $request->user(), $data);
        return $this->success(data: $event, message: 'Event berhasil dibuat.', statusCode: 201);
    }

    public function show(Request $request, string $id): JsonResponse
    {
        $org   = $this->getOrg($request);
        $event = $org->events()->findOrFail($id);
        $event->append('registration_count');
        return $this->success(data: $event);
    }

    public function update(Request $request, string $id): JsonResponse
    {
        $org   = $this->getOrg($request);
        $event = $org->events()->findOrFail($id);

        $data = $request->validate([
            'title'                 => 'sometimes|string|max:255',
            'description'           => 'sometimes|string',
            'event_date'            => 'sometimes|date',
            'end_date'              => 'nullable|date',
            'location'              => 'nullable|string|max:255',
            'banner_url'            => 'nullable|url',
            'max_participants'      => 'nullable|integer|min:1',
            'registration_deadline' => 'nullable|date',
            'status'                => 'nullable|in:draft,published,ongoing,completed,cancelled',
        ]);

        $event->update($data);
        return $this->success(data: $event, message: 'Event berhasil diperbarui.');
    }

    public function publish(Request $request, string $id): JsonResponse
    {
        $org   = $this->getOrg($request);
        $event = $org->events()->findOrFail($id);
        $this->service->publishEvent($event);
        return $this->success(data: $event->fresh(), message: 'Event berhasil dipublikasikan.');
    }

    public function destroy(Request $request, string $id): JsonResponse
    {
        $org   = $this->getOrg($request);
        $event = $org->events()->findOrFail($id);
        $event->delete();
        return $this->success(message: 'Event berhasil dihapus.');
    }

    public function registrations(Request $request, string $id): JsonResponse
    {
        $org          = $this->getOrg($request);
        $event        = $org->events()->findOrFail($id);
        $registrations = $this->service->getEventRegistrations($event);

        $formatted = $registrations->map(fn ($r) => [
            'id'             => $r->id,
            'user_id'        => $r->user_id,
            'name'           => $r->user->name,
            'nim'            => $r->user->profile?->student_id,
            'avatar_url'     => $r->user->profile?->avatar_url,
            'status'         => $r->status,
            'registered_at'  => $r->registered_at->toIso8601String(),
        ]);

        return $this->success(data: $formatted);
    }
}

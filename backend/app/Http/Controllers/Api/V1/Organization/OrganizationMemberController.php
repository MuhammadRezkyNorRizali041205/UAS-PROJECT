<?php
// app/Http/Controllers/Api/V1/Organization/OrganizationMemberController.php

namespace App\Http\Controllers\Api\V1\Organization;

use App\Http\Controllers\Controller;
use App\Models\OrganizationMember;
use App\Services\OrganizationService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrganizationMemberController extends Controller
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
        $org     = $this->getOrg($request);
        $members = $this->service->getMembers($org);

        $formatted = $members->map(fn ($m) => [
            'id'          => $m->id,
            'user_id'     => $m->user_id,
            'name'        => $m->user->name,
            'nim'         => $m->user->profile?->student_id,
            'avatar_url'  => $m->user->profile?->avatar_url,
            'role'        => $m->role,
            'is_active'   => $m->is_active,
            'joined_at'   => $m->joined_at->toIso8601String(),
        ]);

        return $this->success(data: $formatted);
    }

    public function store(Request $request): JsonResponse
    {
        $org  = $this->getOrg($request);
        $data = $request->validate([
            'identifier' => 'required|string',
            'role'       => 'nullable|in:leader,vice_leader,secretary,treasurer,member',
        ]);

        try {
            $member = $this->service->addMember($org, $data['identifier'], $data['role'] ?? 'member');
            return $this->success(data: $member, message: 'Anggota berhasil ditambahkan.', statusCode: 201);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException) {
            return $this->error('Pengguna tidak ditemukan.', 404);
        }
    }

    public function updateRole(Request $request, string $memberId): JsonResponse
    {
        $org    = $this->getOrg($request);
        $member = OrganizationMember::where('organization_id', $org->id)->findOrFail($memberId);

        $request->validate(['role' => 'required|in:leader,vice_leader,secretary,treasurer,member']);

        $this->service->updateMemberRole($member, $request->role);
        return $this->success(data: $member->fresh(), message: 'Role berhasil diperbarui.');
    }

    public function destroy(Request $request, string $memberId): JsonResponse
    {
        $org    = $this->getOrg($request);
        $member = OrganizationMember::where('organization_id', $org->id)->findOrFail($memberId);

        $this->service->removeMember($member);
        return $this->success(message: 'Anggota berhasil dinonaktifkan.');
    }
}

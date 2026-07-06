@extends('admin.layout')
@section('title', 'Dashboard')
@section('content')
<div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
    <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <div class="text-2xl font-bold text-blue-800">{{ $counts['mahasiswa'] }}</div>
        <div class="text-sm text-gray-500 mt-1">Mahasiswa</div>
    </div>
    <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <div class="text-2xl font-bold text-green-700">{{ $counts['dosen'] }}</div>
        <div class="text-sm text-gray-500 mt-1">Dosen</div>
    </div>
    <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <div class="text-2xl font-bold text-purple-700">{{ $counts['kelas'] }}</div>
        <div class="text-sm text-gray-500 mt-1">Kelas</div>
    </div>
    <div class="bg-white rounded-xl p-5 shadow-sm border border-gray-100">
        <div class="text-2xl font-bold text-orange-600">{{ $counts['tugas'] }}</div>
        <div class="text-sm text-gray-500 mt-1">Tugas Terkumpul</div>
    </div>
</div>

<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-5">
    <h2 class="font-semibold text-gray-700 mb-4">Tugas Terbaru</h2>
    <table class="w-full text-sm">
        <thead>
            <tr class="text-left text-gray-500 border-b">
                <th class="pb-2">Mahasiswa</th>
                <th class="pb-2">Mata Kuliah</th>
                <th class="pb-2">Judul Project</th>
                <th class="pb-2">Status</th>
                <th class="pb-2">Dikumpulkan</th>
            </tr>
        </thead>
        <tbody>
            @forelse($recentTugas as $t)
            <tr class="border-b border-gray-50 hover:bg-gray-50">
                <td class="py-2">{{ $t->mahasiswa->user->name ?? '-' }}</td>
                <td class="py-2">{{ $t->kelasMataKuliah->mataKuliah->nama_mk ?? '-' }}</td>
                <td class="py-2 max-w-xs truncate">{{ $t->judul_project }}</td>
                <td class="py-2">
                    @if($t->status === 'dikumpulkan')
                        <span class="bg-green-100 text-green-700 px-2 py-0.5 rounded-full text-xs">Dikumpulkan</span>
                    @elseif($t->status === 'terlambat')
                        <span class="bg-red-100 text-red-700 px-2 py-0.5 rounded-full text-xs">Terlambat</span>
                    @endif
                </td>
                <td class="py-2 text-gray-400">{{ $t->submitted_at?->format('d M Y, H:i') ?? '-' }}</td>
            </tr>
            @empty
            <tr><td colspan="5" class="py-6 text-center text-gray-400">Belum ada tugas terkumpul</td></tr>
            @endforelse
        </tbody>
    </table>
</div>
@endsection

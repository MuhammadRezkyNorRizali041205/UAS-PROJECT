@extends('admin.layout')
@section('title', 'Tugas Pengumpulan')
@section('content')
<div class="flex justify-between items-center mb-4">
    <p class="text-gray-500 text-sm">Monitor pengumpulan tugas seluruh mahasiswa</p>
</div>
<div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
    <table class="w-full text-sm">
        <thead class="bg-gray-50">
            <tr class="text-left text-gray-500">
                <th class="px-5 py-3">No</th>
                <th class="px-5 py-3">Mahasiswa</th>
                <th class="px-5 py-3">NIM</th>
                <th class="px-5 py-3">Mata Kuliah</th>
                <th class="px-5 py-3">Judul Project</th>
                <th class="px-5 py-3">Status</th>
                <th class="px-5 py-3">Dikumpulkan</th>
                <th class="px-5 py-3">Aksi</th>
            </tr>
        </thead>
        <tbody>
            @forelse($items as $i => $item)
            <tr class="border-t border-gray-50 hover:bg-gray-50">
                <td class="px-5 py-3">{{ $i + 1 }}</td>
                <td class="px-5 py-3 font-medium">{{ $item->mahasiswa->user->name ?? '-' }}</td>
                <td class="px-5 py-3 text-gray-500">{{ $item->mahasiswa->nim ?? '-' }}</td>
                <td class="px-5 py-3 text-gray-500">{{ $item->kelasMataKuliah->mataKuliah->nama_mk ?? '-' }}</td>
                <td class="px-5 py-3 max-w-xs truncate">{{ $item->judul_project }}</td>
                <td class="px-5 py-3">
                    @if($item->status === 'dikumpulkan')
                        <span class="bg-green-100 text-green-700 px-2 py-0.5 rounded-full text-xs">Dikumpulkan</span>
                    @elseif($item->status === 'terlambat')
                        <span class="bg-red-100 text-red-700 px-2 py-0.5 rounded-full text-xs">Terlambat</span>
                    @endif
                </td>
                <td class="px-5 py-3 text-gray-400 whitespace-nowrap">{{ $item->submitted_at?->format('d M Y') ?? '-' }}</td>
                <td class="px-5 py-3">
                    <a href="{{ route('admin.tugas.show', $item) }}" class="text-blue-600 hover:underline">Detail</a>
                </td>
            </tr>
            @empty
            <tr><td colspan="8" class="px-5 py-8 text-center text-gray-400">Belum ada tugas terkumpul</td></tr>
            @endforelse
        </tbody>
    </table>
</div>
@endsection

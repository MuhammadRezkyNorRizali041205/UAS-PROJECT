@extends('admin.layout')
@section('title', 'Detail Tugas')
@section('content')
<div class="max-w-2xl bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <div class="flex items-center justify-between mb-6">
        <a href="{{ route('admin.tugas.index') }}" class="text-blue-600 hover:underline text-sm">← Kembali</a>
        @if($item->status === 'dikumpulkan')
            <span class="bg-green-100 text-green-700 px-3 py-1 rounded-full text-xs font-medium">Dikumpulkan</span>
        @elseif($item->status === 'terlambat')
            <span class="bg-red-100 text-red-700 px-3 py-1 rounded-full text-xs font-medium">Terlambat</span>
        @endif
    </div>

    <div class="space-y-4">
        <div class="grid grid-cols-2 gap-4 text-sm">
            <div>
                <p class="text-gray-500">Mahasiswa</p>
                <p class="font-medium">{{ $item->mahasiswa->user->name ?? '-' }}</p>
            </div>
            <div>
                <p class="text-gray-500">NIM</p>
                <p class="font-medium">{{ $item->mahasiswa->nim ?? '-' }}</p>
            </div>
            <div>
                <p class="text-gray-500">Kelas</p>
                <p class="font-medium">{{ $item->kelasMataKuliah->kelas->nama_kelas ?? '-' }}</p>
            </div>
            <div>
                <p class="text-gray-500">Mata Kuliah</p>
                <p class="font-medium">{{ $item->kelasMataKuliah->mataKuliah->nama_mk ?? '-' }}</p>
            </div>
            <div>
                <p class="text-gray-500">Dosen Pengampu</p>
                <p class="font-medium">{{ $item->kelasMataKuliah->dosen->user->name ?? '-' }}</p>
            </div>
            <div>
                <p class="text-gray-500">Tanggal Kumpul</p>
                <p class="font-medium">{{ $item->submitted_at?->format('d M Y, H:i') ?? '-' }}</p>
            </div>
        </div>

        <hr>
        <div>
            <p class="text-gray-500 text-sm">Judul Project / Aplikasi</p>
            <p class="font-semibold text-gray-800 mt-1">{{ $item->judul_project }}</p>
        </div>

        @if($item->file_database)
        <div>
            <p class="text-gray-500 text-sm">File Database (.sql)</p>
            <a href="{{ Storage::url($item->file_database) }}" target="_blank"
               class="text-blue-600 hover:underline text-sm">Unduh File Database</a>
        </div>
        @endif

        @if($item->file_laporan)
        <div>
            <p class="text-gray-500 text-sm">File Laporan (.doc/.docx)</p>
            <a href="{{ Storage::url($item->file_laporan) }}" target="_blank"
               class="text-blue-600 hover:underline text-sm">Unduh File Laporan</a>
        </div>
        @endif

        @if($item->link_gdrive)
        <div>
            <p class="text-gray-500 text-sm">Link Google Drive</p>
            <a href="{{ $item->link_gdrive }}" target="_blank" class="text-blue-600 hover:underline text-sm break-all">{{ $item->link_gdrive }}</a>
        </div>
        @endif

        @if($item->link_github)
        <div>
            <p class="text-gray-500 text-sm">Link GitHub</p>
            <a href="{{ $item->link_github }}" target="_blank" class="text-blue-600 hover:underline text-sm break-all">{{ $item->link_github }}</a>
        </div>
        @endif

        @if($item->link_youtube)
        <div>
            <p class="text-gray-500 text-sm">Link YouTube</p>
            <a href="{{ $item->link_youtube }}" target="_blank" class="text-blue-600 hover:underline text-sm break-all">{{ $item->link_youtube }}</a>
        </div>
        @endif
    </div>
</div>
@endsection

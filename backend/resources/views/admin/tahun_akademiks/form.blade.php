@extends('admin.layout')
@section('title', isset($item) ? 'Edit Tahun Akademik' : 'Tambah Tahun Akademik')
@section('content')
<div class="max-w-lg bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <form method="POST" action="{{ isset($item) ? route('admin.tahun-akademik.update', $item) : route('admin.tahun-akademik.store') }}">
        @csrf
        @if(isset($item)) @method('PUT') @endif
        <div class="space-y-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Nama Tahun Akademik</label>
                <input type="text" name="nama" value="{{ old('nama', $item->nama ?? '') }}" required
                    class="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="2025/2026">
                @error('nama')<p class="text-red-500 text-xs mt-1">{{ $message }}</p>@enderror
            </div>
            <div class="flex items-center gap-2">
                <input type="checkbox" name="status_aktif" id="status_aktif" value="1"
                    {{ old('status_aktif', $item->status_aktif ?? false) ? 'checked' : '' }}
                    class="w-4 h-4 text-blue-600 rounded">
                <label for="status_aktif" class="text-sm text-gray-700">Tahun Akademik Aktif</label>
            </div>
        </div>
        <div class="flex gap-3 mt-6">
            <button type="submit" class="bg-blue-800 text-white px-5 py-2 rounded-lg text-sm hover:bg-blue-900">Simpan</button>
            <a href="{{ route('admin.tahun-akademik.index') }}" class="px-5 py-2 rounded-lg text-sm border border-gray-300 hover:bg-gray-50">Batal</a>
        </div>
    </form>
</div>
@endsection

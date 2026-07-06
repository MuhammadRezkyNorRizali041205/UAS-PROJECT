@extends('admin.layout')
@section('title', isset($item) ? 'Edit Mata Kuliah' : 'Tambah Mata Kuliah')
@section('content')
<div class="max-w-lg bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <form method="POST" action="{{ isset($item) ? route('admin.mata-kuliah.update', $item) : route('admin.mata-kuliah.store') }}">
        @csrf
        @if(isset($item)) @method('PUT') @endif
        <div class="space-y-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Nama Mata Kuliah</label>
                <input type="text" name="nama_mk" value="{{ old('nama_mk', $item->nama_mk ?? '') }}" required
                    class="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Pemrograman Mobile">
                @error('nama_mk')<p class="text-red-500 text-xs mt-1">{{ $message }}</p>@enderror
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Kode MK</label>
                <input type="text" name="kode_mk" value="{{ old('kode_mk', $item->kode_mk ?? '') }}" required
                    class="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="MK-TI-01">
                @error('kode_mk')<p class="text-red-500 text-xs mt-1">{{ $message }}</p>@enderror
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">SKS</label>
                <input type="number" name="sks" value="{{ old('sks', $item->sks ?? 3) }}" required min="1" max="6"
                    class="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                @error('sks')<p class="text-red-500 text-xs mt-1">{{ $message }}</p>@enderror
            </div>
        </div>
        <div class="flex gap-3 mt-6">
            <button type="submit" class="bg-blue-800 text-white px-5 py-2 rounded-lg text-sm hover:bg-blue-900">Simpan</button>
            <a href="{{ route('admin.mata-kuliah.index') }}" class="px-5 py-2 rounded-lg text-sm border border-gray-300 hover:bg-gray-50">Batal</a>
        </div>
    </form>
</div>
@endsection

@extends('admin.layout')
@section('title', isset($item) ? 'Edit Program Studi' : 'Tambah Program Studi')
@section('content')
<div class="max-w-lg bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <form method="POST" action="{{ isset($item) ? route('admin.program-studi.update', $item) : route('admin.program-studi.store') }}">
        @csrf
        @if(isset($item)) @method('PUT') @endif
        <div class="space-y-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Nama Program Studi</label>
                <input type="text" name="nama_prodi" value="{{ old('nama_prodi', $item->nama_prodi ?? '') }}" required
                    class="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="Teknik Informatika">
                @error('nama_prodi')<p class="text-red-500 text-xs mt-1">{{ $message }}</p>@enderror
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Kode Prodi</label>
                <input type="text" name="kode_prodi" value="{{ old('kode_prodi', $item->kode_prodi ?? '') }}" required
                    class="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="TI">
                @error('kode_prodi')<p class="text-red-500 text-xs mt-1">{{ $message }}</p>@enderror
            </div>
        </div>
        <div class="flex gap-3 mt-6">
            <button type="submit" class="bg-blue-800 text-white px-5 py-2 rounded-lg text-sm hover:bg-blue-900">Simpan</button>
            <a href="{{ route('admin.program-studi.index') }}" class="px-5 py-2 rounded-lg text-sm border border-gray-300 hover:bg-gray-50">Batal</a>
        </div>
    </form>
</div>
@endsection

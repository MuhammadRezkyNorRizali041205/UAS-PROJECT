@extends('admin.layout')
@section('title', isset($item) ? 'Edit Kelas-Mata Kuliah' : 'Tambah Kelas-Mata Kuliah')
@section('content')
<div class="max-w-lg bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <form method="POST" action="{{ isset($item) ? route('admin.kelas-mata-kuliah.update', $item) : route('admin.kelas-mata-kuliah.store') }}">
        @csrf
        @if(isset($item)) @method('PUT') @endif
        <div class="space-y-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Kelas</label>
                <select name="kelas_id" required
                    class="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <option value="">-- Pilih Kelas --</option>
                    @foreach($kelasList as $k)
                        <option value="{{ $k->id }}" {{ old('kelas_id', $item->kelas_id ?? '') == $k->id ? 'selected' : '' }}>
                            {{ $k->nama_kelas }} — {{ $k->tahunAkademik->nama ?? '' }}
                        </option>
                    @endforeach
                </select>
                @error('kelas_id')<p class="text-red-500 text-xs mt-1">{{ $message }}</p>@enderror
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Mata Kuliah</label>
                <select name="mata_kuliah_id" required
                    class="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <option value="">-- Pilih Mata Kuliah --</option>
                    @foreach($mataKuliahs as $mk)
                        <option value="{{ $mk->id }}" {{ old('mata_kuliah_id', $item->mata_kuliah_id ?? '') == $mk->id ? 'selected' : '' }}>
                            {{ $mk->nama_mk }} ({{ $mk->kode_mk }})
                        </option>
                    @endforeach
                </select>
                @error('mata_kuliah_id')<p class="text-red-500 text-xs mt-1">{{ $message }}</p>@enderror
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Dosen Pengampu</label>
                <select name="dosen_id" required
                    class="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <option value="">-- Pilih Dosen --</option>
                    @foreach($dosens as $d)
                        <option value="{{ $d->id }}" {{ old('dosen_id', $item->dosen_id ?? '') == $d->id ? 'selected' : '' }}>
                            {{ $d->user->name }}
                        </option>
                    @endforeach
                </select>
                @error('dosen_id')<p class="text-red-500 text-xs mt-1">{{ $message }}</p>@enderror
            </div>
        </div>
        <div class="flex gap-3 mt-6">
            <button type="submit" class="bg-blue-800 text-white px-5 py-2 rounded-lg text-sm hover:bg-blue-900">Simpan</button>
            <a href="{{ route('admin.kelas-mata-kuliah.index') }}" class="px-5 py-2 rounded-lg text-sm border border-gray-300 hover:bg-gray-50">Batal</a>
        </div>
    </form>
</div>
@endsection

@extends('admin.layout')
@section('title', isset($item) ? 'Edit Kelas' : 'Tambah Kelas')
@section('content')
<div class="max-w-lg bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <form method="POST" action="{{ isset($item) ? route('admin.kelas.update', $item) : route('admin.kelas.store') }}">
        @csrf
        @if(isset($item)) @method('PUT') @endif
        <div class="space-y-4">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Nama Kelas</label>
                <input type="text" name="nama_kelas" value="{{ old('nama_kelas', $item->nama_kelas ?? '') }}" required
                    class="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500"
                    placeholder="4A TI">
                @error('nama_kelas')<p class="text-red-500 text-xs mt-1">{{ $message }}</p>@enderror
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Tahun Akademik</label>
                <select name="tahun_akademik_id" required
                    class="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <option value="">-- Pilih --</option>
                    @foreach($tahunAkademiks as $ta)
                        <option value="{{ $ta->id }}" {{ old('tahun_akademik_id', $item->tahun_akademik_id ?? '') == $ta->id ? 'selected' : '' }}>
                            {{ $ta->nama }}
                        </option>
                    @endforeach
                </select>
                @error('tahun_akademik_id')<p class="text-red-500 text-xs mt-1">{{ $message }}</p>@enderror
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1">Program Studi</label>
                <select name="program_studi_id" required
                    class="w-full border border-gray-300 rounded-lg px-4 py-2 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500">
                    <option value="">-- Pilih --</option>
                    @foreach($programStudis as $ps)
                        <option value="{{ $ps->id }}" {{ old('program_studi_id', $item->program_studi_id ?? '') == $ps->id ? 'selected' : '' }}>
                            {{ $ps->nama_prodi }}
                        </option>
                    @endforeach
                </select>
                @error('program_studi_id')<p class="text-red-500 text-xs mt-1">{{ $message }}</p>@enderror
            </div>
        </div>
        <div class="flex gap-3 mt-6">
            <button type="submit" class="bg-blue-800 text-white px-5 py-2 rounded-lg text-sm hover:bg-blue-900">Simpan</button>
            <a href="{{ route('admin.kelas.index') }}" class="px-5 py-2 rounded-lg text-sm border border-gray-300 hover:bg-gray-50">Batal</a>
        </div>
    </form>
</div>
@endsection

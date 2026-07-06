@extends('admin.layout')
@section('title', 'Program Studi')
@section('content')
<div class="flex justify-between items-center mb-4">
    <p class="text-gray-500 text-sm">Daftar program studi</p>
    <a href="{{ route('admin.program-studi.create') }}" class="bg-blue-800 text-white px-4 py-2 rounded-lg text-sm hover:bg-blue-900">+ Tambah</a>
</div>
<div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
    <table class="w-full text-sm">
        <thead class="bg-gray-50">
            <tr class="text-left text-gray-500">
                <th class="px-5 py-3">No</th>
                <th class="px-5 py-3">Nama Prodi</th>
                <th class="px-5 py-3">Kode</th>
                <th class="px-5 py-3">Aksi</th>
            </tr>
        </thead>
        <tbody>
            @forelse($items as $i => $item)
            <tr class="border-t border-gray-50 hover:bg-gray-50">
                <td class="px-5 py-3">{{ $i + 1 }}</td>
                <td class="px-5 py-3 font-medium">{{ $item->nama_prodi }}</td>
                <td class="px-5 py-3 text-gray-500">{{ $item->kode_prodi }}</td>
                <td class="px-5 py-3 flex gap-2">
                    <a href="{{ route('admin.program-studi.edit', $item) }}" class="text-blue-600 hover:underline">Edit</a>
                    <form method="POST" action="{{ route('admin.program-studi.destroy', $item) }}" onsubmit="return confirm('Hapus?')">
                        @csrf @method('DELETE')
                        <button type="submit" class="text-red-500 hover:underline">Hapus</button>
                    </form>
                </td>
            </tr>
            @empty
            <tr><td colspan="4" class="px-5 py-8 text-center text-gray-400">Belum ada data</td></tr>
            @endforelse
        </tbody>
    </table>
</div>
@endsection

<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'Admin') — SI Tugas Poliban</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-gray-100 min-h-screen">

<div class="flex min-h-screen">
    {{-- Sidebar --}}
    <aside class="w-64 bg-blue-800 text-white flex flex-col shadow-lg">
        <div class="p-5 border-b border-blue-700">
            <div class="text-lg font-bold">SI Tugas Poliban</div>
            <div class="text-xs text-blue-300 mt-1">Admin Panel</div>
        </div>
        <nav class="flex-1 p-4 space-y-1 text-sm">
            <a href="{{ route('admin.dashboard') }}" class="flex items-center gap-2 px-3 py-2 rounded-lg hover:bg-blue-700 {{ request()->routeIs('admin.dashboard') ? 'bg-blue-700' : '' }}">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"/></svg>
                Dashboard
            </a>
            <div class="pt-2 pb-1 text-xs text-blue-400 uppercase tracking-wide">Master Data</div>
            <a href="{{ route('admin.tahun-akademik.index') }}" class="flex items-center gap-2 px-3 py-2 rounded-lg hover:bg-blue-700 {{ request()->routeIs('admin.tahun-akademik.*') ? 'bg-blue-700' : '' }}">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/></svg>
                Tahun Akademik
            </a>
            <a href="{{ route('admin.program-studi.index') }}" class="flex items-center gap-2 px-3 py-2 rounded-lg hover:bg-blue-700 {{ request()->routeIs('admin.program-studi.*') ? 'bg-blue-700' : '' }}">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"/></svg>
                Program Studi
            </a>
            <a href="{{ route('admin.mata-kuliah.index') }}" class="flex items-center gap-2 px-3 py-2 rounded-lg hover:bg-blue-700 {{ request()->routeIs('admin.mata-kuliah.*') ? 'bg-blue-700' : '' }}">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/></svg>
                Mata Kuliah
            </a>
            <a href="{{ route('admin.dosen.index') }}" class="flex items-center gap-2 px-3 py-2 rounded-lg hover:bg-blue-700 {{ request()->routeIs('admin.dosen.*') ? 'bg-blue-700' : '' }}">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/></svg>
                Dosen
            </a>
            <a href="{{ route('admin.kelas.index') }}" class="flex items-center gap-2 px-3 py-2 rounded-lg hover:bg-blue-700 {{ request()->routeIs('admin.kelas.*') ? 'bg-blue-700' : '' }}">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0z"/></svg>
                Kelas
            </a>
            <a href="{{ route('admin.kelas-mata-kuliah.index') }}" class="flex items-center gap-2 px-3 py-2 rounded-lg hover:bg-blue-700 {{ request()->routeIs('admin.kelas-mata-kuliah.*') ? 'bg-blue-700' : '' }}">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/></svg>
                Kelas - Mata Kuliah
            </a>
            <a href="{{ route('admin.mahasiswa.index') }}" class="flex items-center gap-2 px-3 py-2 rounded-lg hover:bg-blue-700 {{ request()->routeIs('admin.mahasiswa.*') ? 'bg-blue-700' : '' }}">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/></svg>
                Mahasiswa
            </a>
            <div class="pt-2 pb-1 text-xs text-blue-400 uppercase tracking-wide">Pengumpulan</div>
            <a href="{{ route('admin.tugas.index') }}" class="flex items-center gap-2 px-3 py-2 rounded-lg hover:bg-blue-700 {{ request()->routeIs('admin.tugas.*') ? 'bg-blue-700' : '' }}">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/></svg>
                Tugas
            </a>
        </nav>
        <div class="p-4 border-t border-blue-700">
            <form method="POST" action="{{ route('admin.logout') }}">
                @csrf
                <button type="submit" class="w-full flex items-center gap-2 px-3 py-2 rounded-lg hover:bg-blue-700 text-sm">
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
                    Keluar
                </button>
            </form>
        </div>
    </aside>

    {{-- Main content --}}
    <main class="flex-1 flex flex-col">
        <header class="bg-white shadow px-6 py-4 flex items-center justify-between">
            <h1 class="text-xl font-semibold text-gray-800">@yield('title', 'Dashboard')</h1>
            <span class="text-sm text-gray-500">{{ auth()->guard('admin')->user()->name ?? '' }}</span>
        </header>
        <div class="flex-1 p-6">
            @if(session('success'))
                <div class="mb-4 bg-green-100 border border-green-400 text-green-800 px-4 py-3 rounded">{{ session('success') }}</div>
            @endif
            @if(session('error'))
                <div class="mb-4 bg-red-100 border border-red-400 text-red-800 px-4 py-3 rounded">{{ session('error') }}</div>
            @endif
            @yield('content')
        </div>
    </main>
</div>

</body>
</html>

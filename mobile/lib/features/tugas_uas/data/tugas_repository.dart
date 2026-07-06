// lib/features/tugas_uas/data/tugas_repository.dart

import '../../../core/network/dio_client.dart';

class TugasUasRepository {
  const TugasUasRepository(this._client);
  final DioClient _client;

  Future<List<dynamic>> getMataKuliahSaya() async {
    return await _client.get<List<dynamic>>(
      '/tugas-uas/mata-kuliah',
      fromJson: (json) => json['data'] as List<dynamic>,
    );
  }

  Future<Map<String, dynamic>> submitTugas({
    required int kelasMataKuliahId,
    required String judulProject,
    String? linkGdrive,
    String? linkGithub,
    String? linkYoutube,
  }) async {
    return await _client.post<Map<String, dynamic>>(
      '/tugas-uas',
      data: {
        'kelas_mata_kuliah_id': kelasMataKuliahId,
        'judul_project': judulProject,
        if (linkGdrive != null && linkGdrive.isNotEmpty) 'link_gdrive': linkGdrive,
        if (linkGithub != null && linkGithub.isNotEmpty) 'link_github': linkGithub,
        if (linkYoutube != null && linkYoutube.isNotEmpty) 'link_youtube': linkYoutube,
      },
      fromJson: (json) => (json['data'] ?? json) as Map<String, dynamic>,
    );
  }

  Future<List<dynamic>> getRiwayat() async {
    return await _client.get<List<dynamic>>(
      '/tugas-uas/riwayat',
      fromJson: (json) => json['data'] as List<dynamic>,
    );
  }

  Future<Map<String, dynamic>> getProfil() async {
    return await _client.get<Map<String, dynamic>>(
      '/tugas-uas/profil',
      fromJson: (json) => json['data'] as Map<String, dynamic>,
    );
  }
}

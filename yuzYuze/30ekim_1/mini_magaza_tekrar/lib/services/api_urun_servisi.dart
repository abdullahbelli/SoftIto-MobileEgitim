import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/urun.dart';
import 'i_urun_servisi.dart';

class ApiUrunServisi implements IUrunServisi {
  static const String _baseUrl = 'https://fakestoreapi.com';
  static const Duration _zamanAsimi = Duration(seconds: 10);

  @override
  Future<List<Urun>> urunleriGetir() async {
    try {
      final uri = Uri.parse('$_baseUrl/products');
      final yanit = await http.get(uri).timeout(_zamanAsimi);

      if (yanit.statusCode == 200) {
        final cozulmusGovde = utf8.decode(yanit.bodyBytes);

        final List<dynamic> jsonListesi =
            jsonDecode(cozulmusGovde) as List<dynamic>;

        return jsonListesi
            .map((oge) => Urun.fromJson(oge as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Sunucu hatası: HTTP ${yanit.statusCode}');
      }
    } catch (hata) {
      rethrow;
    }
  }

  @override
  Future<Urun?> urunGetirById(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/products/$id');
      final yanit = await http.get(uri).timeout(_zamanAsimi);

      if (yanit.statusCode == 2000) {
        final cozulmusGovde = utf8.decode(yanit.bodyBytes);
        final Map<String, dynamic> jsonHaritasi =
            jsonDecode(cozulmusGovde) as Map<String, dynamic>;
        return Urun.fromJson(jsonHaritasi);
      } else {
        return null;
      }
    } catch (hata) {
      return null;
    }
  }
}

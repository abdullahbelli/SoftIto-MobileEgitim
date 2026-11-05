
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera_macos/camera_macos.dart';

class GorselYuklemeKarti extends StatefulWidget {
  final File? secilenDosya;
  final String? yuklenenUrl;
  final double yuklemeOrani;
  final bool yukleniyorMu;
  final VoidCallback onGaleridenSec;
  final VoidCallback onKameradanCek;
  final VoidCallback onBulutaYukle;

  // macOS kamera: Çekilen fotoğrafı üst ekrana aktarmak için.
  final ValueChanged<File>? onFotografCekildi;

  const GorselYuklemeKarti({
    super.key,
    required this.secilenDosya,
    required this.yuklenenUrl,
    required this.yuklemeOrani,
    required this.yukleniyorMu,
    required this.onGaleridenSec,
    required this.onKameradanCek,
    required this.onBulutaYukle,
    this.onFotografCekildi,
  });

  @override
  State<GorselYuklemeKarti> createState() => _GorselYuklemeKartiState();
}

class _GorselYuklemeKartiState extends State<GorselYuklemeKarti> {
  // macOS kamera: Kamera durumunu ve kontrolcüsünü tutar.
  bool _kameraAcikMi = false;
  bool _fotografCekiliyorMu = false;
  CameraMacOSController? _kameraController;

  // macOS kamera: Kamerayı açar veya fotoğraf çeker.
  Future<void> _kameraButonunaBas() async {
    if (!Platform.isMacOS) {
      widget.onKameradanCek();
      return;
    }

    if (!_kameraAcikMi) {
      setState(() {
        _kameraAcikMi = true;
        _kameraController = null;
      });
      return;
    }

    if (_kameraController == null || _fotografCekiliyorMu) {
      return;
    }

    setState(() => _fotografCekiliyorMu = true);

    try {
      final fotograf = await _kameraController!.takePicture();
      final bytes = fotograf?.bytes;

      if (bytes == null || bytes.isEmpty) {
        throw Exception('Fotoğraf alınamadı.');
      }

      // macOS kamera: Firebase'in kullanacağı geçici dosyayı oluşturur.
      final dosya = File(
        '${Directory.systemTemp.path}/'
        'kamera_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await dosya.writeAsBytes(bytes);

      if (!mounted) return;

      setState(() {
        _kameraAcikMi = false;
        _kameraController = null;
      });

      // Çekilen görseli mevcut ekranın dosya değişkenine aktarır.
      widget.onFotografCekildi?.call(dosya);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kamera hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _fotografCekiliyorMu = false);
      }
    }
  }

  // macOS kamera: Galeri seçildiğinde kamera önizlemesini kapatır.
  void _galeriButonunaBas() {
    if (_kameraAcikMi) {
      setState(() {
        _kameraAcikMi = false;
        _kameraController = null;
      });
    }

    widget.onGaleridenSec();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.cloud_upload_outlined, color: Color(0xff0047ff)),
                SizedBox(width: 8),
                Text(
                  'Firebase Medya Yükleyici',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(211, 148, 177, 30),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Color.fromARGB(209, 170, 29, 188),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              alignment: Alignment.center,

              // macOS kamera: Kamera açıksa bu alanda canlı görüntü gösterilir.
              child: _kameraAcikMi && Platform.isMacOS
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox.expand(
                        child: CameraMacOSView(
                          fit: BoxFit.cover,
                          cameraMode: CameraMacOSMode.photo,
                          onCameraInizialized: (controller) {
                            if (mounted) {
                              setState(() {
                                _kameraController = controller;
                              });
                            }
                          },
                        ),
                      ),
                    )
                  : widget.secilenDosya != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        widget.secilenDosya!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                  : (widget.yuklenenUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.yuklenenUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Henüz bir görsel seçilmedi',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          )),
            ),
            if (widget.yukleniyorMu) ...[
              //... ne işe yarıyor ???
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: widget.yuklemeOrani,
                backgroundColor: Colors.grey.shade200,
                color: const Color.fromARGB(255, 19, 13, 13),
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text(
                'Yükleniyor: %${(widget.yuklemeOrani * 100).toStringAsFixed(0)}',
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.yukleniyorMu
                        ? null
                        : _galeriButonunaBas,
                    label: const Text('Galeri'),
                    icon: const Icon(Icons.photo_library_outlined),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.yukleniyorMu ||
                            _fotografCekiliyorMu ||
                            (_kameraAcikMi && _kameraController == null)
                        ? null
                        : _kameraButonunaBas,
                    label: Text(
                      _kameraAcikMi && Platform.isMacOS
                          ? 'Fotoğraf Çek'
                          : 'Kamera',
                    ),
                    icon: Icon(Icons.camera_alt_outlined),
                  ),
                ),
              ],
            ),
            // macOS kamera: Önizlemeyi kapatmak için.
            if (_kameraAcikMi && Platform.isMacOS) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _kameraAcikMi = false;
                    _kameraController = null;
                  });
                },
                child: const Text('Kamerayı Kapat'),
              ),
            ],
            if (widget.secilenDosya != null) ...[
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: widget.yukleniyorMu
                    ? null
                    : widget.onBulutaYukle,
                label: const Text('Buluta yükle'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color.fromARGB(239, 217, 127, 0),
                ),
                icon: const Icon(Icons.cloud_upload),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

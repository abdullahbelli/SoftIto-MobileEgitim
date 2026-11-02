
import 'package:flutter/material.dart';

class HataliVeDogruRow extends StatelessWidget {
  const HataliVeDogruRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Row ve Layout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HATALI YAPI
            const Text(
              'Hatalı Yapı: A overflowed by *** pixels (sarı siyah şerit)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              color: Colors.amber.shade100,
              child: Row(
                children: [
                  const Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Kısa metin (hata vermez ama uzarsa Render Patlar)',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // DOĞRU YAPI
            const Text(
              'Doğru Yapı: Flexible ve Expanded ile sınırlandırılmıştır.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green,
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Softİto 4. Dönem Mobil Standartı',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Bu metin ne kadar uzun olursa olsun '
                          'telefonun ekranının genişliğinde alt satıra '
                          'geçer ve asla sarı siyah taşma hatası üretmez.',
                          style: TextStyle(
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart'; // ikon ve arayüz bileşenlerinn kullanılmasını sağlar

class TransactionItem {
  // işlem bilgilerini tutan model sınıfı
  final String id; //işlemin benzersiz kimliği
  final String title; //başlık
  final String category; //kategori
  final String date; // işlem tarihi
  final double amount; // işlem tutarı
  final bool isExpanse; // gider mi değil mi
  final IconData icon; // işlemin ikonu

  const TransactionItem({
    //sabit constructor nesne oluşturmak için
    //required: doldurulması zorunlu alanlar.
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.icon,
    required this.isExpanse,
  });
}

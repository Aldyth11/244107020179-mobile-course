import 'package:flutter/material.dart';

class ImageAnalysisModal extends StatelessWidget {
  final void Function({
    required String prompt,
    required String base64Image,
    String? displayFileName,
  }) onSelectAnalysis;

  const ImageAnalysisModal({super.key, required this.onSelectAnalysis});

  static void show(
    BuildContext context, {
    required void Function({
      required String prompt,
      required String base64Image,
      String? displayFileName,
    }) onSelectAnalysis,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ImageAnalysisModal(onSelectAnalysis: onSelectAnalysis),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.document_scanner, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Text(
                'OCR & Analisis Citra AI',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Pilih sampel dokumen kampus untuk diekstraksi teksnya atau dianalisis oleh AI:',
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE0E7FF),
              child: Icon(Icons.badge, color: Color(0xFF1E3A8A)),
            ),
            title: const Text('Kartu Tanda Mahasiswa (KTM)'),
            subtitle: const Text('Ekstraksi NIM, Nama, dan Program Studi'),
            onTap: () {
              Navigator.pop(context);
              onSelectAnalysis(
                prompt: 'Tolong lakukan OCR dan ringkas data identitas dari KTM ini.',
                base64Image: 'SIMULATED_BASE64_KTM_POLINEMA',
                displayFileName: 'ktm_polinema.png',
              );
            },
          ),
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE0E7FF),
              child: Icon(Icons.receipt_long, color: Color(0xFF1E3A8A)),
            ),
            title: const Text('Bukti Pembayaran UKT'),
            subtitle: const Text('Verifikasi status lunas dan nomor referensi'),
            onTap: () {
              Navigator.pop(context);
              onSelectAnalysis(
                prompt: 'Tolong baca bukti transfer UKT ini dan pastikan validitasnya.',
                base64Image: 'SIMULATED_BASE64_UKT_RECEIPT',
                displayFileName: 'bukti_ukt.jpg',
              );
            },
          ),
        ],
      ),
    );
  }
}

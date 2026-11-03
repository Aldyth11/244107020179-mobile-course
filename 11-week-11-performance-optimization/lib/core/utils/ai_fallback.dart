class AiFallback {
  const AiFallback();

  String getResponse(String query) {
    final q = query.toLowerCase();

    if (q.contains('jadwal') || q.contains('kuliah') || q.contains('senin')) {
      return 'Jadwal perkuliahan semester ganjil dapat dilihat pada portal Siakad Polinema. Perkuliahan dimulai pukul 07.00 - 15.30 WIB.';
    } else if (q.contains('perpustakaan') ||
        q.contains('buku') ||
        q.contains('pinjam')) {
      return 'Perpustakaan Pusat Polinema berlokasi di Gedung Graha Polinema Lantai 2 & 3. Buka Senin-Jumat pukul 08.00-16.00 WIB.';
    } else if (q.contains('ukt') ||
        q.contains('biaya') ||
        q.contains('bayar')) {
      return 'Pembayaran UKT dapat dilakukan melalui Virtual Account Bank Mandiri, BNI, BRI, atau BTN sesuai kalender akademik.';
    } else if (q.contains('beasiswa')) {
      return 'Informasi beasiswa KIP-Kuliah, Djarum, dan industri tersedia di Bagian Kemahasiswaan Gedung AK atau website kemahasiswaan.polinema.ac.id.';
    } else if (q.contains('halo') ||
        q.contains('hai') ||
        q.contains('pagi') ||
        q.contains('siang')) {
      return 'Halo! Saya CampusBot AI Polinema. Ada yang bisa saya bantu seputar informasi akademik atau kampus hari ini?';
    } else {
      return 'Mohon maaf, layanan AI daring sedang tidak terhubung. Anda dapat menghubungi helpdesk akademik Polinema di helpdesk@polinema.ac.id.';
    }
  }

  String get simulatedOcrResult =>
      '[Mode Simulasi OCR / Vision] Gambar terdeteksi: Dokumen akademik / KTM. '
      'Teks simulasi yang terdeteksi: POLITEKNIK NEGERI MALANG - TEKNOLOGI INFORMASI.';
}

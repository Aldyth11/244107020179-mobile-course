class Profil {
  String nama;
  String nim;
  String? email; // tanda tanya biar email bisa null

  Profil({required this.nama, required this.nim, this.email});
}

double hitungLuasPersegiPanjang(double panjang, double lebar) {
  return panjang * lebar;
}

void main() {
  double luas = hitungLuasPersegiPanjang(10, 4.5);
  print('Luas Persegi Panjang: $luas');

  Profil mahasiswa = Profil(
    nama: 'Aldyth',
    nim: '123456789',
    email: null, 
  );

  String infoEmail = mahasiswa.email ?? 'Emailnya kosong';
  print('Nama: ${mahasiswa.nama}');
  print('NIM: ${mahasiswa.nim}');
  print('Email: $infoEmail');
}
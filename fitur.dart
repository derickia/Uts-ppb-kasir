import 'data.dart';
import 'input.dart';

// ============================================================
// Fungsi bantu
// ============================================================

/// Mencari barang berdasarkan kode. Mengembalikan null jika tidak ada.
Map<String, dynamic>? cariByKode(String kode) {
  for (final barang in daftarBarang) {
    if (barang['kode'] == kode) return barang;
  }
  return null;
}

/// Menghitung total harga semua barang di keranjang (sebelum diskon).
int hitungTotal() {
  var total = 0;
  keranjang.forEach((kode, jumlah) {
    final barang = cariByKode(kode)!;
    total += (barang['harga'] as int) * jumlah;
  });
  return total;
}

/// Mencetak isi keranjang beserta subtotal setiap barang.
void cetakIsiKeranjang(Map<String, int> isi) {
  isi.forEach((kode, jumlah) {
    final barang = cariByKode(kode)!;
    final harga = barang['harga'] as int;
    print(
      '$kode | ${barang['nama']} | $jumlah x Rp$harga = Rp${harga * jumlah}',
    );
  });
}

int hitungKembalian(int totalBayar, int uang) {
  if (uang < totalBayar) {
    throw Exception('Uang kurang Rp${totalBayar - uang}.');
  }
  return uang - totalBayar;
}

// ============================================================
// Fitur yang sudah jadi
// ============================================================

/// Menu 1: menampilkan semua barang.
void tampilkanBarang() {
  print('\n=== Daftar Barang ===');
  for (final barang in daftarBarang) {
    print(
      '${barang['kode']} | ${barang['nama']} | '
      'Rp${barang['harga']} | stok ${barang['stok']}',
    );
  }
}

/// Menu 2: memasukkan barang ke keranjang.
void tambahKeKeranjang() {
  print('\n=== Tambah ke Keranjang ===');
  final kode = bacaTeks('Kode barang').toUpperCase();
  final barang = cariByKode(kode);
  if (barang == null) {
    print('Barang dengan kode $kode tidak ditemukan.');
    return;
  }
  final jumlah = bacaInt('Jumlah', min: 1, max: 1000);
  final sudahDiKeranjang = keranjang[kode] ?? 0;
  final stok = barang['stok'] as int;
  if (sudahDiKeranjang + jumlah > stok) {
    print(
      'Stok tidak cukup. Stok ${barang['nama']}: $stok, '
      'di keranjang: $sudahDiKeranjang.',
    );
    return;
  }
  keranjang[kode] = sudahDiKeranjang + jumlah;
  print('$jumlah ${barang['nama']} masuk ke keranjang.');
}

/// Menu 3: menampilkan isi keranjang, diskon, dan total bayar.
void tampilkanKeranjang() {
  print('\n=== Keranjang ===');
  if (keranjang.isEmpty) {
    print('Keranjang kosong.');
    return;
  }
  cetakIsiKeranjang(keranjang);
  final total = hitungTotal();
  final diskon = hitungDiskon(total);
  print('Total      : Rp$total');
  print('Diskon     : Rp$diskon');
  print('Total bayar: Rp${total - diskon}');
}

// ============================================================
// Fitur pilihan (pilih minimal 3, lihat README.md)
// ============================================================

/// Menu 4 [Mudah]: menambah barang baru ke daftar barang.
void tambahBarangBaru() {
  // TODO: minta kode, nama, harga, dan stok. Tolak jika kode sudah dipakai
  // (pakai cariByKode). Tambahkan ke daftarBarang.
  // (!= tidak null),

  print('\n === Tambah Barang Baru ===');
  final kode = bacaTeks('Kode barang').toUpperCase();
  if (cariByKode(kode) != null) {
    print('kode $kode Sudah diPakai');
    return;
  }

  final nama = bacaTeks('Nama barang');
  final harga = bacaInt('Harga');
  final stok = bacaInt('Stok', min: 0, max: 100);

  daftarBarang.add({'kode': kode, 'nama': nama, 'harga': harga, 'stok': stok});

  print('Barang $nama Berhasil DiTambahkan');
}

/// Menu 5 [Mudah]: menghapus satu barang dari keranjang.
void hapusDariKeranjang() {
  // TODO: minta kode barang, hapus dari keranjang.
  // Tampilkan pesan jika barang tidak ada di keranjang.
  // containsKey = apakah kode ini ada di keranjang

  print('\n=== Hapus Dari Keranjang ===');
  final kode = bacaTeks('Kode barang').toUpperCase();
  if (!keranjang.containsKey(kode)) {
    print('Barang dengan kode $kode tidak ada di Keranjang.');
    return;
  }
  keranjang.remove(kode);
  print('Barang $kode Berhasil di Hapus');
}

/// [Sedang] Menghitung potongan diskon dari [total] belanja.
///
/// Fungsi ini sudah dipakai di menu 3. Selama belum dibuat, diskon selalu 0.
int hitungDiskon(int total) {
  // TODO: kembalikan potongan sesuai aturan diskon di data.dart:
  // total >= batasDiskonBesar -> persenDiskonBesar %,
  // total >= batasDiskonKecil -> persenDiskonKecil %, selain itu 0.

  if (total >= batasDiskonBesar) return total * persenDiskonBesar ~/ 100;
  if (total >= batasDiskonKecil) return total * persenDiskonKecil ~/ 100;
  return 0;
}

/// Menu 6 [Sedang]: membayar belanjaan di keranjang.
void bayar() {
  // TODO:
  // 1. Tampilkan total bayar (total - diskon), lalu minta uang yang diterima.
  // 2. Buat fungsi hitungKembalian(totalBayar, uang) yang melempar Exception
  //    jika uang kurang. Tangkap dengan try-catch dan tampilkan pesannya.
  // 3. Jika berhasil: tampilkan kembalian, panggil kurangiStok() dan
  //    simpanRiwayat(...), lalu kosongkan keranjang.

  print('\n=== Pembayaran ===');
  if (keranjang.isEmpty) {
    print('Keranjang kosong.');
    return;
  }

  final total = hitungTotal();
  final diskon = hitungDiskon(total);
  final totalBayar = total - diskon;
  print('Total bayar: Rp$totalBayar');

  final uang = bacaInt('Uang diterima Rp');

  var kembalian = 0;
  try {
    kembalian = hitungKembalian(totalBayar, uang);
  } on Exception catch (e) {
    print('Pembayaran gagal. $e');
    return;
  }

  print('Kembalian: Rp$kembalian');
  kurangiStok();
  simpanRiwayat(total, diskon, uang, kembalian);
  keranjang.clear();
  print('Pembayaran berhasil.');
}

/// [Sulit] Mengurangi stok barang sesuai isi keranjang.
///
/// Dipanggil dari bayar(), jadi fitur ini membutuhkan menu 6.
void kurangiStok() {
  // TODO: untuk setiap barang di keranjang, kurangi stoknya di daftarBarang.
  keranjang.forEach((kode, jumlah) {
    final barang = cariByKode(kode)!;
    barang['stok'] = (barang['stok'] as int) - jumlah;
  });
}

/// [Sulit] Menyimpan transaksi yang sudah dibayar ke riwayatTransaksi.
///
/// Dipanggil dari bayar(), jadi fitur ini membutuhkan menu 6.
void simpanRiwayat(int total, int diskon, int uang, int kembalian) {
  // TODO: simpan nomor transaksi, salinan isi keranjang, total, diskon, uang,
  // dan kembalian sebagai Map ke riwayatTransaksi.
  riwayatTransaksi.add({
    'nomor': riwayatTransaksi.length + 1,
    'isi': Map<String, int>.from(keranjang),
    'total': total,
    'diskon': diskon,
    'uang': uang,
    'kembalian': kembalian,
  });
}

/// Menu 7 [Sulit]: menampilkan struk semua transaksi.
void tampilkanRiwayat() {
  // TODO: tampilkan setiap transaksi di riwayatTransaksi seperti struk:
  // isi belanja, total, diskon, total bayar, uang, dan kembalian.
  print('\n == Riwayat Transaksi ==');
  if (riwayatTransaksi.isEmpty) {
    print('Belum ada Transaksi');
    return;
  }
  for (final trx in riwayatTransaksi) {
    final total = trx['total'] as int;
    final diskon = trx['diskon'] as int;
    print('=== Transaksi #${trx['nomor']}===');
    cetakIsiKeranjang(trx['isi'] as Map<String, int>);
    print('Total      : Rp$total');
    print('Diskon     : Rp$diskon');
    print('Total bayar: Rp${total - diskon}');
    print('Uang       : Rp${trx['uang']}');
    print('Kembalian  : Rp${trx['kembalian']}');
  }
}
//- Total belanja ≥ Rp100.000 → diskon 10%
//- Total belanja ≥ Rp50.000 → diskon 5%
//- Selain itu tidak ada diskon
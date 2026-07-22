import 'DocumentHelper.dart';

class rekodMenu {
  int id = -1;
  String jenis = '';
  num Harga = 0.00;

  rekodMenu(this.jenis, this.Harga);

  rekodMenu.fromMap(
    Map<String, dynamic> map,
  ) // This Function helps to convert our Map into our User Object
  : id = map["id"],
      jenis = map["Menu"],
      Harga = map["Harga"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {"id": id, "Menu": jenis, "Harga": Harga};
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {"id": id, "Menu": jenis, "Harga": Harga};
  }

  factory rekodMenu.fromJson(Map<String, dynamic> toMap) {
    return rekodMenu.fromMap(toMap);
  }
}

class rekodPekerja {
  int id = -1;
  String username = '';
  String nama = '';
  String namaPenuh = '';
  String ic = '';
  String bank = '';
  String noBank = '';
  num gajiHarian = 0.00;
  num gajiSimpan = 0.00;
  bool cucuk;
  List<dynamic> rekodAmbil;
  String role = 'Pekerja';
  bool aktif = false;

  rekodPekerja(
    this.nama,
    this.namaPenuh,
    this.ic,
    this.bank,
    this.noBank,
    this.gajiHarian,
    this.gajiSimpan,
    this.cucuk,
    this.role,
    this.aktif,
    this.rekodAmbil,
  );

  rekodPekerja.fromMap(
    Map<String, dynamic> map,
  ) // This Function helps to convert our Map into our User Object
  : id = map["id"],
      username = "${map["nama"]}_${map["id"]}",
      nama = map["nama"],
      namaPenuh = map["nama penuh"],
      ic = map["kad pengenalan"],
      bank = map["bank"],
      noBank = map["nombor Bank"],
      gajiHarian = map["gajiHarian"],
      gajiSimpan = map["gajiSimpan"],
      cucuk = map["cucuk"],
      role = map["role"],
      aktif = map["aktif"],
      rekodAmbil = (map["Ambil Gaji Rekod"] ?? [])
          .map((e) => rekodAmbilGaji.fromMap(Map<String, dynamic>.from(e)))
          .toList();

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "nama": nama,
      "nama penuh": namaPenuh,
      "kad pengenalan": ic,
      "bank": bank,
      "nombor Bank": noBank,
      "gajiHarian": gajiHarian,
      "gajiSimpan": gajiSimpan,
      "cucuk": cucuk,
      "role": role,
      "aktif": aktif,
      "Ambil Gaji Rekod": rekodAmbil.map((e) => e.toMap()).toList(),
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "nama": nama,
      "nama penuh": namaPenuh,
      "kad pengenalan": ic,
      "bank": bank,
      "nombor Bank": noBank,
      "gajiHarian": gajiHarian,
      "gajiSimpan": gajiSimpan,
      "cucuk": cucuk,
      "role": role,
      "aktif": aktif,
    };
  }

  factory rekodPekerja.fromJson(Map<String, dynamic> toMap) {
    return rekodPekerja.fromMap(toMap);
  }
}

class rekodList {
  int id = -1;
  String epochTime = '';
  String tarikh = '';
  String hari = '';
  List<dynamic> rekod = [];

  rekodList(this.epochTime, this.tarikh, this.hari, this.rekod);

  rekodList.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      epochTime = map["epochTime"],
      tarikh = map['tarikh'] == null ? '' : formatTarikhToServer(map['tarikh']),
      hari = map["hari"],
      rekod = (map["Harian Detail Rekod"] ?? [])
          .map((e) => rekodHarianDetail.fromMap(Map<String, dynamic>.from(e)))
          .toList();

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "epochTime": epochTime,
      "tarikh": tarikh,
      "hari": hari,
      "Harian Detail Rekod": rekod.map((e) => e.toMap()).toList(),
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "epochTime": epochTime,
      "tarikh": formatTarikh(tarikh),
      "hari": hari,
    };
  }

  factory rekodList.fromJson(Map<String, dynamic> toMap) {
    return rekodList.fromMap(toMap);
  }
}

class rekodHarianDetail {
  int id = -1;
  int harianId = 0;
  String username = '';
  String namaPasarMalam = '';
  Map<String, dynamic> rekodMenu = {};
  int jumlahSatay = 0;
  int jualanNS = 0;
  num jumlahJualan = 0.00;
  num barang = 0.00;
  num pendapatanJualan = 0.00;
  num pendapatanQR = 0.00;
  num pendapatanSebenar = 0.00;
  num kerugian = 0.00;

  rekodHarianDetail(
    this.harianId,
    this.namaPasarMalam,
    this.rekodMenu,
    this.jumlahSatay,
    this.jualanNS,
    this.jumlahJualan,
    this.barang,
    this.pendapatanJualan,
    this.pendapatanQR,
    this.pendapatanSebenar,
    this.kerugian,
  );

  rekodHarianDetail.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      harianId = map["Harian id"],
      namaPasarMalam = map["Nama"],
      rekodMenu = Map<String, dynamic>.from(map["Produk"] ?? {}),
      jumlahSatay = map["Jumlah Satay"],
      jualanNS = map["Jumlah NS"],
      jumlahJualan = map["Jumlah Jualan"],
      barang = map["Beli Barang"],
      pendapatanJualan = map["Pendapatan Jualan"],
      pendapatanQR = map["Pendapatan QR"],
      pendapatanSebenar = map["Pendapatan Sebenar"],
      kerugian = map["Kerugian"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "Harian id": harianId,
      "Nama": namaPasarMalam,
      "Produk": rekodMenu,
      "Jumlah Satay": jumlahSatay,
      "Jumlah NS": jualanNS,
      "Jumlah Jualan": jumlahJualan,
      "Beli Barang": barang,
      "Pendapatan Jualan": pendapatanJualan,
      "Pendapatan QR": pendapatanQR,
      "Pendapatan Sebenar": pendapatanSebenar,
      "Kerugian": kerugian,
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "Harian id": harianId,
      "Nama": namaPasarMalam,
      "Produk": rekodMenu,
      "Jumlah Satay": jumlahSatay,
      "Jumlah NS": jualanNS,
      "Jumlah Jualan": jumlahJualan,
      "Beli Barang": barang,
      "Pendapatan Jualan": pendapatanJualan,
      "Pendapatan QR": pendapatanQR,
      "Pendapatan Sebenar": pendapatanSebenar,
      "Kerugian": kerugian,
    };
  }

  factory rekodHarianDetail.fromJson(Map<String, dynamic> toMap) {
    return rekodHarianDetail.fromMap(toMap);
  }
}

class rekodCawangan {
  int id = -1;
  String userName = '';
  String nama = '';
  List<dynamic> rekod = [];
  Map<String, dynamic> rekodHarga = {};
  List<dynamic> rekodBayaran = [];

  rekodCawangan(this.nama, this.rekod, this.rekodHarga, this.rekodBayaran);

  rekodCawangan.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      userName = "${map["nama"]}_${map["id"]}",
      nama = map["nama"],
      rekod = (map["Cawangan Detail Rekod"] ?? [])
          .map((e) => rekodCawanganDetail.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      rekodHarga = Map<String, dynamic>.from(map["harga Menu"] ?? {}),
      rekodBayaran = (map["Cawangan Bayaran Rekod"] ?? [])
          .map(
            (e) => rekodBayaranCawangan.fromMap(Map<String, dynamic>.from(e)),
          )
          .toList();

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "nama": nama,
      "Cawangan Detail Rekod": rekod.map((e) => e.toMap()).toList(),
      "harga Menu": rekodHarga,
      "Cawangan Bayaran Rekod": rekodBayaran.map((e) => e.toMap()).toList(),
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {"id": id, "nama": nama, "harga Menu": rekodHarga};
  }

  factory rekodCawangan.fromJson(Map<String, dynamic> toMap) {
    return rekodCawangan.fromMap(toMap);
  }
}

class rekodCawanganDetail {
  int id = -1;
  int cawanganId = -1;
  String epochTime = '';
  String tarikh = '';
  String hari = '';
  Map<String, dynamic> rekodMenu = {};
  int jumlahSatay = 0;
  num jumlahJualan = 0.00;
  num baki = 0.00;
  num rugi = 0.00;
  bool bayaranPenuh = false;
  num bayaran = 0.00;

  rekodCawanganDetail(
    this.cawanganId,
    this.epochTime,
    this.tarikh,
    this.hari,
    this.rekodMenu,
    this.jumlahSatay,
    this.jumlahJualan,
    this.baki,
    this.rugi,
    this.bayaranPenuh,
    this.bayaran,
  );

  rekodCawanganDetail.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      cawanganId = map["cawangan id"],
      epochTime = map["epochTime"],
      tarikh = map['tarikh'] == null ? '' : formatTarikhToServer(map['tarikh']),
      hari = map["hari"],
      rekodMenu = Map<String, dynamic>.from(map["menu"] ?? {}),
      jumlahSatay = map["jumlahSatay"],
      jumlahJualan = map["jumlahJualan"],
      baki = map["baki"],
      rugi = map["rugi"],
      bayaranPenuh = map["bayaranPenuh"],
      bayaran = map["bayaran"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "cawangan id": cawanganId,
      "epochTime": epochTime,
      "tarikh": tarikh,
      "hari": hari,
      "menu": rekodMenu,
      "jumlahSatay": jumlahSatay,
      "jumlahJualan": jumlahJualan,
      "baki": baki,
      "rugi": rugi,
      "bayaranPenuh": bayaranPenuh,
      "bayaran": bayaran,
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "cawangan id": cawanganId,
      "epochTime": epochTime,
      "tarikh": formatTarikh(tarikh),
      "hari": hari,
      "menu": rekodMenu,
      "jumlahSatay": jumlahSatay,
      "jumlahJualan": jumlahJualan,
      "baki": baki,
      "rugi": rugi,
      "bayaranPenuh": bayaranPenuh,
      "bayaran": bayaran,
    };
  }

  factory rekodCawanganDetail.fromJson(Map<String, dynamic> toMap) {
    return rekodCawanganDetail.fromMap(toMap);
  }
}

class rekodBayaranCawangan {
  int id = -1;
  int cawanganId = -1;
  String epochTime = '';
  String tarikh = '';
  String hari = '';
  num bayaran = 0.00;

  rekodBayaranCawangan(
    this.cawanganId,
    this.epochTime,
    this.tarikh,
    this.hari,
    this.bayaran,
  );

  rekodBayaranCawangan.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      cawanganId = map["cawangan id"],
      epochTime = map["epochTime"],
      tarikh = map['tarikh'] == null ? '' : formatTarikhToServer(map['tarikh']),
      hari = map["hari"],
      bayaran = map["bayaran"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "cawangan id": cawanganId,
      "epochTime": epochTime,
      "tarikh": tarikh,
      "hari": hari,
      "bayaran": bayaran,
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "cawangan id": cawanganId,
      "epochTime": epochTime,
      "tarikh": formatTarikh(tarikh),
      "hari": hari,
      "bayaran": bayaran,
    };
  }

  factory rekodBayaranCawangan.fromJson(Map<String, dynamic> toMap) {
    return rekodBayaranCawangan.fromMap(toMap);
  }
}

class rekodCucuk {
  int id = -1;
  String epochTime = '';
  String tarikh = '';
  String hari = '';
  List<dynamic> rekod = [];
  List<dynamic> jumlahSatayList = [];

  rekodCucuk(
    this.epochTime,
    this.tarikh,
    this.hari,
    this.rekod,
    this.jumlahSatayList,
  );

  rekodCucuk.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      epochTime = map["epochTime"],
      tarikh = map['tarikh'] == null ? '' : formatTarikhToServer(map['tarikh']),
      hari = map["hari"],
      rekod = (map["Cucuk Detail Rekod"] ?? [])
          .map((e) => rekodCucukDetail.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      jumlahSatayList = (map["Jumlah Cucuk Satay Rekod"] ?? [])
          .map((e) => rekodJumlahCucuk.fromMap(Map<String, dynamic>.from(e)))
          .toList();

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "epochTime": epochTime,
      "tarikh": tarikh,
      "hari": hari,
      "Cucuk Detail Rekod": rekod.map((e) => e.toMap()).toList(),
      "Jumlah Cucuk Satay Rekod": jumlahSatayList
          .map((e) => e.toMap())
          .toList(),
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "epochTime": epochTime,
      "tarikh": formatTarikh(tarikh),
      "hari": hari,
    };
  }

  factory rekodCucuk.fromJson(Map<String, dynamic> toMap) {
    return rekodCucuk.fromMap(toMap);
  }
}

class rekodCucukDetail {
  int id = -1;
  int cucukId = 0;
  int pekerja_id = -1;
  String nama = '';
  String jenis = '';
  int jumlah = 0;

  rekodCucukDetail(
    this.cucukId,
    this.pekerja_id,
    this.nama,
    this.jenis,
    this.jumlah,
  );

  rekodCucukDetail.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      pekerja_id = map["pekerja id"],
      cucukId = map["cucuk id"] ?? 0,
      nama = map["nama"],
      jenis = map["jenis"],
      jumlah = map["jumlah"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "pekerja id": pekerja_id,
      "cucuk id": cucukId,
      "nama": nama,
      "jenis": jenis,
      "jumlah": jumlah,
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "pekerja id": pekerja_id,
      "cucuk id": cucukId,
      "nama": nama,
      "jenis": jenis,
      "jumlah": jumlah,
    };
  }

  factory rekodCucukDetail.fromJson(Map<String, dynamic> toMap) {
    return rekodCucukDetail.fromMap(toMap);
  }
}

class rekodCucukFilter {
  int id = -1;
  String tarikh = '';
  String nama = '';
  int jumlah = 0;

  rekodCucukFilter(this.tarikh, this.nama, this.jumlah);

  rekodCucukFilter.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      tarikh = map['tarikh'] == null ? '' : formatTarikhToServer(map['tarikh']),
      nama = map["nama"],
      jumlah = map["jumlah"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {"id": id, "tarikh": tarikh, "nama": nama, "jumlah": jumlah};
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "tarikh": formatTarikh(tarikh),
      "nama": nama,
      "jumlah": jumlah,
    };
  }

  factory rekodCucukFilter.fromJson(Map<String, dynamic> toMap) {
    return rekodCucukFilter.fromMap(toMap);
  }
}

class rekodJumlahCucuk {
  int id = -1;
  int cucukId = 0;
  String jenis = '';
  int jumlah = 0;

  rekodJumlahCucuk(this.cucukId, this.jenis, this.jumlah);

  rekodJumlahCucuk.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      cucukId = map["cucuk id"],
      jenis = map["jenis"],
      jumlah = map["jumlah"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {"id": id, "cucuk id": cucukId, "jenis": jenis, "jumlah": jumlah};
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {"id": id, "cucuk id": cucukId, "jenis": jenis, "jumlah": jumlah};
  }

  factory rekodJumlahCucuk.fromJson(Map<String, dynamic> toMap) {
    return rekodJumlahCucuk.fromMap(toMap);
  }
}

class rekodPelanggan {
  int id = -1;
  String noBil = '';
  String epochTime = '';
  String tarikhOrder = '';
  String tarikh = '';
  String masa = '';
  String hari = '';
  String nama = '';
  String telefon = '';
  String alamat = '';
  int runner = 0;
  List<dynamic> orderMenu = [];
  num jumlahBayaran = 0.00;
  num BayaranPendahuluan = 0.00;
  num baki = 0.00;
  bool bayaranPenuh = false;

  rekodPelanggan(
    this.noBil,
    this.epochTime,
    this.tarikhOrder,
    this.tarikh,
    this.masa,
    this.hari,
    this.nama,
    this.telefon,
    this.alamat,
    this.runner,
    this.orderMenu,
    this.jumlahBayaran,
    this.BayaranPendahuluan,
    this.baki,
    this.bayaranPenuh,
  );

  rekodPelanggan.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      noBil = map["noBil"] ?? "",
      epochTime = map["epochTime"],
      tarikhOrder = map['tarikhOrder'] == null
          ? ''
          : formatTarikhToServer(map['tarikhOrder']),
      tarikh = map['tarikh'] == null ? '' : formatTarikhToServer(map['tarikh']),
      masa = map["masa"],
      hari = map["hari"],
      nama = map["nama"],
      telefon = map["telefon"],
      alamat = map["alamat"],
      runner = map["runner"],
      jumlahBayaran = map["jumlahBayaran"],
      BayaranPendahuluan = map["BayaranPendahuluan"],
      baki = map["baki"],
      bayaranPenuh = map["bayaranPenuh"],
      orderMenu = (map["Pelanggan Detail Rekod"] ?? [])
          .map(
            (e) => rekodPesananPelanggan.fromMap(Map<String, dynamic>.from(e)),
          )
          .toList();

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "noBil": noBil,
      "epochTime": epochTime,
      "tarikhOrder": tarikhOrder,
      "tarikh": tarikh,
      "masa": masa,
      "hari": hari,
      "nama": nama,
      "telefon": telefon,
      "alamat": alamat,
      "runner": runner,
      "jumlahBayaran": jumlahBayaran,
      "BayaranPendahuluan": BayaranPendahuluan,
      "baki": baki,
      "bayaranPenuh": bayaranPenuh,
      "Pelanggan Detail Rekod": orderMenu.map((e) => e.toMap()).toList(),
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "noBil": noBil,
      "epochTime": epochTime,
      "tarikhOrder": formatTarikh(tarikhOrder),
      "tarikh": formatTarikh(tarikh),
      "masa": masa,
      "hari": hari,
      "nama": nama,
      "telefon": telefon,
      "alamat": alamat,
      "runner": runner,
      "jumlahBayaran": jumlahBayaran,
      "BayaranPendahuluan": BayaranPendahuluan,
      "baki": baki,
      "bayaranPenuh": bayaranPenuh,
    };
  }

  factory rekodPelanggan.fromJson(Map<String, dynamic> toMap) {
    return rekodPelanggan.fromMap(toMap);
  }
}

class rekodPesananPelanggan {
  int id = -1;
  int pelanggan_id = -1;
  String jenis = '';
  num pesanan = 0.00;
  num Harga = 0.00;
  num Jumlah = 0.00;

  rekodPesananPelanggan(
    this.pelanggan_id,
    this.jenis,
    this.pesanan,
    this.Harga,
    this.Jumlah,
  );

  rekodPesananPelanggan.fromMap(
    Map<String, dynamic> map,
  ) // This Function helps to convert our Map into our User Object
  : id = map["id"],
      pelanggan_id = map["pesanan id"],
      jenis = map["jenis"],
      pesanan = map["pesanan"],
      Harga = map["Harga"],
      Jumlah = map["Jumlah"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "pesanan id": pelanggan_id,
      "jenis": jenis,
      "pesanan": pesanan,
      "Harga": Harga,
      "Jumlah": Jumlah,
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "pesanan id": pelanggan_id,
      "jenis": jenis,
      "pesanan": pesanan,
      "Harga": Harga,
      "Jumlah": Jumlah,
    };
  }

  factory rekodPesananPelanggan.fromJson(Map<String, dynamic> toMap) {
    return rekodPesananPelanggan.fromMap(toMap);
  }
}

class rekodRunner {
  int id = -1;
  String username = '';
  String nama = '';
  String telefon = '';

  rekodRunner(this.nama, this.telefon);

  rekodRunner.fromMap(
    Map<String, dynamic> map,
  ) // This Function helps to convert our Map into our User Object
  : id = map["id"],
      username = "${map["nama"]}_${map["id"]}",
      nama = map["nama"],
      telefon = map["telefon"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {"id": id, "nama": nama, "telefon": telefon};
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {"id": id, "nama": nama, "telefon": telefon};
  }

  factory rekodRunner.fromJson(Map<String, dynamic> toMap) {
    return rekodRunner.fromMap(toMap);
  }
}

class rekodStok {
  int id = -1;
  String epochTime = '';
  String tarikh = '';
  String hari = '';
  num jumlahPendapatan = 0.00;
  num kerugian = 0.00;
  List<dynamic> rekod = [];

  rekodStok(
    this.epochTime,
    this.tarikh,
    this.hari,
    this.jumlahPendapatan,
    this.kerugian,
    this.rekod,
  );

  rekodStok.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      epochTime = map["epochTime"],
      tarikh = map['tarikh'] == null ? '' : formatTarikhToServer(map['tarikh']),
      hari = map["hari"],
      jumlahPendapatan = map["Jumlah Pendapatan"],
      kerugian = map["Kerugian"],
      rekod = (map["Stok Detail Rekod"] ?? [])
          .map((e) => rekodStokDetail.fromMap(Map<String, dynamic>.from(e)))
          .toList();

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "epochTime": epochTime,
      "tarikh": tarikh,
      "hari": hari,
      "Jumlah Pendapatan": jumlahPendapatan,
      "Kerugian": kerugian,
      "Stok Detail Rekod": rekod.map((e) => e.toMap()).toList(),
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "epochTime": epochTime,
      "tarikh": formatTarikh(tarikh),
      "hari": hari,
      "Jumlah Pendapatan": jumlahPendapatan,
      "Kerugian": kerugian,
    };
  }

  factory rekodStok.fromJson(Map<String, dynamic> toMap) {
    return rekodStok.fromMap(toMap);
  }
}

class rekodStokDetail {
  int id = -1;
  int stokId = 0;
  String jenis = '';
  String stokLama = '';
  num stokBaru = 0;
  num simpan = 0;
  num keluar = 0;
  num jualan = 0;
  num baki = 0;
  num rugi = 0;
  bool simpanManual = false;

  rekodStokDetail(
    this.stokId,
    this.jenis,
    this.stokLama,
    this.stokBaru,
    this.simpan,
    this.keluar,
    this.jualan,
    this.baki,
    this.rugi,
    this.simpanManual,
  );

  rekodStokDetail.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      stokId = map["stok id"],
      jenis = map["menu"],
      stokLama = map["stokLama"],
      stokBaru = map["stokBaru"],
      simpan = map["simpan"],
      keluar = map["keluar"],
      jualan = map["jualan"],
      baki = map["baki"],
      rugi = map["rugi"],
      simpanManual = map["simpanManual"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "stok id": stokId,
      "menu": jenis,
      "stokLama": stokLama,
      "stokBaru": stokBaru,
      "simpan": simpan,
      "keluar": keluar,
      "jualan": jualan,
      "baki": baki,
      "rugi": rugi,
      "simpanManual": simpanManual,
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "stok id": stokId,
      "menu": jenis,
      "stokLama": stokLama,
      "stokBaru": stokBaru,
      "simpan": simpan,
      "keluar": keluar,
      "jualan": jualan,
      "baki": baki,
      "rugi": rugi,
      "simpanManual": simpanManual,
    };
  }

  factory rekodStokDetail.fromJson(Map<String, dynamic> toMap) {
    return rekodStokDetail.fromMap(toMap);
  }
}

class rekodGaji {
  int id = -1;
  String epochTime = '';
  String tarikh = '';
  String hari = '';
  List<dynamic> rekod = [];

  rekodGaji(this.epochTime, this.tarikh, this.hari);

  rekodGaji.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      epochTime = map["epochTime"],
      tarikh = map['tarikh'] == null ? '' : formatTarikhToServer(map['tarikh']),
      hari = map["hari"],
      rekod = (map["Gaji Detail Rekod"] ?? [])
          .map((e) => rekodGajiDetail.fromMap(Map<String, dynamic>.from(e)))
          .toList();

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "epochTime": epochTime,
      "tarikh": tarikh,
      "hari": hari,
      "Gaji Detail Rekod": rekod.map((e) => e.toMap()).toList(),
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "epochTime": epochTime,
      "tarikh": formatTarikh(tarikh),
      "hari": hari,
    };
  }

  factory rekodGaji.fromJson(Map<String, dynamic> toMap) {
    return rekodGaji.fromMap(toMap);
  }
}

class rekodGajiDetail {
  int id = -1;
  int gaji_id = -1;
  int pekerja_id = -1;
  num simpan = 0.00;
  num harian = 0.00;

  rekodGajiDetail(this.gaji_id, this.pekerja_id, this.simpan, this.harian);

  rekodGajiDetail.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      gaji_id = map["gaji id"],
      pekerja_id = map["pekerja id"],
      simpan = map["simpan"],
      harian = map["harian"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "gaji id": gaji_id,
      "pekerja id": pekerja_id,
      "simpan": simpan,
      "harian": harian,
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "gaji id": gaji_id,
      "pekerja id": pekerja_id,
      "simpan": simpan,
      "harian": harian,
    };
  }

  factory rekodGajiDetail.fromJson(Map<String, dynamic> toMap) {
    return rekodGajiDetail.fromMap(toMap);
  }
}

class rekodGajiFilter {
  String tarikh = '';
  String nama = '';
  num harian = 0.00;
  num simpan = 0.00;
  num ambil = 0.00;

  rekodGajiFilter(this.tarikh, this.nama, this.harian, this.simpan, this.ambil);

  rekodGajiFilter.fromMap(Map<String, dynamic> map)
    : tarikh = map['tarikh'] == null ? '' : formatTarikhToServer(map['tarikh']),
      nama = map["nama"],
      harian = map["harian"],
      simpan = map["simpan"],
      ambil = map["ambil"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "tarikh": tarikh,
      "nama": nama,
      "harian": harian,
      "simpan": simpan,
      "ambil": ambil,
    };
  }

  factory rekodGajiFilter.fromJson(Map<String, dynamic> toMap) {
    return rekodGajiFilter.fromMap(toMap);
  }
}

class rekodAmbilGaji {
  int id = -1;
  int pekerjaId = -1;
  String epochTime = '';
  String tarikh = '';
  String hari = '';
  num jumlah = 0.00;

  rekodAmbilGaji(
    this.pekerjaId,
    this.epochTime,
    this.tarikh,
    this.hari,
    this.jumlah,
  );

  rekodAmbilGaji.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      pekerjaId = map["pekerja id"],
      epochTime = map["epochTime"],
      tarikh = map['tarikh'] == null ? '' : formatTarikhToServer(map['tarikh']),
      hari = map["hari"],
      jumlah = map["jumlah"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "pekerja id": pekerjaId,
      "epochTime": epochTime,
      "tarikh": tarikh,
      "hari": hari,
      "jumlah": jumlah,
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "pekerja id": pekerjaId,
      "epochTime": epochTime,
      "tarikh": formatTarikh(tarikh),
      "hari": hari,
      "jumlah": jumlah,
    };
  }

  factory rekodAmbilGaji.fromJson(Map<String, dynamic> toMap) {
    return rekodAmbilGaji.fromMap(toMap);
  }
}

class rekodPembekalList {
  int id = -1;
  String username = '';
  String namaPembekal = '';
  List<dynamic> rekod = [];
  List<dynamic> rekodBayaran = [];

  rekodPembekalList(this.namaPembekal, this.rekod, this.rekodBayaran);

  rekodPembekalList.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      username = "${map["username"]}_${map["id"]}",
      namaPembekal = map["namaPembekal"],
      rekod = (map["Pembekal Detail Rekod"] ?? [])
          .map((e) => rekodPembekalDetail.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      rekodBayaran = (map["Pembekal Bayaran Rekod"] ?? [])
          .map(
            (e) => rekodBayaranPembekal.fromMap(Map<String, dynamic>.from(e)),
          )
          .toList();

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "namaPembekal": namaPembekal,
      "Pembekal Detail Rekod": rekod.map((e) => e.toMap()).toList(),
      "Pembekal Bayaran Rekod": rekodBayaran.map((e) => e.toMap()).toList(),
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {"id": id, "namaPembekal": namaPembekal};
  }

  factory rekodPembekalList.fromJson(Map<String, dynamic> toMap) {
    return rekodPembekalList.fromMap(toMap);
  }
}

class rekodPembekalDetail {
  int id = -1;
  int pembekal_id = -1;
  String epochTime = '';
  String tarikh = '';
  String hari = '';
  Map<String, dynamic> rekodBarang = {};
  num jumlah = 0.00;
  num bayaran = 0.00;
  num baki = 0.00;
  bool bayaranPenuh = false;

  rekodPembekalDetail(
    this.pembekal_id,
    this.epochTime,
    this.tarikh,
    this.hari,
    this.rekodBarang,
    this.jumlah,
    this.bayaran,
    this.baki,
    this.bayaranPenuh,
  );

  rekodPembekalDetail.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      pembekal_id = map["pembekal id"],
      epochTime = map["epochTime"],
      tarikh = map['tarikh'] == null ? '' : formatTarikhToServer(map['tarikh']),
      hari = map["hari"],
      rekodBarang = Map<String, dynamic>.from(map["rekodBarang"] ?? {}),
      jumlah = map["jumlah"],
      bayaran = map["bayaran"],
      baki = map["baki"],
      bayaranPenuh = map["bayaranPenuh"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "pembekal id": pembekal_id,
      "epochTime": epochTime,
      "tarikh": tarikh,
      "hari": hari,
      "rekodBarang": rekodBarang,
      "jumlah": jumlah,
      "bayaran": bayaran,
      "baki": baki,
      "bayaranPenuh": bayaranPenuh,
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "pembekal id": pembekal_id,
      "epochTime": epochTime,
      "tarikh": formatTarikh(tarikh),
      "hari": hari,
      "rekodBarang": rekodBarang,
      "jumlah": jumlah,
      "bayaran": bayaran,
      "baki": baki,
      "bayaranPenuh": bayaranPenuh,
    };
  }

  factory rekodPembekalDetail.fromJson(Map<String, dynamic> toMap) {
    return rekodPembekalDetail.fromMap(toMap);
  }
}

class rekodBarangPembekal {
  String nama = '';
  String kuantiti = '';
  num harga = 0.00;

  rekodBarangPembekal(this.nama, this.kuantiti, this.harga);

  rekodBarangPembekal.fromMap(Map<String, dynamic> map)
    : nama = map["nama"],
      kuantiti = map["kuantiti"],
      harga = map["harga"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {"nama": nama, "kuantiti": kuantiti, "harga": harga};
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {"nama": nama, "kuantiti": kuantiti, "harga": harga};
  }

  factory rekodBarangPembekal.fromJson(Map<String, dynamic> toMap) {
    return rekodBarangPembekal.fromMap(toMap);
  }
}

class rekodBayaranPembekal {
  int id = -1;
  int pembekalId = -1;
  String epochTime = '';
  String tarikh = '';
  String hari = '';
  num bayaran = 0.00;

  rekodBayaranPembekal(
    this.pembekalId,
    this.epochTime,
    this.tarikh,
    this.hari,
    this.bayaran,
  );

  rekodBayaranPembekal.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      pembekalId = map["pembekal id"],
      epochTime = map["epochTime"],
      tarikh = map['tarikh'] == null ? '' : formatTarikhToServer(map['tarikh']),
      hari = map["hari"],
      bayaran = map["bayaran"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "pembekal id": pembekalId,
      "epochTime": epochTime,
      "tarikh": tarikh,
      "hari": hari,
      "bayaran": bayaran,
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "id": id,
      "pembekal id": pembekalId,
      "epochTime": epochTime,
      "tarikh": formatTarikh(tarikh),
      "hari": hari,
      "bayaran": bayaran,
    };
  }

  factory rekodBayaranPembekal.fromJson(Map<String, dynamic> toMap) {
    return rekodBayaranPembekal.fromMap(toMap);
  }
}

class rekodPembekalFilter {
  String tarikh = '';
  String nama = '';
  num jumlah = 0.00;
  num bayaran = 0.00;
  num baki = 0.00;

  rekodPembekalFilter(
    this.tarikh,
    this.nama,
    this.jumlah,
    this.bayaran,
    this.baki,
  );

  rekodPembekalFilter.fromMap(Map<String, dynamic> map)
    : tarikh = map['tarikh'] == null ? '' : formatTarikhToServer(map['tarikh']),
      nama = map["nama"],
      jumlah = map["jumlah"],
      bayaran = map["bayaran"],
      baki = map["baki"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {
      "tarikh": tarikh,
      "nama": nama,
      "jumlah": jumlah,
      "bayaran": bayaran,
      "baki": baki,
    };
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {
      "tarikh": formatTarikh(tarikh),
      "nama": nama,
      "jumlah": jumlah,
      "bayaran": bayaran,
      "baki": baki,
    };
  }

  factory rekodPembekalFilter.fromJson(Map<String, dynamic> toMap) {
    return rekodPembekalFilter.fromMap(toMap);
  }
}

class rekodBarang {
  int id = -1;
  String nama = '';
  String unit = '';

  rekodBarang(this.nama, this.unit);

  rekodBarang.fromMap(Map<String, dynamic> map)
    : id = map["id"],
      nama = map["nama"],
      unit = map["unit"];

  Map<String, dynamic> toMap() {
    // This Function helps to convert our User Object into a Map.
    return {"id": id, "nama": nama, "unit": unit};
  }

  Map<String, dynamic> toMapServer() {
    // This Function helps to convert our User Object into a Map.
    return {"id": id, "nama": nama, "unit": unit};
  }

  factory rekodBarang.fromJson(Map<String, dynamic> toMap) {
    return rekodBarang.fromMap(toMap);
  }
}

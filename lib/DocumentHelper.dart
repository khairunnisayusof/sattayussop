import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../resit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:notification_center/notification_center.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
// import 'package:apple_product_name/apple_product_name.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:archive/archive_io.dart';
import 'package:url_launcher/url_launcher.dart';
import '../supabaseServer.dart';
import '../databaseLocal.dart';
import 'DocumentHelper.dart';

SharedPreferences? sharedPreferences;
List<rekodStok> rekod_stok = <rekodStok>[];
List<rekodList> rekod_List = <rekodList>[];
List<rekodCawangan> rekod_Cawangan = <rekodCawangan>[];
List<rekodCucuk> rekod_Cucuk = <rekodCucuk>[];
List<rekodPelanggan> rekod_Pelanggan = <rekodPelanggan>[];
List<rekodMenu> rekod_Menu = <rekodMenu>[];
List<rekodPekerja> rekod_Pekerja = <rekodPekerja>[];
List<rekodRunner> rekod_Runner = <rekodRunner>[];
List<rekodGaji> rekod_Gaji = <rekodGaji>[];
List<rekodPembekalList> rekod_Pembekal = <rekodPembekalList>[];
List<rekodBarang> senarai_Barang = <rekodBarang>[];
bool loginApps = false;

String zipFileName =
    'Rekod Sattay Ussop ${DateFormat('MMMM yyyy').format(DateTime.now())}.zip';
String fileHarian = 'Rekod_Harian.csv';
String fileStok = 'Rekod_Stok.csv';
String filePembekal = 'Rekod_Pembekal.csv';
String fileCawangan = 'Rekod_Cawangan.csv';
var font = pw.Font.helvetica();
DataStorage fileLog = DataStorage();
String path = "";
String money(num value) => value.toStringAsFixed(2);
int user_id = 0;
String role = '';

String adminPassword = "sattayussop@1993";
String managerPassword = "sattayussop1993";
String pekerjaPassword = "sattayussop";

Future<void> saveDataLocal() async {
  // await sharedPreferences?.remove("rekodMenu");
  // await sharedPreferences?.remove("rekodPekerja");
  // await sharedPreferences?.remove("rekodHarian");
  // await sharedPreferences?.remove("rekodCucuk");
  // await sharedPreferences?.remove("rekodCawangan");
  // await sharedPreferences?.remove("rekodPelanggan");
  // await sharedPreferences?.remove("rekodRunner");
  // await sharedPreferences?.remove("potonganGaji");
  // await sharedPreferences?.remove("rekodGaji");
  // await sharedPreferences?.remove("rekodPembekal");
  // await sharedPreferences?.remove("rekodStok");

  final jsonstringPekerja = jsonEncode(
    rekod_Pekerja.map((e) => e.toMap()).toList(),
  );
  await sharedPreferences?.setString("rekodPekerja", jsonstringPekerja);

  final jsonstringMenu = jsonEncode(rekod_Menu.map((e) => e.toMap()).toList());
  await sharedPreferences?.setString("rekodMenu", jsonstringMenu);

  final jsonstringHarian = jsonEncode(
    rekod_List.map((e) => e.toMap()).toList(),
  );
  await sharedPreferences?.setString("rekodHarian", jsonstringHarian);

  final jsonstringCucuk = jsonEncode(
    rekod_Cucuk.map((e) => e.toMap()).toList(),
  );
  await sharedPreferences?.setString("rekodCucuk", jsonstringCucuk);

  final jsonstringCawangan = jsonEncode(
    rekod_Cawangan.map((e) => e.toMap()).toList(),
  );
  await sharedPreferences?.setString("rekodCawangan", jsonstringCawangan);

  final jsonstringPelanggan = jsonEncode(
    rekod_Pelanggan.map((e) => e.toMap()).toList(),
  );
  await sharedPreferences?.setString("rekodPelanggan", jsonstringPelanggan);

  final jsonstringRunner = jsonEncode(
    rekod_Runner.map((e) => e.toMap()).toList(),
  );
  await sharedPreferences?.setString("rekodRunner", jsonstringRunner);

  final jsonstringGai = jsonEncode(rekod_Gaji.map((e) => e.toMap()).toList());
  await sharedPreferences?.setString("rekodGaji", jsonstringGai);

  final jsonstringPembekal = jsonEncode(
    rekod_Pembekal.map((e) => e.toMap()).toList(),
  );
  await sharedPreferences?.setString("rekodPembekal", jsonstringPembekal);

  final jsonstringSenaraibarang = jsonEncode(
    senarai_Barang.map((e) => e.toMap()).toList(),
  );
  await sharedPreferences?.setString("senaraiBarang", jsonstringSenaraibarang);

  final jsonstringStok = jsonEncode(rekod_stok.map((e) => e.toMap()).toList());
  await sharedPreferences?.setString("rekodStok", jsonstringStok);

  loadData();
}

Future<void> loadData() async {
  font = await PdfGoogleFonts.notoSansRegular();
  path = await fileLog._localPath;

  role = sharedPreferences?.getString("role") ?? '';
  user_id = sharedPreferences?.getInt("userId") ?? 0;

  final userString = sharedPreferences?.getString("rekodPekerja");
  if (userString != null) {
    final List data = jsonDecode(userString);
    rekod_Pekerja = data
        .map((e) => rekodPekerja.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    rekod_Pekerja.sort((a, b) => a.username.compareTo(b.username));
  }

  final jsonString = sharedPreferences?.getString("rekodHarian");
  if (jsonString != null) {
    final List data = jsonDecode(jsonString);
    rekod_List = data
        .map((e) => rekodList.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    rekod_List.sort((a, b) => a.epochTime.compareTo(b.epochTime));
  } else {
    await sharedPreferences?.remove("rekodHarian");
  }

  final menuList = sharedPreferences?.getString("rekodMenu");
  if (menuList != null) {
    final List data = jsonDecode(menuList);
    rekod_Menu = data
        .map((e) => rekodMenu.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    rekod_Menu.sort((a, b) => a.jenis.compareTo(b.jenis));
  } else {
    await sharedPreferences?.remove("rekodMenu");
  }

  final rekodCucukjsonString = sharedPreferences?.getString("rekodCucuk");
  if (rekodCucukjsonString != null) {
    final List data = jsonDecode(rekodCucukjsonString);
    rekod_Cucuk = data
        .map((e) => rekodCucuk.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    rekod_Cucuk.sort((a, b) => a.epochTime.compareTo(b.epochTime));
  } else {
    await sharedPreferences?.remove("rekodCucuk");
  }

  final cawanganListjsonString = sharedPreferences?.getString("rekodCawangan");
  if (cawanganListjsonString != null) {
    final List data = jsonDecode(cawanganListjsonString);
    rekod_Cawangan = data
        .map((e) => rekodCawangan.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    rekod_Cawangan.sort((a, b) => a.userName.compareTo(b.userName));
  } else {
    await sharedPreferences?.remove("rekodCawangan");
  }

  final pelangganList = sharedPreferences?.getString("rekodPelanggan");
  if (pelangganList != null) {
    final List data = jsonDecode(pelangganList);
    rekod_Pelanggan = data
        .map((e) => rekodPelanggan.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    rekod_Pelanggan.sort((a, b) => a.epochTime.compareTo(b.epochTime));
  } else {
    await sharedPreferences?.remove("rekodPelanggan");
  }

  final runnerString = sharedPreferences?.getString("rekodRunner");
  if (runnerString != null) {
    final List data = jsonDecode(runnerString);
    rekod_Runner = data
        .map((e) => rekodRunner.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    rekod_Runner.sort((a, b) => a.username.compareTo(b.username));
  } else {
    await sharedPreferences?.remove("rekodRunner");
  }

  final gajiString = sharedPreferences?.getString("rekodGaji");
  if (gajiString != null) {
    final List data = jsonDecode(gajiString);
    rekod_Gaji = data
        .map((e) => rekodGaji.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    rekod_Gaji.sort((a, b) => a.epochTime.compareTo(b.epochTime));
  } else {
    // await sharedPreferences?.remove("rekodGaji");
  }

  final pembekalString = sharedPreferences?.getString("rekodPembekal");
  if (pembekalString != null) {
    final List data = jsonDecode(pembekalString);
    rekod_Pembekal = data
        .map((e) => rekodPembekalList.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    rekod_Pembekal.sort((a, b) => a.username.compareTo(b.username));
  } else {
    await sharedPreferences?.remove("rekodPembekal");
  }

  final senaraiBarangString = sharedPreferences?.getString("senaraiBarang");
  if (senaraiBarangString != null) {
    final List data = jsonDecode(senaraiBarangString);
    senarai_Barang = data
        .map((e) => rekodBarang.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    senarai_Barang.sort((a, b) => a.nama.compareTo(b.nama));
  } else {
    await sharedPreferences?.remove("senaraiBarang");
  }

  final listString = sharedPreferences?.getString("rekodStok");
  if (listString != null) {
    final List data = jsonDecode(listString);
    rekod_stok = data
        .map((e) => rekodStok.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    rekod_stok.sort((a, b) => a.epochTime.compareTo(b.epochTime));
  } else {
    await sharedPreferences?.remove("rekodStok");
  }

  NotificationCenter().notify('refreshData', data: true);
}

void insertStok(String epochTime, String tarikhRekod, String hariRekod) async {
  if (!rekod_stok.map((item) => item.tarikh).contains(tarikhRekod)) {
    final result = await insertUpdateTable(
      'Stok Rekod',
      (rekodStok(
        epochTime,
        tarikhRekod,
        hariRekod,
        0.00,
        0.00,
        [],
      )).toMapServer(),
    );
    var stokCurrent = rekodStok.fromMap(result);
    var stokId = stokCurrent.id;
    var rekod = stokCurrent.rekod;

    final list = sortMenuList(rekod_Menu);

    for (final current in list) {
      String lowerName = current.jenis.toLowerCase();
      bool validMenu =
          lowerName.contains('satay') || lowerName.contains('nasi');
      if (!validMenu) continue;
      print("list >> ${current.jenis}");
      String nama = current.jenis
          .replaceAll("Satay ", "")
          .replaceAll(" Mentah", "");
      var rekodDetail = rekodStokDetail(
        stokId,
        nama,
        "",
        0,
        0,
        0,
        0,
        0,
        0,
        false,
      );
      await insertUpdateTable('Stok Detail Rekod', rekodDetail.toMapServer());
      rekod.add(rekodDetail);
    }
    rekod_stok.add(
      rekodStok(epochTime, tarikhRekod, hariRekod, 0.00, 0.00, rekod),
    );
  }
}

void updateStok(String tarikh) async {
  print("update stock $tarikh");
  if (rekod_Menu.isEmpty) {
    NotificationCenter().notify('refreshData', data: false);
    return;
  }

  final int row = rekod_stok.indexWhere((item) => item.tarikh == tarikh);
  final index = rekod_stok.elementAt(row).id;
  bool allEmpty = true;
  Set<String> tarikhRekod = {};
  num jumlahPendapatanStok = 0.00;
  num jumlahKerugianPendapatan = 0.00;
  rekodStok current = rekod_stok.firstWhere((element) => element.id == index);
  List<rekodStokDetail> stokCurrent = List<rekodStokDetail>.from(
    current.rekod,
  ).toList();

  for (var i = 0; i < stokCurrent.length; i++) {
    final current = stokCurrent.elementAt(i);
    current.keluar = 0;
    current.jualan = 0;
    current.baki = 0;
    current.rugi = 0;
    current.stokBaru = 0;
    stokCurrent[i] = current;
  }

  final stokMap = {for (final item in stokCurrent) item.jenis: item};
  try {
    if (rekod_List.isNotEmpty) {
      for (var index = 0; index < rekod_List.length; index++) {
        rekodList harianList = rekod_List.elementAt(index);
        tarikhRekod.add(harianList.tarikh);
        if (harianList.tarikh == tarikh) {
          allEmpty = false;
          List<rekodHarianDetail> stokHarian = List<rekodHarianDetail>.from(
            harianList.rekod,
          ).toList();
          for (var index = 0; index < stokHarian.length; index++) {
            rekodHarianDetail current = stokHarian.elementAt(index);
            Map<String, dynamic> rekodMenu = current.rekodMenu;
            for (var menu in rekodMenu.keys) {
              var value = rekodMenu[menu];
              var nama = menu.replaceAll("Satay ", "");
              int bawa = value["bawa"] ?? 0;
              int baki = value["baki"] ?? 0;
              int masak = value["masak"] ?? 0;
              int jualan = value["jualan"] ?? 0;
              int jumlahBawa = bawa;
              int bakiTerkini = baki + masak;
              final currentStok = stokMap[nama];
              if (currentStok != null) {
                final lowerMenu = menu.toLowerCase();
                final isNasi = lowerMenu.contains("nasi");
                isNasi
                    ? currentStok.stokBaru = currentStok.stokBaru + jumlahBawa
                    : currentStok.stokBaru = currentStok.stokBaru;
                currentStok.keluar = currentStok.keluar + jumlahBawa;
                currentStok.baki = currentStok.baki + bakiTerkini;
                currentStok.jualan = currentStok.jualan + jualan;
                stokMap[nama] = currentStok;
                print("record list >>> $nama | $value");
              }
            }
            jumlahPendapatanStok =
                jumlahPendapatanStok +
                (current.pendapatanJualan + current.pendapatanQR);
            jumlahKerugianPendapatan =
                jumlahKerugianPendapatan + current.kerugian;
          }
        }
      }
    }
  } catch (e, stackTrace) {
    print("ERROR list: $e");
    print(stackTrace);
  }
  try {
    if (rekod_Cucuk.isNotEmpty) {
      for (var index = 0; index < rekod_Cucuk.length; index++) {
        rekodCucuk cucukList = rekod_Cucuk.elementAt(index);
        tarikhRekod.add(cucukList.tarikh);
        if (cucukList.tarikh == tarikh) {
          allEmpty = false;
          List<rekodJumlahCucuk> stokCucuk = List<rekodJumlahCucuk>.from(
            cucukList.jumlahSatayList,
          ).toList();
          for (var index = 0; index < stokCucuk.length; index++) {
            rekodJumlahCucuk current = stokCucuk.elementAt(index);
            String nama = current.jenis
                .replaceAll("Satay ", "")
                .replaceAll(" Mentah", "");
            int jumlah = current.jumlah;
            final currentStok = stokMap[nama];
            print("cucuk data >>> $nama");
            if (currentStok != null) {
              currentStok.stokBaru = jumlah;
              stokMap[nama] = currentStok;
            }
          }
        }
      }
    }
  } catch (e, stackTrace) {
    print("ERROR cucuk: $e");
    print(stackTrace);
  }
  try {
    if (rekod_Pelanggan.isNotEmpty) {
      for (var index = 0; index < rekod_Pelanggan.length; index++) {
        rekodPelanggan pelangganList = rekod_Pelanggan.elementAt(index);
        tarikhRekod.add(pelangganList.tarikh);
        if (pelangganList.tarikh == tarikh) {
          allEmpty = false;
          List<rekodPesananPelanggan> pesananPelanggan =
              List<rekodPesananPelanggan>.from(
                pelangganList.orderMenu,
              ).toList();
          for (var k = 0; k < pesananPelanggan.length; k++) {
            rekodPesananPelanggan currentPelanggan = pesananPelanggan.elementAt(
              k,
            );
            print("element >>> $currentPelanggan");
            String menu = currentPelanggan.jenis;
            if (menu.toLowerCase().contains("satay") ||
                menu.toLowerCase().contains("mentah") ||
                menu.toLowerCase().contains("nasi")) {
              int jumlah = currentPelanggan.pesanan.toInt();
              var nama = menu
                  .replaceAll("Satay ", "")
                  .replaceAll(" Mentah", "");
              final currentStok = stokMap[nama];
              final lowerMenu = menu.toLowerCase();
              final isNasi = lowerMenu.contains("nasi");
              if (currentStok != null) {
                isNasi
                    ? currentStok.stokBaru = currentStok.stokBaru + jumlah
                    : currentStok.stokBaru = currentStok.stokBaru;
                currentStok.keluar = currentStok.keluar + jumlah;
                currentStok.jualan = currentStok.jualan + jumlah;
                stokMap[nama] = currentStok;
              }
            }
          }
          jumlahPendapatanStok =
              jumlahPendapatanStok + pelangganList.jumlahBayaran;
          jumlahKerugianPendapatan =
              jumlahKerugianPendapatan + pelangganList.baki;
        }
      }
    }
  } catch (e, stackTrace) {
    print("ERROR pelanggan: $e");
    print(stackTrace);
  }

  try {
    if (rekod_Cawangan.isNotEmpty) {
      for (var index = 0; index < rekod_Cawangan.length; index++) {
        rekodCawangan cawanganList = rekod_Cawangan.elementAt(index);
        List<rekodCawanganDetail> cawanganDetail =
            List<rekodCawanganDetail>.from(cawanganList.rekod).toList();
        for (var k = 0; k < cawanganDetail.length; k++) {
          rekodCawanganDetail currentCawangan = cawanganDetail.elementAt(k);
          if (currentCawangan.tarikh == tarikh) {
            allEmpty = false;
            tarikhRekod.add(currentCawangan.tarikh);
            Map<String, dynamic> rekodMenu = currentCawangan.rekodMenu;
            for (var menu in rekodMenu.keys) {
              if (menu.toLowerCase().contains("satay") ||
                  menu.toLowerCase().contains("mentah") ||
                  menu.toLowerCase().contains("nasi")) {
                var value = rekodMenu[menu];
                int bawa = value["bawa"] ?? 0;
                int baki = value["baki"] ?? 0;
                int rosak = value["rosak"] ?? 0;
                int jualan = bawa - baki - rosak;
                // int jumlahBawa = bawa;
                // int bakiTerkini = baki + masak;
                final nama = menu
                    .replaceAll("Satay ", "")
                    .replaceAll(" Mentah", "");
                final currentStok = stokMap[nama];
                final lowerMenu = menu.toLowerCase();
                final isNasi = lowerMenu.contains("nasi");
                if (currentStok != null) {
                  isNasi
                      ? currentStok.stokBaru = currentStok.stokBaru + bawa
                      : currentStok.stokBaru = currentStok.stokBaru;
                  currentStok.keluar = currentStok.keluar + bawa;
                  currentStok.baki = currentStok.baki + baki;
                  currentStok.jualan = currentStok.jualan + jualan;
                  stokMap[nama] = currentStok;
                }
              }
            }
            jumlahPendapatanStok =
                jumlahPendapatanStok + currentCawangan.bayaran;
            jumlahKerugianPendapatan =
                jumlahKerugianPendapatan + currentCawangan.baki;
          }
        }
      }
    }
  } catch (e, stackTrace) {
    print("ERROR cawangan: $e");
    print(stackTrace);
  }

  try {
    if (stokCurrent.isNotEmpty) {
      final currentDate = DateFormat("yyyy/MM/dd").parse(tarikh);
      final currentEpoch = currentDate.millisecondsSinceEpoch;
      // Previous stock dates
      final previousDates = rekod_stok
          .where(
            (e) =>
                DateFormat(
                  "yyyy/MM/dd",
                ).parse(e.tarikh).millisecondsSinceEpoch <
                currentEpoch,
          )
          .map((e) => e.tarikh)
          .toList();

      print("stok show >>> $currentDate | $currentEpoch >> $previousDates");
      final list = sortMenuList(stokCurrent);
      for (final currentStok in list) {
        final menu = currentStok.jenis;
        final id = currentStok.id;
        final isNasi = menu.toLowerCase().contains("nasi");
        num stokLama = 0;
        String stokLama0 = currentStok.stokLama;

        if (previousDates.isNotEmpty) {
          stokLama0 = previousDates.last;
          currentStok.stokLama = stokLama0;
        }

        if (stokLama0.isNotEmpty) {
          final targetStok = rekod_stok.cast<rekodStok?>().firstWhere(
            (e) => e!.tarikh == stokLama0,
            orElse: () => null,
          );

          if (targetStok != null) {
            final targetDetail = List<rekodStokDetail>.from(targetStok.rekod)
                .cast<rekodStokDetail?>()
                .firstWhere((e) => e!.jenis == menu, orElse: () => null);

            if (targetDetail != null) {
              stokLama = isNasi ? 0 : targetDetail.baki;
            }
          }
        }

        num jumlahStok = stokLama + currentStok.stokBaru;

        if (isNasi) {
          jumlahStok = currentStok.keluar;
        }

        if (!currentStok.simpanManual) {
          currentStok.simpan = jumlahStok - currentStok.keluar;
        }

        if (currentStok.simpan < 0) {
          currentStok.simpan = 0;
        }

        currentStok.baki = isNasi
            ? currentStok.simpan
            : currentStok.baki + currentStok.simpan;

        currentStok.rugi = (jumlahStok - currentStok.jualan - currentStok.baki)
            .clamp(0, double.infinity);

        print(
          "rekod stok >>> $tarikh >> $menu >> ${currentStok.id} >> ${currentStok.stokId} >> ${currentStok.keluar} $jumlahStok | ${currentStok.simpanManual}",
        );
        if (id >= 0) {
          await insertUpdateTable(
            'Stok Detail Rekod',
            currentStok.toMapServer(),
            id: id,
          );
        }
      }
    }
  } catch (e, stackTrace) {
    print("ERROR stok: $e");
    print(stackTrace);
  }
  try {
    if (tarikh.isNotEmpty) {
      print(
        "refresh table >> start >>> $allEmpty | ${rekod_stok.map((item) => item.tarikh).contains(tarikh)}",
      );
      if (allEmpty && rekod_stok.map((item) => item.tarikh).contains(tarikh)) {
        removeItem(tarikh);
      } else if (rekod_stok.map((item) => item.tarikh).contains(tarikh)) {
        current.rekod = stokCurrent;
        current.jumlahPendapatan = jumlahPendapatanStok;
        current.kerugian = jumlahKerugianPendapatan;
        saveDataStok(current);
      }
    }
  } catch (e, stackTrace) {
    print("ERROR current stok: $e");
    print(stackTrace);
  }
}

void removeItem(String tarikh) {
  try {
    final stok = rekod_stok.firstWhere((e) => e.tarikh == tarikh);
    var id = stok.id;
    deleteRow('Stok Rekod', id);
  } catch (_) {
    return;
  }
}

// This block saves our list locally.
void saveDataStok(rekodStok usr) {
  insertUpdateTable('Stok Rekod', usr.toMapServer(), id: usr.id);
  // for (final current in rekod_stok) {
  //   final tarikh0 = current.tarikh;
  //   updateStok(tarikh0);
  // }
  NotificationCenter().notify('refreshData', data: true);
}

Map<String, dynamic> sortMenu(Map<String, dynamic> menu) {
  final order = ["Ayam", "Daging", "Perut", "Nasi"];

  Map<String, dynamic> result = {};

  for (var keyword in order) {
    for (var key in menu.keys) {
      if (key.toLowerCase().contains(keyword.toLowerCase())) {
        result[key] = menu[key];
      }
    }
  }

  // Tambah menu yang tidak termasuk dalam sorting
  for (var key in menu.keys) {
    if (!result.containsKey(key)) {
      result[key] = menu[key];
    }
  }

  print("result sort menu >> $result");
  return result;
}

List<dynamic> sortMenuList(List<dynamic> list) {
  const order = ["Ayam", "Daging", "Perut", "Nasi"];

  list.sort((a, b) {
    int index(String jenis) {
      final lower = jenis.toLowerCase();
      final i = order.indexWhere((e) => lower.contains(e.toLowerCase()));
      return i == -1 ? order.length : i;
    }

    final ia = index(a.jenis);
    final ib = index(b.jenis);

    if (ia != ib) {
      return ia.compareTo(ib);
    }

    return a.jenis.compareTo(b.jenis);
  });
  return list;
}

String formatTarikh(String tarikh) {
  try {
    return DateFormat(
      "yyyy/MM/dd",
    ).format(DateFormat("dd/MM/yyyy").parseStrict(tarikh));
  } catch (_) {
    // Sudah dalam format lain, terus pulangkan
    return tarikh;
  }
}

String formatTarikhToServer(String tarikh) {
  try {
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(tarikh.toString()));
  } catch (_) {
    // Sudah dalam format lain, terus pulangkan
    return tarikh;
  }
}

Future<void> launchWhatsappWithMobileNumber(
  String mobileNumber,
  String message,
) async {
  String number = mobileNumber.cleanNumber();

  if (!number.startsWith("6")) {
    number = "6$number";
  }

  String encodedMessage = Uri.encodeComponent(message);

  final Uri uri = Uri.parse("https://wa.me/$number?text=$encodedMessage");

  // Try regular WhatsApp first
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return;
  }

  // If fails, try WhatsApp Business
  final Uri uriBusiness = Uri.parse(
    "https://wa.me/$number?text=$encodedMessage",
  ); // same URL, but for Business app

  // On Android, we can specify package explicitly if needed
  // But https://wa.me works for both apps on Android/iOS

  if (await canLaunchUrl(uriBusiness)) {
    await launchUrl(uriBusiness, mode: LaunchMode.externalApplication);
    return;
  }

  debugPrint("WhatsApp (Regular & Business) not installed or cannot open");
}

String getNumber(String str) {
  String newnum = str.replaceAll(RegExp(r'[^0-9]'), '');
  return newnum;
}

class DataStorage {
  Future get _localPath async {
    // final directory = await getApplicationDocumentsDirectory();
    final dirInternal = await getApplicationDocumentsDirectory();
    final directory = await getTemporaryDirectory();
    return directory.path ?? dirInternal.path;
  }

  Future _localFile(String FileName) async {
    final path = await _localPath;
    return File('$path/$FileName');
  }

  Future<void> attachLogFile(BuildContext context) async {
    try {
      if (rekod_stok.isNotEmpty) {
        for (var index = 0; index < rekod_stok.length; index++) {
          rekodStok stokList = rekod_stok.elementAt(index);
          String tarikh = stokList.tarikh;
          List<rekodStokDetail> rekod = List<rekodStokDetail>.from(
            stokList.rekod,
          ).toList();
          for (var k = 0; k < rekod.length; k++) {
            final current = rekod[k];

            final String nama = current.jenis;
            final String stokLama0 = current.stokLama;

            num stokLama = 0;

            if (stokLama0.isNotEmpty) {
              final stokIndex = rekod_stok.indexWhere(
                (e) => e.tarikh == stokLama0,
              );
              if (stokIndex == -1) {
                continue; // jangan stop semua loop
              }

              final targetStok = rekod_stok[stokIndex];

              final stokDetail = List<rekodStokDetail>.from(
                targetStok.rekod,
              ).toList();

              final detailIndex = stokDetail.indexWhere((e) => e.jenis == nama);

              if (detailIndex == -1) {
                continue;
              }

              stokLama = stokDetail[detailIndex].baki;
            }

            final stokBaru = current.stokBaru;
            final stokSimpan = current.simpan;
            final keluar = current.keluar;
            final jualan = current.jualan;
            final baki = current.baki;
            final rugi = current.rugi;

            final line = k == 0
                ? '$tarikh,$nama,$stokLama,$stokBaru,$stokSimpan,$keluar,$jualan,$baki,$rugi,${stokList.jumlahPendapatan},${stokList.kerugian}'
                : '"",$nama,$stokLama,$stokBaru,$stokSimpan,$keluar,$jualan,$baki,$rugi,0.00,0.00';

            await writeData(line, fileStok);
          }
        }
      }
      if (rekod_Pembekal.isNotEmpty) {
        for (final currentPembekal in rekod_Pembekal) {
          final String nama = currentPembekal.namaPembekal;

          final rekod = List<rekodPembekalDetail>.from(
            currentPembekal.rekod,
          ).toList();

          for (final currentDetail in rekod) {
            final String tarikh = currentDetail.tarikh;
            final num jumlah = currentDetail.jumlah;
            final num bayaran = currentDetail.bayaran;
            final num baki = currentDetail.baki;

            await writeData(
              '$tarikh,$nama,$jumlah,$bayaran,$baki',
              filePembekal,
            );
          }
        }
      }
      if (rekod_List.isNotEmpty) {
        for (final currentHarian in rekod_List) {
          final String tarikh = currentHarian.tarikh;

          final rekod = List<rekodHarianDetail>.from(
            currentHarian.rekod,
          ).toList();

          for (final currentDetail in rekod) {
            final String nama = currentDetail.namaPasarMalam;

            final int jumlah = currentDetail.jumlahSatay;
            final int jumlahNS = currentDetail.jualanNS;

            final num jualan = currentDetail.jumlahJualan;
            final num barang = currentDetail.barang;
            final num pendapatan = currentDetail.pendapatanJualan;
            final num QR = currentDetail.pendapatanQR;
            final num pendapatanSebenar = currentDetail.pendapatanSebenar;
            final num rugi = currentDetail.kerugian;

            final Map<String, dynamic> rekodMenu = currentDetail.rekodMenu;

            // CASE 1: no menu breakdown
            if (rekodMenu.isEmpty) {
              await writeData(
                '$tarikh,$nama,"",0,0,0,0,$jumlah,$jumlahNS,$jualan,$barang,$pendapatan,$QR,$pendapatanSebenar,$rugi',
                fileHarian,
              );
              continue;
            }

            // CASE 2: menu breakdown
            int menuIndex = 0;

            for (final entry in rekodMenu.entries) {
              final menu = entry.key;
              final value = entry.value;

              final bawa = value['bawa'] ?? 0;
              final baki = value['baki'] ?? 0;
              final masak = value['masak'] ?? 0;
              final rosak = value['rosak'] ?? 0;

              final line = menuIndex == 0
                  ? '$tarikh,$nama,$menu,$bawa,$baki,$rosak,$masak,$jumlah,$jumlahNS,$jualan,$barang,$pendapatan,$QR,$pendapatanSebenar,$rugi'
                  : '"","",$menu,$bawa,$baki,$rosak,$masak,$jumlah,$jumlahNS,$jualan,$barang,$pendapatan,$QR,$pendapatanSebenar,$rugi';

              await writeData(line, fileHarian);
              menuIndex++;
            }
          }
        }
      }

      if (rekod_Cawangan.isNotEmpty) {
        for (final currentHarian in rekod_Cawangan) {
          final String nama = currentHarian.nama;

          final rekod = List<rekodCawanganDetail>.from(
            currentHarian.rekod,
          ).toList();

          for (final currentDetail in rekod) {
            final String tarikh = currentDetail.tarikh;
            final int jumlah = currentDetail.jumlahSatay;
            final num jualan = currentDetail.jumlahJualan;
            final num pendapatan = currentDetail.bayaran;
            final num baki = currentDetail.baki;
            final num rugi = currentDetail.rugi;

            final Map<String, dynamic> rekodMenu = currentDetail.rekodMenu;

            // CASE 1: no menu breakdown
            if (rekodMenu.isEmpty) {
              await writeData(
                '$tarikh,$nama,"",0,0,0,$jumlah,$jualan,$rugi,$pendapatan,$baki',
                fileCawangan,
              );
              continue;
            }

            // CASE 2: menu breakdown
            int menuIndex = 0;

            for (final entry in rekodMenu.entries) {
              final menu = entry.key;
              final value = entry.value;

              final bawa = value['bawa'] ?? 0;
              final bakiMenu = value['baki'] ?? 0;
              final rosak = value['rosak'] ?? 0;

              final line = menuIndex == 0
                  ? '$tarikh,$nama,$menu,$bawa,$bakiMenu,$rosak,$jumlah,$jualan,$rugi,$pendapatan,$baki'
                  : '"","",$menu,$bawa,$bakiMenu,$rosak,$jumlah,$jualan,$rugi,$pendapatan,$baki';

              await writeData(line, fileCawangan);
              menuIndex++;
            }
          }
        }
      }
      zipFile(context);
    } catch (e) {
      // Error in getting access to the file.
      print("error write >>> ${e.toString()}");
    }
  }

  Future<void> writeData(String data, String FileName) async {
    // final path = await _localPath;
    final file = File('$path/$FileName');
    try {
      var string = "";
      if (await file.exists()) {
        print("have file");
        string = '\r\n$data';
      } else {
        print("no have file");
        if (FileName == fileStok) {
          string =
              'Tarikh,Menu,Stok Lama,Stok Baru,Stok Simpan,Stok Keluar,Jualan,Baki,Rugi,Pendapatan,Kerugian\r\n$data';
        } else if (FileName == filePembekal) {
          string =
              'Tarikh,Nama,Jumlah Keseluruhan,Jumlah Sudah Bayar,Baki\r\n$data';
        } else if (FileName == fileHarian) {
          string =
              'Tarikh,Nama,Manu,Bawa,Baki,Rosak,Masak,Jumlah Satay,Jumlah Nasi Himpit,Jumlah Jualan,Beli Barang,Pendapatan Jualan,QR,Pendapatan Sebenar,Kerugian\r\n$data';
        } else if (FileName == fileCawangan) {
          string =
              'Tarikh,Nama,Manu,Bawa,Baki,Rosak,Jumlah Satay,Jumlah Jualan,Kerugian,Jumlah Sudah Bayar,Baki\r\n$data';
        }
      }
      // Write the file
      print("data write file $file >> $string");
      await file.writeAsString(string, mode: FileMode.append, flush: false);
    } catch (e) {
      // Error in getting access to the file.
      print("error write >>> ${e.toString()}");
    }
  }

  Future<void> removeLocalFile(String FileName) async {
    // final path = await _localPath;
    var file = File('$path/$FileName');
    try {
      if (await file.exists()) {
        await file.delete();
        print("successfully delete");
      }
    } catch (e) {
      // Error in getting access to the file.
    }
  }

  Future<void> shareData(BuildContext context, String FileName) async {
    // final path = await _localPath;
    var subject = "Rekod Sattay Ussop";
    var localFile = File('$path/$FileName');

    final result = await Share.shareXFiles([
      XFile(localFile.path),
    ], subject: subject);
    if (result.status == ShareResultStatus.success) {
      print("successfully send");
      removeLocalFile(FileName);
    }
  }

  Future<void> zipFile(BuildContext context) async {
    bool allEmpty = true;
    // final path = await _localPath;
    var encoder = ZipFileEncoder();
    zipFileName =
        'Rekod Sattay Ussop ${DateFormat('MMMM yyyy').format(DateFormat("dd/MM/yyyy").parse(rekod_stok.elementAt(0).tarikh.toString()))}.zip';
    var zipFile = File('$path/$zipFileName');
    try {
      encoder.create(zipFile.path);
      print("Start zip file");

      if (rekod_stok.isNotEmpty) {
        allEmpty = false;
        final stokFile = File('$path/$fileStok');
        if (await stokFile.exists()) {
          encoder.addFile(stokFile);
          await stokFile.delete();
        }
      }

      if (rekod_List.isNotEmpty) {
        allEmpty = false;
        final harianFile = File('$path/$fileHarian');
        if (await harianFile.exists()) {
          encoder.addFile(harianFile);
          await harianFile.delete();
        }
      }

      if (rekod_Pekerja.isNotEmpty &&
          (rekod_Gaji.isNotEmpty || rekod_Cucuk.isNotEmpty)) {
        allEmpty = false;
        var encoderGaji = ZipFileEncoder();
        var encoderCucuk = ZipFileEncoder();
        var fileGaji = File('$path/Rekod_Gaji_Pekerja.zip');
        var fileCucuk = File('$path/Rekod_Gaji_Cucuk.zip');
        encoderGaji.create(fileGaji.path);
        encoderCucuk.create(fileCucuk.path);
        var fileDetailCucuk = await PdfCucukGaji.generate(
          PdfColors.black,
          "Semua Pekerja",
        );
        var fileDetailGaji = await PdfDetailGaji.generate(
          PdfColors.black,
          "Semua Pekerja",
        );
        encoderCucuk.addFile(fileDetailCucuk);
        encoderGaji.addFile(fileDetailGaji);
        await fileDetailCucuk.delete();
        await fileDetailGaji.delete();
        for (var index = 0; index < rekod_Pekerja.length; index++) {
          rekodPekerja current = rekod_Pekerja.elementAt(index);
          if (current.cucuk) {
            final pdfFile = await PdfCucukGaji.generate(
              PdfColors.black,
              current.username,
            );
            encoderCucuk.addFile(pdfFile);
            await pdfFile.delete();
          } else {
            final pdfFile = await PdfSlipGaji.generate(
              PdfColors.black,
              current.username,
              true,
            );
            final pdfFileNonKWSP = await PdfSlipGaji.generate(
              PdfColors.black,
              current.username,
              false,
            );
            encoderGaji.addFile(pdfFile);
            encoderGaji.addFile(pdfFileNonKWSP);
            await pdfFile.delete();
            await pdfFileNonKWSP.delete();
          }
        }
        await encoderCucuk.close();
        await encoderGaji.close();
        encoder.addFile(fileGaji);
        encoder.addFile(fileCucuk);
        await fileGaji.delete();
        await fileCucuk.delete();
      }

      if (rekod_Cawangan.isNotEmpty) {
        allEmpty = false;
        var file = File('$path/$fileCawangan');
        if (await file.exists()) {
          encoder.addFile(file);
          await file.delete();
          var encoderCawangan = ZipFileEncoder();
          var bayaranCawangan = File('$path/Rekod_Bayaran_cawangan.zip');
          encoderCawangan.create(bayaranCawangan.path);
          for (var index = 0; index < rekod_Cawangan.length; index++) {
            rekodCawangan currentCawangan = rekod_Cawangan.elementAt(index);
            String nama = currentCawangan.nama;
            List<rekodBayaranCawangan> rekod = List<rekodBayaranCawangan>.from(
              currentCawangan.rekodBayaran,
            ).toList();
            if (rekod.isNotEmpty) {
              print(
                "start zip file bayaran cawangan >> $nama : ${rekod.length}",
              );
              for (var i = 0; i < rekod.length; i++) {
                rekodBayaranCawangan currentDetail = rekod.elementAt(i);
                String tarikh = currentDetail.tarikh;
                // List<rekodBayaranCawangan> rekodBayaran = currentDetail.rekodBayaran
                //     .map((item) => rekodBayaranCawangan.fromMap(json.decode(item)))
                //     .toList();
                final pdfFile = await PdfBayaranCawanganResit.generate(
                  PdfColors.black,
                  nama,
                  tarikh,
                );
                encoderCawangan.addFile(pdfFile);
                await pdfFile.delete();
              }
            }
          }
          await encoderCawangan.close();
          encoder.addFileSync(bayaranCawangan);
          await bayaranCawangan.delete();
        }
      }

      if (rekod_Pembekal.isNotEmpty) {
        allEmpty = false;
        var file = File('$path/$filePembekal');
        if (await file.exists()) {
          encoder.addFile(file);
          file.delete();
          var encoderPembekal = ZipFileEncoder();
          var bayaranPembekal = File('$path/Rekod_Bayaran_Pembekal.zip');
          encoderPembekal.create(bayaranPembekal.path);
          for (var index = 0; index < rekod_Pembekal.length; index++) {
            rekodPembekalList currentPembekal = rekod_Pembekal.elementAt(index);
            String nama = currentPembekal.namaPembekal;
            List<rekodBayaranPembekal> rekod = List<rekodBayaranPembekal>.from(
              currentPembekal.rekodBayaran,
            ).toList();
            if (rekod.isNotEmpty) {
              print(
                "start zip file bayaran pembekal >> $nama : ${rekod.length}",
              );
              for (var i = 0; i < rekod.length; i++) {
                rekodBayaranPembekal currentDetail = rekod.elementAt(i);
                String tarikh = currentDetail.tarikh;
                final pdfFile = await PdfBayaranPembekalResit.generate(
                  PdfColors.black,
                  nama,
                  tarikh,
                );
                encoderPembekal.addFile(pdfFile);
                await pdfFile.delete();
              }
            }
          }
          await encoderPembekal.close();
          encoder.addFileSync(bayaranPembekal);
          await bayaranPembekal.delete();
        }
      }
    } finally {
      encoder.close();
    }
    if (allEmpty) {
      await zipFile.delete();
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: Text('Your File log is not available.'),
          title: Center(
            child: Column(
              children: <Widget>[
                Text(
                  'Warning',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    shareData(context, zipFileName);
  }
}

class FileHandleApi {
  // save pdf file function
  static Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();
    final dirInternal = await getApplicationDocumentsDirectory();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path ?? dirInternal.path}/$name');
    print("save file $name $file");
    await file.writeAsBytes(bytes);
    return file;
  }

  // open pdf file function
  static Future openFile(File file) async {
    final url = file.path;
    print("open file >>> $url");
    await OpenFile.open(url);
  }
}

extension NumberFormatExtension on String {
  double toDoubleNumberFormat() {
    return double.tryParse(toEnglishNumberFormat()) ?? 0.0;
  }

  int totalIntNumber() {
    try {
      final input = trim();

      if (input.contains('+')) {
        return input
            .split('+')
            .map((e) => int.parse(e.trim()))
            .reduce((a, b) => a + b);
      }

      if (input.contains('-')) {
        final parts = input.split('-').map((e) => int.parse(e.trim())).toList();

        return parts.skip(1).fold(parts.first, (a, b) => a - b);
      }

      if (input.contains('*')) {
        return input
            .split('*')
            .map((e) => int.parse(e.trim()))
            .reduce((a, b) => a * b);
      }

      if (input.contains('/')) {
        final parts = input.split('/').map((e) => int.parse(e.trim())).toList();

        return parts
            .skip(1)
            .fold(parts.first, (a, b) => a ~/ b); // integer division
      }

      return int.parse(input);
    } catch (_) {
      return 0;
    }
  }

  double totalDoubleNumber() {
    try {
      final input = trim();

      if (input.contains('+')) {
        return input
            .split('+')
            .map((e) => e.trim().toDoubleNumberFormat())
            .reduce((a, b) => a + b);
      }

      if (input.contains('-')) {
        final parts = input
            .split('-')
            .map((e) => e.trim().toDoubleNumberFormat())
            .toList();

        return parts.skip(1).fold(parts.first, (a, b) => a - b);
      }

      if (input.contains('*')) {
        return input
            .split('*')
            .map((e) => e.trim().toDoubleNumberFormat())
            .reduce((a, b) => a * b);
      }

      if (input.contains('/')) {
        final parts = input
            .split('/')
            .map((e) => e.trim().toDoubleNumberFormat())
            .toList();

        return parts.skip(1).fold(parts.first, (a, b) => a / b);
      }

      return input.toDoubleNumberFormat();
    } catch (_) {
      return 0.0;
    }
  }

  String toEnglishNumberFormat() {
    try {
      String input = trim();

      if (input.isEmpty) return "0";

      // Remove currency, spaces, and invalid characters
      input = input.replaceAll(RegExp(r'[^0-9,.-]'), '');

      int lastComma = input.lastIndexOf(',');
      int lastDot = input.lastIndexOf('.');

      if (lastComma > lastDot) {
        // Format like 1.234,56
        input = input.replaceAll('.', '');
        input = input.replaceAll(',', '.');
      } else {
        // Format like 1,234.56
        input = input.replaceAll(',', '');
      }

      return input;
    } catch (e) {
      return "0";
    }
  }

  String toEnglishDisplayFormat() {
    try {
      double value = toDoubleNumberFormat();

      final format = NumberFormat("#,##0.################", "en_US");

      return format.format(value);
    } catch (e) {
      return "0";
    }
  }

  String cleanNumber() {
    // Remove spaces and +6 prefix
    String cleaned = replaceAll(" ", "").replaceAll("+6", "");

    // Keep digits only
    cleaned = cleaned.replaceAll(RegExp(r'[^0-9]'), "");

    return cleaned;
  }
}

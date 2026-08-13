import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:notification_center/notification_center.dart';
import 'package:string_capitalize/string_capitalize.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'DocumentHelper.dart';
import 'databaseLocal.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';


final supabase = Supabase.instance.client;
final urlPrivacy = "https://ifgsuxodlpdesffnjigw.supabase.co/storage/v1/object/public/privacy%20policy/Privacy_Policy_ENG_BM.pdf";

Future<List<Map<String, dynamic>>> selectTable(
  String nameTable,{
      String detailTable = '',
      String thirdTable = '',
}) async {
  if (roleID <= 0 &&
      nameTable != supabaseRole &&
      nameTable != supabasePekerja &&
      nameTable != supabaseMenu &&
      !kIsWeb) {
    return [];
  }
  final query = supabase.from(nameTable);

  String selectQuery = '*';

  if (detailTable.isNotEmpty) {
    selectQuery += ', "$detailTable"(*)';
  }

  if (thirdTable.isNotEmpty) {
    selectQuery += ', "$thirdTable"(*)';
  }

  final data = await query.select(selectQuery);
  // print("select table $nameTable >> ${List<Map<String, dynamic>>.from(data)}");
  return List<Map<String, dynamic>>.from(data);
}

Future<Map<String, dynamic>> insertUpdateTable(
  String nameTable,
  Map<String, dynamic> currentRecord, {
  int? id,
}) async {
  print("insert record >> $nameTable | $id | $currentRecord");
  if (role.toLowerCase() == "review") {
    return currentRecord;
  }
  if (id == null) {
    currentRecord.remove("id");
    final result = await supabase
        .from(nameTable)
        .insert(currentRecord)
        .select()
        .single();

    processServerData(nameTable);
    return result;
  } else {
    final result = await supabase
        .from(nameTable)
        .update(currentRecord)
        .eq('id', id)
        .select()
        .single();

    processServerData(nameTable);
    return result;
  }
}

Future<void> deleteRow(String nameTable, int id) async {
  if (!delete) {
    return;
  }
  print("record delete >> $nameTable | $id");
  await supabase.from(nameTable).delete().eq('id', id);
  processServerData(nameTable);
}

Future<void> deleteAllRecord(String nameTable) async {
  if (!delete) {
    return;
  }
  await supabase.from(nameTable).delete().gte('id', 0);
  final name = nameTable.replaceAll(' ', '_').toLowerCase();

  await supabase.rpc('truncate_$name');
  processServerData(nameTable);
}

Future<void> deleteAllRecordFromForeign(
  String nameTable,
  String columnName,
  int id,
) async {
  if (!delete) {
    return;
  }
  try {
    await supabase.from(nameTable).delete().eq(columnName, id);
    processServerData(nameTable);
  } catch (e) {
    print("Delete gagal: $e");
  }
}


Future<bool> hasInternet() async {
  try {
    final results = await selectTable(supabaseRole);
    return results.isNotEmpty;
  } catch (e) {
    return false;
  }
}

Future<void> processServerData(String tableName) async {
  switch (tableName) {
    case supabaseKategoriMenu || supabaseMenu || supabaseRole || supabaseRunner || supabaseBarang:
      loadDataServer(nameTable: tableName);
      break;
    case supabasePekerja || supabaseAmbilGaji:
      loadDataServer(nameTable: supabasePekerja,secondTable: supabaseAmbilGaji);
      break;
    case supabaseStok || supabaseStokDetail :
      loadDataServer(nameTable: supabaseStok,secondTable: supabaseStokDetail);
      break;
    case supabaseHarian || supabaseHarianDetail:
      loadDataServer(nameTable: supabaseHarian,secondTable: supabaseHarianDetail);
      break;
    case supabaseCucuk || supabaseCucukDetail || supabaseJumlahCucuk:
      loadDataServer(nameTable: supabaseCucuk,secondTable: supabaseCucukDetail,thirdTable: supabaseJumlahCucuk);
      break;
    case supabaseGaji || supabaseGajiDetail:
      loadDataServer(nameTable: supabaseGaji,secondTable: supabaseGajiDetail);
      break;
    case supabasePelanggan || supabasePelangganDetail:
      loadDataServer(nameTable: supabasePelanggan,secondTable: supabasePelangganDetail);
      break;
    case supabaseCawangan || supabaseCawanganDetail ||supabaseCawanganBayaran :
      loadDataServer(nameTable: supabaseCawangan,secondTable: supabaseCawanganDetail,thirdTable: supabaseCawanganBayaran);
      break;
    case supabasePembekal || supabasePembekalDetail || supabasePembekalBayaran:
      loadDataServer(nameTable: supabasePembekal,secondTable: supabasePembekalDetail,thirdTable: supabasePembekalBayaran);
      break;
  }
  print("💾 get local: $tableName");
}

Future<bool> loadDataServer({String nameTable = '', String secondTable = '', String thirdTable = ''}) async {
  try {
    // Check Internet dahulu
    internetAvailable = await hasInternet();
    if (!internetAvailable) {
      print("❌ Tiada Internet");
      return false;
    }
      print("✅ Internet ada");

    if (nameTable.isNotEmpty) {
      final result = await selectTable(nameTable,detailTable: secondTable,thirdTable: thirdTable);
      print("result nameTable not empty >> ${nameTable} | ${secondTable} | ${thirdTable}");
      await processTableData(nameTable, result);
      return true;
    }

    final results = await Future.wait([
      selectTable(supabaseKategoriMenu),
      selectTable(supabaseMenu),
      selectTable(supabaseRole)
    ]);
    await processTableData(supabaseKategoriMenu, results[0]);
    await processTableData(supabaseMenu, results[1]);
    await processTableData(supabaseRole, results[2]);

    final index = rekod_Role.indexWhere((e) => e.id == roleID);

    if (index != -1) {
      final current = rekod_Role[index];
      role = current.role;
      read = current.read;
      write = current.write;
      delete = current.delete;
    } else {
      role = "";
      read = false;
      write = false;
      delete = false;
    }

    if (role.isNotEmpty && !kIsWeb) {
      final resultsUser = await Future.wait([
        selectTable(supabasePekerja, detailTable: supabaseAmbilGaji),
        selectTable(supabaseStok, detailTable: supabaseStokDetail),
        selectTable(supabaseHarian, detailTable: supabaseHarianDetail),
        selectTable(supabaseCucuk, detailTable: supabaseCucukDetail, thirdTable: supabaseJumlahCucuk),
        selectTable(supabaseGaji, detailTable: supabaseGajiDetail),
        selectTable(supabasePelanggan, detailTable: supabasePelangganDetail),
        selectTable(supabaseCawangan, detailTable: supabaseCawanganDetail, thirdTable: supabaseCawanganBayaran),
        selectTable(supabasePembekal, detailTable: supabasePembekalDetail, thirdTable: supabasePembekalBayaran),
        selectTable(supabaseRunner),
        selectTable(supabaseBarang)
      ]);
      await processTableData(supabasePekerja, resultsUser[0]);
      await processTableData(supabaseStok, resultsUser[1]);
      await processTableData(supabaseHarian, resultsUser[2]);
      await processTableData(supabaseCucuk, resultsUser[3]);
      await processTableData(supabaseGaji, resultsUser[4]);
      await processTableData(supabasePelanggan, resultsUser[5]);
      await processTableData(supabaseCawangan, resultsUser[6]);
      await processTableData(supabasePembekal, resultsUser[7]);
      await processTableData(supabaseRunner, resultsUser[8]);
      await processTableData(supabaseBarang, resultsUser[9]);
    }
    return true;
  } catch (e, st) {
    print(e);
    print(st);
    return false;
  }
}

Future<void> processTableData(
    String tableName,
    List<Map<String, dynamic>> data,
    ) async {

  print("📦 Processing table: $tableName");
  print("📊 Record count: ${data.length}");
  final List<Map<String, dynamic>> records = data.map((e) => Map<String, dynamic>.from(e)).toList();

  switch (tableName) {
    case supabaseKategoriMenu:
      rekod_Kategori = records
          .map((e) => rekodKategoriMenu.fromMap(e))
          .toList();
      rekod_Kategori.sort(
            (a, b) => a.jenis.compareTo(b.jenis),
      );
      break;
    case supabaseMenu:
      rekod_Menu = records
          .map((e) => rekodMenu.fromMap(e))
          .toList();
      rekod_Menu.sort(
            (a, b) => a.jenis.compareTo(b.jenis),
      );
      break;
    case supabaseRole:
      rekod_Role = records
          .map((e) => rekodRole.fromMap(e))
          .toList();

      rekod_Role.sort(
            (a, b) => a.role.compareTo(b.role),
      );
      break;
    case supabasePekerja:
      rekod_Pekerja = records
          .map((item) => rekodPekerja.fromMap(item))
          .toList();
      rekod_Pekerja.sort((a, b) => a.username.compareTo(b.username));
      break;
    case supabaseStok:
      rekod_stok = records.map((item) => rekodStok.fromMap(item)).toList();
      rekod_stok.sort((a, b) => a.epochTime.compareTo(b.epochTime));
      break;
    case supabaseHarian:
      rekod_List = records.map((e) => rekodList.fromMap(e)).toList();
      rekod_List.sort((a, b) => a.epochTime.compareTo(b.epochTime));
      break;
    case supabaseCucuk:
      rekod_Cucuk = records.map((item) => rekodCucuk.fromMap(item)).toList();
      rekod_Cucuk.sort((a, b) => a.epochTime.compareTo(b.epochTime));
      break;
    case supabaseGaji:
      rekod_Gaji = records.map((item) => rekodGaji.fromMap(item)).toList();
      rekod_Gaji.sort((a, b) => a.epochTime.compareTo(b.epochTime));
      break;
    case supabasePelanggan:
      rekod_Pelanggan = records
          .map((item) => rekodPelanggan.fromMap(item))
          .toList();
      rekod_Pelanggan.sort((a, b) => a.epochTime.compareTo(b.epochTime));
      break;
    case supabaseCawangan:
      rekod_Cawangan = records
          .map((item) => rekodCawangan.fromMap(item))
          .toList();
      rekod_Cawangan.sort((a, b) => a.nama.compareTo(b.nama));
      break;
    case supabasePembekal:
      rekod_Pembekal = records
          .map((item) => rekodPembekalList.fromMap(item))
          .toList();
      rekod_Pembekal.sort((a, b) => a.username.compareTo(b.username));
      break;
    case supabaseRunner:
      rekod_Runner = records.map((e) => rekodRunner.fromMap(e)).toList();
      rekod_Runner.sort((a, b) => a.username.compareTo(b.username));
      break;
    case supabaseBarang:
      senarai_Barang = records.map((e) => rekodBarang.fromMap(e)).toList();
      senarai_Barang.sort((a, b) => a.nama.compareTo(b.nama));
      break;
  }
  // Save selepas table berjaya diproses
  await saveDataLocal();

  print("💾 Saved local: $tableName");
}

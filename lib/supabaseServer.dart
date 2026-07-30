import 'package:flutter/foundation.dart';
import 'package:notification_center/notification_center.dart';
import 'package:string_capitalize/string_capitalize.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'DocumentHelper.dart';
import 'databaseLocal.dart';

final supabase = Supabase.instance.client;
final urlPrivacy = "https://ifgsuxodlpdesffnjigw.supabase.co/storage/v1/object/public/privacy%20policy/Privacy_Policy_ENG_BM.pdf";

Future<List<Map<String, dynamic>>> selectTable(
  String nameTable,
  String detailTable, {
  String thirdTable = '',
}) async {
  if (roleID <= 0 &&
      nameTable != 'Role Rekod' &&
      nameTable != 'Pekerja Rekod' &&
      nameTable != 'Menu Rekod' &&
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

    loadDataServer();
    return result;
  } else {
    final result = await supabase
        .from(nameTable)
        .update(currentRecord)
        .eq('id', id)
        .select()
        .single();

    loadDataServer();
    return result;
  }
}

Future<void> deleteRow(String nameTable, int id) async {
  if (!delete) {
    return;
  }
  print("record delete >> $nameTable | $id");
  await supabase.from(nameTable).delete().eq('id', id);
  loadDataServer();
}

Future<void> deleteAllRecord(String nameTable) async {
  if (!delete) {
    return;
  }
  await supabase.from(nameTable).delete().gte('id', 0);
  final name = nameTable.replaceAll(' ', '_').toLowerCase();

  await supabase.rpc('truncate_$name');
  print(name);
  loadDataServer();
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
    loadDataServer();
  } catch (e) {
    print("Delete gagal: $e");
  }
}

Future<void> loadDataServer() async {
  try {
    final results = await Future.wait([
      selectTable('Kategori Menu Rekod', ""),
      selectTable('Menu Rekod', ""),
      selectTable('Role Rekod', "")
    ]);

    final kategoriList = results[0];
    rekod_Kategori = kategoriList.map((e) => rekodKategoriMenu.fromMap(e)).toList();
    rekod_Kategori.sort((a, b) => a.jenis.compareTo(b.jenis));

    final menuList = results[1];
    rekod_Menu = menuList.map((e) => rekodMenu.fromMap(e)).toList();
    rekod_Menu.sort((a, b) => a.jenis.compareTo(b.jenis));

    final roleList = results[2];
    rekod_Role = roleList
        .map((item) => rekodRole.fromMap(item))
        .toList();
    rekod_Role.sort((a, b) => a.role.compareTo(b.role));
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

    if (role.isEmpty && !kIsWeb) {
      return;
    }

    final resultsUser = await Future.wait([
      selectTable('Pekerja Rekod', "Ambil Gaji Rekod"),
      selectTable('Stok Rekod', "Stok Detail Rekod"),
      selectTable('Harian Rekod', "Harian Detail Rekod"),
      selectTable('Cucuk Rekod', "Cucuk Detail Rekod", thirdTable: 'Jumlah Cucuk Satay Rekod'),
      selectTable('Gaji Rekod', "Gaji Detail Rekod"),
      selectTable('Pelanggan Rekod', "Pelanggan Detail Rekod"),
      selectTable('Cawangan Rekod',"Cawangan Detail Rekod",thirdTable: 'Cawangan Bayaran Rekod'),
      selectTable('Pembekal Rekod', "Pembekal Detail Rekod", thirdTable: 'Pembekal Bayaran Rekod'),
      selectTable('Runner Rekod', ""),
      selectTable('Senarai Barang Rekod', "")
    ]);

    final pekerjaList = resultsUser[0];
    rekod_Pekerja = pekerjaList
        .map((item) => rekodPekerja.fromMap(item))
        .toList();
    rekod_Pekerja.sort((a, b) => a.username.compareTo(b.username));


    final recordData = resultsUser[1];
    rekod_stok = recordData.map((item) => rekodStok.fromMap(item)).toList();
    rekod_stok.sort((a, b) => a.epochTime.compareTo(b.epochTime));

    final dataAll = resultsUser[2];
    rekod_List = dataAll.map((e) => rekodList.fromMap(e)).toList();
    rekod_List.sort((a, b) => a.epochTime.compareTo(b.epochTime));

    final cucukData = resultsUser[3];
    rekod_Cucuk = cucukData.map((item) => rekodCucuk.fromMap(item)).toList();
    rekod_Cucuk.sort((a, b) => a.epochTime.compareTo(b.epochTime));

    final gajiRekod = resultsUser[4];
    rekod_Gaji = gajiRekod.map((item) => rekodGaji.fromMap(item)).toList();
    rekod_Gaji.sort((a, b) => a.epochTime.compareTo(b.epochTime));

    final pelangganRekod = resultsUser[5];
    rekod_Pelanggan = pelangganRekod
        .map((item) => rekodPelanggan.fromMap(item))
        .toList();
    rekod_Pelanggan.sort((a, b) => a.epochTime.compareTo(b.epochTime));

    final cawanganData = resultsUser[6];
    rekod_Cawangan = cawanganData
        .map((item) => rekodCawangan.fromMap(item))
        .toList();
    rekod_Cawangan.sort((a, b) => a.nama.compareTo(b.nama));

    final pembekalRekod = resultsUser[7];
    rekod_Pembekal = pembekalRekod
        .map((item) => rekodPembekalList.fromMap(item))
        .toList();
    rekod_Pembekal.sort((a, b) => a.username.compareTo(b.username));

    final runnerList = resultsUser[8];
    rekod_Runner = runnerList.map((e) => rekodRunner.fromMap(e)).toList();
    rekod_Runner.sort((a, b) => a.username.compareTo(b.username));

    final barangList = resultsUser[9];
    senarai_Barang = barangList.map((e) => rekodBarang.fromMap(e)).toList();
    senarai_Barang.sort((a, b) => a.nama.compareTo(b.nama));

  } catch (e, st) {
    print(e);
    print(st);
  }finally {
    print("finished load data from server");
    saveDataLocal();
  }

}

import 'package:flutter/foundation.dart';
import 'package:string_capitalize/string_capitalize.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'DocumentHelper.dart';
import 'databaseLocal.dart';

final supabase = Supabase.instance.client;

Future<List<Map<String, dynamic>>> selectTable(
  String nameTable,
  String detailTable, {
  String thirdTable = '',
}) async {
  if (role == '' &&
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
  print("select table $nameTable >> ${List<Map<String, dynamic>>.from(data)}");
  return List<Map<String, dynamic>>.from(data);
}

Future<Map<String, dynamic>> insertUpdateTable(
  String nameTable,
  Map<String, dynamic> currentRecord, {
  int? id,
}) async {
  print("insert record >> $nameTable | $id | $currentRecord");
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
  print("record delete >> $nameTable | $id");
  await supabase.from(nameTable).delete().eq('id', id);
  loadDataServer();
}

Future<void> deleteAllRecord(String nameTable) async {
  if (role.toString().capitalize() != "Admin") {
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
  if (role.toString().capitalize() != "Admin") {
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
    final pekerjaList = await selectTable('Pekerja Rekod', "Ambil Gaji Rekod");
    rekod_Pekerja = pekerjaList
        .map((item) => rekodPekerja.fromMap(item))
        .toList();
    rekod_Pekerja.sort((a, b) => a.username.compareTo(b.username));

    final kategoriList = await selectTable('Kategori Menu Rekod', "");
    rekod_Kategori = kategoriList.map((e) => rekodKategoriMenu.fromMap(e)).toList();
    rekod_Kategori.sort((a, b) => a.jenis.compareTo(b.jenis));

    final menuList = await selectTable('Menu Rekod', "");
    rekod_Menu = menuList.map((e) => rekodMenu.fromMap(e)).toList();
    rekod_Menu.sort((a, b) => a.jenis.compareTo(b.jenis));

    final runnerList = await selectTable('Runner Rekod', "");
    rekod_Runner = runnerList.map((e) => rekodRunner.fromMap(e)).toList();
    rekod_Runner.sort((a, b) => a.username.compareTo(b.username));

    final barangList = await selectTable('Senarai Barang Rekod', "");
    senarai_Barang = barangList.map((e) => rekodBarang.fromMap(e)).toList();
    senarai_Barang.sort((a, b) => a.nama.compareTo(b.nama));

    if (role.toString().isEmpty && !kIsWeb) {
      return;
    }

    final recordData = await selectTable('Stok Rekod', "Stok Detail Rekod");
    rekod_stok = recordData.map((item) => rekodStok.fromMap(item)).toList();
    rekod_stok.sort((a, b) => a.epochTime.compareTo(b.epochTime));

    final dataAll = await selectTable('Harian Rekod', "Harian Detail Rekod");
    rekod_List = dataAll.map((e) => rekodList.fromMap(e)).toList();
    rekod_List.sort((a, b) => a.epochTime.compareTo(b.epochTime));

    final cucukData = await selectTable(
      'Cucuk Rekod',
      "Cucuk Detail Rekod",
      thirdTable: 'Jumlah Cucuk Satay Rekod',
    );
    rekod_Cucuk = cucukData.map((item) => rekodCucuk.fromMap(item)).toList();
    rekod_Cucuk.sort((a, b) => a.epochTime.compareTo(b.epochTime));

    final cawanganData = await selectTable(
      'Cawangan Rekod',
      "Cawangan Detail Rekod",
      thirdTable: 'Cawangan Bayaran Rekod',
    );
    rekod_Cawangan = cawanganData
        .map((item) => rekodCawangan.fromMap(item))
        .toList();
    rekod_Cawangan.sort((a, b) => a.nama.compareTo(b.nama));

    final gajiRekod = await selectTable('Gaji Rekod', "Gaji Detail Rekod");
    rekod_Gaji = gajiRekod.map((item) => rekodGaji.fromMap(item)).toList();
    rekod_Gaji.sort((a, b) => a.epochTime.compareTo(b.epochTime));

    final pelangganRekod = await selectTable(
      'Pelanggan Rekod',
      "Pelanggan Detail Rekod",
    );
    rekod_Pelanggan = pelangganRekod
        .map((item) => rekodPelanggan.fromMap(item))
        .toList();
    rekod_Pelanggan.sort((a, b) => a.epochTime.compareTo(b.epochTime));

    final pembekalRekod = await selectTable(
      'Pembekal Rekod',
      "Pembekal Detail Rekod",
      thirdTable: 'Pembekal Bayaran Rekod',
    );
    rekod_Pembekal = pembekalRekod
        .map((item) => rekodPembekalList.fromMap(item))
        .toList();
    rekod_Pembekal.sort((a, b) => a.username.compareTo(b.username));

    saveDataLocal();
  } catch (e, st) {
    print(e);
    print(st);
  }
}

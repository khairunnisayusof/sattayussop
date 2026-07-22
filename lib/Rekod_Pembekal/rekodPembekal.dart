import 'package:flutter/material.dart';
import 'package:sattayussop/Rekod_Pembekal/rekodPembekalList.dart';
import 'package:string_capitalize/string_capitalize.dart';
import 'package:sattayussop/DocumentHelper.dart';
import 'package:notification_center/notification_center.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class RekodBarang extends StatefulWidget {
  const RekodBarang({super.key});

  @override
  State<RekodBarang> createState() => _RekodBarangState();
}

class _RekodBarangState extends State<RekodBarang> {
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  int selectIndex = 0;
  String nama = "";
  bool newRekod = false;
  String tarikh = "";
  List<rekodBarangPembekal> barangList = <rekodBarangPembekal>[];
  TextStyle textStyle = TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);
  bool dark = sharedPreferences?.getBool("darkModeStatus") ?? false;
  Color color = Colors.orange;

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
    }
    NotificationCenter().subscribe('refreshData', _refreshView);
    loadData();
    super.initState();
  }

  @override
  void dispose() {
    if (!mounted) return;
    // Clean up the controller when the widget is disposed.
    loadDataServer();
    super.dispose();
  }

  void _refreshView(bool refresh) {
    if (!refresh) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Rekod Barang Kosong"),
            content: Text("Sila Masukkan Rekod Barang dahulu!"),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        rekod_Pembekal.sort((a, b) => a.namaPembekal.compareTo(b.namaPembekal));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.only(top: 5),
      child: ListView.builder(
        itemCount: rekod_Pembekal.length,
        itemBuilder: (BuildContext context, int index) {
          rekodPembekalList current = rekod_Pembekal.elementAt(index);
          var nama = current.namaPembekal;
          return GestureDetector(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 5),
                  alignment: Alignment.centerLeft,
                  height: 50,
                  color: Colors.transparent,
                  child: Text(
                    nama,
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Divider(thickness: 1, height: 10, color: Colors.grey),
              ],
            ),
            onLongPress: () {
              showDialogRequired(
                context,
                "Pengesahan Memadam",
                "Adakah anda ingin memadam data ini",
                index,
              );
            },
            onTap: () {
              int id = rekod_Pembekal.elementAt(index).id;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => selectRekodBarangList(selectIndex: id),
                ),
              );
            },
          );
        },
      ),
    );

    final settingButton = Padding(
      padding: EdgeInsets.only(right: 5.0),
      child: PopupMenuButton(
        icon: more_rev_Icon,
        onSelected: (item) {
          // your logic
          if (item == '1') {
            removeAllServer();
          }
        },
        itemBuilder: (BuildContext bc) {
          return const [
            PopupMenuItem(value: '1', child: Text("Padam Seluruh Data")),
          ];
        },
      ),
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        foregroundColor: Colors.transparent,
        title: Text("Rekod Pembekal", style: TextStyle(color: Colors.white)),
        actions: <Widget>[],
        centerTitle: true,
      ),
      body: buildCollectionView,
      floatingActionButton: (role.toString().capitalize() == "Admin")
          ? FloatingActionButton(
              backgroundColor: color,
              foregroundColor: Colors.white,
              onPressed: () {
                showDialogTextRequired(
                  context,
                  "Masukkan Nama Pembekal",
                  "nama Pembekal anda.",
                );
              },
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void showDialogRequired(
    BuildContext context,
    String title,
    String message,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ya'),
              onPressed: () {
                Navigator.of(context).pop();
                removeItemInServer(index);
              },
            ),
          ],
        );
      },
    );
  }

  void showDialogTextRequired(
    BuildContext context,
    String title,
    String message,
  ) {
    final myController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            autofocus: true,
            controller: myController,
            decoration: InputDecoration(hintText: message),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Simpan'),
              onPressed: () {
                Navigator.of(context).pop();
                // Handle the submit action
                print("nama >> ${myController.text}");
                nama = myController.text.capitalizeEach();
                List<dynamic> rekod = <rekodPembekalList>[];
                if (!rekod_Pembekal
                    .map((item) => item.namaPembekal)
                    .contains(nama)) {
                  insertServer(rekodPembekalList(nama, rekod, []));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> insertServer(rekodPembekalList usr) async {
    final result = await insertUpdateTable('Pembekal Rekod', usr.toMapServer());
    var current = rekodPembekalList.fromMap(result);
    usr.id = current.id;
    addItem(usr);
  }

  // addItem adds our User Class item to list.
  void addItem(rekodPembekalList usr) {
    selectIndex = rekod_Pembekal.length;
    newRekod = true;
    rekod_Pembekal.add(usr);
    saveData();
  }

  void removeItemInServer(int index) {
    var id = rekod_Pembekal[index].id;
    deleteRow('Pembekal Rekod', id);
    removeItem(index);
  }

  void removeItem(int index) {
    // rekodPembekalList current = rekod_Pembekal.elementAt(index);
    // var list = current.rekod.map((item) =>
    //     rekodPembekalDetail.fromMap(json.decode(item))).toList();
    // rekodPembekalDetail currentRekod = list.elementAt(0);
    // tarikh = currentRekod.tarikh;
    rekod_Pembekal.removeAt(index);
    saveData();
  }

  void removeAllServer() {
    deleteAllRecord("Pembekal Rekod");
    removeAll();
  }

  void removeAll() {
    rekod_Pembekal.clear();
    saveData();
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
    loadData();
  }
}

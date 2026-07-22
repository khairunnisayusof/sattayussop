import 'package:flutter/material.dart';
import 'package:string_capitalize/string_capitalize.dart';
import '../DocumentHelper.dart';
import '../Rekod_Cawangan/rekodCawanganList.dart';
import '../Rekod_Cawangan/rekodHargaCawangan.dart';
import 'package:notification_center/notification_center.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class RekodCawangan extends StatefulWidget {
  const RekodCawangan({super.key});

  @override
  State<RekodCawangan> createState() => _RekodRekodCawanganState();
}

class _RekodRekodCawanganState extends State<RekodCawangan> {
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  int selectIndex = 0;
  String nama = "";
  String id = "";
  bool newRekod = false;
  String tarikh = "";
  List<rekodMenu> menuList = <rekodMenu>[];
  final List<rekodCawanganDetail> _rekodCawanganDetail =
      <rekodCawanganDetail>[];
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
    menuList = rekod_Menu
        .where((e) => e.jenis.toLowerCase().contains("satay"))
        .toList();

    menuList.sort((a, b) => a.jenis.compareTo(b.jenis));
    super.initState();
  }

  @override
  void dispose() {
    loadDataServer();
    super.dispose();
  }

  void _refreshView(bool refresh) {
    if (!refresh) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Rekod Menu Kosong"),
            content: Text("Sila Masukkan Rekod Menu dahulu!"),
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
        rekod_Cawangan.sort((a, b) => a.id.compareTo(b.id));
        if (newRekod) {
          newRekod = false;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => selectRekodHargaCawangan(
                selectedCawangan: rekod_Cawangan.indexWhere(
                  (element) => element.nama == nama,
                ),
                menuList: menuList,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.only(top: 5),
      child: ListView.builder(
        itemCount: rekod_Cawangan.length,
        itemBuilder: (BuildContext context, int index) {
          rekodCawangan current = rekod_Cawangan.elementAt(index);
          var nama = current.nama;
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => selectRekodCawanganList(
                    selectIndex: index,
                    menuList: menuList,
                  ),
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
            removeAll();
          }
        },
        itemBuilder: (BuildContext bc) {
          var menu = [
            PopupMenuItem(value: '1', child: Text("Padam Seluruh Data")),
          ];
          return (role.toString().capitalize() == "Admin") ? menu : [];
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
        title: Text("Rekod Cawangan", style: TextStyle(color: Colors.white)),
        actions: <Widget>[settingButton],
        centerTitle: true,
      ),
      body: buildCollectionView,
      floatingActionButton:
          (role.toString().capitalize() == "Admin" ||
              role.toString().capitalize() == "Manager")
          ? FloatingActionButton(
              backgroundColor: color,
              foregroundColor: Colors.white,
              onPressed: () {
                showDialogTextRequired(
                  context,
                  "Masukkan Nama Cawangan",
                  "nama cawangan anda.",
                );
              },
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            )
          : SizedBox(height: 0),
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
                List<dynamic> rekod = <rekodCawangan>[];
                if (!rekod_Cawangan.map((item) => item.nama).contains(nama)) {
                  insertServer(rekodCawangan(nama, rekod, {}, []));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> insertServer(rekodCawangan usr) async {
    final result = await insertUpdateTable('Cawangan Rekod', usr.toMapServer());
    var current = rekodStok.fromMap(result);
    usr.id = current.id;
    addItem(usr);
  }

  // addItem adds our User Class item to list.
  void addItem(rekodCawangan usr) {
    selectIndex = rekod_Cawangan.length;
    newRekod = true;
    rekod_Cawangan.add(usr);
    saveData();
  }

  void removeItemInServer(int index) {
    var id = rekod_Cawangan[index].id;
    deleteRow('Cawangan Rekod', id);
    removeItem(index);
  }

  void removeItem(int index) {
    rekod_Cawangan.removeAt(index);
    saveData();
  }

  void removeAll() {
    rekod_Cawangan.clear();
    tarikh = "";
    removeAllServer();
  }

  void removeAllServer() {
    deleteAllRecord("Cawangan Rekod");
    saveData();
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
  }
}

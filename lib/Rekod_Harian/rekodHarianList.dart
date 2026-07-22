import 'package:flutter/material.dart';
import 'package:string_capitalize/string_capitalize.dart';
import 'package:sattayussop/DocumentHelper.dart';
import 'package:sattayussop/Rekod_Harian/rekodHarianDetail.dart';
import 'package:notification_center/notification_center.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class RekodHarianDetail extends StatefulWidget {
  const RekodHarianDetail({super.key, required this.selectIndex});

  final int selectIndex;

  @override
  State<RekodHarianDetail> createState() => _RekodHarianDetailState();
}

class _RekodHarianDetailState extends State<RekodHarianDetail> {
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  int selectIndex = 0;
  String namaPasarMalam = "";
  int id = 0;
  String tarikh = "";
  List<rekodHarianDetail> _rekodHarianDetail = <rekodHarianDetail>[];
  TextStyle textStyle = TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);
  bool dark = sharedPreferences?.getBool("darkModeStatus") ?? false;
  Color color = Colors.orange;
  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
    }
    selectIndex = widget.selectIndex;
    NotificationCenter().subscribe('refreshData', _refreshView);
    rekodList current = rekod_List.elementAt(selectIndex);
    tarikh = current.tarikh;
    id = current.id;
    _refreshView(true);
    loadData();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    if (!mounted) return;
    rekodList current = rekod_List.elementAt(
      rekod_List.indexWhere((e) => e.id == id),
    );
    _rekodHarianDetail = List<rekodHarianDetail>.from(current.rekod).toList();
    _rekodHarianDetail.sort((a, b) => a.id.compareTo(b.id));
    super.dispose();
  }

  void _refreshView(bool refresh) {
    if (!mounted) return;
    setState(() {
      print("refresh data in rekodHarianList");
      rekodList current = rekod_List.elementAt(selectIndex);
      _rekodHarianDetail = List<rekodHarianDetail>.from(current.rekod).toList();
      _rekodHarianDetail.sort((a, b) => a.id.compareTo(b.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.only(top: 5),
      child: ListView.builder(
        itemCount: _rekodHarianDetail.length,
        itemBuilder: (BuildContext context, int index) {
          rekodHarianDetail current = _rekodHarianDetail.elementAt(index);
          var nama = current.namaPasarMalam;
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
                  builder: (context) => selectRekodHarianDetail(
                    selectIndex: index,
                    selectedHarian: selectIndex,
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
          if (item == '1') {}
        },
        itemBuilder: (BuildContext bc) {
          return const [
            // PopupMenuItem(
            //   child: Text("Jualan Baru"),
            //   value: '1',
            // ),
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
        title: Text("Detail Harian", style: TextStyle(color: Colors.white)),
        actions: <Widget>[],
        centerTitle: true,
      ),
      body: buildCollectionView,
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialogTextRequired(
            context,
            "Masukkan Nama Pasar Malam",
            "nama pasar malam anda.",
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
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
                removeItem(index);
                Navigator.of(context).pop();
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
                namaPasarMalam = myController.text.capitalizeEach();
                Map<String, dynamic> mapMenu = {};
                var startStore = false;
                if (rekod_Menu.isEmpty) {
                  startStore = true;
                } else {
                  for (var i = 0; i < rekod_Menu.length; i++) {
                    var current = rekod_Menu.elementAt(i);
                    String menu = current.jenis;
                    if (menu.toLowerCase().contains('satay')) {
                      mapMenu[menu] = {
                        "bawa": 0,
                        'baki': 0,
                        'masak': 0,
                        'rosak': 0,
                        'jualan': 0,
                      };
                    } else if (menu.toLowerCase().contains("nasi")) {
                      mapMenu[menu] = {
                        "bawa": 0,
                        'baki': 0,
                        'rosak': 0,
                        'jualan': 0,
                      };
                    }
                    if (i >= rekod_Menu.length - 1) {
                      startStore = true;
                    }
                  }
                }
                if (startStore &&
                    !_rekodHarianDetail
                        .map((item) => item.namaPasarMalam)
                        .contains(namaPasarMalam)) {
                  mapMenu = sortMenu(mapMenu);
                  print("list >>>> $mapMenu");
                  insertItem(
                    rekodHarianDetail(
                      id,
                      namaPasarMalam,
                      mapMenu,
                      0,
                      0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                      0.0,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> insertItem(rekodHarianDetail detail) async {
    await insertUpdateTable('Harian Detail Rekod', detail.toMapServer());
    addItem(detail);
  }

  // addItem adds our User Class item to list.
  void addItem(rekodHarianDetail detail) {
    print("add item >>> $detail");
    _rekodHarianDetail.add(detail);
    var target = rekod_List.elementAt(selectIndex);
    setState(() {
      target.rekod = _rekodHarianDetail;
    });
    saveData();
  }

  void removeItem(int index) {
    var id = _rekodHarianDetail[index].id;
    deleteRow('Harian Detail Rekod', id);
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
    updateStok(tarikh);
  }
}

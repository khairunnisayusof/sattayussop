import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sattayussop/Rekod_Cawangan/rekodCawanganDetail.dart';
import 'package:sattayussop/DocumentHelper.dart';
import 'package:sattayussop/Rekod_Cawangan/rekodHargaCawangan.dart';
import 'package:notification_center/notification_center.dart';
import 'package:string_capitalize/string_capitalize.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';
import 'rekodBayaranCawangan.dart';

class selectRekodCawanganList extends StatefulWidget {
  const selectRekodCawanganList({
    super.key,
    required this.selectIndex,
    required this.menuList,
  });

  final int selectIndex;
  final List<rekodMenu> menuList;

  @override
  State<selectRekodCawanganList> createState() =>
      _selectRekodCawanganListState();
}

class _selectRekodCawanganListState extends State<selectRekodCawanganList> {
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  final myController = TextEditingController();
  String namaRekod = "";
  String tarikhRekod = "";
  String hariRekod = "";
  int selectedIndex = 0;
  int cawangan_id = 0;
  DateTime selectedDate = DateTime.now();
  final TimeOfDay _fromTime = TimeOfDay.now();
  List<rekodCawanganDetail> _rekodCawanganDetail = <rekodCawanganDetail>[];
  List<rekodMenu> menuList = <rekodMenu>[];
  TextStyle titleTextStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );
  TextStyle textStyle = TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
  TextStyle textStyleBtn = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  TextStyle textStyleBtnNormal = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );
  TextStyle textStyleNormal = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
  );
  bool dark = sharedPreferences?.getBool("darkModeStatus") ?? false;
  Color color = Colors.orange;
  final Map<String, dynamic> _rekodMenu = <String, dynamic>{};

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
    }
    loadData();
    selectedIndex = widget.selectIndex;
    menuList = widget.menuList;
    rekodCawangan current = rekod_Cawangan.elementAt(selectedIndex);
    namaRekod = current.nama;
    cawangan_id = current.id;
    NotificationCenter().subscribe('refreshData', _refreshView);
    _refreshView(true);
    super.initState();
  }

  void _refreshView(bool refresh) {
    setState(() {
      print("cawangan >> $cawangan_id");
      rekodCawangan current = rekod_Cawangan.elementAt(
        rekod_Cawangan.indexWhere((e) => e.id == cawangan_id),
      );
      _rekodCawanganDetail = List<rekodCawanganDetail>.from(
        current.rekod,
      ).toList();
      _rekodCawanganDetail.sort((a, b) => a.epochTime.compareTo(b.epochTime));
    });
  }

  @override
  void dispose() {
    if (!mounted) return;
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyleCard = TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    TextStyle textStyleCardNormal = TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      color: Colors.white,
    );
    _refreshView(true);
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.only(top: 5),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _rekodCawanganDetail.length,
        itemBuilder: (BuildContext context, int index) {
          rekodCawanganDetail current = _rekodCawanganDetail.elementAt(index);
          bool fullPayment = current.bayaranPenuh;
          return GestureDetector(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ListTile(
                  leading: Text(
                    '${current.hari}, ${current.tarikh}',
                    style: textStyle,
                    textAlign: TextAlign.left,
                  ),
                  trailing: fullPayment
                      ? Icon(Icons.check_circle_rounded, color: Colors.green)
                      : SizedBox(height: 0),
                ),
                Divider(thickness: 1, height: 10, color: Colors.grey),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => selectRekodCawanganDetail(
                    selectIndex: selectedIndex,
                    selectedDetail: index,
                  ),
                ),
              );
            },
            onLongPress: () {
              showDialogRequired(
                context,
                "Pengesahan Memadam",
                "Adakah anda ingin memadam data ini",
                index,
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => selectRekodHargaCawangan(
                  selectedCawangan: selectedIndex,
                  menuList: menuList,
                ),
              ),
            );
          } else if (item == '2') {
            rekodCawangan current = rekod_Cawangan.elementAt(selectedIndex);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RekodBayaranCawangan(
                  selectIndex: selectedIndex,
                  nama: current.nama,
                ),
              ),
            );
          } else if (item == '3') {
            removeAllServer();
          }
        },
        itemBuilder: (BuildContext bc) {
          var menu = [
            PopupMenuItem(value: '1', child: Text("Tetapan Harga")),
            PopupMenuItem(value: '2', child: Text("Rekod Bayaran")),
            PopupMenuItem(value: '3', child: Text("Padam Seluruh Data")),
          ];
          return (role.toString().capitalize() == "Admin" ||
                  role.toString().capitalize() == "Manager")
              ? menu
              : [];
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
        title: Text(namaRekod, style: TextStyle(color: Colors.white)),
        actions: <Widget>[settingButton],
        centerTitle: true,
      ),
      body: buildCollectionView,
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        foregroundColor: Colors.white,
        onPressed: () {
          _selectDate(context) as String;
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
                Navigator.of(context).pop();
                removeItemInServer(index);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      initialEntryMode: DatePickerEntryMode.calendar,
      firstDate: DateTime(selectedDate.year - 5),
      lastDate: DateTime(selectedDate.year + 1),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        hariRekod = DateFormat('EEE').format(selectedDate);
        if (hariRekod.contains("Sun")) {
          hariRekod = "Ahad";
        } else if (hariRekod.contains("Mon")) {
          hariRekod = "Isnin";
        } else if (hariRekod.contains("Tue")) {
          hariRekod = "Selasa";
        } else if (hariRekod.contains("Wed")) {
          hariRekod = "Rabu";
        } else if (hariRekod.contains("Thu")) {
          hariRekod = "Khamis";
        } else if (hariRekod.contains("Fri")) {
          hariRekod = "Jumaat";
        } else if (hariRekod.contains("Sat")) {
          hariRekod = "Sabtu";
        }
        tarikhRekod = DateFormat('dd/MM/yyyy').format(selectedDate);
        DateTime tempDate1 = DateFormat(
          "dd/MM/yyyy",
        ).parse(tarikhRekod.toString());
        var epochTime = tempDate1.millisecondsSinceEpoch.toString();

        List<dynamic> bayaranList = [];
        Map<String, dynamic> listHarga = rekod_Cawangan
            .elementAt(selectedIndex)
            .rekodHarga;
        Map<String, dynamic> mapMenu = sortMenu(listHarga);
        for (var index = 0; index < listHarga.length; index++) {
          String nama = listHarga.keys.elementAt(index);
          mapMenu[nama] = {"bawa": 0, 'baki': 0, 'rosak': 0};
        }
        if (!_rekodCawanganDetail
            .map((item) => item.tarikh)
            .contains(tarikhRekod)) {
          insertServer(
            rekodCawanganDetail(
              cawangan_id,
              epochTime,
              tarikhRekod,
              hariRekod,
              mapMenu,
              0,
              0.0,
              0.0,
              0.0,
              false,
              0.0,
            ),
          );
        }
      });
    }
  }

  Future<void> insertServer(rekodCawanganDetail usr) async {
    final result = await insertUpdateTable(
      'Cawangan Detail Rekod',
      usr.toMapServer(),
    );
    var current = rekodCawanganDetail.fromMap(result);
    usr.id = current.id;
    print("id <<< $usr");
    addItem(usr);
  }

  // addItem adds our User Class item to list.
  void addItem(rekodCawanganDetail detail) {
    print("add item >>> $detail");
    _rekodCawanganDetail.add(detail);
    var target = rekod_Cawangan[selectedIndex];
    setState(() {
      target.rekod = _rekodCawanganDetail;
    });
    saveData();
  }

  void removeItemInServer(int index) {
    var id = _rekodCawanganDetail[index].id;
    deleteRow('Cawangan Detail Rekod', id);
    removeItem(index);
  }

  void removeItem(int index) {
    tarikhRekod = _rekodCawanganDetail.elementAt(index).tarikh;
    _rekodCawanganDetail.removeAt(index);
    var target = rekod_Cawangan[selectedIndex];
    setState(() {
      target.rekod = _rekodCawanganDetail;
    });
    saveData();
  }

  void removeAllServer() {
    deleteAllRecordFromForeign(
      "Cawangan Detail Rekod",
      "cawangan id",
      cawangan_id,
    );
    removeAll();
  }

  void removeAll() {
    _rekodCawanganDetail.clear();
    var target = rekod_Cawangan[selectedIndex];
    setState(() {
      target.rekod = _rekodCawanganDetail;
    });
    saveData();
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
    updateStok(tarikhRekod);
  }
}

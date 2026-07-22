import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sattayussop/DocumentHelper.dart';
import 'package:sattayussop/Rekod_Pembekal/rekodPembekalDetail.dart';
import 'package:notification_center/notification_center.dart';
import 'package:string_capitalize/string_capitalize.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';
import 'rekodBayaran.dart';

class selectRekodBarangList extends StatefulWidget {
  const selectRekodBarangList({super.key, required this.selectIndex});

  final int selectIndex;

  @override
  State<selectRekodBarangList> createState() => _selectRekodBarangListState();
}

class _selectRekodBarangListState extends State<selectRekodBarangList> {
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  final myController = TextEditingController();
  String namaRekod = "";
  String tarikhRekod = "";
  String hariRekod = "";
  int selectedIndex = 0;
  DateTime selectedDate = DateTime.now();
  final TimeOfDay _fromTime = TimeOfDay.now();
  List<rekodPembekalDetail> _rekodBarangDetail = <rekodPembekalDetail>[];
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
    selectedIndex = widget.selectIndex;
    NotificationCenter().subscribe('refreshData', _refreshView);
    rekodPembekalList current = rekod_Pembekal.elementAt(
      rekod_Pembekal.indexWhere((e) => e.id == selectedIndex),
    );
    namaRekod = current.namaPembekal;
    _rekodBarangDetail = List<rekodPembekalDetail>.from(current.rekod).toList();
    _refreshView(true);
    super.initState();
  }

  void _refreshView(bool refresh) {
    setState(() {
      rekodPembekalList current = rekod_Pembekal.elementAt(
        rekod_Pembekal.indexWhere((e) => e.id == selectedIndex),
      );
      _rekodBarangDetail = List<rekodPembekalDetail>.from(
        current.rekod,
      ).toList();
      _rekodBarangDetail.sort((a, b) => a.epochTime.compareTo(b.epochTime));
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
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.only(top: 5),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _rekodBarangDetail.length,
        itemBuilder: (BuildContext context, int index) {
          rekodPembekalDetail current = _rekodBarangDetail.elementAt(index);
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
              rekodPembekalList currentBarang = rekod_Pembekal.elementAt(
                rekod_Pembekal.indexWhere((e) => e.id == selectedIndex),
              );
              var selectDetailBarang = List<rekodPembekalDetail>.from(
                currentBarang.rekod,
              ).toList();
              rekodPembekalDetail current = selectDetailBarang.elementAt(index);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => selectRekodBarangDetail(
                    selectIndex: selectedIndex,
                    selectedDetail: current.id,
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
            rekodPembekalList current = rekod_Pembekal.elementAt(
              rekod_Pembekal.indexWhere((e) => e.id == selectedIndex),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RekodBayaranPembekal(
                  selectIndex: selectedIndex,
                  nama: current.namaPembekal,
                ),
              ),
            );
          } else if (item == '2') {
            removeAllServer();
          }
        },
        itemBuilder: (BuildContext bc) {
          var menu = const [
            PopupMenuItem(value: '1', child: Text("Rekod Bayaran")),
          ];
          if (role.toString().capitalize() == "Admin") {
            menu = const [
              PopupMenuItem(value: '1', child: Text("Rekod Bayaran")),
              PopupMenuItem(value: '2', child: Text("Padam Seluruh Data")),
            ];
          }
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
        title: Text("$namaRekod List", style: TextStyle(color: Colors.white)),
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
                _selectDate(context) as String;
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

        if (!_rekodBarangDetail
            .map((item) => item.tarikh)
            .contains(tarikhRekod)) {
          insertServer(
            rekodPembekalDetail(
              selectedIndex,
              epochTime,
              tarikhRekod,
              hariRekod,
              {},
              0.0,
              0.0,
              0.0,
              false,
            ),
          );
        }
      });
    }
  }

  Future<void> insertServer(rekodPembekalDetail usr) async {
    final result = await insertUpdateTable(
      'Pembekal Detail Rekod',
      usr.toMapServer(),
    );
    usr.id = rekodPembekalDetail.fromMap(result).id;
    addItem(usr);
  }

  // addItem adds our User Class item to list.
  void addItem(rekodPembekalDetail detail) {
    print("add item >>> $detail");
    _rekodBarangDetail.add(detail);
    var target = rekod_Pembekal.elementAt(
      rekod_Pembekal.indexWhere((e) => e.id == selectedIndex),
    );
    setState(() {
      target.rekod = _rekodBarangDetail;
    });
    saveData();
  }

  void removeItemInServer(int index) {
    var id = _rekodBarangDetail[index].id;
    deleteRow('Pembekal Detail Rekod', id);
    removeItem(index);
  }

  void removeItem(int index) {
    tarikhRekod = _rekodBarangDetail.elementAt(index).tarikh;
    _rekodBarangDetail.removeAt(index);
    var target = rekod_Pembekal.elementAt(
      rekod_Pembekal.indexWhere((e) => e.id == selectedIndex),
    );
    setState(() {
      target.rekod = _rekodBarangDetail;
    });
    saveData();
  }

  void removeAllServer() {
    deleteAllRecordFromForeign(
      "Pembekal Detail Rekod",
      "pembekal id",
      selectedIndex,
    );
    removeAll();
  }

  void removeAll() {
    _rekodBarangDetail.clear();
    var target = rekod_Pembekal.elementAt(
      rekod_Pembekal.indexWhere((e) => e.id == selectedIndex),
    );
    setState(() {
      target.rekod = _rekodBarangDetail;
    });
    saveData();
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sattayussop/DocumentHelper.dart';
import 'package:sattayussop/Rekod_Harian/rekodHarianList.dart';
import 'package:notification_center/notification_center.dart';
import 'package:sattayussop/supabaseServer.dart';
import 'package:string_capitalize/string_capitalize.dart';
import '../databaseLocal.dart';

class selectRekodHarian extends StatefulWidget {
  const selectRekodHarian({super.key});

  @override
  State<selectRekodHarian> createState() => _selectRekodHarianState();
}

class _selectRekodHarianState extends State<selectRekodHarian> {
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  final myController = TextEditingController();
  String tarikhRekod = "";
  String hariRekod = "";
  var epochTime = "";
  DateTime selectedDate = DateTime.now();
  final TimeOfDay _fromTime = TimeOfDay.now();
  int _removeIndex = -1;
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
    myController.dispose();
    loadDataServer();
    super.dispose();
  }

  void _refreshView(bool refresh) {
    if (!mounted) return;
    print("refresh data in rekodHarian ${rekod_List.length}");
    setState(() {});
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
    }
  }

  @override
  Widget build(BuildContext context) {
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.only(top: 5),
      child: ListView.builder(
        itemCount: rekod_List.length,
        itemBuilder: (BuildContext context, int index) {
          rekodList current = rekod_List.elementAt(index);
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
                    '${current.hari}, ${current.tarikh}',
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Divider(thickness: 1, height: 10, color: Colors.grey),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RekodHarianDetail(selectIndex: index),
                ),
              );
            },
            onLongPress: () {
              _removeIndex = index;
              showDialogRequired(
                context,
                "Pengesahan Memadam",
                "Adakah anda ingin memadam data ini",
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
          var menu = const [
            PopupMenuItem(value: '1', child: Text("Padam Seluruh Data")),
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
        title: Text("Rekod Harian", style: TextStyle(color: Colors.white)),
        actions: <Widget>[],
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

  void showDialogRequired(BuildContext context, String title, String message) {
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
                if (_removeIndex > -1) {
                  // rekodList current = rekod_List.elementAt(_removeIndex);
                  removeItemInServer(_removeIndex);
                }
                _removeIndex = -1;
              },
            ),
          ],
        );
      },
    );
  }

  void _selectDate(BuildContext context) async {
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
        tarikhRekod = DateFormat('dd/MM/yyyy').format(selectedDate).toString();
        DateTime tempDate1 = DateFormat(
          "dd/MM/yyyy",
        ).parse(tarikhRekod.toString());
        epochTime = tempDate1.millisecondsSinceEpoch.toString();

        insertHarian(rekodList(epochTime, tarikhRekod, hariRekod, []));
      });
    }
  }

  // addItem adds our User Class item to list.
  void addItem(rekodList usr) {
    if (!rekod_List.map((item) => item.epochTime).contains(usr.epochTime)) {
      rekod_List.add(usr);
    }
    saveData();
  }

  Future<void> insertHarian(rekodList usr) async {
    if (!rekod_List.map((item) => item.epochTime).contains(usr.epochTime)) {
      await insertUpdateTable('Harian Rekod', usr.toMapServer());
    }
    addItem(usr);
    insertStok(epochTime, tarikhRekod, hariRekod);
  }

  void removeItem(int index) {
    rekod_List.removeAt(
      rekod_List.indexWhere((element) => element.tarikh == tarikhRekod),
    );
    saveData();
  }

  void removeItemInServer(int index) {
    tarikhRekod = rekod_List[index].tarikh;
    var id = rekod_List[index].id;
    deleteRow('Harian Rekod', id);
    removeItem(index);
  }

  void removeAll() {
    deleteAllRecord("Harian Rekod");
    rekod_List.clear();
    saveData();
  }

  // This block saves our list locally.
  Future<void> saveData() async {
    saveDataLocal();
    // Future.delayed(Duration(seconds: 2), () {
    updateStok(tarikhRekod);
  }
}

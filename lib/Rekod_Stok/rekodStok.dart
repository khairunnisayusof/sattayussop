import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../DocumentHelper.dart';
import '../Rekod_Stok/rekodStokDetail.dart';
import 'package:notification_center/notification_center.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class RekodStok extends StatefulWidget {
  const RekodStok({super.key});

  @override
  State<RekodStok> createState() => _RekodStokState();
}

class _RekodStokState extends State<RekodStok> {
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  int selectIndex = 0;
  String nama = "";
  String tarikhRekod = "";
  String hariRekod = "";
  String masaRekod = "";
  String epochTime = "";
  String epochTimeStok = "";
  DateTime selectedDate = DateTime.now();
  final TimeOfDay _fromTime = TimeOfDay.now();
  bool newRekod = false;
  List<rekodStokDetail> _rekodStokDetail = <rekodStokDetail>[];
  TextStyle textStyle = TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);
  bool dark = sharedPreferences?.getBool("darkModeStatus") ?? false;
  Color color = Colors.orange;
  List<DropdownMenuItem> dropDownListMenu = <DropdownMenuItem>[];

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
    }
    NotificationCenter().subscribe('refreshData', _refreshView);
    loadData();
    rekod_stok.sort((a, b) => a.epochTime.compareTo(b.epochTime));
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
    if (!mounted) return;
    setState(() {
      if (tarikhRekod.isNotEmpty) {
        var record = rekod_stok.elementAt(
          rekod_stok.indexWhere((element) => element.tarikh == tarikhRekod),
        );
        _rekodStokDetail = (record.rekod)
            .map(
              (item) =>
                  rekodStokDetail.fromMap(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.only(top: 5),
      child: ListView.builder(
        itemCount: rekod_stok.length,
        itemBuilder: (BuildContext context, int index) {
          rekodStok current = rekod_stok.elementAt(index);
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
                  builder: (context) =>
                      selectRekodStokDetail(selectIndex: index),
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
            //   Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //           builder: (context) => selectRekodRunner()));
          }
        },
        itemBuilder: (BuildContext bc) {
          return const [
            // PopupMenuItem(
            //   child: Text("Rekod Runner"),
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
        title: Text("Rekod Stok", style: TextStyle(color: Colors.white)),
        actions: <Widget>[],
        centerTitle: true,
      ),
      body: buildCollectionView,
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: color,
      //   foregroundColor: Colors.white,
      //   onPressed: () {
      //     _selectDate(context);
      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
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
                removeItems(index);
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
        DateTime date = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        );
        tarikhRekod = DateFormat('dd/MM/yyyy').format(selectedDate);
        DateTime tempDate1 = DateFormat(
          "dd/MM/yyyy",
        ).parse(tarikhRekod.toString());
        epochTimeStok = tempDate1.millisecondsSinceEpoch.toString();
        print("epoch >> $epochTime");
        _showTimePicker(context);
      });
    }
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _fromTime,
      builder: (context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    print(picked);
    if (picked != null) {
      setState(() {
        // Conversion logic starts here
        DateTime tempDate = DateFormat(
          "hh:mm",
        ).parse("${picked.hour}:${picked.minute}");
        var dateFormat = DateFormat("h:mm a"); // you can change the format here
        print(dateFormat.format(tempDate));
        print("data $dateFormat");
        masaRekod = dateFormat.format(tempDate).toString();
        DateTime tempDate1 = DateFormat(
          "dd/MM/yyyy hh:mm",
        ).parse("$tarikhRekod ${picked.hour}:${picked.minute}");
        epochTime = tempDate1.millisecondsSinceEpoch.toString();
      });
    }
  }

  // addItem adds our User Class item to list.
  void addItem(rekodStokDetail usr) {
    _rekodStokDetail.add(usr);
    List<String> rekodList = _rekodStokDetail
        .map((item) => jsonEncode(item.toMap()))
        .toList();
    if (!rekod_stok.map((item) => item.tarikh).contains(tarikhRekod)) {
      rekod_stok.add(
        rekodStok(
          epochTimeStok,
          tarikhRekod,
          hariRekod,
          0.00,
          0.00,
          _rekodStokDetail,
        ),
      );
    } else {
      var target =
          rekod_stok[rekod_stok.indexWhere(
            (element) => element.tarikh == tarikhRekod,
          )];
      target.rekod = sortMenuList(rekodList);
    }
  }

  void removeItems(int index) {
    tarikhRekod = rekod_stok.elementAt(index).tarikh;
    // rekod_stok.removeAt(index);
    saveData();
  }

  // This block saves our list locally.
  void saveData() {
    updateStok(tarikhRekod);
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sattayussop/Rekod_Cucuk/rekodCucukFilter.dart';
import 'package:sattayussop/Rekod_Gaji/rekodAmbilGaji.dart';
import 'package:string_capitalize/string_capitalize.dart';
import 'package:sattayussop/DocumentHelper.dart';
import 'package:sattayussop/Rekod_Cucuk/rekodCucukDetail.dart';
import 'package:notification_center/notification_center.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class selectRekodCucuk extends StatefulWidget {
  const selectRekodCucuk({super.key});

  @override
  State<selectRekodCucuk> createState() => _selectRekodCucukState();
}

class _selectRekodCucukState extends State<selectRekodCucuk> {
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  final myController = TextEditingController();
  String tarikhRekod = "";
  String hariRekod = "";
  DateTime selectedDate = DateTime.now();
  final TimeOfDay _fromTime = TimeOfDay.now();
  List<rekodMenu> menuList = <rekodMenu>[];
  final List<rekodPekerja> _rekodPekerja = <rekodPekerja>[];
  TextStyle textStyle = TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);
  bool dark = sharedPreferences?.getBool("darkModeStatus") ?? false;
  Color color = Colors.orange;
  Color colorBorder = Colors.black;
  String fileName = 'Rekod Cucuk';
  List<DropdownMenuItem> dropDownList = <DropdownMenuItem>[];

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
      colorBorder = Colors.white;
    }
    NotificationCenter().subscribe('refreshData', _refreshView);
    loadData();
    for (var index = 0; index < rekod_Menu.length; index++) {
      rekodMenu current = rekod_Menu.elementAt(index);
      if (current.jenis.toLowerCase().contains("satay")) {
        menuList.add(current);
      }
    }
    menuList.sort((a, b) => a.jenis.compareTo(b.jenis));
    for (var index = 0; index < rekod_Pekerja.length; index++) {
      rekodPekerja current = rekod_Pekerja.elementAt(index);
      var username = current.username;
      var nama = current.nama;
      if (current.cucuk == true) {
        print("rekod >> $username");
        dropDownList.add(
          DropdownMenuItem<String>(
            value: username.isEmpty == true ? null : username,
            child: Text(nama),
          ),
        );
        _rekodPekerja.add(current);
      }
    }
    _rekodPekerja.sort((a, b) => a.username.compareTo(b.username));
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
    print("refresh data in rekod Cucuk");
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
    setState(() {
      rekod_Cucuk.sort((a, b) => a.epochTime.compareTo(b.epochTime));
    });
  }

  @override
  Widget build(BuildContext context) {
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.only(top: 5),
      child: ListView.builder(
        itemCount: rekod_Cucuk.length,
        itemBuilder: (BuildContext context, int index) {
          rekodCucuk current = rekod_Cucuk.elementAt(index);
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
                  builder: (context) => selectRekodCucukDetail(
                    selectIndex: index,
                    pekerja: _rekodPekerja,
                    menuList: menuList,
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
                builder: (context) => selectRekodCucukFilter(
                  pekerja: _rekodPekerja,
                  menuList: menuList,
                ),
              ),
            );
          } else if (item == '2') {
            showDialogTextRequired(context, "Masukkan Nama Pekerja");
          } else if (item == '3') {
            removeAll();
          }
        },
        itemBuilder: (BuildContext bc) {
          var menu = const [
            PopupMenuItem(value: '1', child: Text("Rekod Terperinci")),
          ];
          if (role.toString().capitalize() == "Manager") {
            menu = const [
              PopupMenuItem(value: '1', child: Text("Rekod Terperinci")),
              PopupMenuItem(value: '2', child: Text("Ambil Gaji")),
            ];
          } else if (role.toString().capitalize() == "Admin") {
            menu = const [
              PopupMenuItem(value: '1', child: Text("Rekod Terperinci")),
              PopupMenuItem(value: '2', child: Text("Ambil Gaji")),
              PopupMenuItem(value: '3', child: Text("Padam Seluruh Data")),
            ];
          }
          return menu;
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
        title: Text(fileName, style: TextStyle(color: Colors.white)),
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

  void showDialogTextRequired(BuildContext context, String title) {
    final myController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String username = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  //position
                  mainAxisSize: MainAxisSize.min,
                  // wrap content in flutter
                  children: <Widget>[
                    Text(
                      'Nama Pekerja :',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    Container(height: 2),
                    DropdownButtonFormField(
                      isExpanded: true,
                      initialValue: myController.text.isEmpty
                          ? null
                          : myController.text,
                      onChanged: (item) {
                        username = item;
                        var result = _rekodPekerja.elementAt(
                          _rekodPekerja.indexWhere(
                            (e) => e.username == username,
                          ),
                        );
                        var nama = result.nama;
                        myController.text = nama;
                      },
                      items: dropDownList,
                    ),
                  ],
                ),
              ),
            ),
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
                String namaPekerja = username;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        selectRekodAmbilGaji(nama: namaPekerja),
                  ),
                );
              },
            ),
          ],
        );
      },
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
                rekodCucuk current = rekod_Cucuk.elementAt(index);
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

        tarikhRekod = DateFormat('dd/MM/yyyy').format(selectedDate).toString();
        DateTime tempDate1 = DateFormat(
          "dd/MM/yyyy",
        ).parse(tarikhRekod.toString());
        var epochTime = tempDate1.millisecondsSinceEpoch.toString();

        // List<dynamic> rekod = [];
        insertServer(rekodCucuk(epochTime, tarikhRekod, hariRekod, [], []));
      });
    }
  }

  Future<void> insertServer(rekodCucuk usr) async {
    var id = -1;
    if (!rekod_Cucuk.map((item) => item.epochTime).contains(usr.epochTime)) {
      final result = await insertUpdateTable('Cucuk Rekod', usr.toMapServer());
      id = rekodCucuk.fromMap(result).id;
      List<dynamic> rekodJumlah = [];
      for (var i = 0; i < menuList.length; i++) {
        var current = menuList.elementAt(i);
        String menu = current.jenis;
        if (menu.toLowerCase().contains('satay')) {
          var jumlahCucukRekod = rekodJumlahCucuk(id, menu, 0);
          insertUpdateTable(
            'Jumlah Cucuk Satay Rekod',
            jumlahCucukRekod.toMapServer(),
          );
          rekodJumlah.add(jumlahCucukRekod);
        }
      }
    }
    insertStok(usr.epochTime, usr.tarikh, usr.hari);
    addItem(usr);
  }

  // addItem adds our User Class item to list.
  void addItem(rekodCucuk usr) {
    rekod_Cucuk.add(usr);
    if (!rekod_stok.map((item) => item.tarikh).contains(usr.tarikh)) {
      rekod_stok.add(
        rekodStok(usr.epochTime, usr.tarikh, usr.hari, 0.00, 0.00, []),
      );
      print("insert this >> $usr");
    }
    Future.delayed(Duration(seconds: 2), () {
      saveData();
    });
  }

  void removeItemInServer(int index) {
    tarikhRekod = rekod_Cucuk[index].tarikh;
    var id = rekod_Cucuk[index].id;
    deleteRow('Cucuk Rekod', id);
    removeItem(index);
  }

  void removeItem(int index) {
    rekod_Cucuk.removeAt(
      rekod_Cucuk.indexWhere((element) => element.tarikh == tarikhRekod),
    );
    saveData();
  }

  void removeAll() {
    rekod_Cucuk.clear();
    for (var index = 0; index < _rekodPekerja.length; index++) {
      rekodPekerja current = _rekodPekerja.elementAt(index);
      List<rekodAmbilGaji> rekodAmbil = List<rekodAmbilGaji>.from(
        current.rekodAmbil,
      ).toList();
      rekodAmbil.clear();
      current.rekodAmbil = rekodAmbil;
      rekod_Pekerja[rekod_Pekerja.indexWhere(
            (element) => element.nama == current.nama,
          )] =
          current;
    }
    removeAllServer();
  }

  void removeAllServer() {
    deleteAllRecord("Cucuk Rekod");
    saveData();
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
    // Future.delayed(Duration(seconds: 2), () {
    updateStok(tarikhRekod);
  }
}

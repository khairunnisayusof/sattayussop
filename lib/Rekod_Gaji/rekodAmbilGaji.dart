import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sattayussop/DocumentHelper.dart';
import 'package:notification_center/notification_center.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class selectRekodAmbilGaji extends StatefulWidget {
  const selectRekodAmbilGaji({super.key, required this.nama});

  final String nama;

  @override
  State<selectRekodAmbilGaji> createState() => _selectRekodAmbilGajiState();
}

class _selectRekodAmbilGajiState extends State<selectRekodAmbilGaji> {
  List<rekodAmbilGaji> _rekodAmbilGaji = <rekodAmbilGaji>[];
  String nama = "";
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
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
  Color colorBorder = Colors.black;
  List<DropdownMenuItem> dropDownList = <DropdownMenuItem>[];
  num jumlahAmbil = 0.0;
  int id = -1;
  int idPekerja = -1;
  DateTime selectedDate = DateTime.now();
  String tarikhRekod = "";
  String hariRekod = "";
  var epochTime = "";

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
      colorBorder = Colors.white;
    }
    NotificationCenter().subscribe('refreshData', _refreshView);
    nama = widget.nama;
    rekodPekerja current = rekod_Pekerja.elementAt(
      rekod_Pekerja.indexWhere((element) => element.username == nama),
    );
    idPekerja = current.id;
    print("ambik gaji >> $nama | $idPekerja");
    _rekodAmbilGaji = List<rekodAmbilGaji>.from(current.rekodAmbil).toList();
    _rekodAmbilGaji.sort((a, b) => a.epochTime.compareTo(b.epochTime));
    _refreshView(true);
    super.initState();
  }

  @override
  void dispose() {
    if (!mounted) return;
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  void _refreshView(bool refresh) {
    if (!mounted) return;
    setState(() {
      rekodPekerja current = rekod_Pekerja.elementAt(
        rekod_Pekerja.indexWhere((element) => element.id == idPekerja),
      );
      _rekodAmbilGaji = List<rekodAmbilGaji>.from(current.rekodAmbil).toList();
      _rekodAmbilGaji.sort((a, b) => a.epochTime.compareTo(b.epochTime));
      jumlahAmbil = 0.0;
      for (var index = 0; index < _rekodAmbilGaji.length; index++) {
        rekodAmbilGaji current = _rekodAmbilGaji.elementAt(index);
        num ambil = current.jumlah;
        jumlahAmbil = jumlahAmbil + ambil;
      }
    });
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
    rekodPekerja current = rekod_Pekerja.elementAt(
      rekod_Pekerja.indexWhere((element) => element.id == idPekerja),
    );
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Card(
              elevation: 3,
              color: color,
              child: ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Nama :',
                      style: textStyleCard,
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      ' ${current.nama}',
                      style: textStyleCardNormal,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                primary: true,
                children: <Widget>[
                  Table(
                    border: TableBorder.all(color: colorBorder),
                    columnWidths: const <int, TableColumnWidth>{
                      0: FlexColumnWidth(),
                      1: FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: <TableRow>[
                      TableRow(
                        children: <Widget>[
                          SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                'Tarikh',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                'Gaji Ambil',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ListView.builder(
                    primary: false,
                    itemCount: _rekodAmbilGaji.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      rekodAmbilGaji current = _rekodAmbilGaji.elementAt(index);
                      String tarikh = '${current.hari}, ${current.tarikh}';
                      num ambil = current.jumlah;
                      return GestureDetector(
                        child: Table(
                          border: TableBorder.all(color: colorBorder),
                          columnWidths: const <int, TableColumnWidth>{
                            0: FlexColumnWidth(),
                            1: FlexColumnWidth(),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            TableRow(
                              children: <Widget>[
                                SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      tarikh,
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      money(ambil),
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          showDialogAmbilRequired(
                            context,
                            "Masukkan data",
                            index,
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
                      // }
                    },
                  ),
                  ListTile(
                    minTileHeight: 1.0,
                    minVerticalPadding: 16,
                    leading: Text(
                      'Jumlah Ambil : ',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    trailing: Text(
                      ' ${money(jumlahAmbil)}',
                      style: textStyleNormal,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        title: Text("Detail Ambil", style: TextStyle(color: Colors.white)),
        actions: <Widget>[],
        centerTitle: true,
      ),
      body: buildCollectionView,
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        foregroundColor: Colors.white,
        onPressed: () {
          _selectDate(context, -1);
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

  void showDialogAmbilRequired(BuildContext context, String title, int index) {
    var myController = TextEditingController();
    var myController1 = TextEditingController();
    String errorText = "Sila masukkan beberapa digit";
    final formKey = GlobalKey<FormState>();
    rekodAmbilGaji current = rekodAmbilGaji(idPekerja, "", "", "", 0.00);
    if (index >= 0 ||
        _rekodAmbilGaji.map((item) => item.tarikh).contains(tarikhRekod)) {
      current = _rekodAmbilGaji.elementAt(index);
      print(
        "index ambil $index == ${_rekodAmbilGaji.indexWhere((e) => e.tarikh == tarikhRekod)} >> ${current.toMap()}",
      );
      hariRekod = current.hari;
      tarikhRekod = current.tarikh;
      myController1.text = '${current.jumlah}';
    }
    String tarikh = '$hariRekod, $tarikhRekod';
    myController.text = tarikh;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            // height: MediaQuery.of(context).size.height / 3,
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
                      'Tarikh :',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    TextButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 1.0, color: colorBorder),
                      ),
                      onPressed: () {
                        // Navigator.of(context).pop();
                        _selectDate(context, index);
                        // _showTimePicker(context);
                      },
                      child: Text(tarikh),
                    ),
                    Container(height: 2),
                    Text(
                      'Gaji Ambil :',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    TextFormField(
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return errorText;
                        }
                        return null;
                      },
                      autofocus: true,
                      controller: myController1,
                      textInputAction: TextInputAction.next,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9+\-*/.]'),
                        ),
                      ],
                      // Moves focus to next.
                      decoration: InputDecoration(),
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
                // Handle the submit action
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  num ambil = myController1.text.totalDoubleNumber();
                  if (index >= 0) {
                    current.epochTime = epochTime;
                    current.hari = hariRekod;
                    current.tarikh = tarikhRekod;
                    current.jumlah = ambil;
                  } else {
                    current = rekodAmbilGaji(
                      idPekerja,
                      epochTime,
                      tarikhRekod,
                      hariRekod,
                      ambil,
                    );
                  }
                  insertDetailServer(current, index);
                }
                // Handle the submit action
              },
            ),
          ],
        );
      },
    );
  }

  void _selectDate(BuildContext context, int index) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendar,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1),
    ).then((selectDate) {
      if (selectDate != null) {
        if (index >= 0) {
          Navigator.of(context).pop();
        }
        DateTime selectedDateTime = DateTime(
          selectDate.year,
          selectDate.month,
          selectDate.day,
        );
        setState(() {
          selectedDate = selectDate;
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
          epochTime = tempDate1.millisecondsSinceEpoch.toString();
          if (_rekodAmbilGaji
              .map((item) => item.tarikh)
              .contains(tarikhRekod)) {
            index = _rekodAmbilGaji.indexWhere((e) => e.tarikh == tarikhRekod);
          }
          showDialogAmbilRequired(context, "Masukkan Data", index);
        });
      }
    });
  }

  Future<void> insertDetailServer(rekodAmbilGaji usr, int index) async {
    index >= 0
        ? await insertUpdateTable(
            'Ambil Gaji Rekod',
            usr.toMapServer(),
            id: usr.id,
          )
        : await insertUpdateTable('Ambil Gaji Rekod', usr.toMapServer());
    addItem(usr, index);
  }

  // addItem adds our User Class item to list.
  void addItem(rekodAmbilGaji usr, int index) {
    if (index >= 0) {
      rekodAmbilGaji current = _rekodAmbilGaji.elementAt(index);
      current.tarikh = usr.tarikh;
      current.hari = usr.hari;
      current.epochTime = usr.epochTime;
      current.jumlah = usr.jumlah;
    } else {
      _rekodAmbilGaji.add(usr);
    }
    var target = rekod_Pekerja.elementAt(
      rekod_Pekerja.indexWhere((element) => element.id == idPekerja),
    );
    target.rekodAmbil = _rekodAmbilGaji;
    saveData();
  }

  void removeItemInServer(int index) {
    tarikhRekod = _rekodAmbilGaji[index].tarikh;
    var id = _rekodAmbilGaji[index].id;
    print("removed >> $id");
    deleteRow('Ambil Gaji Rekod', id);
    removeItemSelected(index);
  }

  void removeItemSelected(int index) {
    _rekodAmbilGaji.removeAt(index);
    var target = rekod_Pekerja.elementAt(
      rekod_Pekerja.indexWhere((element) => element.id == idPekerja),
    );
    target.rekodAmbil = _rekodAmbilGaji;
    saveData();
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Simpan Data')));
  }
}

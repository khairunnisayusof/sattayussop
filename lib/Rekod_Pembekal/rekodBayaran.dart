import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:notification_center/notification_center.dart';
import '../resit.dart';
import 'dart:convert';
import "../DocumentHelper.dart";
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class RekodBayaranPembekal extends StatefulWidget {
  RekodBayaranPembekal({
    super.key,
    required this.selectIndex,
    required this.nama,
  });

  int selectIndex;
  final String nama;
  @override
  State<RekodBayaranPembekal> createState() => _RekodBayaranPembekalState();
}

class _RekodBayaranPembekalState extends State<RekodBayaranPembekal> {
  int selectIndex = 0;
  int PembekalId = -1;
  int id = -1;
  String tarikhPembekal = "";
  String nama = "";
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  TextStyle textStyle = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
  TextStyle textStyleNormal = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.normal,
  );
  bool dark = sharedPreferences?.getBool("darkModeStatus") ?? false;
  List<rekodBayaranPembekal> rekodBayaran = <rekodBayaranPembekal>[];
  List<rekodPembekalDetail> selectDetailBarang = <rekodPembekalDetail>[];
  Color color = Colors.orange;
  Color colorBorder = Colors.black;
  DateTime selectedDate = DateTime.now();
  String tarikhRekod = "";
  String hariRekod = "";
  var epochTime = "";
  final pdf = pw.Document();
  num jumlahKeseluruhan = 0.0;
  num jumlahBayaran = 0.0;

  @override
  void initState() {
    NotificationCenter().subscribe('refreshData', _refreshView);
    if (dark) {
      color = Colors.deepOrange;
      colorBorder = Colors.white;
    }
    selectIndex = widget.selectIndex;
    nama = widget.nama;
    _refreshView(true);
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
  }

  void _refreshView(bool refresh) {
    setState(() {
      rekodPembekalList currentPembekal = rekod_Pembekal.elementAt(
        rekod_Pembekal.indexWhere((e) => e.id == selectIndex),
      );
      PembekalId = currentPembekal.id;
      nama = currentPembekal.namaPembekal;
      selectDetailBarang = List<rekodPembekalDetail>.from(
        currentPembekal.rekod,
      ).toList();
      rekodBayaran = List<rekodBayaranPembekal>.from(
        currentPembekal.rekodBayaran,
      ).toList();
      print("rekod bayaran >> ${rekodBayaran.length} | $selectIndex");
      jumlahBayaran = 0.0;
      jumlahKeseluruhan = 0.0;
      for (var index = 0; index < rekodBayaran.length; index++) {
        rekodBayaranPembekal current = rekodBayaran.elementAt(index);
        jumlahBayaran = jumlahBayaran + current.bayaran;
      }
      rekodBayaran.sort((a, b) => a.tarikh.compareTo(b.tarikh));
      for (var index = 0; index < selectDetailBarang.length; index++) {
        var current = selectDetailBarang[index];
        var jumlahBayaran = current.jumlah;
        jumlahKeseluruhan += jumlahBayaran;
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
    Container buildCollectionView;
    _refreshView(true);
    buildCollectionView = Container(
      margin: EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ListView(
          primary: true,
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
                      ' $nama',
                      style: textStyleCardNormal,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
            ),
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
                      height: 30,
                      child: Center(
                        child: Text(
                          'Tarikh',
                          style: textStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: Center(
                        child: Text(
                          'Bayaran (RM)',
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
              itemCount: rekodBayaran.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                rekodBayaranPembekal current = rekodBayaran.elementAt(index);
                return GestureDetector(
                  child: Table(
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
                            height: 50,
                            child: Center(
                              child: Text(
                                current.tarikh,
                                style: textStyleNormal,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                money(current.bayaran),
                                style: textStyleNormal,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                    showDialogBayaranRequired(context, "Masukkan Data", index);
                  },
                );
              },
            ),
            Row(
              children: [
                Spacer(flex: 1),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Jumlah Keseluruhan (RM)',
                              style: textStyle,
                            ),
                          ),
                          Text(
                            money(jumlahKeseluruhan),
                            style: textStyleNormal,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Jumlah Sudah Bayar (RM)',
                              style: textStyle,
                            ),
                          ),
                          Text(money(jumlahBayaran), style: textStyleNormal),
                        ],
                      ),
                      SizedBox(height: 5),
                      Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: Text('Baki Bayaran (RM)', style: textStyle),
                          ),
                          Text(
                            money(jumlahKeseluruhan - jumlahBayaran),
                            style: textStyleNormal,
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Container(height: 1, color: Colors.grey),
                      SizedBox(height: 0.5),
                      Container(height: 1, color: Colors.grey),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    final settingButton = Padding(
      padding: EdgeInsets.only(right: 5.0),
      child: PopupMenuButton(
        icon: more_rev_Icon,
        onSelected: (item) async {
          // your logic
          if (item == '1') {
            final pdfFile = await PdfBayaranPembekalResit.generate(
              PdfColors.black,
              nama,
              tarikhPembekal,
            );
            // opening the pdf file
            FileHandleApi.openFile(pdfFile);
          }
        },
        itemBuilder: (BuildContext bc) {
          return const [
            PopupMenuItem(value: '1', child: Text("Resit Rekod Bayaran")),
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
        title: Text("Rekod Bayaran", style: TextStyle(color: Colors.white)),
        actions: <Widget>[settingButton],
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
          epochTime = tempDate1.millisecondsSinceEpoch.toString();
          var selectIndex = rekodBayaran.indexWhere(
            (pelanggan) => pelanggan.tarikh == tarikhRekod,
          );

          if (selectIndex >= 0) {
            rekodBayaranPembekal current = rekodBayaran.elementAt(selectIndex);
            current.tarikh = tarikhRekod;
            current.hari = hariRekod;
            current.epochTime = epochTime;
            showDialogBayaranRequired(context, "Masukkan Data", selectIndex);
          } else {
            showDialogBayaranRequired(context, "Masukkan Data", -1);
          }
        });
      }
    });
  }

  void showDialogBayaranRequired(
    BuildContext context,
    String title,
    int index,
  ) {
    var myController = TextEditingController();
    var myController1 = TextEditingController();
    String errorText = "Sila masukkan beberapa digit";
    final formKey = GlobalKey<FormState>();
    if (index >= 0) {
      rekodBayaranPembekal current = rekodBayaran.elementAt(index);
      hariRekod = current.hari;
      tarikhRekod = current.tarikh;
      myController1.text = money(current.bayaran);
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
                      'Bayaran :',
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
                  num bayaran = myController1.text.totalDoubleNumber();
                  insertServer(
                    rekodBayaranPembekal(
                      PembekalId,
                      epochTime,
                      tarikhRekod,
                      hariRekod,
                      bayaran,
                    ),
                    index,
                  );
                }
                // Handle the submit action
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
                removeItemInServer(index);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> insertServer(rekodBayaranPembekal usr, int index) async {
    if (index >= 0) {
      await insertUpdateTable(
        'Pembekal Bayaran Rekod',
        usr.toMapServer(),
        id: selectIndex,
      );
    } else {
      await insertUpdateTable('Pembekal Bayaran Rekod', usr.toMapServer());
    }
    addItem(usr, index);
  }

  // addItem adds our User Class item to list.
  void addItem(rekodBayaranPembekal usr, int index) {
    if (index >= 0) {
      rekodBayaranPembekal currentPembekal = rekodBayaran.elementAt(index);
      currentPembekal.bayaran = usr.bayaran;
    } else {
      rekodBayaran.add(usr);
    }
    print("document >>> $index | ${usr.bayaran}");
    kiraJualan();
  }

  void kiraJualan() async {
    rekodPembekalList currentPembekal = rekod_Pembekal.elementAt(
      rekod_Pembekal.indexWhere((e) => e.id == PembekalId),
    );

    nama = currentPembekal.namaPembekal;

    List<rekodPembekalDetail> selectDetail = List<rekodPembekalDetail>.from(
      currentPembekal.rekod,
    ).toList();

    // Total bayaran
    num jumlahBayaranSemua = 0.0;

    for (var current in rekodBayaran) {
      print("rekod >>> ${current.tarikh} + ${current.bayaran}");
      jumlahBayaranSemua += current.bayaran;
    }

    num bakiBayaran = jumlahBayaranSemua;

    for (var current in selectDetail) {
      num jumlahJualan = current.jumlah;

      // Bayaran cukup untuk cover full
      if (bakiBayaran >= jumlahJualan) {
        current.bayaran = jumlahJualan;
        current.baki = 0.0;
        current.bayaranPenuh = true;

        bakiBayaran -= jumlahJualan;
      }
      // Bayaran separuh
      else if (bakiBayaran > 0) {
        current.bayaran = bakiBayaran;
        current.baki = jumlahJualan - bakiBayaran;
        current.bayaranPenuh = false;

        bakiBayaran = 0;
      }
      // Tiada bayaran lagi
      else {
        current.bayaran = 0.0;
        current.baki = jumlahJualan;
        current.bayaranPenuh = false;
      }
      await insertUpdateTable(
        'Pembekal Detail Rekod',
        current.toMapServer(),
        id: current.id,
      );
    }

    List<String> rekodList = selectDetail
        .map((item) => jsonEncode(item.toMap()))
        .toList();
    List<String> rekodBayaranList = rekodBayaran
        .map((item) => jsonEncode(item.toMap()))
        .toList();
    setState(() {
      currentPembekal.rekod = selectDetail;
      currentPembekal.rekodBayaran = rekodBayaran;
    });
    await insertUpdateTable(
      'Pembekal Rekod',
      currentPembekal.toMapServer(),
      id: PembekalId,
    );
    saveData();
  }

  void removeItemInServer(int index) {
    var id = rekodBayaran[index].id;
    deleteRow('Pembekal Bayaran Rekod', id);
    removeItem(index);
  }

  void removeItem(int index) {
    rekodBayaran.removeAt(index);
    kiraJualan();
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Simpan Data')));
  }
}

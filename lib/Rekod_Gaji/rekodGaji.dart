import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import '../Rekod_Gaji/rekodAmbilGaji.dart';
import '../Rekod_Gaji/rekodGajiDetail.dart';
import '../Rekod_Gaji/rekodGajiFilter.dart';
import '../resit.dart';
import '../DocumentHelper.dart';
import 'package:notification_center/notification_center.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class selectRekodGaji extends StatefulWidget {
  const selectRekodGaji({super.key});

  @override
  State<selectRekodGaji> createState() => _selectRekodGajiState();
}

class _selectRekodGajiState extends State<selectRekodGaji> {
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  final myController = TextEditingController();
  String tarikhRekod = "";
  String hariRekod = "";
  DateTime selectedDate = DateTime.now();
  int _removeIndex = -1;
  TextStyle textStyle = TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);
  bool dark = sharedPreferences?.getBool("darkModeStatus") ?? false;
  Color color = Colors.orange;
  List<DropdownMenuItem> dropDownList = <DropdownMenuItem>[];
  final List<rekodPekerja> _rekodPekerja = <rekodPekerja>[];

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
    }
    NotificationCenter().subscribe('refreshData', _refreshView);
    loadDataServer();
    for (var index = 0; index < rekod_Pekerja.length; index++) {
      rekodPekerja current = rekod_Pekerja.elementAt(index);
      var username = current.username;
      var nama = current.nama;
      if (!current.cucuk && (current.role == "Pekerja")) {
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

  void _refreshView(bool refresh) {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    if (!mounted) return;
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    loadDataServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.only(top: 5),
      child: ListView.builder(
        itemCount: rekod_Gaji.length,
        itemBuilder: (BuildContext context, int index) {
          rekodGaji current = rekod_Gaji.elementAt(index);
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
                  builder: (context) => selectRekodGajiDetail(
                    selectIndex: index,
                    pekerja: _rekodPekerja,
                  ),
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
            showDialogNamaPekerjaRequired(context, item);
          } else if (item == '2') {
            showDialogNamaPekerjaRequired(context, item);
          } else if (item == '3') {
            showDialogNamaPekerjaRequired(context, item);
          } else if (item == '4') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    selectRekodGajiFilter(pekerja: _rekodPekerja),
              ),
            );
          } else if (item == '5') {
            removeAll();
          }
        },
        itemBuilder: (BuildContext bc) {
          return const [
            PopupMenuItem(value: '1', child: Text("Ambil Gaji")),
            PopupMenuItem(value: '2', child: Text("Slip Gaji")),
            PopupMenuItem(value: '3', child: Text("Slip Gaji Tanpa KWSP")),
            PopupMenuItem(value: '4', child: Text("Rekod Terperinci")),
            PopupMenuItem(value: '5', child: Text("Padam Seluruh Data")),
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
        title: Text("Rekod Gaji", style: TextStyle(color: Colors.white)),
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

  void showDialogNamaPekerjaRequired(BuildContext context, String item) {
    final myController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String username = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Sila Pilih Nama Pekerja"),
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
              onPressed: () async {
                Navigator.of(context).pop();
                // Handle the submit action
                print("nama >> ${myController.text}");
                String namaPekerja = username;
                if (item == '1') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          selectRekodAmbilGaji(nama: namaPekerja),
                    ),
                  );
                } else if (item == '2') {
                  final pdfFile = await PdfSlipGaji.generate(
                    PdfColors.black,
                    namaPekerja,
                    true,
                  );
                  // opening the pdf file
                  FileHandleApi.openFile(pdfFile);
                } else if (item == '3') {
                  final pdfFile = await PdfSlipGaji.generate(
                    PdfColors.black,
                    namaPekerja,
                    false,
                  );
                  // opening the pdf file
                  FileHandleApi.openFile(pdfFile);
                }
              },
            ),
          ],
        );
      },
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
        tarikhRekod = DateFormat('dd/MM/yyyy').format(selectedDate);
        DateTime tempDate1 = DateFormat(
          "dd/MM/yyyy",
        ).parse(tarikhRekod.toString());
        var epochTime = tempDate1.millisecondsSinceEpoch.toString();
        if (!rekod_Gaji.map((item) => item.tarikh).contains(tarikhRekod)) {
          insertServer(rekodGaji(epochTime, tarikhRekod, hariRekod));
        }
      });
    }
  }

  Future<void> insertServer(rekodGaji usr) async {
    final result = await insertUpdateTable('Gaji Rekod', usr.toMapServer());
    var resultRekod = rekodGaji.fromMap(result);
    _rekodPekerja.sort((a, b) => a.username.compareTo(b.username));
    for (var index = 0; index < _rekodPekerja.length; index++) {
      rekodPekerja current = _rekodPekerja.elementAt(index);
      print("rekod >>> $index >> ${current.username}");
      int idPekerja = current.id;
      num simpan = current.gajiSimpan;
      num harian = current.gajiHarian;
      if (!current.cucuk &&
          (current.role == "Pekerja" && !(simpan <= 0 && harian <= 0))) {
        rekodGajiDetail rekodDetail = rekodGajiDetail(
          resultRekod.id,
          idPekerja,
          simpan,
          harian,
        );
        insertDetailServer(rekodDetail);
        usr.rekod.insert(usr.rekod.length, rekodDetail);
      }
    }
    addItem(usr);
  }

  Future<void> insertDetailServer(rekodGajiDetail usr) async {
    await insertUpdateTable('Gaji Detail Rekod', usr.toMapServer());
  }

  // addItem adds our User Class item to list.
  void addItem(rekodGaji usr) {
    saveData();
    rekod_Gaji.add(usr);
  }

  void removeItemInServer(int index) {
    tarikhRekod = rekod_Gaji[index].tarikh;
    var id = rekod_Gaji[index].id;
    deleteRow('Gaji Rekod', id);
    removeItem(index);
  }

  void removeItem(int index) {
    rekod_Gaji.removeAt(index);
    saveData();
  }

  void removeAll() {
    deleteAllRecord("Gaji Rekod");
    rekod_Gaji.clear();
    for (var index = 0; index < rekod_Pekerja.length; index++) {
      rekodPekerja current = rekod_Pekerja.elementAt(index);
      current.rekodAmbil = [];
    }
    saveData();
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
  }
}

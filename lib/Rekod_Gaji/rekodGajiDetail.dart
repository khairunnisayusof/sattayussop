import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:string_capitalize/string_capitalize.dart';
import '../DocumentHelper.dart';
import 'package:notification_center/notification_center.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class selectRekodGajiDetail extends StatefulWidget {
  const selectRekodGajiDetail({
    super.key,
    required this.selectIndex,
    required this.pekerja,
  });

  final int selectIndex;
  final List<rekodPekerja> pekerja;

  @override
  State<selectRekodGajiDetail> createState() => _selectRekodGajiDetailState();
}

class _selectRekodGajiDetailState extends State<selectRekodGajiDetail> {
  int selectIndex = 0;
  int id = 0;
  final List<rekodGajiDetail> _rekodGajiDetail = <rekodGajiDetail>[];
  List<rekodPekerja> pekerja = <rekodPekerja>[];
  String tarikh = "";
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
  num jumlahHarian = 0.0;
  num jumlahSimpan = 0.0;

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
      colorBorder = Colors.white;
    }
    NotificationCenter().subscribe('refreshData', _refreshView);
    pekerja = widget.pekerja;
    selectIndex = widget.selectIndex;
    rekodGaji current = rekod_Gaji.elementAt(selectIndex);
    id = current.id;
    tarikh = current.tarikh;
    pekerja.sort((a, b) => a.username.compareTo(b.username));
    print("rekod in detail >> ${pekerja.length} ");
    for (var index = 0; index < pekerja.length; index++) {
      rekodPekerja list = pekerja.elementAt(index);
      var nama = list.nama;
      dropDownList.add(
        DropdownMenuItem<String>(value: nama, child: Text(nama)),
      );
    }
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
    rekodGaji current = rekod_Gaji.elementAt(
      rekod_Gaji.indexWhere((e) => e.id == id),
    );
    List<rekodGajiDetail> currentDetail = List<rekodGajiDetail>.from(
      current.rekod,
    ).toList();
    _rekodGajiDetail.clear();
    for (var index = 0; index < pekerja.length; index++) {
      rekodPekerja list = pekerja.elementAt(index);
      int i = currentDetail.indexWhere((e) => e.pekerja_id == list.id);
      if (i < 0) {
        print("Pekerja tidak dijumpai: $list.id");
        continue; // atau continue;
      }
      var rekod = currentDetail.elementAt(i);
      _rekodGajiDetail.insert(_rekodGajiDetail.length, rekod);
    }
    jumlahHarian = 0.0;
    jumlahSimpan = 0.0;
    for (var i = 0; i < _rekodGajiDetail.length; i++) {
      rekodGajiDetail currentrekod = _rekodGajiDetail.elementAt(i);
      num harian = currentrekod.harian;
      num simpan = currentrekod.simpan;
      jumlahHarian = jumlahHarian + harian;
      jumlahSimpan = jumlahSimpan + simpan;
    }
    setState(() {});
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
    rekodGaji current = rekod_Gaji.elementAt(
      rekod_Gaji.indexWhere((e) => e.id == id),
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
                      'Hari :',
                      style: textStyleCard,
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      ' ${current.hari}',
                      style: textStyleCardNormal,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Tarikh :',
                      style: textStyleCard,
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      ' $tarikh',
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
                      1: FixedColumnWidth(70),
                      2: FixedColumnWidth(70),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: <TableRow>[
                      TableRow(
                        children: <Widget>[
                          SizedBox(
                            height: 60,
                            child: Center(
                              child: Text(
                                'Nama',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 60,
                            child: Center(
                              child: Text(
                                'Gaji Simpan',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 60,
                            child: Center(
                              child: Text(
                                'Gaji Harian',
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
                    itemCount: _rekodGajiDetail.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      rekodGajiDetail current = _rekodGajiDetail.elementAt(
                        index,
                      );
                      int pekerjaID = current.pekerja_id;
                      String nama = rekod_Pekerja
                          .elementAt(
                            rekod_Pekerja.indexWhere((e) => e.id == pekerjaID),
                          )
                          .nama;
                      return GestureDetector(
                        child: Table(
                          border: TableBorder.all(color: colorBorder),
                          columnWidths: const <int, TableColumnWidth>{
                            0: FlexColumnWidth(),
                            1: FixedColumnWidth(70),
                            2: FixedColumnWidth(70),
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
                                      nama,
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      money(current.simpan),
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      money(current.harian),
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
                          showDialogEditRequired(
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
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
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
                                      'Jumlah Simpan',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    money(jumlahSimpan),
                                    style: textStyleNormal,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Jumlah Harian',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    money(jumlahHarian),
                                    style: textStyleNormal,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Divider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Jumlah Keseluruhan',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    money(jumlahSimpan + jumlahHarian),
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
        title: Text("Detail Gaji", style: TextStyle(color: Colors.white)),
        actions: <Widget>[settingButton],
        centerTitle: true,
      ),
      body: buildCollectionView,
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialogEditRequired(context, "Masukkan data", -1);
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

  void showDialogEditRequired(BuildContext context, String title, int index) {
    var myController = TextEditingController();
    var myController2 = TextEditingController();
    var myController3 = TextEditingController();
    String errorText = "Sila masukkan beberapa digit";
    final formKey = GlobalKey<FormState>();
    // declare a variable to keep track of the input text
    rekodGajiDetail current = rekodGajiDetail(-1, -1, 0.00, 0.00);
    int pekerjaID = -1;
    if (index >= 0) {
      current = _rekodGajiDetail.elementAt(index);
      pekerjaID = current.pekerja_id;
      var detailPekerja = rekod_Pekerja.elementAt(
        rekod_Pekerja.indexWhere((e) => e.id == pekerjaID),
      );
      var nama = detailPekerja.nama;
      var simpan = current.simpan;
      var harian = current.harian;
      if (pekerjaID >= 0) {
        myController.text = nama;
      }
      if (simpan > 0) {
        myController2.text = "$simpan";
      }
      if (harian > 0) {
        myController3.text = "$harian";
      }
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      //position
                      mainAxisSize: MainAxisSize.min,
                      // wrap content in flutter
                      children: <Widget>[
                        Text(
                          'Nama :',
                          style: textStyle,
                          textAlign: TextAlign.left,
                        ),
                        (index >= 0)
                            ? TextField(
                                enableInteractiveSelection: false,
                                // will disable paste operation
                                enabled: false,
                                autofocus: false,
                                controller: myController,
                                decoration: InputDecoration(),
                                textInputAction: TextInputAction
                                    .next, // Moves focus to next.
                              )
                            : DropdownButtonFormField(
                                isExpanded: true,
                                onChanged: (item) {
                                  validator:
                                  (value) {
                                    if (value == null || value.isEmpty) {
                                      return errorText;
                                    }
                                    return null;
                                  };
                                  String username = item.toString();
                                  var detailPekerja = rekod_Pekerja.elementAt(
                                    rekod_Pekerja.indexWhere(
                                      (e) => e.username == username,
                                    ),
                                  );
                                  pekerjaID = detailPekerja.id;
                                  myController.text = detailPekerja.nama;
                                },
                                items: dropDownList,
                              ),
                        Text(
                          'Gaji Simpan :',
                          style: textStyle,
                          textAlign: TextAlign.left,
                        ),
                        TextField(
                          autofocus: false,
                          controller: myController2,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9+\-*/.]'),
                            ),
                          ],
                          decoration: InputDecoration(),
                          textInputAction:
                              TextInputAction.done, // Moves focus to next.
                        ),
                        Text(
                          'Gaji Harian :',
                          style: textStyle,
                          textAlign: TextAlign.left,
                        ),
                        TextField(
                          autofocus: false,
                          controller: myController3,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9+\-*/.]'),
                            ),
                          ],
                          decoration: InputDecoration(),
                          textInputAction:
                              TextInputAction.done, // Moves focus to next.
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
                String nama = myController.text.capitalizeEach();
                print("nama >> $nama");
                num simpan = 0.0;
                num harian = 0.0;
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  if (!(myController2.text.isEmpty)) {
                    simpan = myController2.text.totalDoubleNumber();
                  }
                  if (!(myController3.text.isEmpty)) {
                    harian = myController3.text.totalDoubleNumber();
                  }
                  if (index < 0) {
                    current = rekodGajiDetail(
                      current.id,
                      pekerjaID,
                      simpan,
                      harian,
                    );
                  } else {
                    current.simpan = simpan;
                    current.harian = harian;
                  }
                  print(
                    "rekod detail >> $index : ${current.pekerja_id} = ${_rekodGajiDetail.elementAt(index).id} | ${current.toMap()}",
                  );
                  insertDetailServer(current, index);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> insertDetailServer(rekodGajiDetail usr, int index) async {
    index >= 0
        ? await insertUpdateTable(
            'Gaji Detail Rekod',
            usr.toMapServer(),
            id: usr.id,
          )
        : await insertUpdateTable('Gaji Detail Rekod', usr.toMapServer());
    addItem(usr, index);
  }

  // addItem adds our User Class item to list.
  void addItem(rekodGajiDetail usr, int index) {
    if (index >= 0) {
      _rekodGajiDetail[index] = usr;
    } else {
      if (!_rekodGajiDetail
          .map((item) => item.pekerja_id)
          .contains(usr.pekerja_id)) {
        _rekodGajiDetail.add(usr);
      } else {
        _rekodGajiDetail[_rekodGajiDetail.indexWhere(
              (element) => element.pekerja_id == usr.pekerja_id,
            )] =
            usr;
      }
    }
    var target = rekod_Gaji.elementAt(rekod_Gaji.indexWhere((e) => e.id == id));
    setState(() {
      target.rekod = _rekodGajiDetail;
    });
    saveData();
  }

  void removeItemInServer(int index) {
    var id = _rekodGajiDetail[index].id;
    deleteRow('Gaji Detail Rekod', id);
    removeItemSelected(index);
  }

  void removeItemSelected(int index) {
    _rekodGajiDetail.removeAt(index);
    var target = rekod_Gaji.firstWhere((item) => item.id == id);
    target.rekod = _rekodGajiDetail;
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../DocumentHelper.dart';
import 'package:notification_center/notification_center.dart';
import 'package:pdf/widgets.dart' as pw;
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class selectRekodCawanganDetail extends StatefulWidget {
  const selectRekodCawanganDetail({
    super.key,
    required this.selectIndex,
    required this.selectedDetail,
  });

  final int selectedDetail;
  final int selectIndex;

  @override
  State<selectRekodCawanganDetail> createState() =>
      _selectRekodCawanganDetailState();
}

class _selectRekodCawanganDetailState extends State<selectRekodCawanganDetail> {
  int selectIndex = 0;
  int selectedDetail = 0;
  int cawanganId = -1;
  int id = -1;
  String nama = "";
  String tarikh = "";
  List<rekodCawanganDetail> selectDetailCawangan = <rekodCawanganDetail>[];
  rekodCawanganDetail? _rekodCawanganDetail;
  Map<String, dynamic> listHarga = {};
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
  Map<String, dynamic> _rekodMenu = <String, dynamic>{};
  List<DropdownMenuItem> dropDownListMenu = <DropdownMenuItem>[];
  DateTime selectedDate = DateTime.now();
  String tarikhRekod = "";
  String hariRekod = "";
  var epochTime = "";
  List<rekodBayaranCawangan> _rekodBayaranCawangan = <rekodBayaranCawangan>[];
  bool refreshPage = false;
  final pdf = pw.Document();

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
      colorBorder = Colors.white;
    }
    NotificationCenter().subscribe('refreshData', _refreshView);
    selectIndex = widget.selectIndex;
    selectedDetail = widget.selectedDetail;
    rekodCawangan currentCawangan = rekod_Cawangan.elementAt(selectIndex);
    cawanganId = currentCawangan.id;
    nama = currentCawangan.nama;
    listHarga = currentCawangan.rekodHarga;
    dropDownListMenu.clear();
    for (var index = 0; index < listHarga.length; index++) {
      String nama = listHarga.keys.elementAt(index);
      dropDownListMenu.add(
        DropdownMenuItem<String>(value: nama, child: Text(nama)),
      );
    }
    selectDetailCawangan = List<rekodCawanganDetail>.from(
      currentCawangan.rekod,
    ).toList();
    rekodCawanganDetail current = selectDetailCawangan.elementAt(
      selectedDetail,
    );
    id = current.id;
    tarikh = current.tarikh;
    _rekodCawanganDetail = current;
    _refreshView(true);
    super.initState();
  }

  @override
  void dispose() {
    if (!mounted) return;
    // Clean up the controller when the widget is disposed.
    super.dispose;
  }

  void _refreshView(bool refresh) {
    setState(() {
      rekodCawangan currentCawangan = rekod_Cawangan.elementAt(
        rekod_Cawangan.indexWhere((e) => e.id == cawanganId),
      );
      _rekodBayaranCawangan = List<rekodBayaranCawangan>.from(
        currentCawangan.rekodBayaran,
      ).toList();
      selectDetailCawangan = List<rekodCawanganDetail>.from(
        currentCawangan.rekod,
      ).toList();
      _rekodCawanganDetail = selectDetailCawangan.elementAt(
        selectDetailCawangan.indexWhere((e) => e.id == id),
      );
      _rekodMenu = _rekodCawanganDetail?.rekodMenu ?? {};
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
    rekodCawanganDetail current = selectDetailCawangan.elementAt(
      selectDetailCawangan.indexWhere((e) => e.id == id),
    );
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.only(top: 5),
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
                      ' ${_rekodCawanganDetail?.hari}',
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
                      ' ${_rekodCawanganDetail?.tarikh}',
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
                      3: FixedColumnWidth(70),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: <TableRow>[
                      TableRow(
                        children: <Widget>[
                          Container(
                            child: Center(
                              child: Text(
                                'Produk',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                'Bawa',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                'Baki',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                'Rosak',
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
                    itemCount: _rekodMenu.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      String menu = _rekodMenu.keys.elementAt(index);
                      print("menu >> $menu");
                      var value = _rekodMenu[menu];
                      var bawa = value['bawa'] ?? 0;
                      var baki = value['baki'] ?? 0;
                      var rosak = value['rosak'] ?? 0;
                      return GestureDetector(
                        child: Table(
                          border: TableBorder.all(color: colorBorder),
                          columnWidths: const <int, TableColumnWidth>{
                            0: FlexColumnWidth(),
                            1: FixedColumnWidth(70),
                            2: FixedColumnWidth(70),
                            3: FixedColumnWidth(70),
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
                                      menu,
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      '$bawa',
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      '$baki',
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      '$rosak',
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
                          showDialogTextRequired(
                            context,
                            "Masukkan data $menu",
                            index,
                          );
                        },
                        onLongPress: () {
                          showDialogRequired(
                            context,
                            "Pengesahan Memadam",
                            "Adakah anda ingin memadam data ini",
                            menu,
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    minTileHeight: 1.0,
                    minVerticalPadding: 16,
                    leading: Text(
                      'Jualan Satay',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    trailing: Text(
                      '${current.jumlahSatay}',
                      style: textStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  ListTile(
                    minTileHeight: 1.0,
                    minVerticalPadding: 16,
                    leading: Text(
                      'Jumlah Jualan (RM)',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    trailing: Text(
                      money(current.jumlahJualan),
                      style: textStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  ListTile(
                    minTileHeight: 1.0,
                    minVerticalPadding: 16,
                    leading: Text(
                      'Kerugian (RM)',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    trailing: Text(
                      money(current.rugi),
                      style: textStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  ListTile(
                    minTileHeight: 1.0,
                    minVerticalPadding: 16,
                    leading: Text(
                      'Jumlah Sudah Bayar (RM)',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    trailing: Text(
                      money(current.bayaran),
                      style: textStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  ListTile(
                    minTileHeight: 1.0,
                    minVerticalPadding: 16,
                    leading: Text(
                      'Baki Bayaran (RM)',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    trailing: Text(
                      money(current.baki),
                      style: textStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     _selectDate(context, -1);
                  //   },
                  //   style: ButtonStyle(
                  //     backgroundColor: WidgetStatePropertyAll(color),
                  //   ),
                  //   child: Text(
                  //     'Bayaran',
                  //     style: textStyleBtn,
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
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
        onSelected: (item) async {
          // your logic
          if (item == '1') {}
        },
        itemBuilder: (BuildContext bc) {
          return const [];
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
        title: Text(nama, style: TextStyle(color: Colors.white)),
        actions: <Widget>[],
        centerTitle: true,
      ),
      body: buildCollectionView,
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialogTextRequired(context, "Masukkan data", -1);
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
          var index0 = _rekodBayaranCawangan.indexWhere(
            (element) => element.tarikh == tarikhRekod,
          );
          if (_rekodBayaranCawangan
              .map((item) => item.tarikh)
              .contains(tarikhRekod)) {
            rekodBayaranCawangan current = _rekodBayaranCawangan.elementAt(
              index0,
            );
            current.tarikh = tarikhRekod;
            current.hari = hariRekod;
            current.epochTime = epochTime;
            showDialogBayaranRequired(context, "Masukkan Data", index0);
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
      rekodBayaranCawangan current = _rekodBayaranCawangan.elementAt(index);
      epochTime = current.epochTime;
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
                        Navigator.of(context).pop();
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
                      keyboardType: (index >= 0)
                          ? const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            )
                          : TextInputType.number,
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
                  addItem(
                    rekodBayaranCawangan(
                      cawanganId,
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

  // addItem adds our User Class item to list.
  void addItem(rekodBayaranCawangan usr, int index) {
    if (index >= 0) {
      rekodBayaranCawangan currentPembekal = _rekodBayaranCawangan.elementAt(
        index,
      );
      currentPembekal.bayaran = usr.bayaran;
    } else {
      _rekodBayaranCawangan.add(usr);
    }
    print("document >>> $index | ${usr.bayaran}");
    kiraJualan();
  }

  void showDialogRequired(
    BuildContext context,
    String title,
    String message,
    String menu,
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
                removeItemSelected(menu);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showDialogTextRequired(BuildContext context, String title, int index) {
    var myController = TextEditingController();
    var myController1 = TextEditingController();
    var myController2 = TextEditingController();
    var myController3 = TextEditingController();
    String errorText = "Sila masukkan beberapa digit";
    final formKey = GlobalKey<FormState>();
    if (index >= 0) {
      String menu = _rekodMenu.keys.elementAt(index);
      myController.text = menu;
      var bawa = _rekodMenu[menu]["bawa"] ?? 0;
      var baki = _rekodMenu[menu]["baki"] ?? 0;
      var rosak = _rekodMenu[menu]["rosak"] ?? 0;
      if (bawa > 0) {
        myController1.text = "$bawa";
      }
      if (baki > 0) {
        myController2.text = "$bawa";
      }
      if (rosak > 0) {
        myController3.text = "$rosak";
      }
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
                        'Jenis Satay :',
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                      TextField(
                        enableInteractiveSelection: false,
                        // will disable paste operation
                        enabled: false,
                        autofocus: false,
                        controller: myController,
                        decoration: InputDecoration(),
                        textInputAction:
                            TextInputAction.next, // Moves focus to next.
                      ),
                      Container(height: 2),
                      Text(
                        'Bawa :',
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
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+\-*/.]'),
                          ),
                        ],
                        textInputAction: TextInputAction.next,
                        // Moves focus to next.
                        decoration: InputDecoration(),
                      ),
                      Container(height: 2),
                      Text(
                        'Baki :',
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                      TextFormField(
                        autofocus: true,
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
                        textInputAction: TextInputAction.next,
                        // Moves focus to next.
                        decoration: InputDecoration(),
                      ),
                      Container(height: 2),
                      Text(
                        'Rosak :',
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                      TextFormField(
                        autofocus: true,
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
                        textInputAction: TextInputAction.next,
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
                  int bawa = 0;
                  int baki = 0;
                  int rosak = 0;
                  // Handle the submit action
                  if (formKey.currentState!.validate()) {
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    Navigator.of(context).pop();
                    bawa = myController1.text.totalIntNumber();
                    if (!(myController2.text.isEmpty)) {
                      baki = myController2.text.totalIntNumber();
                    }
                    if (!(myController3.text.isEmpty)) {
                      rosak = myController3.text.totalIntNumber();
                    }
                    var value = _rekodMenu[menu];
                    value["bawa"] = bawa;
                    value["baki"] = baki;
                    value["rosak"] = rosak;
                    _rekodMenu[menu] = value;
                    kiraJualan();
                  }
                  // Handle the submit action
                },
              ),
            ],
          );
        },
      );
    } else {
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
                        'Jenis Satay :',
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                      DropdownButtonFormField(
                        isExpanded: true,
                        initialValue: myController.text,
                        onChanged: (item) {
                          myController.text = item;
                        },
                        items: dropDownListMenu,
                      ),
                      Container(height: 2),
                      Text(
                        'Bawa :',
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
                        autofocus: false,
                        controller: myController1,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9+\-*/.]'),
                          ),
                        ],
                        textInputAction: TextInputAction.next,
                        // Moves focus to next.
                        decoration: InputDecoration(),
                      ),
                      Container(height: 2),
                      Text(
                        'Baki :',
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                      TextFormField(
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
                        textInputAction: TextInputAction.next,
                        // Moves focus to next.
                        decoration: InputDecoration(),
                      ),
                      Container(height: 2),
                      Text(
                        'Rosak :',
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                      TextFormField(
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
                        textInputAction: TextInputAction.next,
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
                  String menu = myController.text;
                  int bawa = 0;
                  int baki = 0;
                  int rosak = 0;
                  // Handle the submit action
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    bawa = myController1.text.totalIntNumber();
                    if (!(myController2.text.isEmpty)) {
                      baki = myController2.text.totalIntNumber();
                    }
                    if (!(myController3.text.isEmpty)) {
                      rosak = myController3.text.totalIntNumber();
                    }
                    if (!_rekodMenu.keys.contains(menu)) {
                      _rekodMenu[menu] = {
                        "bawa": bawa,
                        'baki': baki,
                        'rosak': rosak,
                      };
                    } else {
                      var value = _rekodMenu[menu];
                      value["bawa"] = bawa;
                      value["baki"] = baki;
                      value["rosak"] = rosak;
                      _rekodMenu[menu] = value;
                    }
                    kiraJualan();
                  }
                  // Handle the submit action
                },
              ),
            ],
          );
        },
      );
    }
  }

  void kiraJualan() {
    num jumlahJualan = 0.00;
    int jumlahSatay = 0;
    num rugi = 0.00;
    print("start rekod kira >>> $_rekodMenu");
    if (_rekodMenu.isNotEmpty) {
      for (var menu in _rekodMenu.keys) {
        var value = _rekodMenu[menu];
        int bawa = value["bawa"] ?? 0;
        int baki = value["baki"] ?? 0;
        int rosak = value["rosak"] ?? 0;
        int jualan = bawa - baki - rosak;
        num harga = 0.0;
        num kira = 0.0;
        harga = listHarga[menu];
        print("rekod>>> $menu > $value >> $harga");
        jumlahSatay = jumlahSatay + jualan;
        kira = jualan * harga;
        jumlahJualan = jumlahJualan + kira;
        rugi = rugi + (rosak * harga);
        print("rekod kira >>> $jumlahSatay | $harga | $jumlahJualan");
      }
    }
    _rekodCawanganDetail?.rugi = rugi;
    _rekodCawanganDetail?.rekodMenu = _rekodMenu;
    _rekodCawanganDetail?.jumlahSatay = jumlahSatay;
    _rekodCawanganDetail?.jumlahJualan = jumlahJualan;

    insertServer(_rekodCawanganDetail as rekodCawanganDetail);
    // addItemSelected();
  }

  // addItem adds our User Class item to list.
  void addItemSelected() {
    if (_rekodBayaranCawangan.isNotEmpty) {
      // Total bayaran
      num jumlahBayaranSemua = 0.0;

      for (var current in _rekodBayaranCawangan) {
        print("rekod >>> ${current.tarikh} + ${current.bayaran}");
        jumlahBayaranSemua += current.bayaran;
      }

      num bakiBayaran = jumlahBayaranSemua;

      for (var current in selectDetailCawangan) {
        num jumlahJualan = current.jumlahJualan;

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
      }
    }
  }

  Future<void> insertServer(rekodCawanganDetail usr) async {
    await insertUpdateTable('Cawangan Detail Rekod', usr.toMapServer(), id: id);
    var target = rekod_Cawangan.elementAt(
      rekod_Cawangan.indexWhere((e) => e.id == cawanganId),
    );
    setState(() {
      target.rekod = selectDetailCawangan;
    });
    saveData();
  }

  void removeItemSelected(String menu) {
    _rekodMenu.remove(menu);
    kiraJualan();
  }

  // This block saves our list locally.
  void saveData() {
    updateStok(tarikh);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Simpan Data')));
    // loadData();
  }
}

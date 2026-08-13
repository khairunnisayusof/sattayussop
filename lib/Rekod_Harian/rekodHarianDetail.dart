import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../DocumentHelper.dart';
import 'package:notification_center/notification_center.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class selectRekodHarianDetail extends StatefulWidget {
  const selectRekodHarianDetail({
    super.key,
    required this.selectIndex,
    required this.selectedHarian,
  });

  final int selectIndex;
  final int selectedHarian;

  @override
  State<selectRekodHarianDetail> createState() =>
      _selectRekodHarianDetailState();
}

class _selectRekodHarianDetailState extends State<selectRekodHarianDetail> {
  int selectIndex = 0;
  int selectedHarian = 0;
  String tarikh = "";
  String namaPasarMalam = "";
  List<rekodHarianDetail> selectDetailHarian = <rekodHarianDetail>[];
  rekodList? rekodHarians;
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

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
      colorBorder = Colors.white;
    }
    NotificationCenter().subscribe('refreshData', _refreshView);
    selectIndex = widget.selectIndex;
    selectedHarian = widget.selectedHarian;
    _refreshView(false);
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

      rekodHarians = rekod_List.elementAt(selectedHarian);
      tarikh = rekodHarians?.tarikh ?? "";

      selectDetailHarian = List<rekodHarianDetail>.from(rekodHarians?.rekod ?? []).toList();
      selectDetailHarian.sort((a, b) => a.id.compareTo(b.id));
      if (selectDetailHarian.isNotEmpty &&
          selectIndex < selectDetailHarian.length) {
        rekodHarianDetail current = selectDetailHarian.elementAt(selectIndex);

        namaPasarMalam = current.namaPasarMalam;
        _rekodMenu = sortMenu(current.rekodMenu);
      }});
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
    rekodHarianDetail current = selectDetailHarian.elementAt(selectIndex);
    print("list >> $current");
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
                      ' ${rekodHarians?.hari}',
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
                      ' ${rekodHarians?.tarikh}',
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
                      1: FixedColumnWidth(60),
                      2: FixedColumnWidth(60),
                      3: FixedColumnWidth(60),
                      4: FixedColumnWidth(60),
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
                          Container(
                            child: Center(
                              child: Text(
                                'Masak',
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
                      var masak = value['masak'] ?? 0;
                      var rosak = value['rosak'] ?? 0;
                      if (menu.toLowerCase().contains('nasi')) {
                        return GestureDetector(
                          child: Table(
                            border: TableBorder.all(color: colorBorder),
                            columnWidths: const <int, TableColumnWidth>{
                              0: FlexColumnWidth(),
                              1: FixedColumnWidth(60),
                              2: FixedColumnWidth(60),
                              3: FixedColumnWidth(60),
                              4: FixedColumnWidth(60),
                            },
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: <TableRow>[
                              TableRow(
                                children: <Widget>[
                                  SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: Text(
                                        menu,
                                        style: textStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: Text(
                                        '$bawa',
                                        style: textStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: Text(
                                        '$baki',
                                        style: textStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: Text(
                                        '$rosak',
                                        style: textStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                    child: Center(
                                      child: Text(
                                        '',
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
                        );
                      } else {
                        return GestureDetector(
                          child: Table(
                            border: TableBorder.all(color: colorBorder),
                            columnWidths: const <int, TableColumnWidth>{
                              0: FlexColumnWidth(),
                              1: FixedColumnWidth(60),
                              2: FixedColumnWidth(60),
                              3: FixedColumnWidth(60),
                              4: FixedColumnWidth(60),
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
                                  SizedBox(
                                    height: 50,
                                    child: Center(
                                      child: Text(
                                        '$masak',
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
                        );
                      }
                      // }
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
                      'Jualan Nasi Himpit',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    trailing: Text(
                      '${current.jualanNS}',
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
                      'Beli Barang (RM)',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    trailing: Text(
                      money(current.barang),
                      style: textStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  ListTile(
                    minTileHeight: 1.0,
                    minVerticalPadding: 16,
                    leading: Text(
                      'Pendapatan Jualan (RM)',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    trailing: Text(
                      money(current.pendapatanJualan),
                      style: textStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  ListTile(
                    minTileHeight: 1.0,
                    minVerticalPadding: 16,
                    leading: Text(
                      'Pendapatan QR (RM)',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    trailing: Text(
                      money(current.pendapatanQR),
                      style: textStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  ListTile(
                    minTileHeight: 1.0,
                    minVerticalPadding: 16,
                    leading: Text(
                      'Pendapatan Sebenar (RM)',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    trailing: Text(
                      money(current.pendapatanSebenar),
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
                      money(current.kerugian),
                      style: textStyle,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialogEditRequired(context, "Masukkan Data");
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(color),
                    ),
                    child: Text(
                      'Pendapatan',
                      style: textStyleBtn,
                      textAlign: TextAlign.center,
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
        title: Text(namaPasarMalam, style: TextStyle(color: Colors.white)),
        actions: <Widget>[],
        centerTitle: true,
      ),
      body: buildCollectionView,
    );
  }

  void showDialogEditRequired(BuildContext context, String title) {
    var myController = TextEditingController();
    var myController2 = TextEditingController();
    var myController3 = TextEditingController();
    String errorText = "Sila masukkan beberapa digit";
    final formKey = GlobalKey<FormState>();
    rekodHarianDetail current = selectDetailHarian.elementAt(selectIndex);
    num barang = current.barang;
    num pendapatanJualan = current.pendapatanJualan;
    num pendapatanQR = current.pendapatanQR;
    if (barang > 0.0) {
      myController.text = "$barang";
    }
    if (pendapatanJualan > 0.0) {
      myController2.text = "$pendapatanJualan";
    }
    if (pendapatanQR > 0.0) {
      myController3.text = "$pendapatanQR";
    }
    // declare a variable to keep track of the input text
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
                      'Beli Barang :',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    TextFormField(
                      // The validator receives the text that the user has entered.
                      autofocus: true,
                      controller: myController,
                      decoration: InputDecoration(),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-*/.]')),
                      ],
                      textInputAction:
                      TextInputAction.next, // Moves focus to next.
                    ),
                    Container(height: 2),
                    Text(
                      'Pendapatan Jualan :',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    TextFormField(
                      // The validator receives the text that the user has entered.
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return errorText;
                      //   }
                      //   return null;
                      // },
                      autofocus: true,
                      controller: myController2,
                      decoration: InputDecoration(),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-*/.]')),
                      ],
                      textInputAction:
                      TextInputAction.next, // Moves focus to next.
                    ),
                    Container(height: 2),
                    Text(
                      'Pendapatan QR :',
                      style: textStyle,

                      textAlign: TextAlign.left,
                    ),
                    TextFormField(
                      // The validator receives the text that the user has entered.
                      autofocus: true,
                      controller: myController3,
                      decoration: InputDecoration(),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-*/.]')),
                      ],
                      textInputAction:
                      TextInputAction.done, // Moves focus to next.
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
                double barang = 0.00;
                double pendapatanJualan = 0.00;
                double pendapatanQR = 0.00;
                // if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                if (!(myController.text.isEmpty)) {
                  barang = myController.text.totalDoubleNumber();
                }
                if (!(myController2.text.isEmpty)) {
                  pendapatanJualan = myController2.text.totalDoubleNumber();
                }
                if (!(myController3.text.isEmpty)) {
                  pendapatanQR = myController3.text.totalDoubleNumber();
                }
                rekodHarianDetail current = selectDetailHarian.elementAt(
                  selectIndex,
                );
                current.barang = barang;
                current.pendapatanJualan = pendapatanJualan;
                current.pendapatanQR = pendapatanQR;
                kiraJualanHarian();
                // }
                // Handle the submit action
              },
            ),
          ],
        );
      },
    );
  }

  void showDialogTextRequired(BuildContext context, String title, int index) {
    String menu = _rekodMenu.keys.elementAt(index);
    var myController = TextEditingController();
    var myController2 = TextEditingController();
    var myController3 = TextEditingController();
    var myController4 = TextEditingController();
    String errorText = "Sila masukkan beberapa digit";
    final formKey = GlobalKey<FormState>();
    var bawa = _rekodMenu[menu]["bawa"] ?? 0;
    var baki = _rekodMenu[menu]["baki"] ?? 0;
    var rosak = _rekodMenu[menu]["rosak"] ?? 0;
    var masak = _rekodMenu[menu]["masak"] ?? 0;
    if (bawa > 0) {
      myController.text = "$bawa";
    }
    if (baki > 0) {
      myController2.text = "$baki";
    }
    if (rosak > 0) {
      myController3.text = "$rosak";
    }
    if (masak > 0) {
      myController4.text = "$masak";
    }
    if (menu.toLowerCase().contains("nasi")) {
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
                        'Bawa :',
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                      TextFormField(
                        // The validator receives the text that the user has entered.
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return errorText;
                        //   }
                        //   return null;
                        // },
                        autofocus: true,
                        controller: myController,
                        decoration: InputDecoration(),
                        keyboardType: TextInputType.phone,
                        textInputAction:
                        TextInputAction.next, // Moves focus to next.
                      ),
                      Container(height: 2),
                      Text(
                        'Baki :',
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                      TextFormField(
                        // The validator receives the text that the user has entered.
                        autofocus: true,
                        controller: myController2,
                        decoration: InputDecoration(),
                        keyboardType: TextInputType.phone,
                        textInputAction:
                        TextInputAction.next, // Moves focus to next.
                      ),
                      Container(height: 2),
                      Text(
                        'Rosak :',
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                      TextFormField(
                        // The validator receives the text that the user has entered.
                        autofocus: true,
                        controller: myController3,
                        decoration: InputDecoration(),
                        keyboardType: TextInputType.phone,
                        textInputAction:
                        TextInputAction.next, // Moves focus to next.
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
                  var value = _rekodMenu[menu];
                  int bawa = 0;
                  int baki = 0;
                  int rosak = 0;
                  // Handle the submit action
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    if (!(myController.text.isEmpty)) {
                      bawa = myController.text.totalIntNumber();
                    }
                    if (!(myController2.text.isEmpty)) {
                      baki = myController2.text.totalIntNumber();
                    }
                    if (!(myController3.text.isEmpty)) {
                      rosak = myController3.text.totalIntNumber();
                    }
                    value["bawa"] = bawa;
                    value["baki"] = baki;
                    value["rosak"] = rosak;
                    int jualan = bawa - baki - rosak;
                    value["jualan"] = jualan;
                    _rekodMenu[menu] = value;
                    kiraJualanHarian();
                  }
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
                        'Bawa :',
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                      TextFormField(
                        // The validator receives the text that the user has entered.
                        // validator: (value) {
                        //   if (value == null || value.isEmpty) {
                        //     return errorText;
                        //   }
                        //   return null;
                        // },
                        autofocus: true,
                        controller: myController,
                        keyboardType: TextInputType.phone,
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
                        keyboardType: TextInputType.phone,
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
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        // Moves focus to next.
                        decoration: InputDecoration(),
                      ),
                      Container(height: 2),
                      Text(
                        'Masak :',
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                      TextFormField(
                        autofocus: true,
                        controller: myController4,
                        keyboardType: TextInputType.phone,
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
                  var value = _rekodMenu[menu];
                  int bawa = 0;
                  int baki = 0;
                  int rosak = 0;
                  int masak = 0;
                  // Handle the submit action
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    if (!(myController.text.isEmpty)) {
                      bawa = myController.text.totalIntNumber();
                    }
                    if (!(myController2.text.isEmpty)) {
                      baki = myController2.text.totalIntNumber();
                    }
                    if (!(myController3.text.isEmpty)) {
                      rosak = myController3.text.totalIntNumber();
                    }
                    if (!(myController4.text.isEmpty)) {
                      masak = myController4.text.totalIntNumber();
                    }
                    value["bawa"] = bawa;
                    value["baki"] = baki;
                    value["rosak"] = rosak;
                    value["masak"] = masak;
                    int jualan = bawa - baki - rosak - masak;
                    value["jualan"] = jualan;
                    _rekodMenu[menu] = value;
                    kiraJualanHarian();
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

  void kiraJualanHarian() {
    double jumlahJualan = 0.00;
    int jumlahSatay = 0;
    int jumlahNS = 0;
    print("start rekod kira >>> $_rekodMenu");
    rekodHarianDetail currentDetail = selectDetailHarian.elementAt(selectIndex);
    setState(() {
      for (var menu in _rekodMenu.keys) {
        var value = _rekodMenu[menu];
        int jualan = value["jualan"] ?? 0;
        num harga = 0.0;
        num kira = 0.0;
        var indexMenu =
            rekod_Menu[rekod_Menu.indexWhere(
              (element) => element.jenis == menu,
            )];
        harga = indexMenu.Harga;
        if (menu.toLowerCase().contains("nasi")) {
          jumlahNS = jumlahNS + jualan;
          kira = jualan * harga;
        } else {
          jumlahSatay = jumlahSatay + jualan;
          kira = jualan * harga;
        }
        jumlahJualan = jumlahJualan + kira;
        print(
          "rekod kira >>> $jumlahSatay | $harga | $jumlahJualan | $jumlahNS",
        );
      }
      num barang = currentDetail.barang;
      num pendapatanJualan = currentDetail.pendapatanJualan;
      num pendapatanQR = currentDetail.pendapatanQR;
      num pendapatan = pendapatanJualan + pendapatanQR;
      num pendapatanSebenar = jumlahJualan - barang;
      num kerugian = pendapatanSebenar - pendapatan;
      currentDetail.rekodMenu = _rekodMenu;
      currentDetail.jumlahSatay = jumlahSatay;
      currentDetail.jualanNS = jumlahNS;
      currentDetail.jumlahJualan = jumlahJualan;
      currentDetail.pendapatanSebenar = pendapatanSebenar;
      currentDetail.kerugian = kerugian;
    });
    updateDataTable(currentDetail);
    // updateData();
  }

  void removeItemSelected(String menu) {
    _rekodMenu.remove(menu);
    kiraJualanHarian();
  }

  Future<void> updateDataTable(rekodHarianDetail detail) async {
    insertUpdateTable(supabaseHarianDetail, detail.toMapServer(), id: detail.id);
    setState(() {
      saveData();
    });
  }

  void updateData() {
    List<String> rekodList = selectDetailHarian
        .map((item) => jsonEncode(item.toMap()))
        .toList();
    var target = rekod_List.elementAt(selectedHarian);
    print("update data ");
    setState(() {
      target.rekod = selectDetailHarian;
      saveData();
    });
  }

  // This block saves our list locally.
  void saveData() {
      saveDataLocal();
      refreshAllStok(tarikh);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Simpan Data')));
  }
}

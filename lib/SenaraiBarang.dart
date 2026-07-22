import 'package:flutter/material.dart';
import 'package:notification_center/notification_center.dart';
import 'package:sattayussop/supabaseServer.dart';
import "../DocumentHelper.dart";
import '../databaseLocal.dart';
import 'package:string_capitalize/string_capitalize.dart';

class selectSenaraiBarang extends StatefulWidget {
  const selectSenaraiBarang({super.key});

  @override
  State<selectSenaraiBarang> createState() => _selectSenaraiBarangState();
}

class _selectSenaraiBarangState extends State<selectSenaraiBarang> {
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  TextStyle textStyle = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
  TextStyle textStyleNormal = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.normal,
  );
  bool dark = sharedPreferences?.getBool("darkModeStatus") ?? false;
  Color color = Colors.orange;
  Color colorBorder = Colors.black;

  @override
  void initState() {
    NotificationCenter().subscribe('refreshData', _refreshView);
    if (dark) {
      color = Colors.deepOrange;
      colorBorder = Colors.white;
    }
    loadData();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    if (!mounted) return;
    // Clean up the controller when the widget is disposed.
    loadDataServer();
    super.dispose();
  }

  void _refreshView(bool refresh) {
    setState(() {
      senarai_Barang.sort((a, b) => a.nama.compareTo(b.nama));
    });
  }

  @override
  Widget build(BuildContext context) {
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
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
                      height: 30,
                      child: Center(
                        child: Text(
                          'Barang',
                          style: textStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                      child: Center(
                        child: Text(
                          'Unit',
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
              itemCount: senarai_Barang.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                rekodBarang current = senarai_Barang.elementAt(index);
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
                                current.nama,
                                style: textStyleNormal,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                current.unit,
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
                    showDialogTextRequired(context, "Masukkan Data", index);
                  },
                );
              },
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
            //   child: Text(""),
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
        title: Text("Senarai Barang", style: TextStyle(color: Colors.white)),
        actions: <Widget>[],
        centerTitle: true,
      ),
      body: buildCollectionView,
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialogTextRequired(context, "Masukkan Data", -1);
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

  void showDialogTextRequired(BuildContext context, String title, int index) {
    var myController = TextEditingController();
    var myController2 = TextEditingController();
    String errorText = "Sila masukkan beberapa digit";
    final formKey = GlobalKey<FormState>();
    if (index >= 0) {
      rekodBarang current = senarai_Barang.elementAt(index);
      myController.text = current.nama;
      myController2.text = current.unit;
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
                      'Barang :',
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
                      controller: myController,
                      textInputAction: TextInputAction.next,
                      // Moves focus to next.
                      decoration: InputDecoration(),
                    ),
                    Text('Unit :', style: textStyle, textAlign: TextAlign.left),
                    TextFormField(
                      autofocus: true,
                      controller: myController2,
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
                // Handle the submit action
                String nama = myController.text.capitalizeEach();
                String unit = myController2.text;
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  insertItem(rekodBarang(nama, unit), index);
                }
                // Handle the submit action
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> insertItem(rekodBarang barang, int index) async {
    if (index >= 0) {
      var id = senarai_Barang[index].id;
      barang.id = id;
      insertUpdateTable('Senarai Barang Rekod', barang.toMapServer(), id: id);
    } else {
      if (!senarai_Barang.map((item) => item.nama).contains(barang.nama)) {
        insertUpdateTable('Senarai Barang Rekod', barang.toMapServer());
      }
    }
    addItem(barang, index);
  }

  // addItem adds our User Class item to list.
  void addItem(rekodBarang usr, int index) {
    if (index >= 0) {
      senarai_Barang[senarai_Barang.indexWhere(
            (element) => element.id == usr.id,
          )] =
          usr;
    } else {
      senarai_Barang.add(usr);
    }
    saveData();
  }

  void removeItemInServer(int index) {
    var id = senarai_Barang[index].id;
    deleteRow('Senarai Barang Rekod', id);
    removeItem(index);
  }

  void removeItem(int index) {
    senarai_Barang.removeAt(index);
    saveData();
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
  }
}

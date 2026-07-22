import 'package:flutter/material.dart';
import 'package:notification_center/notification_center.dart';
import "../DocumentHelper.dart";
import 'package:string_capitalize/string_capitalize.dart';
import '../databaseLocal.dart';
import 'supabaseServer.dart';

class selectRekodMenu extends StatefulWidget {
  const selectRekodMenu({super.key});

  @override
  State<selectRekodMenu> createState() => _selectRekodMenuState();
}

class _selectRekodMenuState extends State<selectRekodMenu> {
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
    if (!mounted) return;

    print("rekod menu >> $rekod_Menu");
    setState(() {});
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
                      height: 40,
                      child: Center(
                        child: Text(
                          'Menu',
                          style: textStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          'Harga (RM)',
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
              itemCount: rekod_Menu.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                rekodMenu current = rekod_Menu.elementAt(index);
                print("rekod >>> $current");
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
                                current.jenis.capitalizeEach(),
                                style: textStyleNormal,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                money(current.Harga),
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
        title: Text("Rekod Menu", style: TextStyle(color: Colors.white)),
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
                removeItem(index);
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
      rekodMenu current = rekod_Menu.elementAt(index);
      myController.text = current.jenis;
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
                        'Jenis Menu :',
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
                        'Harga :',
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
                        controller: myController2,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
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
                  num harga = 0.00;
                  // Handle the submit action
                  String namaMenu = myController.text.capitalizeEach();
                  if (!namaMenu.contains(" ") &&
                      !namaMenu.toLowerCase().contains("satay")) {
                    namaMenu = 'Satay $namaMenu'.capitalizeEach();
                  }
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    if (!(myController2.text.isEmpty)) {
                      harga = myController2.text.totalDoubleNumber();
                    }
                    insertItem(rekodMenu(namaMenu, harga), index);
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
                        'Jenis Menu :',
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
                      Container(height: 2),
                      Text(
                        'Harga :',
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
                        controller: myController2,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.done,
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
                  double harga = 0;
                  // Handle the submit action
                  String namaMenu = myController.text.capitalizeEach();
                  if (!namaMenu.contains(" ") &&
                      !namaMenu.toLowerCase().contains("satay")) {
                    namaMenu = 'Satay $namaMenu'.capitalizeEach();
                  }
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    if (!(myController2.text.isEmpty)) {
                      harga = myController2.text.totalDoubleNumber();
                    }
                    insertItem(rekodMenu(namaMenu, harga), index);
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

  Future<void> insertItem(rekodMenu menu, int index) async {
    if (index >= 0) {
      var id = rekod_Menu[index].id;
      menu.id = id;
      insertUpdateTable('Menu Rekod', menu.toMapServer(), id: id);
    } else {
      insertUpdateTable('Menu Rekod', menu.toMapServer());
    }
    addItem(menu, index);
  }

  // addItem adds our User Class item to list.
  void addItem(rekodMenu usr, int index) {
    final index = rekod_Menu.indexWhere((e) => e.jenis == usr.jenis);
    index == -1 ? rekod_Menu.add(usr) : rekod_Menu[index] = usr;
    saveData();
  }

  void removeItem(int index) {
    var id = rekod_Menu[index].id;
    deleteRow('Menu Rekod', id);
    removeInLocal(index);
  }

  void removeInLocal(int index) {
    rekod_Menu.removeAt(index);
    saveData();
  }

  // This block saves our list locally.
  Future<void> saveData() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Simpan Data')));
    saveDataLocal();
  }
}

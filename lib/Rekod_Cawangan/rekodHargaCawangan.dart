import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:notification_center/notification_center.dart';
import "package:sattayussop/DocumentHelper.dart";
import 'package:string_capitalize/string_capitalize.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class selectRekodHargaCawangan extends StatefulWidget {
  const selectRekodHargaCawangan({
    super.key,
    required this.selectedCawangan,
    required this.menuList,
  });

  final int selectedCawangan;
  final List<rekodMenu> menuList;

  @override
  State<selectRekodHargaCawangan> createState() =>
      _selectRekodHargaCawanganState();
}

class _selectRekodHargaCawanganState extends State<selectRekodHargaCawangan> {
  int selectedCawangan = 0;
  int cawanganID = -1;
  List<rekodMenu> menuList = <rekodMenu>[];
  String nama = "";
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  Map<String, dynamic> listHarga = <String, dynamic>{};
  TextStyle textStyle = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
  TextStyle textStyleNormal = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.normal,
  );
  bool dark = sharedPreferences?.getBool("darkModeStatus") ?? false;
  Color color = Colors.orange;
  List<DropdownMenuItem> dropDownListMenu = <DropdownMenuItem>[];

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
    }
    selectedCawangan = widget.selectedCawangan;
    menuList = widget.menuList;
    NotificationCenter().subscribe('refreshData', _refreshView);
    print("items = ${menuList.map((e) => e.jenis).toList()}");
    for (var index = 0; index < menuList.length; index++) {
      rekodMenu list = menuList.elementAt(index);
      var nama = list.jenis;
      print(
        "list record >> $nama ${DropdownMenuItem<String>(value: nama, child: Text(nama))}",
      );
      dropDownListMenu.add(
        DropdownMenuItem<String>(value: nama, child: Text(nama)),
      );
    }
    rekodCawangan current = rekod_Cawangan.elementAt(selectedCawangan);
    cawanganID = current.id;
    nama = current.nama;
    listHarga = sortMenu(current.rekodHarga);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (listHarga.isEmpty) {
        showDialogTextRequired(context, "Masukkan Data", -1);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
  }
  void _refreshView(bool refresh) {
    setState(() {
      rekodCawangan current = rekod_Cawangan.elementAt(
        rekod_Cawangan.indexWhere((item) => item.nama == nama),
      );
      if (cawanganID < 0) {
        cawanganID = current.id;
      }
      listHarga = sortMenu(current.rekodHarga);
    });
  }

  @override
  Widget build(BuildContext context) {
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.only(top: 5),
      child: ListView.builder(
        itemCount: listHarga.length,
        itemBuilder: (BuildContext context, int index) {
          String menu = listHarga.keys.elementAt(index);
          num Harga = listHarga[menu] ?? {};
          return GestureDetector(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ListTile(
                  leading: Text(
                    '${menu.capitalizeEach()} : ',
                    style: textStyle,
                    textAlign: TextAlign.left,
                  ),
                  trailing: Text(
                    'RM ${money(Harga)}',
                    style: textStyleNormal,
                    textAlign: TextAlign.right,
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
              showDialogTextRequired(context, "Masukkan Data", index);
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
        title: Text("Harga $nama", style: TextStyle(color: Colors.white)),
        actions: <Widget>[settingButton],
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
                var nama = listHarga.keys.toList().elementAt(index);
                removeItem(nama);
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
    final initialValue =
        dropDownListMenu.any((e) => e.value == myController.text)
        ? myController.text
        : null;

    if (index >= 0) {
      String current = listHarga.keys.elementAt(index);
      num Harga = listHarga[current];
      myController.text = "$Harga";
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
                  num harga0 = 0;
                  // Handle the submit action
                  String namaMenu = myController.text.capitalizeEach();
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    if (!(myController2.text.isEmpty)) {
                      harga0 = myController2.text.toDoubleNumberFormat();
                    }
                    addItem(namaMenu, harga0);
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
                      DropdownButtonFormField(
                        isExpanded: true,
                        initialValue: initialValue,
                        onChanged: (item) {
                          myController.text = item ?? "";
                        },
                        items: dropDownListMenu,
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
                  num harga = 0;
                  // Handle the submit action
                  String namaMenu = myController.text.capitalizeEach();
                  if (formKey.currentState!.validate()) {
                    Navigator.of(context).pop();
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    if (!(myController2.text.isEmpty)) {
                      harga = myController2.text.toDoubleNumberFormat();
                    }
                    addItem(namaMenu, harga);
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

  Future<void> addItem(String nama, num harga) async {
    var target = rekod_Cawangan[selectedCawangan];
    setState(() {
      listHarga[nama] = harga;
      target.rekodHarga = listHarga;
    });
    print("save record >> ${target.id} | $cawanganID");
    if (cawanganID >= 0) {
      await insertUpdateTable(
        'Cawangan Rekod',
        target.toMapServer(),
        id: cawanganID,
      );
    } else {
      await insertUpdateTable('Cawangan Rekod', target.toMapServer());
    }

    saveData();
  }

  void removeItem(String nama) {
    listHarga.remove(nama);
    var targetManu = rekod_Cawangan[selectedCawangan];
    setState(() {
      targetManu.rekodHarga = listHarga;
    });
    saveData();
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Simpan Data')));
    // loadData();
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import "package:sattayussop/DocumentHelper.dart";
import 'package:string_capitalize/string_capitalize.dart';
import 'package:notification_center/notification_center.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class selectRekodPekerja extends StatefulWidget {
  const selectRekodPekerja({super.key});

  @override
  State<selectRekodPekerja> createState() => _selectRekodPekerjaState();
}

class _selectRekodPekerjaState extends State<selectRekodPekerja> {
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  TextStyle textStyle = TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold);
  TextStyle textStyleNormal = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.normal,
  );
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
  bool dark = sharedPreferences?.getBool("darkModeStatus") ?? false;
  Color color = Colors.orange;
  Color background = Colors.white;
  Color textColor = Colors.black;
  final List<String> _rekodPekerjaView = <String>[];
  String titleFilter = "Senarai Semua Pekerja";
  bool filterCucuk = false;
  bool filterPekerja = false;
  List<DropdownMenuItem> dropDownList = <DropdownMenuItem>[];
  List<String> roleList = ["Admin", "Pekerja", "Manager"];

  @override
  void initState() {
    if (!mounted) return;
    if (dark) {
      color = Colors.deepOrange;
      background = Colors.black12;
      textColor = Colors.white;
    }
    refreshData();
    for (var index = 0; index < roleList.length; index++) {
      var role = roleList[index];
      dropDownList.add(
        DropdownMenuItem<String>(
          value: role.isEmpty == true ? null : role,
          child: Text(role),
        ),
      );
    }
    NotificationCenter().subscribe('refreshData', _refreshView);
    loadData();
    super.initState();
  }

  @override
  void dispose() {
    if (!mounted) return;
    // Clean up the controller when the widget is disposed.
    loadDataServer();
    super.dispose();
  }

  void _refreshView(bool refresh) {
    setState(() {
      refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.zero,
              child: ExpansionTile(
                title: Text(titleFilter),
                children: <Widget>[
                  Divider(thickness: 1, height: 10, color: Colors.grey),
                  ListTile(
                    leading: Text(
                      "Filter Pekerja : ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    title: DropdownButtonFormField(
                      elevation: 8,
                      isExpanded: true,
                      onChanged: (item) {
                        setState(() {
                          if (item == '1') {
                            filterCucuk = false;
                            filterPekerja = false;
                            titleFilter = "Senarai Semua Pekerja";
                          } else if (item == '2') {
                            filterCucuk = true;
                            filterPekerja = false;
                            titleFilter = "Senarai Cucuk Satay";
                          } else if (item == '3') {
                            filterCucuk = false;
                            filterPekerja = true;
                            titleFilter = "Senarai Pekerja Satay";
                          }
                          refreshData();
                        });
                      },
                      hint: Text('Senarai Pekerja'),
                      items: [
                        DropdownMenuItem<String>(
                          value: "1",
                          child: Text("Semua Pekerja"),
                        ),
                        DropdownMenuItem<String>(
                          value: "2",
                          child: Text("Cucuk Satay"),
                        ),
                        DropdownMenuItem<String>(
                          value: "3",
                          child: Text("Pekerja Satay"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _rekodPekerjaView.length,
                itemBuilder: (BuildContext context, int index) {
                  String nama = _rekodPekerjaView.elementAt(index);
                  rekodPekerja current =
                      rekod_Pekerja[rekod_Pekerja.indexWhere(
                        (element) => element.username == nama,
                      )];
                  return GestureDetector(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(5),
                          alignment: Alignment.centerLeft,
                          height: 25,
                          color: Colors.transparent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                current.nama.capitalizeEach(),
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ],
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
                      showDialogTextRequired(
                        context,
                        "Masukkan Data Pekerja",
                        index,
                      );
                    },
                  );
                },
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
        title: Text("Rekod Pekerja", style: TextStyle(color: Colors.white)),
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
    var myController3 = TextEditingController();
    var myController4 = TextEditingController();
    var myController5 = TextEditingController();
    var myController6 = TextEditingController();
    var myController7 = TextEditingController();
    var myController8 = TextEditingController();
    String errorText = "Sila masukkan nama anda";
    final formKey = GlobalKey<FormState>();
    bool cucukSatay = false;
    bool accessApps = false;
    String role = 'Pekerja';
    if (index >= 0) {
      String nama = _rekodPekerjaView.elementAt(index);
      int indexSelected = rekod_Pekerja.indexWhere(
        (element) => element.username == nama,
      );
      rekodPekerja current = rekod_Pekerja.elementAt(indexSelected);
      cucukSatay = current.cucuk;
      accessApps = current.aktif;
      if (current.nama.isNotEmpty) {
        myController.text = current.nama;
      }
      if (current.namaPenuh.isNotEmpty) {
        myController2.text = current.namaPenuh;
      }
      if (current.ic.isNotEmpty) {
        myController3.text = current.ic;
      }
      if (current.bank.isNotEmpty) {
        myController4.text = current.bank;
      }
      if (current.noBank.isNotEmpty) {
        myController5.text = current.noBank;
      }
      if (current.gajiHarian > 0) {
        myController6.text = "${current.gajiHarian}";
      }
      if (current.gajiSimpan > 0) {
        myController7.text = "${current.gajiSimpan}";
      }
      if (current.role.isNotEmpty) {
        role = current.role;
      }
    }
    myController8.text = role.capitalize();
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
                        TextFormField(
                          // The validator receives the text that the user has entered.
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return errorText;
                            }
                            return null;
                          },
                          // enableInteractiveSelection: false,
                          // enabled:  (index >= 0) ? false : true,
                          // autofocus: (index >= 0) ? false : true,
                          autofocus: true,
                          controller: myController,
                          decoration: InputDecoration(),
                          textInputAction:
                              TextInputAction.next, // Moves focus to next.
                        ),
                        Text(
                          'Nama Penuh :',
                          style: textStyle,
                          textAlign: TextAlign.left,
                        ),
                        TextFormField(
                          autofocus: false,
                          controller: myController2,
                          decoration: InputDecoration(),
                          textInputAction:
                              TextInputAction.done, // Moves focus to next.
                        ),
                        Text(
                          'Kad Pengenalan :',
                          style: textStyle,
                          textAlign: TextAlign.left,
                        ),
                        TextFormField(
                          autofocus: false,
                          controller: myController3,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(),
                          textInputAction:
                              TextInputAction.done, // Moves focus to next.
                        ),
                        Text(
                          'Nama Bank :',
                          style: textStyle,
                          textAlign: TextAlign.left,
                        ),
                        TextFormField(
                          autofocus: false,
                          controller: myController4,
                          decoration: InputDecoration(),
                          textInputAction:
                              TextInputAction.done, // Moves focus to next.
                        ),
                        Text(
                          'Nombor Akaun :',
                          style: textStyle,
                          textAlign: TextAlign.left,
                        ),
                        TextFormField(
                          autofocus: false,
                          controller: myController5,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(),
                          textInputAction:
                              TextInputAction.done, // Moves focus to next.
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'Cucuk Satay :',
                              style: textStyle,
                              textAlign: TextAlign.left,
                            ),
                            Switch(
                              value: cucukSatay,
                              onChanged: (value) {
                                setState(() {
                                  cucukSatay = value;
                                });
                              },
                              activeThumbColor: color,
                            ),
                          ],
                        ),
                        Text(
                          'Gaji Harian :',
                          style: textStyle,
                          textAlign: TextAlign.left,
                        ),
                        TextFormField(
                          autofocus: true,
                          controller: myController6,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(),
                          textInputAction:
                              TextInputAction.done, // Moves focus to next.
                        ),
                        !cucukSatay
                            ? Text(
                                'Gaji Simpan :',
                                style: textStyle,
                                textAlign: TextAlign.left,
                              )
                            : SizedBox.fromSize(),
                        !cucukSatay
                            ? TextFormField(
                                autofocus: true,
                                controller: myController7,
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: InputDecoration(),
                                textInputAction: TextInputAction
                                    .done, // Moves focus to next.
                              )
                            : SizedBox.fromSize(),
                        Text(
                          'Role Login :',
                          style: textStyle,
                          textAlign: TextAlign.left,
                        ),
                        DropdownButtonFormField(
                          isExpanded: true,
                          initialValue: myController8.text,
                          onChanged: (item) {
                            role = item;
                            myController8.text = role.capitalize();
                          },
                          items: dropDownList,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'Akses Sistem :',
                              style: textStyle,
                              textAlign: TextAlign.left,
                            ),
                            Switch(
                              value: accessApps,
                              onChanged: (value) {
                                setState(() {
                                  accessApps = value;
                                });
                              },
                              activeThumbColor: color,
                            ),
                          ],
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
                print("nama >> ${myController.text}");
                String nama = myController.text.capitalizeEach();
                String namaPenuh = myController2.text.capitalizeEach();
                String ic = myController3.text;
                String bank = myController4.text;
                String akaun = myController5.text;
                double gajiHarian = 0.000;
                double gajiSimpan = 0.000;

                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  if (namaPenuh.isEmpty && nama.isNotEmpty) {
                    namaPenuh = nama;
                  }
                  if (!(myController6.text.isEmpty)) {
                    gajiHarian = myController6.text.totalDoubleNumber();
                  }
                  if (!(myController7.text.isEmpty)) {
                    gajiSimpan = myController7.text.totalDoubleNumber();
                  }
                  List<dynamic> rekod = <rekodAmbilGaji>[];
                  insertItem(
                    rekodPekerja(
                      nama,
                      namaPenuh,
                      ic,
                      bank,
                      akaun,
                      gajiHarian,
                      gajiSimpan,
                      cucukSatay,
                      role,
                      accessApps,
                      rekod,
                    ),
                    index,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void refreshData() {
    _rekodPekerjaView.clear();
    for (var i = 0; i < rekod_Pekerja.length; i++) {
      rekodPekerja current = rekod_Pekerja.elementAt(i);
      bool cucuk = current.cucuk;
      String nama = current.username;
      if (filterCucuk && !filterPekerja && cucuk) {
        insertData(nama);
      } else if (!filterCucuk && filterPekerja && !cucuk) {
        insertData(nama);
      } else if (!filterCucuk && !filterPekerja) {
        insertData(nama);
      }
    }
  }

  void insertData(String nama) {
    setState(() {
      if (!_rekodPekerjaView.contains(nama)) {
        _rekodPekerjaView.add(nama);
      }
      _rekodPekerjaView.sort((a, b) => a.compareTo(b));
    });
  }

  Future<void> insertItem(rekodPekerja pekerja, int index) async {
    if (index >= 0) {
      var username = _rekodPekerjaView[index];
      var id = rekod_Pekerja
          .elementAt(rekod_Pekerja.indexWhere((e) => e.username == username))
          .id;
      pekerja.id = id;
      print("rekod >>> $id | ${pekerja.toMapServer()} ");
      // insertUpdateTable('Pekerja Rekod', pekerja.toMapServer(), id: id);
    } else {
      // insertUpdateTable('Pekerja Rekod', pekerja.toMapServer());
    }
    addItem(pekerja, index);
  }

  // addItem adds our User Class item to list.
  void addItem(rekodPekerja usr, int index) {
    if (index >= 0) {
      var id = rekod_Pekerja.indexWhere((e) => e.id == usr.id);
      rekod_Pekerja[id] = usr;
    } else {
      rekod_Pekerja.add(usr);
    }
    saveData();
  }

  void removeItem(int index) {
    var nama = _rekodPekerjaView[index];
    int indexDeleted = rekod_Pekerja.indexWhere(
      (element) => element.username == nama,
    );
    var id = rekod_Pekerja.elementAt(indexDeleted).id;
    deleteRow('Pekerja Rekod', id);
    removeInLocal(index);
  }

  void removeInLocal(int index) {
    String nama = _rekodPekerjaView.elementAt(index);
    int indexDeleted = rekod_Pekerja.indexWhere(
      (element) => element.username == nama,
    );
    rekod_Pekerja.removeAt(indexDeleted);
    _rekodPekerjaView.removeAt(index);
    saveData();
  }

  // This block saves our list locally.
  void saveData() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Simpan Data')));
    saveDataLocal();
  }
}

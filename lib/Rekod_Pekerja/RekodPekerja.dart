import 'package:flutter/material.dart';
import 'dart:async';
import "package:sattayussop/DocumentHelper.dart";
import 'package:sattayussop/login.dart';
import 'package:string_capitalize/string_capitalize.dart';
import 'package:notification_center/notification_center.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';
import 'package:flutter/material.dart';
import 'package:bcrypt/bcrypt.dart';


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
  Color colorBorder = Colors.black;
  Color textColor = Colors.black;
  final List<String> _rekodPekerjaView = <String>[];
  String titleFilter = "Senarai Semua Pekerja";
  bool filterCucuk = false;
  bool filterPekerja = false;
  List<DropdownMenuItem<int>> dropDownList = <DropdownMenuItem<int>>[];
  String _selected = "pekerja";
  bool isPekerja = false;

  @override
  void initState() {
    if (!mounted) return;
    if (dark) {
      color = Colors.deepOrange;
      background = Colors.black12;
      textColor = Colors.white;
      colorBorder = Colors.white;
    }
    refreshData();
    for (var index = 0; index < rekod_Role.length; index++) {
      var role = rekod_Role.elementAt(index);
      dropDownList.insert(dropDownList.length,  DropdownMenuItem<int>(
        value: role.id,
        child: Text(role.role),
      ));
    }
    NotificationCenter().subscribe('refreshData', _refreshView);
    processServerData(supabasePekerja);
    super.initState();
  }

  @override
  void dispose() {
    if (!mounted) return;
    // loadDataServer();
    super.dispose();
  }

  void _refreshView(bool refresh) {
    if (!mounted) return;
    setState(() {
      isPekerja = _selected == "pekerja";
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
            buildSegment(),
            isPekerja ? Card(
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
            ) : const SizedBox(height: 10),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isPekerja
                    ? buildPekerjaList()
                    : buildRoleList(),
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
          isPekerja ? showDialogTextRequired(context, "Masukkan Data", -1) : showDialogRoleTextRequired(context, "Masukkan Data", -1);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget buildSegment() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'role',
          label: Text('Role'),
          icon: Icon(Icons.category_outlined),
        ),
        ButtonSegment(
          value: 'pekerja',
          label: Text('Pekerja'),
          icon: Icon(Icons.supervised_user_circle),
        ),
      ],
      selected: {_selected},
      onSelectionChanged: (value) {
        setState(() {
          _selected = value.first;
          isPekerja = _selected == "pekerja";
        });
      },
    );
  }

  Widget buildPekerjaList() {
    return  ListView.builder(
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
            if (!delete) {
              return;
            }
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
    );
  }

  Widget buildRoleList() {
    return ListView(
      children: [

        Table(
          border: TableBorder.all(color: colorBorder),
          children: [
            TableRow(
              children: [
                buildHeader("Role"),
              ],
            ),
          ],
        ),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rekod_Role.length,
          itemBuilder: (context, index) {

            final current = rekod_Role[index];

            return GestureDetector(
              onTap: () {
                showDialogRoleTextRequired(
                  context,
                  "Masukkan Data",
                  index,
                );
              },
              onLongPress: () {
                if (!delete) {
                  return;
                }
                showDialogRequired(
                  context,
                  "Pengesahan Memadam",
                  "Adakah anda ingin memadam data ini",
                  index,
                );
              },
              child: Table(
                border: TableBorder.all(color: colorBorder),
                children: [
                  TableRow(
                    children: [
                      buildCell(current.role),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget buildHeader(String text) {
    return SizedBox(
      height: 40,
      child: Center(
        child: Text(
          text,
          style: textStyle,
        ),
      ),
    );
  }

  Widget buildCell(String text) {
    return SizedBox(
      height: 50,
      child: Center(
        child: Text(
          text,
          style: textStyleNormal,
        ),
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
                isPekerja ? removeItem(index) : removeRoleItem(index);
              },
            ),
          ],
        );
      },
    );
  }

  void showDialogRoleTextRequired(BuildContext context, String title, int index) {
    var myController = TextEditingController();
    var myController1 = TextEditingController();
    String errorText = "Sila masukkan beberapa digit";
    final formKey = GlobalKey<FormState>();
    int id = -1;
    bool read = false;
    bool write = false;
    bool delete = false;
    String hashPassword = "";
    if (index >= 0) {
      rekodRole current = rekod_Role.elementAt(index);
      myController.text = current.role;
      id = current.id;
      read = current.read;
      write = current.write;
      delete = current.delete;
      hashPassword = current.password;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
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
                          'Role:',
                          style: textStyle,
                          textAlign: TextAlign.left,
                        ),
                        TextFormField(
                          // enableInteractiveSelection: false,
                          // will disable paste operation
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return errorText;
                            }
                            return null;
                          },
                          enabled: true,
                          autofocus: true,
                          controller: myController,
                          decoration: InputDecoration(),
                          textInputAction:
                          TextInputAction.next, // Moves focus to next.
                        ),
                        Text(
                          'Password:',
                          style: textStyle,
                          textAlign: TextAlign.left,
                        ),
                        TextFormField(
                          // enableInteractiveSelection: false,
                          // will disable paste operation
                          validator: (value) {
                            if ((value == null || value.isEmpty) &&
                                hashPassword.isEmpty) {
                              return errorText;
                            }
                            return null;
                          },
                          enabled: true,
                          autofocus: true,
                          controller: myController1,
                          decoration: InputDecoration(),
                          textInputAction:
                          TextInputAction.next, // Moves focus to next.
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'Baca :',
                              style: textStyle,
                              textAlign: TextAlign.left,
                            ),
                            Switch(
                              value: read,
                              onChanged: (value) {
                                setState(() {
                                  read = value;
                                });
                              },
                              activeThumbColor: color,
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'Tulis :',
                              style: textStyle,
                              textAlign: TextAlign.left,
                            ),
                            Switch(
                              value: write,
                              onChanged: (value) {
                                setState(() {
                                  write = value;
                                });
                              },
                              activeThumbColor: color,
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'Padam :',
                              style: textStyle,
                              textAlign: TextAlign.left,
                            ),
                            Switch(
                              value: delete,
                              onChanged: (value) {
                                setState(() {
                                  delete = value;
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
                String namaRole = "";
                String password = "";
                if (formKey.currentState!.validate()) {
                  // Handle the submit action
                  if (!(myController.text.isEmpty)) {
                    namaRole = myController.text.capitalizeEach();
                  }
                }
                if (!(myController1.text.isEmpty)) {
                  password = myController1.text.toLowerCase();
                }
                var passwordChecking = checkPassword(password, hashPassword);

                if (formKey.currentState!.validate() && !passwordChecking &&
                    hashPassword.isNotEmpty) {
                  hashPassword = BCrypt.hashpw(
                    password,
                    BCrypt.gensalt(),
                  );
                  print("password change");
                } else if (!formKey.currentState!.validate() &&
                    myController1.text.isEmpty) {
                  print("password error");
                  return;
                }
                print("rekod hash password >>> $namaRole >> $hashPassword");
                rekodRole current = rekodRole(
                    namaRole, hashPassword, read, write, delete);
                if (id > 0) {
                  current.id = id;
                  current.role = namaRole;
                  current.password = hashPassword;
                  current.read = read;
                  current.write = write;
                  current.delete = delete;
                }
                insertRoleItem(current, index);
                Navigator.of(context).pop();
                // Handle the submit action
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> insertRoleItem(rekodRole role, int index) async {
    if (index >= 0) {
      var id = rekod_Role[index].id;
      role.id = id;
      insertUpdateTable(supabaseRole, role.toMapServer(), id: id);
    } else {
      if (!rekod_Role.map((e) => e.role).contains(role.role)) {
        insertUpdateTable(supabaseRole, role.toMapServer());
      }
    }
    addRoleItem(role, index);
  }

  // addItem adds our User Class item to list.
  void addRoleItem(rekodRole usr, int index) {
    if (index < 0) {
      rekod_Role.add(usr);
    }else {
      final index = rekod_Role.indexWhere((e) => e.id == usr.id);
      rekod_Role[index] = usr;
    }
    saveData();
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
    bool slipGaji = false;
    int? role = null;
    if (index >= 0) {
      String nama = _rekodPekerjaView.elementAt(index);
      int indexSelected = rekod_Pekerja.indexWhere(
        (element) => element.username == nama,
      );
      rekodPekerja current = rekod_Pekerja.elementAt(indexSelected);
      cucukSatay = current.cucuk;
      accessApps = current.akses_sistem;
      slipGaji = current.slip_gaji;
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
      role = current.role >= 0 ? current.role : null;
    }
    if (role != null) {
      var _indexKategori = rekod_Role.indexWhere((e) => e.id == role);
      myController8.text = rekod_Role
          .elementAt(_indexKategori).role;
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
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          value:role,
                          hint: const Text("Pilih Kategori"),
                          items: dropDownList,
                          onChanged: (item) {
                            print("item >> ${item}");
                            role = item;
                            var result = rekod_Role.elementAt(
                              rekod_Role.indexWhere(
                                    (e) => e.id == role,
                              ),
                            );
                            var nama = result.role;
                            myController8.text = nama;
                          },
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
                        Row(
                          children: <Widget>[
                            Text(
                              'Slip Gaji :',
                              style: textStyle,
                              textAlign: TextAlign.left,
                            ),
                            Switch(
                              value: slipGaji,
                              onChanged: (value) {
                                setState(() {
                                  slipGaji = value;
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
                      role ?? 2,
                      accessApps,
                        slipGaji,
                      rekod
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
      insertUpdateTable(supabasePekerja, pekerja.toMapServer(), id: id);
    } else {
      insertUpdateTable(supabasePekerja, pekerja.toMapServer());
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

  void removeRoleItem(int index) {
    var id = rekod_Role[index].id;
    deleteRow(supabaseRole, id);
    removeRoleInLocal(index);
  }

  void removeRoleInLocal(int index) {
    rekod_Role.removeAt(index);
    saveData();
  }

  void removeItem(int index) {
    var nama = _rekodPekerjaView[index];
    int indexDeleted = rekod_Pekerja.indexWhere(
      (element) => element.username == nama,
    );
    var id = rekod_Pekerja.elementAt(indexDeleted).id;
    deleteRow(supabasePekerja, id);
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

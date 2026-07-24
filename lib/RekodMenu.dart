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
  List<DropdownMenuItem<int>> dropDownList = <DropdownMenuItem<int>>[];
  String _selected = "menu";
  bool isMenu = false;

  @override
  void initState() {
    NotificationCenter().subscribe('refreshData', _refreshView);
    if (dark) {
      color = Colors.deepOrange;
      colorBorder = Colors.white;
    }
    _refreshView(true);
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
    isMenu = _selected == "menu";
    dropDownList.clear();

    final list = sortMenuList(rekod_Kategori);
    print("kategori >> ${list}");
    for (var index = 0; index < list.length; index++) {
      rekodKategoriMenu current = list.elementAt(index);
      var nama = current.jenis;
      int id = current.id;
      dropDownList.insert(dropDownList.length,  DropdownMenuItem<int>(
        value: id,
        child: Text(nama),
      ));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          children: [
            buildSegment(),

            const SizedBox(height: 10),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: isMenu
                    ? buildMenuList()
                    : buildKategoriList(),
              ),
            ),
          ],
        )
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
          isMenu ? showDialogTextRequired(context, "Masukkan Data", -1) : showDialogKategoriTextRequired(context, "Masukkan Data", -1);
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
          value: 'kategori',
          label: Text('Kategori'),
          icon: Icon(Icons.category),
        ),
        ButtonSegment(
          value: 'menu',
          label: Text('Menu'),
          icon: Icon(Icons.restaurant_menu),
        ),
      ],
      selected: {_selected},
      onSelectionChanged: (value) {
        setState(() {
          _selected = value.first;
          isMenu = _selected == "menu";
        });
      },
    );
  }

  Widget buildMenuList() {
    return ListView(
      children: [

        Table(
          border: TableBorder.all(color: colorBorder),
          columnWidths: const {
            0: FlexColumnWidth(),
            1: FlexColumnWidth(),
          },
          children: [
            TableRow(
              children: [
                buildHeader("Menu"),
                buildHeader("Harga (RM)"),
              ],
            ),
          ],
        ),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rekod_Menu.length,
          itemBuilder: (context, index) {

            final current = rekod_Menu[index];

            return GestureDetector(
              onTap: () {
                showDialogTextRequired(
                  context,
                  "Masukkan Data",
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
              child: Table(
                border: TableBorder.all(color: colorBorder),
                columnWidths: const {
                  0: FlexColumnWidth(),
                  1: FlexColumnWidth(),
                },
                children: [
                  TableRow(
                    children: [
                      buildCell(current.jenis.capitalizeEach()),
                      buildCell(money(current.Harga)),
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

  Widget buildKategoriList() {
    return ListView(
      children: [

        Table(
          border: TableBorder.all(color: colorBorder),
          children: [
            TableRow(
              children: [
                buildHeader("Kategori"),
              ],
            ),
          ],
        ),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rekod_Kategori.length,
          itemBuilder: (context, index) {

            final current = rekod_Kategori[index];

            return GestureDetector(
              onTap: () {
                showDialogKategoriTextRequired(
                  context,
                  "Masukkan Data",
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
              child: Table(
                border: TableBorder.all(color: colorBorder),
                children: [
                  TableRow(
                    children: [
                      buildCell(current.jenis),
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
                isMenu ? removeItem(index) : removeKategoriItem(index);
              },
            ),
          ],
        );
      },
    );
  }

  void showDialogKategoriTextRequired(BuildContext context, String title, int index) {
    var myController = TextEditingController();
    String errorText = "Sila masukkan beberapa digit";
    final formKey = GlobalKey<FormState>();
    int id = -1;
    if (index >= 0) {
      rekodKategoriMenu current = rekod_Kategori.elementAt(index);
      myController.text = current.jenis;
      id = current.id;
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
                        'Kategori Menu:',
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                      TextField(
                        // enableInteractiveSelection: false,
                        // will disable paste operation
                        enabled: true,
                        autofocus: true,
                        controller: myController,
                        decoration: InputDecoration(),
                        textInputAction:
                            TextInputAction.next, // Moves focus to next.
                      )
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
                  if (formKey.currentState!.validate()) {
                    // Handle the submit action
                    String namaMenu = "";
                    if (!(myController.text.isEmpty)) {
                      namaMenu = myController.text.capitalizeEach();
                    }
                    insertKategoriItem(rekodKategoriMenu(namaMenu), index);
                    Navigator.of(context).pop();
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
                        'Kategori Menu :',
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
                  if (formKey.currentState!.validate()) {
                    // Handle the submit action
                    String namaMenu = "";
                    if (!(myController.text.isEmpty)) {
                      namaMenu = myController.text.capitalizeEach();
                    }
                    insertKategoriItem(rekodKategoriMenu(namaMenu), index);
                    Navigator.of(context).pop();
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


  void showDialogTextRequired(BuildContext context, String title, int index) {
    var myController = TextEditingController();
    var myController1 = TextEditingController();
    var myController2 = TextEditingController();
    String errorText = "Sila masukkan beberapa digit";
    final formKey = GlobalKey<FormState>();
    int? id = null;
    myController.text = "";
    myController1.text = "";
    myController2.text = "";
    if (index >= 0) {
      rekodMenu current = rekod_Menu.elementAt(index);
      myController.text = current.jenis;
      var kategori = current.kategori;
      id = kategori >= 0 ? kategori : null;
      if (id != null) {
        var _indexKategori = rekod_Kategori.indexWhere((e) => e.id == id);
        myController1.text = rekod_Kategori
            .elementAt(_indexKategori)
            .jenis;
      }
      myController2.text = money(current.Harga);
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
                        // enableInteractiveSelection: false,
                        // will disable paste operation
                        enabled: true,
                        autofocus: true,
                        controller: myController,
                        decoration: InputDecoration(),
                        textInputAction:
                        TextInputAction.next, // Moves focus to next.
                      ),
                      Container(height: 2),
                      Text(
                        'Kategori Menu :',
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value:id,
                        hint: const Text("Pilih Kategori"),
                        items: dropDownList,
                        onChanged: (item) {
                            print("item >> ${item}");
                            id = item;
                            var result = rekod_Kategori.elementAt(
                              rekod_Kategori.indexWhere(
                                    (e) => e.id == id,
                              ),
                            );
                            var nama = result.jenis;
                            myController1.text = nama;
                        },
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
                  if (formKey.currentState!.validate()) {
                    // Handle the submit action
                    String namaMenu = myController.text.capitalizeEach();
                    if (!namaMenu.contains(" ") &&
                        !namaMenu.toLowerCase().contains("satay")) {
                      namaMenu = 'Satay $namaMenu'.capitalizeEach();
                    }
                    String kategoriMenu = myController1.text.capitalizeEach();
                    if (!(myController1.text.isEmpty)) {
                      kategoriMenu = kategoriMenu.capitalizeEach();
                    }
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    if (!(myController2.text.isEmpty)) {
                      harga = myController2.text.totalDoubleNumber();
                    }
                    Navigator.of(context).pop();
                    insertItem(rekodMenu(namaMenu,id ?? 0, harga), index);
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
                        'Kategori Menu :',
                        style: textStyle,
                        textAlign: TextAlign.left,
                      ),
                      DropdownButtonFormField<int>(
                        isExpanded: true,
                        value:id,
                        hint: const Text("Pilih Kategori"),
                        items: dropDownList,
                        onChanged: (item) {
                          print("item >> ${item}");
                          id = item;
                          var result = rekod_Kategori.elementAt(
                            rekod_Kategori.indexWhere(
                                  (e) => e.id == id,
                            ),
                          );
                          var nama = result.jenis;
                          myController1.text = nama;
                        },
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
                  if (formKey.currentState!.validate()) {
                    String namaMenu = myController.text.capitalizeEach();
                    if (!namaMenu.contains(" ") &&
                        !namaMenu.toLowerCase().contains("satay")) {
                      namaMenu = 'Satay $namaMenu'.capitalizeEach();
                    }

                    String kategoriMenu = myController1.text.capitalizeEach();
                    if (!(myController1.text.isEmpty)) {
                      kategoriMenu = kategoriMenu.capitalizeEach();
                    }
                    // If the form is valid, display a snackbar. In the real world,
                    // you'd often call a server or save the information in a database.
                    if (!(myController2.text.isEmpty)) {
                      harga = myController2.text.totalDoubleNumber();
                    }
                    Navigator.of(context).pop();
                    insertItem(rekodMenu(namaMenu,id ?? 0, harga), index);
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

  Future<void> insertKategoriItem(rekodKategoriMenu menu, int index) async {
    if (index >= 0) {
      var id = rekod_Kategori[index].id;
      menu.id = id;
      insertUpdateTable('Kategori Menu Rekod', menu.toMapServer(), id: id);
    } else {
      if (!rekod_Kategori.map((e) => e.jenis).contains(menu.jenis)) {
        insertUpdateTable('Kategori Menu Rekod', menu.toMapServer());
      }
    }
    addKategoriItem(menu, index);
  }

  // addItem adds our User Class item to list.
  void addKategoriItem(rekodKategoriMenu usr, int index) {
    if (index < 0) {
      rekod_Kategori.add(usr);
    }else {
      final index = rekod_Kategori.indexWhere((e) => e.id == usr.id);
      rekod_Kategori[index] = usr;
    }
    saveData();
  }

  Future<void> insertItem(rekodMenu menu, int index) async {
    if (index >= 0) {
      var id = rekod_Menu[index].id;
      menu.id = id;
      insertUpdateTable('Menu Rekod', menu.toMapServer(), id: id);
    } else {
      final index = rekod_Menu.indexWhere((e) => e.jenis == menu.jenis);
      if (index < 0) {
        insertUpdateTable('Menu Rekod', menu.toMapServer());
      }
    }
    addItem(menu, index);
  }

  // addItem adds our User Class item to list.
  void addItem(rekodMenu usr, int index) {
    if (index < 0) {
      rekod_Menu.add(usr);
    }else {
      final index = rekod_Menu.indexWhere((e) => e.id == usr.id);
      rekod_Menu[index] = usr;
    }
    saveData();
  }

  void removeKategoriItem(int index) {
    var id = rekod_Kategori[index].id;
    deleteRow('Kategori Menu Rekod', id);
    removeKategoriInLocal(index);
  }

  void removeKategoriInLocal(int index) {
    rekod_Kategori.removeAt(index);
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:string_capitalize/string_capitalize.dart';
import '../DocumentHelper.dart';
import 'package:notification_center/notification_center.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class selectRekodCucukDetail extends StatefulWidget {
  const selectRekodCucukDetail({
    super.key,
    required this.selectIndex,
    required this.pekerja,
    required this.menuList,
  });

  final int selectIndex;
  final List<rekodPekerja> pekerja;
  final List<rekodMenu> menuList;

  @override
  State<selectRekodCucukDetail> createState() => _selectRekodCucukDetailState();
}

class _selectRekodCucukDetailState extends State<selectRekodCucukDetail> {
  int selectIndex = 0;
  List<rekodCucukDetail> _rekodCucukDetail = <rekodCucukDetail>[];
  List<rekodPekerja> pekerja = <rekodPekerja>[];
  List<rekodMenu> menuList = <rekodMenu>[];
  List<rekodJumlahCucuk> jumlahSatay = <rekodJumlahCucuk>[];
  rekodCucuk? selectRecordCucuk;
  String tarikh = "";
  int cucukId = 0;
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
  List<DropdownMenuItem> dropDownListMenu = <DropdownMenuItem>[];
  int jumlahKeseluruhan = 0;

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
      colorBorder = Colors.white;
    }
    NotificationCenter().subscribe('refreshData', _refreshView);
    pekerja = widget.pekerja;
    selectIndex = widget.selectIndex;
    menuList = widget.menuList;
    for (var index = 0; index < pekerja.length; index++) {
      rekodPekerja list = pekerja.elementAt(index);
      var nama = list.nama;
      var username = list.username;
      dropDownList.add(
        DropdownMenuItem<String>(value: username, child: Text(nama)),
      );
    }
    for (var index = 0; index < menuList.length; index++) {
      rekodMenu list = menuList.elementAt(index);
      var nama = list.jenis;
      dropDownListMenu.add(
        DropdownMenuItem<String>(value: nama, child: Text(nama)),
      );
    }
    _refreshView(true);
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
  }

  void _refreshView(bool refresh) {
    setState(() {
      rekodCucuk current = rekod_Cucuk.elementAt(selectIndex);
      cucukId = current.id;
      tarikh = current.tarikh;
      jumlahSatay =
          sortMenuList(
                List<rekodJumlahCucuk>.from(current.jumlahSatayList).toList(),
              )
              as List<rekodJumlahCucuk>;
      _rekodCucukDetail = List<rekodCucukDetail>.from(current.rekod).toList();
      jumlahKeseluruhan = 0;
      for (var index = 0; index < jumlahSatay.length; index++) {
        rekodJumlahCucuk current = jumlahSatay.elementAt(index);
        int jumlah = current.jumlah;
        jumlahKeseluruhan = jumlahKeseluruhan + jumlah;
      }
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
    rekodCucuk current = rekod_Cucuk.elementAt(selectIndex);
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
                      1: FlexColumnWidth(),
                      2: FixedColumnWidth(80),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: <TableRow>[
                      TableRow(
                        children: <Widget>[
                          SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                'Nama',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                'Jenis',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            child: Center(
                              child: Text(
                                'Jumlah',
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
                    itemCount: _rekodCucukDetail.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      rekodCucukDetail current = _rekodCucukDetail.elementAt(
                        index,
                      );
                      String nama = rekod_Pekerja
                          .elementAt(
                            rekod_Pekerja.indexWhere(
                              (e) => e.id == current.pekerja_id,
                            ),
                          )
                          .nama;
                      return GestureDetector(
                        child: Table(
                          border: TableBorder.all(color: colorBorder),
                          columnWidths: const <int, TableColumnWidth>{
                            0: FlexColumnWidth(),
                            1: FlexColumnWidth(),
                            2: FixedColumnWidth(80),
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
                                      current.jenis,
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      '${current.jumlah}',
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
                              ListView.builder(
                                primary: false,
                                itemCount: jumlahSatay.length,
                                padding: EdgeInsets.only(bottom: 1.0),
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  rekodJumlahCucuk current = jumlahSatay
                                      .elementAt(index);
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              current.jenis,
                                              style: textStyle,
                                            ),
                                          ),
                                          Text(
                                            '${current.jumlah}',
                                            style: textStyleNormal,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  );
                                },
                              ),
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
                                    '$jumlahKeseluruhan',
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
        title: Text("Detail Cucuk", style: TextStyle(color: Colors.white)),
        actions: <Widget>[],
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
                removeItemServer(index);
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
    String errorText = "Sila pilih nama pekerja anda";
    final formKey = GlobalKey<FormState>();
    // declare a variable to keep track of the input text
    String username = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        if (index >= 0) {
          rekodCucukDetail current = _rekodCucukDetail.elementAt(index);
          var result = rekod_Pekerja.elementAt(
            rekod_Pekerja.indexWhere((e) => e.id == current.pekerja_id),
          );
          myController.text = result.nama;
          myController2.text = current.jenis;
          myController3.text = '${current.jumlah}';
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
                          Text(
                            'Jenis Satay :',
                            style: textStyle,
                            textAlign: TextAlign.left,
                          ),
                          DropdownButtonFormField(
                            isExpanded: true,
                            initialValue: myController2.text,
                            onChanged: (item) {
                              myController2.text = item;
                            },
                            items: dropDownListMenu,
                          ),
                          Text(
                            'Jumlah Satay :',
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
                  Navigator.of(context).pop();
                  // Handle the submit action
                  String nama = myController.text.capitalizeEach();
                  print("nama >> $nama");
                  String jenis = myController2.text.capitalizeEach();
                  int jumlah = 0;
                  if (!(myController3.text.isEmpty)) {
                    jumlah = myController3.text.totalIntNumber();
                  }
                  current.jenis = jenis;
                  current.jumlah = jumlah;
                  updateDataTable(current, index);
                },
              ),
            ],
          );
        } else {
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
                          DropdownButtonFormField(
                            isExpanded: true,
                            onChanged: (item) {
                              validator:
                              (value) {
                                if (value == null || value.isEmpty) {
                                  return errorText;
                                }
                                return null;
                              };
                              username = item;
                              var result = rekod_Pekerja.elementAt(
                                rekod_Pekerja.indexWhere(
                                  (e) => e.username == username,
                                ),
                              );
                              var nama = result.nama;
                              myController.text = nama;
                            },
                            items: dropDownList,
                          ),
                          Text(
                            'Jenis Satay :',
                            style: textStyle,
                            textAlign: TextAlign.left,
                          ),
                          DropdownButtonFormField(
                            isExpanded: true,
                            onChanged: (item) {
                              myController2.text = item;
                            },
                            items: dropDownListMenu,
                          ),
                          Text(
                            'Jumlah Satay :',
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
                  Navigator.of(context).pop();
                  // Handle the submit action
                  String nama = myController.text.capitalizeEach();
                  print("nama >> $nama");
                  String jenis = myController2.text.capitalizeEach();
                  int jumlah = 0;
                  if (formKey.currentState!.validate()) {
                    if (!(myController3.text.isEmpty)) {
                      jumlah = myController3.text.totalIntNumber();
                    }
                    var result = rekod_Pekerja.elementAt(
                      rekod_Pekerja.indexWhere((e) => e.username == username),
                    );
                    var pekerjaID = result.id;
                    var nama = result.nama;
                    updateDataTable(
                      rekodCucukDetail(cucukId, pekerjaID, nama, jenis, jumlah),
                      index,
                    );
                  }
                },
              ),
            ],
          );
        }
      },
    );
  }

  void kiraJualan() {
    print("start kira ${jumlahSatay.length}");
    var startRefresh = false;
    if (jumlahSatay.isEmpty) {
      startRefresh = true;
    } else {
      for (var index = 0; index < jumlahSatay.length; index++) {
        rekodJumlahCucuk current = jumlahSatay.elementAt(index);
        var jenis = current.jenis;
        var id = current.id;
        var jumlah = 0;
        var refresh = false;
        if (_rekodCucukDetail.isEmpty) {
          refresh = true;
        } else {
          for (var i = 0; i < _rekodCucukDetail.length; i++) {
            rekodCucukDetail currentrekod = _rekodCucukDetail.elementAt(i);
            var jenisSatay = currentrekod.jenis;
            if (jenisSatay == jenis) {
              jumlah = jumlah + currentrekod.jumlah;
            }
            if (i >= _rekodCucukDetail.length - 1) {
              print(
                "rekod >> $jenisSatay | $jenis | ${currentrekod.jumlah} | $jumlah",
              );
              refresh = true;
            }
          }
        }
        if (refresh) {
          current.jumlah = jumlah;
          insertUpdateTable(
            "Jumlah Cucuk Satay Rekod",
            current.toMapServer(),
            id: id,
          );
          if (index >= jumlahSatay.length - 1) {
            startRefresh = true;
          }
        }
      }
    }
    if (startRefresh) {
      updateJumlah();
    }
  }

  // addItem adds our User Class item to list.
  void updateJumlah() {
    print("start update satay");
    var record = List<rekodJumlahCucuk>.from(jumlahSatay).toList();
    var target = rekod_Cucuk[selectIndex];
    setState(() {
      target.jumlahSatayList = record;
    });
    saveData();
  }

  Future<void> updateDataTable(rekodCucukDetail detail, int index) async {
    print("update insert >>> $index");
    if (index >= 0) {
      insertUpdateTable(
        'Cucuk Detail Rekod',
        detail.toMapServer(),
        id: detail.id,
      );
    } else {
      insertUpdateTable('Cucuk Detail Rekod', detail.toMapServer());
    }
    addItem(detail, index);
  }

  // addItem adds our User Class item to list.
  void addItem(rekodCucukDetail usr, int index) {
    if (index >= 0) {
      _rekodCucukDetail[index] = usr;
    } else {
      _rekodCucukDetail.add(usr);
    }
    var target = rekod_Cucuk[selectIndex];
    setState(() {
      target.rekod = _rekodCucukDetail;
    });
    kiraJualan();
  }

  void removeItemSelected(int index) {
    _rekodCucukDetail.removeAt(index);
    var target = rekod_Cucuk.firstWhere((item) => item.tarikh == tarikh);
    setState(() {
      target.rekod = _rekodCucukDetail;
    });
    kiraJualan();
  }

  void removeItemServer(int index) {
    var id = _rekodCucukDetail.elementAt(index).id;
    deleteRow('Cucuk Detail Rekod', id);
    removeItemSelected(index);
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
    updateStok(tarikh);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Simpan Data')));
  }
}

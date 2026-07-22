import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sattayussop/DocumentHelper.dart';
import 'package:notification_center/notification_center.dart';
import '../databaseLocal.dart';

class selectRekodStokDetail extends StatefulWidget {
  const selectRekodStokDetail({super.key, required this.selectIndex});

  final int selectIndex;

  @override
  State<selectRekodStokDetail> createState() => _selectRekodStokDetailState();
}

class _selectRekodStokDetailState extends State<selectRekodStokDetail> {
  int selectIndex = 0;
  int stok_id = 0;
  int detail_id = 0;
  String tarikhRekod = "";
  List<rekodStokDetail> selectStokDetail = <rekodStokDetail>[];
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
  List<DropdownMenuItem> dropDownListMenu = <DropdownMenuItem>[];

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
      colorBorder = Colors.white;
    }
    selectIndex = widget.selectIndex;
    NotificationCenter().subscribe('refreshData', _refreshView);
    rekodStok current = rekod_stok.elementAt(selectIndex);
    stok_id = current.id;
    tarikhRekod = current.tarikh;
    selectStokDetail = List<rekodStokDetail>.from(
      sortMenuList(List<rekodStokDetail>.from(current.rekod).toList()),
    );
    DateTime tempDate = DateFormat("dd/MM/yyyy").parse(tarikhRekod.toString());
    int currentEpochTime = tempDate.millisecondsSinceEpoch;
    for (var index = 0; index < rekod_stok.length; index++) {
      rekodStok currentRekod = rekod_stok.elementAt(index);
      String tarikh = currentRekod.tarikh;
      DateTime tempDate1 = DateFormat("dd/MM/yyyy").parse(tarikh.toString());
      int epochTimeStok = tempDate1.millisecondsSinceEpoch;
      if (epochTimeStok < currentEpochTime) {
        dropDownListMenu.add(
          DropdownMenuItem<String>(value: tarikh, child: Text(tarikh)),
        );
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
  }

  void _refreshView(bool refresh) {
    if (!mounted) return;
    setState(() {
      rekodStok current = rekod_stok.elementAt(
        rekod_stok.indexWhere((e) => e.id == stok_id),
      );
      selectStokDetail = List<rekodStokDetail>.from(
        sortMenuList(List<rekodStokDetail>.from(current.rekod).toList()),
      );
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
    rekodStok current = rekod_stok.elementAt(selectIndex);
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
                      ' ${current.tarikh}',
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
                                'Stok \nLama',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                'Stok \nBaru',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                'Stok \nSimpan',
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
                    itemCount: selectStokDetail.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      rekodStokDetail rekod = selectStokDetail.elementAt(index);
                      String menu = rekod.jenis;
                      String stokLama0 = rekod.stokLama;
                      num stokLama = 0;
                      rekodStok? findStok(List<rekodStok> list, String menu) {
                        try {
                          return list.firstWhere(
                            (element) => stokLama0 == element.tarikh,
                          );
                        } catch (e) {
                          return null;
                        }
                      }

                      rekodStok? targetStok = findStok(rekod_stok, stokLama0);
                      if (targetStok != null) {
                        List<rekodStokDetail> stokDetail =
                            List<rekodStokDetail>.from(
                              targetStok.rekod,
                            ).toList();

                        rekodStokDetail? findStok(
                          List<rekodStokDetail> list,
                          String menu,
                        ) {
                          try {
                            return list.firstWhere(
                              (element) => menu.contains(element.jenis),
                            );
                          } catch (e) {
                            return null;
                          }
                        }

                        rekodStokDetail? targetStokDetail = findStok(
                          stokDetail,
                          menu,
                        );
                        if (targetStokDetail != null) {
                          stokLama = targetStokDetail.baki;
                        }
                      }
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
                                  height: 60,
                                  child: Center(
                                    child: Text(
                                      rekod.jenis,
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: Text(
                                      '$stokLama',
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: Text(
                                      '${rekod.stokBaru}',
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: Text(
                                      '${rekod.simpan}',
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
                            "Masukkan data ${rekod.jenis}",
                            index,
                          );
                        },
                      );
                      // }
                    },
                  ),
                  Divider(height: 15),
                  Table(
                    border: TableBorder.all(color: colorBorder),
                    columnWidths: const <int, TableColumnWidth>{
                      0: FlexColumnWidth(),
                      1: FixedColumnWidth(70),
                      2: FixedColumnWidth(70),
                      3: FixedColumnWidth(70),
                      4: FixedColumnWidth(70),
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
                                'Stok \nKeluar',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                'Stok \nJualan',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                'Stok \nBaki',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                'Stok \nRugi',
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
                    itemCount: selectStokDetail.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      rekodStokDetail rekod = selectStokDetail.elementAt(index);
                      return GestureDetector(
                        child: Table(
                          border: TableBorder.all(color: colorBorder),
                          columnWidths: const <int, TableColumnWidth>{
                            0: FlexColumnWidth(),
                            1: FixedColumnWidth(70),
                            2: FixedColumnWidth(70),
                            3: FixedColumnWidth(70),
                            4: FixedColumnWidth(70),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: <TableRow>[
                            TableRow(
                              children: <Widget>[
                                SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: Text(
                                      rekod.jenis,
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: Text(
                                      '${rekod.keluar}',
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: Text(
                                      '${rekod.jualan}',
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: Text(
                                      '${rekod.baki}',
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: Text(
                                      '${rekod.rugi}',
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
                            "Masukkan data ${rekod.jenis}",
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
                                      'Kerugian (RM)',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    money(current.kerugian),
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
                                      'Pendapatan (RM)',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    money(current.jumlahPendapatan),
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
        title: Text("Rekod Stok", style: TextStyle(color: Colors.white)),
        actions: <Widget>[],
        centerTitle: true,
      ),
      body: buildCollectionView,
    );
  }

  void showDialogTextRequired(BuildContext context, String title, int index) {
    var myController = TextEditingController();
    var myController2 = TextEditingController();
    String errorText = "Sila masukkan beberapa digit";
    final formKey = GlobalKey<FormState>();
    rekodStokDetail rekod = selectStokDetail.elementAt(index);
    String menuChange = rekod.jenis;
    myController.text = rekod.stokLama;
    if (rekod.simpan > 0) {
      myController2.text = "${rekod.simpan}";
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
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
                      'Stok Lama :',
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
                    Text(
                      'Stok Simpan :',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    TextFormField(
                      autofocus: true,
                      controller: myController2,
                      decoration: InputDecoration(),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9+\-*/.]'),
                        ),
                      ],
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
                Navigator.of(context).pop();
                int stokSimpan = 0;
                String stokLama = "";
                // Handle the submit action
                // If the form is valid, display a snackbar. In the real world,
                // you'd often call a server or save the information in a database.
                if (!(myController.text.isEmpty)) {
                  stokLama = myController.text;
                }
                if (!(myController2.text.isEmpty)) {
                  stokSimpan = myController2.text.totalIntNumber();
                }
                if (rekod.simpan != stokSimpan) {
                  rekod.simpanManual = true;
                }
                rekod.stokLama = stokLama;
                rekod.simpan = stokSimpan;
                // if (stokLama.isNotEmpty) {
                //   rekodStok targetStok =
                //       rekod_stok[rekod_stok.indexWhere(
                //         (element) => element.tarikh == stokLama,
                //       )];
                //   List<rekodStokDetail> stokDetail = List<rekodStokDetail>.from(targetStok.rekod).toList();
                //   for (var i = 0; i < selectStokDetail.length; i++) {
                //     rekodStokDetail currentStok = selectStokDetail.elementAt(i);
                //     String menu = currentStok.jenis;
                //     rekodStokDetail targetStokDetail = stokDetail.elementAt(
                //       stokDetail.indexWhere((element) => element.jenis == menu),
                //     );
                //     num jumlahStokLama = targetStokDetail.baki;
                //     currentStok.stokLama = stokLama;
                //     print("rekod simpan >>> ${currentStok.simpan}");
                //   }
                // }
                // selectStokDetail[index] = rekod;

                addItemSelected();
                // Handle the submit action
              },
            ),
          ],
        );
      },
    );
  }

  // addItem adds our User Class item to list.
  void addItemSelected() {
    rekodStok target = rekod_stok.elementAt(
      rekod_stok.indexWhere((e) => e.id == stok_id),
    );
    setState(() {
      target.rekod = selectStokDetail;
    });
    saveData();
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
    updateStok(tarikhRekod);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Simpan Data')));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:sattayussop/DocumentHelper.dart';
import 'package:sattayussop/resit.dart';
import 'package:string_capitalize/string_capitalize.dart';
import 'package:notification_center/notification_center.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class selectRekodBarangDetail extends StatefulWidget {
  const selectRekodBarangDetail({
    super.key,
    required this.selectIndex,
    required this.selectedDetail,
  });

  final int selectIndex;
  final int selectedDetail;

  @override
  State<selectRekodBarangDetail> createState() =>
      _selectRekodBarangDetailState();
}

class _selectRekodBarangDetailState extends State<selectRekodBarangDetail> {
  Map<String, dynamic> barangList = {};
  Color color = Colors.orange;
  Color colorBorder = Colors.black;
  bool dark = sharedPreferences?.getBool("darkModeStatus") ?? false;
  List<DropdownMenuItem> dropDownListMenu = <DropdownMenuItem>[];
  var epochTime = "";
  String hariRekod = "";
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  String nama = "";
  List<rekodPembekalDetail> selectDetailBarang = <rekodPembekalDetail>[];
  int selectIndex = 0;
  int selectedDetail = 0;
  DateTime selectedDate = DateTime.now();
  String tarikh = "";
  String tarikhRekod = "";
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
  TextStyle titleTextStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );

  rekodPembekalDetail? _rekodBarangDetail;
  List<rekodBayaranPembekal> _rekodBayaranPembekal = <rekodBayaranPembekal>[];
  final pdf = pw.Document();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
  }

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
      colorBorder = Colors.white;
    }
    NotificationCenter().subscribe('refreshData', _refreshView);
    selectIndex = widget.selectIndex;
    selectedDetail = widget.selectedDetail;
    _refreshView(true);
    for (var index = 0; index < senarai_Barang.length; index++) {
      rekodBarang list = senarai_Barang.elementAt(index);
      var nama = list.nama ?? '';
      dropDownListMenu.add(
        DropdownMenuItem<String>(value: nama, child: Text(nama)),
      );
    }
    super.initState();
  }

  void _refreshView(bool refresh) {
    setState(() {
      rekodPembekalList currentBarang = rekod_Pembekal.elementAt(
        rekod_Pembekal.indexWhere((e) => e.id == selectIndex),
      );
      nama = currentBarang.namaPembekal;
      _rekodBayaranPembekal = List<rekodBayaranPembekal>.from(
        currentBarang.rekodBayaran,
      ).toList();
      selectDetailBarang = List<rekodPembekalDetail>.from(
        currentBarang.rekod,
      ).toList();
      rekodPembekalDetail current = selectDetailBarang.elementAt(
        selectDetailBarang.indexWhere((e) => e.id == selectedDetail),
      );
      tarikh = current.tarikh;
      barangList = current.rekodBarang;
      _rekodBarangDetail = current;
      print("rekod refresh $selectIndex");
    });
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
                removeItemSelected(index);
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
    String errorText = "Sila masukkan beberapa digit";
    final formKey = GlobalKey<FormState>();
    final values = dropDownListMenu.map((e) => e.value).toList();

    if (index >= 0) {
      var current = barangList.keys.elementAt(index);
      String nama = current;
      myController.text = current;
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
                    DropdownButtonFormField(
                      isExpanded: true,
                      initialValue: values.contains(myController.text)
                          ? myController.text
                          : null,
                      onChanged: (item) {
                        myController.text = item;
                      },
                      items: dropDownListMenu,
                    ),
                    Container(height: 2),
                    Text(
                      'Kuantiti :',
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
                      textInputAction: TextInputAction.done,
                      // Moves focus to next.
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
                String namaBarang = myController.text;
                String kuantiti = "";
                // Handle the submit action
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  if (!(myController1.text.isEmpty)) {
                    kuantiti = myController1.text;
                  }
                  barangList[namaBarang] = kuantiti;
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

  void showDialogTextJumlahRequired(BuildContext context, String title) {
    var myController = TextEditingController();
    String errorText = "Sila masukkan beberapa digit";
    final formKey = GlobalKey<FormState>();
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
                      'Jumlah :',
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
                      controller: myController,
                      textInputAction: TextInputAction.done,
                      // Moves focus to next.
                      decoration: InputDecoration(),
                      keyboardType: TextInputType.multiline,
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
                num jumlah = 0.00;
                // Handle the submit action
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  if (!(myController.text.isEmpty)) {
                    jumlah = myController.text.toDoubleNumberFormat();
                  }
                  _rekodBarangDetail?.jumlah = jumlah;
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

  void kiraJualan() {
    num jumlahBarang = _rekodBarangDetail?.jumlah ?? 0.00;
    print("start rekod kira >>> $barangList");
    num jumlah = 0.0;
    if (_rekodBayaranPembekal.isNotEmpty) {
      for (var index = 0; index < _rekodBayaranPembekal.length; index++) {
        rekodBayaranPembekal current = _rekodBayaranPembekal.elementAt(index);
        print("rekod >>> ${current.tarikh} + ${current.bayaran}");
        jumlah = jumlah + current.bayaran;
      }
    }
    print("jumlah >> $jumlah | ${selectDetailBarang.length} | $selectedDetail");
    rekodPembekalDetail currentDetail = selectDetailBarang.elementAt(
      selectDetailBarang.indexWhere((e) => e.id == selectedDetail),
    );
    print("jumlah >> $jumlah | ${_rekodBayaranPembekal.length}");
    currentDetail.rekodBarang = barangList;
    currentDetail.bayaran = jumlah;
    currentDetail.jumlah = jumlahBarang;
    num bayaran = currentDetail.bayaran;
    num baki = jumlahBarang - bayaran;
    currentDetail.baki = baki;
    if (baki <= 0.00 && (jumlahBarang > 0.00) && barangList.isNotEmpty) {
      currentDetail.bayaranPenuh = true;
    } else {
      currentDetail.bayaranPenuh = false;
    }
    insertServer(currentDetail);
  }

  Future<void> insertServer(rekodPembekalDetail usr) async {
    await insertUpdateTable(
      'Pembekal Detail Rekod',
      usr.toMapServer(),
      id: selectedDetail,
    );
    var target = rekod_Pembekal.elementAt(
      rekod_Pembekal.indexWhere((e) => e.id == selectIndex),
    );
    setState(() {
      target.rekod = selectDetailBarang;
    });
    saveData();
  }

  // addItem adds our User Class item to list.
  void addItem(rekodBayaranPembekal usr, int index) {
    if (index >= 0) {
      rekodBayaranPembekal currentPembekal = _rekodBayaranPembekal.elementAt(
        index,
      );
      currentPembekal.bayaran = usr.bayaran;
    } else {
      _rekodBayaranPembekal.add(usr);
    }
    print("document >>> $index | ${usr.bayaran}");
    kiraJualan();
  }

  void removeItemSelected(int index) {
    var nama = barangList.keys.elementAt(index);
    barangList.remove(nama);
    kiraJualan();
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Simpan Data')));
    // loadData();
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
    rekodPembekalDetail current = selectDetailBarang.elementAt(
      selectDetailBarang.indexWhere((e) => e.id == selectedDetail),
    );
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
                      ' ${_rekodBarangDetail?.hari}',
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
                      ' ${_rekodBarangDetail?.tarikh}',
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
                      1: FixedColumnWidth(150),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: <TableRow>[
                      TableRow(
                        children: <Widget>[
                          Container(
                            child: Center(
                              child: Text(
                                'Barang',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                'Kuantiti',
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
                    itemCount: barangList.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      var nama = barangList.keys.elementAt(index);
                      var kuantiti = barangList[nama];
                      var unit = senarai_Barang
                          .elementAt(
                            senarai_Barang.indexWhere((e) => e.nama == nama),
                          )
                          .unit;
                      print("menu >> $nama");
                      return GestureDetector(
                        child: Table(
                          border: TableBorder.all(color: colorBorder),
                          columnWidths: const <int, TableColumnWidth>{
                            0: FlexColumnWidth(),
                            1: FixedColumnWidth(150),
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
                                      "$kuantiti $unit",
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
                            "Masukkan data $nama",
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
                    },
                  ),
                  (role.toString().capitalize() == "Admin" ||
                          role.toString().capitalize() == "Manager")
                      ? Container(
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
                                            'Jumlah Barang (RM)',
                                            style: textStyle,
                                          ),
                                        ),
                                        Text(
                                          money(current.jumlah),
                                          style: textStyleNormal,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Jumlah Bayaran (RM)',
                                            style: textStyle,
                                          ),
                                        ),
                                        Text(
                                          money(current.bayaran),
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
                                            'Baki Bayaran (RM)',
                                            style: textStyle,
                                          ),
                                        ),
                                        Text(
                                          money(current.baki),
                                          style: textStyleNormal,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2),
                                    Container(height: 1, color: Colors.grey),
                                    SizedBox(height: 0.5),
                                    Container(height: 1, color: Colors.grey),
                                    SizedBox(height: 10),
                                    GestureDetector(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: ListTile(
                                          title: Text(
                                            "Jumlah Bayaran",
                                            style: TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                      onTap: () async {
                                        showDialogTextJumlahRequired(
                                          context,
                                          "Masukkan Jumlah Barang Dari Pembekal $nama",
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(height: 0),
                  // Container(
                  //   alignment: Alignment.centerRight,
                  //   child: Row(
                  //     children: [
                  //       Spacer(flex: 1),
                  //       Expanded(
                  //         flex: 2,
                  //         child: ElevatedButton(
                  //           onPressed: () {
                  //             _selectDate(context, -1);
                  //           },
                  //           style: ButtonStyle(
                  //             backgroundColor: WidgetStatePropertyAll(color),
                  //           ),
                  //           child: Text(
                  //             'Bayaran',
                  //             style: textStyleBtn,
                  //             textAlign: TextAlign.center,
                  //           ),
                  //         ),
                  //       ),
                  //     ],
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
          if (item == '1') {
            final pdfFile = await PdfPembekalResit.generate(
              PdfColors.black,
              nama,
              tarikh,
            );
            // opening the pdf file
            FileHandleApi.openFile(pdfFile);
          }
        },
        itemBuilder: (BuildContext bc) {
          var menu = const [
            PopupMenuItem(value: '1', child: Text("Resit Order")),
          ];
          return (role.toString().capitalize() == "Admin" ||
                  role.toString().capitalize() == "Manager")
              ? menu
              : [];
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
        actions: <Widget>[settingButton],
        centerTitle: true,
      ),
      body: buildCollectionView,
      floatingActionButton:
          (role.toString().capitalize() == "Admin" ||
              role.toString().capitalize() == "Manager")
          ? FloatingActionButton(
              backgroundColor: color,
              foregroundColor: Colors.white,
              onPressed: () {
                showDialogTextRequired(context, "Masukkan data", -1);
              },
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            )
          : SizedBox(height: 0),
    );
  }
}

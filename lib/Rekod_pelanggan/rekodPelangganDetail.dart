import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../DocumentHelper.dart';
import 'package:notification_center/notification_center.dart';
import '../resit.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class selectRekodPelangganDetail extends StatefulWidget {
  const selectRekodPelangganDetail({
    super.key,
    required this.selectIndex,
    required this.menuList,
    required this.runnerList,
  });

  final int selectIndex;
  final List<rekodMenu> menuList;
  final List<rekodRunner> runnerList;

  @override
  State<selectRekodPelangganDetail> createState() =>
      _selectRekodPelangganDetailState();
}

class _selectRekodPelangganDetailState
    extends State<selectRekodPelangganDetail> {
  int selectIndex = 0;
  int pelangganID = 0;
  int selectedPelanggan = 0;
  String nama = "";
  String tarikhRekod = "";
  String hariRekod = "";
  String masaRekod = "";
  String epochTime = "";
  String lainMenu = "";
  DateTime selectedDate = DateTime.now();
  final TimeOfDay _fromTime = TimeOfDay.now();
  List<rekodMenu> menuList = <rekodMenu>[];
  rekodPelanggan? rekodPelangganDetail;
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  TextStyle titleTextStyle = TextStyle(
    fontSize: 17.0,
    fontWeight: FontWeight.bold,
  );
  TextStyle textStyle = TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold);
  TextStyle textStyleNormal = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.normal,
  );
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
  bool dark = sharedPreferences?.getBool("darkModeStatus") ?? false;
  Color color = Colors.orange;
  Color colorBorder = Colors.black;
  List<rekodPesananPelanggan> _rekodMenu = <rekodPesananPelanggan>[];
  List<rekodRunner> runnerList = <rekodRunner>[];
  List<DropdownMenuItem> dropDownListMenu = <DropdownMenuItem>[];
  List<DropdownMenuItem> dropDownListRunner = <DropdownMenuItem>[];

  Uint8List? logobytes;
  PdfImage? _logoImage;
  final pdf = pw.Document();

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
      colorBorder = Colors.white;
    }
    NotificationCenter().subscribe('refreshData', _refreshView);
    pelangganID = widget.selectIndex;
    menuList = widget.menuList;
    runnerList = widget.runnerList;
    rekodPelanggan currentList = rekod_Pelanggan.elementAt(
      rekod_Pelanggan.indexWhere((e) => e.id == pelangganID),
    );
    rekodPelangganDetail = currentList;
    _refreshView(true);
    for (var index = 0; index < menuList.length; index++) {
      rekodMenu list = menuList.elementAt(index);
      var nama = list.jenis;
      dropDownListMenu.add(
        DropdownMenuItem<String>(
          value: nama.isEmpty == true ? '' : nama,
          child: Text(nama),
        ),
      );
      if (index >= menuList.length - 1) {
        dropDownListMenu.add(
          DropdownMenuItem<String>(value: "", child: Text("Lain-Lain")),
        );
      }
    }
    for (var index = 0; index < runnerList.length; index++) {
      rekodRunner list = runnerList.elementAt(index);
      var nama = list.nama ?? '';
      var username = list.username ?? '';
      print("username >> $nama | $username");
      dropDownListRunner.add(
        DropdownMenuItem<String>(
          value: username.isEmpty == true ? '' : username,
          child: Text(nama),
        ),
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    if (!mounted) return;
  }

  void _refreshView(bool refresh) {
    if (!mounted) return;
    setState(() {
      rekodPelanggan currentList = rekod_Pelanggan.elementAt(
        rekod_Pelanggan.indexWhere((e) => e.id == pelangganID),
      );
      rekodPelangganDetail = currentList;
      epochTime = currentList.epochTime;
      tarikhRekod = currentList.tarikh;
      hariRekod = currentList.hari;
      masaRekod = currentList.masa;
      nama = currentList.nama;
      var list = List<rekodPesananPelanggan>.from(
        currentList.orderMenu,
      ).toList();
      _rekodMenu = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    rekodPelanggan current = rekodPelangganDetail!;
    int runner = current.runner;
    rekodRunner currentRunner = rekod_Runner.elementAt(
      rekod_Runner.indexWhere((e) => e.id == runner),
    );
    String namaRunner = currentRunner.nama;
    String telRunner = currentRunner.telefon;
    String labelRunner = "Self Pickup";
    if (runner != 12) {
      labelRunner = '$namaRunner ($telRunner)';
    }
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.all(5),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            ListTile(
              title: Container(
                // width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Tarikh   : ',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Flexible(
                          child: Text(
                            ' ${current.hari}, ${current.tarikh} ${current.masa}',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Nama    : ',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Flexible(
                          child: Text(
                            ' ${current.nama}',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Telefon : ',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Flexible(
                          child: Text(
                            ' ${current.telefon.replaceAll(" ", "").replaceAll("+6", "")}',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          'Alamat : ',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        Flexible(
                          child: Text(
                            ' ${current.alamat}',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.normal,
                            ),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.clip,
                            softWrap: true,
                            maxLines: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Divider(thickness: 3, height: 13, color: Colors.grey),
            ListTile(
              minTileHeight: 1.0,
              minVerticalPadding: 14,
              trailing: Text(
                'Runner : $labelRunner',
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
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
                      2: FixedColumnWidth(60),
                      3: FixedColumnWidth(80),
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
                                'Kuantiti',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
                            child: Center(
                              child: Text(
                                'Harga',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Container(
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
                    itemCount: _rekodMenu.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      rekodPesananPelanggan current = _rekodMenu.elementAt(
                        index,
                      );
                      String currentPesanan = current.pesanan.toStringAsFixed(
                        1,
                      );
                      if (currentPesanan.contains(".0")) {
                        currentPesanan = current.pesanan.toStringAsFixed(0);
                      }
                      return GestureDetector(
                        child: Table(
                          border: TableBorder.all(color: colorBorder),
                          columnWidths: const <int, TableColumnWidth>{
                            0: FlexColumnWidth(),
                            1: FixedColumnWidth(70),
                            2: FixedColumnWidth(60),
                            3: FixedColumnWidth(80),
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
                                      current.jenis,
                                      style: textStyleNormal,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      currentPesanan,
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
                                SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      money(current.Jumlah),
                                      style: textStyleNormal,
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
                            "Masukkan data ${current.jenis}",
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
                                      'Jumlah Keseluruhan (RM)',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    money(current.jumlahBayaran),
                                    style: textStyle,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Deposit (RM)',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    current.BayaranPendahuluan.toStringAsFixed(
                                      2,
                                    ),
                                    style: textStyle,
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
                                  Text(money(current.baki), style: textStyle),
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
                  Container(
                    alignment: Alignment.centerRight,
                    child: Row(
                      children: [
                        Spacer(flex: 1),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialogEditRequired(context, "Masukkan Data");
                            },
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(color),
                            ),
                            child: Text(
                              'Bayaran',
                              style: textStyleBtn,
                              textAlign: TextAlign.center,
                            ),
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
        onSelected: (item) async {
          // your logic
          if (item == '1') {
            showDialogPesananRequired(context, "Masukkan Data Pelanggan");
          } else if (item == '2') {
            print("invoice >> ${current.noBil}");
            final pdfFile = await PdfInvoicePelanggan.generate(
              PdfColors.black,
              selectIndex,
              current,
            );
            // opening the pdf file
            FileHandleApi.openFile(pdfFile);
          } else if (item == '3') {
            showDialogWhatsappPelanggan(
              context,
              "Buka Whatsapp",
              "pilih mesej untuk di hantar kepada pelanggan",
            );
          }
        },
        itemBuilder: (BuildContext bc) {
          return const [
            PopupMenuItem(value: '1', child: Text("Edit Pesanan")),
            PopupMenuItem(value: '2', child: Text("Resit Pesanan")),
            PopupMenuItem(value: '3', child: Text("Whatsapp Pelanggan")),
          ];
        },
      ),
    );
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Delay code execution by 1 second
            // Pop the page immediately
            Navigator.of(context).pop();
            Future.delayed(Duration(seconds: 1), () {
              loadData();
            });
          },
        ),
        foregroundColor: Colors.transparent,
        title: Text("Detail Pelanggan", style: TextStyle(color: Colors.white)),
        actions: <Widget>[settingButton],
        centerTitle: true,
      ),
      body: buildCollectionView,
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialogTextRequired(context, "Masukkan data", -1);
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
                removeItemSelected(index);
              },
            ),
          ],
        );
      },
    );
  }

  void showDialogWhatsappPelanggan(
    BuildContext context,
    String title,
    String message,
  ) {
    rekodPelanggan current = rekod_Pelanggan.elementAt(
      rekod_Pelanggan.indexWhere((e) => e.id == pelangganID),
    );
    int runner = current.runner;
    rekodRunner currentRunner = rekod_Runner.elementAt(
      rekod_Runner.indexWhere((e) => e.id == runner),
    );
    String namaRunner = currentRunner.nama;
    String telRunner = currentRunner.telefon;
    List<Widget> textButtonList = <Widget>[
      TextButton(
        child: const Text('Pengesahan Pesanan'),
        onPressed: () async {
          launchWhatsappWithMobileNumber(
            current.telefon,
            "Assalamualaikum dan Salam Sejahtera ${current.nama}, \nKami dari Sattay Ussop ingin confirm order pada ${current.hari},${current.tarikh} jam ${current.masa}. Kami sertakan resit sebagai bukti order anda👇🏻.",
          );
          Navigator.of(context).pop();
          final pdfFile = await PdfInvoicePelanggan.generate(
            PdfColors.black,
            selectIndex,
            current,
          );
          // opening the pdf file
          FileHandleApi.openFile(pdfFile);
        },
      ),
      TextButton(
        child: const Text('Batal'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ];
    if (runner > 0 || telRunner != "00") {
      textButtonList.insert(
        1,
        TextButton(
          child: const Text('Pesanan Dalam Perjalanan'),
          onPressed: () {
            launchWhatsappWithMobileNumber(
              current.telefon,
              "Assalamualaikum dan Salam Sejahtera ${current.nama}, \nRunner Sattay Ussop iaitu $runner dalam perjalanan ke tempat anda. \nTerima Kasih membeli di Sattay Ussop. \nSelamat menjamu selera.",
            );
            Navigator.of(context).pop();
          },
        ),
      );
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: textButtonList,
        );
      },
    );
  }

  void showDialogEditRequired(BuildContext context, String title) {
    var myController = TextEditingController();
    String errorText = "Sila masukkan beberapa digit";
    final formKey = GlobalKey<FormState>();
    var bayaran = rekodPelangganDetail?.BayaranPendahuluan ?? 0.0;
    if (bayaran > 0.0) {
      myController.text = "$bayaran";
    }
    // declare a variable to keep track of the input text
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
                      'Bayaran Pendahuluan :',
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
                num pendahuluan = 0.00;
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  if (!(myController.text.isEmpty)) {
                    pendahuluan = myController.text.totalDoubleNumber();
                  }
                  rekodPelangganDetail?.BayaranPendahuluan = pendahuluan;
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

  void showDialogTextRequired(
    BuildContext context,
    String title,
    int index, {
    bool newMenu = false,
  }) {
    final formKey = GlobalKey<FormState>();

    final myController = TextEditingController();
    final myController1 = TextEditingController();
    final myController2 = TextEditingController();
    final FocusNode myFocusNode = FocusNode();

    // Initialize controllers if editing existing item
    if (index >= 0) {
      final current = _rekodMenu.elementAt(index);
      myController.text = current.jenis;
      num pesananValue = current.pesanan;
      myController1.text = pesananValue % 1 == 0
          ? pesananValue.toStringAsFixed(0)
          : pesananValue.toStringAsFixed(1);
      myController2.text = money(current.Harga);
    }
    final values = dropDownListMenu.map((e) => e.value).toList();
    bool isNewMenu = newMenu;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Jenis :', style: textStyle),
                        SizedBox(height: 4),
                        index >= 0
                            ? TextFormField(
                                enableInteractiveSelection: false,
                                // will disable paste operation
                                enabled: false,
                                autofocus: false,
                                controller: myController,
                                decoration: InputDecoration(),
                                textInputAction:
                                    TextInputAction.next, // Moves focus to ne
                              )
                            : isNewMenu
                            ? TextFormField(
                                controller: myController,
                                focusNode: myFocusNode,
                                autofocus: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Sila masukkan menu anda";
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(),
                              )
                            : DropdownButtonFormField(
                                isExpanded: true,
                                items: dropDownListMenu,
                                onChanged: (item) {
                                  if (item == "") {
                                    // Switch to new menu input
                                    setState(() {
                                      isNewMenu = true;
                                      myController.text = "";
                                      // Focus new menu text field
                                      Future.delayed(
                                        Duration(milliseconds: 100),
                                        () => myFocusNode.requestFocus(),
                                      );
                                    });
                                  } else {
                                    myController.text = item!;
                                  }
                                },
                                decoration: InputDecoration(),
                              ),
                        SizedBox(height: 2),
                        Text('Pesanan :', style: textStyle),
                        SizedBox(height: 2),
                        TextFormField(
                          autofocus: index >= 0 ? true : false,
                          controller: myController1,
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Sila masukkan beberapa digit";
                            }
                            return null;
                          },
                          decoration: InputDecoration(),
                        ),
                        SizedBox(height: 2),
                        Text('Harga :', style: textStyle),
                        SizedBox(height: 2),
                        TextFormField(
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
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text("Batal"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text("Simpan"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (formKey.currentState!.validate()) {
                      num pesanan = myController1.text.totalDoubleNumber();
                      num harga = myController2.text.isEmpty
                          ? 0
                          : myController2.text.toDoubleNumberFormat();
                      String nama = myController.text;
                      num jumlah = pesanan * harga;

                      if (index >= 0) {
                        // Update existing
                        final current = _rekodMenu.elementAt(index);
                        current.jenis = nama;
                        current.pesanan = pesanan;
                        current.Harga = harga;
                        current.Jumlah = jumlah;
                        insertServer(current, index);
                      } else {
                        // Add new
                        insertServer(
                          rekodPesananPelanggan(
                            pelangganID,
                            nama,
                            pesanan,
                            harga,
                            jumlah,
                          ),
                          index,
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _selectDate(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendar,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1),
    ).then((selectDate) {
      if (selectDate != null) {
        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          builder: (context, Widget? child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: false),
              child: child!,
            );
          },
        ).then((selectedTime) {
          print("selected time >>> $selectedTime");
          // Handle the selected date and time here.
          if (selectedTime != null) {
            DateTime selectedDateTime = DateTime(
              selectDate.year,
              selectDate.month,
              selectDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
            setState(() {
              Navigator.of(context).pop();
              selectedDate = selectDate;
              hariRekod = DateFormat('EEE').format(selectedDate);
              if (hariRekod.contains("Sun")) {
                hariRekod = "Ahad";
              } else if (hariRekod.contains("Mon")) {
                hariRekod = "Isnin";
              } else if (hariRekod.contains("Tue")) {
                hariRekod = "Selasa";
              } else if (hariRekod.contains("Wed")) {
                hariRekod = "Rabu";
              } else if (hariRekod.contains("Thu")) {
                hariRekod = "Khamis";
              } else if (hariRekod.contains("Fri")) {
                hariRekod = "Jumaat";
              } else if (hariRekod.contains("Sat")) {
                hariRekod = "Sabtu";
              }
              tarikhRekod = DateFormat('dd/MM/yyyy').format(selectedDate);
              var dateFormat = DateFormat("hh:mm a"); // 12-hour with AM/PM
              masaRekod = dateFormat.format(selectedDateTime).toString();
              epochTime = selectedDateTime.millisecondsSinceEpoch.toString();
              print("data time $dateFormat >> $epochTime  >> $tarikhRekod");
              showDialogPesananRequired(context, "Masukkan Data Pelanggan");
            }); // You can use the selectedDateTime as needed.
          }
        });
      }
    });
  }

  void showDialogPesananRequired(BuildContext context, String title) {
    var myController = TextEditingController();
    var myController1 = TextEditingController();
    var myController2 = TextEditingController();
    var myController3 = TextEditingController();
    var myController4 = TextEditingController();
    String errorText = "Sila masukkan beberapa digit";
    final formKey = GlobalKey<FormState>();
    String tarikh = '$hariRekod, $tarikhRekod $masaRekod';
    myController.text = tarikh;
    rekodPelanggan current = rekod_Pelanggan.elementAt(
      rekod_Pelanggan.indexWhere((e) => e.id == pelangganID),
    );
    myController1.text = current.nama;
    myController2.text = current.telefon.cleanNumber();
    myController3.text = current.alamat;
    int runner = current.runner;
    rekodRunner currentRunner = rekod_Runner.elementAt(
      rekod_Runner.indexWhere((e) => e.id == runner),
    );
    String namaRunner = currentRunner.nama;
    String usernameRunner = currentRunner.username;
    print("runner >>> $runner");
    if (runner > 0) {
      myController4.text = usernameRunner;
    }
    final values = dropDownListRunner.map((e) => e.value).toList();

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
                      'Tarikh :',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    TextButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(width: 1.0, color: colorBorder),
                      ),
                      onPressed: () {
                        // Navigator.of(context).pop();
                        _selectDate(context);
                        // _showTimePicker(context);
                      },
                      child: Text(tarikh),
                    ),
                    Container(height: 2),
                    Text('Nama :', style: textStyle, textAlign: TextAlign.left),
                    TextFormField(
                      // The validator receives the text that the user has entered.
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return errorText;
                      //   }
                      //   return null;
                      // },
                      autofocus: true,
                      controller: myController1,
                      textInputAction: TextInputAction.next,
                      // Moves focus to next.
                      decoration: InputDecoration(),
                    ),
                    Container(height: 2),
                    Text(
                      'Telefon :',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    TextFormField(
                      autofocus: false,
                      controller: myController2,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      // Moves focus to next.
                      decoration: InputDecoration(),
                    ),
                    Container(height: 2),
                    Text(
                      'Alamat :',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    TextFormField(
                      autofocus: false,
                      controller: myController3,
                      textInputAction: TextInputAction.next,
                      // Moves focus to next.
                      decoration: InputDecoration(),
                    ),
                    Container(height: 2),
                    Text(
                      'Runner :',
                      style: textStyle,
                      textAlign: TextAlign.left,
                    ),
                    DropdownButtonFormField(
                      isExpanded: true,
                      initialValue: values.contains(myController4.text)
                          ? myController4.text
                          : null,
                      onChanged: (item) {
                        if (item == null) return;
                        var username = item.toString();
                        rekodRunner currentRunner = rekod_Runner.elementAt(
                          rekod_Runner.indexWhere(
                            (e) => e.username == username,
                          ),
                        );
                        runner = currentRunner.id;
                        myController4.text = username;
                      },
                      items: dropDownListRunner,
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
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  String nama = myController1.text;
                  if (nama.isEmpty) {
                    nama = "Customer";
                  }
                  String tarikh = '$hariRekod, $tarikhRekod $masaRekod';
                  String telefon = myController2.text.cleanNumber();
                  String alamat = myController3.text;
                  current.epochTime = epochTime;
                  current.tarikh = tarikhRekod;
                  current.masa = masaRekod;
                  current.hari = hariRekod;
                  current.nama = nama;
                  current.telefon = telefon;
                  current.alamat = alamat;
                  current.runner = runner;
                  String tarikhOrder = current.tarikhOrder == ""
                      ? DateFormat('dd/MM/yyyy').format(DateTime.now())
                      : current.tarikhOrder;
                  if (current.tarikhOrder.isEmpty) {
                    current.tarikhOrder = tarikhOrder;
                  }
                  if (current.noBil.isEmpty) {
                    int totalOrder = rekod_Pelanggan
                        .where(
                          (pelanggan) => pelanggan.tarikh == current.tarikh,
                        )
                        .length;

                    String invoice =
                        'US${tarikhOrder.replaceAll("/", "")}$totalOrder';
                    current.noBil = invoice;
                  }
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

  Future<void> insertServer(rekodPesananPelanggan usr, int index) async {
    print("pelanggan id in save >> $pelangganID");
    if (index > 0) {
      await insertUpdateTable(
        'Pelanggan Detail Rekod',
        usr.toMapServer(),
        id: usr.id,
      );
    } else {
      final result = await insertUpdateTable(
        'Pelanggan Detail Rekod',
        usr.toMapServer(),
      );
      var resultRekod = rekodPesananPelanggan.fromMap(result);
      usr.id = resultRekod.id;
    }
    addItem(usr, index);
  }

  void addItem(rekodPesananPelanggan pesananList, int index) {
    if (index < 0) {
      _rekodMenu.add(pesananList);
    } else {
      rekodPesananPelanggan current = _rekodMenu[index];
      current.Harga = pesananList.Harga;
      current.pesanan = pesananList.pesanan;
      current.Jumlah = pesananList.Jumlah;
    }
    kiraJualan();
  }

  void kiraJualan() {
    rekodPelanggan currentList = rekod_Pelanggan.elementAt(
      rekod_Pelanggan.indexWhere((e) => e.id == pelangganID),
    );
    setState(() {
      num jumlahSebenar = 0.00;
      for (var index = 0; index < _rekodMenu.length; index++) {
        rekodPesananPelanggan current = _rekodMenu.elementAt(index);
        num jualan = current.Jumlah;
        jumlahSebenar = jumlahSebenar + jualan;
      }
      num pendahuluan = currentList.BayaranPendahuluan ?? 0.00;
      num baki = jumlahSebenar - pendahuluan;
      currentList.orderMenu = _rekodMenu;
      currentList.jumlahBayaran = jumlahSebenar;
      currentList.baki = baki;
      print("start rekod kira >>> $jumlahSebenar | $pendahuluan  | $baki");
      insertServerPelanggan(currentList);
    });
  }

  Future<void> insertServerPelanggan(rekodPelanggan usr) async {
    final result = await insertUpdateTable(
      'Pelanggan Rekod',
      usr.toMapServer(),
      id: pelangganID,
    );
    var resultRekod = rekodPelanggan.fromMap(result);
    insertStok(epochTime, tarikhRekod, hariRekod);
    addItemPesanan(resultRekod);
  }

  void addItemPesanan(rekodPelanggan usr) {
    rekodPelanggan current = rekod_Pelanggan.elementAt(
      rekod_Pelanggan.indexWhere((e) => e.id == pelangganID),
    );
    num rekod = usr.baki;
    if (rekod <= 0.00 && usr.orderMenu.isNotEmpty) {
      current.bayaranPenuh = true;
    } else {
      current.bayaranPenuh = false;
    }
    setState(() {
      current.nama = usr.nama;
      current.alamat = usr.alamat;
      current.telefon = usr.telefon;
      current.runner = usr.runner;
      current.epochTime = epochTime;
      current.tarikh = tarikhRekod;
      current.masa = masaRekod;
      current.hari = hariRekod;
    });
    if (!rekod_stok.map((item) => item.tarikh).contains(usr.tarikh)) {
      List<dynamic> rekod = <rekodStokDetail>[];
      rekod_stok.add(
        rekodStok(epochTime, tarikhRekod, hariRekod, 0.00, 0.00, rekod),
      );
    }
    saveData();
  }

  void removeItemSelected(int index) {
    _rekodMenu.removeAt(index);
    kiraJualan();
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
    updateStok(tarikhRekod);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Simpan Data')));
    // loadData();
  }
}

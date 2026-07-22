import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import '../resit.dart';
import '../DocumentHelper.dart';
import '../databaseLocal.dart';

class selectRekodGajiFilter extends StatefulWidget {
  const selectRekodGajiFilter({super.key, required this.pekerja});

  final List<rekodPekerja> pekerja;

  @override
  State<selectRekodGajiFilter> createState() => _selectRekodGajiFilterState();
}

class _selectRekodGajiFilterState extends State<selectRekodGajiFilter> {
  final List<rekodGajiFilter> _rekodGajiDetail = <rekodGajiFilter>[];
  List<rekodPekerja> pekerja = <rekodPekerja>[];
  List<rekodMenu> menuList = <rekodMenu>[];
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
  String filterName = "Semua Pekerja";
  num jumlahHarian = 0.00;
  num JumlahSimpan = 0.00;
  num jumlahGajiAmbil = 0.00;

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
      colorBorder = Colors.white;
    }
    pekerja = widget.pekerja;
    for (var index = 0; index < pekerja.length; index++) {
      rekodPekerja list = pekerja.elementAt(index);
      var username = list.username;
      var nama = list.nama;
      dropDownList.add(
        DropdownMenuItem<String>(value: username, child: Text(nama)),
      );
    }
    dropDownList.insert(
      0,
      DropdownMenuItem<String>(
        value: 'Semua Pekerja',
        child: Text('Semua Pekerja'),
      ),
    );
    _refreshView();
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
  }

  void _refreshView() {
    setState(() {
      _rekodGajiDetail.clear();
      jumlahHarian = 0.00;
      JumlahSimpan = 0.00;
      jumlahGajiAmbil = 0.00;
      for (var index = 0; index < rekod_Gaji.length; index++) {
        rekodGaji gajiList = rekod_Gaji.elementAt(index);
        String tarikh = gajiList.tarikh;
        List<rekodGajiDetail> rekod = List<rekodGajiDetail>.from(
          gajiList.rekod,
        ).toList();
        for (var k = 0; k < rekod.length; k++) {
          rekodGajiDetail current = rekod.elementAt(k);
          String userName = rekod_Pekerja
              .elementAt(
                rekod_Pekerja.indexWhere((e) => e.id == current.pekerja_id),
              )
              .username;
          String nama = rekod_Pekerja
              .elementAt(
                rekod_Pekerja.indexWhere((e) => e.id == current.pekerja_id),
              )
              .nama;
          num harian = current.harian;
          num simpan = current.simpan;
          if (filterName == userName) {
            jumlahHarian = jumlahHarian + harian;
            JumlahSimpan = JumlahSimpan + simpan;
            if (_rekodGajiDetail.map((item) => item.tarikh).contains(tarikh)) {
              rekodGajiFilter currentfilter = _rekodGajiDetail.elementAt(
                _rekodGajiDetail.indexWhere(
                  (element) => element.tarikh == tarikh,
                ),
              );
              currentfilter.harian = currentfilter.harian + harian;
              currentfilter.simpan = currentfilter.simpan + simpan;
            } else {
              _rekodGajiDetail.add(
                rekodGajiFilter(tarikh, nama, harian, simpan, 0.00),
              );
            }
          } else if (filterName == "Semua Pekerja") {
            jumlahHarian = jumlahHarian + harian;
            JumlahSimpan = JumlahSimpan + simpan;
            if (_rekodGajiDetail.map((item) => item.tarikh).contains(tarikh)) {
              rekodGajiFilter currentfilter = _rekodGajiDetail.elementAt(
                _rekodGajiDetail.indexWhere(
                  (element) => element.tarikh == tarikh,
                ),
              );
              currentfilter.harian = currentfilter.harian + harian;
              currentfilter.simpan = currentfilter.simpan + simpan;
            } else {
              _rekodGajiDetail.add(
                rekodGajiFilter(tarikh, nama, harian, simpan, 0.00),
              );
            }
          }
        }
      }
      for (var index = 0; index < pekerja.length; index++) {
        rekodPekerja currentPekerja = pekerja.elementAt(index);
        String nama = currentPekerja.username;
        if (filterName == nama) {
          List<rekodAmbilGaji> rekodAmbil = List<rekodAmbilGaji>.from(
            currentPekerja.rekodAmbil,
          ).toList();
          for (var i = 0; i < rekodAmbil.length; i++) {
            rekodAmbilGaji current = rekodAmbil.elementAt(i);
            String tarikh0 = current.tarikh;
            num jumlahAmbil = current.jumlah;
            jumlahGajiAmbil = jumlahGajiAmbil + jumlahAmbil;
            print("rekod ambil >> $tarikh0 = $jumlahAmbil");
            if (_rekodGajiDetail.map((item) => item.tarikh).contains(tarikh0)) {
              rekodGajiFilter currentfilter = _rekodGajiDetail.elementAt(
                _rekodGajiDetail.indexWhere(
                  (element) => element.tarikh == tarikh0,
                ),
              );
              currentfilter.ambil = jumlahAmbil;
            } else {
              _rekodGajiDetail.add(
                rekodGajiFilter(tarikh0, nama, 0.00, 0.00, jumlahAmbil),
              );
            }
          }
        } else if (filterName == "Semua Pekerja") {
          List<rekodAmbilGaji> rekodAmbil = List<rekodAmbilGaji>.from(
            currentPekerja.rekodAmbil,
          ).toList();
          for (var i = 0; i < rekodAmbil.length; i++) {
            rekodAmbilGaji current = rekodAmbil.elementAt(i);
            String tarikh0 = current.tarikh;
            num jumlahAmbil = current.jumlah;
            jumlahGajiAmbil = jumlahGajiAmbil + jumlahAmbil;
            print("rekod ambil >> $tarikh0 = $jumlahAmbil");
            if (_rekodGajiDetail.map((item) => item.tarikh).contains(tarikh0)) {
              rekodGajiFilter currentfilter = _rekodGajiDetail.elementAt(
                _rekodGajiDetail.indexWhere(
                  (element) => element.tarikh == tarikh0,
                ),
              );
              currentfilter.ambil = jumlahAmbil;
            } else {
              _rekodGajiDetail.add(
                rekodGajiFilter(tarikh0, nama, 0.00, 0.00, jumlahAmbil),
              );
            }
          }
        }
      }
      _rekodGajiDetail.sort((a, b) => a.tarikh.compareTo(b.tarikh));
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
    bool showGajiAmbil = false;
    if (jumlahGajiAmbil > 0) {
      showGajiAmbil = true;
    }
    var nama = filterName;
    if (filterName != "Semua Pekerja") {
      nama = rekod_Pekerja
          .elementAt(rekod_Pekerja.indexWhere((e) => e.username == filterName))
          .nama;
    }
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
                initiallyExpanded: true,
                title: Text(nama),
                children: <Widget>[
                  Divider(thickness: 1, height: 10, color: Colors.grey),
                  ListTile(
                    leading: Text(
                      "Filter Rekod : ",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    title: DropdownButtonFormField(
                      elevation: 8,
                      isExpanded: true,
                      onChanged: (item) {
                        setState(() {
                          filterName = item.toString();
                          _refreshView();
                        });
                      },
                      hint: Text('Senarai Pekerja'),
                      items: dropDownList,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                primary: true,
                children: <Widget>[
                  Table(
                    border: TableBorder.all(color: colorBorder),
                    columnWidths: const <int, TableColumnWidth>{
                      0: FixedColumnWidth(120),
                      1: FlexColumnWidth(),
                      2: FlexColumnWidth(),
                      3: FlexColumnWidth(),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: <TableRow>[
                      TableRow(
                        children: <Widget>[
                          SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                'Tarikh',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                'Harian (RM)',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                'Simpan (RM)',
                                style: textStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                            child: Center(
                              child: Text(
                                'Ambil (RM)',
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
                    itemCount: _rekodGajiDetail.length,
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      rekodGajiFilter current = _rekodGajiDetail.elementAt(
                        index,
                      );
                      return GestureDetector(
                        child: Table(
                          border: TableBorder.all(color: colorBorder),
                          columnWidths: const <int, TableColumnWidth>{
                            0: FixedColumnWidth(120),
                            1: FlexColumnWidth(),
                            2: FlexColumnWidth(),
                            3: FlexColumnWidth(),
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
                                      current.tarikh,
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      '${current.harian}',
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      '${current.simpan}',
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: Text(
                                      '${current.ambil}',
                                      style: textStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
                                      'Jumlah Harian (RM)',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    money(jumlahHarian),
                                    style: textStyleNormal,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Jumlah Simpan (RM)',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    money(JumlahSimpan),
                                    style: textStyleNormal,
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Jumlah Pendapatan (RM)',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    money(jumlahHarian + JumlahSimpan),
                                    style: textStyleNormal,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              SizedBox(height: 5),
                              showGajiAmbil
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Jumlah Ambil (RM)',
                                            style: textStyle,
                                          ),
                                        ),
                                        Text(
                                          money(jumlahGajiAmbil),
                                          style: textStyleNormal,
                                        ),
                                      ],
                                    )
                                  : SizedBox(height: 0),
                              showGajiAmbil
                                  ? SizedBox(height: 5)
                                  : SizedBox(height: 0),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text('KWSP (RM)', style: textStyle),
                                  ),
                                  Text(
                                    money(((JumlahSimpan * 11) / 100).round()),
                                    style: textStyleNormal,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Jumlah Potongan (RM)',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    money(
                                      (jumlahGajiAmbil +
                                          (((JumlahSimpan * 11) / 100))
                                              .round()),
                                    ),
                                    style: textStyleNormal,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'KWSP Majikan (RM)',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    money(
                                      (((JumlahSimpan * 13) / 100).round()),
                                    ),
                                    style: textStyleNormal,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Baki Gaji (RM)',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    money(
                                      (JumlahSimpan -
                                          jumlahGajiAmbil -
                                          (((JumlahSimpan * 11) / 100))
                                              .round()),
                                    ),
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
                                      'Gaji Bersih (RM)',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    money(
                                      (JumlahSimpan -
                                          jumlahGajiAmbil -
                                          (((JumlahSimpan * 11) / 100))
                                              .round()),
                                    ),
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
        onSelected: (item) async {
          // your logic
          if (item == '1') {
            final pdfFile = await PdfDetailGaji.generate(
              PdfColors.black,
              filterName,
            );
            // opening the pdf file
            FileHandleApi.openFile(pdfFile);
          }
        },
        itemBuilder: (BuildContext bc) {
          return const [
            PopupMenuItem(value: '1', child: Text("Slip Gaji Terperinci")),
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
        title: Text("Rekod Cucuk", style: TextStyle(color: Colors.white)),
        actions: <Widget>[settingButton],
        centerTitle: true,
      ),
      body: buildCollectionView,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:sattayussop/resit.dart';
import 'package:string_capitalize/string_capitalize.dart';
import 'package:sattayussop/DocumentHelper.dart';
import '../databaseLocal.dart';

class selectRekodCucukFilter extends StatefulWidget {
  const selectRekodCucukFilter({
    super.key,
    required this.pekerja,
    required this.menuList,
  });

  final List<rekodPekerja> pekerja;
  final List<rekodMenu> menuList;

  @override
  State<selectRekodCucukFilter> createState() => _selectRekodCucukFilterState();
}

class _selectRekodCucukFilterState extends State<selectRekodCucukFilter> {
  final List<rekodCucukFilter> _rekodCucukDetail = <rekodCucukFilter>[];
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
  int jumlahSatay = 0;
  num jumlahGaji = 0.00;
  num jumlahGajiAmbil = 0.00;

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
      colorBorder = Colors.white;
    }
    pekerja = widget.pekerja;
    menuList = widget.menuList;
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
      _rekodCucukDetail.clear();
      jumlahSatay = 0;
      jumlahGaji = 0.00;
      jumlahGajiAmbil = 0.00;
      if (filterName == "Semua Pekerja") {
        for (var i = 0; i < pekerja.length; i++) {
          rekodPekerja gaji = pekerja.elementAt(i);
          List<rekodAmbilGaji> rekod = List<rekodAmbilGaji>.from(
            gaji.rekodAmbil,
          ).toList();
          for (var l = 0; l < rekod.length; l++) {
            rekodAmbilGaji gajiRekod = rekod.elementAt(l);
            jumlahGajiAmbil = jumlahGajiAmbil + gajiRekod.jumlah;
          }
        }
      } else if (filterName != "") {
        rekodPekerja gaji =
            pekerja[pekerja.indexWhere(
              (element) => element.username == filterName,
            )];
        List<rekodAmbilGaji> rekod = List<rekodAmbilGaji>.from(
          gaji.rekodAmbil,
        ).toList();
        for (var l = 0; l < rekod.length; l++) {
          rekodAmbilGaji gajiRekod = rekod.elementAt(l);
          jumlahGajiAmbil = jumlahGajiAmbil + gajiRekod.jumlah;
        }
      }
      for (var index = 0; index < rekod_Cucuk.length; index++) {
        rekodCucuk cucukList = rekod_Cucuk.elementAt(index);
        String tarikh = cucukList.tarikh;
        List<rekodCucukDetail> stokCucuk = List<rekodCucukDetail>.from(
          cucukList.rekod,
        ).toList();
        for (var k = 0; k < stokCucuk.length; k++) {
          rekodCucukDetail current = stokCucuk.elementAt(k);
          print("record >> ${current.toMap()}");
          int idPekerja = current.pekerja_id;
          if (idPekerja > 0) {
            var indexPekerja = pekerja.indexWhere(
              (element) => element.id == idPekerja,
            );
            if (indexPekerja == -1) {
              print(
                "Pekerja tidak dijumpai. id = $idPekerja == ${current.nama}",
              );
              continue;
            }
            rekodPekerja gaji = pekerja.elementAt(indexPekerja);
            int jumlah = current.jumlah;
            String nama = gaji.username;
            if (filterName == nama) {
              jumlahSatay = jumlahSatay + jumlah;
              num gajiHarian = gaji.gajiHarian;
              num gajiPekerja = jumlah * gajiHarian;
              jumlahGaji = jumlahGaji + gajiPekerja;
              if (!_rekodCucukDetail
                  .map((item) => item.tarikh)
                  .contains(tarikh)) {
                _rekodCucukDetail.add(rekodCucukFilter(tarikh, nama, jumlah));
              } else {
                rekodCucukFilter currentfilter = _rekodCucukDetail.elementAt(
                  _rekodCucukDetail.indexWhere(
                    (element) => element.tarikh == tarikh,
                  ),
                );
                jumlah = currentfilter.jumlah + jumlah;
                currentfilter.jumlah = jumlah;
              }
            } else if (filterName == "Semua Pekerja") {
              jumlahSatay = jumlahSatay + jumlah;
              num gajiHarian = gaji.gajiHarian;
              num gajiPekerja = jumlah * gajiHarian;
              jumlahGaji = jumlahGaji + gajiPekerja;
              if (!_rekodCucukDetail
                  .map((item) => item.tarikh)
                  .contains(tarikh)) {
                _rekodCucukDetail.add(rekodCucukFilter(tarikh, nama, jumlah));
              } else {
                rekodCucukFilter currentfilter = _rekodCucukDetail.elementAt(
                  _rekodCucukDetail.indexWhere(
                    (element) => element.tarikh == tarikh,
                  ),
                );
                jumlah = currentfilter.jumlah + jumlah;
                currentfilter.jumlah = jumlah;
              }
            }
          }
        }
      }
      _rekodCucukDetail.sort((a, b) => a.tarikh.compareTo(b.tarikh));
      print("Jumlah ambil >> $jumlahGajiAmbil");
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
      margin: EdgeInsets.only(top: 5),
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
                                'Tarikh',
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
                      rekodCucukFilter current = _rekodCucukDetail.elementAt(
                        index,
                      );
                      return GestureDetector(
                        child: Table(
                          border: TableBorder.all(color: colorBorder),
                          columnWidths: const <int, TableColumnWidth>{
                            0: FlexColumnWidth(),
                            1: FlexColumnWidth(),
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
                                      'Jumlah Satay',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text("$jumlahSatay", style: textStyleNormal),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Jumlah Gaji (RM)',
                                      style: textStyle,
                                    ),
                                  ),
                                  Text(
                                    money(jumlahGaji),
                                    style: textStyleNormal,
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              showGajiAmbil
                                  ? Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Jumlah Gaji Ambil (RM)',
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
                                    money(jumlahGaji - jumlahGajiAmbil),
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
            final pdfFile = await PdfCucukGaji.generate(
              PdfColors.black,
              filterName,
            );
            // opening the pdf file
            FileHandleApi.openFile(pdfFile);
          }
        },
        itemBuilder: (BuildContext bc) {
          var menu = const [
            PopupMenuItem(value: '1', child: Text("Slip Gaji")),
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
        title: Text("Rekod Cucuk", style: TextStyle(color: Colors.white)),
        actions: <Widget>[settingButton],
        centerTitle: true,
      ),
      body: buildCollectionView,
    );
  }
}

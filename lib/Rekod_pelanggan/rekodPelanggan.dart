import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:sattayussop/DocumentHelper.dart';
import 'package:sattayussop/Rekod_pelanggan/rekodPelangganDetail.dart';
import 'package:notification_center/notification_center.dart';
import '../databaseLocal.dart';
import '../supabaseServer.dart';

class RekodPelanggan extends StatefulWidget {
  const RekodPelanggan({super.key});

  @override
  State<RekodPelanggan> createState() => _selectRekodPelangganState();
}

class _selectRekodPelangganState extends State<RekodPelanggan> {
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  final myController = TextEditingController();
  String nama = "";
  String tarikhRekod = "";
  String hariRekod = "";
  String masaRekod = "";
  String epochTime = "";
  int selectedIndex = 0;
  DateTime selectedDate = DateTime.now();
  final TimeOfDay _fromTime = TimeOfDay.now();
  List<rekodRunner> runnerList = <rekodRunner>[];
  List<rekodMenu> menuList = <rekodMenu>[];
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
  List<DropdownMenuItem> dropDownListRunner = <DropdownMenuItem>[];

  @override
  void initState() {
    if (dark) {
      color = Colors.deepOrange;
    }
    NotificationCenter().subscribe('refreshData', _refreshView);
    loadData();
    final list = sortMenuList(rekod_Menu);
    for (var index = 0; index < list.length; index++) {
      rekodMenu current = list.elementAt(index);
      menuList.insert(menuList.length, current);
    }
    for (var index = 0; index < rekod_Runner.length; index++) {
      rekodRunner list = rekod_Runner.elementAt(index);
      var nama = list.nama;
      var username = list.username;
      runnerList.add(list);
      dropDownListRunner.add(
        DropdownMenuItem<String>(
          value: username.isEmpty == true ? '' : username,
          child: Text(nama),
        ),
      );
    }
    print("runner list >> $runnerList");
    runnerList.sort((a, b) => a.username.compareTo(b.username));
    super.initState();
  }

  void _refreshView(bool refresh) {
    print("listen rekod pelanggan list");
    setState(() {});
  }

  @override
  void dispose() {
    if (!mounted) return;
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    loadDataServer();
    super.dispose();
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
    Container buildCollectionView;
    buildCollectionView = Container(
      margin: EdgeInsets.only(top: 5),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: rekod_Pelanggan.length,
        itemBuilder: (BuildContext context, int index) {
          rekodPelanggan current = rekod_Pelanggan.elementAt(index);
          bool fullPayment = current.bayaranPenuh;
          return GestureDetector(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          current.nama,
                          style: textStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(current.noBil, style: const TextStyle(fontSize: 12)),
                    ],
                  ),

                  subtitle: Text(
                    '${current.tarikh} ${current.masa}',
                    style: textStyleNormal,
                    textAlign: TextAlign.left,
                  ),
                  trailing: fullPayment
                      ? Icon(Icons.check_circle_rounded, color: Colors.green)
                      : SizedBox(height: 0),
                ),
                Divider(thickness: 1, height: 10, color: Colors.grey),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => selectRekodPelangganDetail(
                    selectIndex: rekod_Pelanggan.elementAt(index).id,
                    menuList: menuList,
                    runnerList: runnerList,
                  ),
                ),
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
    );

    final settingButton = Padding(
      padding: EdgeInsets.only(right: 5.0),
      child: PopupMenuButton(
        icon: more_rev_Icon,
        onSelected: (item) {
          // your logic
          // if (item == '1') {

          // }
        },
        itemBuilder: (BuildContext bc) {
          return const [
            // PopupMenuItem(
            //   child: Text("Tetapan Runner"),
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
        title: Text("Senarai Pesanan", style: TextStyle(color: Colors.white)),
        actions: <Widget>[],
        centerTitle: true,
      ),
      body: buildCollectionView,
      floatingActionButton: FloatingActionButton(
        backgroundColor: color,
        foregroundColor: Colors.white,
        onPressed: () {
          _selectDate(context);
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
                removeItemInServer(index);
              },
            ),
          ],
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
              var dateFormat = DateFormat(
                "hh:mm a",
              ); // you can change the format here
              masaRekod = dateFormat.format(selectedDateTime).toString();
              epochTime = selectedDateTime.millisecondsSinceEpoch.toString();
              showDialogTextRequired(context, "Masukkan Data Pelanggan");
            }); // You can use the selectedDateTime as needed.
          }
        });
      }
    });
  }

  void showDialogTextRequired(BuildContext context, String title) {
    var myController = TextEditingController();
    var myController1 = TextEditingController();
    var myController2 = TextEditingController();
    var myController3 = TextEditingController();
    var myController4 = TextEditingController();
    String errorText = "Sila masukkan rekod ini";
    int runnerID = 12;
    final formKey = GlobalKey<FormState>();
    String tarikh = '$hariRekod, $tarikhRekod $masaRekod';
    myController.text = tarikh;
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
                    Text('Nama :', style: textStyle, textAlign: TextAlign.left),
                    TextFormField(
                      // The validator receives the text that the user has entered.
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          myController1.text = "Customer";
                        }
                        return null;
                      },
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
                      keyboardType: TextInputType.number,
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
                      onChanged: (item) {
                        var username = item.toString();
                        var current = rekod_Runner.elementAt(
                          rekod_Runner.indexWhere(
                            (e) => e.username == username,
                          ),
                        );
                        runnerID = current.id;
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
                  String telefon = myController2.text.cleanNumber();
                  String alamat = myController3.text;
                  List<dynamic> rekod = <rekodPesananPelanggan>[];
                  String tarikhOrder = DateFormat(
                    'dd/MM/yyyy',
                  ).format(DateTime.now());
                  int totalOrder = rekod_Pelanggan
                      .where(
                        (pelanggan) => pelanggan.tarikhOrder == tarikhOrder,
                      )
                      .length;
                  String invoice =
                      'US${tarikhOrder.replaceAll("/", "")}$totalOrder';
                  print(
                    "Total orders on $tarikhOrder: $totalOrder >> $invoice",
                  );
                  insertServer(
                    rekodPelanggan(
                      invoice,
                      epochTime,
                      tarikhOrder,
                      tarikhRekod,
                      masaRekod,
                      hariRekod,
                      nama,
                      telefon,
                      alamat,
                      runnerID,
                      rekod,
                      0.00,
                      0.00,
                      0.00,
                      false,
                    ),
                  );
                }
                // Handle the submit action
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> insertServer(rekodPelanggan usr) async {
    final result = await insertUpdateTable(
      'Pelanggan Rekod',
      usr.toMapServer(),
    );
    var resultRekod = rekodPelanggan.fromMap(result);
    usr.id = resultRekod.id;
    addItem(usr);
  }

  // addItem adds our User Class item to list.
  void addItem(rekodPelanggan usr) {
    rekod_Pelanggan.add(usr);
    insertStok(usr.epochTime, usr.tarikh, usr.hari);
    saveData();
  }

  void removeItemInServer(int index) {
    tarikhRekod = rekod_Pelanggan[index].tarikh;
    var id = rekod_Pelanggan[index].id;
    deleteRow('Pelanggan Rekod', id);
    removeItem(index);
  }

  void removeItem(int index) {
    rekod_Pelanggan.removeAt(index);
    saveData();
  }

  // This block saves our list locally.
  void saveData() {
    saveDataLocal();
    print("save rekod pelanggan >> $tarikhRekod");
    updateStok(tarikhRekod);
  }
}

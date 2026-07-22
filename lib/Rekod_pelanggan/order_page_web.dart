import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notification_center/notification_center.dart';
import 'package:provider/provider.dart';
import '../DocumentHelper.dart';
import '../databaseLocal.dart';
import '../main.dart';
import '../supabaseServer.dart';

// class MenuItemModel {
//   final String nama;
//   final double harga;
//   int qty;
//
//   MenuItemModel({
//     required this.nama,
//     required this.harga,
//     this.qty = 0,
//   });
// }

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final dateController = TextEditingController();
  final namaController = TextEditingController();
  final phoneController = TextEditingController();
  final alamatController = TextEditingController();
  final kuantitiController = TextEditingController();

  final FocusNode namaFocus = FocusNode();

  final _formKeyDetail = GlobalKey<FormState>();
  final _formKeyDate = GlobalKey<FormState>();
  final _formKey = GlobalKey<FormState>();
  bool darkMode = false;

  final List<rekodMenu> menu = <rekodMenu>[];
  final num qty = 0;
  String invoice = "";
  num get total {
    num jumlah = 0;

    for (var item in order) {
      jumlah += item.pesanan * item.Harga;
    }

    return jumlah;
  }

  num get jumlahItem {
    num totalQty = 0;

    for (var item in order) {
      totalQty += item.pesanan;
    }

    return totalQty;
  }

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
    color: Colors.grey,
  );

  Color color = Colors.orange;
  List<rekodMenu> menuList = <rekodMenu>[];
  List<rekodPesananPelanggan> order = <rekodPesananPelanggan>[];
  List<DropdownMenuItem<String>> dropDownList = <DropdownMenuItem<String>>[];
  List<rekodMenu> rekod_Menu = <rekodMenu>[];
  DateTime selectedDate = DateTime.now();
  String TarikhPesanan = "Sila tetapkan tarikh pesanan anda";
  String tarikhOrder = "";
  String tarikhRekod = "";
  String hariRekod = "";
  String masaRekod = "";
  String epochTime = "";
  String jenis = "";
  num harga = 0.00;
  int usrID = -1;
  String? selectedMenu;

  Future<void> loadData() async {
    NotificationCenter().subscribe('refreshData', _refreshView);
    final menuListData = await selectTable('Menu Rekod', "");
    rekod_Menu = menuListData.map((e) => rekodMenu.fromMap(e)).toList();
    rekod_Menu.sort((a, b) => a.jenis.compareTo(b.jenis));
    final list = sortMenuList(rekod_Menu);
    menuList.clear();
    dropDownList.clear();

    for (var i = 0; i < list.length; i++) {
      var element = list.elementAt(i);
      String nama = element.jenis;
      if (nama.toLowerCase().contains("cod")) {
        continue;
      } else if (nama.toLowerCase().contains("box")) {
        nama = "Box Satay";
      }
      menuList.insert(menuList.length, element);

      dropDownList.add(
        DropdownMenuItem<String>(
          value: "${element.id}",
          child: Text("$nama : RM ${element.Harga.toStringAsFixed(2)}"),
        ),
      );
    }
    darkMode = await loadDataDarkMode();
    if (mounted) {
      setState(() {
        namaController.text = "";
        phoneController.text = "";
        alamatController.text = "";
        kuantitiController.text = "";
      });
    }
  }

  void _refreshView(bool refresh) {
    if (mounted) {
      print("listen rekod pelanggan list");
      setState(() {});
    }
  }

  //  This block loads our previously-stored list with key 'list'.
  Future<bool> loadDataDarkMode() async {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(
      context,
      listen: false,
    );
    bool dark = sharedPreferences?.getBool("darkModeStatus") ?? false;
    if (dark) {
      themeNotifier.setTheme(ThemeMode.dark);
      color = Colors.deepOrange;
    } else {
      themeNotifier.setTheme(ThemeMode.light);
      color = Colors.orange;
    }
    return dark;
  }

  @override
  void initState() {
    super.initState();
    loadData();
    print("rekod list >> ${rekod_Menu.length} | ${menuList.length}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: Colors.transparent,
        title: const Text(
          "Selamat Datang ke Satay Ussop! 👋",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15),
        color: Colors.white,
        child: GestureDetector(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                "Hantar Pesanan",
                style: textStyleBtn,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          onTap: () async {
            if (!((_formKeyDetail.currentState!.validate()) ||
                (order.isEmpty && _formKey.currentState!.validate()) ||
                _formKeyDate.currentState!.validate())) {
              return;
            }
            print(total);
            String nama = namaController.text.isEmpty
                ? "Customer"
                : namaController.text;
            String noTel = phoneController.text;
            String alamat = alamatController.text;

            insertServer(
              rekodPelanggan(
                invoice,
                epochTime,
                tarikhOrder,
                tarikhRekod,
                masaRekod,
                hariRekod,
                nama,
                noTel,
                alamat,
                13,
                order,
                total,
                0.00,
                0.00,
                false,
              ),
            );
          },
        ),
      ),
      body: Form(
        key: _formKeyDetail,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            Text(
              '''
Sila isi pesanan anda di bawah dan tekan Hantar Pesanan untuk menghantar pesanan.
📌 Harga pesanan tidak termasuk caj penghantaran. Kami akan menghubungi anda melalui WhatsApp selepas pesanan diterima untuk pengesahan dan memaklumkan jumlah bayaran keseluruhan.
''',
              style: textStyle,
              textAlign: .center,
            ),
            Row(
              children: [
                Text("Tarikh          : ", style: textStyle),
                const SizedBox(width: 10),
                Expanded(
                  child: Form(
                    key: _formKeyDate,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: dateController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Sila pilih tarikh';
                            }
                            return null;
                          },
                          decoration: InputDecoration(labelText: ""),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text("Nama          : ", style: textStyle),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: namaController,
                    decoration: const InputDecoration(labelText: ""),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Sila masukkan nama anda';
                      }
                      return null;
                    },
                    focusNode: namaFocus,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text("No Telefon  : ", style: textStyle),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(labelText: ""),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Sila masukkan no. telefon anda untuk kami hubungi.";
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text("Alamat         : ", style: textStyle),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: alamatController,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(labelText: ""),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("Menu Order : ", style: textStyle),

                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedMenu,
                          isExpanded: true,
                          autovalidateMode:
                              AutovalidateMode.onUserInteractionIfError,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Sila pilih menu pesanan anda.";
                            }
                            return null;
                          },
                          hint: Text("Sila pilih menu yang anda ingin pesan"),
                          items: dropDownList,
                          onChanged: (value) {
                            var id = int.parse(value.toString());
                            final index = menuList.indexWhere(
                              (e) => e.id == id,
                            );

                            if (index == -1) {
                              print("Menu tidak dijumpai: $id");
                              return;
                            }
                            rekodMenu current = menuList.elementAt(index);
                            setState(() {
                              selectedMenu = value;
                              jenis = current.jenis;
                              harga = current.Harga;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text("Kuantiti       : ", style: textStyle),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: kuantitiController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: ""),
                          autovalidateMode:
                              AutovalidateMode.onUserInteractionIfError,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Sila masukkan kuantiti yang ingin dipesan.";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    "Tambah Pesanan",
                    style: textStyleBtn,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              onTap: () async {
                num kuantiti = 0;
                if (_formKey.currentState!.validate()) {
                  if (kuantitiController.text.contains(".")) {
                    kuantiti = kuantitiController.text.toDoubleNumberFormat();
                  } else {
                    kuantiti = kuantitiController.text.totalIntNumber();
                  }
                  if (jenis.isNotEmpty && kuantiti > 0 && harga > 0) {
                    num jumlah = kuantiti * harga;
                    order.insert(
                      order.length,
                      rekodPesananPelanggan(-1, jenis, kuantiti, harga, jumlah),
                    );
                    setState(() {
                      kuantitiController.clear();
                      selectedMenu = null;
                      jenis = "";
                      harga = 0;
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 20),
            Divider(thickness: 3, height: 13, color: Colors.grey),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  border: TableBorder.all(color: Colors.grey),
                  columnWidths: const <int, TableColumnWidth>{
                    0: FlexColumnWidth(),
                    1: FixedColumnWidth(70),
                    2: FixedColumnWidth(60),
                    3: FixedColumnWidth(80),
                    4: FixedColumnWidth(80),
                  },
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  children: [
                    TableRow(
                      children: [
                        headerCell("Produk"),
                        headerCell("Kuantiti"),
                        headerCell("Harga"),
                        headerCell("Jumlah"),
                        headerCell("Tindakan"),
                      ],
                    ),
                    // Data
                    ...order.asMap().entries.map((entry) {
                      final index = entry.key;
                      final current = entry.value;

                      String currentPesanan = current.pesanan.toStringAsFixed(
                        1,
                      );
                      if (currentPesanan.endsWith(".0")) {
                        currentPesanan = current.pesanan.toStringAsFixed(0);
                      }

                      return TableRow(
                        children: [
                          tableCell(
                            current.jenis,
                            onTap: () {
                              showDialogTextRequired(
                                context,
                                "Masukkan data ${current.jenis}",
                                index,
                              );
                            },
                          ),
                          tableCell(currentPesanan),
                          tableCell(money(current.Harga)),
                          tableCell(money(current.Jumlah)),
                          // Actions
                          SizedBox(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  iconSize: 22,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                  splashRadius: 16,
                                  onPressed: () {
                                    showDialogTextRequired(
                                      context,
                                      "Masukkan data ${current.jenis}",
                                      index,
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.remove_circle,
                                    color: Colors.red,
                                  ),
                                  iconSize: 22,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 24,
                                    minHeight: 24,
                                  ),
                                  splashRadius: 16,
                                  onPressed: () {
                                    setState(() {
                                      order.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

            // ...order.asMap().entries.map((entry) {
            //   final index = entry.key;
            //   final item = entry.value;
            //   return Card(
            //     margin: const EdgeInsets.only(bottom: 10),
            //     child: Padding(
            //       padding: const EdgeInsets.all(10),
            //       child: Row(
            //         children: [
            //           Expanded(
            //             child: Column(
            //               crossAxisAlignment: CrossAxisAlignment.start,
            //               children: [
            //                 Text(
            //                   item.jenis,
            //                   style: TextStyle(
            //                     fontSize: 18,
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //                 const SizedBox(height: 5),
            //                 Text(
            //                   "${item.pesanan} * ${item.Harga} = RM ${item.Jumlah.toStringAsFixed(2)}"
            //                 ),
            //               ],
            //             ),
            //           ),
            //
            //           IconButton(
            //
            //             onPressed: () {
            //               setState(() {
            //                 order.removeAt(index);
            //
            //               });
            //             },
            //
            //             icon: const Icon(Icons.remove_circle),
            //
            //           ),
            //
            //           // Text(
            //           //   item.qty.toString(),
            //           //   style: const TextStyle(fontSize: 18),
            //           // ),
            //
            //           // IconButton(
            //           //
            //           //   onPressed: () {
            //           //
            //           //     setState(() {
            //           //
            //           //       item.qty++;
            //           //
            //           //     });
            //           //
            //           //   },
            //           //
            //           //   icon: const Icon(Icons.add_circle),
            //           //
            //           // ),
            //
            //         ],
            //       ),
            //     ),
            //   );
            // }),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),

                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text("Jumlah Item"),

                        Text(jumlahItem.toString()),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          "Jumlah Bayaran",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        Text(
                          "RM ${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget headerCell(String text) {
    return SizedBox(
      height: 40,
      child: Center(child: Text(text, style: textStyle)),
    );
  }

  Widget tableCell(String text, {VoidCallback? onTap}) {
    Widget child = SizedBox(
      height: 50,
      child: Center(child: Text(text, style: textStyleNormal)),
    );

    if (onTap != null) {
      child = GestureDetector(onTap: onTap, child: child);
    }

    return child;
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
          if (selectedTime == null && !_formKeyDate.currentState!.validate()) {
            return;
          }
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
              tarikhOrder = DateFormat('dd/MM/yyyy').format(DateTime.now());
              int totalOrder = rekod_Pelanggan
                  .where((pelanggan) => pelanggan.tarikhOrder == tarikhOrder)
                  .length;
              invoice = 'US${tarikhOrder.replaceAll("/", "")}$totalOrder';
              masaRekod = dateFormat.format(selectedDateTime).toString();
              epochTime = selectedDateTime.millisecondsSinceEpoch.toString();
              TarikhPesanan = '$hariRekod, $tarikhRekod $masaRekod';
              dateController.text = TarikhPesanan;
              FocusScope.of(context).requestFocus(namaFocus);
            }); // You can use the selectedDateTime as needed.
          }
        });
      }
    });
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
      final current = order.elementAt(index);
      myController.text = current.jenis;
      num pesananValue = current.pesanan;
      myController1.text = pesananValue % 1 == 0
          ? pesananValue.toStringAsFixed(0)
          : pesananValue.toStringAsFixed(1);
      myController2.text = money(current.Harga);
    }
    final values = dropDownList.map((e) => e.value).toList();
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
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
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
                                items: dropDownList,
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
                                    myController.text = item ?? "";
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
                          ),
                          textInputAction: TextInputAction.next,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Sila masukkan beberapa digit";
                            }
                            return null;
                          },
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
                        final current = order.elementAt(index);
                        current.jenis = nama;
                        current.pesanan = pesanan;
                        current.Harga = harga;
                        current.Jumlah = jumlah;
                        // insertServer(current, index);
                      } else {
                        // Add new
                        // insertServer(
                        //   rekodPesananPelanggan(pelangganID,nama, pesanan, harga, jumlah),
                        //   index,
                        // );
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

  Future<void> insertServer(rekodPelanggan usr) async {
    final result = await insertUpdateTable(
      'Pelanggan Rekod',
      usr.toMapServer(),
    );
    var resultRekod = rekodPelanggan.fromMap(result);
    setState(() {
      usrID = resultRekod.id;
    });
    for (var index = 0; index < order.length; index++) {
      var element = order.elementAt(index);
      element.pelanggan_id = usrID;
      insertPelagganDetail(element, usr);
    }
    if (!rekod_stok.map((item) => item.tarikh).contains(usr.tarikh)) {
      List<dynamic> rekod = <rekodStokDetail>[];
      rekod_stok.add(
        rekodStok(epochTime, tarikhRekod, hariRekod, 0.00, 0.00, rekod),
      );
    }
  }

  Future<void> insertPelagganDetail(
    rekodPesananPelanggan pesanan,
    rekodPelanggan usr,
  ) async {
    rekodPesananPelanggan? resultRekod;
    final result = await insertUpdateTable(
      'Pelanggan Detail Rekod',
      pesanan.toMapServer(),
    );
    resultRekod = rekodPesananPelanggan.fromMap(result);
    usr.id = resultRekod.id;
    try {
      final res = await supabase.functions.invoke(
        'super-api',
        body: {"name": usr.nama, "invois": usr.noBil},
      );

      print("respond data ${res.data}");
    } catch (e) {
      print("respond data error $e");
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pesanan anda berjaya dihantar.')),
    );
    showDialogRequired(
      context,
      "Pesanan Berjaya",
      'Pesanan anda berjaya dihantar.',
    );
  }

  void showDialogRequired(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                // resetAllForm();
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OrderPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void resetAllForm() {
    _formKey.currentState?.reset();
    _formKeyDate.currentState?.reset();
    _formKeyDetail.currentState?.reset();

    dateController.clear();
    namaController.clear();
    phoneController.clear();
    alamatController.clear();
    kuantitiController.clear();

    setState(() {
      tarikhOrder = "";
      tarikhRekod = "";
      hariRekod = "";
      masaRekod = "";
      epochTime = "";
      jenis = "";

      harga = 0.00;
      usrID = -1;
      order.clear();
    });
  }
}

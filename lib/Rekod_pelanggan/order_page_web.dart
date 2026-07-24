import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<rekodKategoriMenu> rekod_Kategori = <rekodKategoriMenu>[];
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
  Map<String, List<rekodPesananPelanggan>> grouped = {};


  Future<void> loadData() async {
    NotificationCenter().subscribe('refreshData', _refreshView);
    menuList.clear();
    dropDownList.clear();
    final menuListData = await selectTable('Menu Rekod', "");
    rekod_Menu = menuListData.map((e) => rekodMenu.fromMap(e)).toList();
    final kategoriListData = await selectTable('Kategori Menu Rekod', "");
    rekod_Kategori = kategoriListData.map((e) => rekodKategoriMenu.fromMap(e)).toList();
    final list = sortMenuList(rekod_Menu);

    for (var i = 0; i < list.length; i++) {
      var element = list.elementAt(i);
      String nama = element.jenis;
      String textHarga = "${element.Harga.toStringAsFixed(2)}";
      String note = "";
      if (nama.toLowerCase().contains("cod")) {
        continue;
      } else if (nama.toLowerCase().contains("box")) {
        nama = "Box Satay";
        note = "• jika pesanan melebihi 200 cucuk";
      }else if (nama.toLowerCase().contains("kuah kacang")) {
        nama = nama  + " (1 Kg)";
        textHarga = textHarga + " (1 Kg)";
      }
      print("rekod >>>  ${element.jenis}");
      var kategori = rekod_Kategori.firstWhere(
            (k) => k.id == element.kategori
      );
      grouped.putIfAbsent(kategori.jenis, () => []);
      grouped[kategori.jenis]!.add(rekodPesananPelanggan(-1, nama, 0, element.Harga, 0.00));
      menuList.insert(menuList.length, element);
      // order.insert(
      //   order.length,
      //   rekodPesananPelanggan(-1, nama, 0, element.Harga, 0.00));
      // dropDownList.add(
      //   DropdownMenuItem<String>(
      //     value: "${element.id}",
      //     child: Row(
      //       children: [
      //         Expanded(
      //           child: Column(
      //             crossAxisAlignment: CrossAxisAlignment.start,
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Text(
      //                 nama,
      //                 style: titleTextStyle,
      //               ),
      //               if (note.isNotEmpty)
      //                 Text(
      //                   note,
      //                   style: TextStyle(
      //                     fontSize: 12,
      //                     color: Colors.grey.shade600,
      //                   ),
      //                 ),
      //             ],
      //           ),
      //         ),
      //         Text(
      //           "RM $textHarga",
      //           style: textStyleNormal,
      //         ),
      //       ],
      //     )
      //   ),
      // );
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showNotice();
    });
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
          "Selamat Datang ke Sattay Ussop! 👋",
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
                _formKeyDate.currentState!.validate())) {
              return;
            }
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
                total,
                false,
              ),
            );
          },
        ),
      ),
      body: viewListOrder(),
    );
  }

  Future<void> showNotice() async {
    bool agree = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("📢 Perhatian"),
              content: SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                   "💰Jumlah bayaran yang dipaparkan tidak termasuk caj penghantaran.\n\n "
                       "🚚 Penghantaran bergantung kepada ketersediaan runner.\n\n "
                       "📌 Selepas pesanan diterima, kami akan menghubungi anda melalui WhatsApp untuk pengesahan dan memaklumkan jumlah bayaran keseluruhan."
                  ),
                  SizedBox(height: 10),
                  CheckboxListTile(
                    value: agree,
                    title: const Text("Saya telah membaca."),
                    onChanged: (value) {
                      setState(() {
                        agree = value!;
                      });
                    },
                  )
                ],
              )),
              actions: [
                ElevatedButton(
                  onPressed: agree
                      ? () => Navigator.pop(context)
                      : null,
                  child: const Text("Mula Membuat Pesanan"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget viewListOrder() {
    return Form(
      key: _formKeyDetail,
      child: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Text(
            '''
Sila isi pesanan anda di bawah dan tekan "Hantar Pesanan" apabila selesai.''',
            style: textStyle,
            textAlign: .center,
          ),
          const SizedBox(height: 10),
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
                    if (value == null || value
                        .trim()
                        .isEmpty) {
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
          const SizedBox(height: 20),
          Divider(thickness: 2, height: 10, color: Colors.grey),
          SizedBox(
            height: 40,
            child: Center(child: Text("SENARAI MENU SATTAY USSOP", style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ))),
          ),
          // Expanded(
          //   child: Column(
          //     children: grouped.entries.map((entry) {
          //       String kategori = entry.key;
          //       List<rekodPesananPelanggan> menus = entry.value;
          //       // var icon = Icons.restaurant_menu;
          //       return Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           // HEADER KATEGORI
          //           Container(
          //             margin: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          //             padding: const EdgeInsets.symmetric(
          //               horizontal: 16,
          //               vertical: 12,
          //             ),
          //             decoration: BoxDecoration(
          //               color: color,
          //               borderRadius: BorderRadius.circular(12),
          //             ),
          //             child: Row(
          //               children: [
          //                 //  Icon(
          //                 //   icon,
          //                 //   color: Colors.white,
          //                 // ),
          //                 // const SizedBox(width: 10),
          //                 Text(
          //                   kategori,
          //                   style: const TextStyle(
          //                     fontSize: 20,
          //                     fontWeight: FontWeight.bold,
          //                     color: Colors.white,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //
          //           // LIST MENU
          //           ...menus.map((item) {
          //             return buildMenu(item);
          //           }),
          //
          //         ],
          //       );
          //     }).toList(),
          //   ),
          // ),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                order.isNotEmpty
                    ? Divider(thickness: 2, height: 10, color: Colors.grey)
                    : const SizedBox(height: 0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${jumlahItem} item",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Text(
                      "Jumlah Bayaran",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "RM ${total.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
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

  Widget buildMenu(rekodPesananPelanggan item) {
    String note = "";
    if (item.jenis.toLowerCase().contains("box")) {
      note = "• jika pesanan melebihi 200 cucuk";
    }
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child:LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.jenis,
                          style: titleTextStyle,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "RM ${item.Harga.toStringAsFixed(2)}",
                        ),

                        if (note.isNotEmpty)
                          Text(
                            note,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),

              //     if (constraints.maxWidth > 250)
              //     QuantityButton(
              // quantity: item.pesanan,
              // colors: color,
              // onChanged: (qty) {
              // setState(() {
              // item.Harga = item.Harga.toDouble();
              // item.pesanan = qty;
              // item.Jumlah = qty * item.Harga.toDouble();
              //
              // var orderIndex =
              // order.indexWhere((e) => e.jenis == item.jenis);
              //
              // if (qty > 0) {
              // if (orderIndex >= 0) {
              // order[orderIndex] = item;
              // } else {
              // order.insert(order.length, item);
              // }
              // } else {
              // if (orderIndex >= 0) {
              // order.removeAt(orderIndex);
              // }
              // }
              // });
              // },
              // )
              //     else
              //       FittedBox(
              //           child:
              //           QuantityButton(
              //             quantity: item.pesanan,
              //             colors: color,
              //             onChanged: (qty) {
              //               setState(() {
              //                 item.Harga = item.Harga.toDouble();
              //                 item.pesanan = qty;
              //                 item.Jumlah = qty * item.Harga.toDouble();
              //
              //                 var orderIndex =
              //                 order.indexWhere((e) => e.jenis == item.jenis);
              //
              //                 if (qty > 0) {
              //                   if (orderIndex >= 0) {
              //                     order[orderIndex] = item;
              //                   } else {
              //                     order.insert(order.length, item);
              //                   }
              //                 } else {
              //                   if (orderIndex >= 0) {
              //                     order.removeAt(orderIndex);
              //                   }
              //                 }
              //               });
              //             },
              //           )
              //       ),

                  SizedBox(
                    width: 100,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: QuantityButton(
                        quantity: item.pesanan,
                        colors: color,
                        onChanged: (qty) {
                          setState(() {
                            item.Harga = item.Harga.toDouble();
                            item.pesanan = qty;
                            item.Jumlah = qty * item.Harga.toDouble();

                            var orderIndex =
                            order.indexWhere((e) => e.jenis == item.jenis);

                            if (qty > 0) {
                              if (orderIndex >= 0) {
                                order[orderIndex] = item;
                              } else {
                                order.insert(order.length, item);
                              }
                            } else {
                              if (orderIndex >= 0) {
                                order.removeAt(orderIndex);
                              }
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  void _selectDate(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendar,
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
      selectableDayPredicate: (day) {
        return day.weekday != DateTime.monday;
      },
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
    showDialog(context: context,builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
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
                    if (!formKey.currentState!.validate()) return;
                      num pesanan = myController1.text.totalDoubleNumber();
                      num harga = myController2.text.isEmpty
                          ? 0
                          : myController2.text.toDoubleNumberFormat();
                      String nama = myController.text;
                      num jumlah = pesanan * harga;
                      print("order jenis ni >> ${index} >> ${order[index].jenis}");
                      if (index >= 0) {
                        // Update existing
                        setState(() {
                          order[index].jenis = nama;
                          order[index].pesanan = pesanan;
                          order[index].Harga = harga;
                          order[index].Jumlah = jumlah;
                        });
                      }
                    Navigator.of(context).pop();
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
    if (order.isNotEmpty) {
      for (var index = 0; index < order.length; index++) {
        var element = order.elementAt(index);
        element.pelanggan_id = usrID;
        insertPelagganDetail(element, usr);
      }
      }
    if (!rekod_stok.map((item) => item.tarikh).contains(usr.tarikh)) {
      List<dynamic> rekod = <rekodStokDetail>[];
      rekod_stok.add(
        rekodStok(epochTime, tarikhRekod, hariRekod, 0.00, 0.00, rekod),
      );
    }
    sendTodiscord(usr);
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
    sendTodiscord(usr);
  }

  void sendTodiscord(rekodPelanggan usr) async {
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
class QuantityButton extends StatefulWidget {
  final num quantity;
  final ValueChanged<int> onChanged;
  final Color colors;

  const QuantityButton({
    super.key,
    required this.quantity,
    required this.onChanged,
    required this.colors,
  });

  @override
  State<QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<QuantityButton> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
      text: widget.quantity.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant QuantityButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.quantity.toString() != controller.text) {
      controller.text = widget.quantity.toString();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void updateQty(int qty) {
    widget.onChanged(qty);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: widget.colors),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              int qty = int.tryParse(controller.text) ?? 0;
              if (qty > 0) updateQty(qty - 1);
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.remove,
                  color: widget.colors),
            ),
          ),

          SizedBox(
            width: 60,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (value) {
                updateQty(int.tryParse(value) ?? 0);
              },
            ),
          ),

          InkWell(
            onTap: () {
              int qty = int.tryParse(controller.text) ?? 0;
              updateQty(qty + 1);
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(Icons.add,
                  color: widget.colors),
            ),
          ),
        ],
      ),
    );
  }
}
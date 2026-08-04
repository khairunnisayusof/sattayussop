import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:notification_center/notification_center.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sattayussop/Rekod_Pembekal/rekodPembekal.dart';
import 'package:sattayussop/Rekod_Gaji/rekodGaji.dart';
import 'package:sattayussop/Rekod_Pekerja/RekodPekerja.dart';
import 'package:sattayussop/Rekod_pelanggan/order_page_web.dart';
import 'package:sattayussop/SenaraiBarang.dart';
import 'package:sattayussop/rekodRunner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:sattayussop/DocumentHelper.dart';
import 'package:sattayussop/Rekod_Harian/RekodHarian.dart';
import 'package:sattayussop/RekodMenu.dart';
import 'package:sattayussop/Rekod_Cucuk/rekodCucuk.dart';
import 'package:sattayussop/Rekod_Cawangan/rekodCawangan.dart';
import 'package:sattayussop/Rekod_pelanggan/rekodPelanggan.dart';
import 'package:sattayussop/Rekod_Stok/rekodStok.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../supabaseServer.dart';
import 'login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // runApp(MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  sharedPreferences = await SharedPreferences.getInstance();
  await dotenv.load(
    fileName: ".env",
  );
  final url = dotenv.env['SUPABASE_URL'];

  if (url == null) {
    throw Exception("SUPABASE_URL not found");
  }

  final urlKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'];

  if (urlKey == null) {
    throw Exception("SUPABASE_PUBLISHABLE_KEY not found");
  }
  await Supabase.initialize(
    url: url,
    publishableKey: urlKey,
  );

  runApp(
    ChangeNotifierProvider(create: (_) => ThemeNotifier(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final ThemeData lightTheme = ThemeData(
    appBarTheme: const AppBarTheme(
      shadowColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      backgroundColor: Colors.orange,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    brightness: Brightness.light,
    // colorSchemeSeed: const Color.fromRGBO(86, 80, 14, 171),
    primaryColor: Colors.orange,
    useMaterial3: true,
    // Define additional light theme properties here
  );
  final ThemeData darkTheme = ThemeData(
    appBarTheme: const AppBarTheme(
      shadowColor: Colors.transparent,
      elevation: 0.0,
      centerTitle: true,
      backgroundColor: Colors.deepOrange,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    brightness: Brightness.dark,
    primaryColor: Colors.deepOrange[900],
    useMaterial3: true,
    // Define additional dark theme properties here
  );
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(
      context,
      listen: true,
    );
    ThemeMode themeMode = themeNotifier.themeMode;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Home',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: DefaultTabController(length: 2, child: MyHomePage()),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  Icon more_rev_Icon = Icon(Icons.more_vert, color: Colors.white);
  var title = "Home";
  Widget appBarTitle = Text(
    "Home",
    style: TextStyle(color: Colors.white),
  );
  Widget appBarSettingTitle = Text(
    "Tetapan Umum",
    style: TextStyle(color: Colors.white),
  );
  int _selectedIndex = 0;
  bool darkMode = false;
  DataStorage fileLog = DataStorage();
  Color color = Colors.orange;
  TextStyle textStyle = TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold);

  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  List<Choice> menuChoices = List.from(choices);
  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
      _packageInfo = info;
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDataDarkMode();
      loadUserServer();
      loadSharedPreferences();
      _initPackageInfo();
    });
  }


  void _refreshView(bool refresh) {
    if (!mounted) return;
    setState(() {
      print("refresh record");
      isLoading = false;
    });
  }

  // Future<void> checkLogin() async {
  //   sharedPreferences = await SharedPreferences.getInstance();
  //   bool login = sharedPreferences?.getBool("login") ?? false;
  //   final session = Supabase.instance.client.auth.currentSession;
  //   if (!mounted) return;
  //
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) =>
  //       session != null ? const MyHomePage() : const LoginPage(),
  //     ),
  //   );
  // }

  @override
  void dispose() {
    if (!mounted) return;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    Container buildCollectionView;
    Container buildSettingViewOfDevices;
    if (write) {
      setState(() {
        if (!menuChoices.any((e) => e.title == "Rekod Gaji")) {
          menuChoices.insert(
            3,
            const Choice(
              title: 'Rekod Gaji',
              icon: 'image/rekod_Gaji.png',
            ),
          );
        }
      });
    } else {
      setState(() {
        if (menuChoices.any((e) => e.title == "Rekod Gaji")) {
          menuChoices.removeAt(3);
        }
      });
    }
    var isAdmin = (write && delete);
    var isAdminManager = (write);
    buildCollectionView = Container(
      margin: EdgeInsets.only(top: 5),
      child: Center(
        child: GridView.builder(
          primary: false,
          padding: EdgeInsets.all(5.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 20.0,
            mainAxisSpacing: 40.0,
            childAspectRatio: 0.75,
            crossAxisCount: 3,
          ),
          itemCount: menuChoices.length,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () async {
                // call click event
                print("select $index");
                if (index == 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => selectRekodHarian(),
                    ),
                  );
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => selectRekodCucuk()),
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RekodPelanggan()),
                  );
                } else if (index == 3) {
                  // _openPageWithPassword();
                  if (isAdminManager) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          selectRekodGaji()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RekodCawangan()),
                    );
                  }
                } else if (index == 4) {
                  if (isAdminManager) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RekodCawangan()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RekodBarang()),
                    );
                  }
                } else if (index == 5) {
                  if (isAdminManager) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RekodBarang()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RekodStok()),
                    );
                  }
                } else if (index == 6) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RekodStok()),
                  );
                }
              },
              child: SelectCard(choice: menuChoices[index], darkMode: darkMode),
            );
          },
        ),
      ),
    );

    buildSettingViewOfDevices = Container(
      margin: EdgeInsets.only(top: 10),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  color: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                  ),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    width: MediaQuery
                        .of(context)
                        .size
                        .width - 100.0,
                    height: 30,
                    child: Text(
                      " Tetapan Rekod",
                      style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            ListTile(
              leading: Container(
                margin: EdgeInsets.only(top: 5, bottom: 5.0, left: 2.0),
                alignment: Alignment.centerLeft,
                width: 40.0,
                height: 40.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  image: DecorationImage(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.centerLeft,
                    image: AssetImage("image/Icon_Dark_Mode.png"),
                  ),
                ),
              ),
              title: Text(
                'Dark Mode',
                style: textStyle,
                textAlign: TextAlign.left,
              ),
              trailing: Switch(
                value: darkMode,
                onChanged: (value) {
                  saveData();
                },
                activeThumbColor: color,
              ),
            ),
            Divider(),
            isAdmin ? GestureDetector(
              child: ListTile(
                leading: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5.0, left: 2.0),
                  alignment: Alignment.centerLeft,
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.centerLeft,
                      image: AssetImage("image/rekod_Pekerja.png"),
                    ),
                  ),
                ),
                title: Text(
                  'Tetapan Pekerja',
                  style: textStyle,
                  textAlign: TextAlign.left,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => selectRekodPekerja()),
                );
              },
            ) : SizedBox(height: 0),
            isAdmin ? Divider() : SizedBox(height: 0),
            isAdmin ? GestureDetector(
              child: ListTile(
                leading: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5.0, left: 2.0),
                  alignment: Alignment.centerLeft,
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.centerLeft,
                      image: AssetImage("image/rekod_Menu.png"),
                    ),
                  ),
                ),
                title: Text(
                  'Tetapan Menu',
                  style: textStyle,
                  textAlign: TextAlign.left,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => selectRekodMenu()),
                );
              },
            ) : SizedBox(height: 0),
            isAdmin ? Divider() : SizedBox(height: 0),
            isAdmin ? GestureDetector(
              child: ListTile(
                leading: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5.0, left: 2.0),
                  alignment: Alignment.centerLeft,
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.centerLeft,
                      image: AssetImage("image/rekod_Runner.png"),
                    ),
                  ),
                ),
                title: Text(
                  'Tetapan Runner',
                  style: textStyle,
                  textAlign: TextAlign.left,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => selectRekodRunner()),
                );
              },
            ) : SizedBox(height: 0),
            isAdmin ? Divider() : SizedBox(height: 0),
            isAdminManager ? GestureDetector(
              child: ListTile(
                leading: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5.0, left: 2.0),
                  alignment: Alignment.centerLeft,
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.centerLeft,
                      image: AssetImage("image/rekod_Barang.png"),
                    ),
                  ),
                ),
                title: Text(
                  'Tetapan Barang',
                  style: textStyle,
                  textAlign: TextAlign.left,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => selectSenaraiBarang(),
                  ),
                );
              },
            ) : SizedBox(height: 0),
            isAdminManager ? Divider() : SizedBox(height: 0),
            GestureDetector(
              child: ListTile(
                leading: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5.0, left: 2.0),
                  alignment: Alignment.centerLeft,
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.centerLeft,
                      image: AssetImage("image/tempahan_Online.png"),
                    ),
                  ),
                ),
                title: Text(
                  'Tempahan Online',
                  style: textStyle,
                  textAlign: TextAlign.left,
                ),
              ),
              onTap: () {
                showQRTempahan(context);
              },
            ),
            Divider(),
            GestureDetector(
              child: ListTile(
                leading: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5.0, left: 2.0),
                  alignment: Alignment.centerLeft,
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.centerLeft,
                      image: AssetImage("image/Location_Kilang.png"),
                    ),
                  ),
                ),
                title: Text(
                  'Location Kilang',
                  style: textStyle,
                  textAlign: TextAlign.left,
                ),
              ),
              onTap: () {
                _sendLocationViaWsap();
              },
            ),
            Divider(),
            GestureDetector(
              child: ListTile(
                leading: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5.0, left: 2.0),
                  alignment: Alignment.centerLeft,
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.centerLeft,
                      image: AssetImage("image/Privacy_Policy.png"),
                    ),
                  ),
                ),
                title: Text(
                  'Dasar Privasi',
                  style: textStyle,
                  textAlign: TextAlign.left,
                ),
              ),
              onTap: () {
                openPrivacyPolicy();
              },
            ),
            Divider(),
            isAdminManager ? GestureDetector(
              child: ListTile(
                leading: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5.0, left: 2.0),
                  alignment: Alignment.centerLeft,
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.centerLeft,
                      image: AssetImage("image/email.png"),
                    ),
                  ),
                ),
                title: Text(
                  'Hantar Rekod',
                  style: textStyle,
                  textAlign: TextAlign.left,
                ),
              ),
              onTap: () {
                fileLog.attachLogFile(context);
              },
            ) : SizedBox(height: 0),
            isAdminManager ? Divider() : SizedBox(height: 0),
            GestureDetector(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text(
                    role.isNotEmpty ? 'Log Keluar' : 'Log Masuk',
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
                if (role.isNotEmpty) {
                  role = '';
                }
                await sharedPreferences?.setInt("userId", 0);
                await sharedPreferences?.setInt("roleID", 0);
                setState(() {
                  write = false;
                  read = true;
                  delete = false;
                });
                await sharedPreferences?.remove(databasePekerja);
                await sharedPreferences?.remove(databaseRole);
                await sharedPreferences?.remove(databaseKategori);
                await sharedPreferences?.remove(databaseKategoriMenu);
                await sharedPreferences?.remove(databaseMenu);
                await sharedPreferences?.remove(databaseStok);
                await sharedPreferences?.remove(databaseHarian);
                await sharedPreferences?.remove(databaseCucuk);
                await sharedPreferences?.remove(databasePelanggan);
                await sharedPreferences?.remove(databaseCawangan);
                await sharedPreferences?.remove(databaseRunner);
                await sharedPreferences?.remove(databaseGaji);
                await sharedPreferences?.remove(databasePembekal);
                await sharedPreferences?.remove(databaseBarang);
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyHomePage(),
                  ),
                );
              },
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              alignment: Alignment.bottomRight,
              child: Text(
                "V ${_packageInfo.version}",
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium,
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
          if (item == '1') {
            // saveData();
          }
        },
        itemBuilder: (BuildContext bc) {
          return const [
            // PopupMenuItem(
            //   child: Text("Tetapan Dark Mode"),
            //   value: '1',
            // ),
          ];
        },
      ),
    );
    if (kIsWeb) {
      return const MaterialApp(
        home: OrderPage(),
      );
    }

    roleID = sharedPreferences?.getInt("roleID") ?? 0;
    user_id = sharedPreferences?.getInt("userId") ?? 0;

    if (roleID <= 0) {
      return const LoginPage();
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56), // 56 is default height
        child: <Widget>[
          AppBar(
            foregroundColor: Colors.transparent,
            title: appBarTitle,
            actions: <Widget>[],
          ),
          AppBar(title: appBarSettingTitle, centerTitle: true),
        ][_selectedIndex],
      ),
      body: Stack(
        children: [
          <Widget>[
            buildCollectionView,
            buildSettingViewOfDevices,
          ][_selectedIndex],
          if (isLoading)
            Container(
              color: Colors.black38,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      "Sila tunggu\nSedang mendapatkan rekod terkini...",
                      style: TextStyle(color: Colors.white),
                      textAlign: .center,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.home, color: Colors.white),
            icon: Icon(Icons.home_outlined, color: Colors.white),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            activeIcon: Icon(Icons.settings, color: Colors.white),
            icon: Icon(Icons.settings_outlined, color: Colors.white),
            label: 'Tetapan',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: color,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }

  void _openPageWithPassword() async {
    String? password = await showDialog<String>(
      context: context,
      barrierDismissible: false, // user must enter/cancel
      builder: (context) {
        final controller = TextEditingController();

        return AlertDialog(
          title: Text("Enter Password"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number, // numeric keyboard
            maxLength: 8, // optional: max digits
            obscureText: true,
            decoration: InputDecoration(hintText: "Password"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null), // cancel
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text("Submit"),
            ),
          ],
        );
      },
    );

    // Check password
    if (password != null && password == "24080524") {
      // replace "24080524" with your password logic
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => selectRekodGaji()),
      );
    } else if (password != null) {
      // wrong password
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Wrong password!")));
    }
  }

  void _sendLocationViaWsap() async {
    String lat = "4.524834";
    String lng = "101.070034";

    // ✅ Use reliable Google Maps link
    final maps = "https://www.google.com/maps?q=$lat,$lng";

    String message =
        "Assalamualaikum dan Salam Sejahtera.\n"
        "Kami dari Sattay Ussop.\n\n"
        "Alamat operasi kami:\n"
        "*No 129, Laluan Pinji Perdana 9, Taman Pinji Perdana, 31500 Lahat, Ipoh*\n\n"
        // "Koordinat: *$lat, $lng*\n\n"
        "Lokasi:\n$maps";

    // launchWhatsappWithMobileNumber(mobileCustomer, message);
    // ✅ Load image from assets
    final byteData = await rootBundle.load("image/location_Satay.png");
    final file = File("$path/location_Satay.png");

    await file.writeAsBytes(byteData.buffer.asUint8List());

    await SharePlus.instance.share(
      ShareParams(
        text: message,
        files: [
          XFile(file.path),
        ],
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
          title: Text("Tempahan Satay Online"),
          content: Text("Pilih mesej untuk di hantar kepada pelanggan"),
          actions: <Widget>[
            TextButton(
              child: const Text('Melalui Mesej'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Generate QR'),
              onPressed: () {
                showQRTempahan(context);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showQRTempahan(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
                content: SingleChildScrollView(
                  child: SizedBox(
                    width: 300,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Scan untuk buat pesanan",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        QrImageView(
                          data: urlTempahan,
                          version: QrVersions.auto,
                          size: 220,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        // SelectableText(
                        //   urlTempahan,
                        //   textAlign: TextAlign.center,
                        // ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                      child: Text("Batal"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      }
                  ),
                  TextButton(
                      child: Text("Hantar"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _sendTempahanOnline();
                      }
                  ),
                ]
            );
          },
        );
      },
    );
  }

  void _sendTempahanOnline() async {
    String message =
    '''
Assalamualaikum dan Salam Sejahtera. Kami dari Sattay Ussop.

Anda boleh buat tempahan melalui online: ${urlTempahan}

🚚 Penghantaran bergantung kepada ketersediaan runner pada waktu pesanan dibuat.

Selepas kami menerima pesanan anda, kami akan menghubungi anda semula untuk:

✅ Mengesahkan pesanan anda.
🚚 Memaklumkan sama ada penghantaran tersedia.
💰 Memberikan jumlah bayaran keseluruhan termasuk caj penghantaran (jika berkenaan).''';

    await SharePlus.instance.share(
      ShareParams(
        text: message,
      ),
    );
  }

  void _onItemTapped(int index) {
    if (isLoading) {
      return;
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> loadSharedPreferences() async {
    print("start load shared");
    NotificationCenter().subscribe('finishLoad', _refreshView);
    darkMode = await loadDataDarkMode();
    setState(() {
      isLoading = true;
    });
    await loadDataServer();
  }

  //  This block loads our previously-stored list with key 'list'.
  Future<bool> loadDataDarkMode() async {
    ThemeNotifier themeNotifier = Provider.of<ThemeNotifier>(
      context,
      listen: false,
    );
    darkMode = sharedPreferences?.getBool("darkModeStatus") ?? false;
    if (darkMode) {
      themeNotifier.setTheme(ThemeMode.dark);
      color = Colors.deepOrange;
    } else {
      themeNotifier.setTheme(ThemeMode.light);
      color = Colors.orange;
    }
    return darkMode;
  }

  // This block saves our list locally.
  void saveData() {
    if (darkMode) {
      darkMode = false;
    } else {
      darkMode = true;
    }
    print("data save >> $darkMode");
    sharedPreferences?.setBool("darkModeStatus", darkMode);
      loadDataDarkMode();
    setState(() {
    });
  }
}

Future<String> loadAsset() async {
  return await rootBundle.loadString('assets/config.json');
}

class Choice {
  const Choice({required this.title, required this.icon});
  final String title;
  final String icon;
}

const List<Choice> choices = <Choice>[
  Choice(title: 'Rekod Harian', icon: 'image/rekod_Harian.png'),
  Choice(title: 'Rekod Cucuk', icon: 'image/rekod_Cucuk.png'),
  Choice(title: 'Rekod Pelanggan', icon: 'image/rekod_Pelanggan.png'),
  Choice(title: 'Rekod Cawangan', icon: 'image/rekod_Cawangan.png'),
  Choice(title: 'Rekod Pembekal', icon: 'image/rekod_Pembekal.png'),
  Choice(title: 'Rekod Stok', icon: 'image/rekod_Stok.png'),
];

class SelectCard extends StatelessWidget {
  const SelectCard({super.key, required this.choice, required this.darkMode});

  final Choice choice;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    Color color = Colors.orange;
    if (darkMode) {
      color = Colors.deepOrange;
    }

    final isTablet = MediaQuery.of(context).size.width >= 800;

    final double iconSize = isTablet ? 110 : 80;
    final double titleSize = isTablet ? 28 : 16;

    final TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: titleSize,
      fontWeight: FontWeight.bold,
    );
    return Card(
      semanticContainer: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 6,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  fit: BoxFit.contain,
                  alignment: Alignment.topCenter,
                  image: AssetImage(choice.icon),
                ),
              ),
            ),
            SizedBox(height: isTablet ? 20 : 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                choice.title,
                style: textStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

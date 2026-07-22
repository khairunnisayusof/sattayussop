import 'package:flutter/material.dart';
import 'package:sattayussop/main.dart';
import 'package:sattayussop/supabaseServer.dart';
import 'package:string_capitalize/string_capitalize.dart';
import 'databaseLocal.dart';
import 'DocumentHelper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  Color color = Colors.orange;
  bool dark = sharedPreferences?.getBool("darkModeStatus") ?? false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dark = sharedPreferences?.getBool("darkModeStatus") ?? false;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.transparent,
        title: Text("Login", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.asset(
                      dark
                          ? 'image/SATAY_USSOP.png'
                          : 'image/orenBlack_icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Log Masuk",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  TextField(
                    controller: usernameController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Username",
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  // const SizedBox(height: 10),

                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child: TextButton(
                  //     onPressed: () {},
                  //     child: const Text("Lupa Password?"),
                  //   ),
                  // ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await login();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dark
                            ? Colors.deepOrange
                            : Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        "LOG MASUK",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     const Text("Tiada akaun?"),
                  //     TextButton(
                  //       onPressed: () {},
                  //       child: const Text("Daftar"),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> login() async {
    try {
      String username = usernameController.text.trim();
      String password = passwordController.text;

      final user = await supabase
          .from('Pekerja Rekod')
          .select()
          .ilike('nama', username.trim())
          .maybeSingle();

      print("nama user >> ${username.trim()} >> $user");

      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User tidak wujud")));
        return;
      }

      bool passwordCorrect;

      if (user['role'].toString().capitalize() == 'Admin') {
        passwordCorrect = password == adminPassword;
      } else if (user['role'].toString().capitalize() == 'Manager') {
        passwordCorrect = password == managerPassword;
      } else {
        passwordCorrect = password == pekerjaPassword;
      }

      print("rekod user >>> $username >> $user");

      if (!passwordCorrect) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Password salah")));

        return;
      }
      var pekerjaList = rekodPekerja.fromJson(user);
      role = pekerjaList.role;
      user_id = pekerjaList.id;
      bool aktif = pekerjaList.aktif;

      if (user_id <= 0) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Sila mohon admin daftar anda ke Sistem Sattay Ussop!",
            ),
          ),
        );
        return;
      }
      if (!aktif) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Sila mohon admin mengaktifkan akses anda ke Sistem Sattay Ussop.",
            ),
          ),
        );
        return;
      }
      // final prefs = await sharedPreferences.getInstance();
      await sharedPreferences?.setInt("userId", user_id);
      await sharedPreferences?.setString("role", role.capitalize());

      // PENTING: check selepas await
      if (!mounted) return;
      loadDataServer();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyHomePage()),
      );
    } catch (e) {
      print("error message >> $e");
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Log Masuk gagal!")));
    }
  }
}

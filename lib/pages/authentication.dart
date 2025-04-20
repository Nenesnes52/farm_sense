import 'package:farm_sense/models/farm_sense_model.dart';
import 'package:farm_sense/pages/main_menu.dart';
import 'package:farm_sense/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it_mixin/get_it_mixin.dart';
import 'package:google_fonts/google_fonts.dart';

enum AuthState {
  signIn,
  signUp,
  forgotPassword,
  verification,
}

class Authentication extends StatefulWidget with GetItStatefulWidgetMixin {
  Authentication({super.key});
  @override
  State<Authentication> createState() => AuthenticationState();
}

class AuthenticationState extends State<Authentication> with GetItStateMixin {
  var currentAuthState = AuthState.signIn;
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;
  bool? isBusy = false;
  final model = locator<FarmSenseModel>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isBusy = watchOnly((FarmSenseModel only) => only.isBusy);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(2, 84, 100, 1),
            Color.fromRGBO(42, 111, 125, 1),
          ],
        ),
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Image.asset(
                    'assets/logo_text.png',
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      color: Color.fromRGBO(246, 246, 249, 1),
                    ),
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(31, 20, 31, 0),
                      child: Column(
                        children: [
                          if (currentAuthState == AuthState.signIn)
                            Column(
                              children: [
                                Text(
                                  'Selamat Datang',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.plusJakartaSans()
                                        .fontFamily,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Color.fromRGBO(2, 84, 100, 1),
                                  ),
                                ),
                                SizedBox(
                                  height: 9.73,
                                ),
                                Text(
                                  'Silakan masukkan detail di bawah ini untuk melanjutkan',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.plusJakartaSans()
                                        .fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(2, 84, 100, 1),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                TextFormField(
                                  controller: usernameController,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Invalid username';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    // prefixIcon: Icon(
                                    //   Icons.person_outline_rounded,
                                    //   color: Color.fromRGBO(2, 84, 100, 1),
                                    // ),
                                    labelText: 'Username',
                                    labelStyle: TextStyle(
                                      fontFamily: GoogleFonts.plusJakartaSans()
                                          .fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color.fromRGBO(2, 84, 100, 1),
                                    ),
                                  ),
                                  onChanged: (value) => setState(() {}),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      // style: ButtonStyle(
                                      //     overlayColor:
                                      //         MaterialStateProperty.all(Colors.transparent)),
                                      onPressed: () => setState(() {
                                        _obscureText = !_obscureText;
                                      }),
                                      icon: _obscureText
                                          ? Icon(
                                              Icons.visibility_outlined,
                                              color:
                                                  Color.fromRGBO(2, 84, 100, 1),
                                            )
                                          : Icon(
                                              Icons.visibility_off_outlined,
                                              color:
                                                  Color.fromRGBO(2, 84, 100, 1),
                                            ),
                                    ),
                                    // prefixIcon: Icon(
                                    //   Icons.lock_outline_rounded,
                                    //   color: Color.fromRGBO(2, 84, 100, 1),
                                    // ),
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                      fontFamily: GoogleFonts.plusJakartaSans()
                                          .fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color.fromRGBO(2, 84, 100, 1),
                                    ),
                                  ),
                                  onChanged: (value) => setState(() {}),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                IconButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () async {
                                    if (kDebugMode) {
                                      print(usernameController.text);
                                      print(passwordController.text);
                                    }
                                    final snackBar = SnackBar(
                                      content: Text(
                                          'Masuk ke akun dengan username ${usernameController.text}'),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => const MainMenu(),
                                      ),
                                    );

                                    // model.handleSignIn(
                                    //   username: usernameController.text.trim(),
                                    //   password: passwordController.text.trim(),
                                    //   onSuccess: () {
                                    //     final snackBar = SnackBar(
                                    //       content: Text(
                                    //           'Masuk ke akun dengan username ${usernameController.text}'),
                                    //     );
                                    //     ScaffoldMessenger.of(context)
                                    //         .showSnackBar(snackBar);
                                    //     Navigator.of(context).pushReplacement(
                                    //       MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             const MainMenu(),
                                    //       ),
                                    //     );
                                    //   },
                                    //   onFailed: () {
                                    //     final snackBar = SnackBar(
                                    //       content: Text(
                                    //           'Gagal masuk ke akun ${usernameController.text}'),
                                    //     );
                                    //     ScaffoldMessenger.of(context)
                                    //         .showSnackBar(snackBar);
                                    //   },
                                    // );
                                  },
                                  style: IconButton.styleFrom(
                                    splashFactory: NoSplash.splashFactory,
                                  ),
                                  icon: Container(
                                    // width: 108,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color.fromRGBO(2, 84, 100, 1),
                                          Color.fromRGBO(42, 111, 125, 1),
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: Color.fromRGBO(2, 84, 100, 1),
                                    ),
                                    child: isBusy == true
                                        ? const CircularProgressIndicator()
                                        : Text(
                                            'Masuk',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Belum punya akun?',
                                      style: GoogleFonts.plusJakartaSans(
                                        // fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      style: IconButton.styleFrom(
                                        splashFactory: NoSplash.splashFactory,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          usernameController.clear();
                                          passwordController.clear();
                                          currentAuthState = AuthState.signUp;
                                        });
                                      },
                                      icon: Text(
                                        'Daftar',
                                        style: GoogleFonts.plusJakartaSans(
                                          // fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromRGBO(
                                              48, 130, 192, 1),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          if (currentAuthState == AuthState.signUp)
                            Column(
                              children: [
                                Text(
                                  'Selamat Datang',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.plusJakartaSans()
                                        .fontFamily,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Color.fromRGBO(2, 84, 100, 1),
                                  ),
                                ),
                                SizedBox(
                                  height: 9.73,
                                ),
                                Text(
                                  'Silakan masukkan detail di bawah ini untuk melanjutkan',
                                  style: TextStyle(
                                    fontFamily: GoogleFonts.plusJakartaSans()
                                        .fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color.fromRGBO(2, 84, 100, 1),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                TextFormField(
                                  controller: nameController,
                                  keyboardType: TextInputType.name,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Nama tidak valid';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    // prefixIcon: Icon(
                                    //   Icons.card,
                                    //   color: Color.fromRGBO(2, 84, 100, 1),
                                    // ),
                                    labelText: 'Nama Lengkap',
                                    labelStyle: TextStyle(
                                      fontFamily: GoogleFonts.plusJakartaSans()
                                          .fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color.fromRGBO(2, 84, 100, 1),
                                    ),
                                  ),
                                  onChanged: (value) => setState(() {}),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Invalid email address';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    // prefixIcon: Icon(
                                    //   Icons.alternate_email_rounded,
                                    //   color: Color.fromRGBO(2, 84, 100, 1),
                                    // ),
                                    labelText: 'Email',
                                    labelStyle: TextStyle(
                                      fontFamily: GoogleFonts.plusJakartaSans()
                                          .fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color.fromRGBO(2, 84, 100, 1),
                                    ),
                                  ),
                                  onChanged: (value) => setState(() {}),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  controller: usernameController,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Invalid username';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    // prefixIcon: Icon(
                                    //   Icons.alternate_email_rounded,
                                    //   color: Color.fromRGBO(2, 84, 100, 1),
                                    // ),
                                    labelText: 'Username',
                                    labelStyle: TextStyle(
                                      fontFamily: GoogleFonts.plusJakartaSans()
                                          .fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color.fromRGBO(2, 84, 100, 1),
                                    ),
                                  ),
                                  onChanged: (value) => setState(() {}),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: _obscureText,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      // style: ButtonStyle(
                                      //     overlayColor:
                                      //         MaterialStateProperty.all(Colors.transparent)),
                                      onPressed: () => setState(() {
                                        _obscureText = !_obscureText;
                                      }),
                                      icon: _obscureText
                                          ? Icon(
                                              Icons.visibility_outlined,
                                              color:
                                                  Color.fromRGBO(2, 84, 100, 1),
                                            )
                                          : Icon(
                                              Icons.visibility_off_outlined,
                                              color:
                                                  Color.fromRGBO(2, 84, 100, 1),
                                            ),
                                    ),
                                    // prefixIcon: Icon(
                                    //   Icons.lock_outline_rounded,
                                    //   color: Color.fromRGBO(2, 84, 100, 1),
                                    // ),
                                    labelText: 'Password',
                                    labelStyle: TextStyle(
                                      fontFamily: GoogleFonts.plusJakartaSans()
                                          .fontFamily,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: Color.fromRGBO(2, 84, 100, 1),
                                    ),
                                  ),
                                  onChanged: (value) => setState(() {}),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                IconButton(
                                  padding: EdgeInsets.all(0),
                                  onPressed: () async {
                                    if (kDebugMode) {
                                      print(nameController.text);
                                      print(emailController.text);
                                      print(usernameController.text);
                                      print(passwordController.text);
                                    }
                                    // model.handleSignUp(
                                    //   name: nameController.text.trim(),
                                    //   email: emailController.text.trim(),
                                    //   username: usernameController.text.trim(),
                                    //   password: passwordController.text.trim(),
                                    //   onSuccess: () {
                                    //     final snackBar = SnackBar(
                                    //       content: Text(
                                    //           'Akun dengan username ${usernameController.text.trim()} berhasil dibuat'),
                                    //     );
                                    //     ScaffoldMessenger.of(context)
                                    //         .showSnackBar(snackBar);
                                    //     Navigator.of(context).pushReplacement(
                                    //       MaterialPageRoute(
                                    //         builder: (context) =>
                                    //             const MainMenu(),
                                    //       ),
                                    //     );
                                    //   },
                                    //   onFailed: () {},
                                    // );
                                  },
                                  style: IconButton.styleFrom(
                                    splashFactory: NoSplash.splashFactory,
                                  ),
                                  icon: Container(
                                    // width: 108,
                                    height: 44,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color.fromRGBO(2, 84, 100, 1),
                                          Color.fromRGBO(42, 111, 125, 1),
                                        ],
                                      ),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: Color.fromRGBO(2, 84, 100, 1),
                                    ),
                                    child: isBusy == true
                                        ? const CircularProgressIndicator()
                                        : Text(
                                            'Daftar',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Sudah punya akun?',
                                      style: GoogleFonts.plusJakartaSans(
                                        // fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      style: IconButton.styleFrom(
                                        splashFactory: NoSplash.splashFactory,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          nameController.clear();
                                          emailController.clear();
                                          usernameController.clear();
                                          passwordController.clear();
                                          currentAuthState = AuthState.signIn;
                                          if (kDebugMode) {
                                            print(currentAuthState);
                                          }
                                        });
                                      },
                                      icon: Text(
                                        'Masuk',
                                        style: GoogleFonts.plusJakartaSans(
                                          // fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: const Color.fromRGBO(
                                              48, 130, 192, 1),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

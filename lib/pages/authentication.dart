import 'package:farm_sense/models/farm_sense_model.dart';
import 'package:farm_sense/provider.dart';
import 'package:farm_sense/routes/route_name.dart';
import 'package:farm_sense/widgets/error_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  DateTime? _lastBackPressed;

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final usernameFocus = FocusNode();
  final passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();

    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 3)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tekan sekali lagi untuk keluar"),
          backgroundColor: Colors.black45.withValues(alpha: 0.7),
          duration: Duration(seconds: 3),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    isBusy = watchOnly((FarmSenseModel only) => only.isBusy);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
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
                    SvgPicture.asset(
                      'assets/images/logo_text.svg',
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
                                    textInputAction: TextInputAction.next,
                                    focusNode: usernameFocus,
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
                                        fontFamily:
                                            GoogleFonts.plusJakartaSans()
                                                .fontFamily,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    onChanged: (value) => setState(() {}),
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context)
                                          .requestFocus(passwordFocus);
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    controller: passwordController,
                                    obscureText: _obscureText,
                                    textInputAction: TextInputAction.done,
                                    focusNode: passwordFocus,
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
                                                color: Color.fromRGBO(
                                                    2, 84, 100, 1),
                                              )
                                            : Icon(
                                                Icons.visibility_off_outlined,
                                                color: Color.fromRGBO(
                                                    2, 84, 100, 1),
                                              ),
                                      ),
                                      // prefixIcon: Icon(
                                      //   Icons.lock_outline_rounded,
                                      //   color: Color.fromRGBO(2, 84, 100, 1),
                                      // ),
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                        fontFamily:
                                            GoogleFonts.plusJakartaSans()
                                                .fontFamily,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    onChanged: (value) => setState(() {}),
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).unfocus();

                                      if (kDebugMode) {
                                        print(usernameController.text);
                                        print(passwordController.text);
                                      }
                                      if (usernameController.text
                                          .trim()
                                          .isEmpty) {
                                        showErrorDialog(
                                          context: context,
                                          message: 'Error',
                                          description:
                                              'Username tidak boleh kosong',
                                          solution: 'Masukkan Username',
                                        );
                                      } else if (passwordController.text
                                          .trim()
                                          .isEmpty) {
                                        showErrorDialog(
                                          context: context,
                                          message: 'Error',
                                          description:
                                              'Password tidak boleh kosong',
                                          solution: 'Masukkan Password',
                                        );
                                      } else {
                                        _handleSignIn();
                                      }
                                    },
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
                                      if (usernameController.text
                                          .trim()
                                          .isEmpty) {
                                        showErrorDialog(
                                          context: context,
                                          message: 'Error',
                                          description:
                                              'Username tidak boleh kosong',
                                          solution: 'Masukkan username',
                                        );
                                      } else if (passwordController.text
                                          .trim()
                                          .isEmpty) {
                                        showErrorDialog(
                                          context: context,
                                          message: 'Error',
                                          description:
                                              'Password tidak boleh kosong',
                                          solution: 'Masukkan password',
                                        );
                                      } else {
                                        _handleSignIn();
                                      }
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                      child: isBusy == true
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child:
                                                  const CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              'Masuk',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
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
                                    controller: fullNameController,
                                    focusNode: nameFocus,
                                    keyboardType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
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
                                      labelText: 'Nama Lengkap',
                                      labelStyle: TextStyle(
                                        fontFamily:
                                            GoogleFonts.plusJakartaSans()
                                                .fontFamily,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    onChanged: (value) => setState(() {}),
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context)
                                          .requestFocus(emailFocus);
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    controller: emailController,
                                    focusNode: emailFocus,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
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
                                        fontFamily:
                                            GoogleFonts.plusJakartaSans()
                                                .fontFamily,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    onChanged: (value) => setState(() {}),
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context)
                                          .requestFocus(usernameFocus);
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    controller: usernameController,
                                    focusNode: usernameFocus,
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
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
                                        fontFamily:
                                            GoogleFonts.plusJakartaSans()
                                                .fontFamily,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    onChanged: (value) => setState(() {}),
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context)
                                          .requestFocus(passwordFocus);
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextFormField(
                                    controller: passwordController,
                                    focusNode: passwordFocus,
                                    textInputAction: TextInputAction.done,
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
                                                color: Color.fromRGBO(
                                                    2, 84, 100, 1),
                                              )
                                            : Icon(
                                                Icons.visibility_off_outlined,
                                                color: Color.fromRGBO(
                                                    2, 84, 100, 1),
                                              ),
                                      ),
                                      // prefixIcon: Icon(
                                      //   Icons.lock_outline_rounded,
                                      //   color: Color.fromRGBO(2, 84, 100, 1),
                                      // ),
                                      labelText: 'Password',
                                      labelStyle: TextStyle(
                                        fontFamily:
                                            GoogleFonts.plusJakartaSans()
                                                .fontFamily,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                    ),
                                    onChanged: (value) => setState(() {}),
                                    onFieldSubmitted: (_) {
                                      FocusScope.of(context).unfocus();

                                      if (kDebugMode) {
                                        print(fullNameController.text);
                                        print(emailController.text);
                                        print(usernameController.text);
                                        print(passwordController.text);
                                      }
                                      if (fullNameController.text
                                          .trim()
                                          .isEmpty) {
                                        showErrorDialog(
                                          context: context,
                                          message: 'Error',
                                          description:
                                              'Nama lengkap tidak boleh kosong',
                                          solution: 'Masukkan nama lengkap',
                                        );
                                      } else if (emailController.text
                                          .trim()
                                          .isEmpty) {
                                        showErrorDialog(
                                          context: context,
                                          message: 'Error',
                                          description:
                                              'Email tidak boleh kosong',
                                          solution: 'Masukkan email',
                                        );
                                      } else if (usernameController.text
                                          .trim()
                                          .isEmpty) {
                                        showErrorDialog(
                                          context: context,
                                          message: 'Error',
                                          description:
                                              'Username tidak boleh kosong',
                                          solution: 'Masukkan username',
                                        );
                                      } else if (passwordController.text
                                          .trim()
                                          .isEmpty) {
                                        showErrorDialog(
                                          context: context,
                                          message: 'Error',
                                          description:
                                              'Password tidak boleh kosong',
                                          solution: 'Masukkan password',
                                        );
                                      } else {
                                        _handleSignUp();
                                      }
                                    },
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.all(0),
                                    onPressed: () async {
                                      if (kDebugMode) {
                                        print(fullNameController.text);
                                        print(emailController.text);
                                        print(usernameController.text);
                                        print(passwordController.text);
                                      }
                                      if (fullNameController.text
                                          .trim()
                                          .isEmpty) {
                                        showErrorDialog(
                                          context: context,
                                          message: 'Error',
                                          description:
                                              'Nama lengkap tidak boleh kosong',
                                          solution: 'Masukkan nama lengkap',
                                        );
                                      } else if (emailController.text
                                          .trim()
                                          .isEmpty) {
                                        showErrorDialog(
                                          context: context,
                                          message: 'Error',
                                          description:
                                              'Email tidak boleh kosong',
                                          solution: 'Masukkan email',
                                        );
                                      } else if (usernameController.text
                                          .trim()
                                          .isEmpty) {
                                        showErrorDialog(
                                          context: context,
                                          message: 'Error',
                                          description:
                                              'Username tidak boleh kosong',
                                          solution: 'Masukkan username',
                                        );
                                      } else if (passwordController.text
                                          .trim()
                                          .isEmpty) {
                                        showErrorDialog(
                                          context: context,
                                          message: 'Error',
                                          description:
                                              'Password tidak boleh kosong',
                                          solution: 'Masukkan password',
                                        );
                                      } else {
                                        _handleSignUp();
                                      }
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
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Color.fromRGBO(2, 84, 100, 1),
                                      ),
                                      child: isBusy == true
                                          ? SizedBox(
                                              height: 20,
                                              width: 20,
                                              child:
                                                  const CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              'Daftar',
                                              style:
                                                  GoogleFonts.plusJakartaSans(
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
                                            fullNameController.clear();
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
      ),
    );
  }

  void _handleSignIn() {
    model.handleSignIn(
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
      onSuccess: () {
        final snackBar = SnackBar(
          content: Text(
              'Masuk ke akun dengan username ${usernameController.text.trim()}'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pushReplacementNamed(context, mainRoute);
      },
      onFailed: () {
        // final snackBar = SnackBar(
        //   content:
        //       Text('Gagal masuk ke akun ${usernameController.text.trim()}'),
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);

        showErrorDialog(
            context: context,
            message: 'Gagal Masuk',
            description: 'Username atau password salah');
      },
    );
  }

  void _handleSignUp() {
    model.handleSignUp(
      name: fullNameController.text.trim(),
      email: emailController.text.trim(),
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
      onSuccess: () {
        final snackBar = SnackBar(
          content: Text(
              'Akun dengan username ${usernameController.text.trim()} berhasil dibuat'),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          fullNameController.clear();
          emailController.clear();
          usernameController.clear();
          passwordController.clear();
          currentAuthState = AuthState.signIn;
          if (kDebugMode) {
            print(currentAuthState);
          }
        });
      },
      onFailed: () {
        // final snackBar = SnackBar(
        //   content: Text('Gagal membuat ke akun'),
        // );
        // ScaffoldMessenger.of(context).showSnackBar(snackBar);
        showErrorDialog(
          context: context,
          message: 'Terjadi Kesalahan',
          description: 'Gagal membuat akun',
        );
      },
    );
  }
}

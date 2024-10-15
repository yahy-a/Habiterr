import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habiter_/screens/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(39, 46, 238, 0.08),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 70,
            ),
            Image.asset(
              'assets/images/Splash.png',
              scale: 1.75,
            ),
            const SizedBox(
              height: 30,
            ),
            Text(
              'Welcome!',
              style: GoogleFonts.nunito(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            Form(
                key: _formKey,
                child: Column(children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(15, 15, 15, 3),
                    child: TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromRGBO(82, 82, 82, 1),
                        hintText: 'Email Address',
                        hintStyle: GoogleFonts.rubik(
                            fontSize: 18, color: Colors.white),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color.fromRGBO(82, 82, 82, 1),
                        hintText: 'Password',
                        hintStyle: GoogleFonts.rubik(
                            fontSize: 18, color: Colors.white),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 330,
                    height: 55,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(141, 74, 248, 1),
                      ),
                      child: Text(
                        'Log In',
                        style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignupScreen())),
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                            text: "DON’T HAVE AN ACCOUNT? ",
                            style: GoogleFonts.nunito(
                                color: const Color.fromRGBO(161, 164, 178, 1),
                                fontSize: 16,
                                fontWeight: FontWeight.w200)),
                        TextSpan(
                            text: "SIGN UP",
                            style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline))
                      ]),
                    ),
                  )
                ]))
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      body: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 70,
            ),
            Container(
              child: Image.asset(
                'assets/images/Splash.png',
                scale: 1.75,
              ),
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
            SizedBox(
              height: 20,
            ),
            Form(
                key: _formKey,
                child: Column(children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(15, 15, 15, 8),
                    child: TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromRGBO(82, 82, 82, 1),
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
                    margin: const EdgeInsets.all(15),
                    child: TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromRGBO(82, 82, 82, 1),
                        hintText: 'Password',
                        hintStyle: GoogleFonts.rubik(
                            fontSize: 18, color: Colors.white),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  Container(
                    width: 330,
                    height: 55,
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Login'),
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromRGBO(141, 74, 248, 1),
                      ),
                    ),
                  )
                ]))
          ],
        ),
      ),
    );
  }
}

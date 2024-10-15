import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habiter_/screens/login.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formKey_ = GlobalKey<FormState>();
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(39, 46, 238, 0.08),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 70,
              ),
              Image.asset(
                'assets/images/Splash.png',
                scale: 2,
              ),
              // const SizedBox(
              //   height: 20,
              // ),
              Text(
                'Create your account',
                style: GoogleFonts.nunito(
                    fontSize: 30,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              // const SizedBox(
              //   height: 10,
              // ),
              Form(
                  key: formKey_,
                  child: Column(children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                      child: TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromRGBO(82, 82, 82, 1),
                          hintText: 'Full Name',
                          hintStyle: GoogleFonts.rubik(
                              fontSize: 18, color: Colors.white),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
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
                      margin: const EdgeInsets.fromLTRB(15, 15, 15, 0),
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
                    Container(
                      margin: const EdgeInsets.fromLTRB(15, 15, 15, 3),
                      child: TextFormField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color.fromRGBO(82, 82, 82, 1),
                          hintText: 'Confirm Password',
                          hintStyle: GoogleFonts.rubik(
                              fontSize: 18, color: Colors.white),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RichText(
                              text: TextSpan(children: <TextSpan>[
                            TextSpan(
                                text: 'I have read the ',
                                style: GoogleFonts.rubik(
                                  fontSize: 18,
                                )),
                            TextSpan(
                                text: 'Privacy Policy',
                                style: GoogleFonts.rubik(
                                  fontSize: 18,
                                  color: Colors.blueAccent, // Color of the link
                                  decoration: TextDecoration.underline,
                                )),
                          ])),
                          Checkbox(
                            value: isChecked,
                            onChanged: (value) {
                              setState(() {
                                isChecked = value!;
                              });
                            },
                            activeColor: Colors.blue,
                          )
                        ]),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 330,
                      height: 55,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(141, 74, 248, 1),
                        ),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10,),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen())),
                   child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: "ALREADY HAVE AN ACCOUNT? ",
                              style: GoogleFonts.nunito(
                                  color: const Color.fromRGBO(161, 164, 178, 1),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200)),
                          TextSpan(
                              text: "SIGN IN",
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
      ),
    );
  }
}

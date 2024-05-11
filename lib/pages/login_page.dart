import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:provider/provider.dart';

import '../services/appwrite/auth_api.dart';
import 'register_page.dart';
import 'tabs_page.dart';

class LoginPage extends StatefulWidget {

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  bool loading = false;
  bool obscureText = true;

  signIn() async {
    try {
      final AuthAPI appwrite = context.read<AuthAPI>();

      // Perform login
      await appwrite.createEmailSession(
        email: emailTextController.text,
        password: passwordTextController.text,
      );

      // Get account information
      final user = await appwrite.currentUser;

      // Check if email is verified
      if (!user.emailVerification) {
        // If email is not verified, stop login process and show a message
        showAlert(title: "Email verification".tr(), text: "Please verify your email.".tr());
        return;
      }

      // Update authentication state in the app
      appwrite.updateAuthenticationStatus(AuthStatus.authenticated);

      // Close the dialog only when login is successful
      Navigator.pop(context); // Close the dialog only when login is successful

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const TabsPage()),
            (route) => false,
      );

      return; // Make sure to end here to avoid continuing execution of the following code
    } on AppwriteException catch (e) {
      // Close the dialog when login fails
      showAlert(title: 'Login failed', text: e.message.toString());
    }
  }


  showAlert({required String title, required String text}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(title),
          content: Text(text),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            )
          ],
        );
      },
    );
  }

  signInWithProvider(String provider) {
    try {
      context.read<AuthAPI>().signInWithProvider(provider: provider);
    } on AppwriteException catch (e) {
      showAlert(title: 'Login failed', text: e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50, bottom: 20),
                  child: Image.asset(
                    "assets/images/login-1.png",
                    width: size.width * 0.8,
                    height: size.height * 0.3, // Set maximum height for the image
                    fit: BoxFit.contain, // Maintain aspect ratio
                  ),
                ),
              ),
              Text(
                "Log In".tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xff97931C),
                  fontSize: 27,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 50),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: emailTextController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF837E93),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(
                        color: Color(0xff97931C),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color(0xFF837E93),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color(0xff97931C),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordTextController,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF393939),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(
                        color: Color(0xff97931C),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color(0xFF837E93),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                          width: 1,
                          color: Color(0xff97931C),
                        ),
                      ),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                          icon: Icon(
                            obscureText ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          )
                      )
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff97931C),
                    ),
                    child: Text(
                      "Sign In".tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${"Don’t have an account".tr()}?",
                        style: const TextStyle(
                          color: Color(0xFF837E93),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 2.5),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterPage()),
                          );
                        },
                        child: Text(
                          "Sign Up".tr(),
                          style: const TextStyle(
                            color: Color(0xff97931C),
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          // Mostra il popup per il reset della password
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Reset password".tr()),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("${"Please enter your email, we will send a recovery email.".tr()}."),
                                    TextField(
                                      controller: emailTextController,
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Cancel".tr()),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      final appwrite = Provider.of<AuthAPI>(context, listen: false);
                                      appwrite.sendRecoveryMail(emailTextController.text);
                                      Navigator.pop(context);
                                    },
                                    child: Text("Send Link".tr()),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          "${"Forget password".tr()}?",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xff97931C),
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

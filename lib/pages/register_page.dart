import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

import '../models/preferences/allergen_preferences.dart';
import '../models/preferences/recipe_preferences.dart';
import '../models/preferences/user_preferences.dart';
import '../services/appwrite/auth_api.dart';
import '../models/allergen.dart';
import 'login_page.dart';
import 'package:foodwaste/models/point.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  final repassTextController = TextEditingController();
  final firstnameTextController = TextEditingController();
  final lastnameTextController = TextEditingController();
  bool obscureTextOne = true;
  bool obscureTextTwo = true;

  static final List<Allergen> _allergens = [
    Allergen(id: 1, name: "Gluten"),
    Allergen(id: 2, name: "Dairy"),
    Allergen(id: 3, name: "Eggs"),
    Allergen(id: 4, name: "Peanuts"),
    Allergen(id: 5, name: "Tree nuts"),
    Allergen(id: 6, name: "Fish"),
    Allergen(id: 7, name: "Shellfish"),
    Allergen(id: 8, name: "Soy"),
    Allergen(id: 9, name: "Celery"),
    Allergen(id: 10, name: "Mustard"),
    Allergen(id: 11, name: "Sesame"),
    Allergen(id: 12, name: "Lupin"),
    Allergen(id: 13, name: "Sulfates"),
    Allergen(id: 14, name: "Cereals"),
    Allergen(id: 15, name: "Mollusk"),
    Allergen(id: 16, name: "Lactose")
  ];

  final _items = _allergens.map((allergen) => MultiSelectItem<Allergen>(allergen, allergen.name.tr())).toList();
  List<Allergen> _selectedAllergens = [];

  createAccount() async {
    try {
      final AuthAPI appwrite = context.read<AuthAPI>();

      // Create user account
      User user = await appwrite.createUser(
        email: emailTextController.text,
        password: passwordTextController.text,
        name: '${firstnameTextController.text} ${lastnameTextController.text}',
      );

      // Create session with email and password
      await appwrite.createEmailSession(
        email: user.email,
        password: passwordTextController.text,
      );

      final userPreferences = UserPreferences(
        allergies: Allergies(allergies: _selectedAllergens),
        recipes: Recipes(recipes: []),
        points: Point(),
      );

      // Show a snackbar
      SnackBar snackbar;
      await appwrite.updatePreferences(preferences: userPreferences);
      bool verificationSent = await appwrite.sendVerificationMail();
      await appwrite.signOut();
      if (verificationSent) {
        snackbar = SnackBar(content: Text("${"Account created! Verification email sent".tr()}."));
      } else {
        snackbar = SnackBar(content: Text("${'Account created! Failed to send verification email'.tr()}."));
      }
      ScaffoldMessenger.of(context).showSnackBar(snackbar);

      // Navigate to login page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on AppwriteException catch (e) {
      showAlert(title: 'Account creation failed', text: e.message.toString());
    }
  }

  showAlert({required String title, required String text}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/login-2.png",
              width: size.width,
              height: size.height * 0.3,
              fit: BoxFit.contain,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.1,
                vertical: size.height * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign up'.tr(),
                    style: const TextStyle(
                      color: Color(0xff97931C),
                      fontSize: 27,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  SizedBox(
                    height: size.height * 0.07,
                    child: TextField(
                      controller: emailTextController,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF393939),
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
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: size.width * 0.35,
                        child: TextField(
                          controller: firstnameTextController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF393939),
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            labelText: 'First Name'.tr(),
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
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.35,
                        child: TextField(
                          controller: lastnameTextController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF393939),
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Surname'.tr(),
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
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: size.width * 0.35,
                        child: TextField(
                          controller: passwordTextController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF393939),
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                          obscureText: obscureTextOne,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Create Password'.tr(),
                            hintStyle: const TextStyle(
                              color: Color(0xFF837E93),
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
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
                                  obscureTextOne = !obscureTextOne;
                                });
                              },
                              icon: Icon(
                                obscureTextOne ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.35,
                        child: TextField(
                          controller: repassTextController,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF393939),
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                          obscureText: obscureTextTwo,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password'.tr(),
                            hintText: 'Confirm Password'.tr(),
                            hintStyle: const TextStyle(
                              color: Color(0xFF837E93),
                              fontSize: 10,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
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
                                  obscureTextTwo = !obscureTextTwo;
                                });
                              },
                              icon: Icon(
                                obscureTextTwo ? Icons.visibility : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF837E93),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        MultiSelectBottomSheetField(
                            initialChildSize: 0.4,
                            listType: MultiSelectListType.CHIP,
                            searchable: true,
                            buttonText: Text(
                                "Allergens".tr(),
                                style: const TextStyle(
                                  color: Color(0xff97931C),
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                            ),
                            items: _items,
                            selectedColor: const Color(0xFF97931C),
                            checkColor: Colors.white,
                            selectedItemsTextStyle: const TextStyle(color: Colors.black),
                            onConfirm: (values) {
                              setState(() {
                                _selectedAllergens = values.cast<Allergen>();
                              });
                            },
                            chipDisplay: MultiSelectChipDisplay(
                            onTap: (value) {
                              setState(() {
                                _selectedAllergens.remove(value);
                              });
                            },
                            chipColor: Colors.grey.withOpacity(0.2),
                            textStyle: const TextStyle(color: Color(0xFF393939)),
                          ),
                        ),
                        _selectedAllergens.isEmpty ? Container(
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "None selected".tr(),
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ) : Container(),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  SizedBox(
                    width: size.width * 0.8,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff97931C),
                      ),
                      onPressed: () {
                        createAccount();
                      },
                      child: Text(
                        'Sign Up'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${"Have an account".tr()}?",
                        style: const TextStyle(
                          color: Color(0xFF837E93),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                        child: Text(
                          "Log In".tr(),
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
                  SizedBox(
                    height: MediaQuery.of(context).viewInsets.bottom, // Keyboard padding
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

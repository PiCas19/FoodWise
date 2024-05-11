import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/bottom_sheet/multi_select_bottom_sheet_field.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:provider/provider.dart';

import '../models/preferences/allergen_preferences.dart';
import '../models/allergen.dart';
import '../models/preferences/recipe_preferences.dart';
import '../models/preferences/user_preferences.dart';
import '../models/recipe.dart';
import '../services/appwrite/auth_api.dart';
import 'login_page.dart';
import '../models/point.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late AuthAPI appwrite;
  late String? email, username, userID;
  TextEditingController bioTextController = TextEditingController();
  late MultiValueDropDownController _cntMulti;
  late UserPreferences userPreferences;
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

  late List<MultiSelectItem<Allergen>> _items;
  late List<Allergen> _selectedAllergens;
  late List<Recipe> listRecipes = [];
  late Point points = Point();


  void _updateAllergensList() {
    setState(() {
      _items.clear();
      _items.addAll(_allergens
          .map((allergen) => MultiSelectItem<Allergen>(allergen, allergen.name.tr()))
          .toList());
    });

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAllergensList();
    loadPreferences();
  }

  @override
  void initState() {
    super.initState();
    _cntMulti = MultiValueDropDownController();
    appwrite = context.read<AuthAPI>();
    email = appwrite.email;
    username = appwrite.username;
    userID = appwrite.currentUser.$id;
    _selectedAllergens = [];
    _items = _allergens
        .map((allergen) => MultiSelectItem<Allergen>(allergen, allergen.name.tr()))
        .toList();
    loadPreferences();
  }

  @override
  void dispose() {
    _cntMulti.dispose();
    super.dispose();
  }

  signOut() {
    final AuthAPI appwrite = context.read<AuthAPI>();
    appwrite.signOut();
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void loadPreferences() async {
    try {
      UserPreferences? userPrefs = await appwrite.getUserPreferences();
      if (userPrefs != null) {
        setState(() {
          _selectedAllergens = (userPrefs.allergies?.allergies ?? [])
              .map((e) {
            Allergen? allergen = _allergens.firstWhere(
                  (a) => a.name.tr() == e.name.tr());
            return allergen;
          })
              .where((element) => element != null)
              .toList()
              .cast<Allergen>();
          listRecipes = userPrefs.recipes?.recipes ?? [];
          points = userPrefs.points;
        });
      }
    } catch (e) {
      print('Failed to load user preferences: $e');
    }
  }





  savePreferences() async {
    try {
      final userPreferences = UserPreferences(
        allergies: Allergies(allergies: _selectedAllergens),
        recipes: Recipes(recipes: listRecipes),
        points: points,
      );

      await appwrite.updatePreferences(preferences: userPreferences);
      const snackbar = SnackBar(content: Text("Preferences updated!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    } catch (e) {
      print('Failed to save user preferences: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Account".tr()),
        backgroundColor: const Color.fromARGB(240, 255, 213, 63),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                child: PopupMenuItem<String>(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Change language".tr()),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PopupMenuItem<String>(
                                child: ListTile(
                                  title: Center(child: Text('Italian'.tr())),
                                ),
                                onTap: () {
                                  setState(() {
                                    context.setLocale(const Locale('it', 'IT'));
                                    _updateAllergensList();
                                  });
                                },
                              ),
                              PopupMenuItem<String>(
                                child: ListTile(
                                  title: Center(child: Text('English'.tr())),
                                ),
                                onTap: () {
                                  setState(() {
                                    context.setLocale(const Locale('en', 'US'));
                                    _updateAllergensList();

                                  });
                                },
                              ),
                            ],
                          ),
                          backgroundColor: const Color.fromARGB(250, 151, 157, 250),
                          icon: const Icon(Icons.language),

                        );
                      },
                    );
                  },
                  child: Text('Change language'.tr()),
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              signOut();
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 255, 240, 170),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              "Name".tr(),
              style: const TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF837E93),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.person),
                      Text('$username'),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              "\n${"Allergens".tr()}",
              style: const TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
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
                    initialValue: _selectedAllergens,
                    initialChildSize: 0.4,
                    listType: MultiSelectListType.CHIP,
                    searchable: true,
                    items: _items,
                    selectedColor: const Color(0xFF97931C),
                    checkColor: Colors.white,
                    selectedItemsTextStyle: const TextStyle(color: Colors.black),
                    onConfirm: (values) {
                      setState(() {
                        _selectedAllergens = values.cast<Allergen>();
                        savePreferences();
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
                  )
                      : Container(),
                ],
              ),
            ),
            const Text(
              "\nEmail",
              style: TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF837E93),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.mail),
                      Text('$email'),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              "\n${"Your points".tr()}",
              style: const TextStyle(fontSize: 20.0),
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/icons8-coin.png'),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF837E93),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    points.value.toString(),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
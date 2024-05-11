import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

import '../controllers/storage_controller.dart';
import '../models/allergen.dart';
import '../models/preferences/allergen_preferences.dart';
import '../models/preferences/recipe_preferences.dart';
import '../models/preferences/user_preferences.dart';
import '../models/recipe.dart';
import '../services/appwrite/auth_api.dart';
import '../models/food.dart';
import '../models/storage.dart';
import '../models/point.dart';
import 'manual_entry_page.dart';

class ScannerBarcodePage extends StatefulWidget {
  const ScannerBarcodePage({super.key});

  @override
  State<ScannerBarcodePage> createState() => _ScannerBarcodePageState();
}

class _ScannerBarcodePageState extends State<ScannerBarcodePage> {
  static const int pointsToAddForScan = 1;
  final StorageController _storageController = StorageController();
  List<Food> scannedFoods = [];
  late DateTime selectedDate;
  late String userId;
  int selectedQuantity = 1;
  late AuthAPI appwrite;
  late Point points = Point();
  List<Allergen> selectedAllergens = [];
  List<Recipe> listRecipes = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    appwrite = context.read<AuthAPI>();
    userId = appwrite.currentUser.$id;
    appwrite.getUserPreferences().then((value) => {
      setState(() {
        selectedAllergens = value!.allergies.allergies;
        listRecipes = value?.recipes.recipes
            .where((recipe) => recipe.userId == userId)
            .toList() ?? [];
        points = value!.points;
      })
    });
  }

  Future<void> _handleScanResult(String result) async {
    final productInfo = await getProductInfoFromAPI(result);
    if (productInfo != null) {
      final BuildContext dialogContext = context;
      showDialog(
        context: dialogContext,
        builder: (context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text('Add Product'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${"Product Name".tr()}:${productInfo['name']}"),
                  Text("${"Brand".tr()}:${productInfo['brand']}"),
                  Text("${"Category".tr()}:${productInfo['category']}"),
                  InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Row(
                      children: [
                        Text("${'Expiry Date'.tr()}: "),
                        const SizedBox(width: 10),
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 10),
                        Text(
                          '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("${'Quantity'.tr()}: "),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (selectedQuantity > 1) {
                              selectedQuantity--;
                            }
                          });
                        },
                      ),
                      Text(
                        selectedQuantity.toString(),
                        style: const TextStyle(fontSize: 20.0),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            selectedQuantity++;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final newFood = Food(
                      name: productInfo['name'],
                      type: FoodType.other,
                      expiryDate: selectedDate,
                      availableQuantity: selectedQuantity,
                      imageName: 'icons8-personalizzazione-di-windows10-96.png',
                    );
                    scannedFoods.add(newFood);
                    points.value += pointsToAddForScan;

                    final userPreferences = UserPreferences(
                      allergies: Allergies(allergies: selectedAllergens),
                      recipes:  Recipes(recipes: listRecipes),
                      points: points,
                    );
                    await appwrite.updatePreferences(preferences: userPreferences);

                    final String? storageId = await _storageController.getStorageIdForUser(userId);
                    if (storageId != null) {
                      await _storageController.addProductsToStorage(storageId, scannedFoods);
                    } else {
                      Storage newStorage = Storage(userId: userId, products: scannedFoods);
                      await _storageController.addStorage(newStorage);
                    }
                    setState(() {
                      scannedFoods.clear();
                    });
                    Navigator.of(dialogContext, rootNavigator: true).pop();
                  },
                  child: Text('Save'.tr()),
                ),
              ],
            );
          },
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product not found in the database'),
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> getProductInfoFromAPI(String barcode) async {
    final apiUrl = 'https://world.openfoodfacts.org/api/v0/product/$barcode.json?lc=en';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (decodedResponse['status'] == 1) {
          final product = decodedResponse['product'];
          String productName = product['product_name'];
          String brand = product['brands'];
          String category = FoodType.other.name;
          String expiryDate = product['expiration_date'] ?? 'Unknown';
          return {
            'name': productName,
            'brand': brand,
            'category': category,
            'expiryDate': expiryDate,
          };
        } else {
          return null;
        }
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Barcode'),
        backgroundColor: const Color.fromARGB(240, 255, 213, 63),
        actions: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(points.value.toString(), style: const TextStyle(fontSize: 20)),
                Image.asset('assets/images/icons8-smallcoin.png'),
              ],
            ),
          ),
        ],
      ),
      body: Builder(
        builder: (context) => Container(
          alignment: Alignment.center,
          color: const Color.fromARGB(255, 255, 240, 170),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SimpleBarcodeScannerPage(),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                    });
                    await _handleScanResult(result);
                  }
                },
                child: Text('Start Barcode Scan'.tr()),
              ),
              Text("\n${"No UPC or scanner not working? Try".tr()}"),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (BuildContext context) {
                      return const ManualEntryPage();
                    }),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Manual entry'.tr(),
                    style: const TextStyle(color: Colors.deepOrange),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


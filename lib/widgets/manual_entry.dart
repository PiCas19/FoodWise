import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodwaste/controllers/storage_controller.dart';
import 'package:foodwaste/services/appwrite/auth_api.dart';
import 'package:provider/provider.dart';
import '../models/allergen.dart';
import '../models/food.dart';
import '../models/preferences/allergen_preferences.dart';
import '../models/preferences/recipe_preferences.dart';
import '../models/preferences/user_preferences.dart';
import '../models/recipe.dart';
import '../models/storage.dart';
import '../models/point.dart';

class ManualEntry extends StatefulWidget {
  final String text;
  final List<Map<String, dynamic>> listWithTextAndImage;

  const ManualEntry({
    super.key,
    required this.text,
    required this.listWithTextAndImage,
  });

  @override
  State<ManualEntry> createState() => _ManualEntryState();
}

class _ManualEntryState extends State<ManualEntry> {
  final StorageController _storageController = StorageController();
  late String userId;
  late Point points = Point();
  List<Allergen> selectedAllergens = [];
  List<Recipe> listRecipes = [];
  late AuthAPI appwrite;
  static const int pointsToAddForManualEntry = 1;

  Future<void> _selectDate(BuildContext context, Food food) async {
    DateTime selectedDate = food.expiryDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        food.setDate(picked);
      });
    }
  }

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.text),
        backgroundColor: const Color.fromARGB(240, 255, 213, 63),
        actions: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(points.value.toString(), style: const TextStyle(fontSize: 20),),
                Image.asset('assets/images/icons8-smallcoin.png'),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 255, 240, 170),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 10.0,
        ),
        itemCount: widget.listWithTextAndImage.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.asset(
                    widget.listWithTextAndImage[index]['image'],
                    fit: BoxFit.none,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    tr(widget.listWithTextAndImage[index]['food'].name),
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          Food food =
                          widget.listWithTextAndImage[index]['food'];
                          if (food.availableQuantity > 0) {
                            food.availableQuantity--;
                          }
                        });
                      },
                    ),
                    Text(
                      widget
                          .listWithTextAndImage[index]['food'].availableQuantity
                          .toString(),
                      style: const TextStyle(fontSize: 20.0),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          widget.listWithTextAndImage[index]['food']
                              .availableQuantity++;
                        });
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      _selectDate(context, widget.listWithTextAndImage[index]['food']);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                    ),
                    child: Center(
                      child: Text('Edit date'.tr()),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ElevatedButton(
          onPressed: () async {
            List<Food> selectedFoods = widget.listWithTextAndImage
                .map((item) => (item['food'] as Food))
                .where((food) => food.availableQuantity > 0)
                .toList();

            points.value +=  pointsToAddForManualEntry;
            final userPreferences = UserPreferences(
              allergies: Allergies(allergies: selectedAllergens),
              recipes:  Recipes(recipes: listRecipes),
              points: points,
            );
            await appwrite.updatePreferences(preferences: userPreferences);

            if (selectedFoods.isNotEmpty) {
              final String? storageId =  await _storageController.getStorageIdForUser(userId);
              if (storageId != null) {
                await _storageController.addProductsToStorage(storageId, selectedFoods);
              } else {
                Storage newStorage =  Storage(userId: userId, products: selectedFoods);
                await _storageController.addStorage(newStorage);
              }

              setState(() {
                selectedFoods.clear();
                for (var item in widget.listWithTextAndImage) {
                  item['food'].availableQuantity = 0;
                }
                Navigator.pop(context);
              });
            }
          },
          child: Text('Save'.tr()),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endDocked, // Posizione del bottone
    );
  }
}

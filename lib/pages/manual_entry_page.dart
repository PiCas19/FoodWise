import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:foodwaste/models/preferences/user_preferences.dart';
import 'package:provider/provider.dart';
import '../controllers/storage_controller.dart';
import '../models/allergen.dart';
import '../models/preferences/allergen_preferences.dart';
import '../models/preferences/recipe_preferences.dart';
import '../models/recipe.dart';
import '../widgets/manual_entry.dart';
import '../models/food.dart';
import '../services/appwrite/auth_api.dart';
import '../models/storage.dart';
import '../models/point.dart';

class ManualEntryPage extends StatefulWidget {
  const ManualEntryPage({super.key});

  @override
  State<ManualEntryPage> createState() => _ManualChoiceState();
}

class _ManualChoiceState extends State<ManualEntryPage> {

  final List<Map<String, dynamic>> manualEntryImagesWithText = [
    {
      'text': "Bakery".tr(),
      'image': 'assets/images/icons8-pasticcino-96.png',
      'page' : const BakeryPage(),
    },
    {
      'text': "Vegetables".tr(),
      'image': 'assets/images/icons8-gruppo-di-verdure-96.png',
      'page' : const VegetablesPage(),
    },
    {
      'text': "Fruits".tr(),
      'image': 'assets/images/icons8-sacchetto-di-frutta-96.png',
      'page' : const FruitsPage(),
    },
    {
      'text': "Others".tr(),
      'image': 'assets/images/icons8-personalizzazione-di-windows10-96.png',
      'page' : const CustomizePage(),
    },
  ];

  late Point points = Point();


  @override
  void initState() {
    super.initState();
    final AuthAPI appwrite = context.read<AuthAPI>();
    appwrite.getUserPreferences().then((value) => {
      setState(() {
        points = value!.points;
      })
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Manual entry".tr()),
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
      body: Center(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
          ),
          itemCount: manualEntryImagesWithText.length,
          itemBuilder: (BuildContext context, int index) {
            final item = manualEntryImagesWithText[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => item['page'],
                  ),
                );
              },
              child: Card(
                elevation: 4.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      item['image'],
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['text'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}



class BakeryPage extends StatefulWidget {
  const BakeryPage({super.key});

  @override
  State<BakeryPage> createState() => _BakeryPageState();
}

class _BakeryPageState extends State<BakeryPage> {
  List<Map<String, dynamic>> bakeryImagesWithText = [
    {
      'food': Food(name: 'Donut'.tr(), type: FoodType.bakery, expiryDate: DateTime.now(), imageName: "icons8-ciambella-96.png"),
      'image': 'assets/bakeryimages/icons8-ciambella-96.png',
    },
    {
      'food': Food(name: 'Cornet', type: FoodType.bakery, expiryDate: DateTime.now(), imageName: "icons8-cornetto-96.png"),
      'image': 'assets/bakeryimages/icons8-cornetto-96.png',
    },
    {
      'food': Food(name: 'Bread', type: FoodType.bakery, expiryDate: DateTime.now(), imageName: "icons8-pane-96.png"),
      'image': 'assets/bakeryimages/icons8-pane-96.png',
    },
    {
      'food': Food(name: 'Pizza', type: FoodType.bakery, expiryDate: DateTime.now(), imageName: "icons8-pizza-96.png"),
      'image': 'assets/bakeryimages/icons8-pizza-96.png',
    },
    {
      'food': Food(name: 'Cake', type: FoodType.bakery, expiryDate: DateTime.now(), imageName: "icons8-torta-96.png"),
      'image': 'assets/bakeryimages/icons8-torta-96.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ManualEntry(
      text: 'Bakery'.tr(),
      listWithTextAndImage: bakeryImagesWithText,
    );
  }
}

class VegetablesPage extends StatefulWidget {
  const VegetablesPage({super.key});

  @override
  State<VegetablesPage> createState() => _VegetablesPageState();
}

class _VegetablesPageState extends State<VegetablesPage> {

  List<Map<String, dynamic>> vegetableImagesWithText = [
    {
      'food': Food(name: 'Garlic', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-aglio-96.png"),
      'image': 'assets/vegetableimages/icons8-aglio-96.png',
    },
    {
      'food': Food(name: 'Asparagus', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-asparago-96.png"),
      'image': 'assets/vegetableimages/icons8-asparago-96.png',
    },
    {
      'food': Food(name: 'Beetroot', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-barbabietola-96.png"),
      'image': 'assets/vegetableimages/icons8-barbabietola-96.png',
    },
    {
      'food': Food(name: 'Broccoli', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-broccoli-96.png"),
      'image': 'assets/vegetableimages/icons8-broccoli-96.png',
    },
    {
      'food': Food(name: 'Artichoke', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-carciofo-96.png"),
      'image': 'assets/vegetableimages/icons8-carciofo-96.png',
    },
    {
      'food': Food(name: 'Carrot', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-carota-96.png"),
      'image': 'assets/vegetableimages/icons8-carota-96.png',
    },
    {
      'food': Food(name: 'Cauliflower', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-cavolfiore-96.png"),
      'image': 'assets/vegetableimages/icons8-cavolfiore-96.png',
    },
    {
      'food': Food(name: 'Cabbage', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-cavolo-96.png"),
      'image': 'assets/vegetableimages/icons8-cavolo-96.png',
    },
    {
      'food': Food(name: 'Cucumber', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-cetriolo-96.png"),
      'image': 'assets/vegetableimages/icons8-cetriolo-96.png',
    },
    {
      'food': Food(name: 'Onion', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-cipolla-96.png"),
      'image': 'assets/vegetableimages/icons8-cipolla-96.png',
    },
    {
      'food': Food(name: 'Fennel', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-finocchio-96.png"),
      'image': 'assets/vegetableimages/icons8-finocchio-96.png',
    },
    {
      'food': Food(name: 'Mushroom', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-fungo-96.png"),
      'image': 'assets/vegetableimages/icons8-fungo-96.png',
    },
    {
      'food': Food(name: 'Lettuce', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-lattuga-96.png"),
      'image': 'assets/vegetableimages/icons8-lattuga-96.png',
    },
    {
      'food': Food(name: 'Corn', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-mais-96.png"),
      'image': 'assets/vegetableimages/icons8-mais-96.png',
    },
    {
      'food': Food(name: 'Aubergine', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-melanzana-96.png"),
      'image': 'assets/vegetableimages/icons8-melanzana-96.png',
    },
    {
      'food': Food(name: 'Potato', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-patata-96.png"),
      'image': 'assets/vegetableimages/icons8-patata-96.png',
    },
    {
      'food': Food(name: 'Pepper', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName:  "icons8-peperone-96.png"),
      'image': 'assets/vegetableimages/icons8-peperone-96.png',
    },
    {
      'food': Food(name: 'Tomato', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-pomodori-96.png"),
      'image': 'assets/vegetableimages/icons8-pomodori-96.png',
    },
    {
      'food': Food(name: 'Radish', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-ravanello-96.png"),
      'image': 'assets/vegetableimages/icons8-ravanello-96.png',
    },
    {
      'food': Food(name: 'Celery', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-sedano-96.png"),
      'image': 'assets/vegetableimages/icons8-sedano-96.png',
    },
    {
      'food': Food(name: 'Spinach', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-spinaci-96.png"),
      'image': 'assets/vegetableimages/icons8-spinaci-96.png',
    },
    {
      'food': Food(name: 'Courgette', type: FoodType.vegetable, expiryDate: DateTime.now(), imageName: "icons8-zucchine-96.png"),
      'image': 'assets/vegetableimages/icons8-zucchine-96.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ManualEntry(text: 'Vegetables'.tr(), listWithTextAndImage: vegetableImagesWithText);
  }
}

class FruitsPage extends StatefulWidget {
  const FruitsPage({super.key});

  @override
  State<FruitsPage> createState() => _FruitsPageState();
}

class _FruitsPageState extends State<FruitsPage> {

  List<Map<String, dynamic>> fruitImagesWithText = [
    {
      'food': Food(name: 'Apricot', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-albicocca-96.png"),
      'image': 'assets/fruitimages/icons8-albicocca-96.png',
    },
    {
      'food': Food(name: 'Pineapple', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-ananas-96.png"),
      'image': 'assets/fruitimages/icons8-ananas-96.png',
    },
    {
      'food': Food(name: 'Watermelon', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-anguria-96.png"),
      'image': 'assets/fruitimages/icons8-anguria-96.png',
    },
    {
      'food': Food(name: 'Orange', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-arancia-96.png"),
      'image': 'assets/fruitimages/icons8-arancia-96.png',
    },
    {
      'food': Food(name: 'Banana', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-banana-96.png"),
      'image': 'assets/fruitimages/icons8-banana-96.png',
    },
    {
      'food': Food(name: 'Cherry', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-ciliegia-96.png"),
      'image': 'assets/fruitimages/icons8-ciliegia-96.png',
    },
    {
      'food': Food(name: 'Strawberry', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-fragola-96.png"),
      'image': 'assets/fruitimages/icons8-fragola-96.png',
    },
    {
      'food': Food(name: 'Kiwi', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-kiwi-96.png"),
      'image': 'assets/fruitimages/icons8-kiwi-96.png',
    },
    {
      'food': Food(name: 'Raspberry', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-lampone-96.png"),
      'image': 'assets/fruitimages/icons8-lampone-96.png',
    },
    {
      'food': Food(name: 'Lemon', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-limone-96.png"),
      'image': 'assets/fruitimages/icons8-limone-96.png',
    },
    {
      'food': Food(name: 'Mandarin', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-mandarino-96.png"),
      'image': 'assets/fruitimages/icons8-mandarino-96.png',
    },
    {
      'food': Food(name: 'Mango', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-mango-96.png"),
      'image': 'assets/fruitimages/icons8-mango-96.png',
    },
    {
      'food': Food(name: 'Apple', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-mela-96.png"),
      'image': 'assets/fruitimages/icons8-mela-96.png',
    },
    {
      'food': Food(name: 'Melon', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-melone-96.png"),
      'image': 'assets/fruitimages/icons8-melone-96.png',
    },
    {
      'food': Food(name: 'Blueberry', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-mirtillo-96.png"),
      'image': 'assets/fruitimages/icons8-mirtillo-96.png',
    },
    {
      'food': Food(name: 'Pear', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-pera-96.png"),
      'image': 'assets/fruitimages/icons8-pera-96.png',
    },
    {
      'food': Food(name: 'Peach', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-pesca-96.png"),
      'image': 'assets/fruitimages/icons8-pesca-96.png',
    },
    {
      'food': Food(name: 'Plum', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-prugna-96.png"),
      'image': 'assets/fruitimages/icons8-prugna-96.png',
    },
    {
      'food': Food(name: 'Grape', type: FoodType.fruit, expiryDate: DateTime.now(), imageName: "icons8-uva-96.png"),
      'image': 'assets/fruitimages/icons8-uva-96.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ManualEntry(text: 'Fruits'.tr(), listWithTextAndImage: fruitImagesWithText);
  }
}

class CustomizePage extends StatefulWidget {
  const CustomizePage({super.key});

  @override
  State<CustomizePage> createState() => _CustomizePageState();
}

class _CustomizePageState extends State<CustomizePage> {
  static const int pointsToAddForManualEntry = 1;
  late List<Food> otherProductsNames;
  late String userId;
  final TextEditingController _controller = TextEditingController();
  final StorageController _storageController = StorageController();
  late Point points = Point();
  List<Allergen> selectedAllergens = [];
  List<Recipe> listRecipes = [];
  late AuthAPI appwrite;

  @override
  void initState() {
    super.initState();
    otherProductsNames = [];
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

  Future<void> _selectDate(BuildContext context, Food food) async {
    DateTime selectedDate = food.expiryDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: selectedDate,
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        food.setDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Other products'.tr()),
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "${'Type your product here'.tr()}...",
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      setState(() {
                        _addNewCard(_controller
                            .text); // Aggiunge una nuova Card con il testo inserito nel TextField
                        _controller.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemCount: otherProductsNames.length,
              itemBuilder: (context, index) {
                return _buildCard(
                    otherProductsNames[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: ElevatedButton(
          onPressed: () async {
            points.value += pointsToAddForManualEntry;

            final userPreferences = UserPreferences(
              allergies: Allergies(allergies: selectedAllergens),
              recipes:  Recipes(recipes: listRecipes),
              points: points,
            );
            await appwrite.updatePreferences(preferences: userPreferences);

            List<Food> selectedFoods = otherProductsNames
                .map((item) => item)
                .where((food) => food.availableQuantity > 0)
                .toList();


            if (selectedFoods.isNotEmpty) {
              final String? storageId = await _storageController
                  .getStorageIdForUser(userId);
              if (storageId != null) {
                await _storageController.addProductsToStorage(
                    storageId, selectedFoods);
              } else {
                Storage newStorage = Storage(
                    userId: userId, products: selectedFoods);
                await _storageController.addStorage(newStorage);
              }

              setState(() {
                selectedFoods.clear();
                for (var item in otherProductsNames) {
                  item.availableQuantity = 0;
                }
                Navigator.pop(context);
              });
            }
          },
          child: Text('Save'.tr()),
        ),
      ),
      floatingActionButtonLocation:
      FloatingActionButtonLocation.endDocked,
    );
  }

  void _addNewCard(String productName) {
    setState(() {
      otherProductsNames.add(Food(
          name: productName, type: FoodType.other, expiryDate: DateTime.now(), imageName: 'icons8-personalizzazione-di-windows10-96.png'));
    });
  }

  void _removeCard(Food food) {
    setState(() {
      otherProductsNames.remove(food);
    });
  }

  Widget _buildCard(Food food) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(4.0), // Ridotto il padding a 4.0
            child: Text(
              food.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16.0, // Mantenuta la dimensione del testo a 16.0
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2, // Limitato il testo a 2 righe
              overflow: TextOverflow
                  .ellipsis, // Mostra "..." se il testo è troncato
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    if (food.availableQuantity > 0) {
                      food.availableQuantity--;
                      food.availableQuantity.toString();
                    }
                  });
                },
              ),
              Text(
                food.availableQuantity.toString(),
                style: const TextStyle(fontSize: 20.0),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    food.availableQuantity++;
                    food.availableQuantity.toString();
                  });
                },
              ),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribuisce lo spazio uniformemente tra i widget
            children: [
              TextButton(
                onPressed: () {
                  _removeCard(food);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Riduci il padding verticale
                ),
                child: Text('Remove'.tr()),
              ),
              ElevatedButton(
                onPressed: () {
                  _selectDate(context, food);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                ),
                child: Center(
                  child: Text('Edit date'.tr()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



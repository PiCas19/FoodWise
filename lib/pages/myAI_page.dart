import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fraction/fraction.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:provider/provider.dart';
import '../models/point.dart';
import '../controllers/storage_controller.dart';
import '../models/allergen.dart';
import '../models/food.dart';
import '../models/openai/message.dart';
import '../models/preferences/allergen_preferences.dart';
import '../models/preferences/user_preferences.dart';
import '../services/appwrite/auth_api.dart';
import '../services/openai/chat_service.dart';
import '../models/recipe.dart';
import '../models/preferences/recipe_preferences.dart';

class MyAIPage extends StatefulWidget {
  const MyAIPage({super.key});

  @override
  State<MyAIPage> createState() => _MyAIPageState();
}

class _MyAIPageState extends State<MyAIPage> {
  static const int pointsToAddForAI = 2;
  TextEditingController controller = TextEditingController();
  ScrollController scrollController = ScrollController();
  late String? currentUserId;
  final StorageController _storageController = StorageController();
  late AuthAPI appwrite;
  List<Message> msgs = [];
  List<Food> allFoodList = [];
  List<Food> selectedFoods = [];
  List<Recipe> listRecipes = [];
  static final List<Allergen> _allergens = [
    Allergen(id: 1, name: "Gluten".tr()),
    Allergen(id: 2, name: "Dairy".tr()),
    Allergen(id: 3, name: "Eggs".tr()),
    Allergen(id: 4, name: "Peanuts".tr()),
    Allergen(id: 5, name: "Tree nuts".tr()),
    Allergen(id: 6, name: "Fish".tr()),
    Allergen(id: 7, name: "Shellfish".tr()),
    Allergen(id: 8, name: "Soy".tr()),
    Allergen(id: 9, name: "Celery".tr()),
    Allergen(id: 10, name: "Mustard".tr()),
    Allergen(id: 11, name: "Sesame".tr()),
    Allergen(id: 12, name: "Lupin".tr()),
    Allergen(id: 13, name: "Sulfates".tr()),
    Allergen(id: 14, name: "Cereals".tr()),
    Allergen(id: 15, name: "Mollusk".tr()),
    Allergen(id: 16, name: "Lactose".tr())
  ];
  List<Allergen> _selectedAllergens = [];
  double proportionFactor = 1.0;
  bool isSheetOpen = false;
  late Point points = Point();


  @override
  void initState() {
    super.initState();
    appwrite = context.read<AuthAPI>();
    currentUserId = appwrite.currentUser.$id;
    _storageController.fetchStoragesForUser(currentUserId!).then((_) {
      appwrite.getUserPreferences().then((value) {
        setState(() {
          _selectedAllergens = value?.allergies.allergies
              .map((allergen) => getMatchingAllergenByName(allergen.name))
              .where((allergen) => allergen != null)
              .cast<Allergen>()
              .toList() ?? [];
          if (_storageController.listStorages!.isNotEmpty) {
            allFoodList = _storageController.listStorages!
                .expand((storage) => storage.products)
                .toList();
          } else {
            allFoodList = [];
          }
          listRecipes = value?.recipes.recipes
              .where((recipe) => recipe.userId == currentUserId)
              .toList() ?? [];
          points = value!.points;
        });
      });
    });
  }


  Future<void> saveRecipe(Message message) async {
    final cleanedRecipe = message.content?.replaceAll(RegExp(r'[\[\]]'), '');
    final titleAndContent = cleanedRecipe?.split('\n');
    final title = titleAndContent?[0] ?? '';
    final content = titleAndContent?.sublist(1).join('\n') ?? '';
    bool recipeExists = listRecipes.any((recipe) => recipe.title == title);

    if (!recipeExists) {
      final recipe = Recipe(userId: currentUserId.toString(), title: title, content: content);
      listRecipes.add(recipe);
      final userPreferences = UserPreferences(
        allergies: Allergies(allergies: _selectedAllergens),
        recipes:  Recipes(recipes: listRecipes),
        points: points,
      );
      await appwrite.updatePreferences(preferences: userPreferences);
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recipe saved to cache'.tr()),
          ),
        );
      });
    } else {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recipe already saved'.tr()),
          ),
        );
      });
    }
  }


  Allergen? getMatchingAllergenByName(String name) {
    return _allergens
        .firstWhere((allergen) => allergen.name.tr() == name.tr());
  }

  Future<void> sendMsg() async {

    String prompt = "${"Create a recipe with these products".tr()}:${selectedFoods.map((food) => food.name).join(", ")}";
    if (_selectedAllergens.isNotEmpty) {
      prompt += " ${"avoiding these allergens".tr()}:${_selectedAllergens.map((allergen) => allergen.name).join(", ")}";
    }


    final userMessage = Message(role: "user", content: prompt);
    setState(() {
      msgs.insert(0, userMessage);
    });

    final response = await ChatService().request("${userMessage.content}. What I want to see is a recipe title, a list of ingredients with quantities for one person, and the instructions I have to do to make the recipe.");
    setState(() {
      msgs.insert(0, Message(role: "bot", content: response ?? "No response"));
      points.value += pointsToAddForAI;
    });
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _extractInstructions(String content) {
    List<String> lines = content.split('\n');
    List<String> instructions = [];

    for (String line in lines) {
      if (RegExp(r'^\d+\.\s').hasMatch(line.trim())) {
        instructions.add(line.trim());
      }
    }
    return instructions.join('\n');
  }

  String _displayIngredients(String content, double factor) {
    List<String> lines = content.split('\n');
    List<String> modifiedIngredients = [];
    for (String line in lines) {
      if (line.startsWith("-")) {
        // Split the line into quantity and description
        List<String> parts = line.substring(1).trim().split(' ');
        if (parts.length >= 2) {
          String quantityString = parts[0];
          String description = parts.sublist(1).join(' ');
          // Try parsing the quantity as a fraction, handling potential errors
          try {
            Fraction originalFraction = Fraction.fromString(quantityString);
            // Convert the original fraction to a double and adjust it based on the factor
            double originalDouble = originalFraction.toDouble();
            double adjustedDouble = originalDouble * factor;
            // Convert the adjusted double back to a fraction
            Fraction adjustedFraction = Fraction.fromDouble(adjustedDouble);
            // Build the modified ingredient line with the adjusted fraction
            String modifiedLine = "- ${adjustedFraction.toString()} $description";
            // Add the modified ingredient line to the list
            modifiedIngredients.add(modifiedLine);
          } catch (e) {
            // Handle the case where the quantity string is not a valid fraction
            // Here you can choose to skip this ingredient, log an error, or handle it differently
            // Add the original line as it is
            modifiedIngredients.add(line);
          }
        }
      }
    }
    // Join the modified ingredient lines back into a single string
    return modifiedIngredients.join('\n');
  }

  // Function to display original instructions
  String _displayInstructions(String content) {
    String instructions = _extractInstructions(content);
    // You can process instructions further here if needed
    return instructions;
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MyAI"),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromARGB(240, 255, 213, 63),
              ),
              child: Text(
                'Saved recipes'.tr(),
              ),
            ),
            Column(
              children: listRecipes.map((recipe) {
                return ListTile(
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        listRecipes.removeWhere((r) => r.title == recipe.title);
                        final userPreferences = UserPreferences(
                          allergies: Allergies(allergies: _selectedAllergens),
                          recipes: Recipes(recipes: listRecipes),
                          points: points,
                        );
                        appwrite.updatePreferences(preferences: userPreferences);

                      });
                    },
                  ),
                  title: Text(recipe.title),
                  onTap: () {
                    if (!isSheetOpen) {
                      showModalBottomSheet<void>(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        backgroundColor: Colors.white,
                        builder: (BuildContext context) {
                          return SingleChildScrollView(
                            child: StatefulBuilder(
                              builder: (BuildContext context, StateSetter setState) {
                                return Container(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        recipe.title,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        "${'Ingredients'.tr()}: ",
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      // Display original ingredients
                                      Text(
                                        _displayIngredients(recipe.content, proportionFactor),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "${'Instructions'.tr()}: ",
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      // Display original instructions
                                      Text(
                                        _displayInstructions(recipe.content),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "${'Adjust Proportions'.tr()}: ",
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove),
                                            onPressed: () {
                                              setState(() {
                                                if (proportionFactor > 1) {
                                                  proportionFactor--;
                                                }
                                              });
                                            },
                                          ),
                                          Text(
                                            proportionFactor.toString(),
                                            style: const TextStyle(fontSize: 20.0),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () {
                                              setState(() {
                                                if (proportionFactor < 9) {
                                                  proportionFactor++;
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            proportionFactor = 1;
                                            isSheetOpen = true;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: Text('Close'.tr()),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ).whenComplete(() {
                        setState(() {
                          isSheetOpen = false;
                        });
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
      body:buildBody(),
    );
  }

  Widget buildBody() {
    if (allFoodList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("You don't have any food stored yet.".tr()),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: msgs.length,
              shrinkWrap: true,
              reverse: true,
              itemBuilder: (context, index) {
                final message = msgs[index];
                return Column(
                  children: [
                    Row(
                      children: [
                        if (message.role == "bot")
                          IconButton(
                            icon: const Icon(Icons.bookmark_border),
                            onPressed: () {
                              saveRecipe(message);
                            },
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: BubbleNormal(
                              text: message.content ?? "",
                              isSender: message.role == "user",
                              color: message.role == "user"
                                  ? const Color.fromARGB(255, 215, 195, 177)
                                  : const Color.fromARGB(255, 189, 154, 126),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 240, 170),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color.fromARGB(255, 204, 177, 153),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MultiSelectDialogField<Food>(
                        backgroundColor: Colors.white,
                        listType: MultiSelectListType.CHIP,
                        selectedColor: const Color(0xFF97931C),
                        checkColor: Colors.white,
                        selectedItemsTextStyle: const TextStyle(
                            color: Colors.black),
                        items: allFoodList.map((food) =>
                            MultiSelectItem<Food>(food, food.name)).toList(),
                        initialValue: selectedFoods,
                        onConfirm: (List<Food>? values) {
                          setState(() {
                            selectedFoods = values ?? [];
                          });
                        },
                        chipDisplay: MultiSelectChipDisplay(
                          onTap: (value) {
                            setState(() {
                              selectedFoods.remove(value);
                            });
                          },
                          chipColor: Colors.grey.withOpacity(0.2),
                          textStyle: const TextStyle(color: Color(0xFF393939)),
                        ),
                        searchable: true,
                        buttonText: Text("Select Foods".tr()),
                        title: Text("Select Foods".tr()),
                      ),
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: selectedFoods.isNotEmpty ? sendMsg : null,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 204, 177, 153),
                    // Colore di sfondo del pulsante di invio
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ],
      );
    }
  }

}

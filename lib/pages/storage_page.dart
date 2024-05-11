import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:searchable_listview/searchable_listview.dart';
import '../models/food.dart';
import '../models/storage.dart';
import '../controllers/storage_controller.dart';
import '../services/appwrite/auth_api.dart';
import '../widgets/empty_view.dart';
import '../widgets/storage_item.dart';
import '../models/point.dart';

class StoragePage extends StatefulWidget {
  const StoragePage({super.key});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> with SingleTickerProviderStateMixin {
  late String? userId;
  final StorageController _storageController = StorageController();
  late List<Food> allFoodList;
  late TabController _tabController;
  late Point points = Point();

  @override
  void initState() {
    super.initState();
    final AuthAPI appwrite = context.read<AuthAPI>();
    userId = appwrite.currentUser.$id;
    appwrite.getUserPreferences().then((value) => {
      setState(() {
        points = value!.points;
      })
    });
    _storageController.fetchStorages();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _storageController.fetchStorages();
        });
      }
    });
  }

  void handleProduct() {
    _storageController.fetchStorages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Storage'.tr()),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Bakery'.tr()),
            Tab(text: 'Vegetables'.tr()),
            Tab(text: 'Fruits'.tr()),
            Tab(text: 'Others'.tr())
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 240, 170),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    renderSimpleSearchableList(FoodType.bakery),
                    renderSimpleSearchableList(FoodType.vegetable),
                    renderSimpleSearchableList(FoodType.fruit),
                    renderSimpleSearchableList(FoodType.other)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget renderSimpleSearchableList(FoodType foodType) {
    return ValueListenableBuilder<bool>(
      valueListenable: _storageController.isLoadingNotifier,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return Padding(
            padding: const EdgeInsets.all(15),
            child: SearchableList<Storage>(
              displayClearIcon: false,
              style: const TextStyle(fontSize: 25),
              builder: (list, index, item) {
                if (item.userId == userId) {
                  return FutureBuilder<List<Food>>(
                    future: _storageController.getFoodsForStorage(item),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          List<Food> foodList = snapshot.data ?? [];
                          List<Food> filteredFoodList = foodList.where((food) => food.type == foodType).toList();
                          return FutureBuilder<List<String>>(
                            future: _storageController.getProductIDs(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else {
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  if (filteredFoodList.isEmpty) {
                                    return Center(
                                      child: EmptyView(text: 'No products available in this storage'.tr()),
                                    );
                                  } else {
                                    return Column(
                                      children: [
                                        StorageItem(
                                          storage: item,
                                          foodList: filteredFoodList,
                                          onAction: () {
                                            setState(() {
                                              handleProduct();
                                            });
                                          },
                                        ),
                                        if (index < list.length - 1) const Divider(),
                                      ],
                                    );
                                  }
                                }
                              }
                            },
                          );
                        }
                      }
                    },
                  );
                } else {
                  return const SizedBox.shrink(); // Rendi la cella invisibile se non è l'utente corrente
                }
              },
              errorWidget: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    color: Colors.red,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Error while fetching storages'),
                ],
              ),
              initialList: _storageController.listStorages ?? [],
              filter: (query) {
                return _storageController.listStorages
                    ?.where((storage) =>
                    storage.products.any((food) =>
                    food.name.toLowerCase().contains(query.toLowerCase()) &&
                        food.type == foodType))
                    .map((storage) => Storage(
                    userId: storage.userId,
                    products: storage.products
                        .where((food) =>
                    food.name.toLowerCase().contains(query.toLowerCase()) &&
                        food.type == foodType)
                        .toList()))
                    .toList() ??
                    [];
              },
              emptyWidget: EmptyView(text: 'No products found'.tr()),
              inputDecoration: InputDecoration(
                labelText: "Search in Storage".tr(),
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              closeKeyboardWhenScrolling: true,
            ),
          );
        }
      },
    );
  }
}

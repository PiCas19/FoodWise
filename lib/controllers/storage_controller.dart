import 'package:appwrite/models.dart';
import 'package:flutter/foundation.dart';
import '../constants/constants.dart';
import '../models/food.dart';
import '../models/storage.dart';
import '../services/appwrite/database_api.dart';

class StorageController extends ChangeNotifier {
  DatabaseAPI _databaseAPI = DatabaseAPI();
  bool _isLoading = false;
  List<Storage>? _listStorages;

  bool get isLoading => _isLoading;

  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);
  ValueListenable<bool> get isLoadingNotifier => _isLoadingNotifier;

  List<Storage>? get listStorages => _listStorages;

  StorageController() {
    _isLoading = true;
  }

  Future<Document> addStorage(Storage storage) async {
    try {
      _isLoadingNotifier.value = true;
      final documentStorage = await _databaseAPI.createDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_STORAGES_ID,
        data: storage.toJson(),
      );
      await fetchStorages();
      _isLoadingNotifier.value = false;
      return documentStorage;
    } catch (e) {
      _isLoadingNotifier.value = false;
      rethrow;
    }
  }

  Future<void> fetchStorages() async {
    try {
      _isLoadingNotifier.value = true;
      final storageListData = await _databaseAPI.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_STORAGES_ID,
      );
      _listStorages = storageListData.documents
          .map((document) => Storage.fromJson(document.data))
          .toList();
      _isLoadingNotifier.value = false;
      notifyListeners();
    } catch (e) {
      _isLoadingNotifier.value = false;
      rethrow;
    }
  }

  Future<List<Food>> getFoodsForStorage(Storage storage) async {
    try {
      return storage.products;
    } catch (e) {
      throw Exception('Failed to get foods for storage: $e');
    }
  }


  Future<String?> getStorageIdForUser(String userId) async {
    try {
      final storageListData = await _databaseAPI.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_STORAGES_ID,
      );
      final storageDocument = storageListData.documents.firstWhere(
            (document) => document.data['userId'] == userId
      );
      if (storageDocument != null) {
        return storageDocument.$id;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<List<String>> getProductIDs() async {
    try {
      final storageListData = await _databaseAPI.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_STORAGES_ID,
      );

      List<String> productIDs = [];
      for (var storageDocument in storageListData.documents) {
        List<dynamic> products = storageDocument.data['products'];
        for (var product in products) {
          String? productId = product['\$id'];
          if (productId != null) {
            productIDs.add(productId);
          }
        }
      }
      return productIDs;
    } catch (e) {
      throw Exception('Failed to get product IDs: $e');
    }
  }

  Future<void> addProductsToStorage(String documentId, List<Food> products) async {
    try {
      final storageDocument = await _databaseAPI.getDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_STORAGES_ID,
        documentId: documentId,
      );

      List<dynamic> productsData = storageDocument.data['products'] ?? [];
      List<String> existingProductIds = productsData.map((product) => Food.fromJson(product).id).toList();
      List<Food> existingProducts = productsData.map((product) => Food.fromJson(product)).toList();

      for (Food product in products) {
        if (!existingProductIds.contains(product.id)) {
          existingProducts.add(product);
        }
      }
      await _databaseAPI.updateDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_STORAGES_ID,
        documentId: documentId,
        data: {'products': existingProducts.map((product) => product.toJson()).toList()},
      );
    } catch (e) {
      throw Exception('Failed to add products to storage: $e');
    }
  }

  Future<void> fetchStoragesForUser(String userId) async {
    try {
      _isLoadingNotifier.value = true;
      final storageListData = await _databaseAPI.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_STORAGES_ID,
      );
      _listStorages = storageListData.documents
          .map((document) => Storage.fromJson(document.data))
          .where((storage) => storage.userId == userId) // Filtra gli storage per userId
          .toList();
      _isLoadingNotifier.value = false;
      notifyListeners();
    } catch (e) {
      _isLoadingNotifier.value = false;
      rethrow;
    }
  }


}

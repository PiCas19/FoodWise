import 'package:flutter/foundation.dart';
import 'package:foodwaste/constants/constants.dart';
import '../models/food.dart';
import '../services/appwrite/database_api.dart';

class ProductController extends ChangeNotifier {
  DatabaseAPI _databaseAPI = DatabaseAPI();
  bool _isLoading = false;
  List<Food>? _listProducts;

  bool get isLoading => _isLoading;

  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);
  ValueListenable<bool> get isLoadingNotifier => _isLoadingNotifier;

  List<Food>? get listProducts => _listProducts;

  ProductController() {
    _isLoading = true;
  }


  Future<void> removeProduct(String productId) async {
    try {
      await _databaseAPI.removeDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_PRODUCTS_ID,
        documentId: productId,
      );
    } catch (e) {
      throw Exception('Failed to remove food from Appwrite products: $e');
    }
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) async {
    try {
      final expiryDate = data['expiryDate'] as DateTime;
      data['expiryDate'] = expiryDate.toIso8601String();
      await _databaseAPI.updateDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_PRODUCTS_ID,
        documentId: productId,
        data: data,
      );
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

}
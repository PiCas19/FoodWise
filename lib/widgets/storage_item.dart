import 'package:flutter/material.dart';
import '../controllers/product_controller.dart';
import '../models/storage.dart';
import '../models/food.dart';
import 'food_item.dart';

class StorageItem extends StatefulWidget {
  final Storage storage;
  final List<Food> foodList;
  final Function() onAction;

  const StorageItem({
    super.key,
    required this.storage,
    required this.foodList,
    required this.onAction,
  });

  @override
  _StorageItemState createState() => _StorageItemState();
}

class _StorageItemState extends State<StorageItem> {
  static const int _itemsPerPage = 6;
  int _currentPage = 0;
  final ProductController _productController = ProductController();
  List<Food> currentPageItems = [];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = screenWidth / (screenWidth < 600 ? 2 : screenWidth < 900 ? 3 : 4) - 20;

    double aspectRatio = 0.7;

    if (screenWidth > 900) {
      aspectRatio = 0.5;
    }

    final int totalPages = (widget.foodList.length / _itemsPerPage).ceil();
    final int startIndex = _currentPage * _itemsPerPage;
    final int endIndex = startIndex + _itemsPerPage;
    currentPageItems = widget.foodList.sublist(startIndex, endIndex.clamp(0, widget.foodList.length));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screenWidth < 600 ? 2 : screenWidth < 900 ? 3 : 4,
            crossAxisSpacing: 5,
            mainAxisSpacing: 20,
            childAspectRatio: aspectRatio,
          ),
          itemCount: currentPageItems.length,
            itemBuilder: (context, index) {
              if (index < currentPageItems.length) {
                return FoodItem(
                  food: currentPageItems[index],
                  width: itemWidth,
                  onProductDelete: _deleteProduct,
                  onProductUpdate: _updateProduct,
                  documentId: currentPageItems[index].id,
                );
              } else {
                return Container();
              }
            }
        ),
        _buildPagination(totalPages),
      ],
    );
  }

  Widget _buildPagination(int totalPages) {
    if (currentPageItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      alignment: Alignment.bottomRight,
      margin: const EdgeInsets.all(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          totalPages,
              (index) => GestureDetector(
            onTap: () {
              setState(() {
                _currentPage = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: index == _currentPage ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                (index + 1).toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateProduct(String documentId, Map<String, dynamic> data) async {
    await _productController.updateProduct(documentId, data);
    _productController.notifyListeners();
    widget.onAction();

    if (mounted) {
      setState(() {});
    }
  }

  void _deleteProduct(String documentId) async {
    await _productController.removeProduct(documentId);
    _productController.notifyListeners();
    widget.onAction();

    if (_currentPage >= _itemsPerPage && _itemsPerPage > 0) {
      _currentPage = _itemsPerPage - 1;
    }

    if (mounted) {
      setState(() {});
    }
  }

}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../models/food.dart';

class FoodItem extends StatefulWidget {
  final Food food;
  final double width;
  final Function(String) onProductDelete;
  final Function(String, Map<String, dynamic>) onProductUpdate;
  final String documentId;

  const FoodItem({
    super.key,
    required this.food,
    required this.width,
    required this.onProductDelete,
    required this.onProductUpdate,
    required this.documentId,
  });

  @override
  _FoodItemState createState() => _FoodItemState();
}

class _FoodItemState extends State<FoodItem> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.food.expiryDate ;
  }

  void showEditPopup(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text("${"Edit".tr()} ${widget.food.name.tr()}"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: widget.width * 0.3,
                    width: widget.width,
                    child: Image.asset(
                      "assets/${widget.food.type.name == FoodType.other.name ? "images" : "${widget.food.type.name.toLowerCase()}images"}/${widget.food.imageName}",
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () async {
                      DateTime initialDate = widget.food.expiryDate.isAfter(DateTime.now()) ? widget.food.expiryDate : DateTime.now();
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: initialDate,
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
                        Text("${'Expiry date'.tr()}: "),
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
                      Text("${'Available quantity'.tr()}: "),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (widget.food.availableQuantity > 0) {
                              widget.food.availableQuantity--;
                              widget.food.availableQuantity.toString();
                            }
                          });
                        },
                      ),
                      Text(
                        widget.food.availableQuantity.toString(),
                        style: const TextStyle(fontSize: 20.0),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            widget.food.availableQuantity++;
                            widget.food.availableQuantity.toString();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Exit'.tr(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    widget.onProductUpdate(widget.documentId, {
                      'expiryDate': selectedDate,
                      'availableQuantity': widget.food.availableQuantity,
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Save'.tr(),
                      style: const TextStyle(color: Colors.white), // Colore del testo
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: widget.width * 0.3, // Set image height to 30% of width
              width: widget.width,
              child: Image.asset(
                "assets/${widget.food.type.name == FoodType.other.name ? "images" : "${widget.food.type.name.toLowerCase()}images"}/${widget.food.imageName}",
                fit: BoxFit.contain,
              ),
            ),
            Text(
              widget.food.name.tr().length > 10 ? '${widget.food.name.tr().substring(0, 10)}...' : widget.food.name.tr(),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              "${"Type".tr()}: ${_foodTypeToString(widget.food.type)}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildExpirationInfo(),
            const SizedBox(height: 8),
            Text(
              "${"Quantity".tr()}: ${widget.food.availableQuantity}",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 14,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {
                    showEditPopup(context);
                  },
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {
                    widget.onProductDelete(widget.documentId);
                  },
                  icon: const Icon(Icons.delete),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpirationInfo() {
    final now = DateTime.now();
    final difference = selectedDate.difference(now);
    final daysUntilExpiration = difference.inDays;
    final hoursUntilExpiration = difference.inHours;

    if (daysUntilExpiration > 0) {
      final expirationText = daysUntilExpiration == 1
          ? 'Expires in 1 day'.tr()
          : "${"Expires in".tr()} $daysUntilExpiration days";

      return Row(
        children: [
          Icon(
            _isExpired() ? Icons.warning : Icons.check_circle,
            color: _isExpired() ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              expirationText,
              style: TextStyle(
                color: _isExpired() ? Colors.red : Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else if (hoursUntilExpiration > 0) {
      return Row(
        children: [
          Icon(
            _isExpired() ? Icons.warning : Icons.check_circle,
            color: _isExpired() ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 2),
          Expanded(
            child: Text(
              "${"Expires in".tr()} $hoursUntilExpiration${hoursUntilExpiration != 1 ? " ${'Hours'.tr()}" : " ${'Hour'.tr()}"}",
              style: TextStyle(
                color: _isExpired() ? Colors.red : Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          const Icon(
            Icons.warning,
            color: Colors.red,
          ),
          const SizedBox(width: 2),
          Text(
            'Expired'.tr(),
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ],
      );
    }
  }

  bool _isExpired() {
    final now = DateTime.now();
    return selectedDate.isBefore(now);
  }

  String _foodTypeToString(FoodType type) {
    switch (type) {
      case FoodType.vegetable:
        return 'Vegetable'.tr();
      case FoodType.bakery:
        return 'Bakery'.tr();
      case FoodType.fruit:
        return 'Fruit'.tr();
      case FoodType.other:
        return 'Other'.tr();
      default:
        return '';
    }
  }
}

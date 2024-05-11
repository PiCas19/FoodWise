import 'package:uuid/uuid.dart';

enum FoodType { vegetable, bakery, fruit, other}
class Food {
  String id;
  String name;
  FoodType type;
  int availableQuantity;
  DateTime expiryDate;
  String imageName;

  Food({
    required this.name,
    required this.type,
    this.availableQuantity = 0,
    required this.expiryDate,
    required this.imageName,
  }): id = const Uuid().v4();

  void setDate(DateTime expiryDate){
    this.expiryDate = expiryDate;
  }

  Food.fromJson(Map<String, dynamic> json)
      : id = json['\$id'],
        name = json['productName'],
        type = _parseFoodType(json['productType']),
        availableQuantity = json['availableQuantity'],
        expiryDate =  DateTime.parse(json['expiryDate']),
        imageName = json['imageName'];

  Map<String, dynamic> toJson() {
    return {
      '\$id': id,
      'productName': name,
      'productType': _foodTypeToString(type), // Converti il tipo enum in stringa
      'availableQuantity': availableQuantity,
      'expiryDate': expiryDate.toIso8601String(),
      'imageName' : imageName
    };
  }

  static FoodType _parseFoodType(String type) {
    switch (type) {
      case 'vegetable':
        return FoodType.vegetable;
      case 'bakery':
        return FoodType.bakery;
      case 'fruit':
        return FoodType.fruit;
      case 'other':
        return FoodType.other;
      default:
        throw ArgumentError('Invalid food type: $type');
    }
  }

  static String _foodTypeToString(FoodType type) {
    switch (type) {
      case FoodType.vegetable:
        return 'vegetable';
      case FoodType.bakery:
        return 'bakery';
      case FoodType.fruit:
        return 'fruit';
      case FoodType.other:
        return 'other';
    }
  }
}

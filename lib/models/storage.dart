import 'food.dart';

class Storage {
  String? id;
  String userId;
  List<Food> products;

  Storage({
    this.id,
    required this.userId,
    required this.products,
  });

  Storage.fromJson(Map<String, dynamic> json)
      : id = json['\$id'],
        userId = json['userId'],
        products = (json['products'] as List<dynamic>)
            .map((item) => Food.fromJson(item)).toList();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (id != null) {
      data['\$id'] = id;
    }
    data['userId'] = userId;
    data['products'] = products.map((item) => item.toJson()).toList();
    return data;
  }
}

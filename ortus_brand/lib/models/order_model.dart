class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final String deliveryType;
  final bool deliveryRequested;
  final DateTime createdAt;
  final String? userFullName;
  final String? userPhoneNumber;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryType,
    required this.deliveryRequested,
    required this.createdAt,
    this.userFullName,
    this.userPhoneNumber,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['_id'],
      userId: json['userId'] is String ? json['userId'] : json['userId']['_id'],
      items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
      totalAmount: json['totalAmount'].toDouble(),
      status: json['status'],
      deliveryType: json['deliveryType'],
      deliveryRequested: json['deliveryRequested'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      userFullName: json['userId'] is Map ? json['userId']['fullName'] : null,
      userPhoneNumber: json['userId'] is Map
          ? json['userId']['phoneNumber']
          : null,
    );
  }
}

class OrderItem {
  final String productId;
  final String name;
  final double price;
  final String size;
  final int quantity;
  final String? image;

  OrderItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.size,
    required this.quantity,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      name: json['name'],
      price: json['price'].toDouble(),
      size: json['size'],
      quantity: json['quantity'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'productId': productId, 'size': size, 'quantity': quantity};
  }
}

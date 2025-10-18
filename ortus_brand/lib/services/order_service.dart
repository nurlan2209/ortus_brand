import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/order_model.dart';
import 'auth_service.dart';

class OrderService {
  Future<OrderModel?> createOrder(List<OrderItem> items) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'items': items.map((i) => i.toJson()).toList()}),
      );

      if (response.statusCode == 201) {
        return OrderModel.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Create order error: $e');
      return null;
    }
  }

  Future<List<OrderModel>> getMyOrders() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders/my-orders'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get my orders error: $e');
      return [];
    }
  }

  Future<List<OrderModel>> getAllOrders() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders/all'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get all orders error: $e');
      return [];
    }
  }

  Future<bool> requestDelivery(String orderId) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/delivery-request'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Request delivery error: $e');
      return false;
    }
  }

  Future<List<OrderModel>> getDeliveryRequests() async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders/delivery-requests'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get delivery requests error: $e');
      return [];
    }
  }
}

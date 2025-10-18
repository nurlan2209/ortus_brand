import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product_model.dart';
import 'auth_service.dart';

class ProductService {
  Future<List<ProductModel>> getAllProducts({String? category}) async {
    try {
      final uri = category != null
          ? Uri.parse('${ApiConfig.baseUrl}/products?category=$category')
          : Uri.parse('${ApiConfig.baseUrl}/products');

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get products error: $e');
      return [];
    }
  }

  Future<ProductModel?> getProductById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/products/$id'),
      );

      if (response.statusCode == 200) {
        return ProductModel.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Get product error: $e');
      return null;
    }
  }

  Future<bool> createProduct({
    required String name,
    required String description,
    required String category,
    required double price,
    required List<File> images,
    required List<SizeStock> sizes,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/products'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['category'] = category;
      request.fields['price'] = price.toString();
      request.fields['sizes'] = json.encode(
        sizes.map((s) => s.toJson()).toList(),
      );

      for (var image in images) {
        request.files.add(
          await http.MultipartFile.fromPath('images', image.path),
        );
      }

      final response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      print('Create product error: $e');
      return false;
    }
  }

  Future<bool> updateProduct({
    required String id,
    required String name,
    required String description,
    required String category,
    required double price,
    List<File>? images,
    required List<SizeStock> sizes,
  }) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('${ApiConfig.baseUrl}/products/$id'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['name'] = name;
      request.fields['description'] = description;
      request.fields['category'] = category;
      request.fields['price'] = price.toString();
      request.fields['sizes'] = json.encode(
        sizes.map((s) => s.toJson()).toList(),
      );

      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          request.files.add(
            await http.MultipartFile.fromPath('images', image.path),
          );
        }
      }

      final response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print('Update product error: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final token = await AuthService().getToken();
      if (token == null) return false;

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/products/$id'),
        headers: {'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Delete product error: $e');
      return false;
    }
  }
}

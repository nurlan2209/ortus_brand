import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/product_service.dart';
import '../services/order_service.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../utils/constants.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductModel? _product;
  bool _isLoading = true;
  String? _selectedSize;
  int _quantity = 1;
  bool _isOrdering = false;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  void _loadProduct() async {
    final product = await ProductService().getProductById(widget.productId);
    setState(() {
      _product = product;
      _isLoading = false;
      if (product != null && product.sizes.isNotEmpty) {
        final availableSize = product.sizes.firstWhere(
          (s) => s.stock > 0,
          orElse: () => product.sizes.first,
        );
        _selectedSize = availableSize.size;
      }
    });
  }

  void _placeOrder() async {
    if (_product == null || _selectedSize == null) return;

    final sizeData = _product!.sizes.firstWhere((s) => s.size == _selectedSize);
    if (sizeData.stock < _quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Недостаточно товара на складе')),
      );
      return;
    }

    setState(() => _isOrdering = true);

    final orderItem = OrderItem(
      productId: _product!.id,
      name: _product!.name,
      price: _product!.price,
      size: _selectedSize!,
      quantity: _quantity,
      image: _product!.images.isNotEmpty ? _product!.images[0] : null,
    );

    final order = await OrderService().createOrder([orderItem]);

    setState(() => _isOrdering = false);

    if (mounted) {
      if (order != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Заказ оформлен'),
            content: Text('Заказ №${order.id.substring(0, 8)} создан успешно'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка оформления заказа')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.black,
          iconTheme: const IconThemeData(color: AppColors.white),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.black,
          iconTheme: const IconThemeData(color: AppColors.white),
        ),
        body: const Center(child: Text('Товар не найден')),
      );
    }

    final selectedSizeData = _product!.sizes.firstWhere(
      (s) => s.size == _selectedSize,
      orElse: () => _product!.sizes.first,
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          _product!.name,
          style: const TextStyle(color: AppColors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_product!.images.isNotEmpty)
                    SizedBox(
                      height: 400,
                      child: PageView.builder(
                        itemCount: _product!.images.length,
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: _product!.images[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.lightGrey,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.lightGrey,
                              child: const Icon(Icons.error, size: 50),
                            ),
                          );
                        },
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _product!.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_product!.price.toStringAsFixed(0)} ₸',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _product!.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.grey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Размер',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _product!.sizes.map((size) {
                            final isSelected = _selectedSize == size.size;
                            final isAvailable = size.stock > 0;
                            return GestureDetector(
                              onTap: isAvailable
                                  ? () => setState(() {
                                      _selectedSize = size.size;
                                      if (_quantity > size.stock) {
                                        _quantity = size.stock;
                                      }
                                    })
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : isAvailable
                                      ? AppColors.white
                                      : AppColors.lightGrey,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.grey.withOpacity(0.3),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      size.size,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppColors.white
                                            : isAvailable
                                            ? AppColors.black
                                            : AppColors.grey,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isAvailable ? '${size.stock} шт' : 'Нет',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                            ? AppColors.white
                                            : isAvailable
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Text(
                              'Количество',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                              color: AppColors.primary,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.grey.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _quantity < selectedSizeData.stock
                                  ? () => setState(() => _quantity++)
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!Provider.of<AuthProvider>(context, listen: false).user!.isAdmin)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Итого:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(_product!.price * _quantity).toStringAsFixed(0)} ₸',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'Оформить заказ',
                    onPressed: selectedSizeData.stock > 0 ? _placeOrder : () {},
                    isLoading: _isOrdering,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

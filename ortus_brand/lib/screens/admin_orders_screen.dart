import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';
import '../utils/constants.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final orders = await OrderService().getAllOrders();
    setState(() {
      _orders = orders;
      _isLoading = false;
    });
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Ожидает';
      case 'confirmed':
        return 'Подтвержден';
      case 'ready':
        return 'Готов';
      case 'completed':
        return 'Завершен';
      case 'cancelled':
        return 'Отменен';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'ready':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateOrderStatus(OrderModel order, String newStatus) async {
    final success = await OrderService().updateOrderStatus(order.id, newStatus);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Статус заказа ${order.id.substring(0, 8)} обновлен'),
          backgroundColor: Colors.green,
        ),
      );
      _loadOrders(); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка обновления статуса'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: const Text(
          'Все заказы',
          style: TextStyle(color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.white),
            onPressed: _loadOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _orders.isEmpty
              ? const Center(
                  child: Text(
                    'Нет заказов',
                    style: TextStyle(fontSize: 18, color: AppColors.grey),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  color: AppColors.primary,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.all(16),
                          childrenPadding: const EdgeInsets.all(16),
                          title: Text(
                            'Заказ №${order.id.substring(0, 8)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                '${order.userFullName ?? "Пользователь"} • ${order.userPhoneNumber ?? ""}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Дата: ${_formatDate(order.createdAt)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(order.status)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: _getStatusColor(order.status),
                                      ),
                                    ),
                                    child: Text(
                                      _getStatusText(order.status),
                                      style: TextStyle(
                                        color: _getStatusColor(order.status),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (order.deliveryRequested)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Colors.purple),
                                      ),
                                      child: const Text(
                                        'Доставка',
                                        style: TextStyle(
                                          color: Colors.purple,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            const Divider(),
                            const SizedBox(height: 8),
                            ...order.items.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              'Размер: ${item.size} • Кол-во: ${item.quantity}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color:
                                                    AppColors.grey.withOpacity(0.8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${(item.price * item.quantity).toStringAsFixed(0)} ₸',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Итого:',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${order.totalAmount.toStringAsFixed(0)} ₸',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Изменить статус:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.grey.withOpacity(0.3),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: order.status,
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'pending',
                                    child: Text('Ожидает подтверждения'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'confirmed',
                                    child: Text('Подтвержден'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ready',
                                    child: Text('Готов к выдаче'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'completed',
                                    child: Text('Завершен'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'cancelled',
                                    child: Text('Отменен'),
                                  ),
                                ],
                                onChanged: (newStatus) {
                                  if (newStatus != null &&
                                      newStatus != order.status) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Изменить статус?'),
                                        content: Text(
                                          'Изменить статус заказа с "${_getStatusText(order.status)}" на "${_getStatusText(newStatus)}"?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Отмена'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              _updateOrderStatus(
                                                  order, newStatus);
                                            },
                                            child: const Text(
                                              'Изменить',
                                              style: TextStyle(
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

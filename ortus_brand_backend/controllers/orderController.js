const Order = require("../models/Order");
const Product = require("../models/Product");

const createOrder = async (req, res) => {
  try {
    const { items } = req.body;

    // Валидация входных данных
    if (!items || !Array.isArray(items) || items.length === 0) {
      return res.status(400).json({ message: "Cart is empty" });
    }

    let totalAmount = 0;
    const orderItems = [];
    const productsToUpdate = [];

    // Фаза 1: Валидация всех товаров и проверка остатков
    for (const item of items) {
      // Проверка обязательных полей
      if (!item.productId || !item.size || !item.quantity) {
        return res.status(400).json({
          message: "Invalid item data. ProductId, size, and quantity are required",
        });
      }

      // Проверка положительного количества
      if (item.quantity <= 0) {
        return res.status(400).json({
          message: "Quantity must be greater than 0",
        });
      }

      const product = await Product.findById(item.productId);

      // Проверка существования товара
      if (!product) {
        return res.status(404).json({
          message: `Товар с ID ${item.productId} не найден`,
        });
      }

      // Проверка активности товара
      if (!product.isActive) {
        return res.status(400).json({
          message: `Товар "${product.name}" больше не доступен для заказа`,
        });
      }

      // Поиск размера
      const sizeData = product.sizes.find((s) => s.size === item.size);
      if (!sizeData) {
        return res.status(400).json({
          message: `Размер ${item.size} не доступен для товара "${product.name}"`,
        });
      }

      // Проверка достаточности остатков
      if (sizeData.stock < item.quantity) {
        return res.status(400).json({
          message: `Недостаточно товара "${product.name}" (${item.size}). В наличии: ${sizeData.stock} шт, запрошено: ${item.quantity} шт`,
        });
      }

      // Сохраняем информацию для обновления
      productsToUpdate.push({
        product,
        sizeData,
        quantity: item.quantity,
      });

      const itemTotal = product.price * item.quantity;
      totalAmount += itemTotal;

      orderItems.push({
        productId: product._id,
        name: product.name,
        price: product.price,
        size: item.size,
        quantity: item.quantity,
        image: product.images[0] || "",
      });
    }

    // Фаза 2: Обновление остатков (только если вся валидация прошла успешно)
    for (const { product, sizeData, quantity } of productsToUpdate) {
      sizeData.stock -= quantity;
      await product.save();
    }

    // Фаза 3: Создание заказа
    const order = await Order.create({
      userId: req.user._id,
      items: orderItems,
      totalAmount,
    });

    await order.populate("userId", "fullName phoneNumber");

    res.status(201).json(order);
  } catch (error) {
    console.error("Create order error:", error);
    res.status(500).json({ message: "Ошибка создания заказа. Попробуйте позже" });
  }
};

const getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.user._id }).sort({
      createdAt: -1,
    });
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getAllOrders = async (req, res) => {
  try {
    if (req.user.userType !== "admin") {
      return res.status(403).json({ message: "Admin only" });
    }

    const orders = await Order.find()
      .populate("userId", "fullName phoneNumber")
      .sort({ createdAt: -1 });

    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const requestDelivery = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);

    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    if (order.userId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ message: "Not your order" });
    }

    order.deliveryType = "delivery";
    order.deliveryRequested = true;
    await order.save();

    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getDeliveryRequests = async (req, res) => {
  try {
    if (req.user.userType !== "admin") {
      return res.status(403).json({ message: "Admin only" });
    }

    const requests = await Order.find({ deliveryRequested: true })
      .populate("userId", "fullName phoneNumber")
      .sort({ createdAt: -1 });

    res.json(requests);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const { id } = req.params;

    // Проверка прав админа
    if (req.user.userType !== "admin") {
      return res.status(403).json({ message: "Admin only" });
    }

    // Валидация статуса
    const validStatuses = ["pending", "confirmed", "ready", "completed", "cancelled"];
    if (!status || !validStatuses.includes(status)) {
      return res.status(400).json({
        message: `Invalid status. Must be one of: ${validStatuses.join(", ")}`,
      });
    }

    const order = await Order.findById(id).populate("userId", "fullName phoneNumber");

    if (!order) {
      return res.status(404).json({ message: "Order not found" });
    }

    // Обновление статуса
    order.status = status;
    await order.save();

    res.json(order);
  } catch (error) {
    console.error("Update order status error:", error);
    res.status(500).json({ message: "Failed to update order status" });
  }
};

module.exports = {
  createOrder,
  getMyOrders,
  getAllOrders,
  requestDelivery,
  getDeliveryRequests,
  updateOrderStatus,
};

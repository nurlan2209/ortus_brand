const express = require("express");
const {
  createOrder,
  getMyOrders,
  getAllOrders,
  requestDelivery,
  getDeliveryRequests,
} = require("../controllers/orderController");
const { protect } = require("../middlewares/authMiddleware");
const router = express.Router();

router.post("/", protect, createOrder);
router.get("/my-orders", protect, getMyOrders);
router.get("/all", protect, getAllOrders);
router.patch("/:id/delivery-request", protect, requestDelivery);
router.get("/delivery-requests", protect, getDeliveryRequests);

module.exports = router;

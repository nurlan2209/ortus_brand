const express = require("express");
const {
  register,
  login,
  getMe,
  updateDetails,
  changePassword,
} = require("../controllers/authController");
const { protect } = require("../middlewares/authMiddleware");
const router = express.Router();

router.post("/register", register);
router.post("/login", login);
router.get("/me", protect, getMe);
router.patch("/update-details", protect, updateDetails);
router.post("/change-password", protect, changePassword);

module.exports = router;

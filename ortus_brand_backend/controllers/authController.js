const User = require("../models/User");
const jwt = require("jsonwebtoken");
const { sendResetCode } = require("../utils/emailService");

const register = async (req, res) => {
  try {
    const { fullName, phoneNumber, email, password } = req.body;

    const passwordRegex = /^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$/;

    if (!password || !passwordRegex.test(password)) {
      return res.status(400).json({
        message:
          "Пароль должен содержать минимум 8 символов, одну заглавную букву и один специальный символ",
      });
    }

    const existingPhone = await User.findOne({ phoneNumber });
    if (existingPhone) {
      return res.status(400).json({ message: "Phone number already exists" });
    }

    const existingEmail = await User.findOne({ email });
    if (existingEmail) {
      return res.status(400).json({ message: "Email already exists" });
    }

    const user = await User.create({ fullName, phoneNumber, email, password });

    const token = jwt.sign(
      { id: user._id, userType: user.userType },
      process.env.JWT_SECRET,
      { expiresIn: "30d" }
    );

    res.status(201).json({
      token,
      user: {
        id: user._id,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber,
        email: user.email,
        userType: user.userType,
      },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const login = async (req, res) => {
  try {
    const { phoneNumber, password } = req.body;

    const user = await User.findOne({ phoneNumber });
    if (!user) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const isMatch = await user.comparePassword(password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials" });
    }

    const token = jwt.sign(
      { id: user._id, userType: user.userType },
      process.env.JWT_SECRET,
      { expiresIn: "30d" }
    );

    res.json({
      token,
      user: {
        id: user._id,
        fullName: user.fullName,
        phoneNumber: user.phoneNumber,
        email: user.email,
        userType: user.userType,
      },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

const getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user._id).select("-password");
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json(user);
  } catch (error) {
    console.error("Get me error:", error);
    res.status(500).json({ message: "Failed to get user data" });
  }
};

const updateDetails = async (req, res) => {
  try {
    const { fullName, phoneNumber } = req.body;

    if (!fullName && !phoneNumber) {
      return res.status(400).json({
        message: "At least one field (fullName or phoneNumber) is required",
      });
    }

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    if (phoneNumber && phoneNumber !== user.phoneNumber) {
      const existingUser = await User.findOne({ phoneNumber });
      if (existingUser) {
        return res.status(400).json({
          message: "Этот номер телефона уже используется",
        });
      }
      user.phoneNumber = phoneNumber;
    }

    if (fullName) {
      user.fullName = fullName;
    }

    await user.save();

    res.json({
      id: user._id,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      email: user.email,
      userType: user.userType,
    });
  } catch (error) {
    console.error("Update details error:", error);
    res.status(500).json({ message: "Failed to update user details" });
  }
};

const changePassword = async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;

    if (!oldPassword || !newPassword) {
      return res.status(400).json({
        message: "Old password and new password are required",
      });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({
        message: "Новый пароль должен содержать минимум 6 символов",
      });
    }

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    const isMatch = await user.comparePassword(oldPassword);
    if (!isMatch) {
      return res.status(401).json({ message: "Неверный текущий пароль" });
    }

    user.password = newPassword;
    await user.save();

    res.json({ message: "Пароль успешно изменен" });
  } catch (error) {
    console.error("Change password error:", error);
    res.status(500).json({ message: "Failed to change password" });
  }
};

const requestPasswordReset = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ message: "Email is required" });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res
        .status(404)
        .json({ message: "Пользователь с таким email не найден" });
    }

    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();

    user.resetCode = resetCode;
    user.resetCodeExpires = new Date(Date.now() + 15 * 60 * 1000);
    await user.save();

    const emailSent = await sendResetCode(email, resetCode, user.fullName);

    if (!emailSent) {
      return res
        .status(500)
        .json({ message: "Не удалось отправить код на email" });
    }

    res.json({ message: "Код восстановления отправлен на email" });
  } catch (error) {
    console.error("Request password reset error:", error);
    res.status(500).json({ message: "Failed to request password reset" });
  }
};

const resetPassword = async (req, res) => {
  try {
    const { email, code, newPassword } = req.body;

    if (!email || !code || !newPassword) {
      return res.status(400).json({
        message: "Email, код и новый пароль обязательны",
      });
    }

    const passwordRegex = /^(?=.*[A-Z])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$/;

    if (!passwordRegex.test(newPassword)) {
      return res.status(400).json({
        message:
          "Новый пароль должен содержать минимум 8 символов, одну заглавную букву и один специальный символ",
      });
    }

    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ message: "Пользователь не найден" });
    }

    if (user.resetCode !== code) {
      return res.status(401).json({ message: "Неверный код восстановления" });
    }

    if (!user.resetCodeExpires || user.resetCodeExpires < new Date()) {
      return res.status(401).json({ message: "Код восстановления истек" });
    }

    user.password = newPassword;
    user.resetCode = undefined;
    user.resetCodeExpires = undefined;
    await user.save();

    res.json({ message: "Пароль успешно изменен" });
  } catch (error) {
    console.error("Reset password error:", error);
    res.status(500).json({ message: "Failed to reset password" });
  }
};

module.exports = {
  register,
  login,
  getMe,
  updateDetails,
  changePassword,
  requestPasswordReset,
  resetPassword,
};

console.log("!!!!!!!!!! ЗАПУЩЕН НОВЫЙ КОД v2 !!!!!!!!!!");

require("dotenv").config();

const express = require("express");
const cors = require("cors");
const connectDB = require("./config/db");

const authRoutes = require("./routes/auth");
const productRoutes = require("./routes/products");
const orderRoutes = require("./routes/orders");

const app = express();

connectDB();

// ДЕБАГ: Ставим логгер ПЕРЕД CORS, чтобы видеть КАЖДЫЙ запрос
app.use((req, res, next) => {
  console.log(
    `[INCOMING] Method: ${req.method} | Path: ${req.path} | Origin: ${req.headers.origin}`
  );
  next();
});

// CORS настройка для Flutter web
app.use(
  cors({
    // ИСПРАВЛЕНИЕ НАВСЕДА:
    // Мы используем функцию, чтобы динамически разрешать ЛЮБОЙ
    // origin, который начинается с http://localhost:
    // Это будет работать для любого порта, который выберет Flutter.
    origin: function (origin, callback) {
      // Разрешаем запросы без origin (например, Postman) ИЛИ с localhost
      if (!origin || /http:\/\/localhost:\d+/.test(origin)) {
        console.log(`[CORS ALLOWED] Origin: ${origin}`);
        callback(null, true);
      } else {
        // Блокируем все остальное
        console.error(`[CORS BLOCKED] Origin: ${origin}`);
        callback(new Error("Not allowed by CORS"));
      }
    },
    credentials: true,
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"],
  })
);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use("/api/auth", authRoutes);
app.use("/api/products", productRoutes);
app.use("/api/orders", orderRoutes);

app.get("/", (req, res) => {
  res.send("Ortus Brand API Running");
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  // Я убрал лог "Environment", чтобы мы видели разницу
});

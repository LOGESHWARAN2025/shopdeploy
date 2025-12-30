const express = require("express");
const mysql = require("mysql2/promise");
const cors = require("cors");

const app = express();
const PORT = process.env.PORT || 3000;

/**
 * CORS
 * Demo-friendly: allow all origins
 * (Later restrict to CloudFront/S3 domain only)
 */
app.use(cors({
  origin: "*",
  methods: ["GET"],
}));

app.use(express.json());

const {
  DB_HOST,
  DB_USER,
  DB_PASSWORD,
  DB_NAME,
} = process.env;

/**
 * ROOT ROUTE
 */
app.get("/", (req, res) => {
  res.send("ShopDeploy API is running 🚀");
});

/**
 * HEALTH CHECK
 * Required by ALB Target Group
 */
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok" });
});

/**
 * PRODUCTS API
 */
app.get("/products", async (req, res) => {
  let conn;

  try {
    conn = await mysql.createConnection({
      host: DB_HOST,
      user: DB_USER,
      password: DB_PASSWORD,
      database: DB_NAME,
    });

    const [rows] = await conn.query(
      "SELECT id, name, price FROM products"
    );

    res.json(rows);
  } catch (err) {
    console.error("DB ERROR:", err.message);
    res.status(500).json({ error: "DB error" });
  } finally {
    if (conn) await conn.end();
  }
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`API running on port ${PORT}`);
});

const nodemailer = require("nodemailer");

// Отправить код восстановления пароля
const sendResetCode = async (email, code, userName) => {
  try {
    // Создаем транспорт для локальной разработки
    const transporter = nodemailer.createTransport({
      host: process.env.EMAIL_HOST || "smtp.gmail.com",
      port: process.env.EMAIL_PORT || 587,
      secure: false, // true для 465, false для других портов
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });

    // HTML тело письма
    const htmlBody = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body {
          font-family: Arial, sans-serif;
          line-height: 1.6;
          color: #333;
        }
        .container {
          max-width: 600px;
          margin: 0 auto;
          padding: 20px;
        }
        .header {
          background-color: #000;
          color: #fff;
          padding: 20px;
          text-align: center;
          border-radius: 5px 5px 0 0;
        }
        .content {
          background-color: #f9f9f9;
          padding: 30px;
          border-radius: 0 0 5px 5px;
        }
        .code {
          background-color: #000;
          color: #fff;
          padding: 15px;
          font-size: 32px;
          font-weight: bold;
          text-align: center;
          letter-spacing: 5px;
          margin: 20px 0;
          border-radius: 5px;
        }
        .footer {
          margin-top: 20px;
          text-align: center;
          color: #666;
          font-size: 12px;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>ORTUS BRAND</h1>
        </div>
        <div class="content">
          <h2>Здравствуйте, ${userName}!</h2>
          <p>Вы запросили восстановление пароля для вашего аккаунта.</p>
          <p>Используйте следующий код для восстановления пароля:</p>
          <div class="code">${code}</div>
          <p>Код действителен в течение 15 минут.</p>
          <p>Если вы не запрашивали восстановление пароля, просто проигнорируйте это письмо.</p>
        </div>
        <div class="footer">
          <p>&copy; ${new Date().getFullYear()} ORTUS Brand. Все права защищены.</p>
        </div>
      </div>
    </body>
    </html>
  `;

    // Отправляем письмо
    await transporter.sendMail({
      from: `"ORTUS Brand" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: "Код восстановления пароля - ORTUS Brand",
      html: htmlBody,
    });

    console.log(`✅ Email sent to ${email}`);
    return true;
  } catch (error) {
    console.error("Email sending error:", error);
    return false;
  }
};

module.exports = { sendResetCode };

const nodemailer = require("nodemailer");

// Создаем транспорт для отправки email
const createTransporter = () => {
  return nodemailer.createTransport({
    service: "gmail", // Можно изменить на другой сервис
    auth: {
      user: process.env.EMAIL_USER, // Email отправителя
      pass: process.env.EMAIL_PASSWORD, // Пароль приложения
    },
  });
};

// Отправить код восстановления пароля
const sendResetCode = async (email, code, userName) => {
  try {
    const transporter = createTransporter();

    const mailOptions = {
      from: `"ORTUS Brand" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: "Код восстановления пароля - ORTUS Brand",
      html: `
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
      `,
    };

    await transporter.sendMail(mailOptions);
    return true;
  } catch (error) {
    console.error("Email sending error:", error);
    return false;
  }
};

module.exports = { sendResetCode };

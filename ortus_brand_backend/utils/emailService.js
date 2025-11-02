const sgMail = require("@sendgrid/mail");

// Отправить код восстановления пароля
const sendResetCode = async (email, code, userName) => {
  try {
    // Устанавливаем API ключ из переменных окружения
    // Убедитесь, что 'SENDGRID_API_KEY' добавлена в Railway
    sgMail.setApiKey(process.env.SENDGRID_API_KEY);

    // HTML тело письма (скопировано из вашего старого файла)
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

    const msg = {
      to: email,
      // ВАЖНО: Этот email (EMAIL_USER) должен быть верифицирован в SendGrid
      from: `"ORTUS Brand" <${process.env.EMAIL_USER}>`,
      subject: "Код восстановления пароля - ORTUS Brand",
      html: htmlBody,
    };

    // Отправляем письмо через API
    await sgMail.send(msg);

    return true;
  } catch (error) {
    // Выводим ошибку в логи Railway
    console.error("Email sending error (SendGrid):", error);
    if (error.response) {
      // Показываем детальную ошибку от API SendGrid
      console.error(error.response.body);
    }
    return false;
  }
};

module.exports = { sendResetCode };

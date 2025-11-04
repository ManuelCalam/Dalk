import * as Smtp from "https://deno.land/x/smtp@v0.7.0/mod.ts";

export async function sendEmailConfirmation(toEmail: string, customerName: string) {
  const GMAIL_USER = Deno.env.get("GMAIL_USER");
  const GMAIL_PASS = Deno.env.get("GMAIL_APP_PASSWORD");

  if (!GMAIL_USER || !GMAIL_PASS) {
    console.error("Faltan credenciales SMTP. No se pudo enviar el correo de confirmación.");
    return;
  }

  const client = new Smtp.SMTPClient({
    connection: {
      hostname: "smtp.gmail.com",
      port: 465,
      tls: true,
      auth: {
        username: GMAIL_USER,
        password: GMAIL_PASS,
      },
    },
  });

  const emailHtml = `
  <html>
  <head>
    <style>
    body {
      font-family: 'Poppins', 'Helvetica Neue', Helvetica, Arial, sans-serif;
      background-color: #f3f5fa;
      margin: 0;
      padding: 0;
    }
    .container {
      max-width: 600px;
      margin: 40px auto;
      background: #fff;
      border-radius: 16px;
      box-shadow: 0 6px 25px rgba(0,0,0,0.06);
      overflow: hidden;
    }
    .header {
      background: linear-gradient(135deg, #0080C4, #163143); 
      color: #fff;
      text-align: center;
      padding: 40px 20px;
    }
    .header h1 {
      margin: 0;
      font-size: 26px;
      font-weight: 600;
    }
    .content {
      padding: 35px 40px;
      color: #163143; 
      line-height: 1.8;
    }
    .content h2 {
      color: #0080C4; 
      font-size: 20px;
      margin-bottom: 10px;
    }
    .highlight {
      background: #E0ECFF; 
      border-left: 5px solid #0080C4; 
      padding: 15px 20px;
      border-radius: 10px;
      margin: 20px 0;
    }
    .footer {
      text-align: center;
      font-size: 12px;
      color: #999;
      padding: 20px;
      background: #fafafa;
      border-top: 1px solid #CCDBFF; 
    }
    .button {
      display: inline-block;
      background-color: #CB5014; 
      color: #ffffff;
      padding: 10px 20px;
      text-decoration: none;
      border-radius: 8px;
      font-weight: 600;
      margin-top: 15px;
      border: 1px solid #CCDBFF;
    }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="header">
        <h1>¡Tu suscripción Premium está activa!</h1>
      </div>
      <div class="content">
        <h2>Hola ${customerName},</h2>
        <p>Nos alegra darte la bienvenida a <strong>Dalk Premium</strong>.</p>
        <div class="highlight">
          <p>Tu suscripción ha sido activada con éxito.</p>
          <p>Ahora tienes acceso completo a contenido exclusivo y beneficios especiales.</p>
        </div>
        <p>Gracias por confiar en nosotros. <br> ¡Disfruta tu experiencia Premium!</p>
        <p style="text-align: center;">
          <a href="https://dalk-legal-git-main-noe-ibarras-projects.vercel.app/?_vercel_share=H06ZuiEgfwHGNcHZ9AdimDz34FNJepDa" class="button">Ir a la aplicación</a>
        </p>
      </div>
      <div class="footer">
        © ${new Date().getFullYear()} Dalk. Todos los derechos reservados.
      </div>
    </div>
  </body>
  </html>
  `;

  try {
    await client.send({
      from: GMAIL_USER,
      to: toEmail,
      subject: "Tu suscripción Premium ha sido activada",
      contentType: "text/html; charset=utf-8",
      html: emailHtml,
    });
    console.log(`Correo de confirmación enviado a ${toEmail}`);
  } catch (e) {
    console.error(`Fallo al enviar el correo a ${toEmail}:`, e);
  } finally {
    await client.close();
  }
}
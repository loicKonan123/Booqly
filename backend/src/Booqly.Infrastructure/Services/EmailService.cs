using Booqly.Application.Common.Interfaces;
using MailKit.Net.Smtp;
using MailKit.Security;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MimeKit;

namespace Booqly.Infrastructure.Services;

public class EmailService(IConfiguration config, ILogger<EmailService> logger) : IEmailService
{
    public async Task SendPasswordResetAsync(string to, string resetToken, CancellationToken ct = default)
    {
        var host = config["Smtp:Host"] ?? "";
        var username = config["Smtp:Username"] ?? "";

        if (string.IsNullOrWhiteSpace(host) || string.IsNullOrWhiteSpace(username))
        {
            logger.LogWarning("📧 [DEV] SMTP non configuré — token pour {Email} : {Token}", to, resetToken);
            return;
        }

        var port = int.Parse(config["Smtp:Port"] ?? "587");
        var password = config["Smtp:Password"] ?? "";
        var from = config["Smtp:From"] ?? username;
        var fromName = config["Smtp:FromName"] ?? "Booqly";

        var message = new MimeMessage();
        message.From.Add(new MailboxAddress(fromName, from));
        message.To.Add(MailboxAddress.Parse(to));
        message.Subject = "Réinitialisation de votre mot de passe Booqly";

        message.Body = new TextPart("html")
        {
            Text = $"""
                <!DOCTYPE html>
                <html>
                <body style="margin:0;padding:0;background:#f4f4f4;font-family:Arial,sans-serif;">
                  <table width="100%" cellpadding="0" cellspacing="0">
                    <tr>
                      <td align="center" style="padding:40px 0;">
                        <table width="520" cellpadding="0" cellspacing="0"
                               style="background:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.08);">
                          <!-- Header violet -->
                          <tr>
                            <td style="background:linear-gradient(135deg,#7C3AED,#9D5CF6);padding:36px 40px;text-align:center;">
                              <h1 style="margin:0;color:#ffffff;font-size:28px;letter-spacing:-0.5px;">Booqly</h1>
                              <p style="margin:8px 0 0;color:rgba(255,255,255,0.75);font-size:14px;">
                                Vos rendez-vous, simplifiés
                              </p>
                            </td>
                          </tr>
                          <!-- Corps -->
                          <tr>
                            <td style="padding:40px;">
                              <h2 style="margin:0 0 16px;color:#1a1a1a;font-size:20px;">
                                Réinitialisation de mot de passe
                              </h2>
                              <p style="margin:0 0 12px;color:#555;font-size:15px;line-height:1.6;">
                                Vous avez demandé à réinitialiser votre mot de passe pour le compte associé à
                                <strong>{to}</strong>.
                              </p>
                              <p style="margin:0 0 28px;color:#555;font-size:15px;line-height:1.6;">
                                Utilisez le code ci-dessous dans l'application pour créer un nouveau mot de passe :
                              </p>
                              <!-- Token -->
                              <div style="background:#f0ebff;border:1px solid #c4b5fd;border-radius:10px;
                                          padding:20px;text-align:center;margin-bottom:28px;">
                                <p style="margin:0 0 8px;font-size:12px;color:#7C3AED;font-weight:600;
                                           text-transform:uppercase;letter-spacing:1px;">Code de réinitialisation</p>
                                <code style="font-size:11px;color:#4c1d95;word-break:break-all;line-height:1.5;">
                                  {resetToken}
                                </code>
                              </div>
                              <p style="margin:0 0 8px;color:#888;font-size:13px;">
                                Ce lien est valable pendant <strong>24 heures</strong>.
                              </p>
                              <p style="margin:0;color:#888;font-size:13px;">
                                Si vous n'avez pas fait cette demande, ignorez cet email.
                              </p>
                            </td>
                          </tr>
                          <!-- Footer -->
                          <tr>
                            <td style="background:#fafafa;border-top:1px solid #eee;padding:20px 40px;
                                        text-align:center;">
                              <p style="margin:0;color:#aaa;font-size:12px;">
                                © {DateTime.UtcNow.Year} Booqly — Ne pas répondre à cet email.
                              </p>
                            </td>
                          </tr>
                        </table>
                      </td>
                    </tr>
                  </table>
                </body>
                </html>
                """
        };

        using var smtp = new SmtpClient();
        await smtp.ConnectAsync(host, port, SecureSocketOptions.StartTls, ct);
        await smtp.AuthenticateAsync(username, password, ct);
        await smtp.SendAsync(message, ct);
        await smtp.DisconnectAsync(true, ct);

        logger.LogInformation("📧 Email de réinitialisation envoyé à {Email}", to);
    }
}

namespace Booqly.Application.Common.Interfaces;

public interface IEmailService
{
    Task SendPasswordResetAsync(string to, string resetToken, CancellationToken ct = default);
}

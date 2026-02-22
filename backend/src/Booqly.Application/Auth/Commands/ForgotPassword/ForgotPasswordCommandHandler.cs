using Booqly.Application.Common.Interfaces;
using MediatR;
using Microsoft.AspNetCore.Identity;

namespace Booqly.Application.Auth.Commands.ForgotPassword;

public class ForgotPasswordCommandHandler(
    UserManager<IdentityUser> userManager,
    IEmailService emailService)
    : IRequestHandler<ForgotPasswordCommand>
{
    public async Task Handle(ForgotPasswordCommand req, CancellationToken ct)
    {
        var identityUser = await userManager.FindByEmailAsync(req.Email);

        // Security: always return success even if email not found
        if (identityUser is null) return;

        var token = await userManager.GeneratePasswordResetTokenAsync(identityUser);
        await emailService.SendPasswordResetAsync(req.Email, token, ct);
    }
}

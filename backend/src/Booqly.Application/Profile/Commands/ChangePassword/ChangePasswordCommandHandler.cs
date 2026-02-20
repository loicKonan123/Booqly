using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using System.Security.Claims;

namespace Booqly.Application.Profile.Commands.ChangePassword;

public class ChangePasswordCommandHandler(
    UserManager<IdentityUser> userManager,
    IHttpContextAccessor httpContext)
    : IRequestHandler<ChangePasswordCommand>
{
    public async Task Handle(ChangePasswordCommand req, CancellationToken ct)
    {
        var identityId = httpContext.HttpContext!.User.FindFirstValue("identityId")
            ?? throw new UnauthorizedAccessException("Non authentifié.");

        var identityUser = await userManager.FindByIdAsync(identityId)
            ?? throw new InvalidOperationException("Utilisateur introuvable.");

        var result = await userManager.ChangePasswordAsync(
            identityUser, req.CurrentPassword, req.NewPassword);

        if (!result.Succeeded)
            throw new InvalidOperationException(
                string.Join(", ", result.Errors.Select(e => e.Description)));
    }
}

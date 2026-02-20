using Booqly.Application.Common.DTOs;
using Booqly.Application.Common.Interfaces;
using Booqly.Domain.Entities;
using Booqly.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Booqly.Application.Auth.Commands.Login;

public class LoginCommandHandler(
    UserManager<IdentityUser> userManager,
    IAppDbContext db,
    IJwtService jwt)
    : IRequestHandler<LoginCommand, AuthResponse>
{
    public async Task<AuthResponse> Handle(LoginCommand req, CancellationToken ct)
    {
        var identityUser = await userManager.FindByEmailAsync(req.Email)
            ?? throw new UnauthorizedAccessException("Identifiants invalides.");

        if (!await userManager.CheckPasswordAsync(identityUser, req.Password))
            throw new UnauthorizedAccessException("Identifiants invalides.");

        var user = await db.Users
            .FirstOrDefaultAsync(u => u.IdentityUserId == identityUser.Id, ct)
            ?? throw new UnauthorizedAccessException("Utilisateur introuvable.");

        string? professionalId = null;
        if (user.IsProfessional)
        {
            var pro = await db.Professionals
                .FirstOrDefaultAsync(p => p.UserId == user.Id, ct);
            professionalId = pro?.Id.ToString();
        }

        var accessToken = jwt.GenerateAccessToken(user, identityUser.Id);
        var refreshToken = jwt.GenerateRefreshToken();
        await userManager.SetAuthenticationTokenAsync(identityUser, "Booqly", "RefreshToken", refreshToken);

        return new AuthResponse(accessToken, refreshToken, ToDto(user, professionalId));
    }

    private static UserDto ToDto(User u, string? professionalId) =>
        new(u.Id.ToString(), u.Email, u.FirstName, u.LastName, u.Phone,
            u.Role == UserRole.Professional ? "professional" : "client",
            professionalId);
}

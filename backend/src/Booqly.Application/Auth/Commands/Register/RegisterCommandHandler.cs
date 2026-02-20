using Booqly.Application.Common.DTOs;
using Booqly.Application.Common.Interfaces;
using Booqly.Domain.Entities;
using Booqly.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Identity;

namespace Booqly.Application.Auth.Commands.Register;

public class RegisterCommandHandler(
    UserManager<IdentityUser> userManager,
    IAppDbContext db,
    IJwtService jwt)
    : IRequestHandler<RegisterCommand, AuthResponse>
{
    public async Task<AuthResponse> Handle(RegisterCommand req, CancellationToken ct)
    {
        var identityUser = new IdentityUser { UserName = req.Email, Email = req.Email };
        var result = await userManager.CreateAsync(identityUser, req.Password);
        if (!result.Succeeded)
            throw new InvalidOperationException(string.Join(", ", result.Errors.Select(e => e.Description)));

        var role = req.Role.Equals("professional", StringComparison.OrdinalIgnoreCase)
            ? UserRole.Professional
            : UserRole.Client;

        var user = User.Create(identityUser.Id, req.Email, req.FirstName, req.LastName, req.Phone, role);
        await db.Users.AddAsync(user, ct);

        Professional? pro = null;
        if (role == UserRole.Professional)
        {
            pro = Professional.Create(user.Id, "Général");
            await db.Professionals.AddAsync(pro, ct);
        }

        await db.SaveChangesAsync(ct);

        var accessToken = jwt.GenerateAccessToken(user, identityUser.Id);
        var refreshToken = jwt.GenerateRefreshToken();

        await userManager.SetAuthenticationTokenAsync(identityUser, "Booqly", "RefreshToken", refreshToken);

        return new AuthResponse(accessToken, refreshToken, ToDto(user, pro?.Id.ToString()));
    }

    private static UserDto ToDto(User u, string? professionalId) =>
        new(u.Id.ToString(), u.Email, u.FirstName, u.LastName, u.Phone,
            u.Role == UserRole.Professional ? "professional" : "client",
            professionalId);
}

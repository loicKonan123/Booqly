using Booqly.Application.Common.DTOs;
using Booqly.Application.Common.Interfaces;
using Booqly.Domain.Enums;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace Booqly.Application.Profile.Commands.UpdateProfile;

public class UpdateProfileCommandHandler(
    IAppDbContext db,
    IHttpContextAccessor httpContext)
    : IRequestHandler<UpdateProfileCommand, UserDto>
{
    public async Task<UserDto> Handle(UpdateProfileCommand req, CancellationToken ct)
    {
        var userId = httpContext.HttpContext!.User.FindFirstValue(ClaimTypes.NameIdentifier)
                  ?? httpContext.HttpContext!.User.FindFirstValue("sub")
                  ?? throw new UnauthorizedAccessException("Non authentifié.");

        var user = await db.Users
            .FirstOrDefaultAsync(u => u.Id.ToString() == userId, ct)
            ?? throw new InvalidOperationException("Utilisateur introuvable.");

        user.UpdateProfile(req.FirstName, req.LastName, req.Phone);
        await db.SaveChangesAsync(ct);

        string? professionalId = null;
        if (user.IsProfessional)
        {
            var pro = await db.Professionals
                .FirstOrDefaultAsync(p => p.UserId == user.Id, ct);
            professionalId = pro?.Id.ToString();
        }

        return new UserDto(
            user.Id.ToString(),
            user.Email,
            user.FirstName,
            user.LastName,
            user.Phone,
            user.IsProfessional ? "professional" : "client",
            professionalId);
    }
}

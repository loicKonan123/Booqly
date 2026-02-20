using Booqly.Application.Common.DTOs;
using Booqly.Application.Common.Interfaces;
using Booqly.Application.Professionals.Queries.GetProfessionals;
using MediatR;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace Booqly.Application.Professionals.Commands.UpdateProfessional;

public class UpdateProfessionalCommandHandler(
    IAppDbContext db,
    IHttpContextAccessor httpContext)
    : IRequestHandler<UpdateProfessionalCommand, ProfessionalDto>
{
    public async Task<ProfessionalDto> Handle(UpdateProfessionalCommand req, CancellationToken ct)
    {
        var userId = httpContext.HttpContext!.User.FindFirstValue(ClaimTypes.NameIdentifier)
                  ?? httpContext.HttpContext!.User.FindFirstValue("sub")
                  ?? throw new UnauthorizedAccessException("Non authentifié.");

        var pro = await db.Professionals
            .Include(p => p.User)
            .FirstOrDefaultAsync(p => p.Id == req.ProId, ct)
            ?? throw new KeyNotFoundException("Professionnel introuvable.");

        // Ensure the professional belongs to the authenticated user
        if (pro.User.Id.ToString() != userId)
            throw new UnauthorizedAccessException("Accès refusé.");

        pro.UpdateProfile(req.Category, req.Bio);
        await db.SaveChangesAsync(ct);

        return GetProfessionalsQueryHandler.ToDto(pro);
    }
}

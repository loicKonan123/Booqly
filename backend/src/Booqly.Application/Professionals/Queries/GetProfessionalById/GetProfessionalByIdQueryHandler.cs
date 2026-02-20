using Booqly.Application.Common.DTOs;
using Booqly.Application.Common.Interfaces;
using Booqly.Application.Professionals.Queries.GetProfessionals;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Booqly.Application.Professionals.Queries.GetProfessionalById;

public class GetProfessionalByIdQueryHandler(IAppDbContext db)
    : IRequestHandler<GetProfessionalByIdQuery, ProfessionalDto>
{
    public async Task<ProfessionalDto> Handle(GetProfessionalByIdQuery req, CancellationToken ct)
    {
        var pro = await db.Professionals
            .Include(p => p.User)
            .FirstOrDefaultAsync(p => p.Id == req.Id, ct)
            ?? throw new KeyNotFoundException("Professionnel introuvable.");

        return GetProfessionalsQueryHandler.ToDto(pro);
    }
}

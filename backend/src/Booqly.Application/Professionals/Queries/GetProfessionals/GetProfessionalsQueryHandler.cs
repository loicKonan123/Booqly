using Booqly.Application.Common.DTOs;
using Booqly.Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Booqly.Application.Professionals.Queries.GetProfessionals;

public class GetProfessionalsQueryHandler(IAppDbContext db)
    : IRequestHandler<GetProfessionalsQuery, IReadOnlyList<ProfessionalDto>>
{
    public async Task<IReadOnlyList<ProfessionalDto>> Handle(GetProfessionalsQuery req, CancellationToken ct)
    {
        var query = db.Professionals.Include(p => p.User).AsQueryable();

        if (!string.IsNullOrWhiteSpace(req.Category))
            query = query.Where(p => p.Category == req.Category);

        var list = await query.ToListAsync(ct);
        return list.Select(ToDto).ToList();
    }

    internal static ProfessionalDto ToDto(Domain.Entities.Professional p) => new(
        p.Id.ToString(), p.User.FirstName, p.User.LastName,
        p.User.Email, p.User.Phone, p.Bio, p.Category, p.Rating, p.ReviewCount);
}

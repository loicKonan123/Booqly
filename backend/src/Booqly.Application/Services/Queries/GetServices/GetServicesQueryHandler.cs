using Booqly.Application.Common.DTOs;
using Booqly.Application.Common.Interfaces;
using Booqly.Application.Services.Commands.CreateService;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Booqly.Application.Services.Queries.GetServices;

public class GetServicesQueryHandler(IAppDbContext db)
    : IRequestHandler<GetServicesQuery, IReadOnlyList<ServiceDto>>
{
    public async Task<IReadOnlyList<ServiceDto>> Handle(GetServicesQuery req, CancellationToken ct)
    {
        var list = await db.Services
            .Where(s => s.ProfessionalId == req.ProfessionalId && s.IsActive)
            .ToListAsync(ct);

        return list.Select(CreateServiceCommandHandler.ToDto).ToList();
    }
}

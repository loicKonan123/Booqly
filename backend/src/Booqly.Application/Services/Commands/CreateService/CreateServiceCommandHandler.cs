using Booqly.Application.Common.DTOs;
using Booqly.Application.Common.Interfaces;
using Booqly.Domain.Entities;
using MediatR;

namespace Booqly.Application.Services.Commands.CreateService;

public class CreateServiceCommandHandler(IAppDbContext db)
    : IRequestHandler<CreateServiceCommand, ServiceDto>
{
    public async Task<ServiceDto> Handle(CreateServiceCommand req, CancellationToken ct)
    {
        var service = Service.Create(req.ProfessionalId, req.Name, req.Price, req.DurationMinutes, req.Description);
        await db.Services.AddAsync(service, ct);
        await db.SaveChangesAsync(ct);
        return ToDto(service);
    }

    internal static ServiceDto ToDto(Service s) => new(
        s.Id.ToString(), s.ProfessionalId.ToString(),
        s.Name, s.Description, (double)s.Price, s.DurationMinutes);
}

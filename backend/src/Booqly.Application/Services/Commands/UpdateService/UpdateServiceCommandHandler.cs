using Booqly.Application.Common.DTOs;
using Booqly.Application.Common.Interfaces;
using Booqly.Application.Services.Commands.CreateService;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Booqly.Application.Services.Commands.UpdateService;

public class UpdateServiceCommandHandler(IAppDbContext db)
    : IRequestHandler<UpdateServiceCommand, ServiceDto>
{
    public async Task<ServiceDto> Handle(UpdateServiceCommand req, CancellationToken ct)
    {
        var service = await db.Services
            .FirstOrDefaultAsync(s => s.Id == req.ServiceId && s.ProfessionalId == req.ProfessionalId, ct)
            ?? throw new KeyNotFoundException("Service introuvable.");

        service.Update(req.Name, req.Price, req.DurationMinutes, req.Description);
        await db.SaveChangesAsync(ct);
        return CreateServiceCommandHandler.ToDto(service);
    }
}

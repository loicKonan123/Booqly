using Booqly.Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Booqly.Application.Services.Commands.DeleteService;

public class DeleteServiceCommandHandler(IAppDbContext db)
    : IRequestHandler<DeleteServiceCommand>
{
    public async Task Handle(DeleteServiceCommand req, CancellationToken ct)
    {
        var service = await db.Services
            .FirstOrDefaultAsync(s => s.Id == req.ServiceId && s.ProfessionalId == req.ProfessionalId, ct)
            ?? throw new KeyNotFoundException("Service introuvable.");

        service.Deactivate();
        await db.SaveChangesAsync(ct);
    }
}

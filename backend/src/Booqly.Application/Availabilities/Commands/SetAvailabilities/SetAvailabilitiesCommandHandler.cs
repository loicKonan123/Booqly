using Booqly.Application.Common.Interfaces;
using Booqly.Domain.Entities;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Booqly.Application.Availabilities.Commands.SetAvailabilities;

public class SetAvailabilitiesCommandHandler(IAppDbContext db)
    : IRequestHandler<SetAvailabilitiesCommand>
{
    public async Task Handle(SetAvailabilitiesCommand req, CancellationToken ct)
    {
        // Delete existing and replace (bulk update pattern)
        var existing = await db.Availabilities
            .Where(a => a.ProfessionalId == req.ProfessionalId)
            .ToListAsync(ct);

        db.Availabilities.RemoveRange(existing);

        foreach (var input in req.Availabilities)
        {
            var avail = Availability.Create(
                req.ProfessionalId,
                input.DayOfWeek,
                TimeSpan.Parse(input.StartTime),
                TimeSpan.Parse(input.EndTime));

            await db.Availabilities.AddAsync(avail, ct);
        }

        await db.SaveChangesAsync(ct);
    }
}

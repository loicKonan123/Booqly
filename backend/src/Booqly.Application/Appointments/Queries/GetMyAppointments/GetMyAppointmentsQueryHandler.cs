using Booqly.Application.Appointments.Commands.CreateAppointment;
using Booqly.Application.Common.DTOs;
using Booqly.Application.Common.Interfaces;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Booqly.Application.Appointments.Queries.GetMyAppointments;

public class GetMyAppointmentsQueryHandler(IAppDbContext db)
    : IRequestHandler<GetMyAppointmentsQuery, IReadOnlyList<AppointmentDto>>
{
    public async Task<IReadOnlyList<AppointmentDto>> Handle(GetMyAppointmentsQuery req, CancellationToken ct)
    {
        var query = db.Appointments
            .Include(a => a.Client)
            .Include(a => a.Professional).ThenInclude(p => p.User)
            .Include(a => a.Service)
            .AsQueryable();

        query = req.Role == "professional"
            ? query.Where(a => a.Professional.UserId == req.UserId)
            : query.Where(a => a.ClientId == req.UserId);

        var list = await query.OrderByDescending(a => a.StartTime).ToListAsync(ct);

        return list.Select(a => CreateAppointmentCommandHandler.ToDto(a, a.Client, a.Service)).ToList();
    }
}

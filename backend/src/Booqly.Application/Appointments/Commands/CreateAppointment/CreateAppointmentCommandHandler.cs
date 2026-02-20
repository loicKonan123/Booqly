using Booqly.Application.Common.DTOs;
using Booqly.Application.Common.Interfaces;
using Booqly.Domain.Entities;
using Booqly.Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Booqly.Application.Appointments.Commands.CreateAppointment;

public class CreateAppointmentCommandHandler(IAppDbContext db, ISmsService sms)
    : IRequestHandler<CreateAppointmentCommand, AppointmentDto>
{
    public async Task<AppointmentDto> Handle(CreateAppointmentCommand req, CancellationToken ct)
    {
        var startTime = DateTime.Parse(req.SlotId, null, System.Globalization.DateTimeStyles.RoundtripKind);

        var service = await db.Services
            .FirstOrDefaultAsync(s => s.Id == req.ServiceId && s.ProfessionalId == req.ProfessionalId, ct)
            ?? throw new KeyNotFoundException("Service introuvable.");

        var endTime = startTime.AddMinutes(service.DurationMinutes);

        // Conflict check
        var conflict = await db.Appointments.AnyAsync(a =>
            a.ProfessionalId == req.ProfessionalId &&
            a.Status != AppointmentStatus.Cancelled &&
            a.StartTime < endTime &&
            a.EndTime > startTime, ct);

        if (conflict) throw new InvalidOperationException("Ce créneau n'est plus disponible.");

        var client = await db.Users.FindAsync([req.ClientId], ct)
            ?? throw new KeyNotFoundException("Client introuvable.");

        var appointment = Appointment.Create(req.ClientId, req.ProfessionalId, req.ServiceId, startTime, endTime, req.Notes);
        await db.Appointments.AddAsync(appointment, ct);
        await db.SaveChangesAsync(ct);

        // Reload with navigation props
        await db.Appointments.Entry(appointment)
            .Reference(a => a.Professional).LoadAsync(ct);
        await db.Appointments.Entry(appointment)
            .Reference(a => a.Professional).Query()
            .Include(p => p.User).LoadAsync(ct);
        await db.Appointments.Entry(appointment)
            .Reference(a => a.Service).LoadAsync(ct);

        // SMS confirmation
        if (!string.IsNullOrWhiteSpace(client.Phone))
        {
            var msg = $"Votre RDV est confirmé le {startTime:dd/MM/yyyy} à {startTime:HH:mm} pour {service.Name}.";
            await sms.SendAsync(client.Phone, msg, ct);
        }

        return ToDto(appointment, client, service);
    }

    internal static AppointmentDto ToDto(
        Appointment a, Domain.Entities.User client, Service svc) => new(
        a.Id.ToString(),
        a.ClientId.ToString(),
        client.FullName,
        client.Phone ?? "",
        new ProfessionalDto(
            a.Professional.Id.ToString(),
            a.Professional.User.FirstName, a.Professional.User.LastName,
            a.Professional.User.Email, a.Professional.User.Phone,
            a.Professional.Bio, a.Professional.Category,
            a.Professional.Rating, a.Professional.ReviewCount),
        new ServiceDto(svc.Id.ToString(), svc.ProfessionalId.ToString(),
            svc.Name, svc.Description, (double)svc.Price, svc.DurationMinutes),
        a.StartTime, a.EndTime,
        a.Status.ToString().ToLower(),
        a.Notes);
}

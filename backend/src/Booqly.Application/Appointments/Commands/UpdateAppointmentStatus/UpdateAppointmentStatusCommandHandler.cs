using Booqly.Application.Appointments.Commands.CreateAppointment;
using Booqly.Application.Common.DTOs;
using Booqly.Application.Common.Interfaces;
using Booqly.Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Booqly.Application.Appointments.Commands.UpdateAppointmentStatus;

public class UpdateAppointmentStatusCommandHandler(IAppDbContext db, ISmsService sms)
    : IRequestHandler<UpdateAppointmentStatusCommand, AppointmentDto>
{
    public async Task<AppointmentDto> Handle(UpdateAppointmentStatusCommand req, CancellationToken ct)
    {
        var appointment = await db.Appointments
            .Include(a => a.Client)
            .Include(a => a.Professional).ThenInclude(p => p.User)
            .Include(a => a.Service)
            .FirstOrDefaultAsync(a => a.Id == req.AppointmentId, ct)
            ?? throw new KeyNotFoundException("Rendez-vous introuvable.");

        // Authorization: client can only cancel their own, pro can confirm/complete/cancel theirs
        if (req.Role == "client" && appointment.ClientId != req.UserId)
            throw new UnauthorizedAccessException();

        if (req.Role == "professional" && appointment.Professional.UserId != req.UserId)
            throw new UnauthorizedAccessException();

        if (!Enum.TryParse<AppointmentStatus>(req.Status, true, out var newStatus))
            throw new ArgumentException($"Statut invalide: {req.Status}");

        if (newStatus == AppointmentStatus.Cancelled && !appointment.CanCancel())
            throw new InvalidOperationException("Ce rendez-vous ne peut plus être annulé.");

        appointment.UpdateStatus(newStatus);
        await db.SaveChangesAsync(ct);

        // SMS on cancellation
        if (newStatus == AppointmentStatus.Cancelled && !string.IsNullOrWhiteSpace(appointment.Client.Phone))
        {
            var msg = $"Votre RDV du {appointment.StartTime:dd/MM/yyyy} à {appointment.StartTime:HH:mm} pour {appointment.Service.Name} a été annulé.";
            await sms.SendAsync(appointment.Client.Phone, msg, ct);
        }

        return CreateAppointmentCommandHandler.ToDto(appointment, appointment.Client, appointment.Service);
    }
}

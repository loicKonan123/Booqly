using Booqly.Application.Common.DTOs;
using MediatR;

namespace Booqly.Application.Appointments.Commands.CreateAppointment;

public record CreateAppointmentCommand(
    Guid ClientId,
    Guid ProfessionalId,
    Guid ServiceId,
    string SlotId,   // ISO 8601 datetime string = StartTime
    string? Notes
) : IRequest<AppointmentDto>;

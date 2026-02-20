using Booqly.Application.Common.DTOs;
using MediatR;

namespace Booqly.Application.Appointments.Commands.UpdateAppointmentStatus;

public record UpdateAppointmentStatusCommand(Guid AppointmentId, Guid UserId, string Role, string Status)
    : IRequest<AppointmentDto>;

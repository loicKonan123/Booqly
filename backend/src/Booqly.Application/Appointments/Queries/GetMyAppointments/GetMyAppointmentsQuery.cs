using Booqly.Application.Common.DTOs;
using MediatR;

namespace Booqly.Application.Appointments.Queries.GetMyAppointments;

public record GetMyAppointmentsQuery(Guid UserId, string Role) : IRequest<IReadOnlyList<AppointmentDto>>;

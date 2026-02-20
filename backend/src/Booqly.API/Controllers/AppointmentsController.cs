using Booqly.Application.Appointments.Commands.CreateAppointment;
using Booqly.Application.Appointments.Commands.UpdateAppointmentStatus;
using Booqly.Application.Appointments.Queries.GetMyAppointments;
using Booqly.API.Extensions;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Booqly.API.Controllers;

[ApiController]
[Route("api/appointments")]
[Authorize]
public class AppointmentsController(IMediator mediator) : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateBody body, CancellationToken ct)
    {
        var userId = User.GetUserId();
        var result = await mediator.Send(
            new CreateAppointmentCommand(userId, body.ProfessionalId, body.ServiceId, body.SlotId, body.Notes), ct);
        return Ok(result);
    }

    [HttpGet("mine")]
    public async Task<IActionResult> GetMine(CancellationToken ct)
    {
        var userId = User.GetUserId();
        var role = User.GetRole();
        return Ok(await mediator.Send(new GetMyAppointmentsQuery(userId, role), ct));
    }

    [HttpPatch("{id:guid}/status")]
    public async Task<IActionResult> UpdateStatus(Guid id, [FromBody] StatusBody body, CancellationToken ct)
    {
        var userId = User.GetUserId();
        var role = User.GetRole();
        return Ok(await mediator.Send(new UpdateAppointmentStatusCommand(id, userId, role, body.Status), ct));
    }

    public record CreateBody(Guid ProfessionalId, Guid ServiceId, string SlotId, string? Notes);
    public record StatusBody(string Status);
}

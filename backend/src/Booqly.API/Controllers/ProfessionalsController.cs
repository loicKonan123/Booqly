using Booqly.Application.Availabilities.Commands.SetAvailabilities;
using Booqly.Application.Common.Interfaces;
using Booqly.Application.Professionals.Commands.UpdateProfessional;
using Booqly.Application.Professionals.Queries.GetAvailableSlots;
using Booqly.Application.Professionals.Queries.GetProfessionalById;
using Booqly.Application.Professionals.Queries.GetProfessionals;
using Booqly.Application.Services.Commands.CreateService;
using Booqly.Application.Services.Commands.DeleteService;
using Booqly.Application.Services.Commands.UpdateService;
using Booqly.Application.Services.Queries.GetServices;
using Booqly.API.Extensions;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Booqly.API.Controllers;

[ApiController]
[Route("api/professionals")]
public class ProfessionalsController(IMediator mediator, IAppDbContext db) : ControllerBase
{
    // ── Professionals ────────────────────────────────────────────

    [HttpGet]
    public async Task<IActionResult> GetAll([FromQuery] string? category, CancellationToken ct) =>
        Ok(await mediator.Send(new GetProfessionalsQuery(category), ct));

    [HttpGet("{id:guid}")]
    public async Task<IActionResult> GetById(Guid id, CancellationToken ct) =>
        Ok(await mediator.Send(new GetProfessionalByIdQuery(id), ct));

    [HttpPut("{proId:guid}")]
    [Authorize]
    public async Task<IActionResult> UpdateProfessional(
        Guid proId,
        [FromBody] UpdateProfessionalBody body,
        CancellationToken ct) =>
        Ok(await mediator.Send(new UpdateProfessionalCommand(proId, body.Category, body.Bio), ct));

    [HttpGet("{id:guid}/slots")]
    public async Task<IActionResult> GetSlots(
        Guid id,
        [FromQuery] Guid serviceId,
        [FromQuery] string date,
        CancellationToken ct)
    {
        var day = DateOnly.Parse(date);
        return Ok(await mediator.Send(new GetAvailableSlotsQuery(id, serviceId, day), ct));
    }

    // ── Services ─────────────────────────────────────────────────

    [HttpGet("{proId:guid}/services")]
    public async Task<IActionResult> GetServices(Guid proId, CancellationToken ct) =>
        Ok(await mediator.Send(new GetServicesQuery(proId), ct));

    [HttpPost("{proId:guid}/services")]
    [Authorize]
    public async Task<IActionResult> CreateService(
        Guid proId,
        [FromBody] ServiceBody body,
        CancellationToken ct) =>
        Ok(await mediator.Send(new CreateServiceCommand(proId, body.Name, body.Description, body.Price, body.DurationMinutes), ct));

    [HttpPut("{proId:guid}/services/{serviceId:guid}")]
    [Authorize]
    public async Task<IActionResult> UpdateService(
        Guid proId,
        Guid serviceId,
        [FromBody] ServiceBody body,
        CancellationToken ct) =>
        Ok(await mediator.Send(new UpdateServiceCommand(proId, serviceId, body.Name, body.Description, body.Price, body.DurationMinutes), ct));

    [HttpDelete("{proId:guid}/services/{serviceId:guid}")]
    [Authorize]
    public async Task<IActionResult> DeleteService(Guid proId, Guid serviceId, CancellationToken ct)
    {
        await mediator.Send(new DeleteServiceCommand(proId, serviceId), ct);
        return NoContent();
    }

    // ── Availabilities ───────────────────────────────────────────

    [HttpGet("{proId:guid}/availabilities")]
    public async Task<IActionResult> GetAvailabilities(Guid proId, CancellationToken ct)
    {
        var list = await db.Availabilities
            .Where(a => a.ProfessionalId == proId)
            .OrderBy(a => a.DayOfWeek)
            .Select(a => new { a.DayOfWeek, startTime = a.StartTime.ToString(@"hh\:mm"), endTime = a.EndTime.ToString(@"hh\:mm") })
            .ToListAsync(ct);
        return Ok(list);
    }

    [HttpPut("{proId:guid}/availabilities")]
    [Authorize]
    public async Task<IActionResult> SetAvailabilities(
        Guid proId,
        [FromBody] SetAvailabilitiesBody body,
        CancellationToken ct)
    {
        await mediator.Send(new SetAvailabilitiesCommand(proId, body.Availabilities), ct);
        return NoContent();
    }

    // ── Request bodies ───────────────────────────────────────────

    public record UpdateProfessionalBody(string Category, string? Bio);
    public record ServiceBody(string Name, string? Description, decimal Price, int DurationMinutes);
    public record SetAvailabilitiesBody(IReadOnlyList<AvailabilityInput> Availabilities);
}

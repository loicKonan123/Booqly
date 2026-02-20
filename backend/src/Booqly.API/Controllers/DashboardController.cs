using Booqly.Application.Common.Interfaces;
using Booqly.API.Extensions;
using Booqly.Domain.Enums;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Booqly.API.Controllers;

[ApiController]
[Route("api/dashboard")]
[Authorize]
public class DashboardController(IAppDbContext db) : ControllerBase
{
    [HttpGet("stats")]
    public async Task<IActionResult> GetStats(CancellationToken ct)
    {
        var userId = User.GetUserId();

        var pro = await db.Professionals
            .FirstOrDefaultAsync(p => p.UserId == userId, ct);

        if (pro is null) return Forbid();

        var today = DateTime.UtcNow.Date;
        var appointments = await db.Appointments
            .Where(a => a.ProfessionalId == pro.Id && a.Status != AppointmentStatus.Cancelled)
            .ToListAsync(ct);

        return Ok(new
        {
            today = appointments.Count(a => a.StartTime.Date == today),
            upcoming = appointments.Count(a => a.StartTime > DateTime.UtcNow),
            total = appointments.Count,
            completed = appointments.Count(a => a.Status == AppointmentStatus.Completed)
        });
    }
}

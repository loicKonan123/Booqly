using Booqly.Application.Common.DTOs;
using Booqly.Application.Common.Interfaces;
using Booqly.Domain.Enums;
using MediatR;
using Microsoft.EntityFrameworkCore;

namespace Booqly.Application.Professionals.Queries.GetAvailableSlots;

public class GetAvailableSlotsQueryHandler(IAppDbContext db)
    : IRequestHandler<GetAvailableSlotsQuery, IReadOnlyList<TimeSlotDto>>
{
    public async Task<IReadOnlyList<TimeSlotDto>> Handle(GetAvailableSlotsQuery req, CancellationToken ct)
    {
        var service = await db.Services
            .FirstOrDefaultAsync(s => s.Id == req.ServiceId && s.ProfessionalId == req.ProId, ct)
            ?? throw new KeyNotFoundException("Service introuvable.");

        var dow = (int)req.Date.DayOfWeek;

        var availability = await db.Availabilities
            .FirstOrDefaultAsync(a => a.ProfessionalId == req.ProId && a.DayOfWeek == dow, ct);

        if (availability is null) return [];

        // Load existing confirmed/pending appointments that day
        var dayStart = req.Date.ToDateTime(TimeOnly.MinValue);
        var dayEnd = req.Date.ToDateTime(TimeOnly.MaxValue);

        var existingAppointments = await db.Appointments
            .Where(a =>
                a.ProfessionalId == req.ProId &&
                a.StartTime >= dayStart &&
                a.StartTime <= dayEnd &&
                a.Status != AppointmentStatus.Cancelled)
            .ToListAsync(ct);

        // Generate slots
        var slots = new List<TimeSlotDto>();
        var slotDuration = TimeSpan.FromMinutes(service.DurationMinutes);
        var current = req.Date.ToDateTime(TimeOnly.FromTimeSpan(availability.StartTime));
        var end = req.Date.ToDateTime(TimeOnly.FromTimeSpan(availability.EndTime));

        while (current + slotDuration <= end)
        {
            var slotEnd = current + slotDuration;
            var isAvailable = !existingAppointments.Any(a => a.Overlaps(current, slotEnd));

            slots.Add(new TimeSlotDto(
                current.ToString("o"), // ISO 8601 as ID
                current,
                slotEnd,
                isAvailable
            ));
            current += slotDuration;
        }

        return slots;
    }
}

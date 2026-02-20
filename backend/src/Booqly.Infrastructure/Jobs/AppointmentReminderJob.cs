using Booqly.Application.Common.Interfaces;
using Booqly.Domain.Enums;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Booqly.Infrastructure.Jobs;

public class AppointmentReminderJob(IAppDbContext db, ISmsService sms, ILogger<AppointmentReminderJob> logger)
{
    /// <summary>Called by Hangfire — sends reminders for appointments starting in ~24h.</summary>
    public async Task SendRemindersAsync()
    {
        var window = DateTime.UtcNow.AddHours(24);
        var from = window.AddMinutes(-30);
        var to = window.AddMinutes(30);

        var appointments = await db.Appointments
            .Include(a => a.Client)
            .Include(a => a.Service)
            .Where(a =>
                a.Status == AppointmentStatus.Confirmed &&
                a.StartTime >= from &&
                a.StartTime <= to)
            .ToListAsync();

        foreach (var appt in appointments)
        {
            if (string.IsNullOrWhiteSpace(appt.Client.Phone)) continue;

            var msg = $"Rappel : Votre RDV est demain le {appt.StartTime:dd/MM/yyyy} à {appt.StartTime:HH:mm} pour {appt.Service.Name}. À bientôt !";

            try
            {
                await sms.SendAsync(appt.Client.Phone, msg);
                logger.LogInformation("Rappel envoyé pour RDV {Id}", appt.Id);
            }
            catch (Exception ex)
            {
                logger.LogError(ex, "Échec rappel RDV {Id}", appt.Id);
            }
        }
    }
}

using Booqly.Domain.Enums;

namespace Booqly.Domain.Entities;

public class Appointment : BaseEntity
{
    public Guid ClientId { get; private set; }
    public User Client { get; private set; } = null!;
    public Guid ProfessionalId { get; private set; }
    public Professional Professional { get; private set; } = null!;
    public Guid ServiceId { get; private set; }
    public Service Service { get; private set; } = null!;
    public DateTime StartTime { get; private set; }
    public DateTime EndTime { get; private set; }
    public AppointmentStatus Status { get; private set; } = AppointmentStatus.Pending;
    public string? Notes { get; private set; }

    private Appointment() { }

    public static Appointment Create(
        Guid clientId,
        Guid professionalId,
        Guid serviceId,
        DateTime startTime,
        DateTime endTime,
        string? notes = null) => new()
        {
            ClientId = clientId,
            ProfessionalId = professionalId,
            ServiceId = serviceId,
            StartTime = startTime,
            EndTime = endTime,
            Notes = notes,
            Status = AppointmentStatus.Pending
        };

    public void UpdateStatus(AppointmentStatus status)
    {
        Status = status;
        SetUpdated();
    }

    public bool CanCancel() =>
        Status == AppointmentStatus.Pending || Status == AppointmentStatus.Confirmed;

    public bool Overlaps(DateTime start, DateTime end) =>
        StartTime < end && EndTime > start;
}

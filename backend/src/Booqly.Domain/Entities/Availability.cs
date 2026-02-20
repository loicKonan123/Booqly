namespace Booqly.Domain.Entities;

public class Availability : BaseEntity
{
    public Guid ProfessionalId { get; private set; }
    public Professional Professional { get; private set; } = null!;

    /// <summary>0 = Sunday … 6 = Saturday (matches System.DayOfWeek)</summary>
    public int DayOfWeek { get; private set; }
    public TimeSpan StartTime { get; private set; }
    public TimeSpan EndTime { get; private set; }

    private Availability() { }

    public static Availability Create(
        Guid professionalId,
        int dayOfWeek,
        TimeSpan startTime,
        TimeSpan endTime) => new()
        {
            ProfessionalId = professionalId,
            DayOfWeek = dayOfWeek,
            StartTime = startTime,
            EndTime = endTime
        };
}

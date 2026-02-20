namespace Booqly.Domain.Entities;

public class Professional : BaseEntity
{
    public Guid UserId { get; private set; }
    public User User { get; private set; } = null!;
    public string? Bio { get; private set; }
    public string Category { get; private set; } = string.Empty;
    public double Rating { get; private set; }
    public int ReviewCount { get; private set; }

    public ICollection<Service> Services { get; private set; } = new List<Service>();
    public ICollection<Availability> Availabilities { get; private set; } = new List<Availability>();
    public ICollection<Appointment> Appointments { get; private set; } = new List<Appointment>();

    private Professional() { }

    public static Professional Create(Guid userId, string category, string? bio = null) => new()
    {
        UserId = userId,
        Category = category,
        Bio = bio,
        Rating = 0,
        ReviewCount = 0
    };

    public void UpdateProfile(string category, string? bio)
    {
        Category = category;
        Bio = bio;
        SetUpdated();
    }

    public void AddReview(double rating)
    {
        Rating = Math.Round(((Rating * ReviewCount) + rating) / (ReviewCount + 1), 1);
        ReviewCount++;
        SetUpdated();
    }
}

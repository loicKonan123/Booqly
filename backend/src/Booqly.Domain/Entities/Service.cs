namespace Booqly.Domain.Entities;

public class Service : BaseEntity
{
    public Guid ProfessionalId { get; private set; }
    public Professional Professional { get; private set; } = null!;
    public string Name { get; private set; } = string.Empty;
    public string? Description { get; private set; }
    public decimal Price { get; private set; }
    public int DurationMinutes { get; private set; }
    public bool IsActive { get; private set; } = true;

    private Service() { }

    public static Service Create(
        Guid professionalId,
        string name,
        decimal price,
        int durationMinutes,
        string? description = null) => new()
        {
            ProfessionalId = professionalId,
            Name = name,
            Price = price,
            DurationMinutes = durationMinutes,
            Description = description
        };

    public void Update(string name, decimal price, int durationMinutes, string? description)
    {
        Name = name;
        Price = price;
        DurationMinutes = durationMinutes;
        Description = description;
        SetUpdated();
    }

    public void Deactivate()
    {
        IsActive = false;
        SetUpdated();
    }
}

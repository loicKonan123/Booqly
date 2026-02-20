using Booqly.Domain.Enums;

namespace Booqly.Domain.Entities;

public class User : BaseEntity
{
    public string IdentityUserId { get; private set; } = string.Empty;
    public string Email { get; private set; } = string.Empty;
    public string FirstName { get; private set; } = string.Empty;
    public string LastName { get; private set; } = string.Empty;
    public string? Phone { get; private set; }
    public UserRole Role { get; private set; }

    public Professional? ProfessionalProfile { get; private set; }

    private User() { }

    public static User Create(
        string identityUserId,
        string email,
        string firstName,
        string lastName,
        string? phone,
        UserRole role) => new()
        {
            IdentityUserId = identityUserId,
            Email = email,
            FirstName = firstName,
            LastName = lastName,
            Phone = phone,
            Role = role
        };

    public string FullName => $"{FirstName} {LastName}";
    public bool IsProfessional => Role == UserRole.Professional;

    public void UpdateProfile(string firstName, string lastName, string? phone)
    {
        FirstName = firstName;
        LastName = lastName;
        Phone = phone;
        SetUpdated();
    }
}

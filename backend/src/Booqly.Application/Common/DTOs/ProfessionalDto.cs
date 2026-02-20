namespace Booqly.Application.Common.DTOs;

public record ProfessionalDto(
    string Id,
    string FirstName,
    string LastName,
    string Email,
    string? Phone,
    string? Bio,
    string Category,
    double Rating,
    int ReviewCount
);

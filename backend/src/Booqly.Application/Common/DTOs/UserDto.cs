namespace Booqly.Application.Common.DTOs;

public record UserDto(
    string Id,
    string Email,
    string FirstName,
    string LastName,
    string? Phone,
    string Role,
    string? ProfessionalId  // null pour les clients, Guid du profil pro sinon
);

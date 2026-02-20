namespace Booqly.Application.Common.DTOs;

public record ServiceDto(
    string Id,
    string ProfessionalId,
    string Name,
    string? Description,
    double Price,
    int DurationMinutes
);

namespace Booqly.Application.Common.DTOs;

public record AppointmentDto(
    string Id,
    string ClientId,
    string ClientName,
    string ClientPhone,
    ProfessionalDto Professional,
    ServiceDto Service,
    DateTime StartTime,
    DateTime EndTime,
    string Status,
    string? Notes
);

namespace Booqly.Application.Common.DTOs;

public record TimeSlotDto(
    string Id,
    DateTime StartTime,
    DateTime EndTime,
    bool IsAvailable
);

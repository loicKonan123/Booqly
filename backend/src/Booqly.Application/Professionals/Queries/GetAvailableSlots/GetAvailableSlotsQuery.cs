using Booqly.Application.Common.DTOs;
using MediatR;

namespace Booqly.Application.Professionals.Queries.GetAvailableSlots;

public record GetAvailableSlotsQuery(Guid ProId, Guid ServiceId, DateOnly Date)
    : IRequest<IReadOnlyList<TimeSlotDto>>;

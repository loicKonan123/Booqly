using MediatR;

namespace Booqly.Application.Availabilities.Commands.SetAvailabilities;

public record AvailabilityInput(int DayOfWeek, string StartTime, string EndTime);

public record SetAvailabilitiesCommand(Guid ProfessionalId, IReadOnlyList<AvailabilityInput> Availabilities)
    : IRequest;

using Booqly.Application.Common.DTOs;
using MediatR;

namespace Booqly.Application.Services.Commands.UpdateService;

public record UpdateServiceCommand(
    Guid ProfessionalId,
    Guid ServiceId,
    string Name,
    string? Description,
    decimal Price,
    int DurationMinutes
) : IRequest<ServiceDto>;

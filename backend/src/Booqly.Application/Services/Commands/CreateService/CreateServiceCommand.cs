using Booqly.Application.Common.DTOs;
using MediatR;

namespace Booqly.Application.Services.Commands.CreateService;

public record CreateServiceCommand(
    Guid ProfessionalId,
    string Name,
    string? Description,
    decimal Price,
    int DurationMinutes
) : IRequest<ServiceDto>;

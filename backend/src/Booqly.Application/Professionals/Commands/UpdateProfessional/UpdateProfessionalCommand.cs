using Booqly.Application.Common.DTOs;
using MediatR;

namespace Booqly.Application.Professionals.Commands.UpdateProfessional;

public record UpdateProfessionalCommand(
    Guid ProId,
    string Category,
    string? Bio) : IRequest<ProfessionalDto>;

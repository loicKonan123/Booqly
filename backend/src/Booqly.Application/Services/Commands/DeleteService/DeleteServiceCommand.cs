using MediatR;

namespace Booqly.Application.Services.Commands.DeleteService;

public record DeleteServiceCommand(Guid ProfessionalId, Guid ServiceId) : IRequest;

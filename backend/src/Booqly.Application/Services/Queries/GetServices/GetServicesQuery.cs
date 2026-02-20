using Booqly.Application.Common.DTOs;
using MediatR;

namespace Booqly.Application.Services.Queries.GetServices;

public record GetServicesQuery(Guid ProfessionalId) : IRequest<IReadOnlyList<ServiceDto>>;

using Booqly.Application.Common.DTOs;
using MediatR;

namespace Booqly.Application.Professionals.Queries.GetProfessionalById;

public record GetProfessionalByIdQuery(Guid Id) : IRequest<ProfessionalDto>;

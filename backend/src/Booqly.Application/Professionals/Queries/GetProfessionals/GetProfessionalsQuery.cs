using Booqly.Application.Common.DTOs;
using MediatR;

namespace Booqly.Application.Professionals.Queries.GetProfessionals;

public record GetProfessionalsQuery(string? Category) : IRequest<IReadOnlyList<ProfessionalDto>>;

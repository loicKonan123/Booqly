using Booqly.Application.Common.DTOs;
using MediatR;

namespace Booqly.Application.Auth.Commands.Register;

public record RegisterCommand(
    string Email,
    string Password,
    string FirstName,
    string LastName,
    string? Phone,
    string Role
) : IRequest<AuthResponse>;

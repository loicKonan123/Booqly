using Booqly.Application.Common.DTOs;
using MediatR;

namespace Booqly.Application.Auth.Commands.Login;

public record LoginCommand(string Email, string Password) : IRequest<AuthResponse>;

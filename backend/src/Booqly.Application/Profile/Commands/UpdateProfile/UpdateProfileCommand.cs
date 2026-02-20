using Booqly.Application.Common.DTOs;
using MediatR;

namespace Booqly.Application.Profile.Commands.UpdateProfile;

public record UpdateProfileCommand(
    string FirstName,
    string LastName,
    string? Phone) : IRequest<UserDto>;

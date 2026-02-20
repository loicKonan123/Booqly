using MediatR;

namespace Booqly.Application.Profile.Commands.ChangePassword;

public record ChangePasswordCommand(
    string CurrentPassword,
    string NewPassword) : IRequest;

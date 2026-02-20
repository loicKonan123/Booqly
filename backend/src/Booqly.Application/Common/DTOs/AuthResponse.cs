namespace Booqly.Application.Common.DTOs;

public record AuthResponse(
    string AccessToken,
    string RefreshToken,
    UserDto User
);

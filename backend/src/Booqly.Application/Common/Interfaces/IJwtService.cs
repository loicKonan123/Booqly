using Booqly.Domain.Entities;
using System.Security.Claims;

namespace Booqly.Application.Common.Interfaces;

public interface IJwtService
{
    string GenerateAccessToken(User user, string identityUserId);
    string GenerateRefreshToken();
    ClaimsPrincipal? GetPrincipalFromExpiredToken(string token);
}

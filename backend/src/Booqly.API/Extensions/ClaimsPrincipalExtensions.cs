using System.Security.Claims;

namespace Booqly.API.Extensions;

public static class ClaimsPrincipalExtensions
{
    public static Guid GetUserId(this ClaimsPrincipal user) =>
        Guid.Parse(user.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? user.FindFirstValue("sub")
            ?? throw new UnauthorizedAccessException("User ID claim missing."));

    public static string GetRole(this ClaimsPrincipal user) =>
        user.FindFirstValue("role") ?? "client";
}

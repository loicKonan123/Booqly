using Booqly.Application.Profile.Commands.ChangePassword;
using Booqly.Application.Profile.Commands.UpdateProfile;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Booqly.API.Controllers;

[ApiController]
[Route("api/profile")]
[Authorize]
public class ProfileController(IMediator mediator) : ControllerBase
{
    [HttpPut]
    public async Task<IActionResult> Update(
        [FromBody] UpdateProfileCommand cmd, CancellationToken ct) =>
        Ok(await mediator.Send(cmd, ct));

    [HttpPut("password")]
    public async Task<IActionResult> ChangePassword(
        [FromBody] ChangePasswordCommand cmd, CancellationToken ct)
    {
        await mediator.Send(cmd, ct);
        return NoContent();
    }
}

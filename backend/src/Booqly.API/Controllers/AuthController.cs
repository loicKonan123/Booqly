using Booqly.Application.Auth.Commands.Login;
using Booqly.Application.Auth.Commands.Register;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace Booqly.API.Controllers;

[ApiController]
[Route("api/auth")]
public class AuthController(IMediator mediator) : ControllerBase
{
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterCommand cmd, CancellationToken ct) =>
        Ok(await mediator.Send(cmd, ct));

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginCommand cmd, CancellationToken ct) =>
        Ok(await mediator.Send(cmd, ct));

    [HttpPost("logout")]
    public IActionResult Logout() => NoContent();
}

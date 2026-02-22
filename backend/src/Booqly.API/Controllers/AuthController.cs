using Booqly.Application.Auth.Commands.ForgotPassword;
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

    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordCommand cmd, CancellationToken ct)
    {
        await mediator.Send(cmd, ct);
        return Ok(new { message = "Si un compte existe avec cet email, un lien de réinitialisation a été envoyé." });
    }
}

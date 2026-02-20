namespace Booqly.Application.Common.Interfaces;

public interface ISmsService
{
    Task SendAsync(string to, string message, CancellationToken ct = default);
}

using Booqly.Application.Common.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Twilio;
using Twilio.Rest.Api.V2010.Account;

namespace Booqly.Infrastructure.Services;

public class TwilioSmsService(IConfiguration config, ILogger<TwilioSmsService> logger) : ISmsService
{
    private readonly string _accountSid = config["Twilio:AccountSid"] ?? "";
    private readonly string _authToken = config["Twilio:AuthToken"] ?? "";
    private readonly string _from = config["Twilio:From"] ?? "";

    public async Task SendAsync(string to, string message, CancellationToken ct = default)
    {
        if (string.IsNullOrWhiteSpace(_accountSid))
        {
            logger.LogWarning("Twilio non configuré — SMS ignoré : {Message}", message);
            return;
        }

        TwilioClient.Init(_accountSid, _authToken);

        await MessageResource.CreateAsync(
            body: message,
            from: new Twilio.Types.PhoneNumber(_from),
            to: new Twilio.Types.PhoneNumber(to));

        logger.LogInformation("SMS envoyé à {To}", to);
    }
}

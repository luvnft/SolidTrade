using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Net.Mail;
using System.Security.Claims;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Services;
using Application.Common.Interfaces.Services.Cache;
using Application.Models.Dtos.Authentication.Response;
using Domain.Enums;
using Infrastructure.Configurations;
using Microsoft.Extensions.Logging;
using Microsoft.IdentityModel.Tokens;

namespace Infrastructure.Authentication;

internal class AuthenticationService : IAuthenticationService
{
    private readonly ILogger<AuthenticationService> _logger;
    private readonly EmailConfiguration _emailConfiguration;
    private readonly SymmetricSecurityKey _jwtSecurityKey;
    private readonly ICacheService _cacheService;
    private readonly IUnitOfWork _unitOfWork;
    private readonly JwtHeader _jwtHeader;
    
    public AuthenticationService(ILogger<AuthenticationService> logger, IUnitOfWork unitOfWork,
        ICacheService cacheService, JwtHeader jwtHeader, SymmetricSecurityKey jwtSecurityKey,
        EmailConfiguration emailConfiguration)
    {
        _logger = logger;
        _unitOfWork = unitOfWork;
        _cacheService = cacheService;
        _jwtHeader = jwtHeader;
        _jwtSecurityKey = jwtSecurityKey;
        _emailConfiguration = emailConfiguration;
    }

    public async Task<Result<CreateMagicLinkResponseDto>> CreateMagicLink(string host, string userEmail)
    {
        var isEmailAvailable = await _unitOfWork.Users.IsEmailAvailable(userEmail);
        if (isEmailAvailable.TryTakeError(out var error, out var emailAvailable))
            return error;

        if (!emailAvailable)
            return EmailNotAvailable.Default(userEmail);

        var magicLinkCode = Guid.NewGuid();
        var magicLinkConfirmationStatusCode = Guid.NewGuid();

        var (subject, body) = ConstructMailMessage(host, magicLinkCode);

        var serviceMail = _emailConfiguration.Email;
        var mailAppPassword = _emailConfiguration.AppPassword;
        var mailPort = _emailConfiguration.Port;
        var mailHost = _emailConfiguration.Host;

        var message = new MailMessage
        {
            From = new MailAddress(serviceMail, "Solidtrade Team"),
            Priority = MailPriority.Normal,
            Subject = subject,
            Body = body,
            IsBodyHtml = true,
        };

        message.To.Add(new MailAddress(userEmail));

        var smtpClient = new SmtpClient(mailHost)
        {
            Port = mailPort,
            Credentials = new NetworkCredential(serviceMail, mailAppPassword),
            EnableSsl = true,
        };

        await smtpClient.SendMailAsync(message);

        var uid = Guid.NewGuid();
        var token = GenerateJwt(_jwtHeader, uid);
        var refreshToken = GenerateJwt(_jwtHeader, uid, true);
       
        const int expirationTimeInMinutes = 60;
        var cachedTokenResponse = new CheckMagicLinkStatusResponseDto
        {
            Status = MagicLinkStatus.MagicLinkNotClicked,
            Token = new VerifyMagicLinkCodeResponseDto
            {
                Token = token,
                RefreshToken = refreshToken,
            },
        };
        
        _cacheService.SetCachedValue(magicLinkCode.ToString(), cachedTokenResponse, expirationTimeInMinutes);
        _cacheService.SetCachedValue(magicLinkConfirmationStatusCode.ToString(), cachedTokenResponse, expirationTimeInMinutes);
        
        return new CreateMagicLinkResponseDto
        {
            ConfirmationStatusCode = magicLinkConfirmationStatusCode,
        };
    }

    // The client will be polling this endpoint to check if the user has clicked the magic link.
    // If so token will be returned. If not, the client will keep polling until user has clicked the magic link.
    public Result<CheckMagicLinkStatusResponseDto> CheckMagicLinkStatus(Guid code)
    {
        var cache = _cacheService.GetCachedValue<CheckMagicLinkStatusResponseDto>(code.ToString());

        if (!cache.Expired && cache.Value.Status == MagicLinkStatus.MagicLinkClicked)
            return cache.Value;

        return new CheckMagicLinkStatusResponseDto { Status = MagicLinkStatus.MagicLinkNotClicked };
    }
    
    public Result<string> VerifyMagicLinkCode(Guid code)
    {
        var cache = _cacheService.GetCachedValue<CheckMagicLinkStatusResponseDto>(code.ToString());
        if (cache.Expired)
        {
            var err = LoginTokenExpired.Default();
            _logger.LogError(err.Message);

            return ConstructInvalidMagicLinkConfirmationMessage();
        }

        cache.Value.Status = MagicLinkStatus.MagicLinkClicked;
        return ConstructMagicLinkConfirmationMessage();
    }

    public (bool, string) VerifyUserToken(string token)
    {
        try
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var validationParameters = new TokenValidationParameters
            {
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = _jwtSecurityKey,
                ValidateIssuer = false,
                ValidateAudience = false
            };

            var claimsPrincipal = tokenHandler.ValidateToken(token, validationParameters, out _);

            var userId = claimsPrincipal.Claims.FirstOrDefault(c => c.Type == "uid");

            if (userId == null)
            {
                _logger.LogError("Token does not contain a user id.");
                return (false, null);
            }
            
            return (true, userId.Value);
        }
        catch (SecurityTokenException ex)
        {
            Console.WriteLine("Token is invalid: " + ex.Message);
        }

        return (false, null);
    }

    private static (string, string) ConstructMailMessage(string host, Guid magicLinkCode)
    {
        var magicLink = $"{host}/auth?ConfirmationCode={magicLinkCode}";
        
        const string subject = "Verify your email";
        const string stylesheet = @"
        .container {
            background-color: #f2f2f2;
            padding: 20px;
            text-align: center;
            font-family: Arial, sans-serif;
        }
        h1 {
            color: #3b3b3b;
            font-size: 36px;
            margin-bottom: 20px;
        }
        p {
            color: #3b3b3b;
            font-size: 18px;
            margin-bottom: 20px;
        }
        a {
            display: inline-block;
            background-color: #337ab7;
            color: #fff;
            padding: 15px 20px;
            border-radius: 5px;
            text-decoration: none;
            font-size: 18px;
            margin-top: 20px;
        }
";
        var body = 
            $""""
    <html>
    <head>
    <style>
{stylesheet}
    </style>
    </head>
    <body>
    <div class='container'>
        <h1>Welcome to Our Service!</h1>
        <p>We're excited to have you on board.</p>
        <p>To complete your registration, please click the link below to verify your email:</p>
        <a href='{magicLink}'>Verify Email</a>
        <p>If you have any questions, please don't hesitate to reach out to us.</p>
        <p>Best regards,<br>The Solidtrade Team</p>
    </div>
    </body>
    </html>
"""";
        
        return (subject, body);
    }

    private static string GenerateJwt(JwtHeader header, Guid uid, bool isRefreshToken = false)
    {
        var payload = new Claim[]
        {
            new("uid", uid.ToString()),
            new("is_refresh_token", isRefreshToken.ToString()),
            new("iat", ((int)(DateTime.UtcNow - new DateTime(1970, 1, 1)).TotalSeconds).ToString()),
        };

        var jwtPayload = new JwtPayload
        (
            issuer: "Solidtrade",
            audience: "SolidtradeClient",
            claims: payload,
            notBefore: DateTime.UtcNow,
            expires: isRefreshToken ? DateTime.UtcNow.AddDays(14) : DateTime.UtcNow.AddMinutes(90)
        );

        var jwt = new JwtSecurityToken(header, jwtPayload);
        var token = new JwtSecurityTokenHandler().WriteToken(jwt);
        return token;
    }

    private static string ConstructMagicLinkConfirmationMessage()
    {
        return @"
    <html>
    <head>
    <style>
        .container {
            background-color: #333;
            padding: 40px;
            text-align: center;
            font-family: Arial, sans-serif;
            color: #fff;
        }
        h1 {
            font-size: 48px;
            margin-bottom: 20px;
        }
        p {
            font-size: 24px;
            margin-bottom: 20px;
        }
        .logo {
            margin-bottom: 40px;
        }
        .confirmation {
            display: inline-block;
            background-color: #0288d1;
            color: #fff;
            padding: 20px 30px;
            border-radius: 5px;
            text-decoration: none;
            font-size: 24px;
            margin-top: 20px;
            box-shadow: 2px 2px #ddd;
        }
        .message {
            margin-top: 40px;
        }
    </style>
    </head>
    <body>
    <div class='container'>
        <img class='logo' src='https://github.com/SolomonRosemite/SolidTrade/blob/staging/client/assets/images/dark-logo.gif?raw=true' alt='Solidtrade Logo'>
        <h1>Email Verified</h1>
        <p>Your email address has been successfully confirmed.</p>
        <a class='confirmation' href='https://www.solidtrade.com'>Go to Solidtrade</a>
        <p class='message'>Thank you for choosing Solidtrade!</p>
    </div>
    </body>
    </html>";
    }
    
    private static string ConstructInvalidMagicLinkConfirmationMessage()
    {
        return @"
    <html>
    <head>
    <style>
        .container {
            background-color: #333;
            padding: 40px;
            text-align: center;
            font-family: Arial, sans-serif;
            color: #fff;
        }
        h1{{
            font-size: 48px;
            margin-bottom: 20px;
        }
        p {
            font-size: 24px;
            margin-bottom: 20px;
        }
        .logo {
            margin-bottom: 40px;
        }
        .resend {
            display: inline-block;
            background-color: #0288d1;
            color: #fff;
            padding: 20px 30px;
            border-radius: 5px;
            text-decoration: none;
            font-size: 24px;
            margin-top: 20px;
            box-shadow: 2px 2px #ddd;
        }
        .message {
            margin-top: 40px;
        }
    </style>
    </head>
    <body>
    <div class='container'>
        <img class='logo' src='https://github.com/SolomonRosemite/SolidTrade/blob/staging/client/assets/images/dark-logo.gif?raw=true' alt='Solidtrade Logo'>
        <h1>Expired Confirmation Link</h1>
        <p>It looks like the confirmation link for your email address has expired. Please resend the confirmation link to your email address.</p>
        <a class='resend' href='https://www.solidtrade.com/resend'>Resend Confirmation Link</a>
        <p class='message'>Thank you for choosing Solidtrade!</p>
    </div>
    </body>
    </html>";
    }
}

using Application.Common;
using Application.Common.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace WebAPI.Filters;

public class AuthenticationFilter : IAsyncActionFilter
{
    private readonly IAuthenticationService _authenticationService;
    private readonly IReadOnlyCollection<string> _publicPaths = new List<string>
    {
        "/",
        "/healthcheck",
        "/image",
        "/auth",
        "/auth/status",
    };

    public AuthenticationFilter(IAuthenticationService authenticationService)
    {
        _authenticationService = authenticationService;
    }

    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        var request = context.HttpContext.Request;
        var path = request.Path.Value?.ToLower();
        path = !path.EndsWith('/') ? path : path[..^1]; 

        if (_publicPaths.Contains(path))
        {
            await next();
            return;
        }
            
        var token = request.Headers["Authorization"];

        if (string.IsNullOrEmpty(token))
        {
            context.Result = new UnauthorizedObjectResult(new NotAuthenticated
            {
                Title = "Authorization header missing",
                Message = "The authorization header was not specified.",
                UserFriendlyMessage = "Login failed. Please try again",
            });
            return;
        }

        if (token.ToString().Length < 7)
        {
            context.Result = new UnauthorizedObjectResult(new NotAuthenticated
            {
                Title = "Invalid token",
                Message = "The token provided invalid.",
                UserFriendlyMessage = "Login failed. Please try again",
            });
            return;
        }
        
        var jtw = token.ToString()[7..];
        var (successful, uid) = _authenticationService.VerifyUserToken(jtw);

        if (!successful)
        {
            context.Result = new UnauthorizedObjectResult(new NotAuthenticated
            {
                Title = "Invalid token",
                Message = "The token provided is expired or invalid.",
                UserFriendlyMessage = "Login failed. Please try again",
            });
            return;
        }

        // Set the uid header so that it can be picked up by controller 
        request.Headers[ApplicationConstants.UidHeader] = uid;
            
        await next();
    }
}
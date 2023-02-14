using System.Net;
using Application.Errors.Base;

namespace Application.Errors.Types;

public class UsernameNotAvailable : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Conflict;

    public static UsernameNotAvailable Default(string username)
    {
        return new UsernameNotAvailable
        {
            Title = "Username not available",
            Message = $"The username '{username}' is already in use.",
            UserFriendlyMessage = "The username is unfortunately already in use. Please choose another one.",
        };
    }
}

public class UidNotAvailable : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Conflict;

    public static UidNotAvailable Default(string uid)
    {
        return new UidNotAvailable
        {
            Title = "Uid already in use",
            Message = $"Can not create user with existing uid of '{uid}'.",
            UserFriendlyMessage = "Seems like this google account is already linked to an user. Please choose another google account or login sign in.",
        };
    }
}

public class EmailNotAvailable : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Conflict;

    public static EmailNotAvailable Default(string email)
    {
        return new EmailNotAvailable
        {
            Title = "Email already in use",
            Message = $"The email: {email} is already in use.",
            UserFriendlyMessage =
                "Seems like this google account is already linked to another user. Please choose another google account.",
        };
    }
}

public class LoginTokenExpired : BaseError
{
    public override HttpStatusCode Code => HttpStatusCode.Unauthorized;

    public static LoginTokenExpired Default()
    {
        return new LoginTokenExpired
        {
            Title = "User token expired",
            Message = $"User tired to make a request with an expired token.",
            UserFriendlyMessage = "Hi there! It seems like you have been inactive for a while. Please login again.",
        };
    }
}

﻿using Application.Common.Interfaces.Services;
using Serilog;

namespace Infrastructure.Services;

internal class NotificationService : INotificationService
{
    private readonly ILogger _logger = Log.ForContext<NotificationService>();

    public Task SendNotification(int userId, string registrationToken, string title, string message)
    {
        var data = new Dictionary<string, string>
        {
            { "Title", title },
            { "Body", message },
        };

        _logger.Information("Send notification to user with id {@UserId} with message {@Data}", userId, data);

        if (registrationToken == string.Empty)
        {
            _logger.Error("The provided user registration token is empty. There for not sending a notification.");
            return Task.CompletedTask;
        }

        // TODO: Add email sender
        return Task.CompletedTask;
    }
}
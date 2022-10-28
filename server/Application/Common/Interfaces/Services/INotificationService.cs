namespace Application.Common.Interfaces.Services;

public interface INotificationService
{
    Task SendNotification(int userId, string registrationToken, string title, string message);
}
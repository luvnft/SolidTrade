namespace Application.Common.Interfaces.Services.Jobs;

public interface IBackgroundJob<T>
{
    public string JobTitle { get; }
    
    public Task StartAsync();
}
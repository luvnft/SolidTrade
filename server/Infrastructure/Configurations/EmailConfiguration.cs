namespace Infrastructure.Configurations;

public record EmailConfiguration(string Email, string AppPassword, string Host, int Port);
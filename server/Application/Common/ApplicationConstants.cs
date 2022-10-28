namespace Application.Common;

public static class ApplicationConstants
{
    public const string LogMessageTemplate = "{@LogParameters}";
    public static string UidHeader => "_Uid";
    
    // Upload size limit: 10mb
    public const int MaxUploadFileSize = 10000000;
}
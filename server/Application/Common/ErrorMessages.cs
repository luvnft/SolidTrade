namespace Application.Common;

public static class ErrorMessages
{
    public const string GoodUntilErrorMessage = "Good until must be future date.";
    public const string CountOfNumberOfSharedMessage = "Number of shares must at least be 1.";
    public const string PriceThresholdMessage = "Price threshold must at least be 0.00010.";
    public const string UsernameFormatMessage = "The username format is not valid.";

    public const string NotFoundErrorMessage = "Bad news friend. We can't seem to find what you're looking for.";
        
    public const string UnexpectedErrorTitle = "We screwed up";
    public const string UnexpectedErrorFriendlyMessage = "We are sorry. Something went wrong on our end. Please try again another time.";
}
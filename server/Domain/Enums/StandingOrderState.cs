namespace Domain.Enums;

public enum StandingOrderState
{
    Filled,
    WaitingForFill,
    
    /// <summary>
    /// If the good until date is in the past or the user manually closed the standing order, the order will be cancelled.
    /// </summary>
    Closed,
    
    /// <summary>
    /// If the order would have been filled, but for some other reasons could not, e.g. insufficient funds or option is expired and so on.
    /// When this occurs, the standing order will be cancelled.
    /// </summary>
    Failed,
}
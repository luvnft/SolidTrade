namespace Domain.Enums;

public enum OngoingTradeResponse
{
    Complete,
    WaitingForFill,
    PositionsAlreadyClosed,
    Failed,
}
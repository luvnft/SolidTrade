using System.Runtime.Serialization;

namespace Domain.Enums;

public enum ProductCategory
{
    Warrant,
    [EnumMember(Value = "Unlimited Turbo")]
    UnlimitedTurbo,
    [EnumMember(Value = "Best Turbo")]
    BestTurbo,
    [EnumMember(Value = "Mini Turbo")]
    MiniTurbo,
    [EnumMember(Value = "Mini Future")]
    MiniFuture,
    [EnumMember(Value = "Turbo")]
    Turbo,
    [EnumMember(Value = "Open End Turbo")]
    OpenEndTurbo,
    [EnumMember(Value = "X-Open End Turbo")]
    XOpenEndTurbo,
}
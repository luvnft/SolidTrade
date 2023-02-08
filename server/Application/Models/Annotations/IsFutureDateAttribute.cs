using System.ComponentModel.DataAnnotations;

namespace Application.Models.Annotations;

public class IsFutureDateAttribute : ValidationAttribute
{
    public override bool IsValid(object value)
    {
        if (value is null)
            return false;
            
        var now = DateTimeOffset.Now;
        var dt = (DateTimeOffset) value;

        return dt >= now;
    }
}
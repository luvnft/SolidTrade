namespace Application.Models.Dtos.Authentication.Response;

// This is used to return a code that the can poll the server with to check if the magic link has been clicked.
// TODO: However once messaging is implemented, this can be removed.
public class CreateMagicLinkResponseDto
{
    public Guid ConfirmationStatusCode { get; set; }
}
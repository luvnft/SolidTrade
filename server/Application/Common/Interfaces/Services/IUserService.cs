using Application.Models.Dtos.User.Request;
using Application.Models.Dtos.User.Response;
using Application.Models.Types;

namespace Application.Common.Interfaces.Services;

public interface IUserService
{
    public Task<Result<UserResponseDto>> CreateUser(CreateUserRequestDto dto, string uid);
    
    public Task<Result<UserResponseDto>> GetUserById(int id, string uid);
    
    public Task<Result<UserResponseDto>> GetUserByUid(string queriedUid, string uid);

    public Task<Result<IEnumerable<UserResponseDto>>> SearchUserByUsername(string username, string uid);

    public Task<Result<UserResponseDto>> UpdateUser(UpdateUserDto dto, string uid);

    public Task<Result<DeleteUserResponseDto>> DeleteUser(string uid, string token);
}
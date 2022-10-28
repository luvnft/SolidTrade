using Application.Errors.Common;
using Application.Models.Dtos.User.Request;
using Application.Models.Dtos.User.Response;
using Application.Models.Types;
using OneOf;

namespace Application.Common.Interfaces.Services;

public interface IUserService
{
    public Task<OneOf<UserResponseDto, ErrorResponse>> CreateUser(CreateUserRequestDto dto, string uid);
    
    public Task<OneOf<UserResponseDto, ErrorResponse>> GetUserById(int id, string uid);
    
    public Task<OneOf<UserResponseDto, ErrorResponse>> GetUserByUid(string queriedUid, string uid);

    public Task<OneOf<List<UserResponseDto>, ErrorResponse>> SearchUserByUsername(string username, string uid);

    public Task<OneOf<UserResponseDto, ErrorResponse>> UpdateUser(UpdateUserDto dto, string uid);

    public Task<OneOf<DeleteUserResponseDto, ErrorResponse>> DeleteUser(string uid);
}
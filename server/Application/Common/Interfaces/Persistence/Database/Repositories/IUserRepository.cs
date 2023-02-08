using Application.Models.Types;
using Domain.Entities;

namespace Application.Common.Interfaces.Persistence.Database.Repositories;

public interface IUserRepository : IRepository<User>
{
    Task<Result<bool>> IsUsernameAvailable(string username);
    Task<Result<bool>> IsUidAvailable(string uid);
    Task<Result<bool>> IsEmailAvailable(string email);

    Task<Result<List<User>>> FindUsersByUsername(string username);
    Task<Result<User>> FindUserByUid(string uid);
}
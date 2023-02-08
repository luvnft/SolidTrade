using Application.Common.Abstracts.Persistence.Database.Repositories;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Persistence.Database.Repositories;
using Application.Extensions;
using Application.Models.Types;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Application.Persistence.Database.Repositories;

public class UserRepository : BaseRepository<User>, IUserRepository
{
    public UserRepository(IApplicationDbContext context) : base(context)
    {
    }

    public Task<Result<bool>> IsUsernameAvailable(string username)
        => AnyAsync(u => EF.Functions.Like(u.Username, $"{username}")).InvertBoolResult();

    public Task<Result<bool>> IsUidAvailable(string uid)
        => AnyAsync(u => u.Uid == uid).InvertBoolResult();

    public Task<Result<bool>> IsEmailAvailable(string email)
        => AnyAsync(u => EF.Functions.Like(u.Username, $"{email}")).InvertBoolResult();
        
    public Task<Result<List<User>>> FindUsersByUsername(string username)
        => FindAsync(u => EF.Functions.Like(u.Username, $"{username}%"));

    public Task<Result<User>> FindUserByUid(string uid)
        => FirstAsync(u => u.Uid == uid);
}
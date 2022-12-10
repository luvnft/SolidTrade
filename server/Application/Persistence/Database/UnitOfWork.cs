using Application.Common;
using Application.Common.Interfaces.Persistence.Database;
using Application.Common.Interfaces.Persistence.Database.Repositories;

namespace Application.Persistence.Database;

public class UnitOfWork : IUnitOfWork
{
    private readonly IApplicationDbContext _context;
    public IStockRepository Stocks { get; }
    public IUserRepository Users { get; }
    
    public UnitOfWork(IApplicationDbContext context, IUserRepository users, IStockRepository stocks)
    {
        _context = context;
        Users = users;
        Stocks = stocks;
    }

    public async Task<Result<OneOf.Types.Success>> Commit()
    {
        try
        {
            await _context.SaveChangesAsync();
            return new OneOf.Types.Success();
        }
        catch (Exception e)
        {
            return new UnexpectedDatabaseError
            {
                Title = ErrorMessages.UnexpectedErrorTitle,
                Exception = e,
                Message = "Failed to commit changes to database.",
                UserFriendlyMessage = ErrorMessages.UnexpectedErrorFriendlyMessage,
            };
        }
    }
}
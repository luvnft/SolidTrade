using System;
using System.Linq;
using Microsoft.EntityFrameworkCore;
using SolidTradeServer.Data.Entities.Common;

namespace SolidTradeServer.Data.Common
{
    public class DbSolidTrade : DbContext
    {
        
        
        // Updates create at and updated at automatically
        public override int SaveChanges()
        {
            var entries = ChangeTracker
                .Entries()
                .Where(e => e.Entity is BaseEntity && e.State is EntityState.Added or EntityState.Modified);

            foreach (var entityEntry in entries)
            {
                ((BaseEntity)entityEntry.Entity).UpdatedAt = DateTime.Now;

                if (entityEntry.State == EntityState.Added)
                {
                    ((BaseEntity)entityEntry.Entity).CreatedAt = DateTime.Now;
                }
            }

            return base.SaveChanges();
        }
    }
}
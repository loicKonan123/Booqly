using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace Booqly.Infrastructure.Data;

/// <summary>Used by dotnet-ef at design time (migrations).</summary>
public class AppDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    public AppDbContext CreateDbContext(string[] args)
    {
        var options = new DbContextOptionsBuilder<AppDbContext>()
            .UseSqlServer("Server=(localdb)\\mssqllocaldb;Database=BooqlyDb_Dev;Trusted_Connection=True;")
            .Options;

        return new AppDbContext(options);
    }
}

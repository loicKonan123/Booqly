using Booqly.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Booqly.Application.Common.Interfaces;

public interface IAppDbContext
{
    DbSet<User> Users { get; }
    DbSet<Professional> Professionals { get; }
    DbSet<Service> Services { get; }
    DbSet<Availability> Availabilities { get; }
    DbSet<Appointment> Appointments { get; }

    Task<int> SaveChangesAsync(CancellationToken ct = default);
}

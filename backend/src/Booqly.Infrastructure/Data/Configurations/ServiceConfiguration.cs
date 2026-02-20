using Booqly.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Booqly.Infrastructure.Data.Configurations;

public class ServiceConfiguration : IEntityTypeConfiguration<Service>
{
    public void Configure(EntityTypeBuilder<Service> b)
    {
        b.HasKey(s => s.Id);
        b.Property(s => s.Name).IsRequired().HasMaxLength(200);
        b.Property(s => s.Description).HasMaxLength(1000);
        b.Property(s => s.Price).HasPrecision(10, 2);
        b.HasQueryFilter(s => s.IsActive);
    }
}

using Booqly.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Booqly.Infrastructure.Data.Configurations;

public class ProfessionalConfiguration : IEntityTypeConfiguration<Professional>
{
    public void Configure(EntityTypeBuilder<Professional> b)
    {
        b.HasKey(p => p.Id);
        b.Property(p => p.Category).IsRequired().HasMaxLength(100);
        b.Property(p => p.Bio).HasMaxLength(1000);

        b.HasMany(p => p.Services)
         .WithOne(s => s.Professional)
         .HasForeignKey(s => s.ProfessionalId);

        b.HasMany(p => p.Availabilities)
         .WithOne(a => a.Professional)
         .HasForeignKey(a => a.ProfessionalId);

        b.HasMany(p => p.Appointments)
         .WithOne(a => a.Professional)
         .HasForeignKey(a => a.ProfessionalId);
    }
}

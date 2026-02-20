using Booqly.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Booqly.Infrastructure.Data.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> b)
    {
        b.HasKey(u => u.Id);
        b.Property(u => u.Email).IsRequired().HasMaxLength(200);
        b.Property(u => u.FirstName).IsRequired().HasMaxLength(100);
        b.Property(u => u.LastName).IsRequired().HasMaxLength(100);
        b.Property(u => u.Phone).HasMaxLength(20);
        b.HasIndex(u => u.Email).IsUnique();
        b.HasIndex(u => u.IdentityUserId).IsUnique();

        b.HasOne(u => u.ProfessionalProfile)
         .WithOne(p => p.User)
         .HasForeignKey<Professional>(p => p.UserId);
    }
}

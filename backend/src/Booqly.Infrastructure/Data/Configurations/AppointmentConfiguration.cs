using Booqly.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Booqly.Infrastructure.Data.Configurations;

public class AppointmentConfiguration : IEntityTypeConfiguration<Appointment>
{
    public void Configure(EntityTypeBuilder<Appointment> b)
    {
        b.HasKey(a => a.Id);
        b.Property(a => a.Notes).HasMaxLength(500);
        b.Property(a => a.Status).HasConversion<string>();

        b.HasOne(a => a.Client)
         .WithMany()
         .HasForeignKey(a => a.ClientId)
         .OnDelete(DeleteBehavior.Restrict);

        b.HasOne(a => a.Service)
         .WithMany()
         .HasForeignKey(a => a.ServiceId)
         .OnDelete(DeleteBehavior.Restrict);

        b.HasIndex(a => new { a.ProfessionalId, a.StartTime });
    }
}

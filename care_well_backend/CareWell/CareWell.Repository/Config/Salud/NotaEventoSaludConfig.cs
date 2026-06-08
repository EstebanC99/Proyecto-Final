using CareWell.Domain.Salud;
using Microsoft.EntityFrameworkCore;

namespace CareWell.Repository.Config.Salud
{
    public class NotaEventoSaludConfig : IEntityTypeConfiguration<NotaEventoSalud>
    {
        public void Configure(Microsoft.EntityFrameworkCore.Metadata.Builders.EntityTypeBuilder<NotaEventoSalud> builder)
        {
            builder.ToTable("t_NotaEventoSalud");

            builder.HasKey(e => e.ID);
            builder.Property(e => e.ID).HasColumnName("ID_NotaEventoSalud").ValueGeneratedOnAdd();

            builder.HasOne(e => e.Autor).WithMany().HasForeignKey("ID_Persona").OnDelete(DeleteBehavior.Restrict);
            builder.Property(e => e.FechaHora).IsRequired();
            builder.Property(e => e.Contenido).IsRequired();
        }
    }
}

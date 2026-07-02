using CareWell.Domain.General;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CareWell.Repository.Config.General
{
    public class TipoEventoConfig : IEntityTypeConfiguration<TipoEvento>
    {
        public void Configure(EntityTypeBuilder<TipoEvento> builder)
        {
            builder.ToTable("t_TipoEvento");

            builder.HasKey(t => t.ID);
            builder.Property(t => t.ID).HasColumnName("ID_TipoEvento").ValueGeneratedOnAdd();

            builder.Property(t => t.Descripcion).IsRequired().HasMaxLength(100);
            builder.Property(t => t.Agendable).IsRequired().HasDefaultValue(false);
        }
    }
}

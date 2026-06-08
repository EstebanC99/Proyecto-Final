using CareWell.Domain.Agenda;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace CareWell.Repository.Config.Agenda
{
    public class TipoEventoAgendaConfig : IEntityTypeConfiguration<TipoEventoAgenda>
    {
        public void Configure(EntityTypeBuilder<TipoEventoAgenda> builder)
        {
            builder.ToTable("t_TipoEventoAgenda");

            builder.HasKey(t => t.ID);
            builder.Property(t => t.ID).HasColumnName("ID_TipoEventoAgenda").ValueGeneratedOnAdd();

            builder.Property(t => t.Descripcion).IsRequired().HasMaxLength(100);
        }
    }
}

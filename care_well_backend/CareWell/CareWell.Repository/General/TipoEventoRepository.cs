using CareWell.DataViews.General;
using CareWell.Domain.General;

namespace CareWell.Repository.General
{
    public class TipoEventoRepository : Repository<TipoEvento>, ITipoEventoRepository
    {
        public TipoEventoRepository(CareWellDbContext dbContext) : base(dbContext)
        {

        }

        public List<TipoEventoDataView> ObtenerTodos()
        {
            return this.DbSet
                .Select(s => new TipoEventoDataView
                {
                    ID = s.ID,
                    Descripcion = s.Descripcion,
                    Agendable = s.Agendable
                })
                .ToList();
        }
    }
}

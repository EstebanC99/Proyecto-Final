using CareWell.DataViews;
using CareWell.Domain.Salud;

namespace CareWell.Repository.Salud
{
    public class TipoHabitoVidaRepository : Repository<TipoHabitoVida>, ITipoHabitoVidaRepository
    {
        public TipoHabitoVidaRepository(CareWellDbContext dbContext) : base(dbContext) { }

        public List<BaseEntityDataView> ObtenerTodos()
        {
            return this.DbSet
                .Select(t => new BaseEntityDataView { ID = t.ID, Descripcion = t.Descripcion })
                .ToList();
        }
    }
}

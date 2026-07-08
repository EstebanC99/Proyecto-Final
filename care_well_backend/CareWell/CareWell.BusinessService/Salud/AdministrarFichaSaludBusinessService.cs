using CareWell.BusinessService.Abstractions.Salud;
using CareWell.Commands.Salud;
using CareWell.DataViews.Salud;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Queries.Salud;
using CareWell.Repository;
using CareWell.Repository.Salud;
using CareWell.Security;

namespace CareWell.BusinessService.Salud
{
    public class AdministrarFichaSaludBusinessService : BusinessService, IAdministrarFichaSaludBusinessService
    {
        private IUserContext UserContext { get; set; }
        private IBaseFactory BaseFactory { get; set; }
        private IEntityLoaderDomainService EntityLoaderDomainService { get; set; }
        private IFichaSaludRepository FichaSaludRepository { get; set; }
        private IValidadorPermisoAccion ValidadorPermisoAccion { get; set; }

        public AdministrarFichaSaludBusinessService(IUnitOfWork unitOfWork,
                                                    IUserContext userContext,
                                                    IBaseFactory baseFactory,
                                                    IEntityLoaderDomainService entityLoaderDomainService,
                                                    IFichaSaludRepository fichaSaludRepository,
                                                    IValidadorPermisoAccion validadorPermisoAccion)
            : base(unitOfWork)
        {
            this.UserContext = userContext;
            this.BaseFactory = baseFactory;
            this.EntityLoaderDomainService = entityLoaderDomainService;
            this.FichaSaludRepository = fichaSaludRepository;
            this.ValidadorPermisoAccion = validadorPermisoAccion;
        }

        public FichaSaludDataView Obtener(FichaSaludQuery query)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var persona = this.EntityLoaderDomainService.GetByID<Persona>(query.PersonaID);

            this.ValidadorPermisoAccion.ValidarPuedeVerFichaSalud(persona, usuario.Persona);

            return this.FichaSaludRepository.Obtener(query);
        }

        public void Crear(CrearFichaSaludCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);

            var crearFichaSalud = new CrearFichaSalud(
                Persona: this.EntityLoaderDomainService.GetByID<Persona>(command.PersonaID),
                Colaborador: usuario.Persona,
                FactorSanguineo: command.FactorSanguineo,
                ObraSocial: command.ObraSocial,
                Antecedentes: command.Antecedentes.Select(MapearAntecedentes).ToList(),
                Alergias: command.Alergias.Select(MapearAlergias).ToList(),
                Enfermedades: command.Enfermedades.Select(MapearEnfermedades).ToList(),
                Observaciones: command.Observaciones
            );

            var fichaSalud = this.BaseFactory.Crear<FichaSalud>();

            fichaSalud.Crear(crearFichaSalud,
                             this.ValidadorPermisoAccion,
                             this.BaseFactory);

            this.FichaSaludRepository.Add(fichaSalud);

            this.UnitOfWork.SaveChanges();
        }

        public void Modificar(ModificarFichaSaludCommand command)
        {
            var usuario = this.EntityLoaderDomainService.GetByID<Usuario>(this.UserContext.UsuarioID);
            var fichaSalud = this.FichaSaludRepository.GetByID(command.ID);

            var modificarFichaSalud = new ModificarFichaSalud(
                Colaborador: usuario.Persona,
                FactorSanguineo: command.FactorSanguineo,
                ObraSocial: command.ObraSocial,
                Antecedentes: command.Antecedentes.Select(MapearAntecedentes).ToList(),
                Alergias: command.Alergias.Select(MapearAlergias).ToList(),
                Enfermedades: command.Enfermedades.Select(MapearEnfermedades).ToList(),
                Observaciones: command.Observaciones
            );

            fichaSalud.Modificar(modificarFichaSalud,
                                 this.ValidadorPermisoAccion,
                                 this.BaseFactory);

            this.UnitOfWork.SaveChanges();
        }

        #region Metodos Privados

        private static AgregarAntecedente MapearAntecedentes(AgregarAntecedenteCommand antecedente)
        {
            return new AgregarAntecedente(
                ID: antecedente.ID,
                Nombre: antecedente.Nombre,
                Descripcion: antecedente.Descripcion,
                VinculoFamiliar: antecedente.VinculoFamiliar
            );
        }

        private static AgregarAlergia MapearAlergias(AgregarAlergiaCommand alergia)
        {
            return new AgregarAlergia(
                ID: alergia.ID,
                Nombre: alergia.Nombre,
                Reaccion: alergia.Reaccion,
                Medicamento: alergia.Medicamento
            );
        }

        private static AgregarEnfermedad MapearEnfermedades(AgregarEnfermedadCommand enfermedad)
        {
            return new AgregarEnfermedad(
                ID: enfermedad.ID,
                Nombre: enfermedad.Nombre,
                Vigente: enfermedad.Vigente,
                Observacion: enfermedad.Observacion
            );
        }

        #endregion
    }
}

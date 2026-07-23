using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.Factories;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Auth;
using CareWell.Global.Constantes.Auth;
using CareWell.Global.Enumeraciones.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using CareWell.Repository;
using CareWell.Repository.Auth;

namespace CareWell.BusinessService.Auth
{
    public class GestorCodigoVerificacionBusinessService : BusinessService, IGestorCodigoVerificacionDomainService
    {
        private ICodigoVerificacionRepository CodigoVerificacionRepository { get; set; }
        private IBaseFactory Factory { get; set; }
        private IPasswordHasherDomainService PasswordHasherDomainService { get; set; }
        private IGeneradorCodigoOtpDomainService GeneradorCodigoOtpDomainService { get; set; }
        private IValidadorLimiteEnvioCodigo ValidadorLimiteEnvioCodigo { get; set; }

        public GestorCodigoVerificacionBusinessService(IUnitOfWork unitOfWork,
                                                       ICodigoVerificacionRepository codigoVerificacionRepository,
                                                       IBaseFactory baseFactory,
                                                       IPasswordHasherDomainService passwordHasherDomainService,
                                                       IGeneradorCodigoOtpDomainService generadorCodigoOtpDomainService,
                                                       IValidadorLimiteEnvioCodigo validadorLimiteEnvioCodigo)
            : base(unitOfWork)
        {
            this.CodigoVerificacionRepository = codigoVerificacionRepository;
            this.Factory = baseFactory;
            this.PasswordHasherDomainService = passwordHasherDomainService;
            this.GeneradorCodigoOtpDomainService = generadorCodigoOtpDomainService;
            this.ValidadorLimiteEnvioCodigo = validadorLimiteEnvioCodigo;
        }

        public string EmitirCodigo(Usuario usuario, TipoCodigoVerificacionEnum tipo)
        {
            this.ValidadorLimiteEnvioCodigo.ValidarCantidadEnviosUltimaHora(usuario);

            var codigoVigente = this.CodigoVerificacionRepository.GetVigentePorUsuario(usuario, tipo);

            if (codigoVigente is not null)
                codigoVigente.Consumir();

            var codigoGenerado = this.GeneradorCodigoOtpDomainService.Generar();

            var crearCodigo = new CrearCodigoVerificacion(
                Usuario: usuario,
                Tipo: tipo,
                CodigoHash: this.PasswordHasherDomainService.Hashear(codigoGenerado),
                Expiracion: DateTime.Now.AddMinutes(ParametrosVerificacionCodigo.MinutosExpiracion)
            );

            var codigoVerificacion = this.Factory.Crear<CodigoVerificacion>();
            codigoVerificacion.Crear(crearCodigo);

            this.CodigoVerificacionRepository.Add(codigoVerificacion);

            this.UnitOfWork.SaveChanges();

            return codigoGenerado;
        }

        public void ValidarYConsumir(Usuario usuario, TipoCodigoVerificacionEnum tipo, string codigoIngresado)
        {
            var codigo = this.CodigoVerificacionRepository.GetVigentePorUsuario(usuario, tipo);

            if (codigo is null)
                throw new ValidacionDominioException(Mensajes.CodigoVerificacionInvalido);

            try
            {
                codigo.Verificar(codigoIngresado, this.PasswordHasherDomainService);
            }
            catch
            {
                this.UnitOfWork.SaveChanges();
                throw;
            }
        }
    }
}

using CareWell.BusinessService.Auth;
using CareWell.Domain.Auth;
using CareWell.Domain.DomainServices.Auth;
using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Auth;
using CareWell.Global.Enumeraciones.Auth;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using CareWell.Repository.Auth;
using Moq;

namespace CareWell.BusinessService.Test.Auth
{
    public class GestorCodigoVerificacionBusinessTest : BusinessTestClassBase<GestorCodigoVerificacionBusinessService>
    {
        private Mock<ICodigoVerificacionRepository> codigoVerificacionRepository;
        private Mock<IBaseFactory> baseFactory;
        private Mock<IPasswordHasherDomainService> passwordHasherDomainService;
        private Mock<IGeneradorCodigoOtpDomainService> generadorCodigoOtpDomainService;
        private Mock<IValidadorLimiteEnvioCodigo> validadorLimiteEnvioCodigo;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.codigoVerificacionRepository = new Mock<ICodigoVerificacionRepository>();
            this.baseFactory = new Mock<IBaseFactory>();
            this.passwordHasherDomainService = new Mock<IPasswordHasherDomainService>();
            this.generadorCodigoOtpDomainService = new Mock<IGeneradorCodigoOtpDomainService>();
            this.validadorLimiteEnvioCodigo = new Mock<IValidadorLimiteEnvioCodigo>();

            this.Target = new GestorCodigoVerificacionBusinessService(
                this.unitOfWork.Object,
                this.codigoVerificacionRepository.Object,
                this.baseFactory.Object,
                this.passwordHasherDomainService.Object,
                this.generadorCodigoOtpDomainService.Object,
                this.validadorLimiteEnvioCodigo.Object
            );
        }

        public class ElMetodo_EmitirCodigo : GestorCodigoVerificacionBusinessTest
        {
            private Usuario usuario;
            private TipoCodigoVerificacionEnum tipo;
            private Mock<CodigoVerificacion> codigoVerificacion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.usuario = Mock.Of<Usuario>(u =>
                    u.NombreUsuario == "mail@algo.com" &&
                    u.Persona == Mock.Of<Persona>(p => p.Nombre == "Persona X")
                );

                this.tipo = TipoCodigoVerificacionEnum.VerificacionEmail;

                this.codigoVerificacion = new Mock<CodigoVerificacion>();

                this.baseFactory.Setup(s => s.Crear<CodigoVerificacion>()).Returns(this.codigoVerificacion.Object);
            }

            private string Action()
            {
                return this.Target.EmitirCodigo(this.usuario, this.tipo);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarCantidadEnviosUltimaHora_del_ValidadorLimiteEnvioEmail()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorLimiteEnvioCodigo.Verify(v => v.ValidarCantidadEnviosUltimaHora(this.usuario), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetVigentePorUsuario_del_CodigoVerificacionRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.codigoVerificacionRepository.Verify(v => v.GetVigentePorUsuario(this.usuario, this.tipo), Times.Once);
            }

            [Fact]
            public void Si_existia_un_codigo_vigente_para_el_usuario_llama_al_Consumir_del_mismo()
            {
                // Arrange
                this.codigoVerificacionRepository.Setup(s => s.GetVigentePorUsuario(this.usuario, this.tipo)).Returns(this.codigoVerificacion.Object);

                // Action
                this.Action();

                // Assert
                this.codigoVerificacion.Verify(v => v.Consumir(), Times.Once);
            }

            [Fact]
            public void Si_se_encuentra_el_usuario_llama_una_vez_al_metodo_Generar_del_CodigoVerificacionRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.generadorCodigoOtpDomainService.Verify(v => v.Generar(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Hashear_del_PasswordHasherDomainService()
            {
                // Arrange
                var codigoGenerado = "Codigo X";
                this.generadorCodigoOtpDomainService.Setup(s => s.Generar()).Returns(codigoGenerado);

                // Action
                this.Action();

                // Assert
                this.passwordHasherDomainService.Verify(v => v.Hashear(codigoGenerado), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_CodigoVerificacion_de_la_Factory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<CodigoVerificacion>(), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Crear_del_CodigoVerificacion()
            {
                // Arrange
                var codigoHash = "Codigo Hasheado";
                this.passwordHasherDomainService.Setup(s => s.Hashear(It.IsAny<string>())).Returns(codigoHash);

                // Action
                this.Action();

                // Assert
                this.codigoVerificacion.Verify(v => v.Crear(It.Is<CrearCodigoVerificacion>(c =>
                    c.Usuario == this.usuario &&
                    c.Tipo == this.tipo &&
                    c.CodigoHash == codigoHash
                )), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Add_del_CodigoVerificacionRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.codigoVerificacionRepository.Verify(v => v.Add(this.codigoVerificacion.Object), Times.Once);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_SaveChanges_del_UnitOfWork()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.unitOfWork.Verify(v => v.SaveChanges(), Times.Once);
            }

            [Fact]
            public void Retorna_el_codigo_generado()
            {
                // Arrange
                var codigoGenerado = "Codigo X";
                this.generadorCodigoOtpDomainService.Setup(s => s.Generar()).Returns(codigoGenerado);

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(codigoGenerado, resultado);
            }

            [Fact]
            public void Retorna_un_string()
            {
                // Arrange
                this.generadorCodigoOtpDomainService.Setup(s => s.Generar()).Returns("Codigo X");

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<string>(resultado);
            }
        }

        public class ElMetodo_ValidarYConsumir : GestorCodigoVerificacionBusinessTest
        {
            private Usuario usuario;
            private TipoCodigoVerificacionEnum tipo;
            private string codigoIngresado;
            private Mock<CodigoVerificacion> codigoVerificacion;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.usuario = Mock.Of<Usuario>(u => u.ID == 1);
                this.tipo = TipoCodigoVerificacionEnum.VerificacionEmail;
                this.codigoIngresado = "Codigo X";

                this.codigoVerificacion = new Mock<CodigoVerificacion>();

                this.codigoVerificacionRepository.Setup(s => s.GetVigentePorUsuario(It.IsAny<Usuario>(), It.IsAny<TipoCodigoVerificacionEnum>())).Returns(this.codigoVerificacion.Object);
            }

            private void Action()
            {
                this.Target.ValidarYConsumir(this.usuario,
                                             this.tipo,
                                             this.codigoIngresado);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_GetVigentePorUsuario_del_CodigoVerificacionRepository()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.codigoVerificacionRepository.Verify(v => v.GetVigentePorUsuario(this.usuario, this.tipo), Times.Once);
            }

            [Fact]
            public void Si_no_se_encuentra_el_codigo_vigente_arroja_un_ValidacionDominioException_con_mensaje_de_codigo_incorrecto()
            {
                // Arrange
                this.codigoVerificacionRepository.Setup(v => v.GetVigentePorUsuario(this.usuario, this.tipo)).Returns((CodigoVerificacion?)null);

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.CodigoVerificacionInvalido, excepcion.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Verificar_del_CodigoVerificacion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.codigoVerificacion.Verify(v => v.Verificar(this.codigoIngresado, this.passwordHasherDomainService.Object), Times.Once);
            }

            [Fact]
            public void Si_se_produce_un_error_al_verificar_el_codigo_llama_al_SaveChanges_del_UnitOfWork_de_todas_formas()
            {
                // Arrange
                this.codigoVerificacion.Setup(v => v.Verificar(this.codigoIngresado, this.passwordHasherDomainService.Object)).Throws(new Exception());

                // Action & Assert
                Assert.Throws<Exception>(() => this.Action());
                this.unitOfWork.Verify(v => v.SaveChanges(), Times.Once);
            }
        }
    }
}

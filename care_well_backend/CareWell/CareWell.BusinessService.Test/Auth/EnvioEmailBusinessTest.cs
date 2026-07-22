using CareWell.BusinessService.Auth;
using CareWell.Commands.Auth;
using CareWell.Global.Mensajes;
using CareWell.Notifications.Email;
using Moq;

namespace CareWell.BusinessService.Test.Auth
{
    public class EnvioEmailBusinessTest : BusinessTestClassBase<EnvioEmailBusinessService>
    {
        private Mock<IEmailSender> emailSender;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.emailSender = new Mock<IEmailSender>();

            this.Target = new EnvioEmailBusinessService(
                this.emailSender.Object
            );
        }

        public class ElMetodo_Enviar : EnvioEmailBusinessTest
        {
            private EnviarEmailCommand command;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.command = Mock.Of<EnviarEmailCommand>(e =>
                    e.Destinatario == "Destinatario" &&
                    e.NombreDestinatario == "Nombre" &&
                    e.Asunto == "Asunto X" &&
                    e.CuerpoHtml == "Cuerpo Y"
                );

                this.emailSender.Setup(s => s.Enviar(this.command.Destinatario, this.command.NombreDestinatario, this.command.Asunto, this.command.CuerpoHtml)).Returns(true);
            }

            private void Action()
            {
                this.Target.Enviar(this.command);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_Enviar_del_EmailSender()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.emailSender.Verify(v => v.Enviar(this.command.Destinatario, this.command.NombreDestinatario, this.command.Asunto, this.command.CuerpoHtml), Times.Once);
            }

            [Fact]
            public void Si_se_envio_correctamente_no_arroja_excepcion()
            {
                // Arrange

                // Action
                var excepcion = Record.Exception(() => this.Action());

                // Assert
                Assert.Null(excepcion);
            }

            [Fact]
            public void Si_no_se_envio_correctamente_arroja_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.emailSender.Setup(s => s.Enviar(this.command.Destinatario, this.command.NombreDestinatario, this.command.Asunto, this.command.CuerpoHtml)).Returns(false);

                // Action & Assert
                var excepcion = Assert.Throws<Exception>(() => this.Action());
                Assert.Equal(Mensajes.ErrorAlEnviarEmailPorFavorReintente, excepcion.Message);
            }
        }
    }
}

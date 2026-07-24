using CareWell.BusinessService.General;
using CareWell.DocumentIntelligence.ReconocedorTexto;
using CareWell.Domain.General;
using CareWell.Domain.ValueObjects.General;
using CareWell.Global.Exceptions;
using CareWell.Global.Extensions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.BusinessService.Test.General
{
    public class EvaluadorIdentidadPersonaBusinessTest : BusinessTestClassBase<EvaluadorIdentidadPersonaBusinessService>
    {
        private Mock<IReconocedorTextoDocumentoAgent> reconocedorTextoDocumentoAgent;

        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.reconocedorTextoDocumentoAgent = new Mock<IReconocedorTextoDocumentoAgent>();

            this.Target = new EvaluadorIdentidadPersonaBusinessService(
                this.reconocedorTextoDocumentoAgent.Object
            );
        }

        public class ElMetodo_EsIdentidadCorrecta : EvaluadorIdentidadPersonaBusinessTest
        {
            private Mock<Persona> persona;
            private byte[]? imagenDocumento;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.persona = new Mock<Persona>();
                this.persona.Setup(s => s.IdentidadValidada).Returns(true);

                this.imagenDocumento = new byte[8];

                this.reconocedorTextoDocumentoAgent.Setup(s => s.ExtraerTexto(It.IsAny<byte[]>())).Returns(Mock.Of<ReconocedorTextoDocumentoAgentResponse>());
            }

            private bool Action()
            {
                return this.Target.EsIdentidadCorrecta(this.persona.Object, this.imagenDocumento);
            }

            [Fact]
            public void Si_la_imagen_del_documento_es_nula_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.imagenDocumento = null;

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ImagenDocumentoRequerida, excepcion.Message);
            }

            [Fact]
            public void Si_la_imagen_del_documento_es_de_largo_cero_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.imagenDocumento = [];

                // Action & Assert
                var excepcion = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.ImagenDocumentoRequerida, excepcion.Message);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ExtraerTexto_del_ReconocedorTextoDocumentoAgent()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.reconocedorTextoDocumentoAgent.Verify(v => v.ExtraerTexto(this.imagenDocumento!), Times.Once);
            }

            [Fact]
            public void Si_la_respuesta_del_agente_es_nula_retorna_false()
            {
                // Arrange
                this.reconocedorTextoDocumentoAgent.Setup(s => s.ExtraerTexto(It.IsAny<byte[]>())).Returns((ReconocedorTextoDocumentoAgentResponse?)null);

                // Action 
                var resultado = this.Action();

                // Assert
                Assert.False(resultado);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarIdentidad_de_Persona()
            {
                // Arrange
                var respuestaAgente = Mock.Of<ReconocedorTextoDocumentoAgentResponse>(r =>
                    r.DNI == 12345678 &&
                    r.Nombre == "Esteban Agustín" &&
                    r.Apellido == "Robertiño"
                );
                this.reconocedorTextoDocumentoAgent.Setup(s => s.ExtraerTexto(this.imagenDocumento!)).Returns(respuestaAgente);

                // Action
                this.Action();

                // Assert
                this.persona.Verify(v => v.ValidarIdentidad(It.Is<TextoDocumentoReconocido>(t =>
                    t.NumeroDocumento == respuestaAgente.DNI.ToString() &&
                    t.Nombre == respuestaAgente.Nombre!.RemoveDiacritics() &&
                    t.Apellido == respuestaAgente.Apellido!.RemoveDiacritics()
                )), Times.Once);
            }

            [Fact]
            public void Retorna_el_valor_de_IdentidadValidada_de_Persona()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(this.persona.Object.IdentidadValidada, resultado);
            }

            [Fact]
            public void Retorna_un_bool()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<bool>(resultado);
            }
        }
    }
}

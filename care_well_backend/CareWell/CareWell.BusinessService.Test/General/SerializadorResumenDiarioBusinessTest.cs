using CareWell.BusinessService.General;
using CareWell.DataViews.General;
using Moq;
using System;
using System.Collections.Generic;
using System.Text;

namespace CareWell.BusinessService.Test.General
{
    public class SerializadorResumenDiarioBusinessTest : BusinessTestClassBase<SerializadorResumenDiario>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new SerializadorResumenDiario();
        }

        public class ElMetodo_Serializar : SerializadorResumenDiarioBusinessTest
        {
            private ResumenDiarioDataView resumenDiario;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.resumenDiario = Mock.Of<ResumenDiarioDataView>();
            }

            private string Action()
            {
                return this.Target.Serializar(this.resumenDiario);
            }

            [Fact]
            public void Retorna_un_string()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<string>(resultado);
            }
        }

        public class ElMetodo_Deserializar : SerializadorResumenDiarioBusinessTest
        {
            private string contenido;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.contenido = this.Target.Serializar(Mock.Of<ResumenDiarioDataView>());
            }

            private ResumenDiarioDataView? Action()
            {
                return this.Target.Deserializar(this.contenido);
            }

            [Theory]
            [InlineData(null)]
            [InlineData(" ")]
            public void Retorna_null_si_el_contenido_es_null_o_vacio(string? contenido)
            {
                // Assert
                this.contenido = contenido!;

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }

            [Fact]
            public void Retorna_una_instancia_del_tipo_ResumenDiarioDataView()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<ResumenDiarioDataView>(resultado);
            }

            [Fact]
            public void Retorna_null_si_hay_un_error_al_convertir()
            {
                // Arrange
                this.contenido = "{*]";

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }
        }
    }
}

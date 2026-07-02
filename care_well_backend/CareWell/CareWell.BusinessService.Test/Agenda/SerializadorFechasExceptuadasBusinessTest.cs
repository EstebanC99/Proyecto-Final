using CareWell.BusinessService.Agenda;
using System.Globalization;

namespace CareWell.BusinessService.Test.Agenda
{
    public class SerializadorFechasExceptuadasBusinessTest : BusinessTestClassBase<SerializadorFechasExceptuadasBusinessService>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new SerializadorFechasExceptuadasBusinessService();
        }

        public class ElMetodo_SerializarFechasExceptuadas : SerializadorFechasExceptuadasBusinessTest
        {
            private List<DateTime> fechas;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.fechas = new List<DateTime>
                {
                    DateTime.Now,
                    DateTime.Now.AddDays(1)
                };
            }

            private string? Action()
            {
                return this.Target.SerializarFechasExceptuadas(this.fechas);
            }

            [Fact]
            public void Retorna_null_si_la_lista_de_fechas_es_nula()
            {
                // Arrange
                this.fechas = null;

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }

            [Fact]
            public void Retorna_null_si_la_lista_de_fechas_esta_vacia()
            {
                // Arrange
                this.fechas.Clear();

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Null(resultado);
            }

            [Fact]
            public void Retorna_string_con_fechas_serializadas_si_la_lista_de_fechas_no_es_nula_ni_vacia()
            {
                // Arrange

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Contains(this.fechas[0].ToString("O"), resultado);
                Assert.Contains(this.fechas[1].ToString("O"), resultado);
            }

            [Fact]
            public void Retorna_un_string_con_tal_formato()
            {
                // Arrange
                var esperado = string.Join(";", this.fechas.Order().Select(f => f.ToString("O", CultureInfo.InvariantCulture)));

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equal(esperado, resultado);
            }

            [Fact]
            public void Retorna_un_string()
            {
                // Arrange 

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<string?>(resultado);
            }
        }

        public class ElMetodo_DeserializarFechasExceptuadas : SerializadorFechasExceptuadasBusinessTest
        {
            private string? fechasSerializadas;
            private List<DateTime> listaFechas;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                this.listaFechas = new List<DateTime>
                {
                    DateTime.Now,
                    DateTime.Now.AddDays(1)
                };

                this.fechasSerializadas = string.Join(";", this.listaFechas.Order().Select(f => f.ToString("O", CultureInfo.InvariantCulture)));
            }

            private List<DateTime> Action()
            {
                return this.Target.DeserializarFechasExceptuadas(this.fechasSerializadas);
            }

            [Fact]
            public void Retorna_una_lista_vacia_si_el_string_es_nulo()
            {
                // Arrange 
                this.fechasSerializadas = null;

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Empty(resultado);
            }

            [Fact]
            public void Retorna_una_lista_vacia_si_el_string_vacio()
            {
                // Arrange 
                this.fechasSerializadas = string.Empty;

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Empty(resultado);
            }

            [Fact]
            public void Retorna_una_lista_con_las_fechas_deserializadas_si_el_string_no_es_nulo_ni_vacio()
            {
                // Arrange 

                // Action
                var resultado = this.Action();

                // Assert
                Assert.Equivalent(this.listaFechas, resultado);
            }

            [Fact]
            public void Retorna_una_instancia_del_tipo_List_DateTime()
            {
                // Arrange 

                // Action
                var resultado = this.Action();

                // Assert
                Assert.IsType<List<DateTime>>(resultado);
            }
        }
    }
}

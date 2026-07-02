using CareWell.BusinessService.Helpers;
using CareWell.Global.Constantes.Agenda;
using CareWell.Global.Enumeraciones.Agenda;
using Ical.Net;
using Ical.Net.DataTypes;

namespace CareWell.BusinessService.Test.Helpers
{
    public class IcalNetHelperTest
    {
        public class ElMetodo_GetFrecuencyType : IcalNetHelperTest
        {
            private FrecuenciaRecurrenciaEnum frecuenciaRecurrenciaEnum;

            [Fact]
            public void Si_FrecuenciaRecurrenciaEnum_es_Diaria_retorna_FrequencyType_Daily()
            {
                // Arrange
                this.frecuenciaRecurrenciaEnum = FrecuenciaRecurrenciaEnum.Diaria;

                // Action
                var resultado = IcalNetHelper.GetFrecuencyType(this.frecuenciaRecurrenciaEnum);

                // Assert
                Assert.Equal(FrequencyType.Daily, resultado);
            }

            [Fact]
            public void Si_FrecuenciaRecurrenciaEnum_es_Semanal_retorna_FrequencyType_Weekly()
            {
                // Arrange
                this.frecuenciaRecurrenciaEnum = FrecuenciaRecurrenciaEnum.Semanal;

                // Action
                var resultado = IcalNetHelper.GetFrecuencyType(this.frecuenciaRecurrenciaEnum);

                // Assert
                Assert.Equal(FrequencyType.Weekly, resultado);
            }

            [Fact]
            public void Si_FrecuenciaRecurrenciaEnum_es_Mensual_retorna_FrequencyType_Monthly()
            {
                // Arrange
                this.frecuenciaRecurrenciaEnum = FrecuenciaRecurrenciaEnum.Mensual;

                // Action
                var resultado = IcalNetHelper.GetFrecuencyType(this.frecuenciaRecurrenciaEnum);

                // Assert
                Assert.Equal(FrequencyType.Monthly, resultado);
            }

            [Fact]
            public void Si_FrecuenciaRecurrenciaEnum_no_esta_entre_las_opciones_arroja_un_ArgumentOutOfRangeException()
            {
                // Arrange

                // Action & Assert
                var exception = Assert.Throws<ArgumentOutOfRangeException>(() => IcalNetHelper.GetFrecuencyType(this.frecuenciaRecurrenciaEnum));
            }
        }

        public class ElMetodo_DateTimeToCalDateTimeArgentina : IcalNetHelperTest
        {
            private DateTime fecha;
            private bool hasTime;

            [Fact]
            public void Retorna_un_CalDateTime_con_la_fecha_y_hora_en_zona_horaria_de_Argentina()
            {
                // Arrange
                this.fecha = new DateTime(2024, 6, 1, 10, 0, 0);
                this.hasTime = true;

                // Action
                var resultado = IcalNetHelper.DateTimeToCalDateTimeArgentina(this.fecha, this.hasTime);

                // Assert
                Assert.Equal(new CalDateTime(this.fecha, ZonasHorarias.Argentina, this.hasTime), resultado);
            }
        }

        public class ElMetodo_ParseRule : IcalNetHelperTest
        {
            private string regla;

            [Fact]
            public void Retorna_un_string_sin_el_prefijo_RRULE()
            {
                // Arrange
                this.regla = "RRULE:FREQ=DAILY;INTERVAL=2";

                // Action
                var resultado = IcalNetHelper.ParseRule(this.regla);

                // Assert
                Assert.Equal("FREQ=DAILY;INTERVAL=2", resultado);
            }
        }
    }
}

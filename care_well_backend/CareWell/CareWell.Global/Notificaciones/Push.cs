namespace CareWell.Global.Notificaciones
{
    public abstract class Push
    {
        #region Titulos

        public const string TituloEmergencia = "¡Emergencia!";

        #endregion

        #region Contenidos

        private const string CuerpoEmergencia = "{0} activó una alerta de emergencia para {1}.";

        #endregion

        #region Claves de Datos

        public const string ClaveTipo = "tipo";
        public const string ClaveEmergenciaID = "emergenciaId";
        public const string ClavePersonaID = "personaId";

        public const string TipoEmergencia = "EMERGENCIA";

        #endregion

        #region Metodos de Formateo

        public static string CuerpoEmergenciaFormat(string nombreActivador, string nombrePersona)
        {
            return string.Format(CuerpoEmergencia, nombreActivador, nombrePersona);
        }

        #endregion
    }
}

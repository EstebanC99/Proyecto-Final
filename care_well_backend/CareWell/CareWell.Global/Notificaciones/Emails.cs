namespace CareWell.Global.Notificaciones
{
    public abstract class Emails
    {
        #region Asuntos de Email

        public const string AsuntoCodigoVerificacionCareWell = "Tu código de verificación de CareWell";

        #endregion

        #region Contenidos de Email

        private const string CodigoVerificacionEmail =
              "<p>Tu código de verificación es: <strong>{0}</strong></p>"
            + "<p>Vence en {1} minutos.</p>";

        #endregion

        #region Metodos de Formateo de Contenido

        public static string CodigoVerificacionEmailFormat(string codigo, string tiempoVencimiento)
        {
            return string.Format(CodigoVerificacionEmail, codigo, tiempoVencimiento);
        }

        #endregion
    }
}

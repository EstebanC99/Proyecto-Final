namespace CareWell.Global.Notificaciones
{
    public abstract class Emails
    {
        #region Asuntos de Email

        public const string AsuntoCodigoVerificacionCareWell = "Tu código de verificación de CareWell";
        public const string AsuntoRestablecerContrasenaCareWell = "Restablecé tu contraseña de CareWell";

        #endregion

        #region Contenidos de Email

        private const string CodigoVerificacion =
              "<p>Tu código de verificación es: <strong>{0}</strong></p>"
            + "<p>Vence en {1} minutos.</p>";

        private const string RecuperacionContrasena =
              "<p>Tu código para restablecer la contraseña es: <strong>{0}</strong></p>"
            + "<p>Vence en {1} minutos.</p>"
            + "<p>Si no solicitaste este cambio, ignorá este correo.</p>";

        #endregion

        #region Metodos de Formateo de Contenido

        public static string CodigoVerificacionFormat(string codigo, string tiempoVencimiento)
        {
            return string.Format(CodigoVerificacion, codigo, tiempoVencimiento);
        }

        public static string RecuperacionContrasenaFormat(string codigo, string tiempoVencimiento)
        {
            return string.Format(RecuperacionContrasena, codigo, tiempoVencimiento);
        }

        #endregion
    }
}

using CareWell.Global.Constantes.Salud;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Salud.AlertasBienestar
{
    public class AlertaBienestar
    {
        public virtual string Tipo { get; private set; }

        public virtual string Severidad { get; private set; }

        public virtual string Categoria { get; private set; }

        public virtual string Mensaje { get; private set; }

        public virtual DateTime FechaDeteccion { get; private set; }

        public virtual HabitoVida? HabitoVida { get; private set; }

        public virtual void RegistrarAnimoBajoSostenido(string severidad, string nombrePersona, DateTime fechaReferencia)
        {
            this.Tipo = TiposAlertaBienestar.AnimoBajoSostenido;
            this.Severidad = severidad;
            this.Categoria = CategoriasAlertaBienestar.Animo;
            this.Mensaje = string.Format(Mensajes.AnimoBajoSostenido, nombrePersona, ParametrosDeteccionBienestar.MinRegistrosConsecutivosAnimoBajo);
            this.FechaDeteccion = fechaReferencia;
        }

        public virtual void RegistrarDeterioroAnimo(string nombrePersona, DateTime fechaReferencia)
        {
            this.Tipo = TiposAlertaBienestar.DeterioroAnimo;
            this.Severidad = SeveridadesAlertaBienestar.Media;
            this.Categoria = CategoriasAlertaBienestar.Animo;
            this.Mensaje = string.Format(Mensajes.DeterioroAnimo, nombrePersona);
            this.FechaDeteccion = fechaReferencia;
        }

        public virtual void RegistrarAbandonoHabito(int diasSinRegistrar, DateTime fechaReferencia, HabitoVida habitoVida)
        {
            this.Tipo = TiposAlertaBienestar.AbandonoHabito;
            this.Severidad = SeveridadesAlertaBienestar.Alta;
            this.Categoria = CategoriasAlertaBienestar.Habito;
            this.Mensaje = string.Format(Mensajes.AbandonoHabito, diasSinRegistrar, habitoVida.Descripcion, habitoVida.Persona.Nombre);
            this.FechaDeteccion = fechaReferencia;
            this.HabitoVida = habitoVida;
        }

        public virtual void RegistrarCaidaCumplimientoHabito(DateTime fechaReferencia, HabitoVida habitoVida)
        {
            this.Tipo = TiposAlertaBienestar.CaidaCumplimiento;
            this.Severidad = SeveridadesAlertaBienestar.Media;
            this.Categoria = CategoriasAlertaBienestar.Habito;
            this.Mensaje = string.Format(Mensajes.CaidaCumplimientoHabito, habitoVida.Descripcion, habitoVida.Persona.Nombre);
            this.FechaDeteccion = fechaReferencia;
            this.HabitoVida = habitoVida;
        }
    }
}

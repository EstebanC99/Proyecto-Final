namespace CareWell.Global.Constantes.EquipoCuidado
{
    public abstract class PermisosCuidado
    {
        public const int VerFichaSalud = (int)PermisosCuidadoEnum.VerFichaSalud;
        public const int EditarFichaSalud = (int)PermisosCuidadoEnum.EditarFichaSalud;
        public const int GestionarAgenda = (int)PermisosCuidadoEnum.GestionarAgenda;
        public const int RegistrarEventosSalud = (int)PermisosCuidadoEnum.RegistrarEventosSalud;
        public const int RegistrarHabitos = (int)PermisosCuidadoEnum.RegistrarHabitos;
        public const int ActivarEmergencia = (int)PermisosCuidadoEnum.ActivarEmergencia;
        public const int AdministrarEquipo = (int)PermisosCuidadoEnum.AdministrarEquipo;

        private enum PermisosCuidadoEnum
        {
            VerFichaSalud = 1,
            EditarFichaSalud = 2,
            GestionarAgenda = 3,
            RegistrarEventosSalud = 4,
            RegistrarHabitos = 5,
            ActivarEmergencia = 6,
            AdministrarEquipo = 7,
        }
    }
}

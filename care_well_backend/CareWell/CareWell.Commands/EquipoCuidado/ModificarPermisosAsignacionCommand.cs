namespace CareWell.Commands.EquipoCuidado
{
    public class ModificarPermisosAsignacionCommand
    {
        public ModificarPermisosAsignacionCommand()
        {
            this.PermisosIDs = new List<int>();
        }

        public int AsignacionCuidadoID { get; set; }

        public List<int> PermisosIDs { get; set; }
    }
}

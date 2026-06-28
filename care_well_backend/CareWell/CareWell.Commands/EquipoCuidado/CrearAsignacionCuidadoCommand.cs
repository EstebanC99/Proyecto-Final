namespace CareWell.Commands.EquipoCuidado
{
    public class CrearAsignacionCuidadoCommand
    {
        public CrearAsignacionCuidadoCommand()
        {
            this.PermisosIDs = new List<int>();
        }

        public int PersonaCuidadaID { get; set; }

        public string ColaboradorEmail { get; set; }

        public int RolCuidadoID { get; set; }

        public List<int> PermisosIDs { get; set; }
    }
}

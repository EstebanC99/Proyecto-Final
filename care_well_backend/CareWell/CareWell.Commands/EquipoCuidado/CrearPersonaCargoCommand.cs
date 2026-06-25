namespace CareWell.Commands.EquipoCuidado
{
    public class CrearPersonaCargoCommand
    {
        public virtual string Nombre { get; set; }

        public virtual string Apellido { get; set; }

        public virtual string Documento { get; set; }

        public virtual DateTime FechaNacimiento { get; set; }

        public virtual string? Email { get; set; }

        public virtual string? Telefono { get; set; }
    }
}

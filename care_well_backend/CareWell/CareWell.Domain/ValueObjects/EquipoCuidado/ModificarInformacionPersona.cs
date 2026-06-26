using CareWell.Domain.Auth;
using CareWell.Domain.ValueObjects.General;
using System;
using System.Collections.Generic;
using System.Text;

namespace CareWell.Domain.ValueObjects.EquipoCuidado
{
    public record ModificarInformacionPersona(
        string Nombre,
        string Apellido,
        string Documento,
        DateTime FechaNacimiento,
        string? Email,
        string? Telefono,
        Usuario UsuarioModificador
        ) 
        : CrearModificarPersona(
        Nombre,
        Apellido,
        Documento,
        FechaNacimiento,
        Email,
        Telefono);
}

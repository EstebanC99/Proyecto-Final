using CareWell.Domain.General;

namespace CareWell.Domain.ValueObjects.Salud
{
    public record CrearFichaSalud(
        Persona Persona,
        Persona Colaborador,
        string FactorSanguineo,
        string? ObraSocial,
        List<AgregarAntecedente> Antecedentes,
        List<AgregarAlergia> Alergias,
        List<AgregarEnfermedad> Enfermedades,
        string? Observaciones
    ) :
    ModificarFichaSalud(
        Colaborador,
        FactorSanguineo,
        ObraSocial,
        Antecedentes,
        Alergias,
        Enfermedades,
        Observaciones
    );
}

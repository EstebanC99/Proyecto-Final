using CareWell.Domain.General;

namespace CareWell.Domain.ValueObjects.Salud
{
    public record ModificarFichaSalud(
        Persona Colaborador,
        string FactorSanguineo,
        string? ObraSocial,
        List<AgregarAntecedente> Antecedentes,
        List<AgregarAlergia> Alergias,
        List<AgregarEnfermedad> Enfermedades,
        string? Observaciones
    );
}

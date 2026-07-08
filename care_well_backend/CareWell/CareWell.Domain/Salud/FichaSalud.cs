using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;

namespace CareWell.Domain.Salud
{
    public class FichaSalud : BaseEntity
    {
        public virtual Persona Persona { get; private set; }

        public virtual string FactorSanguineo { get; private set; }

        public virtual string? ObraSocial { get; private set; }

        public virtual List<FichaSaludAntecedente> Antecedentes { get; private set; }

        public virtual List<FichaSaludAlergia> Alergias { get; private set; }

        public virtual List<FichaSaludEnfermedad> Enfermedades { get; private set; }

        public virtual string? Observaciones { get; private set; }

        public FichaSalud()
        {
            this.Antecedentes = new List<FichaSaludAntecedente>();
            this.Alergias = new List<FichaSaludAlergia>();
            this.Enfermedades = new List<FichaSaludEnfermedad>();
        }

        public virtual void Crear(CrearFichaSalud crearFichaSalud,
                                  IValidadorPermisoAccion validadorPermisoAccion,
                                  IBaseFactory baseFactory)
        {
            validadorPermisoAccion.ValidarPuedeAdministrarFichaSalud(crearFichaSalud.Persona, crearFichaSalud.Colaborador);

            if (crearFichaSalud.Persona is null)
                throw new ValidacionDominioException(Mensajes.PersonaNoExiste);

            if (string.IsNullOrEmpty(crearFichaSalud.FactorSanguineo))
                throw new ValidacionDominioException(Mensajes.FactorSanguineoRequerido);

            this.Persona = crearFichaSalud.Persona;

            this.SetearCampos(crearFichaSalud, baseFactory);
        }

        public virtual void Modificar(ModificarFichaSalud modificarFichaSalud,
                                      IValidadorPermisoAccion validadorPermisoAccion,
                                      IBaseFactory baseFactory)
        {
            validadorPermisoAccion.ValidarPuedeAdministrarFichaSalud(this.Persona, modificarFichaSalud.Colaborador);

            if (string.IsNullOrEmpty(modificarFichaSalud.FactorSanguineo))
                throw new ValidacionDominioException(Mensajes.FactorSanguineoRequerido);

            this.SetearCampos(modificarFichaSalud, baseFactory);
        }

        #region Metodos Privados

        private void SetearCampos(ModificarFichaSalud modificarFichaSalud, IBaseFactory baseFactory)
        {
            this.FactorSanguineo = modificarFichaSalud.FactorSanguineo;
            this.ObraSocial = modificarFichaSalud.ObraSocial;
            this.Observaciones = modificarFichaSalud.Observaciones;

            this.RegistrarAntecedentes(modificarFichaSalud.Antecedentes, baseFactory);
            this.RegistrarAlergias(modificarFichaSalud.Alergias, baseFactory);
            this.RegistrarEnfermedades(modificarFichaSalud.Enfermedades, baseFactory);
        }

        private void RegistrarAntecedentes(List<AgregarAntecedente> antecedentesInformados,
                                           IBaseFactory baseFactory)
        {
            foreach (var antecedenteInformado in antecedentesInformados)
            {
                var antecedente = baseFactory.Crear<FichaSaludAntecedente>();

                if (antecedenteInformado.ID != default)
                    antecedente = this.Antecedentes.First(a => a.ID == antecedenteInformado.ID);

                antecedente.Registrar(antecedenteInformado, this);

                if (antecedente.IsTransient())
                    this.Antecedentes.Add(antecedente);
            }

            var antecedentesEliminar = new List<FichaSaludAntecedente>();

            foreach (var antecedente in this.Antecedentes)
            {
                if (!antecedentesInformados.Any(a => a.ID == antecedente.ID))
                    antecedentesEliminar.Add(antecedente);
            }

            antecedentesEliminar.ForEach(a => this.Antecedentes.Remove(a));
        }

        private void RegistrarAlergias(List<AgregarAlergia> alergiasInformadas,
                                       IBaseFactory baseFactory)
        {
            foreach (var alergiaInformada in alergiasInformadas)
            {
                var alergia = baseFactory.Crear<FichaSaludAlergia>();

                if (alergiaInformada.ID != default)
                    alergia = this.Alergias.First(a => a.ID == alergiaInformada.ID);

                alergia.Registrar(alergiaInformada, this);

                if (alergia.IsTransient())
                    this.Alergias.Add(alergia);
            }

            var alergiasEliminar = new List<FichaSaludAlergia>();

            foreach (var alergia in this.Alergias)
            {
                if (!alergiasInformadas.Any(a => a.ID == alergia.ID))
                    alergiasEliminar.Add(alergia);
            }

            alergiasEliminar.ForEach(a => this.Alergias.Remove(a));
        }

        private void RegistrarEnfermedades(List<AgregarEnfermedad> enfermedadesInformadas,
                                           IBaseFactory baseFactory)
        {
            foreach (var enfermedadInformada in enfermedadesInformadas)
            {
                var enfermedad = baseFactory.Crear<FichaSaludEnfermedad>();

                if (enfermedadInformada.ID != default)
                    enfermedad = this.Enfermedades.First(e => e.ID == enfermedadInformada.ID);

                enfermedad.Registrar(enfermedadInformada, this);

                if (enfermedad.IsTransient())
                    this.Enfermedades.Add(enfermedad);
            }

            var enfermedadesEliminar = new List<FichaSaludEnfermedad>();

            foreach (var enfermedad in this.Enfermedades)
            {
                if (!enfermedadesInformadas.Any(e => e.ID == enfermedad.ID))
                    enfermedadesEliminar.Add(enfermedad);
            }

            enfermedadesEliminar.ForEach(e => this.Enfermedades.Remove(e));
        }

        #endregion
    }
}

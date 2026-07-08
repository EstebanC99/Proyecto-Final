using CareWell.Domain.Factories;
using CareWell.Domain.General;
using CareWell.Domain.Salud;
using CareWell.Domain.Validadores;
using CareWell.Domain.ValueObjects.Salud;
using CareWell.Global.Exceptions;
using CareWell.Global.Mensajes;
using Moq;

namespace CareWell.Domain.Test.Salud
{
    public class FichaSaludTest : TestClassBase<FichaSalud>
    {
        protected override void InitializeTest()
        {
            base.InitializeTest();

            this.Target = new FichaSalud();
        }

        public class ElMetodo_Crear : FichaSaludTest
        {
            private CrearFichaSalud crearFichaSalud;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
            private Mock<IBaseFactory> baseFactory;
            private Mock<FichaSaludAntecedente> antecedente;
            private Mock<FichaSaludAlergia> alergia;
            private Mock<FichaSaludEnfermedad> enfermedad;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                var agregarAntecedente = new AgregarAntecedente(
                    ID: 0,
                    Nombre: "",
                    Descripcion: "",
                    VinculoFamiliar: ""
                );

                var agregarAlergia = new AgregarAlergia(
                    ID: 0,
                    Nombre: "",
                    Reaccion: "",
                    Medicamento: ""
                );

                var agregarEnfermedad = new AgregarEnfermedad(
                    ID: 0,
                    Nombre: "",
                    Vigente: true,
                    Observacion: ""
                );

                this.crearFichaSalud = new CrearFichaSalud(
                    Persona: Mock.Of<Persona>(),
                    Colaborador: Mock.Of<Persona>(),
                    FactorSanguineo: "A+",
                    ObraSocial: "Osde",
                    Antecedentes: new List<AgregarAntecedente> { agregarAntecedente },
                    Alergias: new List<AgregarAlergia> { agregarAlergia },
                    Enfermedades: new List<AgregarEnfermedad> { agregarEnfermedad },
                    Observaciones: "Obs"
                );

                this.antecedente = new Mock<FichaSaludAntecedente>();
                this.antecedente.Setup(s => s.IsTransient()).Returns(true);

                this.alergia = new Mock<FichaSaludAlergia>();
                this.alergia.Setup(s => s.IsTransient()).Returns(true);

                this.enfermedad = new Mock<FichaSaludEnfermedad>();
                this.enfermedad.Setup(s => s.IsTransient()).Returns(true);

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();

                this.baseFactory = new Mock<IBaseFactory>();
                this.baseFactory.Setup(s => s.Crear<FichaSaludAntecedente>()).Returns(this.antecedente.Object);
                this.baseFactory.Setup(s => s.Crear<FichaSaludAlergia>()).Returns(this.alergia.Object);
                this.baseFactory.Setup(s => s.Crear<FichaSaludEnfermedad>()).Returns(this.enfermedad.Object);
            }

            private void Action()
            {
                this.Target.Crear(this.crearFichaSalud,
                                  this.validadorPermisoAccion.Object,
                                  this.baseFactory.Object);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarPuedeAdministrarFichaSalud_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeAdministrarFichaSalud(this.crearFichaSalud.Persona, this.crearFichaSalud.Colaborador), Times.Once);
            }

            [Fact]
            public void Si_la_Persona_es_nulo_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearFichaSalud = this.crearFichaSalud with { Persona = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.PersonaNoExiste, exception.Message);
            }

            [Fact]
            public void Si_el_FactorSanguineo_es_nulo_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.crearFichaSalud = this.crearFichaSalud with { FactorSanguineo = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.FactorSanguineoRequerido, exception.Message);
            }

            [Fact]
            public void Setea_la_propiedad_Persona()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Same(this.crearFichaSalud.Persona, this.Target.Persona);
            }

            [Fact]
            public void Setea_la_propiedad_FactorSanguineo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearFichaSalud.FactorSanguineo, this.Target.FactorSanguineo);
            }

            [Fact]
            public void Setea_la_propiedad_ObraSocial()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearFichaSalud.ObraSocial, this.Target.ObraSocial);
            }

            [Fact]
            public void Setea_la_propiedad_Observaciones()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.crearFichaSalud.Observaciones, this.Target.Observaciones);
            }

            [Fact]
            public void Llama_al_metodo_Crear_FichaSaludAntecedente_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<FichaSaludAntecedente>(), Times.Once);
            }

            [Fact]
            public void Llama_al_metodo_registrar_del_Antecedente_creado_por_la_factory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.antecedente.Verify(v => v.Registrar(It.IsAny<AgregarAntecedente>(), this.Target), Times.Once);
            }

            [Fact]
            public void Agrega_el_Antecedente_a_la_lista_de_antecedentes()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Contains(this.antecedente.Object, this.Target.Antecedentes);
            }

            [Fact]
            public void Llama_al_metodo_Crear_FichaSaludAlergia_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<FichaSaludAlergia>(), Times.Once);
            }

            [Fact]
            public void Llama_al_metodo_registrar_del_Alergia_creado_por_la_factory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.alergia.Verify(v => v.Registrar(It.IsAny<AgregarAlergia>(), this.Target), Times.Once);
            }

            [Fact]
            public void Agrega_la_Alergia_a_la_lista_de_alergias()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Contains(this.alergia.Object, this.Target.Alergias);
            }

            [Fact]
            public void Llama_al_metodo_Crear_FichaSaludEnfermedad_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<FichaSaludEnfermedad>(), Times.Once);
            }

            [Fact]
            public void Llama_al_metodo_registrar_del_Enfermedad_creado_por_la_factory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.enfermedad.Verify(v => v.Registrar(It.IsAny<AgregarEnfermedad>(), this.Target), Times.Once);
            }

            [Fact]
            public void Agrega_la_Enfermedad_a_la_lista_de_enfermedades()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Contains(this.enfermedad.Object, this.Target.Enfermedades);
            }
        }

        public class ElMetodo_Modificar : FichaSaludTest
        {
            private ModificarFichaSalud modificarFichaSalud;
            private Mock<IValidadorPermisoAccion> validadorPermisoAccion;
            private Mock<IBaseFactory> baseFactory;
            private Mock<FichaSaludAntecedente> antecedente;
            private Mock<FichaSaludAlergia> alergia;
            private Mock<FichaSaludEnfermedad> enfermedad;

            protected override void InitializeTest()
            {
                base.InitializeTest();

                var agregarAntecedente = new AgregarAntecedente(
                    ID: 0,
                    Nombre: "",
                    Descripcion: "",
                    VinculoFamiliar: ""
                );

                var agregarAlergia = new AgregarAlergia(
                    ID: 0,
                    Nombre: "",
                    Reaccion: "",
                    Medicamento: ""
                );

                var agregarEnfermedad = new AgregarEnfermedad(
                    ID: 0,
                    Nombre: "",
                    Vigente: true,
                    Observacion: ""
                );

                this.modificarFichaSalud = new ModificarFichaSalud(
                    Colaborador: Mock.Of<Persona>(),
                    FactorSanguineo: "A+",
                    ObraSocial: "Osde",
                    Antecedentes: new List<AgregarAntecedente> { agregarAntecedente },
                    Alergias: new List<AgregarAlergia> { agregarAlergia },
                    Enfermedades: new List<AgregarEnfermedad> { agregarEnfermedad },
                    Observaciones: "Obs"
                );

                this.antecedente = new Mock<FichaSaludAntecedente>();
                this.antecedente.Setup(s => s.IsTransient()).Returns(true);

                this.alergia = new Mock<FichaSaludAlergia>();
                this.alergia.Setup(s => s.IsTransient()).Returns(true);

                this.enfermedad = new Mock<FichaSaludEnfermedad>();
                this.enfermedad.Setup(s => s.IsTransient()).Returns(true);

                this.validadorPermisoAccion = new Mock<IValidadorPermisoAccion>();

                this.baseFactory = new Mock<IBaseFactory>();
                this.baseFactory.Setup(s => s.Crear<FichaSaludAntecedente>()).Returns(this.antecedente.Object);
                this.baseFactory.Setup(s => s.Crear<FichaSaludAlergia>()).Returns(this.alergia.Object);
                this.baseFactory.Setup(s => s.Crear<FichaSaludEnfermedad>()).Returns(this.enfermedad.Object);
            }

            private void Action()
            {
                this.Target.Modificar(this.modificarFichaSalud,
                                      this.validadorPermisoAccion.Object,
                                      this.baseFactory.Object);
            }

            [Fact]
            public void Llama_una_vez_al_metodo_ValidarPuedeAdministrarFichaSalud_del_ValidadorPermisoAccion()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.validadorPermisoAccion.Verify(v => v.ValidarPuedeAdministrarFichaSalud(this.Target.Persona, this.modificarFichaSalud.Colaborador), Times.Once);
            }

            [Fact]
            public void Si_el_FactorSanguineo_es_nulo_arroja_un_ValidacionDominioException_con_mensaje_informativo()
            {
                // Arrange
                this.modificarFichaSalud = this.modificarFichaSalud with { FactorSanguineo = null };

                // Action & Assert
                var exception = Assert.Throws<ValidacionDominioException>(() => this.Action());
                Assert.Equal(Mensajes.FactorSanguineoRequerido, exception.Message);
            }

            [Fact]
            public void Setea_la_propiedad_FactorSanguineo()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.modificarFichaSalud.FactorSanguineo, this.Target.FactorSanguineo);
            }

            [Fact]
            public void Setea_la_propiedad_ObraSocial()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.modificarFichaSalud.ObraSocial, this.Target.ObraSocial);
            }

            [Fact]
            public void Setea_la_propiedad_Observaciones()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Equal(this.modificarFichaSalud.Observaciones, this.Target.Observaciones);
            }

            [Fact]
            public void Llama_al_metodo_Crear_FichaSaludAntecedente_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<FichaSaludAntecedente>(), Times.Once);
            }

            [Fact]
            public void Si_el_Antecedente_es_nuevo_llama_al_metodo_registrar_del_creado_por_la_factory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.antecedente.Verify(v => v.Registrar(It.IsAny<AgregarAntecedente>(), this.Target), Times.Once);
            }

            [Fact]
            public void Si_el_Antecedente_no_es_nuevo_llama_al_metodo_registrar_del_existente()
            {
                // Arrange
                var antecedenteExistente = new Mock<FichaSaludAntecedente>();
                antecedenteExistente.Setup(s => s.ID).Returns(1);
                this.Target.Antecedentes.Add(antecedenteExistente.Object);

                var agregarAntecedente = new AgregarAntecedente(
                    ID: antecedenteExistente.Object.ID,
                    Nombre: "",
                    Descripcion: "",
                    VinculoFamiliar: ""
                );
                this.modificarFichaSalud = this.modificarFichaSalud with { Antecedentes = new List<AgregarAntecedente> { agregarAntecedente } };

                // Action
                this.Action();

                // Assert
                antecedenteExistente.Verify(v => v.Registrar(It.IsAny<AgregarAntecedente>(), this.Target), Times.Once);
            }

            [Fact]
            public void Si_el_Antecedente_es_nuevo_lo_agrega_a_la_lista_de_antecedentes()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Contains(this.antecedente.Object, this.Target.Antecedentes);
            }

            [Fact]
            public void Si_el_Antecedente_no_es_nuevo_no_vuelve_a_agregarlo_a_la_lista()
            {
                // Arrange
                var antecedenteExistente = new Mock<FichaSaludAntecedente>();
                antecedenteExistente.Setup(s => s.ID).Returns(1);
                this.Target.Antecedentes.Add(antecedenteExistente.Object);

                var agregarAntecedente = new AgregarAntecedente(
                    ID: antecedenteExistente.Object.ID,
                    Nombre: "",
                    Descripcion: "",
                    VinculoFamiliar: ""
                );
                this.modificarFichaSalud = this.modificarFichaSalud with { Antecedentes = new List<AgregarAntecedente> { agregarAntecedente } };

                // Action
                this.Action();

                // Assert
                Assert.Equal(1, this.Target.Antecedentes.Count(a => a.ID == antecedenteExistente.Object.ID));
            }

            [Fact]
            public void Llama_al_metodo_Crear_FichaSaludAlergia_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<FichaSaludAlergia>(), Times.Once);
            }

            [Fact]
            public void Si_la_Alergia_es_nueva_llama_al_metodo_registrar_del_creado_por_la_factory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.alergia.Verify(v => v.Registrar(It.IsAny<AgregarAlergia>(), this.Target), Times.Once);
            }

            [Fact]
            public void Si_la_Alergia_no_es_nueva_llama_al_metodo_registrar_del_existente()
            {
                // Arrange
                var alergiaExistente = new Mock<FichaSaludAlergia>();
                alergiaExistente.Setup(s => s.ID).Returns(1);
                this.Target.Alergias.Add(alergiaExistente.Object);

                var agregarAlergia = new AgregarAlergia(
                    ID: alergiaExistente.Object.ID,
                    Nombre: "",
                    Reaccion: "",
                    Medicamento: ""
                );
                this.modificarFichaSalud = this.modificarFichaSalud with { Alergias = new List<AgregarAlergia> { agregarAlergia } };

                // Action
                this.Action();

                // Assert
                alergiaExistente.Verify(v => v.Registrar(It.IsAny<AgregarAlergia>(), this.Target), Times.Once);
            }

            [Fact]
            public void Si_la_Alergia_es_nueva_la_agrega_a_la_lista_de_alergias()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Contains(this.alergia.Object, this.Target.Alergias);
            }

            [Fact]
            public void Si_la_Alergia_no_es_nueva_no_vuelve_a_agregarla_a_la_lista()
            {
                // Arrange
                var alergiaExistente = new Mock<FichaSaludAlergia>();
                alergiaExistente.Setup(s => s.ID).Returns(1);
                this.Target.Alergias.Add(alergiaExistente.Object);

                var agregarAlergia = new AgregarAlergia(
                    ID: alergiaExistente.Object.ID,
                    Nombre: "",
                    Reaccion: "",
                    Medicamento: ""
                );
                this.modificarFichaSalud = this.modificarFichaSalud with { Alergias = new List<AgregarAlergia> { agregarAlergia } };

                // Action
                this.Action();

                // Assert
                Assert.Equal(1, this.Target.Alergias.Count(a => a.ID == alergiaExistente.Object.ID));
            }

            [Fact]
            public void Llama_al_metodo_Crear_FichaSaludEnfermedad_del_BaseFactory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.baseFactory.Verify(v => v.Crear<FichaSaludEnfermedad>(), Times.Once);
            }

            [Fact]
            public void Si_la_Enfermedad_es_nueva_llama_al_metodo_registrar_del_creado_por_la_factory()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                this.enfermedad.Verify(v => v.Registrar(It.IsAny<AgregarEnfermedad>(), this.Target), Times.Once);
            }

            [Fact]
            public void Si_la_Enfermedad_no_es_nueva_llama_al_metodo_registrar_del_existente()
            {
                // Arrange
                var enfermedadExistente = new Mock<FichaSaludEnfermedad>();
                enfermedadExistente.Setup(s => s.ID).Returns(1);
                this.Target.Enfermedades.Add(enfermedadExistente.Object);

                var agregarEnfermedad = new AgregarEnfermedad(
                    ID: enfermedadExistente.Object.ID,
                    Nombre: "",
                    Vigente: true,
                    Observacion: ""
                );
                this.modificarFichaSalud = this.modificarFichaSalud with { Enfermedades = new List<AgregarEnfermedad> { agregarEnfermedad } };

                // Action
                this.Action();

                // Assert
                enfermedadExistente.Verify(v => v.Registrar(It.IsAny<AgregarEnfermedad>(), this.Target), Times.Once);
            }

            [Fact]
            public void Si_la_Enfermedad_es_nueva_la_agrega_a_la_lista_de_enfermedades()
            {
                // Arrange

                // Action
                this.Action();

                // Assert
                Assert.Contains(this.enfermedad.Object, this.Target.Enfermedades);
            }

            [Fact]
            public void Si_la_Enfermedad_no_es_nueva_no_vuelve_a_agregarla_a_la_lista()
            {
                // Arrange
                var enfermedadExistente = new Mock<FichaSaludEnfermedad>();
                enfermedadExistente.Setup(s => s.ID).Returns(1);
                this.Target.Enfermedades.Add(enfermedadExistente.Object);

                var agregarEnfermedad = new AgregarEnfermedad(
                    ID: enfermedadExistente.Object.ID,
                    Nombre: "",
                    Vigente: true,
                    Observacion: ""
                );
                this.modificarFichaSalud = this.modificarFichaSalud with { Enfermedades = new List<AgregarEnfermedad> { agregarEnfermedad } };

                // Action
                this.Action();

                // Assert
                Assert.Equal(1, this.Target.Enfermedades.Count(a => a.ID == enfermedadExistente.Object.ID));
            }
        }
    }
}

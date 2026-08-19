/// Versión y texto de la Política de Privacidad de CareWell.
///
/// Transcripción del apartado "Política de privacidad" de la documentación del
/// proyecto (`care_well_doc/LATEX/CuidadoPersonas.tex`). Se versiona por
/// separado de los Términos y Condiciones: actualizar aquí no implica tocar
/// [kTermsVersion].
const String kPrivacyVersion = '1.0 — Junio 2025';

const String kPrivacyContent = '''
Implementamos diferentes medidas de seguridad, tecnológicas y de procesos, para proteger los datos personales que gestionamos. Tiene por objeto proteger la confidencialidad, integridad y disponibilidad de los datos, de manera que solo sean accedidos o modificados por las personas autorizadas y se encuentren disponibles en tiempo y forma cuando sean requeridos.

En la aplicación recolectamos datos personales de los usuarios para prestar los servicios, algunos de ellos son:

· Identificatoria: nombres, direcciones, credenciales de acceso, etc.
· De contacto: teléfonos, correos electrónicos, etc.
· De salud: enfermedades, condiciones, etc.
· Información de los dispositivos: modelos, identificación de red, información de sensores y hardware, etc.

Mención aparte merece la imagen del documento de identidad que se solicita al crear una cuenta. Dicha imagen se emplea únicamente para comprobar que los datos declarados corresponden al titular del documento y no se almacena: se procesa en el momento y se descarta, conservándose solamente la constancia de que la identidad fue validada y la fecha en que ello ocurrió. Para realizar esa comprobación, la imagen se remite a un proveedor externo de inteligencia artificial —Google Cloud, a través de su plataforma empresarial Vertex AI—, que interviene como encargado del tratamiento, la procesa en el momento y no la conserva.

Del mismo modo, la funcionalidad de resumen diario entrega a ese mismo proveedor el nombre de la persona a cargo junto con los eventos de salud, hábitos de vida y estados de ánimo del día, con la única finalidad de redactar el texto que se muestra al usuario. Se envía solamente la información necesaria para esa redacción y no se remite el historial completo de la persona ni identificadores adicionales. El texto así redactado se conserva en nuestros sistemas para poder mostrarlo nuevamente durante un lapso breve sin volver a generarlo; se guarda únicamente el resumen más reciente de cada persona —cada nueva generación reemplaza al anterior, de modo que no se construye un historial— y se elimina junto con los datos de la persona cuando esta se da de baja. Al utilizar la aplicación, el Usuario presta su consentimiento expreso para este tratamiento, en los términos de la presente política y de los Términos y condiciones.

Respecto de ambos usos, y conforme la documentación oficial del proveedor, las consignas enviadas —incluidas las imágenes— y las respuestas generadas no se utilizan para entrenar sus modelos, y su tratamiento se rige por un acuerdo formal de tratamiento de datos, el Cloud Data Processing Addendum. Estas garantías corresponden a la plataforma empresarial contratada y no al servicio gratuito de uso general del mismo proveedor, motivo por el cual se optó deliberadamente por aquella. Los datos así remitidos viajan por canales cifrados y no se ceden a ningún otro tercero.

Dentro de las soluciones tecnológicas que implementamos para brindar los servicios se encuentran alojadas en la nube por sus proveedores. Por lo que es posible que los datos residan en otros países, cuando esto ocurre se pueden utilizar acuerdos contractuales que requieren el cumplimiento de la política.

No se comercializan los datos personales de ningún tipo bajo ninguna circunstancia. Los terceros con los que se puede compartir, transferir o enviar datos son las entidades gubernamentales y organismos de control para el cumplimiento de las regulaciones establecidas.

Se conservarán los datos personales durante el período de prestación del servicio y por el tiempo que lo indiquen las reglamentaciones nacionales.

Cumpliendo con la ley 25326 los titulares de los datos personales tienen la posibilidad de ejercer sus derechos, solicitando:

· Información al organismo de control relativa a la existencia de archivos, registros bases o bancos de datos personales, sus finalidades y la identidad de sus responsables.
· El acceso a la información: lo cual permite al titular conocer qué información posee de él.
· La rectificación de la información: lo cual permite al titular corregir ciertos datos que se posee de él en caso de que los mismos no fuesen íntegros o adecuados.
· La actualización de la información: lo cual permite al titular modificar ciertos datos que se posee de él en caso de que se encontrasen desactualizados.
· La supresión de datos: lo cual posibilita la eliminación por parte de aquellos datos que el titular indique.
''';

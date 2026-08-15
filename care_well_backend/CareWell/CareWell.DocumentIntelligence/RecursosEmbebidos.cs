using System.Collections.Concurrent;
using System.Reflection;
using System.Text;

namespace CareWell.DocumentIntelligence
{
    internal static class RecursosEmbebidos
    {
        private static readonly Assembly Assembly = typeof(RecursosEmbebidos).Assembly;

        private static readonly ConcurrentDictionary<string, string> Cache = new(StringComparer.Ordinal);

        internal static string Leer(string nombreLogico)
        {
            ArgumentException.ThrowIfNullOrWhiteSpace(nombreLogico);

            return Cache.GetOrAdd(nombreLogico, LeerDelAssembly);
        }

        private static string LeerDelAssembly(string nombreLogico)
        {
            using var stream = Assembly.GetManifestResourceStream(nombreLogico);

            if (stream is null)
            {
                var disponibles = string.Join(", ", Assembly.GetManifestResourceNames());

                throw new InvalidOperationException(
                    $"No se encontró el recurso embebido '{nombreLogico}' en el assembly " +
                    $"'{Assembly.GetName().Name}'. Verificá el LogicalName del EmbeddedResource " +
                    $"en el .csproj. Recursos disponibles: [{disponibles}].");
            }

            using var reader = new StreamReader(stream, Encoding.UTF8, detectEncodingFromByteOrderMarks: true);

            var contenido = reader.ReadToEnd();

            if (string.IsNullOrWhiteSpace(contenido))
                throw new InvalidOperationException(
                    $"El recurso embebido '{nombreLogico}' está vacío.");

            return contenido;
        }
    }
}

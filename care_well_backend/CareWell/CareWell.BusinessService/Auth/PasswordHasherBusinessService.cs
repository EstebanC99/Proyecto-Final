using CareWell.Domain.DomainServices.Auth;
using System.Security.Cryptography;

namespace CareWell.BusinessService.Auth
{
    public class PasswordHasherBusinessService : IPasswordHasherDomainService
    {
        private const int Iteraciones = 350_000;
        private const int TamanoHash = 32;
        private const int TamanoSalt = 16;

        public string Hashear(string contrasena)
        {
            var salt = RandomNumberGenerator.GetBytes(TamanoSalt);

            var hash = Rfc2898DeriveBytes.Pbkdf2(contrasena, salt, Iteraciones, HashAlgorithmName.SHA256, TamanoHash);

            return $"{Iteraciones}.{Convert.ToBase64String(salt)}.{Convert.ToBase64String(hash)}";
        }

        public bool Verificar(string contrasena, string hash)
        {
            var partes = hash.Split('.', 3);

            if (partes.Length != 3)
                return false;

            var iteraciones = int.Parse(partes[0]);
            var salt = Convert.FromBase64String(partes[1]);
            var hashAlmacenado = Convert.FromBase64String(partes[2]);

            var hashCalculado = Rfc2898DeriveBytes.Pbkdf2(contrasena, salt, iteraciones, HashAlgorithmName.SHA256, TamanoHash);

            return CryptographicOperations.FixedTimeEquals(hashAlmacenado, hashCalculado);
        }
    }
}

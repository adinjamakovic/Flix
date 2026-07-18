using System.Security.Cryptography;

namespace Flix.CommonServices.CryptoService
{
    public class CryptoService : ICryptoService
    {
        public string GenerateHash(string password, string salt)
        {
            byte[] hash = Rfc2898DeriveBytes.Pbkdf2(
                password,
                Convert.FromBase64String(salt),
                iterations: 100000,
                HashAlgorithmName.SHA256,
                outputLength: 32);

            return Convert.ToBase64String(hash);
        }

        public string GenerateSalt()
        {
            return Convert.ToBase64String(RandomNumberGenerator.GetBytes(16));
        }

        public bool VerifyPassword(string hash, string salt, string password)
        {
            return GenerateHash(password, salt) == hash;
        }
    }
}

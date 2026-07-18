namespace Flix.CommonServices.CryptoService
{
    public interface ICryptoService
    {
        string GenerateHash(string password, string salt);
        string GenerateSalt();
        bool VerifyPassword(string hash, string salt, string password);
    }
}

namespace Flix.Model.Exceptions
{
    public class ClientException : Exception
    {
        public ClientException(string message) : base(message)
        {
            
        }

        public ClientException(string message, Exception inner) : base(message, inner)
        {
            
        }
    }
}
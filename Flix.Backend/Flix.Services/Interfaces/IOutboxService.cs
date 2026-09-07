namespace Flix.Services.Interfaces
{
    public interface IOutboxService
    {
        void Enqueue(object message);
    }
}

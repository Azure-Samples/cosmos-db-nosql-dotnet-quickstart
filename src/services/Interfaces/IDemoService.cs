namespace Microsoft.Samples.Cosmos.NoSQL.Quickstart.Services.Interfaces;

public interface IDemoService
{
    Task RunAsync(Func<string, Task> writeOutputAync);

    string GetEndpoint();
}
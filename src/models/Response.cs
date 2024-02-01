namespace Cosmos.Samples.NoSQL.Quickstart.Models;

public record Payload<T>(
    double requestCharge,
    T data
);
namespace Cosmos.Samples.NoSQL.Quickstart.Web.Models;

// <model>
public record Product(
    string id,
    string category,
    string name,
    int quantity,
    decimal price,
    bool clearance
);
// </model>

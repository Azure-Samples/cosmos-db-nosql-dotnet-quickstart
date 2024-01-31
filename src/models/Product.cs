namespace Cosmos.Samples.NoSQL.Quickstart.Models;

// <model>
public sealed record Product(
    string id,
    string name,
    string description,
    Category category,
    string sku,
    IList<string> tags,
    decimal cost,
    decimal price,
    string type = nameof(Product)
)
// </model>
{
    public override string ToString() => $"{id} | {name} - {category.name}";
}

namespace Cosmos.Samples.NoSQL.Quickstart.Models;

// <model>
public sealed record Category(
    string name,
    string slug,
    SubCategory subCategory
);
// </model>

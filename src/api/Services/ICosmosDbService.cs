using Cosmos.Samples.NoSQL.Quickstart.Models;

namespace Cosmos.Samples.NoSQL.Quickstart.Api.Services;

internal interface ICosmosDbService
{
    string Endpoint { get; }

    Task<(Product, double)> CreateProductAsync(Product item);

    Task<(Product, double)> ReadProductAsync(string id, string category, string subCategory);

    Task<(Product, double)> UpdateProductAsync(Product item);

    Task<(Product, double)> DeleteProductAsync(string id, string category, string subCategory);

    Task<(IList<Product>, double)> QueryProductsAsync(string category);

    Task<(IList<string>, double)> QueryCategoriesAsync();
}

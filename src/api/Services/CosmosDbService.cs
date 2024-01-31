using Cosmos.Samples.NoSQL.Quickstart.Models;
using Microsoft.Azure.Cosmos;

namespace Cosmos.Samples.NoSQL.Quickstart.Api.Services;

internal sealed class CosmosDbService : ICosmosDbService
{
    private readonly CosmosClient client;

    public CosmosDbService(CosmosClient client)
    {
        this.client = client;
    }

    public string Endpoint
    {
        get => $"{client.Endpoint}";
    }

    private Container TargetContainer
    {
        get
        {
            // <get_database>
            Database database = client.GetDatabase("cosmicworks");
            // </get_database>

            // <get_container>
            Container container = database.GetContainer("products");
            // </get_container>

            return container;
        }
    }

    public async Task<(Product, double)> CreateProductAsync(Product item)
    {
        Container container = TargetContainer;

        // <create_item>
        ItemResponse<Product> response = await container.CreateItemAsync<Product>(
            item: item
        );
        // </create_item>

        return (response.Resource, response.RequestCharge);
    }

    public async Task<(Product, double)> ReadProductAsync(string id, string category, string subCategory)
    {
        Container container = TargetContainer;

        // <read_item>
        PartitionKey partitionKey = new PartitionKeyBuilder()
            .Add(category)
            .Add(subCategory)
            .Build();

        ItemResponse<Product> response = await container.ReadItemAsync<Product>(
            id: id,
            partitionKey: partitionKey
        );
        // </read_item>

        return (response.Resource, response.RequestCharge);
    }

    public async Task<(Product, double)> UpdateProductAsync(Product item)
    {
        Container container = TargetContainer;

        // <update_item>
        ItemResponse<Product> response = await container.UpsertItemAsync<Product>(
            item: item
        );
        // </update_item>

        return (response.Resource, response.RequestCharge);
    }

    public async Task<(Product, double)> DeleteProductAsync(string id, string category, string subCategory)
    {
        Container container = TargetContainer;

        // <delete_item>
        PartitionKey partitionKey = new PartitionKeyBuilder()
            .Add(category)
            .Add(subCategory)
            .Build();

        ItemResponse<Product> response = await container.DeleteItemAsync<Product>(
            id: id,
            partitionKey: partitionKey
        );
        // </delete_item>

        return (response.Resource, response.RequestCharge);
    }

    public async Task<(IList<Product>, double)> QueryProductsAsync(string category)
    {
        Container container = TargetContainer;

        // <query_items>
        var query = new QueryDefinition(
            query: "SELECT * FROM products p WHERE STRINGEQUALS(p.category.name, @category, true)"
        )
        .WithParameter("@category", category);

        using FeedIterator<Product> feed = container.GetItemQueryIterator<Product>(
            queryDefinition: query
        );
        // </query_items>

        // <parse_results>
        List<Product> items = new();
        double requestCharge = 0d;
        while (feed.HasMoreResults)
        {
            FeedResponse<Product> response = await feed.ReadNextAsync();
            foreach (Product item in response)
            {
                items.Add(item);
            }
            requestCharge += response.RequestCharge;
        }
        // </parse_results>

        return (items, requestCharge);
    }

    public async Task<(IList<string>, double)> QueryCategoriesAsync()
    {
        Container container = TargetContainer;

        var query = new QueryDefinition(
            query: "SELECT DISTINCT VALUE p.category.name FROM products p"
        );

        using FeedIterator<string> feed = container.GetItemQueryIterator<string>(
            queryDefinition: query
        );

        List<string> categories = new();
        double requestCharge = 0d;
        while (feed.HasMoreResults)
        {
            FeedResponse<string> response = await feed.ReadNextAsync();
            foreach (string category in response)
            {
                categories.Add(category);
            }
            requestCharge += response.RequestCharge;
        }

        return (categories, requestCharge);
    }
}

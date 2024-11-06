using System.Configuration;
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Options;
using Microsoft.Samples.Cosmos.NoSQL.Quickstart.Models;
using Microsoft.Samples.Cosmos.NoSQL.Quickstart.Services.Interfaces;

using Settings = Microsoft.Samples.Cosmos.NoSQL.Quickstart.Models.Settings;

namespace Microsoft.Samples.Cosmos.NoSQL.Quickstart.Services;

public sealed class DemoService(
    CosmosClient client,
    IOptions<Settings.Configuration> configurationOptions
) : IDemoService
{
    private readonly Settings.Configuration configuration = configurationOptions.Value;

    public string GetEndpoint() => $"{client.Endpoint}";

    public async Task RunAsync(Func<string, Task> writeOutputAync)
    {
        Database database = client.GetDatabase(configuration.AzureCosmosDB.DatabaseName);

        database = await database.ReadAsync();
        await writeOutputAync($"Get database:\t{database.Id}");

        Container container = database.GetContainer(configuration.AzureCosmosDB.ContainerName);

        container = await container.ReadContainerAsync();
        await writeOutputAync($"Get container:\t{container.Id}");

        {
            Product item = new(
                id: "68719518391",
                category: "gear-surf-surfboards",
                name: "Yamba Surfboard",
                quantity: 12,
                price: 850.00m,
                clearance: false
            );

            ItemResponse<Product> response = await container.UpsertItemAsync<Product>(
                item: item,
                partitionKey: new PartitionKey("gear-surf-surfboards")
            );

            await writeOutputAync($"Upserted item:\t{response.Resource}");
            await writeOutputAync($"Status code:\t{response.StatusCode}");
            await writeOutputAync($"Request charge:\t{response.RequestCharge:0.00}");
        }

        {
            Product item = new(
                id: "68719518371",
                category: "gear-surf-surfboards",
                name: "Kiama Classic Surfboard",
                quantity: 25,
                price: 790.00m,
                clearance: false
            );

            ItemResponse<Product> response = await container.UpsertItemAsync<Product>(
                item: item,
                partitionKey: new PartitionKey("gear-surf-surfboards")
            );
            await writeOutputAync($"Upserted item:\t{response.Resource}");
            await writeOutputAync($"Status code:\t{response.StatusCode}");
            await writeOutputAync($"Request charge:\t{response.RequestCharge:0.00}");
        }

        {
            ItemResponse<Product> response = await container.ReadItemAsync<Product>(
                id: "68719518391",
                partitionKey: new PartitionKey("gear-surf-surfboards")
            );

            await writeOutputAync($"Read item id:\t{response.Resource.id}");
            await writeOutputAync($"Read item:\t{response.Resource}");
            await writeOutputAync($"Status code:\t{response.StatusCode}");
            await writeOutputAync($"Request charge:\t{response.RequestCharge:0.00}");
        }

        {
            var query = new QueryDefinition(
                query: "SELECT * FROM products p WHERE p.category = @category"
            )
                .WithParameter("@category", "gear-surf-surfboards");

            using FeedIterator<Product> feed = container.GetItemQueryIterator<Product>(
                queryDefinition: query
            );

            await writeOutputAync($"Ran query:\t{query.QueryText}");

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

            foreach (var item in items)
            {
                await writeOutputAync($"Found item:\t{item.name}\t[{item.id}]");
            }
            await writeOutputAync($"Request charge:\t{requestCharge:0.00}");
        }
    }
}

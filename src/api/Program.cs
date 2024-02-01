using Azure.Identity;
using Microsoft.Azure.Cosmos;
using Cosmos.Samples.NoSQL.Quickstart.Api.Services;
using Cosmos.Samples.NoSQL.Quickstart.Models;
using System.Net;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddSingleton<CosmosClient>((_) =>
{
    // <create_client>
    CosmosClient client = new(
        accountEndpoint: builder.Configuration["AZURE_COSMOS_DB_NOSQL_ENDPOINT"]!,
        tokenCredential: new DefaultAzureCredential()
    );
    // </create_client>
    return client;
});

builder.Services.AddTransient<ICosmosDbService, CosmosDbService>();

var app = builder.Build();

app.UseSwagger();
app.UseSwaggerUI(options =>
{
    options.SwaggerEndpoint("/swagger/v1/swagger.json", "v1");
    options.RoutePrefix = string.Empty;
});

app.MapGet("/endpoint", (ICosmosDbService cosmosDbService) =>
{
    return $"Azure Cosmos DB for NoSQL endpoint: {cosmosDbService.Endpoint}";
})
.WithOpenApi();

app.MapGet("/categories", async (ICosmosDbService cosmosDbService) =>
{
    var (categories, requestCharge) = await cosmosDbService.QueryCategoriesAsync();
    return Results.Ok(new Payload<IList<string>>(requestCharge, categories));
})
.WithOpenApi();

app.MapGet("/products/{category}", async (string category, ICosmosDbService cosmosDbService) =>
{
    var (products, requestCharge) = await cosmosDbService.QueryProductsAsync(category);
    return Results.Ok(new Payload<IList<Product>>(requestCharge, products));
})
.WithOpenApi();

app.MapPost("/product", async (Product product, ICosmosDbService cosmosDbService) =>
{
    var (newProduct, requestCharge) = await cosmosDbService.CreateProductAsync(product);
    return Results.Created($"/product/{newProduct.category.name}/{newProduct.category.subCategory.name}/{newProduct.id}", new Payload<Product>(requestCharge, newProduct));
})
.WithOpenApi();

app.MapGet("/product/{category}/{subcategory}/{id}", async (string category, string subCategory, string id, ICosmosDbService cosmosDbService) =>
{
    try
    {
        var (product, requestCharge) = await cosmosDbService.ReadProductAsync(id, category, subCategory);
        return Results.Ok(new Payload<Product>(requestCharge, product));
    }
    catch (CosmosException ex) when (ex.StatusCode == HttpStatusCode.NotFound)
    {
        return Results.NotFound();
    }
})
.WithOpenApi();

app.MapPut("/product", async (Product product, ICosmosDbService cosmosDbService) =>
{
    var (updatedProduct, requestCharge) = await cosmosDbService.UpdateProductAsync(product);
    return Results.Ok(new Payload<Product>(requestCharge, updatedProduct));
})
.WithOpenApi();

app.MapDelete("/product/{category}/{subcategory}/{id}", async (string category, string subCategory, string id, ICosmosDbService cosmosDbService) =>
{
    var (product, requestCharge) = await cosmosDbService.DeleteProductAsync(id, category, subCategory);
    return Results.Ok(new Payload<Product>(requestCharge, product));
})
.WithOpenApi();

await app.RunAsync();

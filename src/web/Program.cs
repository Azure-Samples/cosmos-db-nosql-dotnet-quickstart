using Azure.Identity;
using Microsoft.Azure.Cosmos;
using Microsoft.Samples.Cosmos.NoSQL.Quickstart.Services;
using Microsoft.Samples.Cosmos.NoSQL.Quickstart.Services.Interfaces;
using Microsoft.Samples.Cosmos.NoSQL.Quickstart.Web.Components;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddRazorComponents().AddInteractiveServerComponents();

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

builder.Services.AddTransient<IDemoService, DemoService>();

var app = builder.Build();

app.UseDeveloperExceptionPage();

app.UseHttpsRedirection();

app.UseAntiforgery();

app.MapStaticAssets();

app.MapRazorComponents<App>().AddInteractiveServerRenderMode();

app.Run();

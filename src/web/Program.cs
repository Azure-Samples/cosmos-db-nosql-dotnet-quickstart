using Azure.Identity;
using Microsoft.Azure.Cosmos;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();

// <client_configuration>
if (builder.Environment.IsDevelopment())
{
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
}
else
{
    builder.Services.AddSingleton<CosmosClient>((_) =>
    {
        // <create_client_client_id>
        CosmosClient client = new(
            accountEndpoint: builder.Configuration["AZURE_COSMOS_DB_NOSQL_ENDPOINT"]!,
            tokenCredential: new DefaultAzureCredential(
                new DefaultAzureCredentialOptions()
                {
                    ManagedIdentityClientId = builder.Configuration["AZURE_MANAGED_IDENTITY_CLIENT_ID"]!
                }
            )
        );
        // </create_client_client_id>
        return client;
    });
}
// </client_configuration>

builder.Services.AddTransient<ICosmosDbService, CosmosDbService>();

var app = builder.Build();

app.UseDeveloperExceptionPage();

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();

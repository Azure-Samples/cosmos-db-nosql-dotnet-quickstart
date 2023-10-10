using Azure.Identity;
using Microsoft.Azure.Cosmos;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();

builder.Services.AddSingleton<CosmosClient>((_) => new CosmosClient(
    accountEndpoint: builder.Configuration["AZURE_COSMOS_DB_NOSQL_ENDPOINT"]!,
    tokenCredential: new DefaultAzureCredential()
));

var app = builder.Build();

app.UseDeveloperExceptionPage();

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();

using Cosmos.Samples.NoSQL.Quickstart.Web.Options;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHttpClient();
builder.Services.AddRazorPages();
builder.Services.AddServerSideBlazor();

builder.Services.AddSingleton((_) => new Endpoints
{
    BaseApi = builder.Configuration["BASE_API_ENDPOINT"]
});

builder.Services.AddTransient<IDataApiService, DataApiService>();

var app = builder.Build();

app.UseDeveloperExceptionPage();

app.UseHttpsRedirection();

app.UseStaticFiles();

app.UseRouting();

app.MapBlazorHub();
app.MapFallbackToPage("/_Host");

app.Run();

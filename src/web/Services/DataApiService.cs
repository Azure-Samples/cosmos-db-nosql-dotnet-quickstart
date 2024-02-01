using Cosmos.Samples.NoSQL.Quickstart.Web.Options;

internal interface IDataApiService
{
    Task<string> StartAsync();
}

internal sealed class DataApiService : IDataApiService
{
    private readonly HttpClient _httpClient;

    public DataApiService(IHttpClientFactory httpClientFactory, Endpoints endpoints)
    {
        ArgumentNullException.ThrowIfNull(httpClientFactory);
        ArgumentNullException.ThrowIfNull(endpoints.BaseApi, nameof(endpoints));

        var client = httpClientFactory.CreateClient();
        client.BaseAddress = new Uri(endpoints.BaseApi);
        _httpClient = client;
    }

    public async Task<string> StartAsync()
    {
        await Task.Delay(2500);
        string response = await _httpClient.GetStringAsync("/endpoint");
        return response;
    }
}
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["web/Cosmos.Samples.NoSQL.Quickstart.Web.csproj", "web/"]
RUN dotnet restore "web/Cosmos.Samples.NoSQL.Quickstart.Web.csproj"
COPY . .
WORKDIR "/src/web"
RUN dotnet build "Cosmos.Samples.NoSQL.Quickstart.Web.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
RUN dotnet publish "Cosmos.Samples.NoSQL.Quickstart.Web.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Cosmos.Samples.NoSQL.Quickstart.Web.dll"]
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 5001

ENV ASPNETCORE_ENVIRONMENT=Development

# Restore as distinct layers
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["TestApi.csproj", "./"]
RUN dotnet restore "TestApi.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "TestApi.csproj" -c Debug -o /app/build

# Build and publish a release
FROM build AS publish
RUN dotnet publish "TestApi.csproj" -c Debug -o /app/publish /p:UseAppHost=false

# Build runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "TestApi.dll"]
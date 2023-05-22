#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

# Set environment variables
ENV NUGET_CREDENTIALPROVIDER_SESSIONTOKENCACHE_ENABLED true
ENV VSS_NUGET_EXTERNAL_FEED_ENDPOINTS '{"endpointCredentials":[{"endpoint":"https://pkgs.dev.azure.com/I457616/partytime/_packaging/Partytime.Common/nuget/v3/index.json","username":"NoRealUserNameAsIsNotRequired","password":"2inm42gzqxcx3fxp4qc7y4g6b6c4p3dp3qtcegoer4ojjiwp54oq"}]}'

# Get and install the Artifact Credential provider
RUN wget -O - https://raw.githubusercontent.com/Microsoft/artifacts-credprovider/master/helpers/installcredprovider.sh  | bash

COPY ["ApiGateway.csproj", "."]

# Critical line to make PartyTime.Common work
COPY ["nuget.config", ""]

RUN dotnet restore "./ApiGateway.csproj"
COPY . .
WORKDIR "/src/."

RUN dotnet restore "ApiGateway.csproj" -s "https://pkgs.dev.azure.com/I457616/partytime/_packaging/Partytime.Common/nuget/v3/index.json" -s "https://pkgs.dev.azure.com/I457616/partytime/_packaging/Partytime.Joined.Contracts/nuget/v3/index.json" -s "https://api.nuget.org/v3/index.json"
RUN dotnet build "ApiGateway.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "ApiGateway.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "ApiGateway.dll"]
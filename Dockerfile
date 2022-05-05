FROM mcr.microsoft.com/dotnet/aspnet:6.0-focal AS base
WORKDIR /app
EXPOSE 80

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:6.0-focal AS build
WORKDIR /src
COPY ["blazor-conf-ci-cd/Server/blazor-conf-ci-cd.Server.csproj", "blazor-conf-ci-cd/Server/"]
RUN dotnet restore "blazor-conf-ci-cd/Server/blazor-conf-ci-cd.Server.csproj"
COPY . .
WORKDIR "/src/blazor-conf-ci-cd/Server"
RUN dotnet build "blazor-conf-ci-cd.Server.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "blazor-conf-ci-cd.Server.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENV ASPNETCORE_URLS http://*:80
ENTRYPOINT ["dotnet", "blazor-conf-ci-cd.Server.dll"]

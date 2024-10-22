# Base Image
FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Create build env
FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim AS build
WORKDIR /app

# Changing the COPY commands to make a more significant change
# Changed 'COPY ["src/Client/", "Client/"]' to 'COPY ["src/Client/", "/app/Client/"]'
COPY ["src/Client/", "/app/Client/"]
COPY ["src/Shared/", "/app/Shared/"]
COPY ["src/Server/", "/app/Server/"]
COPY ["src/Services/", "/app/Services/"]
COPY ["src/Persistence/", "/app/Persistence/"]
COPY ["src/Domain/", "/app/Domain/"]

# Restore & build app
RUN dotnet restore "/app/Server/Server.csproj"
RUN dotnet build "/app/Server/Server.csproj" -c Release -o /app/build --no-restore

# Publish app
FROM build AS publish
RUN dotnet publish "/app/Server/Server.csproj" -c Release -o /app/publish --no-restore

# Final stage/image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Server.dll"]

# Added a new environment variable for testing
ENV APP_VERSION="1.0.1"



# # Base Image
# FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim AS base
# WORKDIR /app
# EXPOSE 80
# EXPOSE 443

# # Create build env
# FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim AS build
# WORKDIR /app
# COPY ["src/Client/", "Client/"]
# COPY ["src/Shared/", "Shared/"]
# COPY ["src/Server/", "Server/"]
# COPY ["src/Services/", "Services/"]
# COPY ["src/Persistence/", "Persistence/"]
# COPY ["src/Domain/", "Domain/"]

# # edit
# # Restore & build app
# RUN dotnet restore "Server/Server.csproj"
# RUN dotnet build "Server/Server.csproj" -c Release -o /app/build --no-restore

# # Publish app
# FROM build AS publish
# RUN dotnet publish "Server/Server.csproj" -c Release -o /app/publish --no-restore

# # Final stage/image
# FROM base AS final
# WORKDIR /app
# COPY --from=publish /app/publish .
# ENTRYPOINT ["dotnet", "Server.dll"]

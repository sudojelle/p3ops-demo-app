# # Use the official .NET Core ASP.NET runtime as a base image
# FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
# WORKDIR /app
# EXPOSE 80

# # Build stage: use SDK image to build the application
# FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
# WORKDIR /src
# COPY . .
# RUN dotnet restore
# RUN dotnet publish -c Release -o /app/publish

# # Copy the compiled application from build stage to runtime image
# FROM base AS final
# WORKDIR /app
# COPY --from=build /app/publish .
# ENTRYPOINT ["dotnet", "Server.dll"]


# Base Image
FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Create build env
FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim AS build
WORKDIR /app
COPY ["src/Client/", "Client/"]
COPY ["src/Shared/", "Shared/"]
COPY ["src/Server/", "Server/"]
COPY ["src/Services/", "Services/"]
COPY ["src/Persistence/", "Persistence/"]
COPY ["src/Domain/", "Domain/"]

# edit
# Restore & build app
RUN dotnet restore "Server/Server.csproj"
RUN dotnet build "Server/Server.csproj" -c Release -o /app/build --no-restore

# Publish app
FROM build AS publish
RUN dotnet publish "Server/Server.csproj" -c Release -o /app/publish --no-restore

# Final stage/image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Server.dll"]

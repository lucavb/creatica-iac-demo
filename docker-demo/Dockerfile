FROM mcr.microsoft.com/dotnet/aspnet:latest AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:latest AS build
WORKDIR /src
COPY ["creatica-iac-demo.csproj", "./"]
RUN dotnet restore "creatica-iac-demo.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "creatica-iac-demo.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "creatica-iac-demo.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "creatica-iac-demo.dll"]

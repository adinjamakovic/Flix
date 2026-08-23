FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY Flix.Backend.slnx .
COPY Flix.Model/Flix.Model.csproj Flix.Model/
COPY Flix.CommonServices/Flix.CommonServices.csproj Flix.CommonServices/
COPY Flix.Services/Flix.Services.csproj Flix.Services/
COPY Flix.WebApi/Flix.WebApi.csproj Flix.WebApi/
RUN dotnet restore "Flix.WebApi/Flix.WebApi.csproj"

COPY . .
RUN dotnet publish "Flix.WebApi/Flix.WebApi.csproj" -c Release --no-restore -o /app

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 5121
ENV ASPNETCORE_URLS=http://+:5121
COPY --from=build /app .
USER $APP_UID
ENTRYPOINT [ "dotnet", "Flix.WebApi.dll"]

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY Flix.Backend/Flix.Backend.slnx Flix.Backend/
COPY Flix.Backend/Flix.Model/Flix.Model.csproj Flix.Backend/Flix.Model/
COPY Flix.Backend/Flix.CommonServices/Flix.CommonServices.csproj Flix.Backend/Flix.CommonServices/
COPY Flix.Backend/Flix.Services/Flix.Services.csproj Flix.Backend/Flix.Services/
COPY Flix.Backend/Flix.WebApi/Flix.WebApi.csproj Flix.Backend/Flix.WebApi/
RUN dotnet restore "Flix.Backend/Flix.WebApi/Flix.WebApi.csproj"

COPY . .
RUN dotnet publish "Flix.Backend/Flix.WebApi/Flix.WebApi.csproj" -c Release --no-restore -o /app

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 5121
ENV ASPNETCORE_URLS=http://+:5121
COPY --from=build /app .
USER $APP_UID
ENTRYPOINT [ "dotnet", "Flix.WebApi.dll"]

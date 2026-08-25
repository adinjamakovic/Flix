FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY Flix.Backend.slnx .
COPY Flix.Model/Flix.Model.csproj Flix.Model/
COPY Flix.CommonServices/Flix.CommonServices.csproj Flix.CommonServices/
COPY Flix.Services/Flix.Services.csproj Flix.Services/
COPY Flix.Subscriber/Flix.Subscriber.csproj Flix.Subscriber/
RUN dotnet restore "Flix.Subscriber/Flix.Subscriber.csproj"

COPY . .
RUN dotnet publish "Flix.Subscriber/Flix.Subscriber.csproj" -c Release --no-restore -o /app

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build /app .
USER $APP_UID
ENTRYPOINT [ "dotnet", "Flix.Subscriber.dll"]

using Flix.CommonServices.CryptoService;
using Flix.Model.Requests;
using DotNetEnv;
using Flix.Services.BackgroundServices;
using Flix.Model.Responses;
using Flix.Services.Database;
using Flix.Services.Implementations;
using Flix.Services.Interfaces;
using Flix.Services.Validators;
using Flix.WebApi.Extensions;
using Flix.WebApi.Filters;
using Flix.WebApi.Services.AccessManager;
using Flix.WebApi.Services.CurrentUser;
using FluentValidation;
using Mapster;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Scalar.AspNetCore;
using System.Text;
using Flix.Model.Enums;
using Azure.Storage.Blobs;
using Flix.CommonServices.ImageStorageService;
using EasyNetQ;

Env.TraversePath().Load();

var builder = WebApplication.CreateBuilder(args);

var blobStorageConnectionString = Environment.GetEnvironmentVariable("BLOB_STORAGE_CONNECTION_STRING");

var rabbitMqHost = Environment.GetEnvironmentVariable("RABBITMQ_HOST");
var rabbitMqUser = Environment.GetEnvironmentVariable("RABBITMQ_USER");
var rabbitMqPass = Environment.GetEnvironmentVariable("RABBITMQ_PASS");

var environmentConfiguration = new Dictionary<string, string?>
{
    ["ConnectionStrings:DefaultConnection"] = builder.Configuration.GetConnectionString("DefaultConnection")
        ?? Environment.GetEnvironmentVariable("DATABASE_CONNECTION"),
    ["ConnectionStrings:RabbitMQ"] = builder.Configuration.GetConnectionString("RabbitMQ")
        ?? (string.IsNullOrWhiteSpace(rabbitMqHost)
            ? null
            : $"host={rabbitMqHost};username={rabbitMqUser};password={rabbitMqPass}"),
    ["JwtToken:Issuer"] = Environment.GetEnvironmentVariable("JWT_ISSUER"),
    ["JwtToken:Audience"] = Environment.GetEnvironmentVariable("JWT_AUDIENCE"),
    ["JwtToken:SecretKey"] = Environment.GetEnvironmentVariable("SECRET_KEY"),
    ["JwtToken:DurationInMinutes"] = Environment.GetEnvironmentVariable("JWT_DURATION"),
    ["Cors:AllowedOrigins"] = Environment.GetEnvironmentVariable("CORS_ORIGINS")
};

builder.Configuration.AddInMemoryCollection(
    environmentConfiguration.Where(x => !string.IsNullOrWhiteSpace(x.Value)));

var databaseConnectionString = builder.Configuration.GetConnectionString("DefaultConnection")
    ?? throw new InvalidOperationException("DATABASE_CONNECTION is not configured. See .env_example.");

const string CorsPolicy = "FlixCors";

var allowedOrigins = (builder.Configuration["Cors:AllowedOrigins"] ?? "http://localhost:5071;https://localhost:7140")
    .Split(';', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);

// Add services to the container.

builder.Services.AddControllers(
    options => { 
        options.Filters.Add<ExceptionFilter>();
    }
);
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi(options =>
{
    options.AddDocumentTransformer<BearerSecuritySchemeTransformer>();
});

builder.Services.AddCors(options =>
{
    options.AddPolicy(CorsPolicy, policy => policy
        .WithOrigins(allowedOrigins)
        .AllowAnyHeader()
        .AllowAnyMethod());
});

builder.Services.AddSingleton(x =>
    new BlobServiceClient(blobStorageConnectionString));

builder.Services.AddSingleton<IBus>(x =>
    RabbitHutch.CreateBus(builder.Configuration.GetConnectionString("RabbitMQ")
        ?? throw new InvalidOperationException("Connection string 'RabbitMQ' is not configured.")));

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
}).AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["JwtToken:Issuer"],
        ValidAudience = builder.Configuration["JwtToken:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.ASCII.GetBytes(builder.Configuration["JwtToken:SecretKey"] ?? string.Empty)),
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddAuthorization();

// Mapster configuration
builder.Services.AddMapster();
TypeAdapterConfig<User, UserResponse>.NewConfig()
    .IgnoreNullValues(true)
    .Map(dest => dest.Role, src => src.Roles.Where(r => r.Role != null).Select(r => r.Role.Name).FirstOrDefault())
    .Map(dest => dest.RoleId, src => src.Roles.Select(r => (int?)r.RoleId).FirstOrDefault())
    // UserResponse.Reviews and ReviewResponse.User point straight back at each other, and EF fixup
    // wires both ends of that pair whenever a user and any of their reviews are tracked by the same
    // query - which every review feed and the activity feed do. Letting Mapster follow it recurses
    // user -> reviews -> user until the stack blows, taking the process down with it. So it is never
    // mapped automatically: UserService.GetByIdAsync fills it for the profile screen. The authors it
    // nests carry no reviews of their own, which is what stops the cycle coming back.
    .Ignore(dest => dest.Reviews)
    .Map(dest => dest.MoviesWatched, src => src.Reviews.Select(x => x.MovieId).Distinct().Count())
    .Map(dest => dest.ReviewsWritten, src => src.Reviews.Count(x => !string.IsNullOrWhiteSpace(x.Content)))
    .Map(dest => dest.FollowerCount, src => src.Followers.Count)
    .Map(dest => dest.FollowingCount, src => src.Following.Count);
TypeAdapterConfig<User, UserSensitiveResponse>.NewConfig()
    .IgnoreNullValues(true)
    .Map(dest => dest.Role, src => src.Roles.Where(r => r.Role != null).Select(r => r.Role.Name).FirstOrDefault())
    .Map(dest => dest.RoleId, src => src.Roles.Select(r => (int?)r.RoleId).FirstOrDefault())
    .Map(dest => dest.MoviesWatched, src => src.Reviews.Select(x => x.MovieId).Distinct().Count())
    .Map(dest => dest.ReviewsWritten, src => src.Reviews.Count(x => !string.IsNullOrWhiteSpace(x.Content)))
    .Map(dest => dest.FollowerCount, src => src.Followers.Count)
    .Map(dest => dest.FollowingCount, src => src.Following.Count);
TypeAdapterConfig<Role, RoleResponse>.NewConfig().IgnoreNullValues(true);
TypeAdapterConfig<CastMember, CastMemberResponse>.NewConfig()
    .Map(dest => dest.Roles, src => src.Credits.Select(c => c.Role).Distinct().ToList())
    .IgnoreNullValues(true);
TypeAdapterConfig<Country, CountryResponse>.NewConfig().IgnoreNullValues(true);
TypeAdapterConfig<Genre, GenreResponse>.NewConfig().IgnoreNullValues(true);
TypeAdapterConfig<Language, LanguageResponse>.NewConfig().IgnoreNullValues(true);
TypeAdapterConfig<Studio, StudioResponse>.NewConfig().IgnoreNullValues(true);
TypeAdapterConfig<MovieCast, MovieCreditResponse>.NewConfig()
    .Map(dest => dest.Role, src => (int)src.Role);
TypeAdapterConfig<Movie, MovieResponse>.NewConfig()
    .Map(dest => dest.Country, src => src.Country)
    .Map(dest => dest.Language, src => src.Language)
    .Map(dest => dest.ReviewCount, src => src.Reviews.Count)
    .Map(dest => dest.Rating, src => src.Reviews.Any(x => x.Rating != null)
                                                                ? (decimal?)Math.Round(
                                                                    src.Reviews.Where(x => x.Rating != null)
                                                                               .Average(x => x.Rating!.Value),
                                                                    1,
                                                                    MidpointRounding.AwayFromZero)
                                                                : null)
    .Map(dest => dest.Directors, src => src.Credits
                                                                .Where(x => x.Role == CastRole.Director)
                                                                .OrderBy(x => x.OrderOfAppearence)
                                                                .Select(x => x.CastMember)
                                                                .ToList())
    .Map(dest => dest.Cast, src => src.Credits
                                                                .Where(x => x.Role != CastRole.Director)
                                                                .OrderBy(x => x.OrderOfAppearence)
                                                                .ToList())
    .Map(dest => dest.Studios, src => src.Studios
                                                                .Select(x => x.Studio)
                                                                .ToList());
TypeAdapterConfig<Clash, ClashResponse>.NewConfig()
    .Map(dest => dest.Participants, src => src.Entries.Count)
    .IgnoreNullValues(true);
TypeAdapterConfig<ClashEntry, ClashEntryResponse>.NewConfig()
    .Map(dest => dest.Votes, src => src.Votes.Count)
    .IgnoreNullValues(true);
TypeAdapterConfig<MovieList, MovieListResponse>.NewConfig()
    .Map(dest => dest.MovieCount, src => src.Items.Count)
    .IgnoreNullValues(true);
TypeAdapterConfig<MovieList, ListResponse>.NewConfig()
    .Map(dest => dest.Movies, src => src.Items
                                                                .OrderBy(x => x.Position)
                                                                .ThenBy(x => x.AddedAt)
                                                                .Select(x => x.Movie)
                                                                .ToList())
    .IgnoreNullValues(true);
TypeAdapterConfig<MovieRequest, MovieRequestResponse>.NewConfig()
    .IgnoreNullValues(true)
    .Map(dest => dest.RequestedByUser, src => src.RequestedBy)
    .Map(dest => dest.Movie, src => src.CreatedMovie);
TypeAdapterConfig<Activity, ActivityResponse>.NewConfig().IgnoreNullValues(true);
TypeAdapterConfig<MovieRecommendation, MovieRecommendationResponse>.NewConfig()
    .IgnoreNullValues(true)
    .Map(dest => dest.Movie, src => src.Movie)
    .Map(dest => dest.RecommendedMovie, src => src.RecommendedMovie)
    .Map(dest => dest.Source, src => RecommendationSource.Similar);

// Image columns hold the blob path and are owned entirely by IImageStorageService inside the
// services. Mapping the request's IFormFile onto them would stringify the upload on insert and
// wipe the existing path on any update that does not include a new file.
TypeAdapterConfig<CastMemberInsertRequest, CastMember>.NewConfig().Ignore(dest => dest.Photo!);
TypeAdapterConfig<CastMemberUpdateRequest, CastMember>.NewConfig().Ignore(dest => dest.Photo!);
TypeAdapterConfig<ClashInsertRequest, Clash>.NewConfig().Ignore(dest => dest.BannerImage!);
TypeAdapterConfig<ClashUpdateRequest, Clash>.NewConfig().Ignore(dest => dest.BannerImage!);
TypeAdapterConfig<CountryInsertRequest, Country>.NewConfig().Ignore(dest => dest.FlagImage!);
TypeAdapterConfig<CountryUpdateRequest, Country>.NewConfig().Ignore(dest => dest.FlagImage!);
TypeAdapterConfig<MovieInsertRequest, Movie>.NewConfig().Ignore(dest => dest.Poster!, dest => dest.HeaderImage!, dest => dest.Credits!, dest => dest.Studios!);
TypeAdapterConfig<MovieUpdateRequest, Movie>.NewConfig().Ignore(dest => dest.Poster!, dest => dest.HeaderImage!, dest => dest.Credits!, dest => dest.Studios!);
TypeAdapterConfig<StudioInsertRequest, Studio>.NewConfig().Ignore(dest => dest.Logo!);
TypeAdapterConfig<StudioUpdateRequest, Studio>.NewConfig().Ignore(dest => dest.Logo!);
TypeAdapterConfig<UserInsertRequest, User>.NewConfig().Ignore(dest => dest.ProfileImage!);
TypeAdapterConfig<UserUpdateRequest, User>.NewConfig().Ignore(dest => dest.ProfileImage!);

// DB Context
builder.Services.AddDbContext<FlixDbContext>(options =>
    options.UseSqlServer(databaseConnectionString));

// Validators
builder.Services.AddScoped<IValidator<ActivityInsertRequest>, ActivityInsertRequestValidator>();
builder.Services.AddScoped<IValidator<UserInsertRequest>, UserInsertRequestValidator>();
builder.Services.AddScoped<IValidator<UserUpdateRequest>, UserUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<CastMemberInsertRequest>, CastMemberInsertRequestValidator>();
builder.Services.AddScoped<IValidator<CastMemberUpdateRequest>, CastMemberUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<ClashInsertRequest>, ClashInsertRequestValidator>();
builder.Services.AddScoped<IValidator<ClashUpdateRequest>, ClashUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<CountryInsertRequest>, CountryInsertRequestValidator>();
builder.Services.AddScoped<IValidator<DiaryInsertRequest>, DiaryInsertRequestValidator>();
builder.Services.AddScoped<IValidator<CountryUpdateRequest>, CountryUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<GenreInsertRequest>, GenreInsertRequestValidator>();
builder.Services.AddScoped<IValidator<GenreUpdateRequest>, GenreUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<LanguageInsertRequest>, LanguageInsertRequestValidator>();
builder.Services.AddScoped<IValidator<LanguageUpdateRequest>, LanguageUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<ListInsertRequest>, ListInsertRequestValidator>();
builder.Services.AddScoped<IValidator<ListUpdateRequest>, ListUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<MovieInsertRequest>, MovieInsertRequestValidator>();
builder.Services.AddScoped<IValidator<MovieUpdateRequest>, MovieUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<ReviewUpsertRequest>, ReviewUpsertRequestValidator>();
builder.Services.AddScoped<IValidator<MovieRequestInsertRequest>, MovieRequestInsertRequestValidator>();
builder.Services.AddScoped<IValidator<MovieRequestUpdateRequest>, MovieRequestUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<StudioInsertRequest>, StudioInsertRequestValidator>();
builder.Services.AddScoped<IValidator<StudioUpdateRequest>, StudioUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<AddToListRequest>, AddToListRequestValidator>();
builder.Services.AddScoped<IValidator<MovieIssueReportInsertRequest>, MovieIssueReportInsertRequestValidator>();
builder.Services.AddScoped<IValidator<MovieIssueReportUpdateRequest>, MovieIssueReportUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<UserReportInsertRequest>, UserReportInsertRequestValidator>();
builder.Services.AddScoped<IValidator<UserReportUpdateRequest>, UserReportUpdateRequestValidator>();

//Services
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddScoped<IImageStorageService, ImageStorageService>();
builder.Services.AddScoped<IResponseImageUrlResolver, ResponseImageUrlResolver>();
builder.Services.AddScoped<IRefreshTokenService, RefreshTokenService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IUserNetworkService, UserNetworkService>();
builder.Services.AddScoped<ICastMemberService, CastMemberService>();
builder.Services.AddScoped<ICryptoService, CryptoService>();
builder.Services.AddScoped<IAccessManager, AccessManager>();
builder.Services.AddScoped<IClashService, ClashService>();
builder.Services.AddScoped<IClashEntryService, ClashEntryService>();
builder.Services.AddScoped<ICountryService, CountryService>();
builder.Services.AddScoped<IGenreService, GenreService>();
builder.Services.AddScoped<ILanguageService, LanguageService>();
builder.Services.AddScoped<IMovieService, MovieService>();
builder.Services.AddScoped<IStudioService, StudioService>();
builder.Services.AddScoped<IReviewService, ReviewService>();
builder.Services.AddScoped<IRoleService, RoleService>();
builder.Services.AddScoped<IMovieRecommendationService, MovieRecommendationService>();
builder.Services.AddScoped<IMovieRequestService, MovieRequestService>();
builder.Services.AddScoped<IActivityService, ActivityService>();
builder.Services.AddScoped<IListService, ListService>();
builder.Services.AddScoped<IDiaryService, DiaryService>();
builder.Services.AddScoped<IMovieIssueReportService, MovieIssueReportService>();
builder.Services.AddScoped<IUserReportService, UserReportService>();
builder.Services.AddHostedService<ClashStateWorkerService>();
builder.Services.AddScoped<IStatisticsService, StatisticsService>();

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<FlixDbContext>();
    await dbContext.Database.MigrateAsync();
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapScalarApiReference();
    app.MapOpenApi();
}

// HTTPS redirection is disabled because of the Flutter mobile development environment
//app.UseHttpsRedirection();

app.UseCors(CorsPolicy);

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();

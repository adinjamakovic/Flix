using Flix.CommonServices.CryptoService;
using Flix.Model.Requests;
using DotNetEnv;
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

Env.Load();

var builder = WebApplication.CreateBuilder(args);

var blobStorageConnectionString = builder.Configuration["BLOB_STORAGE_CONNECTION_STRING"];

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

builder.Services.AddSingleton(x =>
    new BlobServiceClient(blobStorageConnectionString));

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
    .Map(dest => dest.MoviesWatched, src => src.Reviews.Select(x => x.MovieId).Distinct().Count())
    .Map(dest => dest.ReviewsWritten, src => src.Reviews.Count(x => !string.IsNullOrWhiteSpace(x.Content)));
TypeAdapterConfig<User, UserSensitiveResponse>.NewConfig()
    .IgnoreNullValues(true)
    .Map(dest => dest.Role, src => src.Roles.Where(r => r.Role != null).Select(r => r.Role.Name).FirstOrDefault())
    .Map(dest => dest.RoleId, src => src.Roles.Select(r => (int?)r.RoleId).FirstOrDefault())
    .Map(dest => dest.MoviesWatched, src => src.Reviews.Select(x => x.MovieId).Distinct().Count())
    .Map(dest => dest.ReviewsWritten, src => src.Reviews.Count(x => !string.IsNullOrWhiteSpace(x.Content)));
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
TypeAdapterConfig<MovieInsertRequest, Movie>.NewConfig().Ignore(dest => dest.Poster!, dest => dest.HeaderImage!, dest => dest.Credits!);
TypeAdapterConfig<MovieUpdateRequest, Movie>.NewConfig().Ignore(dest => dest.Poster!, dest => dest.HeaderImage!, dest => dest.Credits!);
TypeAdapterConfig<StudioInsertRequest, Studio>.NewConfig().Ignore(dest => dest.Logo!);
TypeAdapterConfig<StudioUpdateRequest, Studio>.NewConfig().Ignore(dest => dest.Logo!);
TypeAdapterConfig<UserInsertRequest, User>.NewConfig().Ignore(dest => dest.ProfileImage!);
TypeAdapterConfig<UserUpdateRequest, User>.NewConfig().Ignore(dest => dest.ProfileImage!);

// DB Context
builder.Services.AddDbContext<FlixDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Validators
builder.Services.AddScoped<IValidator<UserInsertRequest>, UserInsertRequestValidator>();
builder.Services.AddScoped<IValidator<UserUpdateRequest>, UserUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<CastMemberInsertRequest>, CastMemberInsertRequestValidator>();
builder.Services.AddScoped<IValidator<CastMemberUpdateRequest>, CastMemberUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<ClashInsertRequest>, ClashInsertRequestValidator>();
builder.Services.AddScoped<IValidator<ClashUpdateRequest>, ClashUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<CountryInsertRequest>, CountryInsertRequestValidator>();
builder.Services.AddScoped<IValidator<CountryUpdateRequest>, CountryUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<GenreInsertRequest>, GenreInsertRequestValidator>();
builder.Services.AddScoped<IValidator<GenreUpdateRequest>, GenreUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<LanguageInsertRequest>, LanguageInsertRequestValidator>();
builder.Services.AddScoped<IValidator<LanguageUpdateRequest>, LanguageUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<MovieInsertRequest>, MovieInsertRequestValidator>();
builder.Services.AddScoped<IValidator<MovieUpdateRequest>, MovieUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<StudioInsertRequest>, StudioInsertRequestValidator>();
builder.Services.AddScoped<IValidator<StudioUpdateRequest>, StudioUpdateRequestValidator>();

//Services
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();
builder.Services.AddScoped<IImageStorageService, ImageStorageService>();
builder.Services.AddScoped<IResponseImageUrlResolver, ResponseImageUrlResolver>();
builder.Services.AddScoped<IRefreshTokenService, RefreshTokenService>();
builder.Services.AddScoped<IUserService, UserService>();
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

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapScalarApiReference();
    app.MapOpenApi();
}

// HTTPS redirection is disabled because of the Flutter mobile development environment
//app.UseHttpsRedirection();

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();

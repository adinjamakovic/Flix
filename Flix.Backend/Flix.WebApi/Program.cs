using Flix.CommonServices.CryptoService;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Services.Database;
using Flix.Services.Implementations;
using Flix.Services.Interfaces;
using Flix.Services.Validators;
using Flix.WebApi.Extensions;
using Flix.WebApi.Filters;
using Flix.WebApi.Services.AccessManager;
using FluentValidation;
using Mapster;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Scalar.AspNetCore;
using System.Text;
using Flix.Model.Enums;


var builder = WebApplication.CreateBuilder(args);

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
    .Map(dest => dest.Role, src => src.Roles.Where(r => r.Role != null).Select(r => r.Role.Name).FirstOrDefault());
TypeAdapterConfig<User, UserSensitiveResponse>.NewConfig()
    .IgnoreNullValues(true)
    .Map(dest => dest.Role, src => src.Roles.Where(r => r.Role != null).Select(r => r.Role.Name).FirstOrDefault());
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
builder.Services.AddScoped<IRefreshTokenService, RefreshTokenService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<ICastMemberService, CastMemberService>();
builder.Services.AddScoped<ICryptoService, CryptoService>();
builder.Services.AddScoped<IAccessManager, AccessManager>();
builder.Services.AddScoped<IClashService, ClashService>();
builder.Services.AddScoped<ICountryService, CountryService>();
builder.Services.AddScoped<IGenreService, GenreService>();
builder.Services.AddScoped<ILanguageService, LanguageService>();
builder.Services.AddScoped<IMovieService, MovieService>();
builder.Services.AddScoped<IStudioService, StudioService>();


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapScalarApiReference();
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.UseAuthentication();

app.UseAuthorization();

app.MapControllers();

app.Run();

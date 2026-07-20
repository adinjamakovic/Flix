using Flix.CommonServices.CryptoService;
using Flix.Model.Requests;
using Flix.Model.Responses;
using Flix.Services.Database;
using Flix.Services.Implementations;
using Flix.Services.Interfaces;
using Flix.Services.Validators;
using Flix.WebApi.Extensions;
using Flix.WebApi.Services.AccessManager;
using FluentValidation;
using Mapster;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Scalar.AspNetCore;
using System.Text;


var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
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
TypeAdapterConfig<User, UserResponse>.NewConfig().IgnoreNullValues(true);
TypeAdapterConfig<CastMember, CastMemberResponse>.NewConfig().IgnoreNullValues(true);

// DB Context
builder.Services.AddDbContext<FlixDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// Validators
builder.Services.AddScoped<IValidator<UserInsertRequest>, UserInsertRequestValidator>();
builder.Services.AddScoped<IValidator<UserUpdateRequest>, UserUpdateRequestValidator>();
builder.Services.AddScoped<IValidator<CastMemberInsertRequest>, CastMemberInsertRequestValidator>();
builder.Services.AddScoped<IValidator<CastMemberUpdateRequest>, CastMemberUpdateRequestValidator>();

//Services
builder.Services.AddScoped<IRefreshTokenService, RefreshTokenService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<ICastMemberService, CastMemberService>();
builder.Services.AddScoped<ICryptoService, CryptoService>();
builder.Services.AddScoped<IAccessManager, AccessManager>();

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

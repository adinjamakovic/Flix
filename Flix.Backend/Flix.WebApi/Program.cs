using Flix.Model.Requests;
using Flix.Services.Database;
using Flix.Services.Implementations;
using Flix.Services.Interfaces;
using Flix.Services.Validators;
using FluentValidation;
using Mapster;
using Microsoft.EntityFrameworkCore;
using Scalar.AspNetCore;


var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();
builder.Services.AddMapster();

builder.Services.AddDbContext<FlixDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

builder.Services.AddScoped<IValidator<UserInsertRequest>, UserInsertRequestValidator>();
builder.Services.AddScoped<IValidator<UserUpdateRequest>, UserUpdateRequestValidator>();
builder.Services.AddScoped<IUserService, UserService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapScalarApiReference();
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();

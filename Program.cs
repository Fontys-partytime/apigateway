//using JwtAuthenticationManager;
using Ocelot.DependencyInjection;
using Ocelot.Middleware;
using Partytime.Common.JwtAuthentication;

var MyAllowSpecificOrigins = "_myAllowSpecificOrigins";
var builder = WebApplication.CreateBuilder(args);
builder.Configuration.SetBasePath(builder.Environment.ContentRootPath)
    .AddJsonFile("ocelot.json", optional: false, reloadOnChange: true)
    .AddEnvironmentVariables();

builder.Services.AddCors(options =>
{
    options.AddPolicy(name: MyAllowSpecificOrigins,
        builder => builder.WithOrigins("http://localhost:3000")
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials());
});

builder.Services.AddOcelot(builder.Configuration);
builder.Services.AddCustomJwtAuthentication();

var app = builder.Build();
app.UseCors(MyAllowSpecificOrigins);

app.UseOcelot().Wait();

app.UseAuthentication();
app.UseAuthorization();

app.Run();
using CareWell.API.Filters;
using CareWell.BusinessService;
using CareWell.DocumentIntelligence;
using CareWell.Notifications;
using CareWell.Notifications.Email;
using CareWell.Notifications.Push;
using CareWell.Repository;
using CareWell.Security;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.DataProtection;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Net;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

builder.Services.Configure<ApiBehaviorOptions>(options =>
{
    options.SuppressModelStateInvalidFilter = true;
});

// Add services to the container.

builder.Services.AddControllers(options =>
{
    options.Filters.Add<ApiResultFilter>();
    options.Filters.Add<UserContextRequestFilter>();
});

builder.Services.AddRepositories();
builder.Services.AddBusinessServices();
builder.Services.AddNotifications();
builder.Services.AddDocumentIntelligences();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.Configure<EmailOptions>(builder.Configuration.GetSection("Email"));
builder.Services.Configure<IAOptions>(builder.Configuration.GetSection("IA"));
builder.Services.Configure<PushOptions>(builder.Configuration.GetSection("Push"));

builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto;
    options.KnownProxies.Clear();
    options.KnownProxies.Add(IPAddress.Loopback);
});

if (!builder.Environment.IsDevelopment())
{
    builder.Services.AddDataProtection()
        .PersistKeysToFileSystem(new DirectoryInfo("/var/lib/carewell/keys"));
}

builder.Services.AddHealthChecks()
    .AddDbContextCheck<CareWellDbContext>();

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

#region ConnectionString

var connectionString = builder.Configuration.GetConnectionString("CareWellDb");

builder.Services.AddDbContext<CareWellDbContext>(options => options.UseLazyLoadingProxies().UseSqlServer(connectionString));

#endregion

#region Securizacion

var jwtKey = builder.Configuration["Jwt:Key"]!;
var jwtIssuer = builder.Configuration["Jwt:Issuer"]!;
var jwtAudience = builder.Configuration["Jwt:Audience"]!;

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = jwtIssuer,
            ValidAudience = jwtAudience,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            ClockSkew = TimeSpan.Zero
        };
    });

builder.Services.AddAuthorizationBuilder().SetFallbackPolicy(new AuthorizationPolicyBuilder().RequireAuthenticatedUser().Build());

#endregion

#region UserContext

builder.Services.AddScoped<UserContext>();
builder.Services.AddScoped<IUserContextWriter>(sp => sp.GetRequiredService<UserContext>());
builder.Services.AddScoped<IUserContext>(sp => sp.GetRequiredService<UserContext>());

#endregion

var app = builder.Build();
app.UseForwardedHeaders();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseSwagger();
    app.UseSwaggerUI();
}
else
{
    app.UseHttpsRedirection();
}

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHealthChecks("/health").AllowAnonymous();

app.Run();

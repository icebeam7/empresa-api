using EmpresaApi.Data;
using EmpresaApi.Endpoints;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// EF Core + SQLite
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlite(connectionString));

var app = builder.Build();

// Ensure DB is created (for demo/simple local use)
using (var scope = app.Services.CreateScope())
{
	var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
	db.Database.EnsureCreated();
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
	app.UseSwagger();
	app.UseSwaggerUI();
}

// Minimal API endpoints
app.MapGet("/", () => "Hello World!");
app.MapContactos();

app.Run();

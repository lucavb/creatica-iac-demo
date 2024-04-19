var builder = WebApplication.CreateBuilder(args);

builder.Services.AddHttpClient();
builder.Services.AddSingleton<WeatherService>();

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapGet("/weatherforecast", async (WeatherService weatherService, double? latitude, double? longitude) =>
{
    // Set default values if none provided
    double lat = latitude ?? 48.1351;
    double lon = longitude ?? 11.5820;

    // Example coordinates for Munich, Germany
    var forecast = await weatherService.GetCurrentWeatherAsync(lat, lon);
    return forecast;
})
.WithName("GetWeatherForecast")
.WithOpenApi();

app.Run("http://*:3000");

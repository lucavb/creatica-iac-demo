using System.Net.Http;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

public class WeatherService
{
    private readonly HttpClient _httpClient;

    public WeatherService(IHttpClientFactory httpClientFactory)
    {
        _httpClient = httpClientFactory.CreateClient();
    }

    public async Task<WeatherForecast?> GetCurrentWeatherAsync(double latitude, double longitude)
    {
        var url =
            $"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current_weather=true";
        var response = await _httpClient.GetFromJsonAsync<OpenMeteoResponse>(url);
        if (response?.CurrentWeather != null)
        {
            return new WeatherForecast(
                DateOnly.FromDateTime(DateTime.Parse(response.CurrentWeather.Time)),
                (int)Math.Round(response.CurrentWeather.Temperature),
                GetWeatherSummary(response.CurrentWeather.WeatherCode)
            );
        }
        return null;
    }

    private string GetWeatherSummary(int code)
    {
        // Example of mapping weather codes to summary descriptions
        return code switch
        {
            0 => "Clear sky",
            1 => "Mainly clear",
            2 => "Partly cloudy",
            3 => "Overcast",
            45 => "Fog",
            48 => "Depositing rime fog",
            51 => "Light drizzle",
            56 => "Light freezing drizzle",
            61 => "Light rain",
            66 => "Light freezing rain",
            80 => "Light rain showers",
            _ => "Unknown"
        };
    }
}

public record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}

public class OpenMeteoResponse
{
    [JsonPropertyName("current_weather")]
    public CurrentWeather? CurrentWeather { get; set; }
}

public class CurrentWeather
{
    [JsonPropertyName("time")]
    public string Time { get; set; }

    [JsonPropertyName("interval")]
    public int Interval { get; set; }

    [JsonPropertyName("temperature")]
    public double Temperature { get; set; }

    [JsonPropertyName("windspeed")]
    public double Windspeed { get; set; }

    [JsonPropertyName("winddirection")]
    public int Winddirection { get; set; }

    [JsonPropertyName("is_day")]
    public int IsDay { get; set; }

    [JsonPropertyName("weathercode")]
    public int WeatherCode { get; set; }
}

# Creatica goes Infrastructure-as-Code

## Weather App

An app written in C# that uses the [Open-Meteo][open-meteo] API to get the weather for a given location.

1. Build the Docker image.

```bash
docker build --tag weather .
```

2. Run the Docker container.

```bash
docker run --name weather -d -p 8080:3000 weather
```

3. cURL the endpoint to get the weather:

```bash
curl http://localhost:8080/weatherforecast\?latitude\=48.1\&longitude\=11.6
```

[open-meteo]: https://open-meteo.com/

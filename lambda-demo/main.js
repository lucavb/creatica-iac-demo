'use strict';

// https://docs.aws.amazon.com/lambda/latest/dg/services-apigateway.html#apigateway-example-event
exports.handler = async (event) => {
  // default coordinates for Munich, Germany
  const latitude = event['queryStringParameters']?.['latitude'] ?? 48.1351;
  const longitude = event['queryStringParameters']?.['longitude'] ?? 11.582;
  const response = await fetch(
    `https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current_weather=true`
  );

  const weather = await response.json();

  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8',
    },
    body: `<ul>
    <li>Date: ${weather['current_weather']['time']}</li>
    <li>Temperature: ${weather['current_weather']['temperature']} ${
      weather['current_weather_units']['temperature']
    }</li>
    <li>Summary: ${summaries[weather['current_weather']['weathercode']] ?? 'unknown'}</li>
    </ul>`,
  };
};

const summaries = {
  0: 'Clear sky',
  1: 'Mainly clear',
  2: 'Partly cloudy',
  3: 'Overcast',
  45: 'Fog',
  48: 'Depositing rime fog',
  51: 'Light drizzle',
  56: 'Light freezing drizzle',
  61: 'Light rain',
  66: 'Light freezing rain',
  80: 'Light rain showers',
};

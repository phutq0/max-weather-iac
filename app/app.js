import express from 'express';
import axios from 'axios';
import cors from 'cors';

const PORT = process.env.PORT || 3000;
const OPENWEATHER_API_KEY = process.env.OPENWEATHER_API_KEY || '';
const OPENWEATHER_BASE_URL = process.env.OPENWEATHER_BASE_URL || 'https://api.openweathermap.org/data/2.5';

const app = express();
app.use(express.json());
app.use(cors());

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// Minimal proxy/mock endpoint
app.get('/api/v1/weather', async (req, res) => {
  const { q, lat, lon, units = 'metric' } = req.query;
  // If an API key is provided, proxy to OpenWeather; otherwise return a mock
  if (OPENWEATHER_API_KEY) {
    try {
      const params = { appid: OPENWEATHER_API_KEY, units };
      if (q) params.q = q;
      if (lat && lon) { params.lat = lat; params.lon = lon; }
      const url = `${OPENWEATHER_BASE_URL}/weather`;
      const resp = await axios.get(url, { params, timeout: 5000 });
      return res.status(resp.status).json(resp.data);
    } catch (err) {
      const status = err.response?.status || 502;
      return res.status(status).json({ message: 'Upstream error', detail: err.message });
    }
  }
  // Mock response
  res.json({
    city: q || 'MockCity',
    lat: lat || 0,
    lon: lon || 0,
    units,
    current: { temp: 25, condition: 'Clear' }
  });
});

app.listen(PORT, () => {
  // eslint-disable-next-line no-console
  console.log(`Weather API (mock/proxy) listening on ${PORT}`);
});


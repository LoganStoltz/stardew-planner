import dotenv from 'dotenv';
import { Client, GatewayIntentBits } from 'discord.js';

dotenv.config({
  path: '/home/ec2-user/stardewbot/.env'
});

console.log('TOKEN LOADED:', !!process.env.DISCORD_TOKEN);

const VALID_SEASONS = new Set(['spring', 'summer', 'fall', 'winter']);

const API_BASE_URL = (process.env.API_BASE_URL || 'https://api.stardewvalleyplanner.com')
  .replace(/\/$/, '');

function formatGold(value) {
  return `${Number(value || 0).toLocaleString()}g`;
}

async function fetchBestCrops(season, day) {
  const url = `${API_BASE_URL}/api/best-crops?` + new URLSearchParams({
    season,
    days: String(day),
    year: '1', 
    budget: 'null',
    includeAncientFruit: 'true',
    includeSweetGemBerry: 'true',
    includeOasis: 'false'
  });

  const response = await fetch(url);
  const data = await response.json();

  if (!response.ok || data.error) {
    throw new Error(data.error || `Backend request failed (${response.status})`);
  }

  return data;
}

function buildBestCropsReply(result, season) {
  const leaderboard = Array.isArray(result.top_crops)
    ? result.top_crops
        .map(
          (crop, index) =>
            `${index + 1}. ${crop.name} - ${formatGold(crop.profit)} profit per seed`
        )
        .join('\n')
    : 'No crops returned.';

  return [
    `🌱 Top 5 crops for ${season} (day ${result.day_in_season})`,
    `🏆 Best crop: ${result.best_crop} (${formatGold(result.profit)} profit per seed)`,
    `📅 Days remaining: ${result.days_remaining}`,
    '',
    leaderboard
  ].join('\n');
}

function buildBestCropsErrorReply(error) {
  if (error instanceof TypeError) {
    return `Could not reach API at ${API_BASE_URL}. Is the server running?`;
  }
  return error.message || 'Something went wrong while fetching crop rankings.';
}

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages,
    GatewayIntentBits.MessageContent
  ]
});

client.once('ready', () => {
  console.log(`Logged in as ${client.user.tag}`);
});

client.login(process.env.DISCORD_TOKEN);

client.on('messageCreate', async (message) => {
  if (message.author.bot) return;
  if (!message.content.startsWith('/')) return;

  const args = message.content.slice(1).split(/ +/);
  const command = args.shift().toLowerCase();

  if (command === 'ping') {
    return message.reply('pong');
  }

  if (command === 'bestcrops') {
    const season = args[0]?.toLowerCase();
    const day = Number.parseInt(args[1], 10);

    if (!VALID_SEASONS.has(season)) {
      return message.reply(
        'Usage: `/bestcrops <season> <day>` (spring, summer, fall, winter)'
      );
    }

    if (!Number.isInteger(day) || day < 1 || day > 28) {
      return message.reply('Day must be 1–28. Example: `/bestcrops summer 12`');
    }

    try {
      const result = await fetchBestCrops(season, day);
      return message.reply(buildBestCropsReply(result, season));
    } catch (error) {
      return message.reply(buildBestCropsErrorReply(error));
    }
  }
});
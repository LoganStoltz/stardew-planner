import dotenv from 'dotenv';

dotenv.config({
  path: '/home/ec2-user/stardewbot/.env'
});
console.log('TOKEN LOADED:', process.env.DISCORD_TOKEN);

import { Client, GatewayIntentBits } from 'discord.js';

const VALID_SEASONS = new Set(['spring', 'summer', 'fall', 'winter']);
const API_BASE_URL = (process.env.API_BASE_URL || 'http://3.142.121.136:4567').replace(/\/$/, '');

function formatGold(value) {
    return `${Number(value || 0).toLocaleString()}g`;
}

async function fetchBestCrops(season, day) {
    const url = new URL('/api/best-crops', `${API_BASE_URL}/`);
    url.searchParams.set('season', season);
    url.searchParams.set('days', String(day));

    const response = await fetch(url);
    const data = await response.json();

    if (!response.ok || data.error) {
        throw new Error(data.error || `Backend request failed with status ${response.status}`);
    }

    return data;
}

function buildBestCropsReply(result) {
    const leaderboard = Array.isArray(result.top_crops)
        ? result.top_crops
            .map((crop, index) => `${index + 1}. ${crop.name} - ${formatGold(crop.profit)} profit per seed`)
            .join('\n')
        : 'No crops returned.';

    return [
        `Top 5 crops for ${result.season} on day ${result.day_in_season}`,
        `Best crop: ${result.best_crop} (${formatGold(result.profit)} profit per seed)`,
        `Days remaining: ${result.days_remaining}`,
        '',
        leaderboard
    ].join('\n');
}

function buildBestCropsErrorReply(error) {
    if (error instanceof TypeError) {
        return `Could not reach ${API_BASE_URL}. Make sure your Sinatra server is running.`;
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

client.once("ready", () => {
    console.log(`Logged in as ${client.user.tag}`);
});

client.login(process.env.DISCORD_TOKEN);

client.on("messageCreate", async (message) => {
    if (message.author.bot) return;

    if(!message.content.startsWith("/")) return;

    const args = message.content.slice(1).split(/ +/);
    const command = args.shift().toLowerCase();

    if(command === "ping") {
        message.reply("pong");
        return;
    }

    if (command === "bestcrops") {
        const season = args[0]?.toLowerCase();
        const day = Number.parseInt(args[1], 10);

        if (!VALID_SEASONS.has(season)) {
            await message.reply('Use `/bestcrops <season> <day>` with season set to spring, summer, fall, or winter.');
            return;
        }

        if (!Number.isInteger(day) || day < 1 || day > 28) {
            await message.reply('Day must be a number from 1 to 28. Example: `/bestcrops summer 12`.');
            return;
        }

        try {
            const result = await fetchBestCrops(season, day);
            await message.reply(buildBestCropsReply({ ...result, season }));
        } catch (error) {
            await message.reply(buildBestCropsErrorReply(error));
        }
    }
});
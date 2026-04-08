import dotenv from 'dotenv';
dotenv.config();

import { Client, GatewayIntentBits } from 'discord.js';

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
    }
});
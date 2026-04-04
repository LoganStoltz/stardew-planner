# Stardew Planner

Stardew Planner is a **min-max crop profit planner** for Stardew Valley. It’s focused on answering questions like:

- *What’s the most profitable crop to plant this season?*
- *If I plant X, how much gold should I expect to make after Y harvests?*
- *What’s the best greenhouse crop and what will it yield over time?*

The project uses a **Ruby on Rails backend** as the source of truth, with a web frontend that reads from the backend (API-style). A planned next step is a **Discord bot** that can pull the same crop/yield/profit data directly from Rails—similar to how the frontend does it.

## What it does

- **Best crop by season:** compare crops to determine top profit options for Spring/Summer/Fall (and greenhouse setups)
- **Profit + yield estimates:** calculate expected profit and output for any crop based on growth time and regrowth behavior
- **Greenhouse planning:** estimate what you can expect to yield from greenhouse plantings over time
- **Backend-driven:** calculations/data are served from Rails so multiple clients (web + bot) can reuse the same logic

> Status: the main planner functionality is largely implemented. Remaining major feature: **Discord bot integration**.

## Tech Stack

- **Backend:** Ruby on Rails
- **Frontend:** Vue.js
- **Database:** (file-based JSON storage, NO database)

## Core Concepts (Planner Logic)

The planner revolves around a few core calculations:

- **Season crop ranking:** compute and compare profit across crops available in a given season
- **Single-harvest vs regrowth crops:** handle crops that regrow differently than one-time harvest crops
- **Greenhouse projections:** estimate yields over time where season restrictions don’t apply (depending on crop rules)

I currently have no feature for adding fertilizer / speed-gro / artisan goods to the revenue calculations, once the core features are complete this will be the next area of develepment.

## API / Data Flow

The frontend pulls crop and calculation results from the Rails backend. The upcoming Discord bot will call the same endpoints.

### Planned: Discord bot client
A Discord bot that reads from the Rails backend similarly to the frontend.

Possible commands:
- `/bestcrop <season>` — show the top crop(s) for a season
- `/profit <crop> <days|season>` — estimate profit over a time window
- `/greenhouse <crop> <days>` — greenhouse yield/profit estimate over N days
- `/compare <crop1> <crop2>` — quick comparison summary

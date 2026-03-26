# Crop Data Schema

Each crop record has a small core shape that the planner can always use:

- `name`
- `seasons`
- `economy.seed_price`
- `economy.growth_days`
- `economy.regrow_days`
- `economy.yield`
- `economy.sell_prices`
- `traits.giant_crop`

Use `availability` only when a crop has special access rules that matter to planning.

## Availability Shape

```json
{
  "availability": {
    "sources": [
      {
        "type": "shop",
        "vendor": "Sandy",
        "location": "Oasis"
      },
      {
        "type": "festival",
        "event": "Egg Festival"
      }
    ],
    "requirements": [
      {
        "type": "year",
        "min": 2,
        "label": "Year 2 or later"
      },
      {
        "type": "quest",
        "key": "bus_repaired",
        "label": "Bus repaired"
      }
    ]
  }
}
```

This keeps normal crops small while still supporting special cases like merchants, mine drops, festivals, and unlock gates.
<script setup>
import { ref } from 'vue'

const season = ref('spring')
const dayInSeason = ref(1)
const year = ref(1)
const includeAncientFruit = ref(true)
const includeSweetGemBerry = ref(true)
const oasisAccess = ref(false)
const budget = ref(0)
const result = ref(null)

const seasons = ['spring', 'summer', 'fall', 'winter']

async function fetchData() {
  const params = new URLSearchParams({
    season: season.value,
    days: dayInSeason.value,
    budget: budget.value,
    includeAncientFruit: includeAncientFruit.value,
    includeSweetGemBerry: includeSweetGemBerry.value,
  })

  const res = await fetch(`http://localhost:4567/api/best-crops?${params.toString()}`)
  result.value = await res.json()
}
</script>

<template>
  <section class="page-grid">
    <div class="form-section">
      <div class="section-heading">
        <p class="kicker">Current Tool</p>
        <h2>Season Crop Planner</h2>
        <p>Compare the best crop for the current season based on the time left and your budget.</p>
      </div>

      <div class="form-group">
        <label for="season">Season</label>
        <select id="season" v-model="season">
          <option v-for="s in seasons" :key="s" :value="s">
            {{ s.charAt(0).toUpperCase() + s.slice(1) }}
          </option>
        </select>
      </div>

      <div class="form-group">
        <label for="day">What day of the season is it?</label>
        <input id="day" v-model.number="dayInSeason" type="number" min="1" max="28" />
      </div>

      <div class="form-group">
        <label for="year">Year</label>
        <input id="year" v-model.number="year" type="number" min="1" />
      </div>

      <div class="form-group">
        <label for="budget">Budget (gold)</label>
        <input id="budget" v-model.number="budget" type="number" min="0" />
      </div>

      <div class="form-group checkbox">
        <input id="ancient-fruit" v-model="includeAncientFruit" type="checkbox" />
        <label for="ancient-fruit">Include Ancient Fruit in search</label>
      </div>

      <div class="form-group checkbox">
        <input id="sweet-gem-berry" v-model="includeSweetGemBerry" type="checkbox" />
        <label for="sweet-gem-berry">Include Sweet Gem Berry in search</label>
      </div>

      <div class="form-group checkbox">
        <input id="oasis-access" v-model="oasisAccess" type="checkbox" />
        <label for="oasis-access">Do you have access to the Oasis?</label>
      </div>

      <div class="form-group">
        <button class="fetch-button" @click="fetchData">Find Best Crop</button>
      </div>
    </div>

    <div class="results-section">
      <div v-if="result">
        <p v-if="result.error" class="error">{{ result.error }}</p>
        <div v-else>
          <p><strong>Best Crop:</strong> {{ result.best_crop }}</p>
          <p><strong>Profit (per seed):</strong> {{ result.profit }} gold</p>
          <p><strong>Harvests:</strong> {{ result.harvests }}</p>

          <div v-if="result.revenue !== undefined" class="math-section">
            <p><strong>Math Breakdown</strong></p>
            <p>Day {{ result.day_in_season }} means {{ result.days_remaining }} day(s) remaining in season.</p>
            <p><strong>Revenue</strong> = harvests × minimum yield × sell price = {{ result.harvests }} × {{ result.yield }} × {{ result.sell_price }} = {{ result.revenue }} gold</p>
            <p><strong>Profit per seed</strong> = revenue − seed price = {{ result.revenue }} − {{ result.seed_price }} = {{ result.profit }} gold</p>
          </div>

          <div v-if="budget > 0 && result.seeds_affordable !== undefined" class="budget-section">
            <p><strong>Seeds Affordable:</strong> {{ result.seeds_affordable }}</p>
            <p><strong>Total Seed Cost:</strong> {{ result.total_seed_cost }} gold</p>
            <p><strong>Lowest Total Profit:</strong> {{ result.lowest_profit }} gold</p>
          </div>
        </div>
      </div>

      <div v-else class="empty-state">
        <p class="empty-title">Planner output will show here.</p>
        <p>The existing crop planner stays functional while the new greenhouse tool lives on its own page.</p>
      </div>
    </div>
  </section>
</template>

<style scoped>
.page-grid {
  display: grid;
  grid-template-columns: minmax(320px, 520px) minmax(280px, 1fr);
  gap: 24px;
}

.form-section,
.results-section {
  border-radius: 24px;
  padding: 28px;
  box-shadow: 0 18px 45px rgba(85, 58, 24, 0.12);
}

.form-section {
  background: linear-gradient(180deg, rgba(255, 249, 240, 0.98) 0%, rgba(247, 234, 217, 0.95) 100%);
  border: 1px solid rgba(117, 83, 41, 0.18);
}

.results-section {
  background: linear-gradient(180deg, rgba(227, 244, 224, 0.98) 0%, rgba(209, 235, 206, 0.95) 100%);
  border: 1px solid rgba(71, 128, 78, 0.2);
}

.section-heading {
  margin-bottom: 24px;
}

.kicker {
  margin: 0 0 8px;
  color: #916a3e;
  font-size: 0.8rem;
  font-weight: 700;
  letter-spacing: 0.16em;
  text-transform: uppercase;
}

.section-heading h2 {
  margin: 0 0 10px;
  color: #3e2c19;
  font-size: 2rem;
}

.section-heading p,
.empty-state p,
.results-section p {
  margin: 0;
  color: #4a4339;
  line-height: 1.6;
}

.form-group {
  margin-bottom: 18px;
  display: flex;
  flex-direction: column;
}

.form-group:last-child {
  margin-bottom: 0;
}

.form-group.checkbox {
  flex-direction: row;
  align-items: center;
  gap: 12px;
}

.form-group label {
  margin-bottom: 8px;
  color: #573d1f;
  font-weight: 700;
}

.form-group.checkbox label {
  margin-bottom: 0;
  font-weight: 600;
}

.form-group input,
.form-group select,
.fetch-button {
  min-height: 48px;
  border-radius: 14px;
  font: inherit;
}

.form-group input,
.form-group select {
  padding: 12px 14px;
  border: 1px solid rgba(117, 83, 41, 0.22);
  background: rgba(255, 253, 248, 0.95);
  color: #2d241c;
}

.form-group.checkbox input {
  width: 20px;
  height: 20px;
  margin: 0;
  accent-color: #8d6639;
}

.fetch-button {
  border: none;
  background: linear-gradient(135deg, #8f6739 0%, #6e4f2b 100%);
  color: #fff9f0;
  font-weight: 700;
  cursor: pointer;
}

.empty-state {
  display: grid;
  align-content: center;
  min-height: 100%;
}

.empty-title {
  margin-bottom: 10px;
  color: #22582a;
  font-size: 1.5rem;
  font-weight: 700;
}

.error {
  padding: 16px;
  border-radius: 16px;
  background: rgba(255, 236, 236, 0.92);
  color: #9a2222;
}

.math-section,
.budget-section {
  margin-top: 18px;
  padding-top: 18px;
  border-top: 1px dashed rgba(34, 88, 42, 0.25);
}

.results-section p + p {
  margin-top: 12px;
}

@media (max-width: 900px) {
  .page-grid {
    grid-template-columns: 1fr;
  }
}
</style>
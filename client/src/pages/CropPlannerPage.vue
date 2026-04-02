<script setup>
import { ref } from 'vue'

const season = ref('spring')
const dayInSeason = ref(1)
const year = ref(1)
const includeAncientFruit = ref(true)
const includeSweetGemBerry = ref(true)
const oasisAccess = ref(false)
const budget = ref(null)
const result = ref(null)
const selectedCrop = ref(null)
const searchedSeason = ref(null)

const seasons = ['spring', 'summer', 'fall', 'winter']

function selectCrop(crop) {
  selectedCrop.value = crop
}

const displayed = {
  get best_crop() { return selectedCrop.value?.name ?? result.value?.best_crop },
  get profit()    { return selectedCrop.value?.profit ?? result.value?.profit },
  get harvests()  { return selectedCrop.value?.harvests ?? result.value?.harvests },
  get revenue()   { return selectedCrop.value?.revenue ?? result.value?.revenue },
  get yield()     { return selectedCrop.value?.yield ?? result.value?.yield },
  get sell_price(){ return selectedCrop.value?.sell_price ?? result.value?.sell_price },
  get seed_price(){ return selectedCrop.value?.seed_price ?? result.value?.seed_price },
}

async function fetchData() {
  searchedSeason.value = season.value

  const params = new URLSearchParams({
    season: season.value,
    days: dayInSeason.value,
    year: year.value,
    budget: budget.value,
    includeAncientFruit: includeAncientFruit.value,
    includeSweetGemBerry: includeSweetGemBerry.value,
    includeOasis: oasisAccess.value,
  })

  const res = await fetch(`http://localhost:4567/api/best-crops?${params.toString()}`)
  result.value = await res.json()
  selectedCrop.value = null
}
</script>

<template>
  <section class="page-grid">
    <div class="form-section">
      <div class="section-heading">
        <h2>Season Crop Planner</h2>
        <p>Compare the best crop for the current season based on the time left and your budget.</p>
      </div>

      <div class="form-grid">
        <div class="form-group">
          <label for="season">Season</label>
          <select id="season" v-model="season">
            <option v-for="s in seasons" :key="s" :value="s">
              {{ s.charAt(0).toUpperCase() + s.slice(1) }}
            </option>
          </select>
        </div>

        <div class="form-group">
          <label for="day">Day in season</label>
          <input id="day" v-model.number="dayInSeason" type="number" min="1" max="28" />
        </div>

        <div class="form-group">
          <label for="year">Year</label>
          <input id="year" v-model.number="year" type="number" min="1" />
        </div>

        <div class="form-group">
          <label for="budget">Budget (gold) <span class="optional-hint">(optional)</span></label>
          <input id="budget" v-model.number="budget" type="number" min="0" placeholder="Leave blank to skip" />
        </div>
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
        <div v-if="searchedSeason === 'winter'" class="winter-notice">
          <p><strong>Winter has no farmable crops outdoors.</strong> Consider using the Greenhouse to keep income going - check the Greenhouse Revenue page for planning help. Otherwise you may need to look elsewhere for gold this season. (Fishing, Foraging, etc...)</p>
        </div>

        <p v-if="result.error && searchedSeason !== 'winter'" class="error">{{ result.error }}</p>
        <div v-if="!result.error">
          <div class="best-crop-hero">
            <p class="best-crop-kicker">{{ selectedCrop ? 'Selected Crop' : 'Best Crop' }}</p>
            <h3 class="best-crop-name">{{ displayed.best_crop }}</h3>
            <div class="best-crop-stats">
              <span><strong>{{ displayed.profit }}</strong> gold profit/seed</span>
              <span><strong>{{ displayed.harvests }}</strong> harvest{{ displayed.harvests !== 1 ? 's' : '' }}</span>
            </div>
          </div>

          <div v-if="displayed.revenue !== undefined" class="math-section">
            <p><strong>{{ displayed.best_crop }} — Math Breakdown</strong></p>
            <p>Day {{ result.day_in_season }} — {{ result.days_remaining }} day(s) remaining in season.</p>

            <div class="math-row">
              <span class="math-label">Revenue</span>
              <span class="math-formula">{{ displayed.harvests }} harvests × {{ displayed.yield }} yield × {{ displayed.sell_price }}g</span>
              <span class="math-result">{{ displayed.revenue }} gold</span>
            </div>

            <div class="math-row">
              <span class="math-label">Profit per seed</span>
              <span class="math-formula">{{ displayed.revenue }}g revenue − {{ displayed.seed_price }}g seed cost</span>
              <span class="math-result">{{ displayed.profit }} gold</span>
            </div>
          </div>

          <div v-if="budget > 0 && result.seeds_affordable !== undefined" class="budget-section">
            <p><strong>Budget Breakdown</strong></p>

            <div class="math-row">
              <span class="math-label">Seeds affordable</span>
              <span class="math-formula">{{ budget }}g budget ÷ {{ displayed.seed_price }}g per seed</span>
              <span class="math-result">{{ result.seeds_affordable }}</span>
            </div>

            <div class="math-row">
              <span class="math-label">Total seed cost</span>
              <span class="math-formula">{{ result.seeds_affordable }} seeds × {{ displayed.seed_price }}g</span>
              <span class="math-result">{{ result.total_seed_cost }} gold</span>
            </div>

            <div class="math-row">
              <span class="math-label">Lowest total profit</span>
              <span class="math-formula">{{ result.seeds_affordable }} seeds × {{ displayed.profit }}g profit/seed</span>
              <span class="math-result">{{ result.lowest_profit }} gold</span>
            </div>
          </div>

          <div v-if="result.top_crops?.length" class="budget-section">
            <p><strong>Top 5 Crops — click to view details</strong></p>
            <ol class="top-crops-list">
              <li v-for="(crop, index) in result.top_crops" :key="crop.name">
                <button
                  class="crop-select-btn"
                  :class="{ active: (selectedCrop?.name ?? result.best_crop) === crop.name }"
                  @click="selectCrop(crop)"
                >
                  <span class="crop-rank">{{ index + 1 }}</span>
                  <span class="crop-select-name">{{ crop.name }}</span>
                  <span class="crop-select-profit">{{ crop.profit }} gold/seed</span>
                </button>
              </li>
            </ol>
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
  align-items: start;
}

.form-section,
.results-section {
  border-radius: 24px;
  padding: 24px;
  box-shadow: 0 18px 45px var(--color-shadow);
  border: 1px solid var(--color-panel-border);
  background: var(--color-panel);
}

.form-section {
  background: linear-gradient(180deg, var(--color-panel) 0%, rgba(255, 255, 255, 0.88) 100%);
}

.section-heading {
  margin-bottom: 16px;
}

.section-heading h2 {
  margin: 0 0 10px;
  color: var(--color-title);
  font-size: 2rem;
}

.section-heading p,
.empty-state p,
.results-section p {
  margin: 0;
  color: var(--color-text-muted);
  line-height: 1.6;
}

.form-group {
  margin-bottom: 12px;
  display: flex;
  flex-direction: column;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 10px 12px;
}

.form-group:last-child {
  margin-bottom: 0;
}

.form-group.checkbox {
  flex-direction: row;
  align-items: center;
  gap: 12px;
  margin-bottom: 10px;
}

.form-group label {
  margin-bottom: 8px;
  color: var(--color-label);
  font-weight: 700;
}

.optional-hint {
  font-weight: 400;
  font-size: 0.85em;
  color: var(--color-text-muted);
}

.form-group.checkbox label {
  margin-bottom: 0;
  font-weight: 600;
}

.form-group input,
.form-group select,
.fetch-button {
  min-height: 44px;
  border-radius: 14px;
  font: inherit;
}

.form-group input,
.form-group select {
  padding: 12px 14px;
  border: 1px solid var(--color-panel-border);
  background: var(--color-surface);
  color: var(--color-text);
}

.form-group.checkbox input {
  width: 20px;
  height: 20px;
  margin: 0;
  accent-color: var(--color-accent);
}

.fetch-button {
  border: none;
  background: linear-gradient(135deg, var(--color-accent) 0%, var(--color-accent-strong) 100%);
  color: var(--color-accent-contrast);
  font-weight: 700;
  cursor: pointer;
  width: 100%;
}

.empty-state {
  display: grid;
  align-content: center;
  min-height: 100%;
}

.best-crop-hero {
  padding: 14px 18px;
  border-radius: 14px;
  background: linear-gradient(135deg, var(--color-accent) 0%, var(--color-accent-strong) 100%);
  color: var(--color-accent-contrast);
  margin-bottom: 14px;
}

.best-crop-kicker {
  margin: 0 0 4px;
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.14em;
  text-transform: uppercase;
  opacity: 0.8;
  color: var(--color-accent-contrast) !important;
}

.best-crop-name {
  margin: 0 0 10px;
  font-size: 2rem;
  color: var(--color-accent-contrast);
  line-height: 1.1;
}

.best-crop-stats {
  display: flex;
  gap: 20px;
  font-size: 0.95rem;
  opacity: 0.9;
}

.best-crop-stats span strong {
  font-size: 1.1rem;
}

.empty-title {
  margin-bottom: 10px;
  color: var(--color-title);
  font-size: 1.5rem;
  font-weight: 700;
}

.error {
  padding: 16px;
  border-radius: 16px;
  background: var(--color-danger-bg);
  color: var(--color-danger-text);
}

.winter-notice {
  padding: 12px 16px;
  border-radius: 12px;
  border-left: 4px solid #1a87ec;
  border-right: 4px solid #1a87ec;
  background: #e8f1fb;
  color: #1a3a5c;
  margin-bottom: 14px;
}

.winter-notice p {
  margin: 0;
  color: #1a3a5c !important;
  line-height: 1.5;
}

.math-section,
.budget-section {
  margin-top: 14px;
  padding-top: 14px;
  border-top: 2px solid rgba(15, 118, 110, 0.18);
}

.math-row {
  display: grid;
  grid-template-columns: max-content 1fr max-content;
  align-items: baseline;
  gap: 6px 14px;
  margin-top: 8px;
  padding: 8px 12px;
  border-radius: 10px;
  background: var(--color-surface);
}

.math-label {
  font-weight: 700;
  color: var(--color-label);
  white-space: nowrap;
}

.math-formula {
  color: var(--color-text-muted);
  font-size: 0.92rem;
}

.math-result {
  font-weight: 700;
  color: var(--color-accent);
  white-space: nowrap;
}

.results-section p + p {
  margin-top: 8px;
}

.top-crops-list {
  margin: 12px 0 0;
  padding-left: 0;
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.crop-select-btn {
  display: flex;
  justify-content: flex-start;
  align-items: center;
  gap: 16px;
  width: 100%;
  padding: 10px 14px;
  border: 1px solid var(--color-panel-border);
  border-radius: 10px;
  background: var(--color-surface);
  color: var(--color-text);
  font: inherit;
  cursor: pointer;
  transition: border-color 0.15s, background 0.15s;
}

.crop-rank {
  width: 24px;
  height: 24px;
  border-radius: 999px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  font-weight: 700;
  background: rgba(15, 118, 110, 0.14);
  color: var(--color-accent-strong);
  flex: 0 0 24px;
}

.crop-select-btn:hover {
  border-color: var(--color-accent);
  background: var(--color-surface-soft);
}

.crop-select-btn.active {
  border-color: var(--color-accent);
  background: linear-gradient(135deg, var(--color-accent) 0%, var(--color-accent-strong) 100%);
  color: var(--color-accent-contrast);
}

.crop-select-btn.active .crop-rank {
  background: rgba(255, 255, 255, 0.22);
  color: var(--color-accent-contrast);
}

.crop-select-name {
  font-weight: 700;
}

.crop-select-profit {
  font-size: 0.9rem;
  opacity: 0.85;
  margin-left: auto;
}

@media (max-width: 900px) {
  .page-grid {
    grid-template-columns: 1fr;
  }

  .form-grid {
    grid-template-columns: 1fr;
  }
}
</style>
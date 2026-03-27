<script setup>
import { ref, onMounted } from 'vue'

const season = ref('spring')
const dayInSeason = ref(1)
const year = ref(1)
const includeAncientFruit = ref(true)
const budget = ref(0)
const result = ref(null)

const seasons = ['spring', 'summer', 'fall', 'winter']

async function fetchData() {
  const params = new URLSearchParams({
    season: season.value,
    days: dayInSeason.value,
    budget: budget.value,
  });
  
  const res = await fetch(
    `http://localhost:4567/api/best-crops?${params.toString()}`
  );
  result.value = await res.json();
}

onMounted(() => {
  fetchData();
});
</script>

<template>
  <div class="container">
    <h1>Stardew Planner 🌱</h1>

    <div class="form-section">
      <div class="form-group">
        <label for="season">Season:</label>
        <select v-model="season" id="season" @change="fetchData">
          <option v-for="s in seasons" :key="s" :value="s">
            {{ s.charAt(0).toUpperCase() + s.slice(1) }}
          </option>
        </select>
      </div>

      <div class="form-group">
        <label for="day">Day in Season:</label>
        <input v-model.number="dayInSeason" id="day" type="number" min="1" max="28" @change="fetchData" />
      </div>

      <div class="form-group">
        <label for="year">Year:</label>
        <input v-model.number="year" id="year" type="number" min="1" />
      </div>

      <div class="form-group">
        <label for="budget">Budget (gold):</label>
        <input v-model.number="budget" id="budget" type="number" min="0" @change="fetchData" />
      </div>

      <div class="form-group checkbox">
        <input v-model="includeAncientFruit" id="ancient-fruit" type="checkbox" />
        <label for="ancient-fruit">Include Ancient Fruit in search</label>
      </div>
    </div>

    <div v-if="result" class="results-section">
      <p v-if="result.error" class="error">{{ result.error }}</p>
      <div v-else>
        <p><strong>Best Crop:</strong> {{ result.best_crop }}</p>
        <p><strong>Profit (per seed):</strong> {{ result.profit }} gold</p>
        <p><strong>Harvests:</strong> {{ result.harvests }}</p>
        <div v-if="budget > 0 && result.seeds_affordable !== undefined" class="budget-section">
          <p><strong>Seeds Affordable:</strong> {{ result.seeds_affordable }}</p>
          <p><strong>Total Seed Cost:</strong> {{ result.total_seed_cost }} gold</p>
          <p><strong>Lowest Total Profit:</strong> {{ result.lowest_profit }} gold</p>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
* {
  box-sizing: border-box;
}

body {
  background: linear-gradient(135deg, #f5f1de 0%, #faf4ed 100%);
}

.container {
  max-width: 700px;
  margin: 0 auto;
  padding: 40px 20px;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  min-height: 100vh;
}

h1 {
  text-align: center;
  color: #5a4a2a;
  font-size: 2.5rem;
  margin-bottom: 30px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.1);
  letter-spacing: 1px;
}

.form-section {
  background: linear-gradient(135deg, #fff9f0 0%, #fef5ea 100%);
  padding: 30px;
  border-radius: 12px;
  margin-bottom: 30px;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
  border: 2px solid #e8d5c4;
}

.form-group {
  margin-bottom: 20px;
  display: flex;
  flex-direction: column;
}

.form-group:last-child {
  margin-bottom: 0;
}

.form-group.checkbox {
  flex-direction: row;
  align-items: center;
  margin-bottom: 8px;
}

.form-group.checkbox input {
  width: 20px;
  height: 20px;
  margin-right: 12px;
  cursor: pointer;
  accent-color: #a97a3f;
}

.form-group label {
  font-weight: 600;
  margin-bottom: 8px;
  color: #5a4a2a;
  font-size: 0.95rem;
  display: flex;
  align-items: center;
}

.form-group.checkbox label {
  margin-bottom: 0;
  font-weight: 500;
  cursor: pointer;
}

.form-group input,
.form-group select {
  padding: 12px 14px;
  border: 2px solid #d4c4b9;
  border-radius: 8px;
  font-size: 15px;
  background-color: white;
  color: #333;
  font-family: inherit;
  transition: all 0.3s ease;
}

.form-group input::placeholder {
  color: #999;
}

.form-group input:hover,
.form-group select:hover {
  border-color: #c4a58a;
  box-shadow: 0 4px 12px rgba(169, 122, 63, 0.1);
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: #a97a3f;
  box-shadow: 0 0 0 3px rgba(169, 122, 63, 0.15);
  background-color: #fffbf5;
}

.results-section {
  background: linear-gradient(135deg, #d4f1d4 0%, #c8e6c9 100%);
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 8px 24px rgba(76, 175, 80, 0.15);
  border: 2px solid #81c784;
  animation: slideIn 0.4s ease-out;
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.results-section p {
  margin: 14px 0;
  font-size: 16px;
  color: #1b5e20;
  line-height: 1.6;
}

.results-section p:first-child {
  margin-top: 0;
  font-size: 1.8rem;
  font-weight: 700;
  color: #2e7d32;
}

.results-section strong {
  color: #1b5e20;
  font-weight: 700;
}

.error {
  color: #b71c1c;
  background: linear-gradient(135deg, #ffebee 0%, #ffcdd2 100%);
  padding: 16px;
  border-radius: 8px;
  border-left: 4px solid #c62828;
  font-weight: 500;
  animation: slideIn 0.4s ease-out;
}

.budget-section {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 2px solid rgba(27, 94, 32, 0.3);
}

.budget-section p {
  margin: 10px 0;
  font-size: 15px;
}
</style>
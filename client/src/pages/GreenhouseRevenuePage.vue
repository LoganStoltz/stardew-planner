<script setup>
import { ref } from 'vue'

const cropName = ref('Ancient Fruit')
const cropCount = ref(116)
const harvestCount = ref(1)
const minimumYield = ref(1)
const sellPrice = ref(550)
const seedCost = ref(0)
const includeSeedCost = ref(false)
const notes = ref('')
</script>

<template>
  <section class="page-grid">
    <div class="panel form-panel">
      <div class="section-heading">
        <p class="kicker">New Tool Skeleton</p>
        <h2>Greenhouse Revenue Floor</h2>
        <p>Front-end shell for a lowest-revenue calculator based on a chosen crop and number planted.</p>
      </div>

      <div class="form-grid">
        <div class="form-group full-width">
          <label for="crop-name">Crop name</label>
          <input id="crop-name" v-model="cropName" type="text" placeholder="Ancient Fruit" />
        </div>

        <div class="form-group">
          <label for="crop-count">Number planted</label>
          <input id="crop-count" v-model.number="cropCount" type="number" min="1" />
        </div>

        <div class="form-group">
          <label for="harvest-count">Harvest cycles</label>
          <input id="harvest-count" v-model.number="harvestCount" type="number" min="1" />
        </div>

        <div class="form-group">
          <label for="minimum-yield">Minimum yield per harvest</label>
          <input id="minimum-yield" v-model.number="minimumYield" type="number" min="1" />
        </div>

        <div class="form-group">
          <label for="sell-price">Sell price per item</label>
          <input id="sell-price" v-model.number="sellPrice" type="number" min="0" />
        </div>

        <div class="form-group">
          <label for="seed-cost">Seed cost per crop</label>
          <input id="seed-cost" v-model.number="seedCost" type="number" min="0" />
        </div>

        <div class="form-group checkbox full-width">
          <input id="include-seed-cost" v-model="includeSeedCost" type="checkbox" />
          <label for="include-seed-cost">Include seed cost in the future calculation</label>
        </div>

        <div class="form-group full-width">
          <label for="notes">Notes</label>
          <textarea id="notes" v-model="notes" rows="4" placeholder="Optional notes for greenhouse runs or Discord bot parity."></textarea>
        </div>
      </div>

      <div class="button-row">
        <button type="button" class="primary-button">Calculate Lowest Revenue</button>
        <span class="helper-text">UI only for now. No calculation logic or API calls are wired yet.</span>
      </div>
    </div>

    <div class="panel preview-panel">
      <div class="preview-card">
        <p class="preview-label">Preview</p>
        <h3>{{ cropName || 'Selected crop' }}</h3>
        <p>{{ cropCount }} crops planted</p>
        <p>{{ harvestCount }} harvest cycle<span v-if="harvestCount !== 1">s</span></p>
      </div>

      <div class="placeholder-card">
        <p class="placeholder-label">Future output area</p>
        <h3>Lowest revenue result</h3>
        <p>This section is intentionally static until you decide how the greenhouse math should work.</p>

        <div class="placeholder-metric">
          <span>Estimated floor revenue</span>
          <strong>-- gold</strong>
        </div>

        <div class="placeholder-metric">
          <span>Seed cost toggle</span>
          <strong>{{ includeSeedCost ? 'Included' : 'Ignored' }}</strong>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.page-grid {
  display: grid;
  grid-template-columns: minmax(320px, 1.15fr) minmax(280px, 0.85fr);
  gap: 24px;
}

.panel {
  border-radius: 24px;
  padding: 28px;
  box-shadow: 0 20px 48px rgba(48, 65, 35, 0.12);
}

.form-panel {
  background: linear-gradient(180deg, rgba(249, 255, 245, 0.96) 0%, rgba(234, 245, 224, 0.98) 100%);
  border: 1px solid rgba(74, 112, 56, 0.16);
}

.preview-panel {
  display: grid;
  gap: 18px;
  align-content: start;
}

.preview-card,
.placeholder-card {
  border-radius: 24px;
  padding: 24px;
}

.preview-card {
  background: linear-gradient(135deg, rgba(255, 244, 218, 0.96) 0%, rgba(252, 232, 183, 0.92) 100%);
  border: 1px solid rgba(155, 120, 55, 0.18);
}

.placeholder-card {
  background: linear-gradient(135deg, rgba(34, 67, 33, 0.94) 0%, rgba(53, 96, 47, 0.96) 100%);
  color: #f4f6ef;
}

.kicker,
.preview-label,
.placeholder-label {
  margin: 0 0 8px;
  font-size: 0.8rem;
  font-weight: 700;
  letter-spacing: 0.16em;
  text-transform: uppercase;
}

.kicker {
  color: #587443;
}

.preview-label,
.placeholder-label {
  color: inherit;
  opacity: 0.72;
}

.section-heading {
  margin-bottom: 24px;
}

.section-heading h2,
.preview-card h3,
.placeholder-card h3 {
  margin: 0 0 10px;
  font-size: 2rem;
  color: #20331d;
}

.placeholder-card h3 {
  color: #f7f9f3;
}

.section-heading p,
.preview-card p,
.placeholder-card p {
  margin: 0;
  line-height: 1.6;
}

.form-grid {
  display: grid;
  grid-template-columns: repeat(2, minmax(0, 1fr));
  gap: 18px 16px;
}

.full-width {
  grid-column: 1 / -1;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  margin-bottom: 8px;
  color: #36502d;
  font-weight: 700;
}

.form-group input,
.form-group textarea,
.primary-button {
  min-height: 48px;
  border-radius: 14px;
  font: inherit;
}

.form-group input,
.form-group textarea {
  padding: 12px 14px;
  border: 1px solid rgba(74, 112, 56, 0.22);
  background: rgba(255, 255, 252, 0.92);
  color: #1f281d;
}

.form-group textarea {
  resize: vertical;
  min-height: 120px;
}

.form-group.checkbox {
  flex-direction: row;
  align-items: center;
  gap: 12px;
}

.form-group.checkbox label {
  margin-bottom: 0;
}

.form-group.checkbox input {
  width: 20px;
  height: 20px;
  min-height: 20px;
  margin: 0;
  accent-color: #5f7f45;
}

.button-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 14px;
  margin-top: 24px;
}

.primary-button {
  padding: 0 18px;
  border: none;
  background: linear-gradient(135deg, #56773d 0%, #3d5b2c 100%);
  color: #f6fbef;
  font-weight: 700;
  cursor: default;
}

.helper-text {
  color: #4a6043;
  line-height: 1.5;
}

.preview-card p + p,
.placeholder-card p + .placeholder-metric,
.placeholder-metric + .placeholder-metric {
  margin-top: 12px;
}

.placeholder-metric {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  padding-top: 14px;
  border-top: 1px solid rgba(244, 246, 239, 0.16);
}

.placeholder-metric strong {
  font-size: 1.1rem;
}

@media (max-width: 900px) {
  .page-grid {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 640px) {
  .form-grid {
    grid-template-columns: 1fr;
  }
}
</style>
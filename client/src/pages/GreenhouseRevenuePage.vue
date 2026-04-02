<script setup>
import { onMounted, ref } from 'vue'

const cropName = ref('Ancient Fruit')
const cropCount = ref(116)
const harvestCount = ref(1)

const crops = ref([])
const isLoadingCrops = ref(false)
const cropsLoadError = ref('')

async function loadCrops() {
  isLoadingCrops.value = true
  cropsLoadError.value = ''

  try {
    const response = await fetch('http://localhost:4567/api/crops')
    if (!response.ok) {
      throw new Error(`Request failed with status ${response.status}`)
    }

    const data = await response.json()
    crops.value = Array.isArray(data) ? data : []

    if (crops.value.length > 0) {
      const cropExists = crops.value.some((crop) => crop.name === cropName.value)
      if (!cropExists) {
        cropName.value = crops.value[0].name
      }
    }
  } catch (error) {
    cropsLoadError.value = 'Unable to load crops. Make sure the Ruby server is running on port 4567.'
  } finally {
    isLoadingCrops.value = false
  }
}

onMounted(loadCrops)
</script>

<template>
  <section class="page-grid">
    <div class="form-section">
      <div class="section-heading">
        <h2>Greenhouse Revenue Floor</h2>
        <p>Front-end shell for a lowest-revenue calculator based on a chosen crop and number planted.</p>
      </div>

      <div class="form-group">
        <label for="crop-name">Crop name</label>
        <select id="crop-name" v-model="cropName" :disabled="isLoadingCrops">
          <option v-if="isLoadingCrops" value="">Loading crops...</option>
          <option v-for="crop in crops" :key="crop.name" :value="crop.name">
            {{ crop.name }}
          </option>
        </select>
        <p v-if="cropsLoadError" class="error">{{ cropsLoadError }}</p>
      </div>

      <div class="form-group">
        <label for="crop-count">Number planted</label>
        <input id="crop-count" v-model.number="cropCount" type="number" min="1" />
      </div>

      <div class="form-group">
        <label for="harvest-count">Harvests</label>
        <input id="harvest-count" v-model.number="harvestCount" type="number" min="1" />
      </div>

      <div class="form-group">
        <button type="button" class="fetch-button">Calculate Lowest Revenue</button>
      </div>
    </div>

    <div class="results-section">
      <div class="empty-state">
        <p class="empty-title">Preview</p>
        <p><strong>Selected crop:</strong> {{ cropName || 'None' }}</p>
        <p><strong>Crops planted:</strong> {{ cropCount }}</p>
        <p><strong>Harvest cycles:</strong> {{ harvestCount }}</p>
      </div>

      <div class="math-section">
        <h3>Lowest revenue result</h3>
        <p>This section is intentionally static until you decide how the greenhouse math should work.</p>
        <p><strong>Estimated floor revenue:</strong> -- gold</p>
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
  box-shadow: 0 18px 45px var(--color-shadow);
  border: 1px solid var(--color-panel-border);
  background: var(--color-panel);
}

.section-heading {
  margin-bottom: 24px;
}

.section-heading h2,
.results-section h3 {
  margin: 0 0 10px;
  font-size: 2rem;
  color: var(--color-title);
}

.section-heading p,
.results-section p,
.empty-state p {
  margin: 0;
  color: var(--color-text-muted);
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

.form-group label {
  margin-bottom: 8px;
  color: var(--color-label);
  font-weight: 700;
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
  border: 1px solid var(--color-panel-border);
  background: var(--color-surface);
  color: var(--color-text);
}

.fetch-button {
  border: none;
  background: linear-gradient(135deg, var(--color-accent) 0%, var(--color-accent-strong) 100%);
  color: var(--color-accent-contrast);
  font-weight: 700;
  cursor: pointer;
}

.error {
  padding: 12px;
  border-radius: 12px;
  background: var(--color-danger-bg);
  color: var(--color-danger-text);
}

.empty-state p + p,
.results-section p + p {
  margin-top: 12px;
}

.empty-title {
  margin-bottom: 10px;
  color: var(--color-title);
  font-size: 1.5rem;
  font-weight: 700;
}

.math-section {
  margin-top: 18px;
  padding-top: 18px;
  border-top: 1px dashed var(--color-panel-border);
}

@media (max-width: 900px) {
  .page-grid {
    grid-template-columns: 1fr;
  }
}
</style>
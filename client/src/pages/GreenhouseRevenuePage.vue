<script setup>
import { onMounted, onUnmounted, ref } from 'vue'

const dropdownOpen = ref(false)

function selectCrop(name) {
  cropName.value = name
  dropdownOpen.value = false
}

function handleOutsideClick(e) {
  if (!e.target.closest('.custom-select')) {
    dropdownOpen.value = false
  }
}

onMounted(() => document.addEventListener('mousedown', handleOutsideClick))
onUnmounted(() => document.removeEventListener('mousedown', handleOutsideClick))

const cropName = ref('')
const cropCount = ref(null)
const harvestCount = ref(null)
const quality = ref('')
const qualityOptions = ['regular', 'silver', 'gold']
const showGreenhouseTip = ref(true)
const result = ref(null)
const calculationError = ref('')

const crops = ref([])
const isLoadingCrops = ref(false)
const cropsLoadError = ref('')

async function loadCrops() {
  isLoadingCrops.value = true
  cropsLoadError.value = ''

  try {
    const response = await fetch('http://3.142.121.136:4567/api/crops')
    if (!response.ok) {
      throw new Error(`Request failed with status ${response.status}`)
    }

    const data = await response.json()
    crops.value = Array.isArray(data) ? data : []

  } catch (error) {
    cropsLoadError.value = 'Unable to load crops. Make sure the Ruby server is running on port 4567.'
  } finally {
    isLoadingCrops.value = false
  }
}

onMounted(loadCrops)

function selectedCrop() {
  return crops.value.find((crop) => crop.name === cropName.value)
}

async function calculateRevenue() {
  calculationError.value = ''

  const crop = selectedCrop()
  if (!crop) {
    calculationError.value = 'Pick a valid crop first.'
    result.value = null
    return
  }

  if (!quality.value) {
    calculationError.value = 'Select a quality first.'
    result.value = null
    return
  }

  const planted = Number(cropCount.value)
  const harvests = Number(harvestCount.value)

  if (!Number.isFinite(planted) || planted < 1 || !Number.isInteger(planted)) {
    calculationError.value = 'Number planted must be a whole number of at least 1.'
    result.value = null
    return
  }

  if (!Number.isFinite(harvests) || harvests < 1 || !Number.isInteger(harvests)) {
    calculationError.value = 'Harvests must be a whole number of at least 1.'
    result.value = null
    return
  }

  const params = new URLSearchParams({
    cropName: crop.name,
    cropCount: planted,
    harvests,
    quality: quality.value,
  })

  try {
    const response = await fetch(`http://localhost:4567/api/greenhouse-revenue?${params.toString()}`)
    if (!response.ok) {
      throw new Error(`Request failed with status ${response.status}`)
    }

    const data = await response.json()
    if (data.error) {
      calculationError.value = data.error
      result.value = null
      return
    }

    result.value = data
  } catch (error) {
    calculationError.value = 'Unable to calculate greenhouse revenue. Make sure the Ruby server is running on port 4567.'
    result.value = null
  }
}

function formatGold(value) {
  return `${Number(value || 0).toLocaleString()} gold`
}

function formatAbsoluteGold(value) {
  return `${Math.abs(Number(value || 0)).toLocaleString()} gold`
}
</script>

<template>
  <section class="page-grid">
    <div class="form-section">
      <div class="section-heading">
        <h2>Greenhouse Revenue Floor</h2>
        <p>Front-end shell for a lowest-revenue calculator based on a chosen crop and number planted.</p>
      </div>

      <div class="form-group">
        <label>Crop name</label>
        <div class="custom-select" :class="{ open: dropdownOpen, disabled: isLoadingCrops }">
          <button
            type="button"
            class="custom-select-trigger"
            :disabled="isLoadingCrops"
            @click="dropdownOpen = !dropdownOpen"
          >
            <span>{{ isLoadingCrops ? 'Loading crops...' : (cropName || 'Select a crop') }}</span>
            <svg class="chevron" viewBox="0 0 10 6" width="10" height="6" aria-hidden="true">
              <path d="M0 0l5 6 5-6z" />
            </svg>
          </button>
          <ul v-if="dropdownOpen" class="custom-select-list" role="listbox">
            <li
              v-for="crop in crops"
              :key="crop.name"
              :class="{ selected: crop.name === cropName }"
              role="option"
              @mousedown.prevent="selectCrop(crop.name)"
            >
              {{ crop.name }}
            </li>
          </ul>
        </div>
        <p v-if="cropsLoadError" class="error">{{ cropsLoadError }}</p>
      </div>

      <div class="form-group">
        <label for="crop-count">Number planted</label>
        <input id="crop-count" v-model.number="cropCount" type="number" min="1" placeholder="Enter crop count" />
      </div>

      <div class="form-group">
        <label for="harvest-count">Harvests</label>
        <input id="harvest-count" v-model.number="harvestCount" type="number" min="1" placeholder="Enter total harvests" />
      </div>

      <div class="form-group">
        <label for="quality">Quality</label>
        <select id="quality" v-model="quality">
          <option disabled value="">Select quality</option>
          <option v-for="option in qualityOptions" :key="option" :value="option">
            {{ option.charAt(0).toUpperCase() + option.slice(1) }}
          </option>
        </select>
      </div>

      <div v-if="showGreenhouseTip" class="greenhouse-tip">
        <p><strong>Quality tip:</strong> Crop quality is not guaranteed. Higher quality selections provide a rough estimate for better crops, while regular quality shows the lowest possible profit.</p>
        <button
          class="greenhouse-tip-close"
          type="button"
          @click="showGreenhouseTip = false"
          aria-label="Close quality tip"
        >
          Exit
        </button>
      </div>

      <div class="form-group">
        <button type="button" class="fetch-button" @click="calculateRevenue">Calculate Lowest Revenue</button>
        <p v-if="calculationError" class="error">{{ calculationError }}</p>
      </div>
    </div>

    <div class="results-section">
      <div class="best-crop-hero greenhouse-hero">
        <p class="best-crop-kicker">{{ result ? 'Greenhouse Result' : 'Preview' }}</p>
        <h3 class="best-crop-name">{{ result?.cropName ?? (cropName || 'Select a crop') }}</h3>
        <div class="best-crop-stats">
          <span>
            <strong>{{ result ? formatAbsoluteGold(result.lowestProfit) : (cropCount ?? '--') }}</strong>
            {{ result ? 'lowest profit' : 'crops planted' }}
          </span>
          <span>
            <strong>{{ result?.daysToCompleteHarvests ?? harvestCount ?? '--' }}</strong>
            {{ result ? 'days required' : 'harvests' }}
          </span>
        </div>
      </div>

      <div v-if="result" class="math-section">
        <p><strong>{{ result.cropName }} - Math Breakdown</strong></p>

        <div class="math-row">
          <span class="math-label">Harvest timing</span>
          <span class="math-formula">
            Initial harvest in {{ result.growthDays }} day(s)
            <template v-if="result.harvests > 1 && result.isRegrowCrop">
              + {{ result.futureHarvests }} future harvest(s) every {{ result.regrowDays }} day(s)
            </template>
            <template v-else-if="result.harvests > 1">
              + {{ result.futureHarvests }} additional harvest(s), each requiring a full regrow cycle
            </template>
          </span>
          <span class="math-result">{{ result.daysToCompleteHarvests }} day(s)</span>
        </div>

        <div class="math-row">
          <span class="math-label">Minimum total crops</span>
          <span class="math-formula">{{ result.planted }} planted x {{ result.harvests }} harvests x {{ result.yieldPerHarvest }} yield</span>
          <span class="math-result">{{ result.totalItems }}</span>
        </div>

        <div class="math-row">
          <span class="math-label">Lowest revenue</span>
          <span class="math-formula">{{ result.totalItems }} x {{ result.selectedSellPrice }}g ({{ result.quality }} quality)</span>
          <span class="math-result">{{ formatGold(result.lowestRevenue) }}</span>
        </div>

        <div class="math-row">
          <span class="math-label">Seed cost</span>
          <span class="math-formula">{{ result.planted }} seeds x {{ result.seedPrice }}g</span>
          <span class="math-result">{{ formatGold(result.totalSeedCost) }}</span>
        </div>

        <div class="math-row">
          <span class="math-label">Lowest profit</span>
          <span class="math-formula">|{{ formatGold(result.lowestRevenue) }} - {{ formatGold(result.totalSeedCost) }}|</span>
          <span class="math-result">{{ formatAbsoluteGold(result.lowestProfit) }}</span>
        </div>
      </div>

      <div v-else class="empty-state">
        <p class="empty-title">Run a greenhouse estimate</p>
        <p>Pick a crop, planted amount, harvest count, and quality to generate the floor revenue breakdown.</p>
        <p>The result panel will show timing, crop totals, revenue, seed cost, and lowest profit.</p>
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

.results-section {
  display: flex;
  flex-direction: column;
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

/* Custom dropdown */
.custom-select {
  position: relative;
}

.custom-select-trigger {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  min-height: 48px;
  padding: 12px 14px;
  border: 1px solid var(--color-panel-border);
  border-radius: 14px;
  background: var(--color-surface);
  color: var(--color-text);
  font: inherit;
  cursor: pointer;
  text-align: left;
}

.custom-select.open .custom-select-trigger {
  border-bottom-left-radius: 0;
  border-bottom-right-radius: 0;
}

.custom-select.disabled .custom-select-trigger {
  opacity: 0.6;
  cursor: not-allowed;
}

.chevron {
  flex-shrink: 0;
  fill: currentColor;
  opacity: 0.5;
  margin-left: 8px;
  transition: transform 0.15s;
}

.custom-select.open .chevron {
  transform: rotate(180deg);
}

.custom-select-list {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  max-height: 200px;
  overflow-y: auto;
  margin: 0;
  padding: 4px 0;
  list-style: none;
  border: 1px solid var(--color-panel-border);
  border-top: none;
  border-bottom-left-radius: 14px;
  border-bottom-right-radius: 14px;
  background: var(--color-surface);
  color: var(--color-text);
  z-index: 100;
  box-shadow: 0 8px 24px var(--color-shadow);
}

.custom-select-list li {
  padding: 8px 14px;
  cursor: pointer;
}

.custom-select-list li:hover {
  background: var(--color-panel-border);
}

.custom-select-list li.selected {
  font-weight: 700;
  color: var(--color-accent);
}

.fetch-button {
  border: none;
  background: linear-gradient(135deg, var(--color-accent) 0%, var(--color-accent-strong) 100%);
  color: var(--color-accent-contrast);
  font-weight: 700;
  cursor: pointer;
  width: 100%;
}

.error {
  padding: 12px;
  border-radius: 12px;
  background: var(--color-danger-bg);
  color: var(--color-danger-text);
}

.greenhouse-tip {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  margin: 4px 0 16px;
  padding: 10px 12px;
  border-radius: 12px;
  border: 1px solid rgba(26, 135, 236, 0.35);
  background: rgba(26, 135, 236, 0.09);
}

.greenhouse-tip-close {
  flex: 0 0 auto;
  border: 1px solid rgba(26, 135, 236, 0.4);
  background: rgba(255, 255, 255, 0.7);
  color: #1a3a5c;
  border-radius: 999px;
  padding: 3px 10px;
  margin: 0;
  line-height: 1;
  font-size: 0.75rem;
  font-weight: 700;
  cursor: pointer;
}

.greenhouse-tip-close:hover {
  background: rgba(255, 255, 255, 0.92);
}

.greenhouse-tip p {
  flex: 1;
  margin: 0;
  color: #1a3a5c;
  line-height: 1.45;
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
  border-top: 2px solid rgba(15, 118, 110, 0.18);
}

.math-row {
  display: grid;
  grid-template-columns: max-content 1fr max-content;
  gap: 6px 12px;
  align-items: baseline;
  margin-top: 10px;
  padding: 8px 10px;
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
}

.math-result {
  font-weight: 700;
  color: var(--color-accent);
  white-space: nowrap;
}

@media (max-width: 900px) {
  .page-grid {
    grid-template-columns: 1fr;
  }

  .best-crop-stats {
    flex-direction: column;
    gap: 8px;
  }
}
</style>
<script setup>
import { ref, onMounted } from 'vue'

const result = ref(null)

async function fetchData() {
  const res = await fetch(
    'http://localhost:4567/api/best-crops?season=spring&days=10'
  );
  result.value = await res.json();
}

onMounted(() => {
  fetchData();
});
</script>

<template>
  <div>
    <h1>Stardew Planner 🌱</h1>

    <div v-if="result">
      <p>Best Crop: {{ result.best_crop }}</p>
      <p>Profit: {{ result.profit }}</p>
      <p>Harvests: {{ result.harvests }}</p>
    </div>
  </div>
</template>
<template>
  <footer class="footer">
    <p>Created by Logan Stoltz, 2026</p>
  </footer>
</template>

<script lang="js">
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&display=swap');

.footer {
  font-family: 'Inter', sans-serif;
  background: var(--color-accent);
  border-top: 2px solid var(--color-accent-strong);
  border-radius: 6px 6px 0 0;
  width: 100%;
  height: 2rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 4px;
  padding: 0 16px;
  z-index: 1000;
}

p {
  color: var(--color-accent-contrast);
  font-size: large;
  font-weight: 600;
  line-height: 1.2;
  margin: 0;
  text-align: center;
}

@media (max-width: 930px) {
  .footer {
    padding: 0rem;
  }
  
  p {
    font-size: 0.8rem;
  }
}

@media (max-width: 499px) {
  .footer {
    padding: 0rem;
  }
  
  p {
    font-size: 0.6rem;
  }
}
</style>
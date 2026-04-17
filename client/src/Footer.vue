<template>
  <footer class="footer">
    <div class="footer-inner">
      <span class="footer-brand">Stardew Valley Planner</span>
      <span class="footer-divider" aria-hidden="true">·</span>
      <span class="footer-credit">Created by Logan Stoltz</span>
      <span class="footer-divider" aria-hidden="true">·</span>
      <span class="footer-year">2026</span>
    </div>
  </footer>
</template>

<script lang="js">
</script>

<style scoped>
.footer {
  background: rgba(15, 118, 110, 0.35);
  backdrop-filter: blur(8px);
  -webkit-backdrop-filter: blur(8px);
  border-top: 1px solid rgba(15, 118, 110, 0.4);
  border-radius: 8px 8px 0 0;
  width: 100%;
  padding: 14px 24px;
}

.footer-inner {
  display: flex;
  align-items: center;
  justify-content: center;
  flex-wrap: wrap;
  gap: 8px;
  font-family: 'Trebuchet MS', 'Segoe UI', sans-serif;
  font-size: 0.85rem;
  color: var(--color-text-muted);
}

.footer-brand {
  font-weight: 700;
  letter-spacing: 0.03em;
}

.footer-credit,
.footer-year {
  font-weight: 400;
  opacity: 0.85;
}

.footer-divider {
  opacity: 0.5;
}

@media (max-width: 499px) {
  .footer-divider {
    display: none;
  }

  .footer-inner {
    flex-direction: column;
    gap: 2px;
  }
}
</style>
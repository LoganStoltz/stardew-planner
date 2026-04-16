<template>
  <div class="app-layout">
    <div class="shell">
      <header class="shell-header">
        <div>
          <p class="eyebrow">Stardew Planner</p>
          <h1>Crop Planning Tools</h1>
        </div>

        <nav class="nav-links" aria-label="Planner tools">
          <RouterLink to="/" class="nav-link">Season Planner</RouterLink>
          <RouterLink to="/greenhouse-revenue" class="nav-link">Greenhouse Revenue</RouterLink>
        </nav>
      </header>

      <main>
        <RouterView />
      </main>
    </div>

    <Footer />
  </div>
</template>

<script setup lang="js">
  import Footer from './Footer.vue';
</script>

<style scoped>
.app-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.shell {
  width: min(1100px, calc(100% - 32px));
  margin: 0 auto;
  padding: 32px 0 56px;
  flex: 1;
}

.shell-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  gap: 24px;
  margin-bottom: 28px;
}

.eyebrow {
  margin: 0 0 8px;
  color: var(--color-accent);
  font-size: 0.8rem;
  font-weight: 700;
  letter-spacing: 0.18em;
  text-transform: uppercase;
}

.shell-header h1 {
  margin: 0;
  color: var(--color-title);
  font-size: clamp(2rem, 5vw, 3.4rem);
  line-height: 1;
  font-family: Georgia, 'Times New Roman', serif;
}

.nav-links {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
}

.nav-link {
  padding: 12px 16px;
  border: 1px solid var(--color-panel-border);
  border-radius: 999px;
  color: var(--color-label);
  background: var(--color-panel);
  text-decoration: none;
  font-weight: 700;
  transition: transform 0.18s ease, border-color 0.18s ease, background-color 0.18s ease;
}

.nav-link:hover {
  transform: translateY(-1px);
  border-color: var(--color-accent);
}

.nav-link.router-link-active {
  color: var(--color-accent-contrast);
  background: linear-gradient(135deg, var(--color-accent) 0%, var(--color-accent-strong) 100%);
  border-color: transparent;
}

@media (max-width: 720px) {
  .shell {
    width: min(100% - 20px, 1100px);
    padding-top: 20px;
  }

  .shell-header {
    align-items: stretch;
    flex-direction: column;
  }

  .nav-links {
    justify-content: center;
    gap: 12px;
    flex-direction: row;
  }

  .nav-link {
    flex: 1 1 0;
    text-align: center;
  }
}
</style>
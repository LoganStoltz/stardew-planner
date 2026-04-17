<template>
  <div class="app-layout">
    <div class="shell">
      <header class="shell-header">
        <div class='heading'>
          <img src="/favicon.svg" alt="" class="mascot" aria-hidden="true" />
          <div>
            <p class="eyebrow">Stardew Valley Planner</p>
            <h1>Crop Planning Tools</h1>
          </div>
        </div>

        <nav class="nav-links" aria-label="Planner tools">
          <RouterLink to="/" class="nav-link">Season Planner</RouterLink>
          <RouterLink to="/greenhouse-revenue" class="nav-link">Greenhouse Revenue</RouterLink>
          <button
            class="tips-toggle"
            :class="{ active: showTips }"
            :aria-pressed="showTips"
            :title="showTips ? 'Hide tips & promos' : 'Show tips & promos'"
            @click="showTips = !showTips"
          >
            <span class="tips-toggle-icon" aria-hidden="true">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0Zm-7-4a1 1 0 1 1-2 0 1 1 0 0 1 2 0ZM9 9a.75.75 0 0 0 0 1.5h.253a.25.25 0 0 1 .244.304l-.459 2.066A1.75 1.75 0 0 0 10.747 15H11a.75.75 0 0 0 0-1.5h-.253a.25.25 0 0 1-.244-.304l.459-2.066A1.75 1.75 0 0 0 9.253 9H9Z" clip-rule="evenodd" />
              </svg>
            </span>
            <span class="tips-toggle-label">Extra Info</span>
          </button>
        </nav>
      </header>

      <div v-if="showTips && showDiscordPromo" class="discord-promo">
        <svg class="discord-icon" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 127.14 96.36" aria-hidden="true"><path d="M107.7 8.07A105.15 105.15 0 0 0 81.47 0a72.06 72.06 0 0 0-3.36 6.83 97.68 97.68 0 0 0-29.11 0A72.37 72.37 0 0 0 45.64 0a105.89 105.89 0 0 0-26.25 8.09C2.79 32.65-1.71 56.6.54 80.21a105.73 105.73 0 0 0 32.17 16.15 77.7 77.7 0 0 0 6.89-11.11 68.42 68.42 0 0 1-10.85-5.18c.91-.66 1.8-1.34 2.66-2a75.57 75.57 0 0 0 64.32 0c.87.71 1.76 1.39 2.66 2a68.68 68.68 0 0 1-10.87 5.19 77 77 0 0 0 6.89 11.1 105.25 105.25 0 0 0 32.19-16.14c2.64-27.38-4.51-51.11-18.9-72.15ZM42.45 65.69C36.18 65.69 31 60 31 53s5-12.74 11.43-12.74S54 46 53.89 53s-5.05 12.69-11.44 12.69Zm42.24 0C78.41 65.69 73.25 60 73.25 53s5-12.74 11.44-12.74S96.23 46 96.12 53s-5.04 12.69-11.43 12.69Z"/></svg>
        <span>Want to use the Stardew Valley Planner right in Discord? &mdash; Try the bot today.</span>
        <div class="discord-promo-buttons">
          <a class="discord-link" href="https://discord.com/oauth2/authorize?client_id=1490764286249664552" target="_blank" rel="noopener noreferrer">Add to your server</a>
          <button class="discord-promo-close" type="button" @click="showDiscordPromo = false" aria-label="Close Discord promotion">Close</button>
        </div>
      </div>

      <main>
        <RouterView />
      </main>
    </div>

    <Footer />
  </div>
</template>

<script setup lang="js">
  import Footer from './Footer.vue';
  import { ref, watch } from 'vue';
  import { usePreferences } from './usePreferences.js';

  const { showTips } = usePreferences();
  const showDiscordPromo = ref(true);

  watch(showTips, (val) => {
    if (val) showDiscordPromo.value = true;
  });
</script>

<style scoped>
.app-layout {
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

.shell {
  width: min(1200px, calc(100% - 32px));
  margin: 0 auto;
  padding: 32px 0 56px;
  flex: 1;
}

.shell-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 24px;
  margin-bottom: 28px;
  flex-wrap: nowrap;
}

.heading {
  display: flex;
  align-items: center;
  gap: 12px;
  flex-shrink: 0;
}

.mascot {
  width: 60px;
  height: 60px;
  flex-shrink: 0;
  image-rendering: pixelated;
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

.tips-toggle {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  padding: 12px 16px;
  border: 1px solid var(--color-panel-border);
  border-radius: 999px;
  background: var(--color-panel);
  color: var(--color-label);
  font: inherit;
  font-weight: 700;
  cursor: pointer;
  user-select: none;
  white-space: nowrap;
  flex: 0 0 auto;
  transition: border-color 0.18s ease, background 0.18s ease, color 0.18s ease;
}

.tips-toggle:hover {
  border-color: var(--color-accent);
}

.tips-toggle.active {
  background: linear-gradient(135deg, var(--color-accent) 0%, var(--color-accent-strong) 100%);
  border-color: transparent;
  color: var(--color-accent-contrast);
}

.tips-toggle-icon {
  display: flex;
  align-items: center;
}

.tips-toggle-icon svg {
  width: 15px;
  height: 15px;
}

.discord-promo {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 16px;
  margin-bottom: 28px;
  background: var(--color-panel);
  border: 1px solid var(--color-panel-border);
  border-radius: 10px;
  font-size: 0.88rem;
  color: var(--color-label);
  flex-wrap: wrap;
}

.discord-icon {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
  fill: var(--color-accent);
}

.discord-link {
  margin-left: auto;
  padding: 6px 14px;
  border-radius: 999px;
  background: linear-gradient(135deg, var(--color-accent) 0%, var(--color-accent-strong) 100%);
  color: var(--color-accent-contrast);
  font-weight: 700;
  font-size: 0.8rem;
  text-decoration: none;
  white-space: nowrap;
  transition: opacity 0.15s ease;
}

.discord-link:hover {
  opacity: 0.85;
}

.discord-promo-buttons {
  display: contents;
}

.discord-promo-close {
  flex: 0 0 auto;
  border: 1px solid var(--color-panel-border);
  background: var(--color-panel);
  color: var(--color-label);
  border-radius: 999px;
  padding: 6px 14px;
  margin: 0;
  font: inherit;
  font-size: 0.8rem;
  font-weight: 700;
  white-space: nowrap;
  cursor: pointer;
  transition: background 0.15s ease;
}

.discord-promo-close:hover {
  background: var(--color-surface);
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

  .heading {
    text-align: center;
    justify-content: center;
  }

  .mascot {
    width: 48px;
    height: 48px;
  }

  .nav-links {
    justify-content: center;
    gap: 12px;
    flex-direction: row;
    align-items: center;
  }

  .nav-link {
    flex: 1 1 0;
    text-align: center;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .tips-toggle-label {
    display: none;
  }

  .discord-icon {
    width: 32px;
    height: 32px;
    opacity: 0.4;
  }

  .discord-promo {
    flex-direction: column;
    align-items: center;
    text-align: center;
    gap: 8px;
  }

  .discord-promo-buttons {
    display: flex;
    gap: 10px;
    width: 100%;
  }

  .discord-link,
  .discord-promo-close {
    margin-left: 0;
    flex: 1 1 0;
    text-align: center;
    justify-content: center;
  }
}
</style>
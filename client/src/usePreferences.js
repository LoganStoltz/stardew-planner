import { ref, watch } from 'vue'

const STORAGE_KEY = 'stardew-planner-show-tips'

const stored = localStorage.getItem(STORAGE_KEY)
const showTips = ref(stored === null ? true : stored === 'true')

watch(showTips, (val) => {
  localStorage.setItem(STORAGE_KEY, String(val))
})

export function usePreferences() {
  return { showTips }
}

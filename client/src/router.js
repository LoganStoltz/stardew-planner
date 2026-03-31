import { createRouter, createWebHistory } from 'vue-router'
import CropPlannerPage from './pages/CropPlannerPage.vue'
import GreenhouseRevenuePage from './pages/GreenhouseRevenuePage.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'planner',
      component: CropPlannerPage,
    },
    {
      path: '/greenhouse-revenue',
      name: 'greenhouse-revenue',
      component: GreenhouseRevenuePage,
    },
  ],
})

export default router
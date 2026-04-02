import { createRouter, createWebHistory } from 'vue-router'
import HomePage           from '../views/HomePage.vue'
import LoginPage          from '../views/LoginPage.vue'
import ActivitiesPage     from '../views/ActivitiesPage.vue'
import ActivityDetailPage from '../views/ActivityDetailPage.vue'
import PreventionPage     from '../views/PreventionPage.vue'
import ArticlePage        from '../views/sante-mentale/ArticlePage.vue'

const routes = [
  { path: '/',                    component: HomePage           },
  { path: '/login',               component: LoginPage          },
  { path: '/activities',          component: ActivitiesPage     },
  { path: '/activities/:id',      component: ActivityDetailPage },
  { path: '/prevention',          component: PreventionPage     },
  { path: '/prevention/:id',      component: ArticlePage        },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router

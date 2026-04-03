import { createRouter, createWebHistory } from 'vue-router'
import HomePage           from '../views/HomePage.vue'
import LoginPage          from '../views/LoginPage.vue'
import ActivitiesPage     from '../views/ActivitiesPage.vue'
import ActivityDetailPage from '../views/ActivityDetailPage.vue'
import PreventionPage     from '../views/PreventionPage.vue'
import ArticlePage        from '../views/sante-mentale/ArticlePage.vue'
import AccountPage        from '../views/AccountPage.vue'

//--- meta: { requiresAuth: true } marque les routes protégées par login
const routes = [
  { path: '/',                    component: HomePage           },
  { path: '/login',               component: LoginPage          },
  { path: '/account',             component: AccountPage,        meta: { requiresAuth: true } },
  { path: '/activities',          component: ActivitiesPage,     meta: { requiresAuth: true } },
  { path: '/activities/:id',      component: ActivityDetailPage, meta: { requiresAuth: true } },
  { path: '/prevention',          component: PreventionPage     },
  { path: '/prevention/:id',      component: ArticlePage        },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

/*router.beforeEach s'exécute avant chaque navigation et vérifie si un token existe dans le localStorage
Si pas de token → redirige vers /login*/

router.beforeEach((to) => {
  if (to.meta.requiresAuth && !localStorage.getItem('token')) {
    return { path: '/login' }
  }
})

export default router
<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'

const menuOpen = ref(false)
const router = useRouter()

const isLoggedIn = ref(!!localStorage.getItem('token'))

router.afterEach(() => {
  menuOpen.value = false
  isLoggedIn.value = !!localStorage.getItem('token')
})

function logout() {
  localStorage.removeItem('token')
  isLoggedIn.value = false
  router.push('/login')
}
</script>

<template>
  <header class="navbar">
    <div class="container navbar__inner">

      <!-- Logo -->
      <router-link to="/" class="navbar__logo" aria-label="CESIZen - Accueil">
        <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg" class="navbar__logo-icon" aria-hidden="true">
          <defs>
            <linearGradient id="bgGradient" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stop-color="#f0fdfa"/>
              <stop offset="100%" stop-color="#ccfbf1"/>
            </linearGradient>
            <linearGradient id="leafGradient" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stop-color="#14b8a6"/>
              <stop offset="100%" stop-color="#0d9488"/>
            </linearGradient>
          </defs>
          <circle cx="50" cy="50" r="46" fill="url(#bgGradient)" stroke="#14b8a6" stroke-width="2"/>
          <circle cx="50" cy="50" r="38" fill="none" stroke="#5eead4" stroke-width="1" stroke-dasharray="4 4" opacity="0.5"/>
          <ellipse cx="50" cy="68" rx="22" ry="8" fill="#5c724e" opacity="0.9"/>
          <ellipse cx="50" cy="58" rx="18" ry="7" fill="#7a8f6b"/>
          <ellipse cx="50" cy="49" rx="14" ry="6" fill="url(#leafGradient)"/>
          <path d="M50 25 Q35 35 38 50 Q50 45 50 25" fill="#14b8a6" opacity="0.6"/>
          <path d="M50 25 Q65 35 62 50 Q50 45 50 25" fill="#0d9488" opacity="0.6"/>
        </svg>
        <span class="navbar__logo-text">CESIZen</span>
      </router-link>

      <!-- Menu horizontal (desktop) -->
      <nav class="navbar__nav" aria-label="Navigation principale">
        <ul class="navbar__links">
          <li><router-link to="/">Accueil</router-link></li>
          <li><router-link to="/activities">Activités de détente</router-link></li>
          <li><router-link to="/prevention">Santé mentale</router-link></li>
        </ul>
      </nav>

      <!-- Bouton connexion + hamburger -->
      <div class="navbar__right">
        <router-link to="/account" class="btn btn-primary navbar__cta">Mon compte</router-link>

        <button
          class="hamburger"
          @click="menuOpen = !menuOpen"
          :aria-expanded="menuOpen"
          aria-label="Ouvrir le menu"
        >
          <span :class="['hamburger__bar', { open: menuOpen }]"></span>
          <span :class="['hamburger__bar', { open: menuOpen }]"></span>
          <span :class="['hamburger__bar', { open: menuOpen }]"></span>
        </button>
      </div>

    </div>

    <!-- Menu déroulant mobile -->
    <div v-if="menuOpen" class="mobile-menu">
      <ul>
        <li><router-link to="/">Accueil</router-link></li>
        <li><router-link to="/activities">Activités de détente</router-link></li>
        <li><router-link to="/prevention">Santé mentale</router-link></li>
        <li v-if="isLoggedIn"><button @click="logout" class="mobile-menu__logout">Se déconnecter</button></li>
        <li v-else><router-link to="/login">Connexion</router-link></li>
      </ul>
    </div>
  </header>

  <main>
    <RouterView />
  </main>

  <footer class="footer">

    <!-- Logo centré -->
    <div class="footer__logo-wrap">
      <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg" class="footer__logo-icon" aria-hidden="true">
        <defs>
          <linearGradient id="fBg" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stop-color="#f0fdfa"/>
            <stop offset="100%" stop-color="#ccfbf1"/>
          </linearGradient>
          <linearGradient id="fLeaf" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stop-color="#14b8a6"/>
            <stop offset="100%" stop-color="#0d9488"/>
          </linearGradient>
        </defs>
        <circle cx="50" cy="50" r="46" fill="url(#fBg)" stroke="#14b8a6" stroke-width="2"/>
        <circle cx="50" cy="50" r="38" fill="none" stroke="#5eead4" stroke-width="1" stroke-dasharray="4 4" opacity="0.5"/>
        <ellipse cx="50" cy="68" rx="22" ry="8" fill="#5c724e" opacity="0.9"/>
        <ellipse cx="50" cy="58" rx="18" ry="7" fill="#7a8f6b"/>
        <ellipse cx="50" cy="49" rx="14" ry="6" fill="url(#fLeaf)"/>
        <path d="M50 25 Q35 35 38 50 Q50 45 50 25" fill="#14b8a6" opacity="0.6"/>
        <path d="M50 25 Q65 35 62 50 Q50 45 50 25" fill="#0d9488" opacity="0.6"/>
      </svg>
      <span class="footer__logo-name">CESIZen</span>
      <p class="footer__tagline">Votre espace bien-être mental</p>
    </div>

    <hr class="footer__divider" />

    <!-- Colonnes -->
    <div class="container footer__inner">
      <div class="footer__col">
        <h4>À propos</h4>
        <p>Service dédié à la prévention et au bien-être mental, accessible gratuitement à tous.</p>
      </div>
      <div class="footer__col">
        <h4>Navigation</h4>
        <ul>
          <li><router-link to="/">Accueil</router-link></li>
          <li><router-link to="/activities">Activités de détente</router-link></li>
          <li><router-link to="/prevention">Santé mentale</router-link></li>
          <li><router-link to="/login">Connexion</router-link></li>
        </ul>
      </div>
      <div class="footer__col">
        <h4>Informations légales</h4>
        <ul>
          <li><a href="#">Mentions légales</a></li>
          <li><a href="#">Accessibilité</a></li>
          <li><a href="#">Politique de confidentialité</a></li>
        </ul>
      </div>
    </div>

    <hr class="footer__divider" />

    <div class="footer__bottom">
      <p>© {{ new Date().getFullYear() }} CESIZen — Service public de santé mentale.</p>
    </div>
  </footer>
</template>

<style>
/* ========================
   NAVBAR
   ======================== */
.navbar {
  background-color: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  position: sticky;
  top: 0;
  z-index: 100;
}

.navbar__inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 1.5rem;
  gap: 1.5rem;
}

.navbar__logo {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  text-decoration: none;
  flex-shrink: 0;
}

.navbar__logo-icon { width: 40px; height: 40px; }

.navbar__logo-text {
  font-size: var(--font-size-lg);
  font-weight: 700;
  color: var(--color-text);
}

/* Liens horizontaux */
.navbar__nav { flex: 1; }

.navbar__links {
  list-style: none;
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.navbar__links a {
  text-decoration: none;
  color: var(--color-text);
  font-weight: 500;
  padding: 0.4rem 0.75rem;
  border-radius: var(--border-radius);
  transition: background-color var(--transition), color var(--transition);
}

.navbar__links a:hover {
  background-color: var(--color-surface-teal);
  color: var(--color-primary);
}

.navbar__links a.router-link-active {
  background-color: var(--color-surface-teal);
  color: var(--color-primary-dark);
  font-weight: 600;
}

/* Côté droit : bouton + hamburger */
.navbar__right {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-shrink: 0;
}

.navbar__cta {
  padding: 0.45rem 1rem;
  font-size: 0.85rem;
  font-weight: 700;
  color: #ffffff !important;
  text-decoration: none;
}
/* Hamburger (caché sur desktop) */
.hamburger {
  display: none;
  flex-direction: column;
  gap: 5px;
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
}

.hamburger__bar {
  display: block;
  width: 24px;
  height: 2px;
  background-color: var(--color-text);
  border-radius: 2px;
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.hamburger__bar.open:nth-child(1) { transform: translateY(7px) rotate(45deg); }
.hamburger__bar.open:nth-child(2) { opacity: 0; }
.hamburger__bar.open:nth-child(3) { transform: translateY(-7px) rotate(-45deg); }

/* Menu déroulant mobile */
.mobile-menu {
  background-color: var(--color-surface);
  border-top: 1px solid var(--color-border);
  padding: 0.5rem 0;
}

.mobile-menu ul {
  list-style: none;
}

.mobile-menu a {
  display: block;
  padding: 0.85rem 1.5rem;
  text-decoration: none;
  color: var(--color-text);
  font-weight: 500;
  transition: background-color var(--transition), color var(--transition);
}

.mobile-menu a:hover,
.mobile-menu a.router-link-active {
  background-color: var(--color-surface-teal);
  color: var(--color-primary);
}

.mobile-menu__logout {
  display: block;
  width: 100%;
  padding: 0.85rem 1.5rem;
  text-align: left;
  background: none;
  border: none;
  color: var(--color-text);
  font-weight: 500;
  font-size: inherit;
  cursor: pointer;
  transition: background-color var(--transition), color var(--transition);
}
.mobile-menu__logout:hover {
  background-color: var(--color-surface-teal);
  color: var(--color-primary);
}

/* ========================
   RESPONSIVE MOBILE
   ======================== */
@media (max-width: 768px) {
  .navbar__nav { display: none; }
  .hamburger { display: flex; }
  .navbar__cta { display: none; }
}

/* ========================
   FOOTER
   ======================== */
.footer {
  background: linear-gradient(180deg, #0d9488 0%, #0f766e 100%);
  margin-top: 4rem;
  color: #ffffff;
}

.footer__logo-wrap {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 2.5rem 0;
}

.footer__logo-icon { width: 50px; height: 50px; margin-bottom: 0.5rem; }

.footer__logo-name {
  font-size: var(--font-size-xl);
  font-weight: 700;
  color: #ffffff;
}

.footer__tagline {
  font-size: 0.9rem;
  color: rgba(255,255,255,0.75);
  margin-top: 0.25rem;
}

.footer__divider {
  width: 80%;
  margin: 0 auto;
  border: none;
  border-top: 1px solid rgba(255,255,255,0.2);
}

.footer__inner {
  display: grid;
  grid-template-columns: 2fr 1fr 1fr;
  gap: 2rem;
  padding: 2rem 1.5rem;
}

.footer__col p {
  color: rgba(255,255,255,0.75);
  font-size: 0.9rem;
  line-height: 1.6;
}

.footer__col h4 {
  font-weight: 600;
  margin-bottom: 0.75rem;
  color: #ffffff;
  font-size: 0.95rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.footer__col ul {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.footer__col ul a {
  color: rgba(255,255,255,0.7);
  text-decoration: none;
  font-size: 0.9rem;
  transition: color var(--transition);
}

.footer__col ul a:hover { color: #ffffff; }

.footer__bottom {
  padding: 1rem 1.5rem;
  text-align: center;
  color: rgba(255,255,255,0.6);
  font-size: 0.85rem;
}

@media (max-width: 700px) {
  .footer__inner { grid-template-columns: 1fr; }
}
</style>

<template>
  <div class="auth-page">
    <div class="container">
      <div class="auth-card card">

        <!-- Onglets Connexion / Inscription -->
        <div class="auth-tabs" role="tablist">
          <button
            role="tab"
            :aria-selected="activeTab === 'login'"
            :class="['auth-tab', { 'auth-tab--active': activeTab === 'login' }]"
            @click="activeTab = 'login'"
          >
            Connexion
          </button>
          <button
            role="tab"
            :aria-selected="activeTab === 'register'"
            :class="['auth-tab', { 'auth-tab--active': activeTab === 'register' }]"
            @click="activeTab = 'register'"
          >
            Créer un compte
          </button>
        </div>

        <!-- Message de retour (erreur ou succès) -->
        <div v-if="message.text" :class="['alert', `alert-${message.type}`]" role="alert">
          {{ message.text }}
        </div>

        <!-- FORMULAIRE CONNEXION -->
        <form v-if="activeTab === 'login'" @submit.prevent="handleLogin" novalidate>
          <div class="form-group">
            <label for="login-email">Adresse e-mail</label>
            <input
              id="login-email"
              type="email"
              v-model="loginForm.email"
              placeholder="exemple@email.com"
              autocomplete="email"
              required
            />
          </div>

          <div class="form-group">
            <label for="login-password">Mot de passe</label>
            <input
              id="login-password"
              type="password"
              v-model="loginForm.password"
              placeholder="Votre mot de passe"
              autocomplete="current-password"
              required
            />
          </div>

          <button type="submit" class="btn btn-primary btn-full" :disabled="loading">
            {{ loading ? 'Connexion...' : 'Se connecter' }}
          </button>
        </form>

        <!-- FORMULAIRE INSCRIPTION -->
        <form v-if="activeTab === 'register'" @submit.prevent="handleRegister" novalidate>
          <div class="form-row">
            <div class="form-group">
              <label for="reg-name">Prénom</label>
              <input
                id="reg-name"
                type="text"
                v-model="registerForm.name"
                placeholder="Alice"
                autocomplete="given-name"
                required
              />
            </div>
            <div class="form-group">
              <label for="reg-surname">Nom</label>
              <input
                id="reg-surname"
                type="text"
                v-model="registerForm.surname"
                placeholder="Dupont"
                autocomplete="family-name"
                required
              />
            </div>
          </div>

          <div class="form-group">
            <label for="reg-email">Adresse e-mail</label>
            <input
              id="reg-email"
              type="email"
              v-model="registerForm.email"
              placeholder="exemple@email.com"
              autocomplete="email"
              required
            />
          </div>

          <div class="form-group">
            <label for="reg-password">Mot de passe</label>
            <input
              id="reg-password"
              type="password"
              v-model="registerForm.password"
              placeholder="Min. 5 caractères, 1 majuscule, 1 chiffre, 1 caractère spécial"
              autocomplete="new-password"
              required
            />
          </div>

          <button type="submit" class="btn btn-primary btn-full" :disabled="loading">
            {{ loading ? 'Création...' : 'Créer mon compte' }}
          </button>
        </form>

      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

// Onglet actif : 'login' ou 'register'
const activeTab = ref('login')

// État du chargement (pendant l'appel API)
const loading = ref(false)

// Message de retour affiché à l'utilisateur
const message = reactive({ text: '', type: 'error' })

// Données des formulaires
const loginForm = reactive({ email: '', password: '' })
const registerForm = reactive({ name: '', surname: '', email: '', password: '' })

// Connexion
async function handleLogin() {
  loading.value = true
  message.text = ''

  try {
    const response = await fetch('/api/auth/login', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(loginForm),
    })

    const data = await response.json()

    if (response.ok) {
      // On stocke le token pour les prochaines requêtes
      localStorage.setItem('token', data.access_token)
      router.push('/activities')
    } else {
      message.text = data.detail || 'Email ou mot de passe incorrect.'
      message.type = 'error'
    }
  } catch {
    message.text = 'Impossible de contacter le serveur.'
    message.type = 'error'
  } finally {
    loading.value = false
  }
}

// Inscription
async function handleRegister() {
  loading.value = true
  message.text = ''

  try {
    const response = await fetch('/api/users/create', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(registerForm),
    })

    const data = await response.json()

    if (response.ok) {
      message.text = 'Compte créé ! Vous pouvez maintenant vous connecter.'
      message.type = 'success'
      activeTab.value = 'login'
    } else {
      // Gère les erreurs de validation Pydantic
      const detail = data.detail
      if (Array.isArray(detail)) {
        message.text = detail.map(e => e.msg).join(' — ')
      } else {
        message.text = detail || 'Une erreur est survenue.'
      }
      message.type = 'error'
    }
  } catch {
    message.text = 'Impossible de contacter le serveur.'
    message.type = 'error'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.auth-page {
  padding: 3rem 0;
  min-height: 70vh;
  display: flex;
  align-items: center;
}

.auth-card {
  max-width: 480px;
  margin: 0 auto;
  padding: 2rem;
}

/* Onglets */
.auth-tabs {
  display: flex;
  border-bottom: 2px solid var(--color-border);
  margin-bottom: 1.5rem;
}

.auth-tab {
  flex: 1;
  padding: 0.75rem;
  background: none;
  border: none;
  font-size: var(--font-size-base);
  font-weight: 600;
  color: var(--color-text-light);
  cursor: pointer;
  border-bottom: 3px solid transparent;
  margin-bottom: -2px;
  transition: color var(--transition), border-color var(--transition);
}

.auth-tab--active {
  color: var(--color-primary);
  border-bottom-color: var(--color-primary);
}

/* Bouton pleine largeur */
.btn-full {
  width: 100%;
  text-align: center;
  margin-top: 0.5rem;
}

/* Deux champs côte à côte (prénom / nom) */
.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
}

@media (max-width: 480px) {
  .form-row {
    grid-template-columns: 1fr;
  }
}
</style>

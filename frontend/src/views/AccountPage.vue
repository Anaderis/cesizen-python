<template>
  <div class="account-page">

    <!-- Hero -->
    <section class="account-hero">
      <div class="container account-hero__inner">
        <div class="account-hero__text">
          <h1>Mon compte</h1>
          <p v-if="user">
            Bonjour {{ user.name }} {{ user.surname }}
            <span v-if="user.role_id === 2" class="account-hero__badge">Admin</span>
          </p>
          <p v-if="user?.description" class="account-hero__quote">
            "{{ user.description }}"
          </p>
        </div>
        <div v-if="user?.photo" class="account-hero__avatar">
          <img :src="`/img/${user.photo}`" :alt="user.name" />
        </div>
      </div>
    </section>

    <div v-if="loading" class="account-state container"><p>Chargement…</p></div>
    <div v-else-if="error" class="account-state account-state--error container"><p>{{ error }}</p></div>

    <div v-else class="container account-layout">

      <!-- ===================== DONNÉES PERSONNELLES ===================== -->
      <section class="account-section">
        <h2 class="account-section__title">Données personnelles</h2>

        <div v-if="profileMessage.text" :class="['alert', `alert-${profileMessage.type}`]">
          {{ profileMessage.text }}
        </div>

        <form @submit.prevent="updateProfile" class="account-form">
          <div class="form-row">
            <div class="form-group">
              <label>Prénom</label>
              <input v-model="profileForm.name" type="text" />
            </div>
            <div class="form-group">
              <label>Nom</label>
              <input v-model="profileForm.surname" type="text" />
            </div>
          </div>
          <div class="form-group">
            <label>Adresse e-mail</label>
            <input v-model="profileForm.email" type="email" />
          </div>
          <div class="form-group">
            <label>Téléphone</label>
            <input v-model="profileForm.phone" type="tel" placeholder="06 00 00 00 00" />
          </div>
          <div class="form-group">
            <label>Description</label>
            <textarea v-model="profileForm.description" rows="3" placeholder="Quelques mots sur vous…"></textarea>
          </div>
          <div class="account-form__divider">Changer de mot de passe</div>
          <div class="form-group">
            <label>Nouveau mot de passe</label>
            <input v-model="profileForm.password" type="password" placeholder="Je réinitialise mon mot de passe" />
          </div>
          <div class="form-group">
            <label>Confirmer le nouveau mot de passe</label>
            <input v-model="profileForm.passwordConfirm" type="password" placeholder="Retapez le nouveau mot de passe" />
            <span v-if="passwordMismatch" class="form-error">Les mots de passe ne correspondent pas.</span>
          </div>
          <button type="submit" class="btn btn-primary" :disabled="profileLoading">
            {{ profileLoading ? 'Enregistrement…' : 'Enregistrer les modifications' }}
          </button>
        </form>
      </section>

      <!-- ===================== MES FAVORIS ===================== -->
      <section class="account-section">
        <h2 class="account-section__title">Mes favoris</h2>

        <!-- Filtres -->
        <div v-if="favorites.length > 0" class="filters">
          <div class="filters__inner">
            <div class="filters__field">
              <label>Rechercher</label>
              <input v-model="favSearch" type="search" placeholder="Nom de l'activité…" />
            </div>
            <div class="filters__field">
              <label>Catégorie</label>
              <select v-model="favCategory">
                <option value="">Toutes</option>
                <option v-for="cat in favCategories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
              </select>
            </div>
            <div class="filters__field">
              <label>Format</label>
              <select v-model="favFormat">
                <option value="">Tous</option>
                <option v-for="fmt in favFormats" :key="fmt.id" :value="fmt.id">{{ fmt.type }}</option>
              </select>
            </div>
          </div>
        </div>

        <p v-if="favorites.length === 0" class="account-empty">Vous n'avez pas encore d'activités en favori.</p>
        <p v-else-if="filteredFavorites.length === 0" class="account-empty">Aucun favori ne correspond à votre recherche.</p>

        <div v-else class="favorites-grid">
          <div v-for="activity in filteredFavorites" :key="activity.id" class="fav-card">
            <img
              v-if="thumbUrl(activity)"
              :src="thumbUrl(activity)"
              :alt="activity.title"
              class="fav-card__img"
              @error="e => e.target.style.display='none'"
            />
            <div class="fav-card__body">
              <span v-if="activity.category" class="fav-card__tag">{{ activity.category.name }}</span>
              <h3 class="fav-card__title">{{ activity.title }}</h3>
              <span v-if="activity.duration" class="fav-card__duration">⏱ {{ activity.duration }}</span>
            </div>
            <div class="fav-card__actions">
              <router-link :to="`/activities/${activity.id}`" class="btn btn-sm btn-primary">Voir</router-link>
              <button @click="removeFavorite(activity.id)" class="btn btn-sm btn-danger">Retirer</button>
            </div>
          </div>
        </div>
      </section>

      <!-- ===================== RGPD ===================== -->
      <section class="account-section account-section--danger">
        <h2 class="account-section__title">Confidentialité &amp; RGPD</h2>
        <p class="account-section__desc">
          Vous pouvez à tout moment désactiver ou supprimer votre compte. Ces actions sont irréversibles.
        </p>
        <div class="rgpd-actions">
          <button @click="confirmAction('deactivate')" class="btn btn-warning">
            Désactiver mon compte
          </button>
          <button @click="confirmAction('delete')" class="btn btn-danger">
            Supprimer mon compte
          </button>
        </div>
      </section>

    </div>

    <!-- ===================== MODALE CONFIRMATION ===================== -->
    <teleport to="body">
      <div v-if="modal.visible" class="modal-overlay" @click.self="modal.visible = false">
        <div class="modal" role="dialog" aria-modal="true">
          <h3 class="modal__title">{{ modal.title }}</h3>
          <p class="modal__body">{{ modal.message }}</p>
          <div class="modal__actions">
            <button @click="modal.visible = false" class="btn btn-outline">Annuler</button>
            <button @click="executeAction" class="btn" :class="modal.action === 'delete' ? 'btn-danger' : 'btn-warning'">
              Confirmer
            </button>
          </div>
        </div>
      </div>
    </teleport>

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

// ── Données utilisateur ──────────────────────────────────────
const user         = ref(null)
const loading      = ref(true)
const error        = ref(null)

// ── Formulaire profil ────────────────────────────────────────
const profileForm    = reactive({ name: '', surname: '', email: '', phone: '', description: '', password: '', passwordConfirm: '' })
const passwordMismatch = computed(() => profileForm.password && profileForm.passwordConfirm && profileForm.password !== profileForm.passwordConfirm)
const profileLoading = ref(false)
const profileMessage = reactive({ text: '', type: 'success' })

// ── Favoris ──────────────────────────────────────────────────
const favorites   = ref([])
const favSearch   = ref('')
const favCategory = ref('')
const favFormat   = ref('')

// ── Modale RGPD ──────────────────────────────────────────────
const modal = reactive({ visible: false, action: '', title: '', message: '' })

// ── Auth helpers ─────────────────────────────────────────────
function authHeaders() {
  return { 'Authorization': `Bearer ${localStorage.getItem('token')}`, 'Content-Type': 'application/json' }
}

function getUserIdFromToken() {
  const token = localStorage.getItem('token')
  if (!token) return null
  try {
    return JSON.parse(atob(token.split('.')[1])).sub
  } catch { return null }
}

// ── Chargement initial ───────────────────────────────────────
onMounted(async () => {
  const userId = getUserIdFromToken()
  if (!userId) { router.push('/login'); return }

  try {
    const [userRes, favRes] = await Promise.all([
      fetch(`/api/users/${userId}`, { headers: authHeaders() }),
      fetch('/api/users/me/favorites',  { headers: authHeaders() }),
    ])
    if (!userRes.ok) throw new Error('Impossible de charger le profil.')
    user.value = await userRes.json()
    profileForm.name        = user.value.name
    profileForm.surname     = user.value.surname
    profileForm.email       = user.value.email
    profileForm.phone       = user.value.phone ?? ''
    profileForm.description = user.value.description ?? ''

    if (favRes.ok) favorites.value = await favRes.json()
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
})

// ── Mise à jour profil ───────────────────────────────────────
async function updateProfile() {
  profileLoading.value = true
  profileMessage.text  = ''

  if (passwordMismatch.value) {
    profileMessage.text = 'Les mots de passe ne correspondent pas.'
    profileMessage.type = 'error'
    return
  }

  const userId = getUserIdFromToken()

  const payload = {
    name:        profileForm.name,
    surname:     profileForm.surname,
    email:       profileForm.email,
    phone:       profileForm.phone || null,
    description: profileForm.description || null,
  }
  if (profileForm.password) payload.password = profileForm.password

  try {
    const res = await fetch(`/api/users/${userId}`, {
      method: 'PUT',
      headers: authHeaders(),
      body: JSON.stringify(payload),
    })
    const data = await res.json()
    if (res.ok) {
      profileMessage.text = 'Modifications enregistrées !'
      profileMessage.type = 'success'
      profileForm.password        = ''
      profileForm.passwordConfirm = ''
    } else {
      const detail = data.detail
      profileMessage.text = Array.isArray(detail) ? detail.map(e => e.msg).join(' — ') : (detail || 'Erreur.')
      profileMessage.type = 'error'
    }
  } catch {
    profileMessage.text = 'Impossible de contacter le serveur.'
    profileMessage.type = 'error'
  } finally {
    profileLoading.value = false
  }
}

// ── Favoris : filtres ────────────────────────────────────────
const favCategories = computed(() => {
  const seen = new Map()
  favorites.value.forEach(a => { if (a.category && !seen.has(a.category.id)) seen.set(a.category.id, a.category) })
  return [...seen.values()]
})
const favFormats = computed(() => {
  const seen = new Map()
  favorites.value.forEach(a => { if (a.format && !seen.has(a.format.id)) seen.set(a.format.id, a.format) })
  return [...seen.values()]
})
const filteredFavorites = computed(() =>
  favorites.value.filter(a => {
    const matchText = favSearch.value === '' || a.title.toLowerCase().includes(favSearch.value.toLowerCase())
    const matchCat  = favCategory.value === '' || a.category?.id === favCategory.value
    const matchFmt  = favFormat.value === '' || a.format?.id === favFormat.value
    return matchText && matchCat && matchFmt
  })
)

function thumbUrl(activity) {
  const match = activity.url?.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})/)
  if (match) return `https://img.youtube.com/vi/${match[1]}/hqdefault.jpg`
  if (activity.photo) return `/src/assets/img/${activity.photo}`
  return null
}

async function removeFavorite(activityId) {
  await fetch(`/api/activities/${activityId}/favorite`, { method: 'DELETE', headers: authHeaders() })
  favorites.value = favorites.value.filter(a => a.id !== activityId)
}

// ── RGPD ─────────────────────────────────────────────────────
function confirmAction(action) {
  modal.action  = action
  modal.visible = true
  if (action === 'deactivate') {
    modal.title   = 'Désactiver mon compte'
    modal.message = 'Votre compte sera désactivé. Vous ne pourrez plus vous connecter. Êtes-vous sûr ?'
  } else {
    modal.title   = 'Supprimer mon compte'
    modal.message = 'Cette action est irréversible. Toutes vos données seront définitivement supprimées. Êtes-vous sûr ?'
  }
}

async function executeAction() {
  modal.visible = false
  const userId = getUserIdFromToken()
  try {
    if (modal.action === 'deactivate') {
      await fetch(`/api/users/deactivate/${userId}`, { method: 'PUT', headers: authHeaders() })
    } else {
      await fetch(`/api/users/${userId}`, { method: 'DELETE', headers: authHeaders() })
    }
    localStorage.removeItem('token')
    router.push('/')
  } catch {
    error.value = 'Une erreur est survenue.'
  }
}
</script>

<style scoped>
/* Hero */
.account-hero {
  background: linear-gradient(135deg, #0d9488 0%, #14b8a6 60%, #5c724e 100%);
  padding: 2.5rem 1.5rem;
  color: #ffffff;
}
.account-hero__inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1.5rem;
}
.account-hero__text h1 { font-size: clamp(1.5rem, 3vw, 2rem); font-weight: 700; margin-bottom: 0.25rem; }
.account-hero__text p  { font-size: 1rem; opacity: 0.88; display: flex; align-items: center; gap: 0.6rem; }
.account-hero__quote {
  font-size: 0.88rem;
  font-style: italic;
  opacity: 0.8;
  margin-top: 0.4rem;
  max-width: 480px;
  line-height: 1.5;
}
.account-hero__badge {
  background: rgba(255,255,255,0.25);
  font-size: 0.7rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  padding: 0.15rem 0.6rem;
  border-radius: 999px;
}
.account-hero__avatar {
  width: 100px;
  height: 100px;
  border-radius: 50%;
  border: 3px solid #ffffff;
  overflow: hidden;
  flex-shrink: 0;
  background: #ffffff;
  box-shadow: 0 2px 12px rgba(0,0,0,0.2);
}
.account-hero__avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* Layout */
.account-state { padding: 3rem 1.5rem; color: var(--color-text-muted); }
.account-state--error { color: #991b1b; }

.account-layout {
  display: flex;
  flex-direction: column;
  gap: 2rem;
  padding: 2rem 1.5rem 4rem;
  max-width: 860px;
  margin: 0 auto;
}

/* Section */
.account-section {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  padding: 1.75rem 2rem;
}
.account-section--danger { border-color: #fecaca; }

.account-section__title {
  font-size: 1.15rem;
  font-weight: 700;
  color: var(--color-primary-dark);
  margin-bottom: 1.25rem;
  padding-bottom: 0.6rem;
  border-bottom: 1px solid var(--color-border);
}
.account-section__desc {
  font-size: 0.9rem;
  color: var(--color-text-muted);
  margin-bottom: 1.25rem;
  line-height: 1.6;
}

/* Formulaire */
.account-form { display: flex; flex-direction: column; gap: 1rem; }
.account-form__divider {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  padding-top: 0.5rem;
  border-top: 1px solid var(--color-border);
}
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; }
.form-group { display: flex; flex-direction: column; gap: 0.3rem; }
.form-group label { font-size: 0.85rem; font-weight: 600; color: var(--color-text-muted); }
.form-group input {
  padding: 0.5rem 0.75rem;
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  font-size: 0.9rem;
  color: var(--color-text);
  background: var(--color-background);
  transition: border-color var(--transition);
}
.form-group input:focus,
.form-group textarea:focus { outline: none; border-color: var(--color-primary); }
.form-group textarea {
  padding: 0.5rem 0.75rem;
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  font-size: 0.9rem;
  color: var(--color-text);
  background: var(--color-background);
  resize: vertical;
  font-family: inherit;
  transition: border-color var(--transition);
}
.form-error { font-size: 0.8rem; color: #dc2626; margin-top: 0.2rem; }

/* Filtres favoris */
.filters { margin-bottom: 1.25rem; }
.filters__inner {
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem;
  padding: 1rem;
  background: var(--color-background);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
}
.filters__field { display: flex; flex-direction: column; gap: 0.3rem; flex: 1; min-width: 140px; }
.filters__field label { font-size: 0.75rem; font-weight: 600; color: var(--color-text-muted); text-transform: uppercase; letter-spacing: 0.04em; }
.filters__field input,
.filters__field select {
  padding: 0.45rem 0.65rem;
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  font-size: 0.875rem;
  background: var(--color-surface);
  color: var(--color-text);
}
.filters__field input:focus,
.filters__field select:focus { outline: none; border-color: var(--color-primary); }

.account-empty { color: var(--color-text-muted); font-size: 0.9rem; }

/* Grille favoris */
.favorites-grid { display: flex; flex-direction: column; gap: 0.75rem; }

.fav-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 0.75rem 1rem;
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  background: var(--color-background);
}
.fav-card__img {
  width: 72px;
  height: 52px;
  object-fit: cover;
  border-radius: calc(var(--border-radius) - 2px);
  flex-shrink: 0;
}
.fav-card__body { flex: 1; display: flex; flex-direction: column; gap: 0.2rem; }
.fav-card__tag {
  font-size: 0.7rem;
  font-weight: 600;
  text-transform: uppercase;
  color: var(--color-primary-dark);
  background: var(--color-surface-teal);
  padding: 0.1rem 0.5rem;
  border-radius: 999px;
  align-self: flex-start;
}
.fav-card__title { font-size: 0.9rem; font-weight: 700; color: var(--color-text); }
.fav-card__duration { font-size: 0.78rem; color: var(--color-text-muted); }
.fav-card__actions { display: flex; gap: 0.5rem; flex-shrink: 0; }

/* Boutons taille réduite */
.btn-sm { padding: 0.35rem 0.85rem; font-size: 0.8rem; }
.btn-warning { background-color: #f59e0b; color: #ffffff; border: none; cursor: pointer; }
.btn-warning:hover { background-color: #d97706; }
.btn-danger  { background-color: #ef4444; color: #ffffff; border: none; cursor: pointer; }
.btn-danger:hover  { background-color: #dc2626; }

/* RGPD */
.rgpd-actions { display: flex; gap: 1rem; flex-wrap: wrap; }

/* Modale */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 1rem;
}
.modal {
  background: var(--color-surface);
  border-radius: var(--border-radius);
  padding: 2rem;
  max-width: 420px;
  width: 100%;
  box-shadow: 0 20px 60px rgba(0,0,0,0.2);
}
.modal__title { font-size: 1.1rem; font-weight: 700; color: var(--color-text); margin-bottom: 0.75rem; }
.modal__body  { font-size: 0.9rem; color: var(--color-text-muted); line-height: 1.6; margin-bottom: 1.5rem; }
.modal__actions { display: flex; gap: 0.75rem; justify-content: flex-end; }

.btn-outline {
  background: none;
  border: 2px solid var(--color-border);
  border-radius: var(--border-radius);
  padding: 0.5rem 1.25rem;
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-text-muted);
  cursor: pointer;
}
.btn-outline:hover { border-color: var(--color-primary); color: var(--color-primary); }

@media (max-width: 600px) {
  .form-row { grid-template-columns: 1fr; }
  .account-section { padding: 1.25rem; }
  .rgpd-actions { flex-direction: column; }
}
</style>
<template>
  <div class="activities-page">

    <!-- Hero -->
    <section class="activities-hero">
      <div class="container activities-hero__inner">
        <h1>Activités de détente</h1>
        <p>Méditation, respiration, relaxation… Trouvez l'activité qui vous correspond.</p>
      </div>
    </section>

    <!-- Filtres -->
    <section v-if="!loading && !error" class="container filters">
      <div class="filters__inner">

        <div class="filters__field">
          <label for="search">Rechercher</label>
          <input
            id="search"
            v-model="searchText"
            type="search"
            placeholder="Nom de l'activité…"
          />
        </div>

        <div class="filters__field">
          <label for="category">Catégorie</label>
          <select id="category" v-model="selectedCategory">
            <option value="">Toutes les catégories</option>
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">
              {{ cat.name }}
            </option>
          </select>
        </div>

        <div class="filters__field">
          <label for="format">Format</label>
          <select id="format" v-model="selectedFormat">
            <option value="">Tous les formats</option>
            <option v-for="fmt in formats" :key="fmt.id" :value="fmt.id">
              {{ fmt.type }}
            </option>
          </select>
        </div>

        <div class="filters__field">
          <label for="sort">Trier par date</label>
          <select id="sort" v-model="sortOrder">
            <option value="desc">Plus récent d'abord</option>
            <option value="asc">Plus ancien d'abord</option>
          </select>
        </div>

        <button v-if="isFiltered" class="filters__reset" @click="resetFilters">
          Réinitialiser
        </button>

      </div>
    </section>

    <!-- Chargement -->
    <div v-if="loading" class="activities-state container">
      <p>Chargement des activités…</p>
    </div>

    <!-- Erreur -->
    <div v-else-if="error" class="activities-state activities-state--error container">
      <p>{{ error }}</p>
    </div>

    <!-- Listing -->
    <section v-else class="container activities-list">
      <p v-if="filteredActivities.length === 0" class="activities-state">
        Aucune activité ne correspond à votre recherche.
      </p>
      <div v-else class="activities-grid">
        <router-link
          v-for="activity in filteredActivities"
          :key="activity.id"
          :to="`/activities/${activity.id}`"
          class="activity-card"
        >
          <!-- Image de prévisualisation -->
          <div class="activity-card__thumb">
            <img
              :src="thumbUrl(activity)"
              :alt="activity.title"
              class="activity-card__img"
              @error="onImgError($event)"
            />
            <!-- Bandeau format superposé -->
            <div class="activity-card__format" :class="`format--${formatSlug(activity.format?.type)}`">
              <span>{{ formatIcon(activity.format?.type) }} {{ activity.format?.type }}</span>
            </div>
          </div>

          <div class="activity-card__body">
            <span v-if="activity.category" class="activity-card__tag">{{ activity.category.name }}</span>
            <h2 class="activity-card__title">{{ activity.title }}</h2>
            <p v-if="activity.description" class="activity-card__excerpt">{{ activity.description }}</p>
            <span v-if="activity.duration" class="activity-card__duration">⏱ {{ activity.duration }}</span>
          </div>

          <div class="activity-card__footer">
            <span class="activity-card__cta">Accéder à l'activité →</span>
          </div>
        </router-link>
      </div>
    </section>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const activities       = ref([])
const loading          = ref(true)
const error            = ref(null)

const searchText       = ref('')
const selectedCategory = ref('')
const selectedFormat   = ref('')
const sortOrder        = ref('desc')

onMounted(async () => {
  try {
    const res = await fetch('/api/activities/')
    if (!res.ok) throw new Error('Impossible de charger les activités.')
    activities.value = await res.json()
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
})

const categories = computed(() => {
  const seen = new Map()
  activities.value.forEach(a => {
    if (a.category && !seen.has(a.category.id)) seen.set(a.category.id, a.category)
  })
  return [...seen.values()]
})

const formats = computed(() => {
  const seen = new Map()
  activities.value.forEach(a => {
    if (a.format && !seen.has(a.format.id)) seen.set(a.format.id, a.format)
  })
  return [...seen.values()]
})

const isFiltered = computed(() =>
  searchText.value !== '' || selectedCategory.value !== '' ||
  selectedFormat.value !== '' || sortOrder.value !== 'desc'
)

const filteredActivities = computed(() =>
  activities.value
    .filter(a => {
      const matchText     = searchText.value === '' ||
        a.title.toLowerCase().includes(searchText.value.toLowerCase())
      const matchCategory = selectedCategory.value === '' || a.category?.id === selectedCategory.value
      const matchFormat   = selectedFormat.value === '' || a.format?.id === selectedFormat.value
      return matchText && matchCategory && matchFormat
    })
    .sort((a, b) => {
      const da = a.created_at ? new Date(a.created_at) : new Date(0)
      const db = b.created_at ? new Date(b.created_at) : new Date(0)
      return sortOrder.value === 'desc' ? db - da : da - db
    })
)

function resetFilters() {
  searchText.value       = ''
  selectedCategory.value = ''
  selectedFormat.value   = ''
  sortOrder.value        = 'desc'
}

function youtubeId(url) {
  if (!url) return null
  const match = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})/)
  return match ? match[1] : null
}

function thumbUrl(activity) {
  // Vidéo YouTube → miniature auto
  const ytId = youtubeId(activity.url)
  if (ytId) return `https://img.youtube.com/vi/${ytId}/hqdefault.jpg`
  // Autre format → photo stockée dans assets
  if (activity.photo) return `/src/assets/img/${activity.photo}`
  // Fallback par format
  const slug = formatSlug(activity.format?.type)
  if (slug === 'pdf')   return '/src/assets/img/placeholder-pdf.jpg'
  if (slug === 'audio') return '/src/assets/img/placeholder-audio.jpg'
  return '/src/assets/img/placeholder-activity.jpg'
}

function onImgError(e) {
  e.target.style.display = 'none'
}

function formatIcon(type) {
  if (!type) return '🎯'
  const t = type.toLowerCase()
  if (t.includes('vid')) return '▶'
  if (t.includes('pdf')) return '📄'
  if (t.includes('audio')) return '🎧'
  return '🎯'
}

function formatSlug(type) {
  if (!type) return 'other'
  const t = type.toLowerCase()
  if (t.includes('vid'))   return 'video'
  if (t.includes('pdf'))   return 'pdf'
  if (t.includes('audio')) return 'audio'
  return 'other'
}
</script>

<style scoped>
/* Hero */
.activities-hero {
  background: linear-gradient(135deg, #5c724e 0%, #14b8a6 100%);
  padding: 3.5rem 1.5rem;
  text-align: center;
  color: #ffffff;
}
.activities-hero h1 {
  font-size: clamp(1.75rem, 4vw, 2.5rem);
  font-weight: 700;
  margin-bottom: 0.75rem;
}
.activities-hero p {
  font-size: 1.05rem;
  color: rgba(255,255,255,0.85);
  max-width: 520px;
  margin: 0 auto;
  line-height: 1.6;
}

/* Filtres */
.filters { padding: 1.5rem 1.5rem 0; }
.filters__inner {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  gap: 1rem;
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  padding: 1.25rem 1.5rem;
}
.filters__field {
  display: flex;
  flex-direction: column;
  gap: 0.3rem;
  flex: 1;
  min-width: 160px;
}
.filters__field label {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-text-muted);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}
.filters__field input,
.filters__field select {
  padding: 0.5rem 0.75rem;
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  font-size: 0.9rem;
  color: var(--color-text);
  background-color: var(--color-background);
  transition: border-color var(--transition);
}
.filters__field input:focus,
.filters__field select:focus {
  outline: none;
  border-color: var(--color-primary);
}
.filters__reset {
  padding: 0.5rem 1rem;
  background: none;
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  font-size: 0.85rem;
  color: var(--color-text-muted);
  cursor: pointer;
  transition: border-color var(--transition), color var(--transition);
  white-space: nowrap;
  align-self: flex-end;
}
.filters__reset:hover { border-color: var(--color-primary); color: var(--color-primary); }

/* États */
.activities-state { padding: 3rem 1.5rem; color: var(--color-text-muted); }
.activities-state--error { color: #991b1b; }

/* Grid */
.activities-list { padding: 2rem 1.5rem 3rem; }
.activities-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

/* Card */
.activity-card {
  display: flex;
  flex-direction: column;
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  text-decoration: none;
  overflow: hidden;
  transition: box-shadow var(--transition), transform var(--transition), border-color var(--transition);
}
.activity-card:hover {
  box-shadow: 0 6px 20px rgba(20,184,166,0.15);
  transform: translateY(-3px);
  border-color: var(--color-primary);
}

/* Thumbnail */
.activity-card__thumb {
  position: relative;
  overflow: hidden;
}
.activity-card__img {
  width: 100%;
  height: 170px;
  object-fit: cover;
  display: block;
  border-radius: var(--border-radius) var(--border-radius) 0 0;
}

/* Badge format superposé sur l'image */
.activity-card__format {
  position: absolute;
  bottom: 0.6rem;
  left: 0.75rem;
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  padding: 0.25rem 0.65rem;
  border-radius: 999px;
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  backdrop-filter: blur(4px);
}
.format--video { background-color: rgba(237,233,254,0.92); color: #5b21b6; }
.format--pdf   { background-color: rgba(254,226,226,0.92); color: #991b1b; }
.format--audio { background-color: rgba(254,243,199,0.92); color: #92400e; }
.format--other { background-color: rgba(240,253,250,0.92); color: var(--color-primary-dark); }

/* Corps */
.activity-card__body {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  padding: 1.25rem 1.25rem 0.75rem;
  flex: 1;
}
.activity-card__tag {
  display: inline-block;
  background-color: var(--color-surface-teal);
  color: var(--color-primary-dark);
  font-size: 0.72rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  padding: 0.2rem 0.65rem;
  border-radius: 999px;
  align-self: flex-start;
}
.activity-card__title {
  font-size: 1rem;
  font-weight: 700;
  color: var(--color-text);
  line-height: 1.4;
  margin: 0;
}
.activity-card__excerpt {
  font-size: 0.875rem;
  color: var(--color-text-muted);
  line-height: 1.6;
  margin: 0;
}
.activity-card__duration { font-size: 0.8rem; color: var(--color-text-muted); }

/* Footer carte */
.activity-card__footer {
  padding: 0.75rem 1.25rem;
  border-top: 1px solid var(--color-border);
  margin-top: auto;
}
.activity-card__cta {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--color-primary);
}

@media (max-width: 600px) {
  .filters__field { min-width: 100%; }
}
</style>
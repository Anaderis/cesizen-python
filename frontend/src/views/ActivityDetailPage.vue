<template>
  <div class="activity-page">

    <!-- Breadcrumb -->
    <nav class="breadcrumb container" aria-label="Fil d'Ariane">
      <router-link to="/activities">Activités de détente</router-link>
      <span class="breadcrumb__sep" aria-hidden="true">›</span>
      <span>{{ activity?.title ?? '…' }}</span>
    </nav>

    <!-- Chargement -->
    <div v-if="loading" class="activity-state container">
      <p>Chargement de l'activité…</p>
    </div>

    <!-- Erreur -->
    <div v-else-if="error" class="activity-state activity-state--error container">
      <p>{{ error }}</p>
      <router-link to="/activities" class="btn btn-outline">← Retour aux activités</router-link>
    </div>

    <!-- Contenu -->
    <div v-else class="container activity-detail">

      <!-- En-tête -->
      <header class="activity-detail__header">
        <div class="activity-detail__meta">
          <span class="activity-badge" :class="`format--${formatSlug}`">
            {{ formatIcon }} {{ activity.format?.type }}
          </span>
          <span v-if="activity.category" class="activity-tag">{{ activity.category.name }}</span>
          <span v-if="activity.duration" class="activity-duration">⏱ {{ activity.duration }}</span>
        </div>
        <h1 class="activity-detail__title">{{ activity.title }}</h1>
        <p v-if="activity.description" class="activity-detail__description">{{ activity.description }}</p>

        <!-- Bouton favori (utilisateur connecté uniquement) -->
        <button
          v-if="isLoggedIn"
          @click="toggleFavorite"
          :class="['btn', 'btn-favorite', { 'btn-favorite--active': isFavorite }]"
        >
          {{ isFavorite ? '♥ Retirer des favoris' : '♡ Ajouter aux favoris' }}
        </button>
      </header>

      <!-- ===== VIDÉO YouTube ===== -->
      <div v-if="formatSlug === 'video'" class="activity-media">
        <div v-if="youtubeEmbedUrl" class="activity-media__video-wrapper">
          <iframe
            :src="youtubeEmbedUrl"
            title="Vidéo YouTube"
            frameborder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowfullscreen
          ></iframe>
        </div>
        <div v-else class="activity-media__fallback">
          <a :href="activity.url" target="_blank" rel="noopener noreferrer" class="btn btn-primary">
            ▶ Regarder la vidéo
          </a>
        </div>
      </div>

      <!-- ===== PDF ===== -->
      <div v-else-if="formatSlug === 'pdf'" class="activity-media">
        <div class="activity-media__pdf-wrapper">
          <iframe
            :src="activity.url"
            title="Document PDF"
          ></iframe>
        </div>
        <a :href="activity.url" target="_blank" rel="noopener noreferrer" class="activity-media__pdf-link">
          📄 Ouvrir le PDF dans un nouvel onglet
        </a>
      </div>

      <!-- ===== AUDIO ===== -->
      <div v-else-if="formatSlug === 'audio'" class="activity-media">
        <div class="activity-media__audio-wrapper">
          <audio controls :src="activity.url">
            Votre navigateur ne supporte pas la lecture audio.
          </audio>
          <a :href="activity.url" target="_blank" rel="noopener noreferrer" class="activity-media__pdf-link">
            🎧 Ouvrir l'audio dans un nouvel onglet
          </a>
        </div>
      </div>

      <!-- ===== Autre / lien externe ===== -->
      <div v-else class="activity-media activity-media--link">
        <p>Accédez à cette ressource via le lien ci-dessous :</p>
        <a :href="activity.url" target="_blank" rel="noopener noreferrer" class="btn btn-primary">
          Accéder à l'activité →
        </a>
      </div>

      <!-- Footer -->
      <div class="activity-detail__footer">
        <router-link to="/activities" class="btn btn-outline">← Retour aux activités</router-link>
      </div>

    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'

const route    = useRoute()
const activity = ref(null)
const loading  = ref(true)
const error    = ref(null)
const isFavorite = ref(false)

const isLoggedIn = !!localStorage.getItem('token')

function authHeaders() {
  return { 'Authorization': `Bearer ${localStorage.getItem('token')}`, 'Content-Type': 'application/json' }
}

onMounted(async () => {
  try {
    const res = await fetch(`/api/activities/${route.params.id}`)
    if (!res.ok) throw new Error('Activité introuvable.')
    activity.value = await res.json()

    // Vérifie si déjà en favori
    if (isLoggedIn) {
      const favRes = await fetch('/api/users/me/favorites', { headers: authHeaders() })
      if (favRes.ok) {
        const favs = await favRes.json()
        isFavorite.value = favs.some(f => f.id === activity.value.id)
      }
    }
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
})

const formatSlug = computed(() => {
  const type = activity.value?.format?.type?.toLowerCase() ?? ''
  const url  = activity.value?.url?.toLowerCase() ?? ''
  if (type.includes('vid') || url.match(/youtube\.com|youtu\.be/)) return 'video'
  if (type.includes('pdf') || url.endsWith('.pdf'))                  return 'pdf'
  if (type.includes('audio') || url.match(/\.(mp3|wav|ogg|m4a)$/))  return 'audio'
  return 'other'
})

const formatIcon = computed(() => {
  const s = formatSlug.value
  if (s === 'video') return '▶'
  if (s === 'pdf')   return '📄'
  if (s === 'audio') return '🎧'
  return '🎯'
})

// Convertit une URL YouTube classique en URL embed
const youtubeEmbedUrl = computed(() => {
  const url = activity.value?.url ?? ''
  const match = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})/)
  if (match) return `https://www.youtube.com/embed/${match[1]}`
  if (url.includes('youtube.com/embed/')) return url
  return null
})

async function toggleFavorite() {
  const method = isFavorite.value ? 'DELETE' : 'POST'
  const res = await fetch(`/api/activities/${activity.value.id}/favorite`, { method, headers: authHeaders() })
  if (res.ok) isFavorite.value = !isFavorite.value
}
</script>

<style scoped>
.activity-page { padding-bottom: 4rem; }

/* Breadcrumb */
.breadcrumb {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 1rem 1.5rem;
  font-size: 0.875rem;
  color: var(--color-text-muted);
}
.breadcrumb a { color: var(--color-primary); text-decoration: none; }
.breadcrumb a:hover { text-decoration: underline; }
.breadcrumb__sep { color: var(--color-border); }

/* États */
.activity-state { padding: 3rem 1.5rem; color: var(--color-text-muted); }
.activity-state--error { color: #991b1b; }

/* Layout */
.activity-detail {
  max-width: 860px;
  margin: 0 auto;
  padding: 0 1.5rem 2rem;
}

/* Header */
.activity-detail__header {
  margin-bottom: 2rem;
  padding-bottom: 1.5rem;
  border-bottom: 2px solid var(--color-surface-teal);
}
.activity-detail__meta {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.6rem;
  margin-bottom: 1rem;
}
.activity-badge {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  padding: 0.25rem 0.75rem;
  border-radius: 999px;
}
.format--video { background-color: #ede9fe; color: #5b21b6; }
.format--pdf   { background-color: #fee2e2; color: #991b1b; }
.format--audio { background-color: #fef3c7; color: #92400e; }
.format--other { background-color: var(--color-surface-teal); color: var(--color-primary-dark); }

.activity-tag {
  display: inline-block;
  background-color: var(--color-surface-teal);
  color: var(--color-primary-dark);
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  padding: 0.25rem 0.75rem;
  border-radius: 999px;
}
.activity-duration { font-size: 0.85rem; color: var(--color-text-muted); }

.activity-detail__title {
  font-size: clamp(1.4rem, 3vw, 2rem);
  font-weight: 700;
  color: var(--color-text);
  line-height: 1.3;
  margin-bottom: 0.75rem;
}
.activity-detail__description {
  font-size: 1rem;
  color: var(--color-text-muted);
  line-height: 1.7;
}
.btn-favorite {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  margin-top: 1rem;
  padding: 0.5rem 1.25rem;
  border: 2px solid var(--color-primary);
  border-radius: var(--border-radius);
  background: transparent;
  color: var(--color-primary);
  font-weight: 600;
  font-size: 0.9rem;
  cursor: pointer;
  transition: background-color var(--transition), color var(--transition);
}
.btn-favorite:hover,
.btn-favorite--active {
  background-color: var(--color-primary);
  color: #ffffff;
}

/* ===== Media ===== */
.activity-media { margin-bottom: 2rem; }

/* Vidéo 16:9 */
.activity-media__video-wrapper {
  position: relative;
  padding-top: 56.25%;
  border-radius: var(--border-radius);
  overflow: hidden;
  background: #000;
}
.activity-media__video-wrapper iframe {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
}

/* PDF */
.activity-media__pdf-wrapper {
  border-radius: var(--border-radius);
  overflow: hidden;
  border: 1px solid var(--color-border);
}
.activity-media__pdf-wrapper iframe {
  width: 100%;
  height: 600px;
  display: block;
}
.activity-media__pdf-link {
  display: inline-block;
  margin-top: 0.75rem;
  font-size: 0.875rem;
  color: var(--color-primary);
  text-decoration: none;
}
.activity-media__pdf-link:hover { text-decoration: underline; }

/* Audio */
.activity-media__audio-wrapper {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  padding: 2rem;
  align-items: center;
}
.activity-media__audio-wrapper audio {
  width: 100%;
  max-width: 500px;
}

/* Lien externe */
.activity-media--link {
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  padding: 2rem;
  text-align: center;
}
.activity-media--link p {
  color: var(--color-text-muted);
  margin-bottom: 1.25rem;
}

/* Footer */
.activity-detail__footer {
  margin-top: 2.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid var(--color-border);
}
.btn-outline {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.6rem 1.25rem;
  border: 2px solid var(--color-primary);
  border-radius: var(--border-radius);
  color: var(--color-primary);
  font-weight: 600;
  font-size: 0.9rem;
  text-decoration: none;
  transition: background-color var(--transition), color var(--transition);
}
.btn-outline:hover { background-color: var(--color-primary); color: #ffffff; }
</style>
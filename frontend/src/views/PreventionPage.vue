<template>
  <div class="prevention-page">

    <!-- Hero -->
    <section class="prevention-hero">
      <div class="container prevention-hero__inner">
        <h1>Santé mentale &amp; prévention</h1>
        <p>Des ressources fiables pour comprendre, prévenir et prendre soin de votre bien-être psychique.</p>
      </div>
    </section>

    <!-- Filtres -->
    <section v-if="!loading && !error" class="container filters">
      <div class="filters__inner">

        <!-- Recherche textuelle -->
        <div class="filters__field">
          <label for="search">Rechercher</label>
          <input
            id="search"
            v-model="searchText"
            type="search"
            placeholder="Titre de l'article…"
          />
        </div>

        <!-- Filtre catégorie -->
        <div class="filters__field">
          <label for="category">Catégorie</label>
          <select id="category" v-model="selectedCategory">
            <option value="">Toutes les catégories</option>
            <option v-for="cat in categories" :key="cat.id" :value="cat.id">
              {{ cat.name }}
            </option>
          </select>
        </div>

        <!-- Tri par date -->
        <div class="filters__field">
          <label for="sort">Trier par date</label>
          <select id="sort" v-model="sortOrder">
            <option value="desc">Du plus récent au plus ancien</option>
            <option value="asc">Du plus ancien au plus récent</option>
          </select>
        </div>

        <!-- Bouton reset -->
        <button v-if="isFiltered" class="filters__reset" @click="resetFilters">
          Réinitialiser
        </button>

      </div>
    </section>

    <!-- Chargement -->
    <div v-if="loading" class="prevention-state container">
      <p>Chargement des articles…</p>
    </div>

    <!-- Erreur -->
    <div v-else-if="error" class="prevention-state prevention-state--error container">
      <p>{{ error }}</p>
    </div>

    <!-- Listing -->
    <section v-else class="container prevention-articles">
      <p v-if="filteredArticles.length === 0" class="prevention-state">
        Aucun article ne correspond à votre recherche.
      </p>
      <div v-else class="articles-grid">
        <router-link
          v-for="article in filteredArticles"
          :key="article.id"
          :to="`/prevention/${article.id}`"
          class="article-card"
        >
          <img
            v-if="article.photo"
            :src="`/src/assets/img/${article.photo}`"
            :alt="article.title"
            class="article-card__img"
          />
          <div class="article-card__body">
            <span v-if="article.category" class="article-card__tag">{{ article.category.name }}</span>
            <h2 class="article-card__title">{{ article.title }}</h2>
            <p v-if="article.description" class="article-card__excerpt">{{ article.description }}</p>
            <span class="article-card__cta">Lire l'article →</span>
          </div>
        </router-link>
      </div>
    </section>

  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

const articles        = ref([])
const loading         = ref(true)
const error           = ref(null)

const searchText       = ref('')
const selectedCategory = ref('')
const sortOrder        = ref('desc')

onMounted(async () => {
  try {
    const res = await fetch('/api/articles/')
    if (!res.ok) throw new Error('Impossible de charger les articles.')
    articles.value = await res.json()
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
})

// Liste dédupliquée des catégories présentes dans les articles chargés
const categories = computed(() => {
  const seen = new Map()
  articles.value.forEach(a => {
    if (a.category && !seen.has(a.category.id)) {
      seen.set(a.category.id, a.category)
    }
  })
  return [...seen.values()]
})

const isFiltered = computed(() =>
  searchText.value !== '' || selectedCategory.value !== '' || sortOrder.value !== 'desc'
)

const filteredArticles = computed(() => {
  return articles.value
    .filter(a => {
      const matchText = searchText.value === '' ||
        a.title.toLowerCase().includes(searchText.value.toLowerCase())

      const matchCategory = selectedCategory.value === '' ||
        a.category?.id === selectedCategory.value

      return matchText && matchCategory
    })
    .sort((a, b) => {
      const dateA = a.publish_date ? new Date(a.publish_date) : new Date(0)
      const dateB = b.publish_date ? new Date(b.publish_date) : new Date(0)
      return sortOrder.value === 'desc' ? dateB - dateA : dateA - dateB
    })
})

function resetFilters() {
  searchText.value       = ''
  selectedCategory.value = ''
  sortOrder.value        = 'desc'
}
</script>

<style scoped>
/* Hero */
.prevention-hero {
  background: linear-gradient(135deg, #0d9488 0%, #14b8a6 50%, #5eead4 100%);
  padding: 3.5rem 1.5rem;
  text-align: center;
  color: #ffffff;
}
.prevention-hero h1 {
  font-size: clamp(1.75rem, 4vw, 2.5rem);
  font-weight: 700;
  margin-bottom: 0.75rem;
}
.prevention-hero p {
  font-size: 1.05rem;
  color: rgba(255, 255, 255, 0.85);
  max-width: 560px;
  margin: 0 auto;
  line-height: 1.6;
}

/* Filtres */
.filters {
  padding: 1.5rem 1.5rem 0;
}
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
  min-width: 180px;
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
.filters__reset:hover {
  border-color: var(--color-primary);
  color: var(--color-primary);
}

/* États */
.prevention-state {
  padding: 3rem 1.5rem;
  color: var(--color-text-muted);
}
.prevention-state--error { color: #991b1b; }

/* Grid */
.prevention-articles {
  padding: 2rem 1.5rem 3rem;
}
.articles-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
}

/* Card */
.article-card {
  display: flex;
  flex-direction: column;
  gap: 0;
  padding: 0;
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  text-decoration: none;
  transition: box-shadow var(--transition), transform var(--transition), border-color var(--transition);
}
.article-card:hover {
  box-shadow: 0 6px 20px rgba(20, 184, 166, 0.15);
  transform: translateY(-3px);
  border-color: var(--color-primary);
}
.article-card__img {
  width: 100%;
  height: 180px;
  object-fit: cover;
  border-radius: var(--border-radius) var(--border-radius) 0 0;
  display: block;
}
.article-card__body {
  display: flex;
  flex-direction: column;
  gap: 0.6rem;
  padding: 1.25rem;
  flex: 1;
}
.article-card__tag {
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
.article-card__title {
  font-size: 1.05rem;
  font-weight: 700;
  color: var(--color-text);
  line-height: 1.4;
  margin: 0;
}
.article-card__excerpt {
  font-size: 0.875rem;
  color: var(--color-text-muted);
  line-height: 1.6;
  flex: 1;
  margin: 0;
}
.article-card__cta {
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--color-primary);
  margin-top: 0.25rem;
}

@media (max-width: 600px) {
  .filters__field { min-width: 100%; }
}
</style>

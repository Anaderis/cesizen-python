<template>
  <div class="article-page">

    <!-- Breadcrumb -->
    <nav class="breadcrumb container" aria-label="Fil d'Ariane">
      <router-link to="/prevention">Santé mentale</router-link>
      <span class="breadcrumb__sep" aria-hidden="true">›</span>
      <span>{{ article?.title ?? '…' }}</span>
    </nav>

    <!-- Chargement -->
    <div v-if="loading" class="article-state container">
      <p>Chargement de l'article…</p>
    </div>

    <!-- Erreur -->
    <div v-else-if="error" class="article-state container article-state--error">
      <p>{{ error }}</p>
      <router-link to="/prevention" class="btn btn-outline">← Retour aux articles</router-link>
    </div>

    <!-- Article -->
    <article v-else class="article container">

      <header class="article__header">
        <span v-if="article.category" class="article__tag">{{ article.category.name }}</span>
        <h1 class="article__title">{{ article.title }}</h1>
        <p v-if="article.publish_date" class="article__date">
          Publié le {{ formatDate(article.publish_date) }}
        </p>
      </header>

      <!-- Contenu HTML venant de la BDD -->
      <div class="article__body" v-html="article.content"></div>

      <div class="article__footer">
        <router-link to="/prevention" class="btn btn-outline">← Retour aux articles</router-link>
      </div>

    </article>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'

const route  = useRoute()
const article = ref(null)
const loading = ref(true)
const error   = ref(null)

onMounted(async () => {
  try {
    const res = await fetch(`/api/articles/${route.params.id}`)
    if (!res.ok) throw new Error('Article introuvable.')
    article.value = await res.json()
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
})

function formatDate(dateStr) {
  return new Date(dateStr).toLocaleDateString('fr-FR', {
    day: 'numeric', month: 'long', year: 'numeric'
  })
}
</script>

<style scoped>
.article-page {
  padding-bottom: 4rem;
}

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

/* États chargement / erreur */
.article-state {
  padding: 3rem 1.5rem;
  color: var(--color-text-muted);
}
.article-state--error { color: #991b1b; }

/* Layout article */
.article {
  max-width: 780px;
  margin: 0 auto;
  padding: 0 1.5rem 2rem;
}

/* Header */
.article__header {
  margin-bottom: 2rem;
  padding-bottom: 1.5rem;
  border-bottom: 2px solid var(--color-surface-teal);
}
.article__tag {
  display: inline-block;
  background-color: var(--color-surface-teal);
  color: var(--color-primary-dark);
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  padding: 0.25rem 0.75rem;
  border-radius: 999px;
  margin-bottom: 1rem;
}
.article__title {
  font-size: clamp(1.5rem, 3vw, 2.25rem);
  font-weight: 700;
  color: var(--color-text);
  line-height: 1.3;
  margin-bottom: 0.5rem;
}
.article__date {
  font-size: 0.8rem;
  color: var(--color-text-muted);
}

/* Corps — styles pour le HTML injecté via v-html */
.article__body :deep(p) {
  color: var(--color-text);
  line-height: 1.8;
  margin-bottom: 0.9rem;
}
.article__body :deep(h2) {
  font-size: 1.3rem;
  font-weight: 700;
  color: var(--color-primary-dark);
  margin: 2rem 0 1rem;
  padding-bottom: 0.4rem;
  border-bottom: 1px solid var(--color-border);
}
.article__body :deep(h3) {
  font-size: 1rem;
  font-weight: 700;
  color: var(--color-primary-dark);
  margin-bottom: 0.5rem;
}
.article__body :deep(ul) {
  padding-left: 1.5rem;
  margin-bottom: 1rem;
}
.article__body :deep(li) {
  color: var(--color-text);
  line-height: 1.8;
  margin-bottom: 0.5rem;
}
.article__body :deep(strong) {
  font-weight: 600;
}

/* Classes utilisées dans le HTML stocké en BDD */
.article__body :deep(.article-sources) {
  font-size: 0.8rem;
  color: var(--color-text-muted);
  font-style: italic;
  line-height: 1.5;
  margin-bottom: 1.5rem;
}
.article__body :deep(.article-intro) {
  background: linear-gradient(135deg, #f0fdfa, #d1fae5);
  border-left: 4px solid var(--color-primary);
  border-radius: 0 var(--border-radius) var(--border-radius) 0;
  padding: 1.25rem 1.5rem;
  margin-bottom: 2rem;
}
.article__body :deep(.article-warning) {
  background-color: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: var(--border-radius);
  padding: 1rem 1.25rem;
  margin: 1rem 0;
}
.article__body :deep(.article-warning p) {
  color: #991b1b;
  margin: 0;
  font-weight: 500;
}
.article__body :deep(.article-callout) {
  background-color: #fff7ed;
  border: 1px solid #fed7aa;
  border-radius: var(--border-radius);
  padding: 1rem 1.25rem;
  margin: 1rem 0;
}
.article__body :deep(.article-callout p) {
  color: #92400e;
  margin: 0;
}
.article__body :deep(.article-highlight) {
  background: linear-gradient(135deg, var(--color-surface-teal), #ccfbf1);
  border: 1px solid #99f6e4;
  border-radius: var(--border-radius);
  padding: 1.25rem 1.5rem;
  margin-top: 1rem;
}
.article__body :deep(.article-highlight p) {
  color: var(--color-text);
  margin: 0;
}
.article__body :deep(.article-cards) {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  margin-top: 1rem;
}
.article__body :deep(.article-card) {
  background-color: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  padding: 1.25rem;
}
.article__body :deep(.article-card p) {
  font-size: 0.9rem;
  color: var(--color-text-muted);
  line-height: 1.6;
  margin: 0;
}

/* Footer */
.article__footer {
  margin-top: 3rem;
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
.btn-outline:hover {
  background-color: var(--color-primary);
  color: #ffffff;
}

@media (max-width: 600px) {
  .article__body :deep(.article-cards) { grid-template-columns: 1fr; }
}
</style>

<template>
  <!-- CAROUSEL HERO -->
  <section class="carousel" aria-label="Articles à la une">

    <!-- Slides -->
    <div class="carousel__track">
      <transition name="slide" mode="out-in">
        <div
          v-if="carouselArticles.length"
          :key="currentIndex"
          class="carousel__slide"
          :style="slideStyle"
        >
          <div class="carousel__overlay"></div>
          <div class="container carousel__content">
            <span class="carousel__tag">{{ carouselArticles[currentIndex].category?.name }}</span>
            <h1 class="carousel__title">{{ carouselArticles[currentIndex].title }}</h1>
            <p class="carousel__excerpt">{{ carouselArticles[currentIndex].description }}</p>
            <router-link
              :to="`/prevention/${carouselArticles[currentIndex].id}`"
              class="btn carousel__btn"
            >
              Lire l'article →
            </router-link>
          </div>
        </div>

        <!-- Fallback si pas d'articles -->
        <div v-else key="fallback" class="carousel__slide carousel__slide--fallback">
          <div class="container carousel__content">
            <h1 class="carousel__title">Prenez soin de votre<br>santé mentale</h1>
            <p class="carousel__excerpt">
              CESIZen vous accompagne avec des ressources adaptées et des activités de détente.
            </p>
            <router-link to="/prevention" class="btn carousel__btn">Découvrir les articles →</router-link>
          </div>
        </div>
      </transition>
    </div>

    <!-- Contrôles -->
    <div v-if="carouselArticles.length > 1" class="carousel__controls">
      <button class="carousel__arrow" @click="prev" aria-label="Article précédent">‹</button>

      <div class="carousel__dots">
        <button
          v-for="(_, i) in carouselArticles"
          :key="i"
          :class="['carousel__dot', { active: i === currentIndex }]"
          @click="currentIndex = i"
          :aria-label="`Article ${i + 1}`"
        ></button>
      </div>

      <button class="carousel__arrow" @click="next" aria-label="Article suivant">›</button>
    </div>

  </section>

  <!-- FONCTIONNALITÉS -->
  <section class="features">
    <div class="container">
      <h2 class="section-title">Que propose CESIZen ?</h2>
      <div class="features__grid">

        <article class="card feature-card">
          <img src="../assets/img/img-articles.jpg" alt="Personne se reposant dans la nature" class="feature-card__img" />
          <h3>Articles santé mentale</h3>
          <p>Accédez à des ressources fiables sur le stress, l'anxiété, le burn-out et bien d'autres thématiques.</p>
        </article>

        <article class="card feature-card">
          <img src="../assets/img/img-activities.jpg" alt="Femme pratiquant la méditation en plein air" class="feature-card__img" />
          <h3>Activités de détente</h3>
          <p>Découvrez des exercices de méditation, respiration et relaxation adaptés à votre rythme.</p>
        </article>

        <article class="card feature-card">
          <img src="../assets/img/img-personal.jpg" alt="Personne contemplant un paysage de montagne" class="feature-card__img" />
          <h3>Espace personnalisé</h3>
          <p>Sauvegardez vos activités favorites et retrouvez-les facilement depuis votre compte.</p>
        </article>

      </div>
    </div>
  </section>

  <!-- APPEL À L'ACTION -->
  <section class="cta">
    <div class="container cta__content">
      <h2>Commencez dès aujourd'hui</h2>
      <p>L'inscription est gratuite et prend moins d'une minute.</p>
      <router-link to="/login" class="btn btn-cta">Rejoindre CESIZen</router-link>
    </div>
  </section>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'

const articles     = ref([])
const currentIndex = ref(0)
let   autoplayTimer = null

onMounted(async () => {
  try {
    const res = await fetch('/api/articles/')
    if (res.ok) {
      const data = await res.json()
      // On prend les 3 premiers articles actifs
      articles.value = data.filter(a => a.active).slice(0, 3)
    }
  } catch (_) { /* silencieux — fallback affiché */ }

  startAutoplay()
})

onUnmounted(() => clearInterval(autoplayTimer))

const carouselArticles = computed(() => articles.value)

const slideStyle = computed(() => {
  const article = carouselArticles.value[currentIndex.value]
  if (article?.photo) {
    return { backgroundImage: `url(/src/assets/img/${article.photo})` }
  }
  return {}
})

function next() {
  currentIndex.value = (currentIndex.value + 1) % carouselArticles.value.length
  restartAutoplay()
}

function prev() {
  currentIndex.value = (currentIndex.value - 1 + carouselArticles.value.length) % carouselArticles.value.length
  restartAutoplay()
}

function startAutoplay() {
  autoplayTimer = setInterval(next, 5000)
}

function restartAutoplay() {
  clearInterval(autoplayTimer)
  startAutoplay()
}
</script>

<style scoped>
/* ========================
   CAROUSEL
   ======================== */
.carousel {
  position: relative;
  overflow: hidden;
}

.carousel__track {
  min-height: 480px;
}

.carousel__slide {
  min-height: 480px;
  display: flex;
  align-items: center;
  background: linear-gradient(135deg, #0d9488 0%, #14b8a6 60%, #5c724e 100%);
  background-size: cover;
  background-position: center;
  position: relative;
}

/* Overlay sombre pour lisibilité sur photo */
.carousel__overlay {
  position: absolute;
  inset: 0;
  background: linear-gradient(to right, rgba(0,0,0,0.55) 0%, rgba(0,0,0,0.2) 100%);
}

.carousel__slide--fallback {
  background: linear-gradient(135deg, #0d9488 0%, #14b8a6 60%, #5c724e 100%);
}

.carousel__content {
  position: relative;
  z-index: 1;
  padding: 4rem 1.5rem;
  max-width: 680px;
}

.carousel__tag {
  display: inline-block;
  background: rgba(255,255,255,0.2);
  backdrop-filter: blur(4px);
  color: #ffffff;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.08em;
  padding: 0.25rem 0.75rem;
  border-radius: 999px;
  margin-bottom: 1rem;
}

.carousel__title {
  font-size: clamp(1.6rem, 4vw, 2.5rem);
  font-weight: 700;
  color: #ffffff;
  line-height: 1.3;
  margin-bottom: 1rem;
}

.carousel__excerpt {
  font-size: 1rem;
  color: rgba(255,255,255,0.95);
  line-height: 1.7;
  margin-bottom: 2rem;
  max-width: 520px;
  text-shadow: 0 1px 4px rgba(0,0,0,0.5);
  padding-bottom: 1.25rem;
  border-bottom: 1px solid rgba(255,255,255,0.3);
}

.carousel__btn {
  background-color: #ffffff;
  color: var(--color-primary-dark);
  font-weight: 700;
  padding: 0.75rem 1.75rem;
  border-radius: var(--border-radius);
  text-decoration: none;
  display: inline-block;
  transition: background-color var(--transition), transform var(--transition);
}

.carousel__btn:hover {
  background-color: var(--color-surface-teal);
  transform: translateY(-2px);
}

/* Contrôles */
.carousel__controls {
  position: absolute;
  bottom: 1.5rem;
  left: 0;
  right: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  z-index: 2;
}

.carousel__arrow {
  background: rgba(255,255,255,0.25);
  backdrop-filter: blur(4px);
  border: none;
  color: #ffffff;
  font-size: 1.5rem;
  width: 36px;
  height: 36px;
  border-radius: 50%;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: background-color var(--transition);
  line-height: 1;
}

.carousel__arrow:hover {
  background: rgba(255,255,255,0.45);
}

.carousel__dots {
  display: flex;
  gap: 0.5rem;
}

.carousel__dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  border: none;
  background: rgba(255,255,255,0.45);
  cursor: pointer;
  padding: 0;
  transition: background-color var(--transition), transform var(--transition);
}

.carousel__dot.active {
  background: #ffffff;
  transform: scale(1.3);
}

/* Transition slide */
.slide-enter-active,
.slide-leave-active {
  transition: opacity 0.5s ease, transform 0.5s ease;
}
.slide-enter-from {
  opacity: 0;
  transform: translateX(40px);
}
.slide-leave-to {
  opacity: 0;
  transform: translateX(-40px);
}

/* ========================
   FEATURES
   ======================== */
.features {
  padding: 4rem 0;
}

.section-title {
  text-align: center;
  font-size: var(--font-size-xl);
  margin-bottom: 2.5rem;
  color: var(--color-text);
}

.features__grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.5rem;
}

.feature-card {
  text-align: center;
  padding: 0;
  overflow: hidden;
}

.feature-card__img {
  width: 100%;
  height: 200px;
  object-fit: cover;
  display: block;
  border-radius: var(--border-radius) var(--border-radius) 0 0;
}

.feature-card h3 {
  padding: 1.25rem 1.5rem 0.5rem;
  font-size: var(--font-size-lg);
  margin-bottom: 0.75rem;
  color: var(--color-primary-dark);
}

.feature-card p {
  color: var(--color-text-light);
  line-height: 1.6;
  padding: 0 1.5rem 1.5rem;
}

/* ========================
   CTA
   ======================== */
.cta {
  background: linear-gradient(135deg, #ccfbf1 0%, #d1fae5 100%);
  padding: 3.5rem 0;
  text-align: center;
  color: var(--color-text);
}

.cta h2 {
  font-size: var(--font-size-xl);
  margin-bottom: 0.75rem;
  color: var(--color-primary-dark);
}

.cta p {
  font-size: var(--font-size-lg);
  margin-bottom: 1.5rem;
  color: var(--color-text-light);
}

.btn-cta {
  background-color: var(--color-primary);
  color: #ffffff;
  font-weight: 700;
  padding: 0.875rem 2rem;
  border-radius: var(--border-radius);
  text-decoration: none;
  display: inline-block;
  transition: background-color var(--transition), transform var(--transition);
}

.btn-cta:hover {
  background-color: var(--color-primary-dark);
  color: #ffffff;
  transform: translateY(-2px);
}

@media (max-width: 600px) {
  .carousel__track,
  .carousel__slide { min-height: 380px; }
  .carousel__title { font-size: 1.5rem; }
}
</style>

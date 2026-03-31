<template>
  <!-- HERO -->
  <section class="hero">
    <div class="container hero__content">
      <h1 class="hero__title">Prenez soin de votre<br>santé mentale</h1>
      <p class="hero__subtitle">
        CESIZen vous accompagne avec des ressources adaptées, des activités de détente
        et un espace personnalisé pour votre bien-être au quotidien.
      </p>
      <div class="hero__actions">
        <router-link to="/login" class="btn btn-primary">Créer un compte</router-link>
        <router-link to="/login" class="btn btn-outline">Se connecter</router-link>
      </div>
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

<style scoped>
/* Hero */
.hero {
  background: linear-gradient(135deg, #0d9488 0%, #14b8a6 60%, #5c724e 100%);
  color: #ffffff;
  padding: 5rem 0;
  text-align: center;
}

.hero__title {
  font-size: var(--font-size-2xl);
  font-weight: 700;
  margin-bottom: 1rem;
  line-height: 1.3;
}

.hero__subtitle {
  font-size: var(--font-size-lg);
  max-width: 600px;
  margin: 0 auto 2rem;
  opacity: 0.92;
  line-height: 1.7;
}

.hero__actions {
  display: flex;
  gap: 1rem;
  justify-content: center;
  flex-wrap: wrap;
}

.hero .btn-outline {
  border-color: #ffffff;
  color: #ffffff;
}

.hero .btn-outline:hover {
  background-color: #ffffff;
  color: var(--color-primary);
}

/* Features */
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

/* CTA */
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
  .hero__title { font-size: 1.6rem; }
  .hero { padding: 3rem 0; }
}
</style>

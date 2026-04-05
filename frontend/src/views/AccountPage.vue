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

    <div v-else>

      <!-- ===================== NAVIGATION ONGLETS ===================== -->
      <div class="tabs-nav" v-if="user">
        <div class="container tabs-nav__inner">
          <button
            @click="switchTab('account')"
            :class="['tab-btn', { 'tab-btn--active': activeTab === 'account' }]"
          >Mon compte</button>
          <template v-if="user.role_id === 2">
            <button
              @click="switchTab('users')"
              :class="['tab-btn', { 'tab-btn--active': activeTab === 'users' }]"
            >Gestion des utilisateurs</button>
            <button
              @click="switchTab('articles')"
              :class="['tab-btn', { 'tab-btn--active': activeTab === 'articles' }]"
            >Informations Articles</button>
            <button
              @click="switchTab('activities')"
              :class="['tab-btn', { 'tab-btn--active': activeTab === 'activities' }]"
            >Activités de détente</button>
          </template>
        </div>
      </div>

      <!-- ===================== BARRE D'ACTIONS ADMIN ===================== -->
      <div v-if="user?.role_id === 2" class="admin-actions-bar">
        <div class="container">
          <button @click="exportLogs" class="btn btn-sm btn-outline">
            ⬇ Récupérer les logs Administrateur
          </button>
        </div>
      </div>

      <!-- ===================== ONGLET 1 : MON COMPTE ===================== -->
      <div v-show="activeTab === 'account'" class="container account-layout">

        <!-- Données personnelles -->
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

        <!-- Mes favoris -->
        <section class="account-section">
          <h2 class="account-section__title">Mes favoris</h2>
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

        <!-- RGPD -->
        <section class="account-section account-section--danger">
          <h2 class="account-section__title">Confidentialité &amp; RGPD</h2>
          <p class="account-section__desc">
            Vous pouvez à tout moment désactiver ou supprimer votre compte. Ces actions sont irréversibles.
          </p>
          <div class="rgpd-actions">
            <button @click="confirmAction('deactivate')" class="btn btn-warning">Désactiver mon compte</button>
            <button @click="confirmAction('delete')" class="btn btn-danger">Supprimer mon compte</button>
          </div>
        </section>

      </div>

      <!-- ===================== ONGLET 2 : GESTION DES UTILISATEURS ===================== -->
      <div v-show="activeTab === 'users'" class="container account-layout">
        <section class="account-section">
          <div class="admin-section-header">
            <h2 class="account-section__title" style="margin-bottom:0; border-bottom:none; padding-bottom:0">
              Gestion des utilisateurs
            </h2>
            <button @click="showCreateUser = !showCreateUser" class="btn btn-primary btn-sm">
              {{ showCreateUser ? 'Annuler' : '+ Créer un utilisateur' }}
            </button>
          </div>
          <div class="account-section__sep"></div>

          <!-- Formulaire de création -->
          <div v-if="showCreateUser" class="admin-form-box">
            <h3 class="admin-form-box__title">Nouveau compte</h3>
            <div v-if="createUserMessage.text" :class="['alert', `alert-${createUserMessage.type}`]">
              {{ createUserMessage.text }}
            </div>
            <form @submit.prevent="createUser" class="account-form">
              <div class="form-row">
                <div class="form-group">
                  <label>Prénom *</label>
                  <input v-model="createUserForm.name" type="text" required />
                </div>
                <div class="form-group">
                  <label>Nom *</label>
                  <input v-model="createUserForm.surname" type="text" required />
                </div>
              </div>
              <div class="form-group">
                <label>Adresse e-mail *</label>
                <input v-model="createUserForm.email" type="email" required />
              </div>
              <div class="form-group">
                <label>Téléphone</label>
                <input v-model="createUserForm.phone" type="tel" placeholder="06 00 00 00 00" />
              </div>
              <div class="form-group">
                <label>Mot de passe *</label>
                <input v-model="createUserForm.password" type="password" placeholder="Min. 5 car., 1 majuscule, 1 chiffre, 1 caractère spécial" required />
              </div>
              <div class="form-group">
                <label>Rôle</label>
                <select v-model="createUserForm.role_id">
                  <option :value="1">Utilisateur</option>
                  <option :value="2">Admin</option>
                </select>
              </div>
              <button type="submit" class="btn btn-primary" :disabled="createUserLoading">
                {{ createUserLoading ? 'Création…' : 'Créer le compte' }}
              </button>
            </form>
          </div>

          <!-- Tableau des utilisateurs -->
          <div v-if="usersLoading" class="account-empty">Chargement des utilisateurs…</div>
          <div v-else-if="usersError" class="alert alert-error">{{ usersError }}</div>
          <p v-else-if="users.length === 0" class="account-empty">Aucun utilisateur trouvé.</p>
          <div v-else class="admin-table-wrap">
            <table class="admin-table">
              <thead>
                <tr>
                  <th>Prénom</th>
                  <th>Nom</th>
                  <th>Email</th>
                  <th>Rôle</th>
                  <th>Statut</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="u in users" :key="u.id">
                  <td>{{ u.name }}</td>
                  <td>{{ u.surname }}</td>
                  <td>{{ u.email }}</td>
                  <td>
                    <span :class="['role-badge', u.role_id === 2 ? 'role-badge--admin' : 'role-badge--user']">
                      {{ u.role_id === 2 ? 'Admin' : 'Utilisateur' }}
                    </span>
                  </td>
                  <td>
                    <span :class="['status-badge', u.is_active ? 'status-badge--active' : 'status-badge--inactive']">
                      {{ u.is_active ? 'Actif' : 'Inactif' }}
                    </span>
                  </td>
                  <td class="actions-cell">
                    <button @click="openEditUser(u)" class="btn btn-sm btn-outline">Modifier</button>
                    <button
                      v-if="u.is_active && u.id !== user.id"
                      @click="deactivateUser(u.id)"
                      class="btn btn-sm btn-warning"
                    >Désactiver</button>
                    <button
                      v-if="!u.is_active"
                      @click="reactivateUser(u.id)"
                      class="btn btn-sm btn-success"
                    >Réactiver</button>
                    <button
                      v-if="u.id !== user.id"
                      @click="confirmDeleteUser(u)"
                      class="btn btn-sm btn-danger"
                    >Supprimer</button>
                    <span v-if="u.id === user.id" class="self-note">Votre compte</span>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </div>

      <!-- ===================== ONGLET 3 : INFORMATIONS ARTICLES ===================== -->
      <div v-show="activeTab === 'articles'" class="container account-layout">
        <section class="account-section">
          <h2 class="account-section__title">Informations Articles</h2>
          <p class="account-section__desc">
            Modifiez le contenu des articles sur la santé mentale. La création et la suppression d'articles se font directement en base de données.
          </p>

          <div v-if="articlesLoading" class="account-empty">Chargement des articles…</div>
          <div v-else-if="articlesError" class="alert alert-error">{{ articlesError }}</div>
          <p v-else-if="articles.length === 0" class="account-empty">Aucun article trouvé.</p>
          <div v-else class="admin-table-wrap">
            <table class="admin-table">
              <thead>
                <tr>
                  <th>Titre</th>
                  <th>Cat��gorie</th>
                  <th>Date de publication</th>
                  <th>Statut</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="a in articles" :key="a.id">
                  <td>{{ a.title }}</td>
                  <td>{{ a.category?.name ?? '—' }}</td>
                  <td>{{ a.publish_date ?? '—' }}</td>
                  <td>
                    <span :class="['status-badge', a.active ? 'status-badge--active' : 'status-badge--inactive']">
                      {{ a.active ? 'Actif' : 'Inactif' }}
                    </span>
                  </td>
                  <td class="actions-cell">
                    <button @click="openEditArticle(a)" class="btn btn-sm btn-outline">Modifier</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </div>

      <!-- ===================== ONGLET 4 : ACTIVITÉS DE DÉTENTE ===================== -->
      <div v-show="activeTab === 'activities'" class="container account-layout">
        <section class="account-section">
          <div class="admin-section-header">
            <h2 class="account-section__title" style="margin-bottom:0; border-bottom:none; padding-bottom:0">
              Activités de détente
            </h2>
            <button @click="showCreateActivity = !showCreateActivity" class="btn btn-primary btn-sm">
              {{ showCreateActivity ? 'Annuler' : '+ Créer une activité' }}
            </button>
          </div>
          <div class="account-section__sep"></div>

          <!-- Formulaire de création -->
          <div v-if="showCreateActivity" class="admin-form-box">
            <h3 class="admin-form-box__title">Nouvelle activité</h3>
            <div v-if="createActivityMessage.text" :class="['alert', `alert-${createActivityMessage.type}`]">
              {{ createActivityMessage.text }}
            </div>
            <form @submit.prevent="createActivity" class="account-form">
              <div class="form-group">
                <label>Titre *</label>
                <input v-model="createActivityForm.title" type="text" required />
              </div>
              <div class="form-group">
                <label>Description</label>
                <textarea v-model="createActivityForm.description" rows="3" placeholder="Courte description…"></textarea>
              </div>
              <div class="form-group">
                <label>URL (YouTube, audio, PDF…)</label>
                <input v-model="createActivityForm.url" type="text" placeholder="https://… ou /static/pdf/fichier.pdf" />
                <span class="form-hint">Adresse web (https://…) ou chemin statique avec extension (/static/pdf/fichier.pdf)</span>
              </div>
              <div class="form-group">
                <label>Durée</label>
                <input v-model="createActivityForm.duration" type="text" placeholder="ex : 15 min" />
              </div>
              <div class="form-row">
                <div class="form-group">
                  <label>Catégorie *</label>
                  <select v-model="createActivityForm.category_id" required>
                    <option value="" disabled>Choisir…</option>
                    <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
                  </select>
                </div>
                <div class="form-group">
                  <label>Format *</label>
                  <select v-model="createActivityForm.format_id" required>
                    <option value="" disabled>Choisir…</option>
                    <option v-for="fmt in formats" :key="fmt.id" :value="fmt.id">{{ fmt.type }}</option>
                  </select>
                </div>
              </div>
              <button type="submit" class="btn btn-primary" :disabled="createActivityLoading">
                {{ createActivityLoading ? 'Création…' : "Créer l'activité" }}
              </button>
            </form>
          </div>

          <!-- Tableau des activités -->
          <div v-if="activitiesLoading" class="account-empty">Chargement des activités…</div>
          <div v-else-if="activitiesError" class="alert alert-error">{{ activitiesError }}</div>
          <p v-else-if="activities.length === 0" class="account-empty">Aucune activité trouvée.</p>
          <div v-else class="admin-table-wrap">
            <table class="admin-table">
              <thead>
                <tr>
                  <th>Titre</th>
                  <th>Catégorie</th>
                  <th>Format</th>
                  <th>Durée</th>
                  <th>Statut</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="a in activities" :key="a.id">
                  <td>{{ a.title }}</td>
                  <td>{{ a.category?.name ?? '—' }}</td>
                  <td>{{ a.format?.type ?? '—' }}</td>
                  <td>{{ a.duration ?? '—' }}</td>
                  <td>
                    <span :class="['status-badge', a.active ? 'status-badge--active' : 'status-badge--inactive']">
                      {{ a.active ? 'Active' : 'Inactive' }}
                    </span>
                  </td>
                  <td class="actions-cell">
                    <button @click="openEditActivity(a)" class="btn btn-sm btn-outline">Modifier</button>
                    <button
                      v-if="a.active"
                      @click="deactivateActivity(a.id)"
                      class="btn btn-sm btn-warning"
                    >Désactiver</button>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </section>
      </div>

    </div>

    <!-- ===================== MODALE CONFIRMATION ===================== -->
    <teleport to="body">
      <div v-if="modal.visible" class="modal-overlay" @click.self="modal.visible = false">
        <div class="modal" role="dialog" aria-modal="true">
          <h3 class="modal__title">{{ modal.title }}</h3>
          <p class="modal__body">{{ modal.message }}</p>
          <div class="modal__actions">
            <button @click="modal.visible = false" class="btn btn-outline">Annuler</button>
            <button
              @click="executeAction"
              class="btn"
              :class="['delete', 'delete-user'].includes(modal.action) ? 'btn-danger' : 'btn-warning'"
            >Confirmer</button>
          </div>
        </div>
      </div>
    </teleport>

    <!-- ===================== MODALE ÉDITION ===================== -->
    <teleport to="body">
      <div v-if="editModal.visible" class="modal-overlay" @click.self="closeEditModal">
        <div class="modal modal--wide" role="dialog" aria-modal="true">
          <h3 class="modal__title">
            {{ editModal.type === 'user' ? "Modifier l'utilisateur" : editModal.type === 'article' ? "Modifier l'article" : "Modifier l'activité" }}
          </h3>
          <div v-if="editModal.message.text" :class="['alert', `alert-${editModal.message.type}`]" style="margin-bottom:1rem">
            {{ editModal.message.text }}
          </div>

          <!-- Formulaire utilisateur -->
          <form v-if="editModal.type === 'user'" @submit.prevent="saveEdit" class="account-form">
            <div class="form-row">
              <div class="form-group">
                <label>Prénom</label>
                <input v-model="editModal.form.name" type="text" />
              </div>
              <div class="form-group">
                <label>Nom</label>
                <input v-model="editModal.form.surname" type="text" />
              </div>
            </div>
            <div class="form-group">
              <label>Email</label>
              <input v-model="editModal.form.email" type="email" />
            </div>
            <div class="form-group">
              <label>Téléphone</label>
              <input v-model="editModal.form.phone" type="tel" />
            </div>
            <div class="form-group">
              <label>Description</label>
              <textarea v-model="editModal.form.description" rows="2"></textarea>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label>Rôle</label>
                <select v-model="editModal.form.role_id">
                  <option :value="1">Utilisateur</option>
                  <option :value="2">Admin</option>
                </select>
              </div>
              <div class="form-group">
                <label>Statut du compte</label>
                <select v-model="editModal.form.is_active">
                  <option :value="true">Actif</option>
                  <option :value="false">Inactif</option>
                </select>
              </div>
            </div>
            <div class="modal__actions">
              <button type="button" @click="closeEditModal" class="btn btn-outline">Annuler</button>
              <button type="submit" class="btn btn-primary" :disabled="editModal.loading">
                {{ editModal.loading ? 'Enregistrement…' : 'Enregistrer' }}
              </button>
            </div>
          </form>

          <!-- Formulaire article -->
          <form v-else-if="editModal.type === 'article'" @submit.prevent="saveEdit" class="account-form">
            <div class="form-group">
              <label>Titre</label>
              <input v-model="editModal.form.title" type="text" />
            </div>
            <div class="form-group">
              <label>Description courte</label>
              <textarea v-model="editModal.form.description" rows="2" placeholder="Accroche affichée dans les listes…"></textarea>
            </div>
            <div class="form-group">
              <label>Contenu (HTML accepté)</label>
              <textarea v-model="editModal.form.content" rows="10" placeholder="Contenu complet de l'article…"></textarea>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label>Date de publication</label>
                <input v-model="editModal.form.publish_date" type="date" />
              </div>
              <div class="form-group">
                <label>Catégorie</label>
                <select v-model="editModal.form.category_id">
                  <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
                </select>
              </div>
            </div>
            <div class="form-group">
              <label>Statut</label>
              <select v-model="editModal.form.active">
                <option :value="true">Actif</option>
                <option :value="false">Inactif</option>
              </select>
            </div>
            <div class="modal__actions">
              <button type="button" @click="closeEditModal" class="btn btn-outline">Annuler</button>
              <button type="submit" class="btn btn-primary" :disabled="editModal.loading">
                {{ editModal.loading ? 'Enregistrement…' : 'Enregistrer' }}
              </button>
            </div>
          </form>

          <!-- Formulaire activité -->
          <form v-else-if="editModal.type === 'activity'" @submit.prevent="saveEdit" class="account-form">
            <div class="form-group">
              <label>Titre</label>
              <input v-model="editModal.form.title" type="text" />
            </div>
            <div class="form-group">
              <label>Description</label>
              <textarea v-model="editModal.form.description" rows="3"></textarea>
            </div>
            <div class="form-group">
              <label>URL (YouTube, audio, PDF…)</label>
              <input v-model="editModal.form.url" type="text" placeholder="https://… ou /static/pdf/fichier.pdf" />
              <span class="form-hint">Adresse web (https://…) ou chemin statique avec extension (/static/pdf/fichier.pdf)</span>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label>Durée</label>
                <input v-model="editModal.form.duration" type="text" placeholder="ex : 15 min" />
              </div>
              <div class="form-group">
                <label>Catégorie</label>
                <select v-model="editModal.form.category_id">
                  <option v-for="cat in categories" :key="cat.id" :value="cat.id">{{ cat.name }}</option>
                </select>
              </div>
            </div>
            <div class="form-row">
              <div class="form-group">
                <label>Format</label>
                <select v-model="editModal.form.format_id">
                  <option v-for="fmt in formats" :key="fmt.id" :value="fmt.id">{{ fmt.type }}</option>
                </select>
              </div>
              <div class="form-group">
                <label>Statut</label>
                <select v-model="editModal.form.active">
                  <option :value="true">Active</option>
                  <option :value="false">Inactive</option>
                </select>
              </div>
            </div>
            <div class="modal__actions">
              <button type="button" @click="closeEditModal" class="btn btn-outline">Annuler</button>
              <button type="submit" class="btn btn-primary" :disabled="editModal.loading">
                {{ editModal.loading ? 'Enregistrement…' : 'Enregistrer' }}
              </button>
            </div>
          </form>

        </div>
      </div>
    </teleport>

  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

// ── Données utilisateur ──────────────────────────────────────
const user    = ref(null)
const loading = ref(true)
const error   = ref(null)

// ── Onglets ──────────────────────────────────────────────────
const activeTab = ref('account')

function switchTab(tab) {
  activeTab.value = tab
}

// ── Formulaire profil ────────────────────────────────────────
const profileForm      = reactive({ name: '', surname: '', email: '', phone: '', description: '', password: '', passwordConfirm: '' })
const passwordMismatch = computed(() => profileForm.password && profileForm.passwordConfirm && profileForm.password !== profileForm.passwordConfirm)
const profileLoading   = ref(false)
const profileMessage   = reactive({ text: '', type: 'success' })

// ── Favoris ──────────────────────────────────────────────────
const favorites   = ref([])
const favSearch   = ref('')
const favCategory = ref('')
const favFormat   = ref('')

// ── Modale confirmation (RGPD + suppression utilisateur) ─────
const modal = reactive({ visible: false, action: '', title: '', message: '', targetId: null })

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
      fetch('/api/users/me/favorites', { headers: authHeaders() }),
    ])
    if (!userRes.ok) throw new Error('Impossible de charger le profil.')
    user.value = await userRes.json()
    profileForm.name        = user.value.name
    profileForm.surname     = user.value.surname
    profileForm.email       = user.value.email
    profileForm.phone       = user.value.phone ?? ''
    profileForm.description = user.value.description ?? ''

    if (favRes.ok) favorites.value = await favRes.json()

    if (user.value.role_id === 2) {
      loadCategoriesAndFormats()
    }
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
    profileLoading.value = false
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
    const res  = await fetch(`/api/users/${userId}`, { method: 'PUT', headers: authHeaders(), body: JSON.stringify(payload) })
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

// ── Favoris : filtres & helpers ──────────────────────────────
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
  modal.action   = action
  modal.targetId = null
  modal.visible  = true
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
    if (modal.action === 'delete-user') {
      await fetch(`/api/users/${modal.targetId}`, { method: 'DELETE', headers: authHeaders() })
      users.value = users.value.filter(u => u.id !== modal.targetId)
      return
    }
    if (modal.action === 'deactivate') {
      await fetch(`/api/users/deactivate/${userId}`, { method: 'PUT', headers: authHeaders() })
    } else if (modal.action === 'delete') {
      await fetch(`/api/users/${userId}`, { method: 'DELETE', headers: authHeaders() })
    }
    localStorage.removeItem('token')
    router.push('/')
  } catch {
    error.value = 'Une erreur est survenue.'
  }
}

// ── ADMIN : Catégories & Formats ─────────────────────────────
const categories = ref([])
const formats    = ref([])

async function loadCategoriesAndFormats() {
  const [catRes, fmtRes] = await Promise.all([
    fetch('/api/categories/', { headers: authHeaders() }),
    fetch('/api/categories/formats', { headers: authHeaders() }),
  ])
  if (catRes.ok) categories.value = await catRes.json()
  if (fmtRes.ok) formats.value    = await fmtRes.json()
}

// ── ADMIN : Utilisateurs ─────────────────────────────────────
const users        = ref([])
const usersLoading = ref(false)
const usersError   = ref(null)
const usersLoaded  = ref(false)

const showCreateUser    = ref(false)
const createUserForm    = reactive({ name: '', surname: '', email: '', phone: '', password: '', role_id: 1 })
const createUserMessage = reactive({ text: '', type: 'success' })
const createUserLoading = ref(false)

async function loadUsers() {
  usersLoading.value = true
  usersError.value   = null
  try {
    const res = await fetch('/api/users/', { headers: authHeaders() })
    if (!res.ok) throw new Error('Impossible de charger les utilisateurs.')
    users.value   = await res.json()
    usersLoaded.value = true
  } catch (e) {
    usersError.value = e.message
  } finally {
    usersLoading.value = false
  }
}

async function createUser() {
  createUserLoading.value = true
  createUserMessage.text  = ''
  try {
    const res  = await fetch('/api/users/create', {
      method:  'POST',
      headers: authHeaders(),
      body:    JSON.stringify({
        name:     createUserForm.name,
        surname:  createUserForm.surname,
        email:    createUserForm.email,
        phone:    createUserForm.phone || null,
        password: createUserForm.password,
        role_id:  createUserForm.role_id,
      }),
    })
    const data = await res.json()
    if (res.ok) {
      createUserMessage.text = 'Utilisateur créé avec succès !'
      createUserMessage.type = 'success'
      Object.assign(createUserForm, { name: '', surname: '', email: '', phone: '', password: '', role_id: 1 })
      await loadUsers()
    } else if (res.status === 409) {
      createUserMessage.text = 'Un compte existe déjà avec cette adresse e-mail.'
      createUserMessage.type = 'error'
    } else {
      const detail = data.detail
      createUserMessage.text = Array.isArray(detail) ? detail.map(e => e.msg).join(' — ') : (detail || 'Erreur.')
      createUserMessage.type = 'error'
    }
  } catch {
    createUserMessage.text = 'Impossible de contacter le serveur.'
    createUserMessage.type = 'error'
  } finally {
    createUserLoading.value = false
  }
}

async function deactivateUser(userId) {
  await fetch(`/api/users/deactivate/${userId}`, { method: 'PUT', headers: authHeaders() })
  const u = users.value.find(u => u.id === userId)
  if (u) u.is_active = false
}

async function reactivateUser(userId) {
  await fetch(`/api/users/${userId}`, { method: 'PUT', headers: authHeaders(), body: JSON.stringify({ is_active: true }) })
  const u = users.value.find(u => u.id === userId)
  if (u) u.is_active = true
}

function confirmDeleteUser(u) {
  modal.action   = 'delete-user'
  modal.targetId = u.id
  modal.title    = `Supprimer ${u.name} ${u.surname}`
  modal.message  = `Cette action est irréversible. Le compte de ${u.name} ${u.surname} sera définitivement supprimé. Êtes-vous sûr ?`
  modal.visible  = true
}

// ── ADMIN : Articles ─────────────────────────────────────────
const articles        = ref([])
const articlesLoading = ref(false)
const articlesError   = ref(null)
const articlesLoaded  = ref(false)

async function loadArticles() {
  articlesLoading.value = true
  articlesError.value   = null
  try {
    const res = await fetch('/api/articles/', { headers: authHeaders() })
    if (!res.ok) throw new Error('Impossible de charger les articles.')
    articles.value   = await res.json()
    articlesLoaded.value = true
  } catch (e) {
    articlesError.value = e.message
  } finally {
    articlesLoading.value = false
  }
}

// ── ADMIN : Activités ─────────────────────────────────────────
const activities        = ref([])
const activitiesLoading = ref(false)
const activitiesError   = ref(null)
const activitiesLoaded  = ref(false)

const showCreateActivity    = ref(false)
const createActivityForm    = reactive({ title: '', description: '', url: '', duration: '', category_id: '', format_id: '' })
const createActivityMessage = reactive({ text: '', type: 'success' })
const createActivityLoading = ref(false)

async function loadActivities() {
  activitiesLoading.value = true
  activitiesError.value   = null
  try {
    const res = await fetch('/api/activities/admin/all', { headers: authHeaders() })
    if (!res.ok) throw new Error('Impossible de charger les activités.')
    activities.value   = await res.json()
    activitiesLoaded.value = true
  } catch (e) {
    activitiesError.value = e.message
  } finally {
    activitiesLoading.value = false
  }
}

async function createActivity() {
  createActivityLoading.value = true
  createActivityMessage.text  = ''
  try {
    const res  = await fetch('/api/activities/create', {
      method:  'POST',
      headers: authHeaders(),
      body:    JSON.stringify({
        title:       createActivityForm.title,
        description: createActivityForm.description || null,
        url:         createActivityForm.url || null,
        duration:    createActivityForm.duration || null,
        category_id: Number(createActivityForm.category_id),
        format_id:   Number(createActivityForm.format_id),
        active:      true,
      }),
    })
    const data = await res.json()
    if (res.ok) {
      createActivityMessage.text = 'Activité créée avec succès !'
      createActivityMessage.type = 'success'
      Object.assign(createActivityForm, { title: '', description: '', url: '', duration: '', category_id: '', format_id: '' })
      await loadActivities()
    } else {
      const detail = data.detail
      createActivityMessage.text = Array.isArray(detail) ? detail.map(e => e.msg).join(' — ') : (detail || 'Erreur.')
      createActivityMessage.type = 'error'
    }
  } catch {
    createActivityMessage.text = 'Impossible de contacter le serveur.'
    createActivityMessage.type = 'error'
  } finally {
    createActivityLoading.value = false
  }
}

async function deactivateActivity(activityId) {
  await fetch(`/api/activities/deactivate/${activityId}`, { method: 'PUT', headers: authHeaders() })
  const a = activities.value.find(a => a.id === activityId)
  if (a) a.active = false
}

// ── ADMIN : Modale d'édition ──────────────────────────────────
const editModal = reactive({
  visible: false,
  type:    '',
  id:      null,
  form:    {},
  loading: false,
  message: { text: '', type: 'success' },
})

function openEditUser(u) {
  editModal.type    = 'user'
  editModal.id      = u.id
  editModal.form    = { name: u.name, surname: u.surname, email: u.email, phone: u.phone ?? '', description: u.description ?? '', role_id: u.role_id, is_active: u.is_active }
  editModal.message = { text: '', type: 'success' }
  editModal.visible = true
}

function openEditArticle(a) {
  editModal.type    = 'article'
  editModal.id      = a.id
  editModal.form    = { title: a.title, description: a.description ?? '', content: a.content ?? '', publish_date: a.publish_date ?? '', active: a.active, category_id: a.category_id }
  editModal.message = { text: '', type: 'success' }
  editModal.visible = true
}

function openEditActivity(a) {
  editModal.type    = 'activity'
  editModal.id      = a.id
  editModal.form    = { title: a.title, description: a.description ?? '', url: a.url ?? '', duration: a.duration ?? '', active: a.active, category_id: a.category_id, format_id: a.format_id }
  editModal.message = { text: '', type: 'success' }
  editModal.visible = true
}

function closeEditModal() {
  editModal.visible = false
}

async function saveEdit() {
  editModal.loading      = true
  editModal.message.text = ''

  try {
    let url, payload

    if (editModal.type === 'user') {
      url     = `/api/users/${editModal.id}`
      payload = {
        name:        editModal.form.name,
        surname:     editModal.form.surname,
        email:       editModal.form.email,
        phone:       editModal.form.phone || null,
        description: editModal.form.description || null,
        role_id:     editModal.form.role_id,
        is_active:   editModal.form.is_active,
      }
    } else if (editModal.type === 'article') {
      url     = `/api/articles/${editModal.id}`
      payload = {
        title:        editModal.form.title,
        description:  editModal.form.description || null,
        content:      editModal.form.content || null,
        publish_date: editModal.form.publish_date || null,
        active:       editModal.form.active,
        category_id:  editModal.form.category_id,
      }
    } else {
      url     = `/api/activities/${editModal.id}`
      payload = {
        title:       editModal.form.title,
        description: editModal.form.description || null,
        url:         editModal.form.url || null,
        duration:    editModal.form.duration || null,
        active:      editModal.form.active,
        category_id: editModal.form.category_id,
        format_id:   editModal.form.format_id,
      }
    }

    const res  = await fetch(url, { method: 'PUT', headers: authHeaders(), body: JSON.stringify(payload) })
    const data = await res.json()

    if (res.ok) {
      editModal.message.text = 'Modifications enregistrées !'
      editModal.message.type = 'success'
      // Mise à jour de la liste locale
      if (editModal.type === 'user') {
        const idx = users.value.findIndex(u => u.id === editModal.id)
        if (idx !== -1) Object.assign(users.value[idx], data.user ?? editModal.form)
      } else if (editModal.type === 'article') {
        const idx = articles.value.findIndex(a => a.id === editModal.id)
        if (idx !== -1) Object.assign(articles.value[idx], data.article ?? editModal.form)
      } else {
        const idx = activities.value.findIndex(a => a.id === editModal.id)
        if (idx !== -1) Object.assign(activities.value[idx], data.activity ?? editModal.form)
      }
      setTimeout(() => { editModal.visible = false }, 800)
    } else {
      const detail = data.detail
      editModal.message.text = Array.isArray(detail) ? detail.map(e => e.msg).join(' — ') : (detail || 'Erreur.')
      editModal.message.type = 'error'
    }
  } catch {
    editModal.message.text = 'Impossible de contacter le serveur.'
    editModal.message.type = 'error'
  } finally {
    editModal.loading = false
  }
}

// ── Export logs ───────────────────────────────────────────────
async function exportLogs() {
  const res = await fetch('/api/logs/export', { headers: authHeaders() })
  if (!res.ok) return
  const text = await res.text()
  const blob = new Blob([text], { type: 'text/plain' })
  const url  = URL.createObjectURL(blob)
  const a    = document.createElement('a')
  a.href     = url
  a.download = `logs-admin-${new Date().toISOString().slice(0, 10)}.txt`
  a.click()
  URL.revokeObjectURL(url)
}

// ── Chargement paresseux des onglets admin ────────────────────
watch(activeTab, (tab) => {
  if (tab === 'users'      && !usersLoaded.value)      loadUsers()
  if (tab === 'articles'   && !articlesLoaded.value)   loadArticles()
  if (tab === 'activities' && !activitiesLoaded.value) loadActivities()
})
</script>

<style scoped>
/* ── Hero ────────────────────────────────────────────────── */
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
.account-hero__avatar img { width: 100%; height: 100%; object-fit: cover; }

/* ── Tabs ────────────────────────────────────────────────── */
.tabs-nav {
  background: var(--color-surface);
  border-bottom: 2px solid var(--color-border);
  position: sticky;
  top: 0;
  z-index: 10;
}
.tabs-nav__inner {
  display: flex;
  gap: 0;
  overflow-x: auto;
  scrollbar-width: none;
}
.tabs-nav__inner::-webkit-scrollbar {
  display: none;
}
.tab-btn {
  padding: 1rem 1.5rem;
  background: none;
  border: none;
  border-bottom: 3px solid transparent;
  margin-bottom: -2px;
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-text-muted);
  cursor: pointer;
  white-space: nowrap;
  transition: color 0.15s, border-color 0.15s;
}
.tab-btn:hover { color: var(--color-primary); }
.tab-btn--active {
  color: var(--color-primary-dark);
  border-bottom-color: var(--color-primary);
}

/* ── Layout ──────────────────────────────────────────────── */
.account-state { padding: 3rem 1.5rem; color: var(--color-text-muted); }
.account-state--error { color: #991b1b; }

.account-layout {
  display: flex;
  flex-direction: column;
  gap: 2rem;
  padding: 2rem 1.5rem 4rem;
  max-width: 960px;
  margin: 0 auto;
}

/* ── Section ─────────────────────────────────────────────── */
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
.account-section__sep {
  border-top: 1px solid var(--color-border);
  margin: 1.25rem 0;
}
.account-section__desc {
  font-size: 0.9rem;
  color: var(--color-text-muted);
  margin-bottom: 1.25rem;
  line-height: 1.6;
}

/* ── Formulaire profil ───────────────────────────────────── */
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
.form-group input,
.form-group select {
  padding: 0.5rem 0.75rem;
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  font-size: 0.9rem;
  color: var(--color-text);
  background: var(--color-background);
  transition: border-color var(--transition);
}
.form-group input:focus,
.form-group select:focus,
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
.form-hint  { font-size: 0.78rem; color: var(--color-text-muted); margin-top: 0.2rem; font-style: italic; }

/* ── Filtres favoris ─────────────────────────────────────── */
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

/* ── Grille favoris ──────────────────────────────────────── */
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
.fav-card__img { width: 72px; height: 52px; object-fit: cover; border-radius: calc(var(--border-radius) - 2px); flex-shrink: 0; }
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

/* ── Boutons utilitaires ─────────────────────────────────── */
.btn-sm { padding: 0.35rem 0.85rem; font-size: 0.8rem; }
.btn-warning { background-color: #f59e0b; color: #ffffff; border: none; cursor: pointer; border-radius: var(--border-radius); }
.btn-warning:hover { background-color: #d97706; }
.btn-danger  { background-color: #ef4444; color: #ffffff; border: none; cursor: pointer; border-radius: var(--border-radius); }
.btn-danger:hover  { background-color: #dc2626; }
.btn-success { background-color: #22c55e; color: #ffffff; border: none; cursor: pointer; border-radius: var(--border-radius); }
.btn-success:hover { background-color: #16a34a; }
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

/* ── RGPD ────────────────────────────────────────────────── */
.rgpd-actions { display: flex; gap: 1rem; flex-wrap: wrap; }

/* ── Barre d'actions admin ───────────────────────────────── */
.admin-actions-bar {
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  padding: 0.6rem 0;
}
.admin-actions-bar .container { display: flex; justify-content: flex-end; }

/* ── Admin : en-tête de section ─────────────────────────── */
.admin-section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
}

/* ── Admin : formulaire de création ─────────────────────── */
.admin-form-box {
  background: var(--color-background);
  border: 1px solid var(--color-border);
  border-radius: var(--border-radius);
  padding: 1.25rem 1.5rem;
  margin-bottom: 1.5rem;
}
.admin-form-box__title {
  font-size: 1rem;
  font-weight: 700;
  color: var(--color-primary-dark);
  margin-bottom: 1rem;
}

/* ── Admin : tableau ─────────────────────────────────────── */
.admin-table-wrap { overflow-x: auto; }
.admin-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.875rem;
}
.admin-table th {
  text-align: left;
  padding: 0.6rem 0.75rem;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--color-text-muted);
  border-bottom: 2px solid var(--color-border);
  white-space: nowrap;
}
.admin-table td {
  padding: 0.65rem 0.75rem;
  border-bottom: 1px solid var(--color-border);
  vertical-align: middle;
}
.admin-table tbody tr:last-child td { border-bottom: none; }
.admin-table tbody tr:hover { background: var(--color-background); }

.actions-cell { display: flex; gap: 0.4rem; align-items: center; flex-wrap: wrap; }
.self-note { font-size: 0.75rem; color: var(--color-text-muted); font-style: italic; }

/* ── Badges rôle & statut ────────────────────────────────── */
.role-badge,
.status-badge {
  display: inline-block;
  padding: 0.15rem 0.55rem;
  border-radius: 999px;
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}
.role-badge--admin    { background: #dbeafe; color: #1d4ed8; }
.role-badge--user     { background: var(--color-surface-teal); color: var(--color-primary-dark); }
.status-badge--active   { background: #dcfce7; color: #166534; }
.status-badge--inactive { background: #fee2e2; color: #991b1b; }

/* ── Modale ──────────────────────────────────────────────── */
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
  max-height: 90vh;
  overflow-y: auto;
}
.modal--wide { max-width: 680px; }
.modal__title { font-size: 1.1rem; font-weight: 700; color: var(--color-text); margin-bottom: 0.75rem; }
.modal__body  { font-size: 0.9rem; color: var(--color-text-muted); line-height: 1.6; margin-bottom: 1.5rem; }
.modal__actions { display: flex; gap: 0.75rem; justify-content: flex-end; margin-top: 1.25rem; }

@media (max-width: 640px) {
  .form-row { grid-template-columns: 1fr; }
  .account-section { padding: 1.25rem; }
  .rgpd-actions { flex-direction: column; }
  .tab-btn { padding: 0.75rem 1rem; font-size: 0.82rem; }
  .admin-section-header { flex-direction: column; align-items: flex-start; }
}
</style>
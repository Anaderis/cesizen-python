# Conventions de contribution

## Convention de nommage des branches

```
{id-issue}-nom-court-de-la-feature
```

Exemples :
- `57-test-docker-maj-ci`
- `42-ajout-authentification-jwt`
- `15-correction-bug-favoris`

Flux de merge :
```
{id}-feature  →  dev  →  stage  →  main
```

---

## Convention de messages de commit

Format obligatoire (Conventional Commits) :

```
<type>(<portée>): <description courte>
```

- `type` : nature de la modification (voir liste ci-dessous)
- `portée` : module ou fichier concerné (optionnel)
- `description` : phrase courte, au présent, sans majuscule, sans point final

> Le format sans espace avant `:` est requis pour que semantic-release génère automatiquement les versions et le CHANGELOG.

### Types autorisés

| Type | Usage |
|---|---|
| `feat` | Ajout d'une nouvelle fonctionnalité |
| `fix` | Correction d'un bug |
| `docs` | Modification de la documentation uniquement |
| `style` | Mise en forme, indentation (sans impact fonctionnel) |
| `refactor` | Restructuration du code sans changement de comportement |
| `test` | Ajout ou modification de tests |
| `chore` | Tâches techniques (dépendances, configuration, CI) |

### Exemples corrects

```
feat(auth): ajouter la connexion par token JWT
fix(docker): corriger la variable DATABASE_URL dans le compose dev
docs: mettre à jour le CHANGELOG pour la v1.1.0
chore(ci): ajouter le workflow de publication Docker
test(users): ajouter les tests de création de compte
```

### Exemples incorrects

```
Fix: correction bug          ← majuscule sur le type
fix: Correction bug          ← majuscule sur la description
fix : correction bug         ← espace avant le ":" — non reconnu par semantic-release
mise à jour docker           ← pas de type
update stuff                 ← trop vague
```

---

## Mise à jour du CHANGELOG

À chaque merge sur `main`, mettre à jour [CHANGELOG.md](CHANGELOG.md) :

1. Créer une nouvelle entrée `## [vX.Y.Z] — YYYY-MM-DD`
2. Lister les modifications sous les sections `Ajouts`, `Corrections`, `Maintenance`
3. Utiliser le même format que les messages de commit

---

## Création d'un tag de version

Après chaque merge sur `main` :

```bash
git tag v1.2.0
git push origin v1.2.0
```

Puis créer une Release GitHub associée au tag avec un résumé des changements.
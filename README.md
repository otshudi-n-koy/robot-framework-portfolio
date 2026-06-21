# Robot Framework Portfolio

Projet de démonstration Robot Framework couvrant l'automatisation **UI** et **API**, avec intégration **CI/CD** sur GitHub Actions.

L'objectif principal est de comparer concrètement deux approches d'automatisation UI en Robot Framework : la bibliothèque historique **SeleniumLibrary** et la bibliothèque moderne **Browser Library** (basée sur Playwright).

## Structure du projet

```
robot-framework-portfolio/
├── .github/workflows/ci.yml        # Pipeline CI : 3 jobs en parallèle
├── resources/
│   └── variables.resource          # Variables partagées (URLs, identifiants de test)
├── tests/
│   ├── ui/
│   │   ├── selenium/
│   │   │   └── login_and_cart.robot    # Scénario UI via SeleniumLibrary
│   │   └── browser/
│   │       └── login_and_cart.robot    # Même scénario via Browser Library (Playwright)
│   └── api/
│       └── booking_api.robot           # CRUD + authentification via RequestsLibrary
├── requirements.txt
└── README.md
```

## Comparaison SeleniumLibrary vs Browser Library

Les deux fichiers `login_and_cart.robot` implémentent **exactement le même scénario** (login → vérification de la liste produits → ajout au panier → vérification du badge), ce qui permet de comparer directement la syntaxe et la philosophie des deux bibliothèques.

| Aspect | SeleniumLibrary | Browser Library (Playwright) |
|---|---|---|
| Moteur sous-jacent | Selenium WebDriver | Playwright |
| Attentes | Explicites le plus souvent nécessaires (cf. flakiness rencontrée et corrigée pendant le développement) | Auto-attente intégrée sur la plupart des actions |
| Saisie de texte | `Input Text` | `Fill Text` |
| Clic | `Click Button` / `Click Element` | `Click` |
| Assertions texte | `Element Text Should Be` (égalité stricte) | `Get Text` avec opérateur (`==`, `contains`, etc.) |
| Comptage d'éléments | Nécessite un keyword dédié | `Get Element Count` natif avec opérateur de comparaison |
| Maturité / adoption en mission | Très répandue, nombreuses ressources | Plus récente, en croissance |

## Lancer les tests localement
```
pip install -r requirements.txt
rfbrowser init          # uniquement nécessaire pour les tests Browser Library

robot --outputdir results/api tests/api
robot --outputdir results/ui-selenium tests/ui/selenium
robot --outputdir results/ui-browser tests/ui/browser
```

## CI/CD

Le pipeline `.github/workflows/ci.yml` exécute 3 jobs en parallèle à chaque push/PR sur `main` : tests API, tests UI SeleniumLibrary, tests UI Browser Library. Chaque job publie son rapport HTML en artefact téléchargeable, même en cas d'échec.

## Sites de test utilisés

- **UI** : [saucedemo.com](https://www.saucedemo.com) — site de démo officiel pour la pratique de l'automatisation
- **API** : [restful-booker.herokuapp.com](https://restful-booker.herokuapp.com) — API REST publique conçue pour la pratique des tests automatisés (CRUD + authentification par token)

## Stack technique

Robot Framework · SeleniumLibrary · Browser Library (Playwright) · RequestsLibrary · GitHub Actions
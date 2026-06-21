*** Settings ***
Documentation       Parcours UI sur SauceDemo (login -> ajout panier) avec SeleniumLibrary.
...                 Variante "classique" -- comparer avec tests/ui/browser/login_and_cart.robot
...                 qui implémente exactement le même scénario avec Browser Library (Playwright).

Library             SeleniumLibrary
Resource            ../../../resources/variables.resource

Suite Setup         Open Browser    ${BASE_URL}    headlesschrome
Suite Teardown      Close All Browsers


*** Test Cases ***
Standard User Can Login And Add Item To Cart
    [Documentation]    Vérifie le parcours complet : login -> liste produits -> ajout panier -> badge mis à jour
    Login As                  ${VALID_USER}    ${VALID_PASSWORD}
    Page Should Contain Element    css:.inventory_list
    Add Product To Cart       sauce-labs-backpack
    Cart Badge Should Show    1

Locked Out User Cannot Login
    [Documentation]    Vérifie le message d'erreur affiché pour un utilisateur bloqué.
    ...                Utilise Wait Until Keyword Succeeds pour absorber une éventuelle
    ...                instabilité réseau/environnement sur les runners CI partagés.
    Wait Until Keyword Succeeds    3x    5s    Attempt Locked Out Login


*** Keywords ***
Login As
    [Documentation]    Saisit les identifiants et clique sur le bouton de connexion. Attend que le
    ...                formulaire soit prêt avant d'interagir (évite la flakiness au démarrage du navigateur).
    [Arguments]    ${username}    ${password}
    Wait Until Element Is Visible    id:user-name    timeout=15s
    Press Keys      id:user-name    ${username}
    Press Keys      id:password    ${password}
    Click Button    id:login-button

Add Product To Cart
    [Documentation]    Ajoute un produit au panier via son data-test id
    [Arguments]    ${product_id}
    Click Button    css:[data-test="add-to-cart-${product_id}"]

Cart Badge Should Show
    [Documentation]    Vérifie que le badge du panier affiche le nombre attendu d'articles
    [Arguments]    ${expected_count}
    Element Text Should Be    css:.shopping_cart_badge    ${expected_count}

Attempt Locked Out Login
    [Documentation]    Tente le scénario complet (navigation + login + vérification erreur).
    ...                Encapsulé pour permettre un retry complet via Wait Until Keyword Succeeds.
    Go To    ${BASE_URL}
    Login As    ${LOCKED_USER}    ${VALID_PASSWORD}
    Wait Until Element Is Visible    css:[data-test="error"]    timeout=10s
    Element Should Contain    css:[data-test="error"]    Sorry, this user has been locked out.

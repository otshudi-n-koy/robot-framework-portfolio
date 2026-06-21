*** Settings ***
Documentation       Même parcours UI que tests/ui/selenium/login_and_cart.robot, mais implémenté
...                 avec Browser Library (basée sur Playwright) au lieu de SeleniumLibrary.
...                 Comparer les deux fichiers permet de visualiser les différences de syntaxe
...                 et de philosophie entre les deux approches (attentes auto, sélecteurs, assertions).

Library             Browser
Resource            ../../../resources/variables.resource

Suite Setup         New Browser    chromium    headless=True
Suite Teardown      Close Browser    ALL


*** Test Cases ***
Standard User Can Login And Add Item To Cart
    [Documentation]    Vérifie le parcours complet : login -> liste produits -> ajout panier -> badge mis à jour
    New Page                  ${BASE_URL}
    Login As                  ${VALID_USER}    ${VALID_PASSWORD}
    Get Element Count         .inventory_item    >=    1
    Add Product To Cart       sauce-labs-backpack
    Cart Badge Should Show    1

Locked Out User Cannot Login
    [Documentation]    Vérifie le message d'erreur affiché pour un utilisateur bloqué
    New Page                  ${BASE_URL}
    Login As                  ${LOCKED_USER}    ${VALID_PASSWORD}
    Get Text                  [data-test="error"]    contains    Sorry, this user has been locked out.


*** Keywords ***
Login As
    [Documentation]    Saisit les identifiants et clique sur le bouton de connexion
    [Arguments]    ${username}    ${password}
    Fill Text    id=user-name    ${username}
    Fill Text    id=password     ${password}
    Click        id=login-button

Add Product To Cart
    [Documentation]    Ajoute un produit au panier via son data-test id
    [Arguments]    ${product_id}
    Click    css=[data-test="add-to-cart-${product_id}"]

Cart Badge Should Show
    [Documentation]    Vérifie que le badge du panier affiche le nombre attendu d'articles
    [Arguments]    ${expected_count}
    Get Text    .shopping_cart_badge    ==    ${expected_count}

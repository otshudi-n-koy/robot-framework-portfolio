*** Settings ***
Documentation       Tests API CRUD + authentification avec RequestsLibrary sur l'API publique
...                 Restful-Booker (conçue pour la pratique des tests API automatisés).
...                 Les tests s'exécutent dans l'ordre (création -> lecture -> modification -> suppression),
...                 chaque test alimentant le suivant via des variables de suite (Set Suite Variable).

Library             RequestsLibrary
Library             Collections
Resource            ../../resources/variables.resource

Suite Setup         Create Session    booker    ${API_BASE_URL}


*** Variables ***
${BOOKING_ID}       ${EMPTY}
${AUTH_TOKEN}        ${EMPTY}


*** Test Cases ***
Authenticate And Get Token
    [Documentation]    Vérifie l'obtention d'un token d'authentification valide
    ${credentials}=    Create Dictionary    username=${API_USERNAME}    password=${API_PASSWORD}
    ${response}=        POST On Session    booker    /auth    json=${credentials}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Not Be Empty           ${response.json()}[token]
    Set Suite Variable    ${AUTH_TOKEN}    ${response.json()}[token]

Create A New Booking
    [Documentation]    Vérifie la création d'une réservation et la structure de la réponse
    ${dates}=      Create Dictionary    checkin=2026-07-01    checkout=2026-07-05
    ${payload}=    Create Dictionary
    ...    firstname=Test
    ...    lastname=Automation
    ...    totalprice=150
    ...    depositpaid=${True}
    ...    bookingdates=${dates}
    ...    additionalneeds=Breakfast
    ${response}=    POST On Session    booker    /booking    json=${payload}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Be Equal As Strings    ${response.json()}[booking][firstname]    Test
    Set Suite Variable    ${BOOKING_ID}    ${response.json()}[bookingid]

Get Booking By Id
    [Documentation]    Vérifie que la réservation créée est consultable et conforme
    ${response}=    GET On Session    booker    /booking/${BOOKING_ID}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Be Equal As Strings    ${response.json()}[lastname]    Automation

Update Booking Requires Auth
    [Documentation]    Vérifie la mise à jour d'une réservation existante (nécessite un token)
    ${headers}=    Create Dictionary    Cookie=token=${AUTH_TOKEN}    Content-Type=application/json
    ${new_dates}=    Create Dictionary    checkin=2026-07-01    checkout=2026-07-06
    ${payload}=    Create Dictionary
    ...    firstname=Test
    ...    lastname=Updated
    ...    totalprice=200
    ...    depositpaid=${True}
    ...    bookingdates=${new_dates}
    ...    additionalneeds=Lunch
    ${response}=    PUT On Session    booker    /booking/${BOOKING_ID}    json=${payload}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    200
    Should Be Equal As Strings    ${response.json()}[lastname]    Updated

Delete Booking Requires Auth
    [Documentation]    Vérifie la suppression de la réservation (nécessite un token)
    ${headers}=      Create Dictionary    Cookie=token=${AUTH_TOKEN}
    ${response}=     DELETE On Session    booker    /booking/${BOOKING_ID}    headers=${headers}
    Should Be Equal As Integers    ${response.status_code}    201

Deleted Booking Should No Longer Be Found
    [Documentation]    Vérifie que la réservation supprimée n'est plus accessible (404 attendu)
    ${response}=    GET On Session    booker    /booking/${BOOKING_ID}    expected_status=404
    Should Be Equal As Integers    ${response.status_code}    404

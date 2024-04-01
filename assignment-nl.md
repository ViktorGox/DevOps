# Toetsopdracht DevOps — Best Songs Ever
_april 2024_

In deze toetsopdracht ontwerp en implementeer je een infrastructuur en
ontwikkelomgeving voor een webapplicatie, waarmee gebruikers een
playlist kunnen bekijken en doorzoeken met de beste liedjes ooit gemaakt
(volgens Spotify).

Deze Flutter-webapplicatie maakt verbinding met een backend die is
geschreven in SpringBoot. De informatie over de liedjes in de playlist
wordt opgeslagen in de backend-applicatie. De SpringBoot-applicatie
gebruikt een MariaDB-database om de liedjes op te slaan.

Jouw taak is om deze applicatie uit te voeren en te testen. Bovendien
moet je de pipeline voor continuous integration voor deze applicatie
instellen en de applicatie containeriseren.

### Voorwaardelijke Eisen

-   Het is verplicht om alle *oefenopdrachten* in te leveren en te laten
    aftekenen door je docent, voordat deze eindopdracht kan worden
    ingeleverd. Uiteraard kun je ondertussen alvast wel een beginnetje
    maken met deze examenopdracht.

-   Voor elke requirement (zie hieronder) leg je uit hoe je het probleem
    hebt opgelost en waarom je het op deze manier hebt opgelost. Dit
    beschrijf je in je eigen woorden worden op een manier die te
    begrijpen is voor de docent die je werk beoordeelt. Je kunt het
    opschrijven in een Markdown-bestand in je repository of in
    commentaar in de source code (in het laatste geval verwijs je in het
    Markdown-bestand naar de locaties van deze comments).

-   Zorg ervoor dat je een repository gebruikt in de Saxion Gitlab
    organisatie, gemaakt via
    [https://repo.hboictlab.nl](https://repo.hboictlab.nl/)

-   Upload een gezipte export van je Gitlab-project naar Blackboard
    (Settings → General → Advanced → Export Project).\
    **Vermeld ook de URL van je repository in het opmerkingenveld op
    Blackboard.**

### Toetsregels

-   De deadline voor het inleveren van de opdracht is maandag 15 april
    9:00 (week 3.9).

-   De opdracht wordt gemaakt in groepjes van twee studenten die zich
    hebben aangemeld bij de docent. Groepjes worden gevormd in week 7,
    waarbij groepsleden allebei evenveel oefenopdrachten ingeleverd
    moeten hebben om te mogen samenwerken (maximaal 1 week verschil).

-   Je cijfer wordt bepaald op basis van het assessment dat plaatsvindt
    nadat je je opdracht hebt ingeleverd. Zorg dus dat je alle
    onderdelen die je gemaakt hebt goed begrijpt, er zullen ook
    theoretische vragen worden gesteld over je gemaakte oplossing.

-   Je krijgt alleen punten voor onderdelen van je werk die je tijdens
    het assessment kunt uitleggen. Bijvoorbeeld: als je code werkt, maar
    je kunt niet uitleggen wat het doet of waarom het zo werkt, dan telt
    dat onderdeel van de opdracht niet mee voor je eindcijfer.

-   Het is **niet** toegestaan om hulp te krijgen van iemand buiten je
    toetsgroepje, behalve van je docent. Het is ook **niet** toegestaan
    om hulp te verlenen aan iemand anders.

-   Je mag online posts, artikelen, tutorials, boeken, video\'s
    gebruiken. Je moet wel verwijzingen toevoegen [[1]](https://libguides.murdoch.edu.au/IEEE) voor alle bronnen
    en codefragmenten die je in je tekst/code gebruikt.

## Proces Requirements

Tijdens het uitvoeren van de opdracht moet je een gedegen
softwareontwikkelingsproces volgen, zoals behandeld in week 1. Dit omvat
dingen zoals het bijhouden van taken met behulp van Gitlab Issues, het
gebruik van Git om samen te werken aan de code, en het gebruik van
branches en merge request om code reviews te kunnen doen. Dit zou
allemaal duidelijk moeten blijken uit je Gitlab-repository.

## Functionele Requirements

### 1. Voeg gegevens toe aan de backend

In de repository vind je een map met daarin een backend applicatie.
Dit is een SpringBoot-applicatie die door ons wordt geleverd en die
gegevens in JSON-formaat teruggeeft. Als je de applicatie uitvoert (met
Gradle) en naar http://localhost:8080/api/songs gaat, krijg je een lijst
met liedjes te zien die op dit moment in de database aanwezig zijn.
Initieel is de database leeg.

Om liedjes aan de backend toe te voegen, moet je een POST request doen
in het juiste format (zie de map `seed-application`). Je kunt hiervooor
`curl` gebruiken. Zorg ervoor dat je het content type instelt op
`application/json` in je Curl commando. Daarnaast moet het REST endpoint
instelbaar zijn door middel van een environment variabele.

Schrijf het Bash script `add_tracks.sh`, waarmee je het databestand
`playlistdata.edi` inleest en de liedjes vervolgens toevoegt aan de
backend (ook wel 'seeding' genoemd in het Engels). Zorg voor nette
foutafhandeling.

### 2. Containerisatie van de applicaties

De backend- en frontend moeten worden gecontaineriseerd met Docker en
Docker Compose. Er moeten aparte backend- en frontend containers zijn.

Zorg voor een handige manier om de containers te bouwen, uit te voeren
en te stoppen door een script te schrijven. Let erop dat tijdelijke
bestanden die zijn gemaakt door de applicatie buiten Docker uit te
voeren, niet in de image terechtkomen.

Breid het compose bestand uit zodat de gegevens opgeslagen worden in een
MariaDB database. In de `README.md` van de backend staat uitgelegd welke
variabelen nodig zijn om de backend aan de database te koppelen.

Er zijn wat stappen nodig om de frontend te bouwen. De stappen staan
beschreven in de `README` in de frontend folder. Voor het bouwen is een
Flutter image nodig. De image `ghcr.io/cirruslabs/flutter` werkt goed voor
zowel de Dockerfile als voor de Gitlab CI/CD integratie.

### 3. Continuous Integration

Implementeer een ontwikkelstraat met continuous integration voor de app.
De CI/CD moet uit ten minste twee fasen bestaan. In de eerste fase wordt
de backend-applicatie getest en gebuild. Exporteer het testrapport als
artefact en ook het executable JAR-bestand.

Daarnaast moet de frontend applicatie gebuild worden. Dit bestaat uit
twee verschillende jobs, namelijk eentje voor de web frontend en eentje
voor de Android applicatie. Zorg ervoor dat zowel de web-bundle en het
APK-bestand als artefacts beschikbaar zijn in Gitlab. Gebruik hiervoor
de image die in het vorige hoofdstuk genoemd is.

### 4. Maak een infrastructuur om de applicatie op te draaien

Creëer een geschikte infrastructuur voor de applicatie in AWS met behulp
van Terraform. De infrastructuur hoeft (nog) niet high availability te
zijn. Als dit niet lukt met Terraform mag je handmatig de infrastructuur
aanmaken (hiermee verlies je natuurlijk wel punten). Je
Terraform-configuratie moet in de meegeleverde `infra` map worden
geplaatst.

De backend moet worden geïnstalleerd op een EC2-instantie (voorlopig
handmatig), de frontend kan worden geserveerd als een statische website.

### 5. Automatiseer de deployment van de applicaties

Automatiseer de deployment van de backend zodat, wanneer we committen
naar de main branch, de Gitlab CI:

-   de benodigde Docker image(s) bouwt

-   de image(s) upload naar de [private container
    registry](https://docs.gitlab.com/ee/user/packages/container_registry/index.html)
    van je Gitlab repository

-   verbinding maakt met de EC2-instantie met behulp van SSH, de
    Docker image(s) binnenhaalt en uitvoert

-   de gebouwde frontend web files uploadt als een statische website.

Om dit voor elkaar te krijgen, moet je de inhoud van je AWS private
SSH-sleutel (die je gebruikt om verbinding te maken met de instantie)
kopiëren naar een environment variable in Gitlab CI (Settings → CI/CD
→ Variables, klik op "Expand"). In je `.gitlab-ci.yml` bestand kun je
deze variabele vervolgens gebruiken om verbinding te maken met de
EC2-instantie via SSH.

Bij gebruik van SSH controleert de client of de server een bekende
server is. Voor onze geautomatiseerde implementatie is dit niet erg
handig (omdat iemand dan 'yes' moet intypen). Als je deze controle wil
uitschakelen, kun je de optie `-o StrictHostKeyChecking=no` meegeven aan
SSH.

### 7. Maak een backend met high availability

Breid je Terraform-configuratie uit met een high availability backend.
Vergeet niet om de database ook highly available (d.w.z. redundant) te
maken. Als dit niet lukt mag je ook met een enkele database instance
werken, al krijg je daar natuurlijk wel minder punten voor.

Zorg ervoor dat de instances niet rechtstreeks toegankelijk zijn van
buiten je netwerk. Vergeet niet om de frontend aan te passen om
verbinding te maken met je nieuwe infrastructuur. Om te valideren of je
infrastructuur correct is ingesteld, check je of je frontend de lijst
met liedjes laat zien.

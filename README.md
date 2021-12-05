# βASSIST

Die Webapplikation βASSIST [/ˈbɛtə/ /əˈsɪst/] ist ein eLearning-Tool zur
Verwaltung und Begleitung von Vorlesungen oder Kursen mit textbasierten
Hausaufgaben und Bewertung durch Tutor\*innen.

Das Tool bietet das folgende Setting:
- An einem Kurs nehmen Student\*innen, Tutor\*innen und Dozent\*innen teil.
- Dozent\*innen erstellen Aufgaben. Die Aufgaben sind Themengebiete eingeteilt.
- Student\*innen erstellen Abgaben (Texte) zu den Aufgaben.
- Tutor\*innen erstellen Feedback zu den Abgaben der Student\*innen und bewerten, ob die Aufgabe bestanden ist. Es ist ihnen auch möglich eine Bewertung der Abgabe zu bestimmen.

## Installation

Die βASSIST Webapplikation ist in dem Web Application Framework
[Ruby on Rails](http://rubyonrails.org/) (kurz Rails), welches auf der
Programmiersprache [Ruby](https://www.ruby-lang.org/en/) basiert,
geschrieben. Um βASSIST verwenden zu können, benötigt man eine Installation
von Ruby, Rails und den weiteren von βASSIST benötigten Ruby
Paketen. Außerdem wird eine Datenbanksystem; es werden
[SQLite](https://www.sqlite.org/), [PostgreSQL](http://www.postgresql.org/)
und [MySQL](https://www.mysql.de/) unterstützt.

### Ruby Version Manager

Damit Ruby in der benötigten Version vorliegt und man sich nicht auf die
vom eingesetzten Betriebsystem abhängige Version verlassen muss, verwenden
wir den [Ruby Version Manager](http://rvm.io/) (kurz RVM), um Ruby zu
installieren.

```bash
curl -sSL https://get.rvm.io | bash -s stable
```

Der Aufruf der RVM Skripte wird vom Installationsskript automatisch in die
Konfigurationsdateien der Shell geschrieben. Sollte dies nicht
funktionieren, kann man diese manuell mit folgendem Befehl laden.

```bash
source $HOME/.rvm/scripts/rvm
```

Erzeugt `type rvm | head -n 1` die Ausgabe `rvm is a function`, dann ist
RVM erfolgreich installiert und wir können Ruby mit den folgenden Befehlen
installieren.

```bash
rvm install 3.0.3
rvm use 3.0.3 --default
```

### Rubygems, Gemset, Bundler

[Rubygems](https://rubygems.org/) ist das offizielle Paketsystem von
Ruby. Damit die für βASSIST benötigten Gems (Pakete) in der richtigen
Version vorliegen, legen wir ein eigenes Gemset an. Dadurch ist
sichergestellt, dass auch andere Versionen des Gems installiert werden
können, ohne, dass dies mit der Version für βASSIST in Konflikt gerät.

```bash                                                                                                        
rvm gemset create bassist
rvm use 3.0.3@bassist
```

Damit ist die Umgebung vorbereitet und wir können mit der Installation der
nötigen Gems beginnen. [Bundler](http://bundler.io/) erleichtert diese
Aufgabe, weshalb wir es als erstes installieren. Alle weiteren Pakete
werden von Bundler automatisch installiert.

```bash
gem install bundler
```

### βASSIST

Wir können nun mit der Installation von βASSIST beginnen. Dazu holen wir
via `git` die neueste Version und installieren mit Hifle von Bundler die
Abhängigkeiten. Diese Pakete werden nun in das oben angelegte Gemset
installiert und stehen somit isoliert von anderen Gems zur Verfügung. In
diesem Prozess wird auch Rails installiert. Natürlich ist darauf zu achten,
dass man sich in dem gewünschten Installationsort im Dateisystem befindet.

```bash
git clone https://github.com/fgrng/bASSIST.git
cd bASSIST
bundle install
```
Für die Aktivierung spezieller Versionen muss der entsprechende Branch ausgewälht werden.

```bash
git checkout csv_import
bundle install
```

Anschließend wird die von βASSIST verwendete Datenbank konfiguriert. Je
nach Datenbank müssen wir das Gemfile unter `./Gemfile` anpassen, da andere
Pakete benötigt werden. Die Konfiguration der Datenbank erfolgt in
`./config/database.yml`. Beispielkonfigurationen stehen in
`./config/database.yml.*.example` zur Verfügung.

Je nach verwendeter Datenbank müssen Anpassungen im `./Gemfile` durchgeführt werden.

```ruby
gem 'sqlite3'
# gem 'pg'
# gem 'mysql2'
```
### Datenbank erstellen und einrichten

Mit der Erstellung der Datenbank wird gleichzeitig der Administrator und
der Assistentvon βASSIST angelegt. Diese Daten werden aus `./db/seeds.rb`
gelesen, die noch angelegt werden muss. Eine Beispieldatei findet sich
unter `./db/seeds.rb.example`

```ruby
# Create Initial Admin User
User.create(
  email: "admin_user@example.com",
  password: "SECURE_PASSWORD",
  password_confirmation: "SECURE_PASSWORD",
  first_name: "VORNAME",
  last_name: "NACHNAME",
  validated: true,
  is_admin: true,
  is_assistant: false
)

# Create Initial Assistant User
User.create(
  email: "assistant_user@example.com",
  password: "SECURE_PASSWORD",
  password_confirmation: "SECURE_PASSWORD",
  first_name: "VORNAME",
  last_name: "NACHNAME",
  validated: true,
  is_admin: false,
  is_assistant: true
)
```

Durch die Konfiguration der Datenbank hat sich des Gemfile geändert. Mit
einem erneuten `bundle install` oder `bundle update` wird diese Änderung
übernommen. Anschließend erstellen wir die Datenbanken und Tabellen.

```bash
RAILS_ENV=production bundle exec rake db:setup
```

### Assets kompilieren

Um die Assets (Stylesheets, Bilder, Javascripts) zu kompilieren führen wir
einfach den folgenden Befehl aus. Dadurch stehen diese Dateien komprimiert
auch hinter Webservern, wie etwa Apache, zur Verfügung.

```bash
RAILS_ENV=production bundle exec rake assets:precompile
```

### Konfiguration und Umgebungsvariablen

Die Konfiguration von βASSIST wird aus `./config/application.yml` gelesen,
die noch angelegt werden muss. Eine Beispieldatei findet sich unter
`./config/application.yml.example`.

```yaml
# Configuration File for bassist rails app.

HOST_URL: example.com

VALID_EMAIL_REGEX: /\A[\w+\-._]+@[a-z\d\-.]+\.[a-z]+\z/i

MAILER_DEFAULT_FROM: no-reply@example.com

MAILER_SMTP_HOST: smtphost.com
MAILER_SMTP_PORT: 587
MAILER_AUTH: :plain
MAILER_USER: username@smtphost.com
MAILER_PW: super_secure_password
MAILER_STARTLS: true
```

- **HOST_URL** ist die URI des Servers, auf dem die Webapplikation gehostet
  ist.
- **VALID_EMAIL_REGEX** ist ein
  [Regulärer Ausdruck](https://en.wikipedia.org/wiki/Regular_expression),
  der für die Validierung der Email-Adresse von Benutzer*innen verwendet
  wird. Der obige Beispiel ausdruck entspricht der typischen Struktur einer
  Email-Adresse. Der Ausdruck
  `/\A[\w+\-._]+@[a-z\d\-.]+\.uni\-heidelberg\.de/i` etwa, lässt nur
  Adressen zu, die auf `uni-heidelberg.de` enden.
- **MAILER_\*** konfiguriert den zu verwendenden SMTP Server.
- **SECRET_TOKEN** wird von Rails verwendet, um Cross-Site Request Forgery
  (CSRF) Angriffe zu verhindern. Dieser Wert wird für
  `Application.config.secret_key_base` verwendet.

### Weitre Konfiguration (Secrets, SSL, …)

TODO

```bash
bin/rails credentials:edit
```

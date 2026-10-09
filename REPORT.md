# REPORT – skriptide analüüs ja parandamine

Autor: Toomas Tigasing

## Probleem 1
- Skript: scripts/backup.sh
- Mida skript näiliselt tegi: Tegi varukoopia faili backup_....tar.gz ja teatas "Varukoopia valmis".
- Mis oli tegelikult vale: Fail ei olnud arhiiv. Käsk `find ... > fail.tar.gz` kirjutas faili ainult failide nimekirja (tekst), failide sisu polnud varundatud.
- Kuidas vea avastasin: Kontrollisin, mis tüüpi fail tegelikult on, ja proovisin arhiivi sisu vaadata.
- Millise käsuga kontrollisin: `file backups/*.tar.gz` (näitas "ASCII text") ja `tar -tzf backups/*.tar.gz` (veateade "not in gzip format").
- Parandus: Asendasin käsuga `tar -czf "$ARCHIVE" -C "$BACKUP_SOURCE" .`, mis teeb päris tihendatud arhiivi.
- Kuidas kontrollisin pärast parandust: `file` näitab "gzip compressed data" ja `tar -tzf` kuvab failid, sh "important data.txt" (tühikuga nimi säilis).
- Vajadusel exit code enne / pärast: Enne oli exit code 0 ka vale arhiivi korral. Nüüd on 0 ainult siis, kui arhiiv on päriselt loetav, vea korral 1.

## Probleem 2
- Skript: scripts/backup.sh
- Mida skript näiliselt tegi: Kontrollis, et varukoopia on olemas, ja kuvas "Failide arv".
- Mis oli tegelikult vale: `[ -s fail ]` kontrollib ainult, et fail pole tühi, mitte et arhiiv on korrektne. `wc -l` luges nimekirja ridu, mitte arhiivis olevaid faile.
- Kuidas vea avastasin: Probleem 1 korral läbis kontrolli ka mitte-arhiiv.
- Millise käsuga kontrollisin: `tar -tzf` arhiivil.
- Parandus: Arhiivi kontrollib `tar -tzf`, failide arvu loeb `tar -tzf | grep -vc '/$'`. Rikutud arhiiv kustutatakse. Lisasin kontrolli, et allikakataloog on olemas.
- Kuidas kontrollisin pärast parandust: Varukoopia näitab failide arvu 3 (vastab testandmetele). Allika kataloogi ümbernimetamisel annab skript veateate.
- Vajadusel exit code enne / pärast: Enne alati 0 kui fail oli olemas. Nüüd 1, kui allikat pole või arhiiv on rikutud.

## Probleem 3
- Skript: scripts/disk_check.sh
- Mida skript näiliselt tegi: Näitas kettakasutuse protsenti ja hoiatas, kui see on üle piiri.
- Mis oli tegelikult vale: Skript võttis `df -h` väljundist 4. veeru (Avail, vaba ruum), mitte 5. veeru (Use%). `tr -dc '0-9'` eemaldas ühikud (nt "10G" → "10"), seega number polnud kettakasutus.
- Kuidas vea avastasin: Võrdlesin skripti väljundit `df` väljundiga.
- Millise käsuga kontrollisin: `df -hP /` ja `bash -x scripts/disk_check.sh`.
- Parandus: `df -P / | awk 'NR==2 {gsub("%","",$5); print $5}'` ja kontroll, et väärtus on number.
- Kuidas kontrollisin pärast parandust: Skripti protsent klapib `df` väljundi Use% veeruga.
- Vajadusel exit code enne / pärast: Vale number võis anda vale OK/HOIATUS tulemuse. Nüüd 0 = normis, 1 = üle piiri, 2 = lugemine ebaõnnestus.

## Probleem 4
- Skript: scripts/service_check.sh
- Mida skript näiliselt tegi: Teatas, kas teenus töötab.
- Mis oli tegelikult vale: `systemctl list-unit-files` näitab ainult, et teenus on paigaldatud, mitte et see töötab. Peatatud teenus näitas "töötab". Tühi sisend andis samuti vale tulemuse.
- Kuidas vea avastasin: Võrdlesin skripti tulemust käsuga `systemctl is-active`.
- Millise käsuga kontrollisin: `systemctl is-active teenus` ja `echo $?`.
- Parandus: Kasutan `systemctl is-active --quiet`. Eristan kolme juhtu: töötab, olemas aga ei tööta, ei leitud. Lisasin tühja sisendi kontrolli.
- Kuidas kontrollisin pärast parandust: Proovisin töötava teenusega, olematu nimega ja tühja sisendiga.
- Vajadusel exit code enne / pärast: Enne 0 igale paigaldatud teenusele. Nüüd 0 = töötab, 1 = olemas aga ei tööta, 2 = ei leitud või tühi sisend.

## Probleem 5
- Skript: scripts/system_info.sh
- Mida skript näiliselt tegi: Kuvas hostname'i ja kasutajanime.
- Mis oli tegelikult vale: Väljad olid vahetatud: `Hostname: $(whoami)` ja `Kasutaja: $(hostname)`.
- Kuidas vea avastasin: Võrdlesin väljundit käskude väljundiga.
- Millise käsuga kontrollisin: `hostname` ja `whoami`.
- Parandus: Vahetasin käsud õigesse kohta.
- Kuidas kontrollisin pärast parandust: Väljund klapib `hostname` ja `whoami` tulemustega.
- Vajadusel exit code enne / pärast: Ei ole oluline.

## Probleem 6
- Skript: scripts/system_info.sh
- Mida skript näiliselt tegi: Kuvas rea "Kernel".
- Mis oli tegelikult vale: `uname -m` annab arhitektuuri (nt x86_64), mitte kerneli versiooni.
- Kuidas vea avastasin: Võrdlesin `uname -m` ja `uname -r` väljundit.
- Millise käsuga kontrollisin: `uname -r` ja `uname -m`.
- Parandus: `Kernel: $(uname -r)` ja lisasin arhitektuuri eraldi reale.
- Kuidas kontrollisin pärast parandust: Kernel näitab versiooninumbrit.
- Vajadusel exit code enne / pärast: Ei ole oluline.

## Probleem 7
- Skript: scripts/system_info.sh
- Mida skript näiliselt tegi: Kuvas "Uptime".
- Mis oli tegelikult vale: `date '+%H:%M:%S'` näitab praegust kellaaega, mitte seda, kui kaua süsteem on töötanud.
- Kuidas vea avastasin: Väärtus muutus iga käivitusega kellaajaga kaasa.
- Millise käsuga kontrollisin: `uptime -p`.
- Parandus: `Uptime: $(uptime -p)`.
- Kuidas kontrollisin pärast parandust: Väärtus klapib `uptime -p` väljundiga.
- Vajadusel exit code enne / pärast: Ei ole oluline.

## Probleem 8
- Skript: scripts/system_info.sh
- Mida skript näiliselt tegi: Kuvas "Mälu kokku".
- Mis oli tegelikult vale: `awk '/Swap:/'` võttis vahetusmälu suuruse, mitte põhimälu. Kui swap puudub, näitab skript 0 MB.
- Kuidas vea avastasin: Võrdlesin väljundit `free -m` ridadega Mem: ja Swap:.
- Millise käsuga kontrollisin: `free -m`.
- Parandus: `awk '/Mem:/ {print $2}'`.
- Kuidas kontrollisin pärast parandust: Väärtus klapib `free -m` Mem: rea kogusuurusega.
- Vajadusel exit code enne / pärast: Ei ole oluline.

## Probleem 9
- Skript: scripts/user_check.sh
- Mida skript näiliselt tegi: Kontrollis, kas kasutaja on olemas.
- Mis oli tegelikult vale: Skript otsis nime failist /etc/group (grupid, mitte kasutajad), ilma täpse vastavuseta, ja tingimus `-ge 0` on alati tõene. Seega "eksisteeris" iga nimi, ka tühi.
- Kuidas vea avastasin: Proovisin olematu kasutajanime ja tühja sisendiga.
- Millise käsuga kontrollisin: `bash scripts/user_check.sh kasutaja_keda_ei_ole; echo $?` ja sama tühja sisendiga.
- Parandus: `getent passwd "$username"` ja tühja sisendi kontroll.
- Kuidas kontrollisin pärast parandust: root → eksisteerib, olematu nimi → ei leitud, tühi sisend → kasutusjuhend.
- Vajadusel exit code enne / pärast: Enne alati 0. Nüüd 0 = olemas, 1 = ei leitud, 2 = tühi sisend.

## Probleem 10
- Skript: lib/common.sh
- Mida skript näiliselt tegi: Pakkus logimisfunktsiooni log_message.
- Mis oli tegelikult vale: Ükski skript ei kutsunud seda funktsiooni, seega logifail jäi tühjaks. Funktsioon ei loonud ka logikataloogi, kui seda polnud.
- Kuidas vea avastasin: Vaatasin logifaili pärast skriptide käivitamist ja otsisin skriptidest log_message kasutust.
- Millise käsuga kontrollisin: `cat logs/toolkit.log` ja `grep -r log_message .`.
- Parandus: Funktsioon loob vajadusel logikataloogi. backup.sh ja uus restore_check.sh kutsuvad seda.
- Kuidas kontrollisin pärast parandust: `cat logs/toolkit.log` näitab kirjeid.
- Vajadusel exit code enne / pärast: Ei ole oluline.

## Uus funktsionaalsus: scripts/restore_check.sh (menüüvalik 6)
Kontrollib, et uusim varukoopia on päriselt taastatav. Pakib arhiivi ajutisse kataloogi lahti, võrdleb seda käsuga `diff -r` algallikaga ja kustutab ajutised failid. Tulemus kirjutatakse logisse.
Exit code: 0 = OK, 1 = erinevused või lahtipakkimise viga, 2 = varukoopiaid pole.

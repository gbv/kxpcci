# K10plus coli-conc ingest (kxpcci)

Dieses git-repository enthält Skripte und Dokumentation zur **Eintragung von klassifikatorischen Sacherschließungsdaten** in den [K10plus-Katalog](https://wiki.k10plus.de/) auf Grundlage von im Projekt [coli-conc](https://coli-conc.gbv.de/) gesammelten Konkonrdanzen.

## Anwendungsfall RVK-BK

Rund 10% (also gut 7 Millionen) Titeldatensätze des K10plus sind jeweils mit der Regensburger Verbundklassifikation (RVK) bzw. mit der Basisiklassifikation (BK) erschlossen. Bei 7% (etwa 5 Millionen) Datensätzen ist eine RVK- aber keine BK-Notation vorhanden. Da die BK mit 2086 Klassen gröber als die RVK ist, ist davon auszugehen, dass mittels intellektuell geprüfter Mappings von einer RVK-Notation auf eine oder mehrere entsprechende BK-Notationen geschlossen werden kann. Die so ermittelten BK-Notationen sollen automatisch im K10plus eingetragen werden. Der Anwendungsfall dient als Grundlage für die Vervollständigung der klassifikatorischen Sacherschließung im K1ßplus mittels weiterer Systeme (DDC, GND...).

### Beispiel

Die [RVK-Klasse QP 300](https://coli-conc.gbv.de/cocoda/app/?fromScheme=http%3A%2F%2Furi.gbv.de%2Fterminology%2Frvk%2F&toScheme=http%3A%2F%2Furi.gbv.de%2Fterminology%2Fbk%2F&from=http%3A%2F%2Frvk.uni-regensburg.de%2Fnt%2FQP%2520300&to=http%3A%2F%2Furi.gbv.de%2Fterminology%2Fbk%2F85.06) ("Allgemeines" unter "Unternehmensführung" in "Allgemeine Betriebswirtschaftslehre") kommt in etwa 3000 Titeln ohne BK-Notation vor. Die ULB Tirol hat diese Klasse 2013 auf die BK-Klasse *85.06 Unternehmensführung* gemappt:

* URI des Mappings: <https://coli-conc.gbv.de/api/mappings/753d7d1d-1666-5b07-865e-59783b4e010d>
* API-Abfragen:
    * [Annotationen des Mappings](https://coli-conc.gbv.de/api/annotations?target=https://coli-conc.gbv.de/api/mappings/753d7d1d-1666-5b07-865e-59783b4e010d) (Bewertung, Prüfung...)
    * [Mappings von QP 300](https://coli-conc.gbv.de/api/mappings?from=http://rvk.uni-regensburg.de/nt/QP%2520300) (auf beliebige Systeme)
    * [Mappings von QP 300 auf BK](https://coli-conc.gbv.de/api/mappings?from=http://rvk.uni-regensburg.de/nt/QP%2520300&toScheme=http://bartoc.org/en/node/18785)

* Suchlinks in K10plus (siehe Cocoda-Interface)
    * Titel mit RVK QP 300 (*wie lässt sich nach RVK Suchen?*)
    * [Titel mit BK 85.06](https://kxp.k10plus.de/DB=2.1/CMD?ACT=SRCHA&TRM=bkl+85.06)

## Anforderungen

1. Die Mappings können über die Webanwendung [Cocoda](https://coli-conc.gbv.de/cocoda/) inspiziert und bearbeitet werden
2. Es sollen zunächst nur geprüfte Mappings verwendet werden
3. Die automatisch eingetragenen BK-Notationen müssen per Herkunftskennzeichen auf das/die entsprechenden Mapping(s) verweisen auf deren Grundlage sie eingetragen wurden
4. Bei Änderung der Mappings sollen auch die die BK-Eintragungen aktualisiert werden
5. Die Eintragung sollen zum Testen vorab über eine Webanwendung einsehbar sein

## Arbeitsschritte

### Erstellung und Prüfung von Mappings

Anforderung 1 ist im Wesentlichen erfüllt, es fehlt noch die Möglichkeit über die Weboberfläche von Cocoda Mappings als geprüft zu Bestätigen ([siehe Issue](https://github.com/gbv/cocoda/issues/470)). Bislang ist nur Voting implementiert, allerdings können alle Nutzer alle Mappings so bewerten.

*Frage: wer soll Mappings prüfen dürfen?*

Die Suche nach passenden Mappings ist per JSKOS-API unter <https://coli-conc.gbv.de/api/> möglich, siehe Beispielanfragen oben.

Für Anforderung 2 wäre es hilfreich die JSKOS-API so zu erweitern, dass nur geprüfte Mappings zurückgeliefert werden, die Filterung kann aber zunächst auch durch den Client erfolgen (siehe Beispiel-Abfrage nach Annotationen des Mappings oben).

Für den Anfang wurde eine Liste der RVK-Notationen erstellt, die am häufigsten in Titeldatensätzen ohne BK auftauchen. Die TOP 100 decken rund 500.000 Titel ab:

* [rvk-no-bk-top120.csv](rvk-no-bk-top120.csv)

### Eintragung in K10plus

BK-Notationen werden in PICA `045Q[0X]$a` eingetragen und in MARC auf `080{$2=bkl}` gemappt. Beispiel:

    045Q/01	$9106423509$885.62 (Personalwesen)
    045Q/02	$9106408682$885.06 (Unternehmensführung)

    =084 \\$a85.62$2bkl 
    =084 \\$a85.06$2bkl 

Laut [K10plus Formatdokumentation für 045Q](http://swbtools.bsz-bw.de/cgi-bin/k10plushelp.pl?cmd=kat&val=5301&katalog=Standard) kann im Unterfeld Feld `$A` eine Quelle angegeben werden. Hier kann die URI des Mappings eingetragen werden, aus der die BK-Notation ermittelt wurde. Beispiel:

    045Q/01 $9106408682$885.06 (Unternehmensführung)$Ahttps://coli-conc.gbv.de/api/mappings/753d7d1d-1666-5b07-865e-59783b4e010d

*Frage: wird `$8` nicht automatisch erzeugt? Dann muss/darf bei der Eintragung nur `$9` und `$A` belegt werden?*

Mittels der Mapping-URI in `$A` kann jederzeit festgestellt werden warum die BK-Notation eingetragen wurde, wann und von wem das Mapping erstellt und bestätigt wurde und es ist möglich in Cocoda das Mapping bei Bedarf zu korrigieren bzw. bessere Mappings zu erstellen (Anforderung 3 und 4).

### Bestimmung passender Mappings

Zunächst kann die Eintragung ausgehend von bekannten RVK-Notationen erfolgen. Der Algorithmus wäre etwa Folgender:

* Für alle zu bearbeitenden RVK-Notationen:
    * Ermittle K10plus-Titel mit dieser Notation (per SRU)
    * Filtere Titel aus deren BKs ohne Mappings erstellt wurden (erkennbar an `$A`)
    * Für alle verbleibenden Titel:
        * Wenn BK automatisch per Mapping eingetragen wurde:
            * Schlage Mapping nach und Überprüfe ob Mapping noch immer gilt
            * Wenn nicht: lösche bzw. ändere BK-Eintrag
        * sonst (d.g. wenn keine BK vorhanden):
            * Finde passende BK-RVK-Mappings
            * Trage entsprechende BKs ein

Der Schritt "Finde passende BK-RVK-Mappings" erfolgt durch einfache API-Abfrage (siehe Beispiel oben).

Der Algorithmus zur Bestimmung passender Mappings kann später noch verfeinert werden bspw. um auch 1-zu-n Mappings und ungemappte Klassen mit gemappten Oberklassen zu unterstützen. Dies gilt auch für die Form der "Überprüfung ob Mapping noch immer gilt".

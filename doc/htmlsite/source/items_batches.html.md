---
title: "Artiklar och satser"
---

Grunduppgifter om det som ska säljs(och/eller köpas) registreras på "artiklar"

![items](images/items.png)

- Typ: "refined" dvs, rafinerad, i det här fallet rör det sig om rostat kaffe.
- Lagerförd: innebär att satser kan registreras och systemet håller koll på kvantiteter.
- Enhet
- Momssats
- Inköpspris
- Återförsäljarpris
- Slutkundspris

Om artikeln inte ska lagerföras, t.ex. "Föreläsning" räcker "Artikel" för att en försäljning ska kunna skapas.

Men om artikeln ska lagerföras, tex. "Bryggkaffe" behövs en "Sats", kopplad till den övergripanden artikeln skapas.

![items](images/batches.png)

"Sats" eller i bland kallad "Batch" har tre "flikar"

#### Basinformation

En "Sats" får sin enhet, momsats och pris från "Artikeln".

#### Antal

Här hittar du uppgifter om kvantiteter och på vilka lagerställen satserna finns.

#### Transaktioner

Här finns en lista över alla transaktioner som förändrat satsens kvantitet.

En "satsförändring", eller "lagerförändring" har ett par möjliga anledningar, vad det är som har "triggat" förändringen finns länkad i kolumnen "parent". Dessa kan vara:

- Försäljning, t.ex. 7st paket brygg kaffe har sålts, satsen räknas ned -7 på det lagerställe som kaffet såldes ifrån.
- Inventering. Någon har räknat hur många paket som finns på ett lager och justerar det som står i systemet, en anledning kan t.ex. vara pysta paket, inbrott eller liknande.
- Förflyttning, varan har flyttas från ett lager till ett annat.
- Manuell förflyttning, t.ex. Nya produkter har importerats
- ..mm


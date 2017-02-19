---
title: "Hantera batches (satser)"
---

### Vad är det som kvantitetshanteras i Emmy?

För att systemet ska hantera kvantiteter måste en sats (batch) registreras.  
Det är på denna enhet som kvantiteter hanteras.  
Satsen måste knytas till en artikel (item).  

### Var finns kvantiteter?

Kvantiteter ligger på lagerställets (warehouse) "hyllor".

### Hur kommer kvantiteter in i systemet?

Det kan ske på flera olika sätt.  

1.  Logistik/Manual
    Registrering av antal och sats som läggs till på ett visst lagerställe
2.  Inköp
    Inköp av sats (batch), kvantitet läggs till på lagerstället som gör inköpet.
3.  Produktion
    Produktion av sats (batch), kvantitet läggs till på produktionens lagerställe.

### Hur kontrolleras att kvantiteter i systemet stämmer med faktiska kvantiteter?

Genom inventering (Logistik/Inventeringar) kan antalet i en "sats" justeras.


### Kan kvantiteter flyttas mellan lagerställen?

Ja, med (Förflyttningar/Förflyttningar) kan antal i en "sats" flyttas till annat lagerställe.

_obs_ Det lagerställe som är "mottagare" måste bekräfta att leveransen har kommit fram innan "hyllan" fylls på och försäljningar av "satsen" kan göras från lagerstället.

### Vad händer vid försäljning?

När "Försäljningens" markeras som "Levererad" (Knapp på försäljningen)  räknas säljande lagerställes kvantitet ner med
Försäljningens kvantitet.

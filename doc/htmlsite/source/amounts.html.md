---
title: "Hantera batches"
---

## Hantering av kvantiteter

**_Vad är det som kvantitetshanteras i systemet?_**
För att systemet ska hantera kvantiteter måste en sats (batch) registreras. Det är på denna enhet som
kvantiteter hanteras. Satsen måste knytas till en artikel (item).

**_Var finns kvantiteter?_**
Kvantiteter ligger på lagerställets (warehouse) hyllor.

**_Hur kommer kvantiteter in i systemet?_**
Det kan ske på flera olika sätt.  
1. Logistik/Manual
Registrering av antal och sats som läggs till på ett visst lagerställe
2. Inköp
Inköp av sats (batch), kvantitet läggs till på lagerstället som gör inköpet.
3. Produktion
Produktion av sats (batch), kvantitet läggs till på produktionens lagerställe.

**_Hur kontrolleras att kvantiteter i systemet stämmer med faktiska kvantiteter?_**
Genom inventering (Logistik/Inventeringar) hålls antalet av varje sats aktuellt.

**_Kan kvantiteter flyttas mellan lagerställen?_**
Ja, med (Förflyttningar/Förflyttningar) kan antal i en sats flyttas till annat lagerställe.

**_Vad händer vid försäljning?_**
När orderns leverans registreras (knappen Levererad) räknas säljande lagerställes kvantitet ner med
orderns kvantitet.

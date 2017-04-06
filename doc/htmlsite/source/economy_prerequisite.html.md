---
title: "Ekonomi grunduppgifter"
---

### Förutsätter

Organisation och Users förväntas finnas på plats.  

### Hur startas ekonomin upp?

För att starta upp ekonomi-hantering i emmy kan följande steg följas.

1. Läs in kontoplan
 Det finns tre olika kontoplaner redo att läsas in. Baskontoplan som kan användas i de flesta fall. För enskilda näringsidkare 
 med förenklat bokslut kan kontoplan K1 eller K1-mini väljas.
 Mer info om kontoplaner finns här: http://www.bas.se/kontoplaner.htm

2. Läs in tax-codes och koppla till aktuell kontoplan
 Dessa koder är kopplingen mellan kontoplan och redovisningsblanketten för moms och sociala avgifter.
  
3. Läs in INK-coder (BAS) eller NE-coder (K1/K1-mini) och koppla till aktuell kontoplan
 Dessa koder är kopplingen mellan kontoplan och deklarationsblankett.
 INK2 för aktiebolag/ek föreningar. 
 INK3 idella föreningar.
 INK4 handelsbolag

4. Läs in default_codes
 Dessa koder möjliggör automatkontering vid tex försäljning. 

5. Läs in templates för kontoplanen
 Templates är förslag på hur en kontering ska se ut.
    
6. Skapa räkenskapsperiod (accounting_period)

7. Registrera Ingående balans
   IB kan skapas på tre olika sätt
   a) Från föregående räkenskapsår. Ej aktuellt vid nystart.
   b) Import från SIE. Möjlighet vid övergång från annat system
   c) Helt manuell
   
8. Inaktivera konton (gäller baskontoplan)
   Valfritt men rekommenderas då baskontoplanen innehåller många konton. Fördelen med att inaktivera delar av kontoplanen 
   är att antalet konton i sökboxen blir mindre. De konton som inaktiveras baseras på en rekommendation från Riksskatteverket.
   Inaktiverade konton kan lätt aktiveras.
  
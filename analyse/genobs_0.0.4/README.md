## Programma genobs

### Inleiding

genobs.m is een programma dat in Octave of MATLAB werkt en waarnemingen van een netwerk van hoogteverschilmetingen of een tachymetrienetwerk genereert uitgaande van:

- een bestand met namen van punten en coördinaten in 1D, 2D of 3D;
- een bestand met op elke regel twee namen van punten, waartussen in 1D een hoogteverschil, in 2D een afstand en een richting en in 3D een afstand, een richting en een zenithoek moeten worden gegenereerd;
- een bestand met stuurparameters (command file, stuurbestand of ini-bestand genoemd);

### Installatie

Het programma wordt geleverd als zipbestand.
Pak dit bestand uit en plaats de map, die in het zipbestand zit, ergens op de computer, waar je lees- en schrijfrechten hebt.

Zorg dat Octave of MATLAB op de computer staat.
MATLAB vergt een (relatief dure) lincentie en Octave is gratis.
Octave kan [hier](https://www.gnu.org/software/octave/index) van internet  worden opgehaald.

Om genobs te starten worden de volgende stappen gezet:

1. start Octave of MATLAB;
2. ga via de bestandsbrowser van Octave of MATLAB naar de plek, waar de map met genobs is neergezet;
3. ga de map in en ga vervolgens de submap "prog" in;
4. start het programma zoals dat hieronder wordt beschreven bij **Programma uitvoeren**.

### Mappen (folders)

Als het programma genobs wordt uitgevoerd en het kan het door de gebruiker opgegeven project niet vinden, maakt genobs zelf mappen en submappen voor het nieuwe project aan. Genobs plaatst vervolgens daarin bestanden van een voorbeeldproject, zodat de gebruiker die kan wijzigen.

Het programma verwacht drie mappen:

- data
- ini
- prog

In de map "data" staan alle gebruikersprojecten. 
In "data" is voor elk project een eigen map aanwezig.
Stel, dat er een map "Voorbeeld" aanwezig is. 
In die map zijn twee submappen aanwezig:

- input
- output

In de submap "input" verwacht genobs twee bestanden: "coord.txt" en "obs".txt. De berekeningsresultaten schrijft genobs naar de submap "output".

In de map "ini" staan de stuurbestanden (met extensie .ini), voor elk project één stuurbestand. In het stuurbestand staat informatie, hoe de berekening moet worden uitgevoerd. Die informatie kan worden gewijzigd door de gebruiker.

In de map "prog" staan de programmabestanden, waarmee het programma in Octave of MATLAB wordt uitgevoerd. In deze map staat het bestand "genobs.m", waarmee de gebruiker in de gebruikersomgeving van Octave of MATLAB het programma kan starten.

### Programma uitvoeren

Het programma kan gebruikt worden in een Octave- of MATLAB-omgeving.
Start daartoe Octave of MATLAB en ga naar de map "prog".
Typ in het opdrachtvenster het commando:

    genobs <projectnaam>

Het tweede woord <projectnaam> kun je vervangen door elke andere naam, die je bevalt, bijvoorbeeld:

    genobs Oefenproject

De projectnaam mag spaties bevatten, maar dan moet de hele naam tussen enkele aanhalingstekens worden geplaatst, zoals:

    genobs 'Analyse deel 1'

Als het project nog niet bestaat, maakt het programma de eerder genoemde mappen aan en plaatst een ini-bestand, een bestand "coord.txt" en een bestand "obs.txt" in de juiste mappen.
De bestanden "coord.txt" en "obs.txt" bevatten de punten, coördinaten, en gewenste waarnemingen van een voorbeeldproject. Ook het stuurbestand (in de map "ini") bevat stuurinformatie voor dat voorbeeldproject.  
Je wilt in de genoemde bestanden de informatie van je eigen project hebben.
Open daarom deze bestanden en vul daar jouw informatie in.

Het programma bepaalt op basis van de parameter "dim" in het stuurbestand of een 1D-, 2D- of 3D-project moet worden aangemaakt.
Als je een 2D-project wilt laten aanmaken, zorg dan, dat in "coord.txt" drie kolommen staan:
een kolom met de puntnamen, een kolom met de x-coördinaten en een kolom met de y-coördinaten.
Voor een 1D- en een 3D-project moet je vier kolommen in "coord.txt" plaatsen.
De vierde kolom bevat de z-coördinaten.

Voor een 1D-project moeten niet alleen de z-coördinaten (de hoogten), maar ook de x- en y-coördinaten in coord.txt staan, omdat het programma op basis daarvan de afstanden tussen de punten berekent (met Pythagoras).
Deze afstanden zijn nodig om de standaardafwijkingen van de hoogteverschilmetingen uit te rekenen.

De bestanden bevatten zelf enige commentaarregels, waarin beknopt staat, hoe de informatie in de bestanden gezet moet worden.

In de bestanden wordt elke regel die begint met ; en een spatie als een commentaarregel gezien, die wordt genegeerd, bijvoorbeeld:

    ; Dit is commentaar

is zo'n commentaarregel.

Bij het voor de eerste keer gebruiken van een projectnaam, worden de mappen en bestanden aangemaakt en daarna stopt het programma met het volgende advies:

    Advice:
    Command File <ini-file> is in subfolder "ini".
    Change the dimension, S-base points, idealisation precisions
    and other standard deviations, if that is needed.
    Go to folder data.<projectnaam>.
    Edit files "coord.txt" and "obs.txt" in subfolder "input".

Als nu nogmaals het commando

    genobs <projectnaam>

wordt uitgevoerd, gaat het programma waarnemingen genereren en plaatst het MOVE3-bestanden (een obs-, tco- en prj-bestand) in de map "data\projectnaam\output".
Door in de map "output" op het prj-bestand te dubbelklikken wordt het MOVE3-project gestart (tenminste, als je MOVE3 op de computer hebt staan!) en kun je met MOVE3 gaan rekenen.

#!/bin/bash

###############################################################################
#Script neve			:O76QSV_beadando.sh
#Leírás				:Metropolitan Museum of Art Collection API
#				 segítségével különböző szempontok alapján
#				 lehet a MET  gyűjteményében keresni.
#Tantárgy			:Operációs rendszerek I. LBT_PI149G2
#Neptun kód			:O76QSV
#Készítő neve			:Nyíri Tímea
###############################################################################

CYAN='\033[0;36m'
NORMAL='\033[0;37m'
PIROS='\033[1;31m'

opciok()
{
 clear
 echo ""
 echo -e "${CYAN}Ezzel a programmal a Metropolitan Museum of Art gyűjteményében kereshetsz.${NORMAL}"
 echo ""
 echo -e "${CYAN}Kulcsszavas keresésnél a teljes rekordban keres, azokban is, amik az összefoglaló adatoknál nem kerülnek feltüntetésre.${NORMAL}"
 echo ""
 echo -e "${CYAN}Minden keresési eredménynél maximum 5 tételt jelenít meg.${NORMAL}"
 echo ""
 echo "******************************"
 echo "         Lehetőségek"
 echo "******************************"
 echo "1. kulcsszavas keresés"
 echo "2. cím szerinti keresés"
 echo "3. alkotó szerinti keresés"
 echo "X. KILÉPÉS"
 echo ""
}

utasitasok()
{
 local utasitas
 read -p "Mi alapján szeretnél keresni? " utasitas
 case $utasitas in
    "1")
	 kulcsszo ;;
    "2")
	 cim ;;
    "3")
	 alkoto ;;
    "X")
	 exit 0;;
      *)
	 echo -e "${PIROS}Kérlek, a listában felsorolt értékekből válassz!${NORMAL}"
	pause
 esac
}

pause()
{
 read -p "Nyomj ENTER-t a folytatáshoz" fackEnterKey
}

kulcsszo()
{
 rm ./output.html 2>/dev/null
 echo ""
 echo -n "Add meg a kulcsszót, amire keresni szeretnél (angolul): "
 local kulcsszo
 read kulcsszo
 curl --silent  https://collectionapi.metmuseum.org/public/collection/v1/search?q=$kulcsszo -o output.html
 tordeles
}


tordeles()
{
 szamlalo=$(cat output.html | cut -d : -f 2 | cut -d \" -f 1 | tr -d ","":" )
 if [ $szamlalo -gt 5 ]
 then
    szamlalo=5
 fi
 start=1
 for (( c=$start; c<=$szamlalo; c++))
 do
    objectID=$(cat output.html | cut -d : -f 3 | tr -d "["" ]"" }" | cut -d , -f $c)
    curl --silent https://collectionapi.metmuseum.org/public/collection/v1/objects/$objectID -o object.html
    sed -i 's/accessionYear/+/' object.html
    sed -i 's/primaryImage/+/' object.html
    sed -i 's/department/+/' object.html
    sed -i 's/title/+/' object.html
    sed -i 's/artistDisplayName/+/' object.html
    sed -i 's/artistNationality/+/' object.html
    sed -i 's/objectDate/+/' object.html
    sed -i 's/medium/+/' object.html
    bekerulesEve=$(cat object.html | cut -d + -f 2 | cut -d \" -f 3)
    kep=$(cat object.html | cut -d + -f 3 | cut -d \" -f 3)
    department=$(cat object.html | cut -d + -f 4 | cut -d \" -f 3)
    cim=$(cat object.html | cut -d + -f 5 | cut -d \" -f 3)
    alkotoNev=$(cat object.html | cut -d + -f 6 | cut -d \" -f 3)
    nemzetiseg=$(cat object.html | cut -d + -f 7 | cut -d \" -f 3)
    kelte=$(cat object.html | cut -d + -f 8 | cut -d \" -f 3)
    tipus=$(cat object.html | cut -d + -f 9 | cut -d \" -f 3)
cat <<ZZZZZZ
 Alkotás címe:		$cim
 Alkotó:		$alkotoNev
 Alkotó nemzetisége:	$nemzetiseg
 Alkotás keletkezése:	$kelte
 Alkotás típusa:	$tipus
 Kép:			$kep
 Múzeumi osztály:	$department
 Bekerülés ideje:	$bekerulesEve


ZZZZZZ
 pause
 done
}

cim()
{
 rm ./output.html 2>/dev/null
 echo ""
 echo -n "Add meg az alkotás címét, amit keresel (angolul): "
 local cim
 read cim
 curl --silent  https://collectionapi.metmuseum.org/public/collection/v1/search?title=true\&q=$cim  -o output.html
 tordeles
}

alkoto()
{
 rm ./output.html 2>/dev/null
 echo ""
 echo -n "Add meg az alkotó nevét, akinek a műveit keresed: "
 local nev
 read nev
 curl --silent  https://collectionapi.metmuseum.org/public/collection/v1/search?artistOrCulture=true\&q=$nev -o output.html
 tordeles
}



#############################  Főprogram #################################


while true
do
  opciok
  utasitasok
done
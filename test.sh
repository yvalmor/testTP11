#!/bin/bash
# Série de tests pour le TP 11 "Tig isn't Git"
# Yvon Morice - 02/04/2020

start=$(date +%s.%N)

# Colors
    RED='\033[0;31m'
    NC='\033[0m' # No Color
    GREEN='\033[0;32m'


function setup() {
    [[ -d sandbox ]] && rm -r sandbox
    # On compile l'executable afin d'avoir la derniere version
    make > /dev/null 2>&1
    # On se déplace dans le dossier sandbox,
    # si celui-ci n'existe pas, c'est que make a echoue auquel cas on quitte
    cd sandbox || exit > /dev/null 2>&1
    [[ ! -f tig ]] && echo -e "${RED}La compilation a échouée${NC}" && exit
    
    # Variables
    initPercentage=0
    addPercentage=0
    commitPercentage=0
    statusPercentage=0
    logPercentage=0
    
    echo "setup finished"
}


function roundPercentage() {
    [[ "$initPercentage" == 98 ]] && initPercentage=100
    [[ "$addPercentage" == 99 ]] && addPercentage=100
    [[ "$commitPercentage" == 99 ]] && commitPercentage=100
    [[ "$statusPercentage" == 100 ]] && statusPercentage=100
    [[ "$logPercentage" == 100 ]] && logPercentage=100
}


function basicInitTest() {
    # Tests de la fonction init
    mono tig init > initTest.txt
    echo "Initialized empty Tig repository." > comparison.txt
    cmp --silent initTest.txt comparison.txt && initPercentage=$(($initPercentage + 14)) || echo -e "${RED}init n'a pas affiche la bonne string"
    rm initTest.txt comparison.txt
    [[ ! -d .tig ]] && echo -e "${RED}Le dossier .tig/ n'a pas été créé !" || initPercentage=$(($initPercentage + 14))
    [[ ! -d .tig/objects ]] && echo -e "${RED}Le dossier .tig/objects n'a pas été créé !" || initPercentage=$(($initPercentage + 14))
    [[ ! -f .tig/index ]] && echo -e "${RED}Le fichier .tig/index n'a pas été créé !" || initPercentage=$(($initPercentage + 14))
    [[ ! -f .tig/HEAD ]] && echo -e "${RED}Le fichier .tig/index n'a pas été créé !" || initPercentage=$(($initPercentage + 14))
    (find .tig/objects -mindepth 1 | read) && echo -e "${RED}Le dossier .tig/objects devrait être vide !" || initPercentage=$(($initPercentage + 14))
}


function addInitTest() {
    # Tests pour add et init
    mono tig init > /dev/null 2>&1
    echo "bonjour" > test.txt
    mono tig add test.txt
    echo "test.txt c1bf683d 8" > comparison.txt
    cmp --silent .tig/index comparison.txt && addPercentage=$(($addPercentage + 33)) || echo -e "${RED}Add n'ajoute pas la bonne valeur a l'index"
    rm comparison.txt
    [[ ! -f .tig/objects/c1bf683d ]] && echo -e "${RED}Add aurait du rajouter un fichier nommé d'après le hash de l'objet dans .tig/objects" || addPercentage=$(($addPercentage + 33))
    echo "blob 8" > test.txt
    echo "bonjour" >> test.txt
    cmp --silent test.txt .tig/objects/c1bf683d && addPercentage=$(($addPercentage + 33)) || echo -e "${RED}Add n'a pas rempli correctement le fichier correspondant dans .tig/objects"
    rm test.txt
    mono tig init > /dev/null 2>&1
    (find .tig/objects -mindepth 1 | read) && echo -e "${RED}Apres un tig init dans un repo, .tig devrait etre réinitialisé" || initPercentage=$(($initPercentage + 14))
}


function commitTest() {
    #Tests pour commit
    echo "bonjour" > test.txt
    mono tig init > /dev/null 2>&1
    mono tig add test.txt
    mono tig commit test > commit.txt
    echo "559c80ce test" > comparison.txt
    cmp --silent commit.txt comparison.txt && commitPercentage=$(($commitPercentage + 33)) || echo -e "${RED}Le commit n'affiche pas le bon string"
    echo "559c80ce" > comparison.txt
    cmp --silent .tig/HEAD comparison.txt && commitPercentage=$(($commitPercentage + 33)) || echo -e "${RED}Le commit ne modifie pas correctement la reference contenue dans .tig/HEAD"
    echo "commit 74" > comparison.txt
    echo "parent " >> comparison.txt
    echo "tree d84c57ca" >> comparison.txt
    echo "author Joseph Marchand joseph.marchand@epita.fr" >> comparison.txt
    echo -n "test" >> comparison.txt
    cmp --silent .tig/objects/559c80ce comparison.txt && commitPercentage=$(($commitPercentage + 33)) || echo -e "${RED}Le commit ne remplit pas correctement le fichier dans .tig/objects"
    rm comparison.txt commit.txt
}

function statusTest() {
    #Tests pour status
    # test for new file
    mono tig init > /dev/null 2>&1
    mono tig add tig > /dev/null 2>&1
    echo "bonjour" > test.txt
    mono tig status > ../status.txt
    # test for no new file   
    mono tig add test.txt
    mono tig status >> ../status.txt
    # test for modified file
    echo "bujur" > test.txt
    mono tig status >> ../status.txt
    # test for removed file
    rm test.txt
    mono tig status >> ../status.txt
    echo "new: test.txt" > comparison.txt
    echo "modified: test.txt" >> comparison.txt
    echo "deleted: test.txt" >> comparison.txt
    cmp --silent ../status.txt comparison.txt && statusPercentage=$(($statusPercentage + 100)) || echo -e "${RED}Le status n'affiche pas les bons elements"
    rm ../status.txt comparison.txt
}

function logTest() {
    #Tests pour log
    mono tig init > /dev/null 2>&1
    echo "bonjour" > test.txt
    mono tig add test.txt
    mono tig commit test > /dev/null 2>&1
    mono tig log > log.txt
    echo "commit 74" > comparison.txt
    echo "parent " >> comparison.txt
    echo "tree d84c57ca" >> comparison.txt
    echo "author Joseph Marchand joseph.marchand@epita.fr" >> comparison.txt
    echo "test" >> comparison.txt
    cmp --silent log.txt comparison.txt && logPercentage=$(($logPercentage + 100)) || echo -e "${RED}Le log obtenu est incorrect"
    rm log.txt comparison.txt test.txt
}

setup
echo -e "${NC}tests finis à 0%"
basicInitTest
echo -e "${NC}tests finis à 15%"
addInitTest
echo -e "${NC}tests finis à 30%"
commitTest
echo -e "${NC}tests finis à 60%"
statusTest
echo -e "${NC}tests finis à 80%"
logTest
echo -e "${NC}tests finis à 100%"

roundPercentage

echo -e "${GREEN}Init finie a $initPercentage %"
echo -e "Add finie a $addPercentage %"
echo -e "Commit finie a $commitPercentage %"
echo -e "Status finie a $statusPercentage %"
echo -e "Log finie a $logPercentage %${NC}"

rm -r .tig
mkdir .tig
mkdir .tig/objects
touch .tig/index
touch .tig/HEAD

cd ../

duration=$(echo "$(date +%s.%N) - $start" | bc)
execution_time=`printf "%.2f seconds" $duration`

echo "Tests effectués en : $execution_time"

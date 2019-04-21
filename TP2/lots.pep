; ************************************************************************************************
;       Programme: Analyse des LOTS gagnants à la loterie.     version PEP813 sous Linux
;
;        Ce programme analyse les lots gagnants entrés par l'utilisateur.
;        Le programme va demander l'entré d'un maximum de 7 lots
;        allant de 0.0 à 100.0. Lorsque l'utilisateur appuie ENTER,
;        le programme affiche le lot maximum, la moyenne des lots et l'écart-type.
;        Finalement, lorsque l'utilisateur entre seulement ENTER,
;        le programme cesse de demander des lots et affiche le nombre de périodes de tirages,
;        le nombre total de tirages et la moyenne des moyennes des lots gagnants.
;        Le programme affiche donc son message de fin et s'arrête.
;
;       auteur:         Charles Morin
;       code permanent: MORC28019804
;       courriel:       morin.charles.5@courrier.uqam.ca
;       date:           hiver 2019
;       cours:          INF2171
; ************************************************************************************************
;

         STRO    bienvenu,d  ; Affiche le message de bienvenu
         LDA     ESPACE,d
         STA     avCaract,d
         LDX      0,i
         LDA      0,i
         STRO    tiret,d
         STRO    entrer,d    ; Affiche l'invitation à l'utilisateur à rentrer les lots
         CHARI   caract,d    ; Entre un chiffre
         LDBYTEA caract,d         
         CPA     '\n',i      ; Regarde si c'est une fin de ligne
         BREQ    calcFin     ; Si c'est la fin, il vérifie s'il n'y a pas d'autre lots
         BR      continu5
         
boucle:  CHARI   caract,d    ; Entre un chiffre
         LDBYTEA caract,d         
         CPA     '\n',i      ; Regarde si c'est une fin de ligne
         BREQ    verifFin    ; Si c'est la fin, il vérifie s'il n'y a pas d'autre lots
continu5:STA     tempA,d     ; Remet la valeur du chiffre dans le registre A
         LDA     0,i
         STA     estFin,d
         LDA     tempA,d
         BR      ajoutVal    ; Ajoute la valeur au tableau

;
; Ajout de chaque chiffre dans le tableau
;  
ajoutVal:SUBA    48,i        ; Soustrait 48 de la valeur ASCII du caractère pour avoir sa valeur décimal
         CPA     POINT,d     ; Regarde si le caractère entré est un point
         BREQ    estPoint    
         CPA     ESPACE,d    ; Regarde si le caractère entré est un espace
         BREQ    estEspa 
         STA     tempA,d
interval:LDA     0,i         ; Si le chiffre est plus grand ou égale à zéro
if:      CPA     tempA,d         
         BRGT    else        
         LDA     tempA,d     ; Si le chiffre est plus petit ou égale à 9
         CPA     9,i     
         BRGT    else        ; S'il ne répond à aucun des critère il est invalide
then:    BR      add         ; S'il n'est pas valide, il est ajouté au tableau
else:    BR      setInva1    ; Est invalide 
add:     ADDA    tabLots,x   ; Est ajouté au tableau
         STA     tabLots,x   
         LDA     avCaract,d  ; Le contenu du régistre A est le caractère d'avant
         CPA     POINT,d     ; Regarde si le caractère d'avant est un point 
         BREQ    avPoint     ; Le caractère d'avant est un point
         LDA     estDeci,d
         CPA     1,i
         BREQ    setInva1    ; Est invalide 
         LDA     tempA,d
         STA     avCaract,d  ; Remplace le caractère d'avant par celui lu présentement
         BR      multi10     ; Multiplie le contenu du tableau à X par 10

;
; Lorsque le caractère d'avant est un point
;
avPoint: LDA     tempA,d
         STA     avCaract,d  ; Remplace le caractère d'avant par celui lu présentement
         LDA     0,i  
         BR      boucle

;
; Lorsque le caractère d'avant est un espace
;
avEspa:  LDA     0,i
         BR      boucle

;
; Lorsque le caractère lu présentement est un point
;
estPoint:STA     tempA,d
         LDA     avCaract,d  
         CPA     POINT,d     ; Le caractère d'avant est un point
         BREQ    setInva1    ; Est invalide 
         LDA     estDeci,d
         CPA     1,i         ; Le lot a un chiffre à virgule
         BREQ    setInva1    ; Est invalide
         LDA     1,i
         STA     estDeci,d
         LDA     tempA,d
         STA     avCaract,d
         LDA     0,i
         BR      boucle      ; Est un point

;
; Lorsque le caractère lu présentement est un espace
;
estEspa: LDA     avCaract,d  
         CPA     ESPACE,d    ; Le caractère d'avant est un espace
         BREQ    avEspa
         ADDX    2,i
         LDA     ESPACE,d
         STA     avCaract,d  ; Le caractère d'avant est maintenant un espace
         LDA     0,i
         STA     estDeci,d
         BR      boucle      ; Est un espace

;
; Multiplication par 10 du régistre A
;
multi10: LDA     tabLots,x   
         ASLA                ; * 2
         BRV     setInva1    ; Est invalide    
         ASLA                ; * 4
         BRV     setInva1    ; Est invalide
         ADDA    tabLots,x   ; * 5
         BRV     setInva1    ; Est invalide
         ASLA                ; * 10
         BRV     setInva1    ; Est invalide
         CPA     0,i
         BRLT    setPosi
         STA     tabLots,x  
         LDA     0,i
         BR      boucle

;
; Transforme les négatifs en positifs
;
setPosi: NEGA    
         STA     tabLots,x  
         LDA     0,i
         BR      boucle

;
; Fait une division
;
DIVISE:  SUBSP   2,i         ; empilons le diviseur #diviseu
         STX     diviseu,s   
         LDX     diviseu,s   ;
         BREQ    retdiv      ; division par 0 tolérée
         BRLT    zerocalc    ; diviseur négatif retourne 0 comme quotient et comme reste
         CPA     0,i         
         BRLE    zerocalc    ; dividende négatif retourne 0 comme quotient et comme reste
         LDX     0,i         ; initialisation du quotient
soustrai:ADDX    1,i         
         SUBA    diviseu,s   
         BRGE    soustrai    ; soustraction répétitive
         SUBX    1,i         ; redéfaisons la dernière soustraction
         ADDA    diviseu,s   
         BR      retdiv      
zerocalc:LDA     0,i         ; reste = 0
         LDX     0,i         ; quotient = 0
retdiv:  RET2                ; désempilons le diviseur #diviseu

;
; Fait la racine carrée
;
racine:  STA     tempA,d
         STX     tempX,d   
         LDA     1,i         
         LDX     1,i         
         STA     resRacin,d  
tantque: CPX     tempA,d     ; tempA est la valeur dont on veut calculer la racine carré
         BRGT    finttq      
         ADDX    resRacin,d  
         ADDX    resRacin,d  
         ADDX    1,i         ; x <- 2 * résultat + 1
         ADDA    1,i         
         STA     resRacin,d  
         BR      tantque     
finttq:  SUBA    1,i         ; 1 fois en trop
         STA     resRacin,d  ; racine carrée   
         RET0      

;
; Calcule a la puissance 2
;
carre:   LDX     1,i
         STA     base,d
         STA     resCarre,d
         CPA     -1,i
         BRLE    estNegat
         CPA     0,i
         BREQ    finCarre
         BR      ajoutBas
estNegat:NEGA
         STA     base,d
         STA     resCarre,d
ajoutBas:ADDA    base,d
         STA     resCarre,d
         ADDX    1,i
         CPX     base,d
         BRLT    ajoutBas
finCarre:RET0

;
; Calcul l'écart-type
;
ecartLot:LDA     nbTirage,d  ; Pour avoir le nombre de tirage x2
         SUBA    1,i         ;
         ASLA                ;
         STA     tempX,d     ;
         LDX     tempX,d     ;
for4:    LDA     tabLots,x
         SUBA    lotMoy,d    ; Soustrait le lot du tableau avec la moyenne
         CALL    carre       ; Fait le résultat au carré
         BRV     invalEca
         ADDA    ecart,d     ; Ajoute le résultat du carré à la somme pour calculer l'écart-type
         STA     ecart,d     ;
         BRV     invalEca
         LDX     tempX,d
         CPX     0,i         ; Regarde si tous les lots ont été mis à la deux et ajouté
         BREQ    divEcart    ; Si oui, nous allons faire la division
         SUBX    2,i
         STX     tempX,d
         BR      for4        ; Si non, nous recommençons
divEcart:LDA     ecart,d
         STA     dividend,d
         LDX     nbTirage,d
         STX     diviseur,d
         CALL    DIVISE      ; Fait la division pour calculer l'écart-type
         STX     quotient,d
         STA     reste,d
         LDA     quotient,d
         CALL    racine
         BRV     invalEca
         STA     quotient,d
         CALL    affiDeci
         RET0

;
; Lorsqu'il y a un débordement dans le calcul de l'écart-type
;
invalEca:STRO    errEcart,d
         BR      continu6

;
; Trouve le lot maximum, le nombre de lot et fait la somme pour la moyenne
;
verifFin:STA     tempA,d     ; Regarde si le programme est terminé
         LDA     estFin,d    
         CPA     1,i         
         BREQ    calcFin     ; Le programme est terminé
         LDA     1,i         
         STA     estFin,d    ; Indique que la prochaine fois le programme devra prendre fin
lireTab: LDA     avCaract,d  ; Si le dernier caractère est un espace, nous l'annulons
         CPA     ESPACE,d       
         BREQ    annulFin    ; Est un espace
continu: CPX     12,i        ; Regarde si il y a plus de 7 lots
         BRGT    invalide    
         STX     tempX,d     
         ASRX    
         ADDX    1,i         
         STX     nbTirage,d  ; Indique le nobre de tirage
         CPX     0,i         
         BREQ    setInva2    
continu2:LDX     tempX,d     
         LDA     tabLots,x   
         STA     lotMax,d    ; Indique le premier lot comme étant le lot maximum de départ
for:     CALL    checkMax    ; Vérifie que le lot ne dépasse pas 100
         CALL    verifMax    ; Vérifie si le lot présent est supérieur au lot maximum
         CALL    addSomme    ; Ajoute un lot à la somme de lot
         SUBX    2,i         ; Diminue le compteur du tableau
         CPX     0,i         
         BRGE    for         ; Vérifie si le programme a lu tout le tableau
         BR      calcLot     ; Lis la prochaine case du tableau

;
; Annule les espaces en trop à la fin
;
annulFin:SUBX 2,i            
         BR continu          

;
; Vérifie que les lots ne dépassent pas 100
;
checkMax:STA     tempA,d     
         LDA     tabLots,x   
         CPA     1000,i      
         BRGT    invalide    ; Est invalide
         RET0

;
; Vérifie si le lot présent est supérieur au lot maximum
;
verifMax:CPA     lotMax,d    
         BRGE    setMax      
         RET0

;
; Indique le lot maximum
;
setMax:  LDA     tabLots,x   
         STA     lotMax,d    
         RET0

;
; Ajoute un lot à la somme de lot
;
addSomme:LDA     tabLots,x   
         ADDA    somme,d     
         STA     somme,d     
         RET0

;
; Calcul la moyenne des moyennes
;
moyenTot:LDA     sommeMoy,d  ; Prend la somme de tous les moyenne et la met dans le registre A
         LDX     nbPerTir,d  
         STA     dividend,d  
         STX     diviseur,d  
         CALL    DIVISE      ; Divise la somme des moyennes avec le nombre total de periode de tirage
         STX     quotient,d  
         STA     reste,d     
         ASLA    
         CPA     4,i         
         BRGE    callArro    ; Arrondit la moyenne
         CALL    affiDeci    ; Affiche le résultat en décimal
         RET0

;
; Calcul la moyenne des lots d'une période
;
moyenLot:STA     tempA,d     
         STX     tempX,d     
         LDA     somme,d     
         LDX     nbTirage,d  
         STA     dividend,d  
         STX     diviseur,d  
         CALL    DIVISE      ; Divise la somme des lots avec le nombre de lot
         STX     quotient,d  
         STA     reste,d              
         ASLA
         CPA     4,i         
         BRGE    callArro    ; Arrondit la moyenne
continu3:LDA     quotient,d
         STA     lotMoy,d
         LDA     sommeMoy,d  ; Ajoute la moyenne de ce tirage au total des moyennes
         ADDA    lotMoy,d      
         STA     sommeMoy,d
continu4:CALL    affiDeci    ; Affiche le résultat en décimal 
         RET0

;
; Appel le sous programme arrondir
;
callArro:CALL    arrondir
         BR      continu3

;
; Arrondit le chiffre si besoin
;
arrondir:LDA     quotient,d  
         ADDA    1,i         
         STA     quotient,d  
         RET0

;
; Affiche un chiffre en décimal
;
affiDeci:LDA     quotient,d  
         STA     dividend,d  
         LDA     10,i        
         STA     diviseur,d  
         LDA     dividend,d  
         LDX     diviseur,d  
         CALL    DIVISE      
         STX     quotient,d  
         DECO    quotient,d  
         STA     reste,d     
         CHARO   '.',i       
         DECO    reste,d     
         RET0

;
; Calcul les résultats par période
;
calcLot: LDA     estInval,d  
         CPA     1,i         
         BREQ    invalide    ; Si le flag estInval est égale à 1, le programme affiche invalide

         STRO    NBTIRAGE,d  
         DECO    nbTirage,d  ; Affiche le nombre de tirages
         CHARO   '\n',i      

         LDA     nbTotTir,d  
         ADDA    nbTirage,d  
         STA     nbTotTir,d  

         STRO    LOTMAX,d    
         STA     tempA,d     
         STX     tempX,d     
         LDA     lotMax,d    
         STA     quotient,d  
         CALL    affiDeci    ; Affiche le lot maximum

         CHARO   ' ',i       
         STRO    LOTMOY,d    
         CALL    moyenLot    ; Affiche la moyenne des lots

         CHARO   ' ',i       
         STRO    ECART,d     
         CALL    ecartLot    ; Calcul et affiche l'écart-type
         
continu6:CALL    viderTab    ; Vide le tableau de lot
         CHARO   '\n',i      
         STRO    tiret,d     
         STRO    entrer,d    
         LDA     ESPACE,d       
         STA     avCaract,d  
         LDA     nbPerTir,d  
         ADDA    1,i         
         STA     nbPerTir,d  
         LDX     0,i         ; Réinitialise les variables à zéro
         LDA     0,i         ;
         STA     lotMax,d    ;
         STA     lotMoy,d    ;
         STA     somme,d     ;
         STA     ecart,d     ;
         STA     resCarre,d  ;
         STA     resRacin,d  ;
         STA     base,d      ;
         STA     estInval,d  ;
         STA     estDeci,d   ;
         BR      boucle      

;
; Calcul les totaux
;
calcFin: STRO    NBPERTIR,d  
         DECO    nbPerTir,d  ; Affiche le nombre de période de tirage
         CHARO   '\n',i      
         STRO    NBTOTTIR,d  
         DECO    nbTotTir,d  ; Affiche le nombre total de tirage
         CHARO   '\n',i      
         STRO    MOYTOTAL,d  
         CALL    moyenTot    ; Affiche la moyenne des moyennes
         CHARO   '\n',i      
         BR      termine     

;
; Dit au programme qu'ìl y a une entrée invalide
;
setInva1:LDA     1,i         ; Est invalide
         STA     estInval,d  
         LDA     0,i         
         BR      boucle      

;
; Dit au programme qu'ìl y a une entrée invalide
;
setInva2:LDA     1,i         ; Est invalide
         STA     estInval,d  
         LDA     0,i         
         BR      continu2  

;
; Lorsqu'il y a une entrée invalide
;
invalide:STRO    erreur,d    ; Affiche le message d'erreur
for2:    STA     tempA,d     
         LDA     0,i         
         STA     tabLots,x   
         LDA     tempA,d     
         SUBX    2,i         
         CPX     0,i         
         BRGE    for2        
         LDX     0,i         
         LDA     ESPACE,d       
         STA     avCaract,d  
         LDA     0,i         ; Réinitialise les variables à zéro
         STA     lotMax,d    ;
         STA     lotMoy,d    ;
         STA     somme,d     ;
         STA     estDeci,d   ;
         STA     estInval,d  ;
         STA     ecart,d     ;
         STA     resCarre,d  ;
         STA     resRacin,d  ;
         STA     base,d      ;
         STRO    tiret,d     
         STRO    entrer,d    
         BR      boucle      

;
; Vide le tableau
;
viderTab:LDA     nbTirage,d
         SUBA    1,i
         ASLA    
         STA     nbTirage,d
         LDX     nbTirage,d
for3:    LDA     0,i         
         STA     tabLots,x   ; Vide le tableau à la case suivante  
         SUBX    2,i         ; Augmente le compteur du tableau
         CPX     0,i         
         BRGE    for3        ; Vérifie si le programme a lu tout le tableau
         RET0

;
; Fin du programme
;     
termine: STRO    aurevoir,d 
         STOP

;
; Résultats par période
;
nbTirage:.BLOCK  2
lotMax:  .BLOCK  2
lotMoy:  .BLOCK  2
ecart:   .BLOCK  2

;
; Totaux
;
nbPerTir:.BLOCK  2
nbTotTir:.BLOCK  2
moyTotal:.BLOCK  2

;
; Variables
;
diviseu: .EQUATE 0
dividend:.BLOCK  2           
diviseur:.BLOCK  2           
quotient:.BLOCK  2           
reste:   .BLOCK  2  
estFin:  .BLOCK  2         
tempA:   .BLOCK  2
tempX:   .BLOCK  2
somme:   .BLOCK  2
sommeMoy:.BLOCK  2
caract:  .BLOCK  2
avCaract:.BLOCK  2
estDeci: .BLOCK  2
estInval:.BLOCK  2
resRacin:.BLOCK  2
resCarre:.BLOCK  2
base:    .BLOCK  2
tabLots: .BLOCK  12

;
; Constantes
;
POINT:   .WORD   -2
ESPACE:  .WORD   -16

;
; Messages
;
bienvenu:.ASCII  "Bienvenu dans le programme d'analyse de lots gagnants!\nLe programme va demander l'entré d'un maximum de 7 lots\nallant de 0.0 à 100.0. Ensuite, lorsque l'utilisateur appuie ENTER,\nle programme affiche le lot maximum, la moyenne des lots et l'écart-type.\nFinalement, lorsque l'utilisateur entre seulement ENTER,\nle programme cesse de demander des lots et affiche le nombre de périodes de tirages,\nle nombre total de tirages et la moyenne des moyennes des lots gagnants.\nLe programme affiche donc son message de fin et s'arrête.\n\n\x00"
entrer:  .ASCII  "Entrez les montants des lots gagnants:\n\x00"
aurevoir:.ASCII  "\nMerci, à la prochaine!\x00"
message: .ASCII  "\nLe code de validation est \x00"
tiret:   .ASCII  "-------------------------------------------------------------------------\n\x00"
erreur:  .ASCII  "Entrée invalide\n\x00"
errEcart:.ASCII  "nd\x00"
deborde: .ASCII  "Erreur débordement\n\x00"

NBTIRAGE:.ASCII  "Nombre de tirages: \x00"
LOTMAX:  .ASCII  "Lot maximum: \x00"
LOTMOY:  .ASCII  "Moyenne des lots: \x00"
ECART:   .ASCII  "Ecart: \x00"

NBPERTIR:.ASCII  "Nombre de périodes de tirages: \x00"
NBTOTTIR:.ASCII  "Nombre total de tirages: \x00"
MOYTOTAL:.ASCII  "Moyenne des moyennes des lots gagnants: \x00"
         .END                  

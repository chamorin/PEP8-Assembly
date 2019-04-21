; ************************************************************************************************
;       Programme: Remise en ordre de chaînes de caractères.     version PEP813 sous Linux
;
;        Suite à une demande à l'utilisateur,le programme affiche en ordre 
;        ASCII croissant les chaînes des caractères entrées.
;
;       auteur:         Charles Morin
;       code permanent: MORC28019804
;       courriel:       morin.charles.5@courrier.uqam.ca
;       date:           hiver 2019
;       cours:          INF2171
; ************************************************************************************************
;
;                            ; // Lit la liste (Ã  l'envers)

         STRO    bienvenu,d
         STRO    message,d
         STRO    entrer,d     

;
; Lecture initial d'un caractère
;
begin:   LDA     mLength,i   
         CHARI   mVal,d
         LDBYTEA mVal,d      ; Regarde si le caractère entré est un ENTER
         CPA     ' ',i
         BREQ    begin
         CALL    new         ;   X = new Maillon(); #mVal #mNext   
         CHARO   '-',i       
         CHARO   '>',i       
         CHARO   ' ',i               
         LDA     0,i
         LDBYTEA mVal,d
         STBYTEA mVal,x      ; Range mVal dans le tableau à la position X
         CPA     '\n',i      ; Regarde si le caractère entré est un ENTER   
         BREQ    end         ; Si le caractère est un ENTER seul le programme termine
         STA     avCaract,d  ; Range le caractère entré dans avCaract
         LDA     head,d      
         STA     mNext,x     ;   X.next = head;
         STX     head,d      ;   head = X;
         LDA     cpt,d       ; Ajoute 1 au compteur de chaine 
         ADDA    1,i         ;
         STA     cpt,d       ;
         STA     nbCaract,d  ; Ajoute 1 au compteur de caractère 

;
; Lecture des caractères
;
loop_in: LDA     avCaract,d  ; Regarde si le avCaract est un espace
         CPA     ' ',i       ;
         BREQ    avEspace    ;
         LDA     nbCaract,d
         ADDA    1,i         ; Ajoute 1 au compteur de caractère 
         STA     nbCaract,d  ;
         LDA     mLength,i   
         CHARI   mVal,d
         LDBYTEA mVal,d      ; Regarde si le caractère entré est un ENTER
         CPA     '\n',i      ;
         BREQ    setNbCh     ; Si oui va aux étape de trie
         ADDX    1,i
         STBYTEA mVal,x      ; Range le BYTE un index plus loin que le précédent
         STA     avCaract,d  ; Range le caractère entré dans avCaract
         BR      loop_in     ; } // fin for

;
; Création de nouveaux maillons
;
avEspace:LDA     nbCaract,d  ; Ajoute au compteur de caractère
         ADDA    1,i         ;
         STA     nbCaract,d  ;
         CHARI   mVal,d
         LDBYTEA mVal,d      ; Regarde si le caractère entré est un ENTER
         CPA     '\n',i      ;
         BREQ    setNbCh     ; Si oui va aux étape de trie
         CPA     ' ',i       ; Si c'est un espace
         BREQ    addTo       ; Ajoute dans le maillon courrant 
         LDA     mLength,i   
         CALL    new         ;   X = new Maillon(); #mVal #mNext
         LDA     cpt,d       ; Ajoute 1 au compteur de chaine 
         ADDA    1,i         ;
         STA     cpt,d       ;
         LDA     0,i
         LDBYTEA mVal,d
         STA     avCaract,d  ; Range le caractère entré dans avCaract
         STBYTEA mVal,x      ; Range mVal dans le tableau à la position X
         LDA     head,d      
         STA     mNext,x     ;   X.next = head;
         STX     head,d      ;   head = X;
         BR      loop_in 

;
; Ajout aux maillons existant
;
addTo:   LDBYTEA mVal,d      ; Ajouter au maillon present  
         STA     mVal,x
         STBYTEA mVal,x      ; Range mVal dans le tableau à la position X
         STA     avCaract,d  ; Range le caractère entré dans avCaract
         ADDX    1,i
         LDA     nbCaract,d  ; Ajoute 1 au compteur de caractère 
         ADDA    1,i         ;
         STA     nbCaract,d  ;
         BR      loop_in     ; } // fin for

;
; Trouve le plus petit maillon
;    
setNbCh: LDA     cpt,d       ; Indique le nombre de chaine
         STA     nbChaine,d  ;
findMin: LDA     nbCaract,d
         CPA     28,i        ; Si il y a plus que 26 caractère
         BRGE    setInval    ; L'entré est invalide
continu: LDX     head,d      
         STX     minAddr,d   ; Le dernier maillon est le plus petit maillon initial 
         LDBYTEA mVal,x      ;
         STA     minVal,d    ; 
loop_out:CPX     0,i         
         BREQ    out         ; for (X=head; X!=null; X=X.next) {
         LDBYTEA mVal,x
         CPA     minVal,d
         BREQ    checkNex
         CPA     minVal,d
         BRLE    setMin      ; Si le maillon évalué est plus petit que le maillon minimum
         LDX     mNext,x     
         BR      loop_out    ; } // fin for

;
; Si les deux maillons à comparer commence par la même valeur
;
checkNex:STX     tempX,d 
         STA     tempA,d
         STX     tAddMai,d   ; Range l'adresse du maillon courrant
         LDBYTEA mVal,x
         STA     tValMai,d   ; Range la valeur du maillon courrant
         LDX     minAddr,d   
         STX     tAddMin,d   ; Range l'adresse du plus petit maillon
         LDA     minVal,d    
         STA     tValMin,d   ; Range la valeur du plus petit maillon
while2:  LDX     tAddMin,d
         ADDX    1,i
         STX     tAddMin,d   
         LDBYTEA mVal,x
         STA     tValMin,d   
         LDX     tAddMai,d
         ADDX    1,i
         STX     tAddMai,d   
         LDBYTEA mVal,x
         STA     tValMai,d 
         CPA     tValMin,d
         BRLT    setMin2
         CPA     tValMin,d
         BRGT    setMin3 
         CPA     ' ',i
         BREQ    setMin2
         CPA     0x00,i
         BREQ    setMin2
         CPA     tValMin,d
         BREQ    while2

;
; Maillon courrant est plus petit que le minimum
;
setMin2: LDX     tempX,d
         STX     minAddr,d   ;
         LDBYTEA mVal,x
         STA     minVal,d
         LDX     mNext,x
         BR      loop_out

;
; Maillon minimum est plus petit que le courrant
;
setMin3: LDA     minVal,d
         LDX     tempX,d  
         LDX     mNext,x
         BR      loop_out

;
; Indique le plus petit maillon
;
setMin:  STA     minVal,d    ; On change le maillon minimum
         STX     minAddr,d   ;
         LDX     mNext,x     
         BR      loop_out

;
; Affiche le plus petit maillon
;
out:     LDA     cpt,d       
         SUBA    1,i
         STA     cpt,d
         LDA     isInval,d
if:      CPA     1,i         ; Si l'entré est invalide
         BREQ    and         ; évite l'affichage
         BR      else
and:     LDA     cpt,d       ; Sinon regarde si le compteur est à zero
         CPA     0,i
         BREQ    invalide    ; Affiche le message d'erreur
else:    LDA     isInval,d
         CPA     1,i         ; Si l'entré est invalide
         BREQ    invalMin    ; évite l'affichage

         LDX     minAddr,d   ; Affiche la chaine complete   
while:   LDBYTEA mVal,x      ;
         STA     minVal,d    ;
         CPA     ' ',i       ;
         BREQ    continu3    ;
         CPA     0x00,i      ;
         BREQ    continu3    ;
         CHARO   minVal2,d   ;
         ADDX    1,i         ;
         BR      while       ;

continu3:LDX     minAddr,d
         LDBYTEA 0xFF,i      ; Remplace la chaine par 0xFF 
         STBYTEA mVal,x      ;
         LDA     cpt,d
         CPA     0,i         ; Si c'est le dernier caractère n'affiche pas la flèche
         BREQ    continu2
         CHARO   ' ',i       ; Affiche la flèche
         CHARO   '-',i       ;
         CHARO   '>',i       ;
         CHARO   ' ',i       ;
continu2:LDA     cpt,d
         CPA     0,i
         BRGT    findMin
         CALL    reset
         LDA     mLength,i 
         CHARO   '\n',i
         STRO    entrer,d
         BR      begin       ; Retourne au début

;
; Remplace la chaine par 0xFF lorsque c'est invalide
;
invalMin:LDX     minAddr,d
         LDBYTEA 0xFF,i      ; Remplace la chaine par 0xFF 
         STBYTEA mVal,x
         BR      continu

;
; Indique que l'entrée est invalide
;
setInval:LDA     1,i
         STA     isInval,d
         BR      continu

;
; Affiche le message d'erreur
;
invalide:LDX     minAddr,d
         LDBYTEA 0xFF,i      ; Remplace la chaine par 0xFF 
         STBYTEA mVal,x
         STRO    erreur,d 
         CALL    reset
         LDA     mLength,i   
         STRO    entrer,d  
         BR      begin

;
; Réinitialise toutes les variables
;  
reset:   LDA     0,i
         LDX     0,i
         STA     isInval,d
         STA     nbCaract,d
         STA     cpt,d
         STA     minVal,d
         STA     minVal2,d
         STA     minAddr,d
         STA     nbChaine,d
         RET0
         
end:     STRO    aurevoir,d
         STOP                

;
; Variables
;
head:    .BLOCK  2           ; #2h tête de liste (null (aka 0) si liste vide)
minVal:  .BLOCK  1           ; #1h 
minVal2: .BLOCK  1           ; #1h
minAddr: .BLOCK  2           ; #2h     
cpt:     .BLOCK  2           ; #2d compteur de boucle
avCaract:.BLOCK  2
isInval: .BLOCK  2           ; #2d
nbCaract:.BLOCK  2           ; #2d
nbChaine:.BLOCK  2           ; #2d
tempA:   .BLOCK  2
tempX:   .BLOCK  2
tAddMin: .BLOCK  2           ; #2h
tAddMai: .BLOCK  2           ; #2h
tValMin: .BLOCK  2           ; #2d
tValMai: .BLOCK  2           ; #2d
isEnd:   .BLOCK  2

;
; Messages
;
bienvenu:.ASCII  "Bienvenu dans le programme de chaine.\n\n\x00"
entrer:  .ASCII  "Entrez une ou plusieurs chaînes:\n\x00"
aurevoir:.ASCII  "\nMerci, à la prochaine!\x00"
message: .ASCII  "Ce programme accepte une valeur d'entrée de l'utilisateur\npouvant aller jusqu'à 26 caractères.\nLe programme affiche alors les chaînes,\nséparées par un ou plusieurs espaces, dans leur ordre croissant de valeur.\nPour terminer le programme, l'utilisateur n'a\nqu'à entrer un ENTER seul.\n\n\x00"
erreur:  .ASCII  "Entrée invalide\n\x00"

;
;******* Structure de liste d'entiers
; Une liste est constituée d'une chaîne de maillons.
; Chaque maillon contient une valeur et l'adresse du maillon suivant
; La fin de la liste est marquée arbitrairement par l'adresse 0
mVal:    .EQUATE 0          ; #1h26a valeur de l'élément dans le maillon
mNext:   .EQUATE 26         ; #2h maillon suivant (null (aka 0) pour fin de liste)
mLength: .EQUATE 28         ; taille d'un maillon en octets
;
;
;******* operator new
;        Precondition: A contains number of bytes
;        Postcondition: X contains pointer to bytes
new:     LDX     hpPtr,d     ;returned pointer
         ADDA    hpPtr,d     ;allocate from heap
         STA     hpPtr,d     ;update hpPtr
         RET0                
hpPtr:   .ADDRSS heap        ;address of next free byte
heap:    .BLOCK  2           ;first byte in the heap

         .END                  

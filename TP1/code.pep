; ************************************************************************************************
;       Programme: Le CODE de validation     version PEP813 sous Linux
;
;       Ce programme affiche un pointage pour des noms de familles.
;
;       auteur:        Charles Morin
;       code permanent: MORC28019804
;       courriel:       morin.charles.5@courrier.uqam.ca
;       date:           hiver 2019
;       cours:          INF2171
; ************************************************************************************************
;
         STRO    bienvenu,d  

;
; boucle qui va lire chacun des caractères
;
boucle:  CHARI   lettre,d    ; prend une lettre en entrée
         LDBYTEA lettre,d    ; charge la lettre dans le régistre A
         CPA     '\n',i      ; compare le régistre A avec un line feed
         BREQ    resultat    ; si la lettre est un line feed, on calcule la valeur du nom
         STA     temp,d      ; store le contenu du régistre A dans temp
         LDX     codeVal,d   ; charge le codeVal dans le régistre X

;
; si c'est une minuscule
;
ifMin:   CPA     minMin,i    ; regarde si la lettre est minuscule
         BRLT    elseMin     
         CPA     maxMin,i    ; regarde si la lettre est minuscule
         BRGT    elseMin     
         SUBX    32,i        ; met la lettre minuscule en majuscule
         SUBX    64,i        ; donne la valeur de la lettre selon son ordre dans l'alphabet
         STA     temp2,d     
         BR      storeVal    
elseMin: BR      ifMaj       ; n'est pas minuscule

;
; si c'est une majuscule
;
ifMaj:   CPA     minMaj,i    ; regarde si la lettre est majuscule
         BRLT    elseMaj     
         CPA     maxMaj,i    ; regarde si la lettre est majuscule
         BRGT    elseMaj     
         SUBX    64,i        ; donne la valeur de la lettre selon son ordre dans l'alphabet
         STA     temp2,d     
         BR      storeVal    
elseMaj: BR      ifTir       ; n'est pas majuscule

;
; si c'est un tiret
;
ifTir:   CPA     45,i        ; regarde si il s'agit d'un tiret
         BRNE    elseTir     
         SUBX    18,i        ; donne le pointage voulu au tiret
         STA     temp2,d     
         LDA     lettreAv,d  
         CPA     '-',i       ; regarde si le caractère avant est un tiret
         BREQ    mauvais     ; si oui va dans mauvais
         CPA     '\'',i      ; regarde si le caractère avant est un apostrophe
         BREQ    mauvais     ; si oui va dans mauvais
         BR      storeVal    
elseTir: BR      ifApo       ; n'est pas un tiret

;
; si c'est un apostrophe
;
ifApo:   CPA     39,i        ; regarde si il s'agit d'un apostrophe
         BRNE    elseApo     
         SUBX    11,i        ; donne le pointage voulu à l'apostrophe
         STA     temp2,d     
         LDA     lettreAv,d  
         CPA     '-',i       ; regarde si le caractère avant est un tiret
         BREQ    mauvais     ; si oui va dans mauvais
         CPA     '\'',i      ; regarde si le caractère avant est un apostrophe
         BREQ    mauvais     ; si oui va dans mauvais
         BR      storeVal    
elseApo: BR      ifEsp       ; n'est pas un apostrophe

;
; si c'est un espace
;
ifEsp:   CPA     32,i        ; regarde si il s'agit d'un espace
         BRNE    elseEsp     
         SUBX    32,i        ; enleve le pointage de l'espace
         STA     temp2,d     
         LDA     lettreAv,d 
         BR      storeEsp    
elseEsp: LDA     -1,i        ; est invalide
         STA     verif,d     
         LDA     temp2,d     
         BR      skipVal     

mauvais: LDA     -1,i        
         STA     verif,d     ; attribue -1 à verif pour signaler une entrée invalide
         BR      storeVal    

mauvais2:LDA     -1,i        
         STA     verif,d     ; attribue -1 à verif pour signaler une entrée invalide
         BR      verifFin    

;
; si se sont des voyelles, on double les points
;
ifA:     ADDX    1,i         
         BR      continue    
ifE:     ADDX    5,i         
         BR      continue    
ifI:     ADDX    9,i         
         BR      continue    
ifO:     ADDX    15,i        
         BR      continue    
ifU:     ADDX    21,i        
         BR      continue    
ifY:     ADDX    25,i        
         BR      continue    

;
; ajoute la valeur du caractère au résultat final
;
storeVal:LDA     temp2,d     
         ADDX    temp,d      ; ajoute temp dans le régistre X (codeVal + temp)
         CPA     97,i        ; verifie si la lettre est un a
         BREQ    ifA         
         CPA     65,i        ; verifie si la lettre est un A
         BREQ    ifA         
         CPA     101,i       ; verifie si la lettre est un e
         BREQ    ifE         
         CPA     69,i        ; verifie si la lettre est un E
         BREQ    ifE         
         CPA     105,i       ; verifie si la lettre est un i
         BREQ    ifI         
         CPA     73,i        ; verifie si la lettre est un I
         BREQ    ifI         
         CPA     111,i       ; verifie si la lettre est un o
         BREQ    ifO         
         CPA     79,i        ; verifie si la lettre est un O
         BREQ    ifO         
         CPA     117,i       ; verifie si la lettre est un u
         BREQ    ifU         
         CPA     85,i        ; verifie si la lettre est un U
         BREQ    ifU         
         CPA     121,i       ; verifie si la lettre est un y
         BREQ    ifY         
         CPA     89,i        ; verifie si la lettre est un Y
         BREQ    ifY         
continue:STX     codeVal,d   ; store le contenu du régistre X dans codeVal
skipVal: LDX     1,i         ; déplace 1 dans le régistre X
         STA     lettreAv,d  
         BR      boucle      ; recommence pour la prochaine lettre

;
; éviter des étapes lorsque c'est un espace
;
storeEsp:LDA     temp2,d     
         ADDX    temp,d      ; ajoute temp dans le régistre X (codeVal + temp)
         STX     codeVal,d   ; store le contenu du régistre X dans codeVal
         LDX     1,i         ; déplace 1 dans le régistre X
         BR      boucle      ; recommence pour la prochaine lettre

;
; trouve le modulo 10 du pointage total 
;
modulo2: ADDA    10,i        
         STA     codeVal,d   
         BR      afficher    
modulo:  SUBA    10,i        
         CPA     0,i         
         BRLT    modulo2     
         BR      modulo      

;
; créer le résultat final
;
resultat:CPX     0,i         ; compare le régistre X à 0
         BREQ    termine     ; si le régistre X est égale à 0 va à termine
         STA     temp2,d     
         LDA     lettreAv,d  ; regarde si la lettre avant la fin de ligne est valide
         CPA     '-',i       ; si c'est un tiret, c'est invalide
         BREQ    mauvais2    
         CPA     '\'',i      ; si c'est un apostrophe, c'est invalide
         BREQ    mauvais2    
verifFin:LDA     verif,d     
         CPA     -1,i        
         BREQ    invalide    
         LDA     codeVal,d   
         CPA     0,i         
         BREQ    invalide    
         BR      modulo      

;
; affiche le pointage final du nom et remet les valeurs des régistre et variables à zéro
;
afficher:STRO    message,d   ; affiche le message pour le code de validation
         DECO    codeVal,d   ; affiche le code de validation
         CHARO   '.',i       ; affiche un point
         CHARO   '\n',i      ; affiche un line feed
         STRO    tiret,d     
         LDA     '-',i       
         STA     lettreAv,d  
         LDX     0,i         ; charge 0 dans le régistre X
         LDA     0,i         
         STA     temp2,d
         STX     codeVal,d   
         STRO    entrer,d    
         BR      boucle      ; mot termine, va au prochain

;
; si la vérif indique une entrée invalide, le programme vient ici
;
invalide:STRO    erreur,d    ; affiche le message d'erreur
         STRO    tiret,d     
         LDA     '-',i       
         STA     lettreAv,d  
         LDX     0,i         ; charge 0 dans le régistre X
         LDA     0,i
         STA     temp2,d     
         STA     verif,d     
         STX     codeVal,d   
         STRO    entrer,d    
         BR      boucle      ; mot termine, va au prochain

;
; fin du programme et affichage du message d'aurevoir
;
termine: STRO    aurevoir,d  
         STOP 
      
lettre:  .BLOCK  2           
lettreAv:.WORD   '-'         
bienvenu:.ASCII  "Bienvenu dans le programme de nom de famille!\nLe programme va additionner chacune des positions\ndes lettres dans l'alphabet contenue dans le nom de famille\npour ensuite appliquer un modulo 10 au résultat.\nAinsi, vous pourrez donc voir le pointage du nom entré.\nPour quitter le programme entrez ENTER.\n\nVeuillez entrer un nom de famille: \x00"
entrer:  .ASCII  "Veuillez entrer un nom de famille: \x00"
aurevoir:.ASCII  "\nMerci, à la prochaine!\x00"
message: .ASCII  "\nLe code de validation est \x00"
tiret:   .ASCII  "-------------------------------------------------------------------------\n\x00"
erreur:  .ASCII  "\nEntrée invalide\n\x00"
codeVal: .BLOCK  2           
temp:    .BLOCK  2           
temp2:   .BLOCK  2       
verif:   .BLOCK  2           
minMin:  .EQUATE 97          
maxMin:  .EQUATE 122         
minMaj:  .EQUATE 65          
maxMaj:  .EQUATE 90          
         .END                  

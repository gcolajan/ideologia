// Affichage du pseudo
function affichage_pseudo(joueur, pseudo) {
	document.getElementById('joueur_pseudo'+joueur).innerHTML = pseudo
}


// Affichage des idéologies (couleur et title)
function affichage_ideologie(joueur, ideologie) {
	document.getElementById('jj'+joueur).style.background = couleurs[ideologie-1]
	document.getElementById('jj'+joueur).title = ideologies[ideologie-1]
}


// Réglage des niveaux des jauges (idéal)
function affichage_niveauIdeal(jauge, niveau) {
	document.getElementById('ideal'+jauge).style.backgroundPosition = '0 '+niveau+'%'
}


// Déplacement d'un pion sur le plateau
function affichage_pion(position, joueurs) {

	element = 'case_s'+position;
	if (position == 0)
		element = 'case0';
		
	casePos = document.getElementById(element)
	
	fondCase = "fond_case.png"
	if (position == 0)
		fondCase = "case_depart.png"
	else if (chercherTerritoire(position) == -1)
		fondCase = "case_evenement.png"

	if (joueurs == -1) {
		casePos.style.backgroundImage = "url('/assets/"+fondCase+"')"
		casePos.style.backgroundPosition = "center"
	}
	else {
		j0I = "url('/assets/pions/p1.png')"
		j0P = "left top"
		j1I = "url('/assets/pions/p2.png')"
		j1P = "right top"
		j2I = "url('/assets/pions/p3.png')"
		j2P = "left bottom"
		j3I = "url('/assets/pions/p4.png')"
		j3P = "right bottom"
		
		bi = ""
		bp = ""
		
		for (var it = 0 ; it < joueurs.length ; it++)
		{
			switch (joueurs[it]) {
				case 0:
					bi += j0I+", "
					bp += j0P+", "
				break;
				case 1:
					bi += j1I+", "
					bp += j1P+", "				
				break;
				case 2:
					bi += j2I+", "
					bp += j2P+", "
				break;
				case 3:
					bi += j3I+", "
					bp += j3P+", "
				break;
			}
			
			bp
		}
		
		casePos.style.backgroundImage = bi+"url('/assets/"+fondCase+"')"
		casePos.style.backgroundPosition = bp+"center"
		casePos.style.backgroundRepeat = "no-repeat"
	}
}


// Mise à jour des fonds possédés par le joueur
function affichage_fonds(fonds) {
	document.getElementById('synthese_fonds').innerHTML = fonds+" $"
}


// Affichage du niveau actuel de la jauge (+ affichages secondaires)
function affichage_jauge(jauge, niveau) {
	document.getElementById('niveau'+jauge).style.backgroundPosition = '0 '+niveau+'%'
	document.getElementById('indicateur'+jauge).style.height = (100-niveau)+'%'
	document.getElementById('label_jauge'+jauge).innerHTML = niveau+'%'
	document.getElementById('ecart_jauge'+jauge).innerHTML = 'Δ '+Math.abs(niveau-ep_niveauIdeals[jauge])+'pts'
}


// Affichage du nombre de territoires possédés
function affichage_nbTerritoires(nb) {
	s = ''
	if (nb > 1) s = 's'
	document.getElementById('synthese_territoires').innerHTML = nb
}


// Coloration des cases en fonction du propriétaire
function affichage_cases(ideologie, territoire) {
	couleur = couleurs[ideologie-1]
	caseSelectionnee = terrCases[territoire]
	document.getElementById('case'+caseSelectionnee).style.backgroundColor = couleur
}


// Met la couleur relative à l'idéologie sur un territoire
function affichage_territoire(ideologie, territoire) {
	c = couleurs[ideologie-1]
	c = c.substring(1,c.length)
	
	couleur = "#"+variationCouleur(c)

	el = document.getElementById('terr'+territoire)
	if (el)
		el.style.fill = couleur
	else
	{
		p = 0;
		broken = false
		while (!broken) {
			p++
			el = document.getElementById('terr'+territoire+'-'+p)
			if (!el) broken = true;
			else el.style.fill = couleur
		}
	}
}


function affichage_nouveauTerritoire(territoire) {
	// Information log
	ecrire_log("Vous avez gagné le territoire « "+territoires[territoire]+" » !")
	
	// Changement couleur de la case
	affichage_cases(ep_partenaires[ep_numJoueur-1]['ideologie'], territoire)
	
	// Changement couleur pays
	affichage_territoire(ep_partenaires[ep_numJoueur-1]['ideologie'], territoire)	
}


function affichage_perteTerritoire(territoire, nouveauProprietaire) {
	// Information log
	ecrire_log(ep_partenaires[nouveauProprietaire]['pseudo']+" a fait basculer votre territoire « "+territoires[territoire]+" » !")
	
	// Changement couleur de la case
	affichage_cases(ep_partenaires[nouveauProprietaire]['ideologie'], territoire)
	
	// Changement couleur pays
	affichage_territoire(ep_partenaires[nouveauProprietaire]['ideologie'], territoire)	
}


// Efface tous les indicateurs santé
function affichage_effacerIndicateursSante() {
	document.getElementById('etatTerritoires').innerHTML = ''
}


// Ajoute un indicateur santé
function affichage_indicateurSante(territoire, decalage) {
	hauteur = 50
	if (decalage < 10) bpos = -2*hauteur;
	else if (decalage < 20) bpos = -1*hauteur;
	else bpos = 0;

	document.getElementById('etatTerritoires').innerHTML += '<span class="microjauge" title="'+territoires[territoire]+' (décalage : '+decalage+'pts)" style="background-position:0 '+bpos+'px;"></span>'
}


// Affiche le joueur courant (fait clignoter et ajoute un log)
function affichage_jc(jc) {
	
	for (i = 0 ; i < nbJoueurs; i ++)
	{
		if (i == jc) document.getElementById('jj'+i).style.textDecoration = "blink"
		else document.getElementById('jj'+i).style.textDecoration = "none"
	}

	ecrire_log(ep_partenaires[jc]['pseudo']+" (J"+(jc+1)+") joue")
}


// Affiche les éléments nécessaire au lancer des dés
function affichage_interfaceDes() {
	document.getElementById('notification_des').style.display = "block"
	listenerActif = true
	ecrire_notification('Au suivant !', "C'est à "+ep_partenaires[ep_numJoueur-1]['pseudo']+" (J"+ep_numJoueur+") de jouer")
	afficher_notification()
}


// Rend les dés moins visibles
function affichage_masquerDes() {
	document.getElementById('etatPartie').style.opacity = 0.33
}


// Affiche le résultat des dés sur le plateau
function affichage_des(de1, de2) {
	hauteurDes = 33
	document.getElementById('etatPartie').style.opacity = 1
	document.getElementById('de1').style.backgroundPosition = '0 '+(-(de1-1)*hauteurDes)+'px'
	document.getElementById('de1').title = de1
	document.getElementById('de2').style.backgroundPosition = '0 '+(-(de2-1)*hauteurDes)+'px'
	document.getElementById('de2').title = de2
}


// Affiche le fomulaire avec la liste des opérations
function affichage_operations(operations) {
	territoire = chercherTerritoire(ep_positions[ep_numJoueur-1])
	proprietaire = chercherProprietaire(territoire)
	texte = "Vous êtes sur le territoire « "+territoires[territoire]+" » (J"+(proprietaire+1)+" : "+ep_partenaires[proprietaire]['pseudo']+"). Quelle opération choississez vous ?<br />"
	
	checked = ' checked="checked"'
	for (i = 0 ; i < operations.length ; i++)
	{
		cout = jeu_couts[operations[i]]*-1
		if (cout < 0) color = "red"
		else color = "green"
		texte += '<span title="'+jeu_operations[operations[i]]['desc']+'"><input type="radio" name="operation" value="'+operations[i]+'"'+checked+'> '+jeu_operations[operations[i]]['nom']+' <span style="color:'+color+';">('+cout+' $)</span></span><br />'
		checked = ""
	}
	ecrire_notification('Lancez une opération !', texte)
	afficher_notification()
	
	document.getElementById('notification_operation').style.display = "block"
	listenerActif = true
}

function affichage_evenement_recu(joueur, nom, desc) {
	ecrire_log(ep_partenaires[joueur]['pseudo']+' a déclenché <span title="'+desc+'">l\'événement « '+nom+' »</span>')
}


function affichage_evenement(joueurDeclencheur) {
	if (joueurDeclencheur == -1)
		ecrire_log("Vous subissez votre propre événement")
	else
		ecrire_log("Vous subissez l'évènement de J"+(joueurDeclencheur+1)+":"+ep_partenaires[joueurDeclencheur]['pseudo'])
}

// Écriture d'éléments dans le log
function ecrire_log(contenu) {
	if (document.getElementById('log').innerHTML != '')
	{
		histo = document.getElementById('log').innerHTML
		document.getElementById('log').innerHTML = contenu+'<br />'+histo
	}
	else
		document.getElementById('log').innerHTML = contenu
}


// Écriture d'une notification
function ecrire_notification(titre, contenu) {
	document.getElementById('contenu_notification').innerHTML = '<h1>'+titre+'</h1><p>'+contenu+'</p>'
}


// Affichage de la fenêtre de notification
function afficher_notification() {
	document.getElementById('conteneur_notification').style.display = "block"
}

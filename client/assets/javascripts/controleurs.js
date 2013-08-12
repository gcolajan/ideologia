function controleur_etat() {
	// Si un état est retourné, c'est que la partie est pleine
	document.location="./accueil?plein";
}


function controleur_numeroJoueur(num) {
	ep_numJoueur = num+1;
	
	// Cet événement correspond au début de la partie, on affiche le plateau
	document.getElementById('attente').style.display='none';document.getElementById('conteneur_plateau').style.display='block';
	
	// Mettre en gras le pseudo choisi par le joueur
	document.getElementById('joueur_pseudo'+num).style.fontWeight = "bold";
	document.getElementById('jj'+num).style.fontWeight = "bold";
}


function controleur_partenaires(partenaires) {
	for (i = 0 ; i < nbJoueurs ; i++) 
	{
		affichage_pseudo(i, partenaires[i]['pseudo'])
		affichage_ideologie(i, partenaires[i]['ideologie'])
	}
	
	// On ne retient les coûts de nos opérations uniquement
	jeu_couts = jeu_couts[partenaires[ep_numJoueur-1]['ideologie']]
	
	// Stockage des données
	ep_partenaires = partenaires
}


function controleur_jaugesIdeales(niveauIdeals) {
	for (i = 1 ; i <= nbJauges ; i++)
		affichage_niveauIdeal(i, niveauIdeals[i])
	ep_niveauIdeals = niveauIdeals
}


function controleur_temps(secondes) {
	minutes = parseInt(secondes/60)
	secondes = secondes - minutes*60
	setTimer(minutes,secondes)
}


function controleur_evenement(evenement) {
	// Il s'agit juste de faire un affichage
	
	joueurDeclencheur = evenement[0]
	evenementDeclenche = evenement[1]
	
	destination = jeu_evenements[evenementDeclenche]['dest']
	nom = jeu_evenements[evenementDeclenche]['nom']
	desc = jeu_evenements[evenementDeclenche]['desc']
	
	affichage_evenement_recu(joueurDeclencheur, nom, desc)
	
	switch (destination) {
		case 0: // Moi
			if (joueurDeclencheur == ep_numJoueur)
				affichage_evenement(-1)
			break;
		case 1: // Tous
			affichage_evenement(joueurDeclencheur)
			break;
	}
}


function controleur_pcases(positions) {

	// On efface les anciennes positions
	if (toClean && toClean.length > 0) {
		for (var i = 0 ; i < toClean.length ; i++)
			affichage_pion(toClean[i], -1)
	}
	
	nbCasesOccupees = positions.length
	
	// Préparation des cases à "nettoyer"
	toClean = Array()
	for (var i = 0 ; i < nbCasesOccupees ; i++)
		toClean.push(positions[i]['case'])


	// On affiche nos pions

	for (var i = 0 ; i < nbCasesOccupees ; i++)
		affichage_pion(positions[i]['case'], positions[i]['joueurs'])
}


function controleur_fonds(fonds) {
	if (ep_fonds != fonds)
	{
		affichage_fonds(fonds)
		ep_fonds = fonds
	}
}


function controleur_jauges(jauges) {
	for (i = 1 ; i <= nbJauges ; i++)
		affichage_jauge(i, Math.round(jauges[i]))
}



function controleur_listeTerritoires(terrs, synth) {

	// Synthèse des jauges
	numJoueur = (ep_numJoueur-1)

	affichage_effacerIndicateursSante()
	// On parcourt la liste de nos terrs
	for (i = 0 ; i < terrs[numJoueur].length ; i++)
	{
		decalage = synth[terrs[numJoueur][i]]
	
		// Pour chaque territoire, on affiche son indicateur
		affichage_indicateurSante(terrs[numJoueur][i], decalage)
	}



	// Algo traitement des territoires
	affichage_nbTerritoires(terrs[ep_numJoueur-1].length)

	if (!ep_listeTerritoires[0]) // Si c'est la première fois qu'on reçoit la liste
	{
		// On envoie tous les terrs pour qu'ils soient affichés
		for (i = 0 ; i < nbJoueurs ; i++)
		{
			nbTerr = terrs[i].length
			for (j = 0 ; j < nbTerr ; j++)
			{
				terr = terrs[i][j]
				affichage_cases(ep_partenaires[i]['ideologie'], terr)
				affichage_territoire(ep_partenaires[i]['ideologie'], terr)
			}
		}
	}
	else
	{
		// Affichage seulement si cela concerne le joueur
		var jconcerne = (ep_numJoueur-1)
		nbTerr = terrs[jconcerne].length
		nbTerrAvant = ep_listeTerritoires[jconcerne].length

		if (nbTerr > nbTerrAvant) // Territoire gagné
		{
			for (var i = 0 ; i < nbTerr ; i++)
			{
				if (ep_listeTerritoires[jconcerne].indexOf(terrs[jconcerne][i]) == -1)
				{
					affichage_nouveauTerritoire(terrs[jconcerne][i])
					break;
				}
			}

		}
		else if (nbTerr < nbTerrAvant) // Territoire perdu
		{
			var proprio;
			var terrPerdu;
			
			// Parcours des territoires précédemments possédés
			for (var i = 0 ; i < nbTerrAvant ; i++)
			{
				// On cherche quel est le territoire perdu
				if (terrs[jconcerne].indexOf(ep_listeTerritoires[jconcerne][i]) == -1)
				{
					terrPerdu = ep_listeTerritoires[jconcerne][i]
					break;
				}
			}
			
			// Parcours des nouveaux territoires des joueurs
			for (var i = 0 ; i < nbJoueurs ; i++)
			{
				// On ne regarde pas s'il est chez nous
				if (i != jconcerne)
				{
					// Qui est le propriétaire
					if (terrs[i].indexOf(terrPerdu) != -1)
					{
						proprio = i
						break;
					}
				}
			}
			
			affichage_perteTerritoire(terrPerdu, proprio)
		}
		
		
		// On cherche à savoir s'il y a eu des changements entre d'autres joueurs
		// Si un territoire apparait dans une nouvelle liste !
		// Actuellement, forcément un double usage avec les éléments ci-dessus (mais sans affichage ci-dessous)
		
		// TODO : Revoir l'algo en débutant TOUT depuis ci-dessous (virer la condition i != jconcerne)
		// Lorsqu'un territoire bascule, il faudra juste chercher son ANCIEN propriétaire
		// Et afficher un message à ceux non concernés (le territoire X passe de J à J) et aux joueurs concernés (Vous avez gagné le territoire X de J) / (J a fait basculé le territoire X)
		
		// Pour chaque joueur
		for (var i = 0 ; i < nbJoueurs ; i++)
		{
			if (i != jconcerne) // On ne regarde que les cas des autres joueurs
			{
				// Si un territoire a changé de main (en possède plus qu'avant)
				if (terrs[i].length > ep_listeTerritoires[i].length)
				{
					// On parcoure la liste des territoires
					for (var j = 0 ; j < terrs[i].length ; j++)
					{
						// Pour savoir lequel est apparu
						if (ep_listeTerritoires[i].indexOf(terrs[i][j]) == -1)
						{
							// Changement couleur de la case
							affichage_cases(ep_partenaires[i]['ideologie'], terrs[i][j])
	
							// Changement couleur pays
							affichage_territoire(ep_partenaires[i]['ideologie'], terrs[i][j])	
							
							//break;
						}
					}
				}
			}
		}
	}
	
	ep_listeTerritoires = terrs
}


function controleur_joueurCourant(numeroJoueurCourant) {
	ep_jc = parseInt(numeroJoueurCourant)+1
	affichage_jc(numeroJoueurCourant)
	
	if (ep_numJoueur == numeroJoueurCourant+1)
		affichage_interfaceDes()
	else
		affichage_masquerDes()
}


function controleur_des(des) {
	affichage_des(des[0], des[1])
}


function controleur_position(position) {
	// Non pris en charge avec le système actuel
	//affichage_deplacement(i, ep_positions[ep_numJoueur-1], position)
	ep_positions[ep_numJoueur-1] = position
}


function controleur_gain(gain) {
	// Affichage d'une animation avec la somme gagnée (si > 0)
	ep_fonds += gain
	affichage_fonds(ep_fonds)
}

function controleur_operations(operations) {
	affichage_operations(operations)
}

function controleur_scores() {
	
}


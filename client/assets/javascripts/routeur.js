// Dirige les informations du serveur vers les fonctions de traitement
function routeur(message_serveur)
{
	var recept = eval('('+message_serveur+')');

	var transmission = recept['transmission'];
	var contenu = recept['contenu'];

	switch(transmission){
		case "etat":
			controleur_etat()
		break;
		case "numeroJoueur":
			controleur_numeroJoueur(contenu)
		break;
		case "partenaires":
			controleur_partenaires(contenu)
		break;
		case "jaugesIdeales":
			controleur_jaugesIdeales(contenu)
		break;
		case "temps":
			controleur_temps(contenu)
		break;
		case "evenement":
			controleur_evenement(contenu)
		break;
		case "positions":
			//controleur_positions(contenu)
		break
		case "pcases":
			controleur_pcases(contenu)
		break;
		case "fonds":
			controleur_fonds(contenu)
		break;
		case "jauges":
			controleur_jauges(contenu)
		break;
		case "listeTerritoires":
			controleur_listeTerritoires(contenu['liste'], contenu['synthese'])
			//controleur_syntheseTerritoires(contenu['synthese'])
		break;
		case "syntheseTerritoires":
			//controleur_syntheseTerritoires(contenu)
		break;
		case "joueurCourant":
			controleur_joueurCourant(contenu)
		break;
		case "des":
			controleur_des(contenu)
		break;
		case "position":
			controleur_position(contenu)
		break;
		case "gain":
			controleur_gain(contenu)
		break; 
		case "operations":
			controleur_operations(contenu)
		break;
		case "scores":
			controleur_scores()
		break;   
		default:
			alert("Transmission non prise en charge");
	}
}

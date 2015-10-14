$LOAD_PATH << File.dirname(__FILE__) + "/jeu"

require 'Territoire'
require 'Ideologie'
require 'Joueur'
require 'Plateau'

class Partie

	attr_reader :joueurCourant
	attr_reader :estDemarree
	attr_reader :plateau
	attr_reader :nbJoueurs
  attr_reader :listeJoueurs
	
	# Initialise une nouvelle partie de quatre joueurs et d'une durée de 30 minutes
	def initialize
	
		@nbJoueurs = 4
		@nbTerritoires = 32
		
		@estDemarree = true
		@scores = nil
		@listeJoueurs = []
		
		@mutPEC = Mutex.new
		@partieEnCours = ConditionVariable.new
		
		@sem = Mutex.new # Sémaphore globale
		@semFinTour = Mutex.new # Sémaphore fin de tour
		@finTour = ConditionVariable.new
		@heureDebut = nil
		
		@nbAppelObtenirEvenement = 0
		
		listeTerritoires, popMondiale = obtenirTerritoires()
		listeIdeologies = obtenirIdeologies()
		portionsTerritoires = partageTerritoire(listeTerritoires)
		
		for i in (0..@nbJoueurs-1)
			@listeJoueurs.push(Joueur.new(listeIdeologies[i], portionsTerritoires[i], i))
		end
		
		@plateau = Plateau.new(listeTerritoires, popMondiale)
		@joueurCourant = @listeJoueurs[0]
	end

	def start
		@heureDebut = Time.now
	end

	def started?
		return (not @heureDebut.nil?)
	end

  # Permet de savoir si le temps est dépassé
  def timeOver?
		if started?
    	return (Time.now > @heureDebut + $TEMPS_JEU)
		else
			return false
		end
	end

	# Retourne la durée restante
	def timeLeft
		unless started?
			$TEMPS_JEU
		else
			$TEMPS_JEU - (Time.now - @heureDebut)
		end
	end
	
	# Retourne l'instance du joueur correspondant au thread appelant
	def recupererInstanceJoueur(numero)
		return @listeJoueurs[numero]
	end


  def finTour
    # Met à jour le prochain joueur courant (pas de mutex, les autres threads dorment encore)
    @joueurCourant = @listeJoueurs[(@joueurCourant.numJoueur+1)%4]

    # Réveil les threads-joueurs inactifs qui ne jouaient pas pendant le tour
    @semFinTour.synchronize{
      @finTour.broadcast()
    }

    # Vérifier que le temps n'est pas dépassé, le cas échéant déclarer la partie terminée
    if timeOver?
      finPartie()
    end
  end
	
	
	# Fais progresser le joueur de la somme des dés
	# Retourne la case sur laquelle le joueur est tombé et 
	def progression(sommeDes)
		# Plateau	va faire progresser le joueur de sommeDes
		ancienneCase, nouvelleCase = @plateau.faireProgresser(@joueurCourant, sommeDes)
		
		passageDepart = false
		if (nouvelleCase.numCase < ancienneCase.numCase) # On a passé la case départ
			passageDepart = true
		end
		
		# On retourne la nouvelle case du joueur et un indicateur de passage
		return nouvelleCase, passageDepart
	end
	
	
	# Application du gain suivant si le joueur est passé sur la case départ ou non
	# Retourne le gain du joueur pour afficher du côté du client
	def recupererGain(passageDepart)
		gain = 0
		if (passageDepart)
			gain = @plateau.listeCases[0].actionCaseDepart(@joueurCourant)
			@joueurCourant.fondsFinanciers += gain
		end

		return gain
	end


	
	# Endort les threads qui ne joue pas pendant le tour
	def attendreFinTour
		@semFinTour.synchronize{
			 @finTour.wait(@semFinTour)
		}	
	end
	
	
		
	def finPartie
		@estDemarree = false
		@mutPEC.synchronize{
			@partieEnCours.broadcast()
		}
	end
	
	def endormirFinPartie
		@mutPEC.synchronize{
			@partieEnCours.wait(@mutPEC)
		}
	end
	
	
	# Retourne 4 identifiants d'opération à choisir par le client
	# Une opération peut avoir un coût négatif qui va permettre au joueur de gagner de l'argent
	def genererIdOperationsProposees(ideologie)
		return Datastore.instance.getOperations(
        ideologie.numero,
        rand(4) == 0 ? 1 : 0, # In 25% of cases, we get a negative-cost operation
        4)
	end
	
	
	
	# Applique le coût de l'opération sur le joueur et l'opération sur le territoire
	def appliquerOperationTerritoire(operation, territoire)
		@joueurCourant.fondsFinanciers -= operation.cout
		territoire.recoitOperation(operation, @joueurCourant)
	end
	
	
	
	# Applique un événement (prise en charge de la destination)
	def appliquerOperationEvenement(operation)
		destination = operation.destination
		
		case destination
			when -1 # Tous sauf moi
				for joueur in @listeJoueurs
					if (joueur != @joueurCourant)
						for territoire in joueur.listeTerritoires
							territoire.recoitOperation(operation, nil)
						end
					end
				end
				 
			when 0 # Moi
				for territoire in @joueurCourant.listeTerritoires
					territoire.recoitOperation(operation, nil)
				end
				
			when 1 # Tous
				for joueur in @listeJoueurs
					for territoire in joueur.listeTerritoires
						territoire.recoitOperation(operation, nil)
					end
				end
		end
	end
	
	

	# Permet de créer un dictionnaire contenant les pseudos et idéologies de chaque joueur
	# Retourne le dictionnaire
	def obtenirTableauPartenaires
		partenaires = {}
		for joueur in @listeJoueurs
			partenaire = {"pseudo" => joueur.pseudo, "ideologie" => joueur.ideologie.numero}
			partenaires.merge!({joueur.numJoueur => partenaire})
		end
		return partenaires
	end
	
	
	# Permet d'obtenir les scores de la partie
	def obtenirScores
		if @scores == nil
			calculerScores()
		end
		return @scores
	end
	
	def deconnexionJoueur(numeroJoueurDeconnecte)
		for joueur in @listeJoueurs
			if(joueur.numJoueur != numeroJoueurDeconnecte)
				joueur.direAGestionJoueurDeconnexionJoueur(numeroJoueurDeconnecte)
				finPartie() # Fin de partie, attention threadGestionJoueur peut dormir (sans incidence en théorie)
			end
		end
	end
	
	
	# --------------- méthodes privées
	
	private
	# Instanciation des territoires (pour Joueur et CaseTerritoire)
	# Retourne la liste des territoires afin que Partie les répartissent et la population mondiale pour la case départ
	def obtenirTerritoires
    territoires = Datastore.instance.getTerritoriesPopulation()
		listeTerritoireObtenus = []

    popMondiale = 0
    territoires.each { |id,info|
      listeTerritoireObtenus.push(Territoire.new(id, info['population'], info['position']))
      popMondiale += info['population']
    }

		return listeTerritoireObtenus, popMondiale
	end
	
	
	
	
	
	# Instanciation des idéologies pour Joueur
	# Retourne une liste de toutes les idéologies
	def obtenirIdeologies
    ideologies = Datastore.instance.getIdeologies()
    ideoInstances = []

    ideologies.each { |id|
      ideoInstances.push(Ideologie.new(id))
    }

    return ideoInstances
	end
	
	

	# Fonctionne seulement pour une division entière sans reste
	# Permet de séparer les territoires en 4 listes
	# Retourne une liste composée de ces 4 listes
	def partageTerritoire(territoire)

		nbTerritoiresTotal = territoire.length
		nbTerritoiresJoueur = nbTerritoiresTotal/@nbJoueurs
		
		partage = []
		territoire = territoire.shuffle

		for i in 0..(@nbJoueurs-1)
			partage.push(territoire.pop(nbTerritoiresJoueur))
		end
		
		return partage
	end
	
	
	
	
	# Crée un dictionnaire contenant tous les scores des joueurs
	# Insère dans la base de données les résultats
	def calculerScores
		@scores = {}
		values = ""
		for joueur in @listeJoueurs
			respectIdeo = joueur.calculerDecalage() # Faible = meilleur
			dominationGeo = joueur.listeTerritoires.length/@nbTerritoires.to_f # Haut = meilleur
			values += "(NOW(), '"+joueur.pseudo+"', "+joueur.ideologie.numero.to_s+", "+respectIdeo.to_s+", "+dominationGeo.to_s+"), "
			@scores.merge!(joueur.numJoueur => [respectIdeo, dominationGeo])
		end

    # TODO change method to store score into file
		# dbh.query("INSERT INTO ideo_score (score_date, score_pseudo, score_ideologie_id, score_respect_ideologie, score_domination_geo) VALUES"+values)
	end
	
end

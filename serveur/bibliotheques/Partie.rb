$LOAD_PATH << File.dirname(__FILE__) + "/jeu"

require 'mysql'
require 'Territoire'
require 'Ideologie'
require 'Joueur'
require 'Plateau'
require 'ConnexionSQL'

class Partie

	attr_reader :evenement
	attr_reader :joueurCourant
	attr_reader :estDemarree
	attr_reader :plateau
	attr_reader :nbJoueurs
	
	#Initialise une nouvelle partie de quatre joueurs et d'une durée de 30 minutes
	def initialize
	
		@nbJoueurs = 4
		@nbTerritoires = 32
		@dureePartie = 1800
		
		@evenement=nil
		@estDemarree = true
		@scores = nil
		@listeJoueurs = []
		
		@sem = Mutex.new # Sémaphore globale
		@semFinTour = Mutex.new # Sémaphore fin de tour
		@finTour = ConditionVariable.new
		@heureDebut=Time.now
		
		@nbAppelObtenirEvenement = 0
		
		listeTerritoires, popMondiale = obtenirTerritoires()
		listeIdeologies = obtenirIdeologies()
		portionsTerritoires = partageTerritoire(listeTerritoires)
		
		for i in (0..@nbJoueurs-1)
			@listeJoueurs.push(Joueur.new(listeIdeologies[i],portionsTerritoires[i],i))
		end
		
		@plateau = Plateau.new(listeTerritoires, popMondiale)
		@joueurCourant = @listeJoueurs[0]
	end
	
	
	
	# Retourne l'instance du joueur correspondant au thread appelant
	def recupererInstanceJoueur numero
		return @listeJoueurs[numero]
	end
	
	
	#Permet de savoir si le temps est dépassé
	#Retourne la durée restante
	def temps
		if(Time.now > @heureDebut + @dureePartie)
			@estDemarree=false
		end
		return @dureePartie - (Time.now - @heureDebut).round
	end
	
	
	
	# Met à jour le prochain joueur courant
	def tourSuivant
		@sem.synchronize {
			@joueurCourant = @listeJoueurs[(@joueurCourant.numJoueur+1)%4]
		}
	end
	
	
	
	#Fais progresser le joueur de la somme des dés
	#Retourne la case sur laquelle le joueur est tombé et 
	def progression sommeDes
		# Plateau	va faire progresser le joueur de sommeDes
		ancienneCase, nouvelleCase = @plateau.faireProgresser(@joueurCourant,sommeDes)
		
		passageDepart = false
		if (nouvelleCase.numCase < ancienneCase.numCase) # On a passé la case départ
			passageDepart = true
		end
		
		# On retourne la nouvelle case du joueur et un indicateur de passage
		return nouvelleCase,passageDepart
	end
	
	
	#Application du gain suivant si le joueur est passé sur la case départ ou non
	#Retourne le gain du joueur pour afficher du côté du client
	def recupererGain passageDepart
		gain = 0
		if (passageDepart)
			gain = @plateau.listeCases[0].actionCaseDepart(@joueurCourant)
			@joueurCourant.fondsFinanciers += gain
		end

		return gain
	end

	
	#Réveil les threads qui ne jouaient pas pendant le tour
	def reveilFinTour
		@semFinTour.synchronize{
			(@nbJoueurs-1).times {
				@finTour.signal
			}
		}
	end
	
	#Endort les threads qui ne joue pas pendant le tour
	def attendreFinTour
		@semFinTour.synchronize{
			 @finTour.wait(@semFinTour)
		}	
	end
	
	
	
	#Retourne 4 identifiants d'opération à choisir par le client
	#Une opération peut avoir un coût négatif qui va permettre au joueur de gagner de l'argent
	def genererIdOperationsProposees
		
		listeIdObtenus = []
		
		begin
			dbh=Mysql.new($host, $user, $mdp, $bdd)
			# On prend un nombre aléatoire entre 1 et 4
			nb = rand(4)
			if (nb == 0) # Dans ce cas, on choisi 3 opérations au coût positif et une opération au coût négatif
				nb = 3
				res = dbh.query("SELECT toc_operation_id
								FROM ideo_territoire_operation_cout
								WHERE toc_ideologie_id = "+@joueurCourant.ideologie.numero.to_s+"
								AND toc_cout < 0
								ORDER BY RAND()
								LIMIT 1")
				data=res.fetch_hash()
				listeIdObtenus.push(data['toc_operation_id'])
			else
				nb = 4
			end

			res = dbh.query("SELECT toc_operation_id
							FROM ideo_territoire_operation_cout
							WHERE toc_ideologie_id = "+@joueurCourant.ideologie.numero.to_s+"
							AND toc_cout BETWEEN 0 AND "+@joueurCourant.fondsFinanciers.to_s+"
							ORDER BY RAND()
							LIMIT "+nb.to_s)
			while(data=res.fetch_hash())
				listeIdObtenus.push(data['toc_operation_id'])
			end
		rescue Mysql::Error => e
			puts e
		ensure
			dbh.close if dbh
		end
		
		return listeIdObtenus
	end
	
	
	
	# Applique le coût de l'opération sur le joueur et l'opération sur le territoire
	def appliquerOperationTerritoire operation,territoire
		@joueurCourant.fondsFinanciers -= operation.cout
		territoire.recoitOperation(operation,@joueurCourant)
	end
	
	
	
	# Applique un événement (prise en charge de la destination)
	def appliquerOperationEvenement operation
		destination = operation.destination
		
		case destination
			when -1 # Tous sauf moi
				for joueur in @listeJoueurs
					if (joueur != @joueurCourant)
						for territoire in joueur.listeTerritoires
							territoire.recoitOperation(operation,nil)
						end
					end
				end
				 
			when 0 # Moi
				for territoire in @joueurCourant.listeTerritoires
					territoire.recoitOperation(operation,nil)
				end
				
			when 1 # Tous
				for joueur in @listeJoueurs
					for territoire in joueur.listeTerritoires
						territoire.recoitOperation(operation,nil)
					end
				end
		end
		
		@evenement = [@joueurCourant.numJoueur, operation.idEvenement]
	end
	
	
	#Retourne l'identifiant de l'événement ainsi que le numéro du joueur courant pour savoir qui a causé l'événement
	def obtenirEvenement
		@sem.synchronize{
			@nbAppelObtenirEvenement = @nbAppelObtenirEvenement + 1
		}
		ev = @evenement
		if(@nbAppelObtenirEvenement==4)
			@evenement = nil
			@nbAppelObtenirEvenement = 0
		end
		return ev
	end
	
	#Permet de créer un dictionnaire contenant les pseudos et idéologies de chaque joueur
	#Retourne le dictionnaire
	def obtenirTableauPartenaires
		partenaires = {}
		for joueur in @listeJoueurs
			partenaire = {"pseudo" => joueur.pseudo, "ideologie" => joueur.ideologie.numero}
			partenaires.merge!({joueur.numJoueur => partenaire})
		end
		return partenaires
	end
	
	
	#Retourne un dictionnaire contenant toutes les positions des joueurs
	def positionsJoueurs
		pos = {}
		for joueur in @listeJoueurs
			pos.merge!({joueur.numJoueur => joueur.position})
		end
		return pos
	end
	
	
	#Retourne un dictionnaire donnant, pour chaque case les joueurs présents
	def presenceCases
		pCases = {}
		for i in 0..41
			pCases.merge!({i => []})
		end
		
		pJoueurs = positionsJoueurs()
		for i in 0..(@nbJoueurs-1)
			for j in 0..(@nbJoueurs-1)
				if (i != j)
					if (not(pCases[pJoueurs[i]].include?(i)))
						pCases[pJoueurs[i]].push(i)
					end
					if (not(pCases[pJoueurs[j]].include?(j)))
						pCases[pJoueurs[j]].push(j)
					end
				end
			end 
		end
		
		pos = []
		for i in 0..41
			if pCases[i].length != 0 
				pos.push({"case" => i, "joueurs" => pCases[i]})
			end
		end
		
		return pos
	end
	
	
	#Crée un dictionnaire contenant le numéro de chaque joueur et les territoires qu'il possède
	#Retourne le dictionnaire
	def territoiresPartenaires
		terrPartenaires = {}
		for joueur in @listeJoueurs
			territoires = []
			for territoire in joueur.listeTerritoires
				territoires.push(territoire.idTerritoire)
			end
			terrPartenaires.merge!({joueur.numJoueur => territoires})
		end
		
		return terrPartenaires
	end
	
	
	#Permet d'obtenir les scores de la partie
	def obtenirScores
		if @scores == nil
			calculerScores()
		end
		return @scores
	end
	
	
	
	# --------------- méthodes privées
	
	private
	# Instanciation des territoires (pour Joueur et CaseTerritoire)
	#Retourne la liste des territoires afin que Partie les répartissent et la population mondiale pour la case départ
	def obtenirTerritoires
		listeTerritoireObtenus = []
		begin
			dbh = Mysql.real_connect($host, $user, $mdp, $bdd)
			res = dbh.query("SELECT terr_id, terr_position, 
								(SELECT SUM(unite_population) 
								FROM terr_unite 
								WHERE unite_territoire=terr_id) AS popTerritoire 
							FROM terr_territoire")
			popMondiale = 0
			while(data=res.fetch_hash())
				listeTerritoireObtenus.push(Territoire.new(data["terr_id"].to_i,data["popTerritoire"].to_i,data["terr_position"].to_i))
				popMondiale += data["popTerritoire"].to_i
			end	
		rescue Mysql::Error => e
			puts e.error
		ensure
			dbh.close if dbh
		end
		return listeTerritoireObtenus, popMondiale
	end
	
	
	
	
	
	# Instanciation des idéologies pour Joueur
	#Retourne une liste de toutes les idéologies
	def obtenirIdeologies
		listeIdeologiesObtenues=[]
		begin
			dbh=Mysql.new($host, $user, $mdp, $bdd)
			res = dbh.query("SELECT ideo_id FROM ideo_ideologie")
			while(data=res.fetch_hash())
				listeIdeologiesObtenues.push(Ideologie.new(data['ideo_id'].to_i))
			end
		rescue Mysql::Error => e
			puts e
		ensure
			dbh.close if dbh
		end
		return listeIdeologiesObtenues
	end
	
	
		

	
	# Fonctionne seulement pour une division entière sans reste
	#Permet de séparer les territoires en 4 listes
	#Retourne une liste composée de ces 4 listes
	def partageTerritoire territoire

		nbTerritoiresTotal = territoire.length
		nbTerritoiresJoueur = nbTerritoiresTotal/@nbJoueurs
		
		partage = []
		territoire = territoire.shuffle

		for i in 0..(@nbJoueurs-1)
			partage.push(territoire.pop(nbTerritoiresJoueur))
		end
		
		return partage
	end
	
	
	
	
	#Crée un dictionnaire contenant tous les scores des joueurs
	#Insère dans la base de données les résultats
	def calculerScores
		@scores = {}
		values = ""
		for joueur in @listeJoueurs
			respectIdeo = joueur.calculerDecalage() # Faible = meilleur
			dominationGeo = joueur.listeTerritoires.length/@nbTerritoires.to_f # Haut = meilleur
			values += "('', NOW(), '"+joueur.pseudo+"', "+joueur.ideologie.numero.to_s+", "+respectIdeo.to_s+", "+dominationGeo.to_s+"),"
			@scores.merge!(joueur.numJoueur => [respectIdeo, dominationGeo])
		end
		
		begin
			dbh=Mysql.new($host, $user, $mdp, $bdd)
			values = values[0,values.length-1]
			res = dbh.query("INSERT INTO ideo_score (score_id, score_date, score_pseudo, score_ideologie_id, score_respect_ideologie, score_domination_geo) VALUES"+values)
		rescue Mysql::Error => e
			puts e
		ensure
			dbh.close if dbh
		end
	end
	
end

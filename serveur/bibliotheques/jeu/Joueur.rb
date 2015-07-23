require 'Jauge'
require 'Joueur'

class Joueur

	
	attr_reader :numJoueur
	attr_reader :ideologie
	attr_reader :listeJaugesPourCopie
	attr_reader :pseudo

	attr_writer :instanceGestionJoueur
	
	attr_accessor :position
	attr_accessor :listeTerritoires
	attr_accessor :fondsFinanciers
	
	
	def initialize(ideologie, territoires, numJoueur)
		@position = 0
		@numJoueur = numJoueur
		@ideologie = ideologie
		@listeJaugesPourCopie = definirJauges()
		@listeTerritoires = approprierTerritoires(territoires)
		@fondsFinanciers = $FONDS_INITIAUX
		@pseudo = ""
		@instanceGestionJoueur = nil
		
	end
	
	# Permet de définir le pseudo du joueur suivant celui transmis par le client
	def definirPseudo(pseudo)
		@pseudo = pseudo
	end
	
	# Retourne les niveaux idéals pour chaque jauge
	def niveauxIdeals
		niveaux = {}
		for i in (1..3)
			niveaux.merge!({i => @listeJaugesPourCopie[i.to_s].niveauIdeal})
		end
		return niveaux
	end
	
	# Permet de donner le joueur instancié comme joueur possesseur d'un territoire
	# Retourne les territoires qui sont possédés
	def approprierTerritoires(territoires)
		for territoire in territoires
			territoire.appropriationTerritoire(self)
		end
		return territoires
	end

	# Permet de calculer le décalage moyen de l'ensemble des jauges des territoires du joueur
	# Retourne le décalage moyen
	def calculerDecalage
		somme = 0
		for territoire in @listeTerritoires
			somme += territoire.calculerDecalage()
		end
		return somme/@listeTerritoires.length()
	end

	# Permet de connaître le nombre de territoires possédés par le joueur
	# Retourne le nombre de territoires possédés
	def calculerNombreTerritoires
		return listeTerritoires.length
	end

	# Permet de calculer la population totale que le joueur possède
	# Retourne la population possédée
	def calculerPopulation
		pop = 0
		listeTerritoires.each{|territoire| pop += territoire.population}
		return pop
	end
	
	# Permet de créer les jauges modèles du joueur suivant la base de données
	# Retourne un dictionnaire contenant les trois jauges
	def definirJauges
    jauges = {}

    Datastore.instance.getJaugesInfo(@ideologie.numero).each { |id, info|
      jauges.merge!(id => Jauge.new(info['ideal'], info['plus'], info['minus']))
    }

    return jauges
	end
	
	# Permet de synthétiser les jauges du joueur
	# Retourne la synthèse des jauges
	def syntheseJauge
		synthJauge = {}
		for i in (1..3)
			somme = 0
			synthJauge[i] = 0
			for territoire in @listeTerritoires
				somme += territoire.listeJauges[i].niveau
			end
		synthJauge[i] += somme/@listeTerritoires.size()
		end
  		return synthJauge
	end
	
	# Permet de synthétiser chaque territoire
	# Retourne la synthèse des territoires
	def syntheseTerritoire
		listeTerr = {}
		for territoire in @listeTerritoires
			listeTerr.merge!({territoire.idTerritoire => territoire.calculerDecalage})
		end
		return listeTerr
	end

	def obtenirInstanceGestionJoueur(gerantJoueur)
		@instanceGestionJoueur = gerantJoueur
	end

	def direAGestionJoueurDeconnexionJoueur(numeroJoueurDeconnecte)
		@instanceGestionJoueur.envoyerSignalDeconnexion(numeroJoueurDeconnecte)
	end
	
end

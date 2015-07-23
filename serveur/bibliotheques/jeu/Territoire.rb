class Territoire
	
	attr_reader :listeJauges
	attr_reader :joueurPossesseur
	attr_reader :population
	attr_reader :idTerritoire
	attr_reader :positionTerritoire
	
	def initialize(id, pop, pos)
		@listeJauges = {}
		@idTerritoire = id
		@positionTerritoire = pos
		@population = pop
		@seuil = 30
	end
	
	# Permet de définir les jauges et le joueur possesseur
	def appropriationTerritoire(joueur)
		@joueurPossesseur = joueur
		@listeJauges = {}
		for i in (1..3)
			@listeJauges.merge!(i => Jauge.new(@joueurPossesseur.listeJaugesPourCopie[i]))
    end
	end
	
	# Permet d'appliquer une opération à un territoire
	# Si c'est une action et que le joueur n'est pas le joueur possesseur on transfère le territoire
	def recoitOperation(operation, joueur)
		operation.listeEffet.each{ |key, value|
      @listeJauges[key.to_i].appliquerEffet(value)
    }
		if(calculerDecalage() > @seuil && joueur != @joueurPossesseur && joueur != nil)
			transfert(joueur)
		end
	end
	
	# Permet le transfert d'un territoire à un autre joueur
	def transfert(joueur)
		@joueurPossesseur.listeTerritoires.delete(self)
		appropriationTerritoire(joueur)
		joueur.listeTerritoires.push(self)
  end

  # Retourne un tableau avec l'état des jauges {1..3 => float}
  def etatJauges()
    etats = {}
    (1..3).each { |i|
      etats.merge!(i => @listeJauges[i].niveau)
    }
    return etats
  end
	
	# Permet de calculer le décalage de chaque jauge
	# Retourne le décalage total du territoire
	def calculerDecalage
		somme = 0
		for i in (1..3)
			somme += @listeJauges[i].calculerDecalage()
		end
		return somme
	end
	
end

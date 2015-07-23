require 'Effet'

class Operation

	attr_reader :listeEffet
	attr_reader :cout
	attr_reader :destination
	attr_reader :joueur
	attr_reader :idEvenement # Nécessaire pour communiquer le numéro de l'événement au client
	
	# Permet d'initialiser une opération suivant si il s'agit d'un événement ou d'une action sur un territoire
	# Aucun argument -> événement
	# Deux argument -> action sur territoire
	def initialize(idOp = nil, numIdeo = nil)
		@listeEffet = Hash.new()
		@joueur = joueur
		if(idOp != nil) # territoire
			genererEffetTerritoire(idOp, numIdeo)
		else
			genererEffetEvenement()
		end
	end
	
	
	# ----------------Méthodes privées


	private
	# Permet de générer les effets qui sont dus à une action sur un territoire
	def genererEffetTerritoire(idOp, numIdeo)
    cost, effects = Datastore.instance.getOperationEffect(numIdeo, idOp)

    @cout = cost
    [1,2,3].each{ |i| # for our 3 gauges, we bind the effect
      @listeEffet.merge!(i => Effet.new(effects['abs'][i.to_s], effects['rel'][i.to_s]))
    }
	end
	
	# Permet de générer les effets d'un événement
	def genererEffetEvenement
    id, dest, effects = Datastore.instance.getRandomEventEffect

    @idEvenement = id
    @destination = dest
    [1,2,3].each{ |i| # for our 3 gauges, we bind the effect
      @listeEffet.merge!(i => Effet.new(effects['abs'][i.to_s], effects['rel'][i.to_s]))
    }
	end
	
end

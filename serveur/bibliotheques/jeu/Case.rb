class Case

	attr_reader :numCase

	def initialize positionCase
		@numCase=positionCase
	end

	#Retourne false si la case courante n'est pas une case territoire
	def estTerritoire
		return false
	end

	#Retourne false si la case courante n'est pas une case départ
	def estDepart
		return false
	end

	#Retourne false si la case courante n'est pas une case événement
	def estEvenement
		return false
	end

end

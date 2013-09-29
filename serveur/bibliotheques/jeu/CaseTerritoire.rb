require 'Case'

class CaseTerritoire < Case

	attr_reader :territoire

	def initialize(numCase, territoire)
		super(numCase)
		@territoire=territoire
	end

	#Retourne true si la case courante est une case territoire
	def estTerritoire
		return true
	end
	
end

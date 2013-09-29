require 'Case'
require 'Operation'

class CaseEvenement < Case

	def initialize(numCase)
		super(numCase)
	end

	# Retourne une opération choisie aléatoirement
	def selectionnerOperation
		return Operation.new()
	end
	
	# Retourne true si la case courante est une case événement
	def estEvenement
		return true
	end

end

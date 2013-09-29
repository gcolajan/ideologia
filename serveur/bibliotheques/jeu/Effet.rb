class Effet

	attr_reader :effetPourcentage
	attr_reader :effetAbsolu

	def initialize(variationAbsolue, variationPourcentage)
		@effetAbsolu = variationAbsolue
		@effetPourcentage = variationPourcentage
	end

end

require 'Case'

class CaseDepart < Case

	def initialize(popMonde)
		super(0)
		@popMondiale = popMonde
		$ARGENT_CASE_DEPART = 1600
	end

	# Permet de calculer le gain lors du passage par la case départ
	# Retourne le gain afin de l'afficher chez le client
	def actionCaseDepart(joueur)
		popJoueur = joueur.calculerPopulation()
		decalage = joueur.calculerDecalage()
		gain = ($ARGENT_CASE_DEPART+(($ARGENT_CASE_DEPART/2)*(1-(decalage/100))*(1+(popJoueur/@popMondiale)))).to_i
		joueur.fondsFinanciers += gain
		return gain
	end

	# Retourne true si c'est la case départ qui est la case courante
	def estDepart
		return true
	end

end

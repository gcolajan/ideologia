class Jauge

	attr_reader :niveauIdeal
	attr_reader :niveau
	attr_reader :coeffAugmentation
	attr_reader :coeffDiminution

	#Initialise la jauge en fonction des arguments passés
	#Si il n'y a qu'un argument c'est qu'on cherche à créer la jauge par copie
	#Sinon on cherche à créer la jauge modèle du joueur dans un des trois domaines
	def initialize argument,coeffA=nil,coeffD=nil
		if(coeffA==nil||coeffD==nil)
			constructeurCopie(argument)
		else
			constructeurComplet(argument,coeffA,coeffD)
		end
	end
	

	#Permet d'appliquer un effet sur une jauge en tenant compte des coefficients dûs à l'idéologie
	#Permet d'empêcher que le niveau descend en dessous de 0 ou dépasse 100
	def appliquerEffet effet
		effetAbsolu = effet.effetAbsolu
		effetPourcentage = effet.effetPourcentage

		nouveauNiveau = (@niveau*effetPourcentage)+effetAbsolu
    
		if (@niveau >= nouveauNiveau)
			nouveauNiveau *= @coeffAugmentation
		else 
			nouveauNiveau *= @coeffDiminution
		end 
	
		@niveau = nouveauNiveau.round

		if (@niveau > 100)
			@niveau = 100
		end

		if (@niveau < 0)
			@niveau = 0
		end
	end

	#Permet de calculer le décalage entre le niveau actuel et le niveau idéal
	def calculerDecalage
		return (niveau-niveauIdeal).abs
	end
	
	#Permet de copier la jauge générique du joueur
# JAMAIS UTILISÉE
#	def transfert jauge
#		@niveauIdeal=jauge.niveauIdeal
#		@niveau=jauge.niveauIdeal
#		@coeffAugmentation=jauge.coeffAugmentation
#		@coeffDiminution=jauge.coeffDiminution
#	end


	# ----------------Méthodes privées


	private
	#Permet de d'instancier la jauge par copie
	def constructeurCopie jauge
		@niveauIdeal=jauge.niveauIdeal
		@niveau=jauge.niveauIdeal
		@coeffAugmentation=jauge.coeffAugmentation
		@coeffDiminution=jauge.coeffDiminution
	end

	#Permet d'instancier la jauge modèle d'un domaine
	def constructeurComplet niveauIdeal,coeffA,coeffD
		@niveauIdeal=niveauIdeal
		@niveau=niveauIdeal
		@coeffAugmentation=coeffA
		@coeffDiminution=coeffD
	end

end

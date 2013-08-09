require 'CaseDepart'
require 'CaseEvenement'
require 'CaseTerritoire'

class Plateau

	attr_reader :listePositions
	attr_reader :listeCases

	def initialize listeTerritoires, popMondiale
		@popMondiale = popMondiale
		@listeCases=obtenirCases(listeTerritoires)
		@listePositions=[0,0,0,0]
	end
	
	#Permet de faire progresser le joueur sur le plateau
	#Retourne l'ancienne et la nouvelle case du joueur pour que la partie sache si le joueur est passé par la case départ
	def faireProgresser joueurCourant,sommeDes
		ancienneCase = @listeCases[@listePositions[joueurCourant.numJoueur]] # récupération ancienne case
		@listePositions[joueurCourant.numJoueur] = (@listePositions[joueurCourant.numJoueur] + sommeDes)%42
		joueurCourant.position = @listePositions[joueurCourant.numJoueur] # le joueur courant récupère sa nouvelle position
		nouvelleCase = @listeCases[@listePositions[joueurCourant.numJoueur]] # récupération nouvelle case
		return ancienneCase,nouvelleCase
	end
	
	
	
  	#Retournera le type de la case sur laquelle le joueur courant est.
	def recupererTypeCase caseCourante
		if (caseCourante.estTerritoire())
			type = "caseTerritoire"
		end
		if (caseCourante.estDepart())
			type = "caseDepart"
		end
		if (caseCourante.estEvenement())
			type = "caseEvenement"
		end
		return type
  end
  
  
  
  # Génère deux aléatoires correspondant aux deux dés
  def lanceDes
		return rand(5)+1,rand(5)+1
  end
  
  
  # ------------------Méthode privée
	
	
	private
	#Permet d'obtenir la liste des toutes les cases
	#Retourne une liste de case
	def obtenirCases listeTerritoire
		listeCasesObtenues={}
		listeCasesObtenues.merge!(0 => CaseDepart.new(@popMondiale))
   
		for territoire in listeTerritoire
			listeCasesObtenues.merge!(territoire.positionTerritoire => CaseTerritoire.new(territoire.positionTerritoire,territoire))
		end
    
		listeNumCaseUtilise = []
		listeCasesObtenues.each{|key,value| listeNumCaseUtilise.push(key.to_i)}
    
		i = 0
		for i in (0..41)
			if(!(listeNumCaseUtilise.include?(i)))
				listeCasesObtenues.merge!(i => CaseEvenement.new(i))
			end
		end
    
		return listeCasesObtenues
	end
end

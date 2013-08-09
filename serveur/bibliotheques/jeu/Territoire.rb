class Territoire
	
	attr_reader :listeJauges
	attr_reader :joueurPossesseur
	attr_reader :population
	attr_reader :idTerritoire
	attr_reader :positionTerritoire
	
	def initialize id,pop,pos
		@listeJauges={}
		@idTerritoire=id
		@positionTerritoire=pos
		@population=pop
		@seuil = 30
	end
	
	#Permet de définir les jauges et le joueur possesseur
	def appropriationTerritoire joueur
		@joueurPossesseur=joueur
		@listeJauges={}
		for i in (1..3)
			@listeJauges.merge!(i => Jauge.new(@joueurPossesseur.listeJaugesPourCopie[i.to_s]))
		end
	end
	
	#Permet d'appliquer une opération à un territoire
	#Si c'est une action et que le joueur n'est pas le joueur possesseur on transfère le territoire
	def recoitOperation operation,joueur
		operation.listeEffet.each{|key,value| @listeJauges[key.to_i].appliquerEffet(value)}
		if(calculerDecalage() > @seuil && joueur!=@joueurPossesseur && joueur !=nil)
			transfert(joueur)
		end
	end
	
	#Permet le transfert d'un territoire à un autre joueur
	def transfert joueur
		puts @idTerritoire.to_s+" passe de "+@joueurPossesseur.numJoueur.to_s+" -> "+joueur.numJoueur.to_s
		@joueurPossesseur.listeTerritoires.delete(self)
		appropriationTerritoire(joueur)
		joueur.listeTerritoires.push(self)
	end
	
	#Permet de calculer le décalage de chaque jauge
	#Retourne le décalage total du territoire
	def calculerDecalage
		somme=0
		for i in (1..3)
			somme+=@listeJauges[i].calculerDecalage()
		end
		return somme
	end
	
end

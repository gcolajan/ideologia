require "thread"
class CoordinationClient

	def initialize
		@nbJoueur = 0
		@semaphore = Mutex.new
		@condVariable = ConditionVariable.new
		@semaphorePseudo = Mutex.new
		@condVariablePseudo = ConditionVariable.new
		@debutPartie = false
		@partie = nil
		@transmissionPseudo = 0
				
	end
	
	
	# Permet de créer une partie si quatre joueur sont présents
	# Retourne un numéro pour le thread appelant
	def nouveauJoueur
		num = 0
		@semaphore.synchronize{
			if (@nbJoueur > 3)
				return -1
			end
		
			if((@nbJoueur%4) == 3 and @nbJoueur != 0)
				@debutPartie = true
				@partie = Partie.new
				@condVariable.signal
			end
			
			num = @nbJoueur
			@nbJoueur += 1
		}
		return num%4
	end
	
	# Met les threads en attente du lancement de la partie
	def attendreDebutPartie
		@semaphore.synchronize{
			while(!@debutPartie)
				@condVariable.wait(@semaphore)
			end
		}
	end
	
	
	# Permet de retourner à tous les threads appelant la partie qui vient d'être lancée
	# Retourne l'instance de la partie
	def obtenirPartie
		return @partie
	end
	
	
	# Attend 4 appels (un pour chaque thread) afin de réceptionner tous les pseudos des joueurs
	# Réveil tous les threads quand il y a eu 4 appels
	def transmissionPseudo
		@transmissionPseudo += 1
		@semaphorePseudo.synchronize{
			if (@transmissionPseudo == 4)
				nombreSignaux = @partie.nbJoueurs-1
				nombreSignaux.times do @condVariablePseudo.signal end
			else
				@condVariablePseudo.wait(@semaphorePseudo)
			end		
		}
	end
	
	def nouvellePartie
		puts "nouvelle partie"
		@debutPartie = false
		@partie = nil
		@transmissionPseudo = 0
		@nbJoueur = 0
	end
	
end

class Salon
	
	attr_reader :partie
	attr_reader :plein
	attr_reader :nbJoueur
	attr_reader :debutPartie

	def initialize
		@partie = Partie.new
		@plein = false
		@listeJoueur = [nil, nil, nil, nil]
		@listePseudo = [nil, nil, nil, nil]
		@semaphore = Mutex.new
		@condVariable = ConditionVariable.new
		@semaphorePseudo = Mutex.new
		@condVariablePseudo = ConditionVariable.new
		@debutPartie = false
		@nbJoueur = 0
	end

	def destruction
		@partie = nil
	end

	def attendreDebutPartie
		@semaphore.synchronize{
			while(!@debutPartie)
				@condVariable.wait(@semaphore)
			end
		}
	end

	def deconnexionJoueur ws
		indexDeco = @listeJoueur.index(ws)
		@listeJoueur.insert(indexDeco, nil)
		@listePseudo.insert(indexDeco, nil)
	end

	def connexionJoueurSalon ws, pseudo
		if(@listeJoueur.size == 4)
			return -1
		end
		@listeJoueur.insert(listeJoueur.index(nil), ws)
		@listePseudo.insert(@listeJoueur.index(ws), pseudo)

		@nbJoueur += 1
		transmissionPseudo()
		if(@listeJoueur.size == 4)
			@debutPartie = true
			@plein = true
			@condVariable.signal
		end

		return @listeJoueur.index(ws)
	end

	#Transmet le pseudo à chaque joueur présent dans le salon
	def transmissionPseudo(pseudo)
		@listeJoueur.each{|ws| ws.send(tojson("pseudo", @listePseudo))}
	end
end

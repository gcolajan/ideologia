# Recuperation du pseudo
pseudo = reception.wait('pseudo')

puts pseudo + " vient de se connecter"


numJoueur = -1

# On boucle en attendant le début de la partie ou en quittant le salon
begin
	# On cherche à savoir si tous les salons sont pleins
	tousPleins = true
	listeSalons.each{ |salon| if(!salon.plein)
			tousPleins = false
			break
		end
	}

	if(tousPleins)
		puts "Salons tous pleins"
		salon = Salon.new
		listeSalons.push(salon)
		ws.send(tojson("salons", listeSalons.index(salon) => salon.nbJoueur))
	else
		dictionnaireSalon = {}
		listeSalons.each{|salon| if(!salon.plein)
				dictionnaireSalon.merge!({listeSalons.index(salon) => salon.nbJoueur})
			end
		}
		ws.send(tojson("salons", dictionnaireSalon))

		puts "Attente choix salon par "+pseudo

		indexSalon = reception.wait('join')

		puts "Salon choisi par "+pseudo+" : "+indexSalon.to_s

		salon = listeSalons.at(indexSalon)

		if(salon.plein)
			ws.send(tojson("salonplein", indexSalon))
			redo
		end
	end

	puts pseudo+" commence à attendre"

	numJoueur = salon.connexionJoueurSalon(ws, pseudo)

	puts pseudo+" a le numéro de joueur "+numJoueur.to_s

	ws.send(tojson("joined", listeSalons.index(salon)))

	partie = salon.partie

	joueur = partie.recupererInstanceJoueur(numJoueur)

	gestionJoueur = GestionJoueur.new(ws,partie,joueur,salon)
	
	reception.wait('deco')

end while(!salon.debutPartie)

# We show the last message extracted
puts "Message reçu après fin du salon d'attente"+transmission.to_s

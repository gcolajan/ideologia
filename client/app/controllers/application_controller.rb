# coding: utf-8=
require 'mysql2'

class ApplicationController < ActionController::Base
	protect_from_forgery
	
	def index
		render :action => 'index.html.erb'
	end
	
	
	def scores
		@listeScores = ActiveRecord::Base.connection.execute("
			SELECT score_pseudo, score_respect_ideologie, score_domination_geo, ideo_nom, ideo_couleur
			FROM ideo_score
			JOIN ideo_ideologie ON ideo_id = score_ideologie_id
			ORDER BY score_date DESC, score_domination_geo DESC
			LIMIT 4")
	
	
		render :action => 'scores.html.erb'
	end
	
	def plateau

		# Récupération des données
		listeTerritoires = ActiveRecord::Base.connection.execute("SELECT terr_id, terr_nom, terr_position FROM terr_territoire ORDER BY terr_position")
		
		# Formatage des données pour exploitation
		@nbCases = 42
		@territoires = {}
		@listeTerritoires = ''
		@listeCases = {}
		for terr in listeTerritoires
			@territoires.merge!(terr[2] => [terr[1], terr[0]])
			@listeCases.merge!(terr[2] => "territoire")
			@listeTerritoires += terr[0].to_s+':"'+terr[1].to_s+'",'
		end
		
		@listeTerritoires = 'territoires = {'+@listeTerritoires[0,@listeTerritoires.length-1]+'}'
		
		# On complète la liste des cases avec la case départ
		@listeCases.merge!(0 => "depart")
		
		# On complète la liste des cases avec celles déterminées par les trous restants
		for t in 1..(@nbCases-1)
			if !@listeCases.has_key?(t)
				 @listeCases.merge!(t => "evenement")
			end
		end
		
		# On créer le tableau à afficher
		@affichage = []
		@terrCases = "" # {territoire:case}
		nbEve = 0
		x,y = 0,0
		for i in 0..(@nbCases-1)
			if @listeCases[i] == "territoire"
				@terrCases += @territoires[i].last.to_s+":"+i.to_s+","
				title = @territoires[i].first
				id = @territoires[i].last
			elsif @listeCases[i] == "evenement"
				nbEve +=1
				title = ""
			else # départ
				title = ""
			end
			x += 25
			y += 50
			
			
			classes = "case_plateau "
			if i >= 0 and i <= 11
				classes = classes+"case_superieure case_horizontale "
			end
			if i >= 11 and i <= 21
				classes = classes+"case_droite case_verticale "
			end
			if i >= 21 and i <= 32
				classes = classes+"case_inferieure case_horizontale "
			end
			if i >= 32 or i == 0
				classes = classes+"case_gauche case_verticale "
			end
			
			if [0,11,21,32].include?(i)
				classes = classes+"case_angle "
			end
			
			classe = "case_"+@listeCases[i]
			
			@affichage.push({"title" => title, "terr_id" => id, "class" => classe})
			id = nil
		end
		
		@terrCases = "terrCases = {"+@terrCases[0,@terrCases.length-1]+"}"
		
		# Construire le tableau suivant
		# toutesOperations {ideo_id : {id_operation : [cout, nom, desc]}}
		

		@ideologies = "ideologies = ["
		@couleurs = "couleurs = ["
		@listeCoutOperations = {}
		listeIdeologies = ActiveRecord::Base.connection.execute("SELECT ideo_id, ideo_nom, ideo_couleur FROM ideo_ideologie ORDER BY ideo_id")
		for ideo in listeIdeologies
			@ideologies += "'"+ideo[1].to_s+"', "
			@couleurs += "'#"+ideo[2].to_s+"', "
			@listeCoutOperations.merge!({ideo[0] => {}})
		end
		
		@ideologies = @ideologies[0, @ideologies.length-2]+"]"
		@couleurs = @couleurs[0, @couleurs.length-2]+"]"
		
		
		@jauges = []
		@jauges_js = "jauges = ["
		listeJauges = ActiveRecord::Base.connection.execute("SELECT jauge_id, jauge_nom FROM ideo_jauge ORDER BY jauge_id")
		for jauge in listeJauges
			@jauges.push({'id' => jauge[0], 'nom' => jauge[1]})
			@jauges_js += "'"+jauge[1]+"', "
		end
		
		@jauges_js = @jauges_js[0, @jauges_js.length-2]+']'
		
		post = request.POST
		@pseudo = post['pseudo']
		
		# Liste des événements
		@listeEvenements = ''
		listeEvenements = ActiveRecord::Base.connection.execute("SELECT eo_id, eo_nom, eo_description, eo_destination FROM ideo_evenement_operation ORDER BY eo_id")
		for ev in listeEvenements
			@listeEvenements += ev[0].to_s+':{"nom":"'+ev[1]+'", "desc":"'+ev[2]+'", "dest":'+ev[3].to_s+'},'
		end
		
		@listeEvenements = "jeu_evenements = {"+@listeEvenements[0, @listeEvenements.length-1]+'}'
		
		
		# Liste des opérations
		@listeOperations = ''
		listeOperations = ActiveRecord::Base.connection.execute("SELECT to_id, to_nom, to_description FROM ideo_territoire_operation ORDER BY to_id")
		for op in listeOperations
			@listeOperations += op[0].to_s+':{"nom":"'+op[1]+'", "desc":"'+op[2]+'"},'
		end
		
		@listeOperations = "jeu_operations = {"+@listeOperations[0, @listeOperations.length-1]+'}'
		
		# Listes des coûts par idéologie
		listeOperations = ActiveRecord::Base.connection.execute("SELECT toc_operation_id, toc_ideologie_id, toc_cout FROM ideo_territoire_operation_cout ORDER BY toc_ideologie_id, toc_operation_id")
		for op in listeOperations
			@listeCoutOperations[op[1]].merge!({op[0] => op[2]})
		end
		
		@listeCoutOperations = 'jeu_couts = '+@listeCoutOperations.to_s.gsub('=>', ':')
		
		#@listeOperations = "operations = {"+@listeOperations[0, @listeOperations.length-1]+'}'

		render :action => 'plateau.html.erb'
	end
	
end

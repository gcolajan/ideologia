require 'Effet'

class Operation

	attr_reader :listeEffet
	attr_reader :cout
	attr_reader :destination
	attr_reader :joueur
	attr_reader :idEvenement # Nécessaire pour communiquer le numéro de l'événement au client
	
	# Permet d'initialiser une opération suivant si il s'agit d'un événement ou d'une action sur un territoire
	# Aucun argument -> événement
	# Deux argument -> action sur territoire
	def initialize(idOp = nil, numIdeo = nil)
		@listeEffet = Hash.new()
		@joueur = joueur
		if(idOp != nil) # territoire
			genererEffetTerritoire(idOp, numIdeo)
		else
			genererEffetEvenement()
		end
	end
	
	
	# ----------------Méthodes privées


	private
	# Permet de générer les effets qui sont dus à une action sur un territoire
	def genererEffetTerritoire(idOp, numIdeo)
		begin
			dbh = Mysql.new($host, $user, $mdp, $bdd)
			res = dbh.query("SELECT te_jauge_id, te_variation_absolue, te_variation_pourcentage, toc_cout
		    				FROM ideo_territoire_effet, ideo_territoire_operation_cout
							WHERE te_ideologie_id = "+numIdeo.to_s+"
							AND te_operation_id = "+idOp.to_s+"
							AND toc_operation_id = te_operation_id
							AND toc_ideologie_id = te_ideologie_id")
			while(data = res.fetch_hash())
				@cout = data['toc_cout'].to_i
				@listeEffet.merge!(data['te_jauge_id'] => Effet.new(data['te_variation_absolue'].to_i, data['te_variation_pourcentage'].to_f))
			end
		rescue Mysql::Error => e
			puts e
		ensure
			dbh.close if dbh
		end
	end
	
	# Permet de générer les effets d'un événement
	def genererEffetEvenement
		begin
			dbh = Mysql.new($host, $user, $mdp, $bdd)
			res = dbh.query("SELECT ee_operation_id, ee_jauge_id, ee_variation_absolue, ee_variation_pourcentage, eo_destination
							FROM ideo_evenement_effet
							JOIN ideo_evenement_operation ON eo_id = ee_operation_id
							ORDER BY RAND()
							LIMIT 1")
			while(data = res.fetch_hash())
				@idEvenement = data['ee_operation_id'].to_i
				@destination = data['eo_destination'].to_i
				@listeEffet.merge!(data['ee_jauge_id'] => Effet.new(data['ee_variation_absolue'].to_i, data['ee_variation_pourcentage'].to_f))
			end
		rescue Mysql::Error => e
			puts e
		ensure
			dbh.close if dbh
		end
	end
	
end

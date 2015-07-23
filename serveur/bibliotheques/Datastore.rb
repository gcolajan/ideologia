require 'singleton'

class Datastore
  include Singleton

  def initialize()
    # Loading our JSON data file

    # Actually, we translate our queries into this class
    begin
      @dbh = Mysql.new($host, $user, $mdp, $bdd)
    rescue Mysql::Error => e
      puts e
    end
  end

  # Returns an array with the ID of the chosen operations
  def getOperations(ideology, nbNeg, nbRequired, maxCost)

    operations = []

    if (nbNeg > 0)
      req = @dbh.query('
        SELECT toc_operation_id
        FROM ideo_territoire_operation_cout
        WHERE toc_ideologie_id = '+ideology.to_s+'
        AND toc_cout < 0
        ORDER BY RAND()
        LIMIT 1')

      operations.push(
          req.fetch_hash()['toc_operation_id']
      )
    end

    req = @dbh.query('
      SELECT toc_operation_id
      FROM ideo_territoire_operation_cout
      WHERE toc_ideologie_id = '+ideology.to_s+'
      AND toc_cout BETWEEN 0 AND '+maxCost.to_s+'
      ORDER BY RAND()
      LIMIT '+(nbRequired-nbNeg).to_s)

    while data = req.fetch_hash()
      operations.push(
          data['toc_operation_id']
      )
    end

    return operations
  end


  def getTerritoriesPopulation
    population = {}

    req = @dbh.query('
      SELECT terr_id, terr_position,
        (SELECT SUM(unite_population)
        FROM terr_unite
        WHERE unite_territoire = terr_id) AS popTerritoire
      FROM terr_territoire')

    while(data = req.fetch_hash())
      population.merge!(data['terr_id'].to_i => {'population' => data['popTerritoire'].to_i, 'position' => data['terr_position'].to_i})
    end

    return population
  end


  def getIdeologies
    ideologies = []
    req = @dbh.query('SELECT ideo_id FROM ideo_ideologie')
    while(data = req.fetch_hash())
      ideologies.push(data['ideo_id'].to_i)
    end

    return ideologies
  end


    def getJaugesInfo(ideology)
        jauges = {}
        req = @dbh.query('
          SELECT caract_jauge_id, caract_coeff_diminution, caract_coeff_augmentation, caract_ideal
          FROM ideo_jauge_caracteristique
          WHERE caract_ideo_id = '+ideology.to_s+'
          ORDER BY caract_jauge_id')
        while(data = req.fetch_hash())
          jauges.merge!(data['caract_jauge_id'] =>
            {
              'ideal' => data['caract_ideal'].to_f*100,
              'plus' => data['caract_coeff_augmentation'].to_f,
              'minus' => data['caract_coeff_diminution'].to_f
            }
          )
        end
      return jauges
    end


  def getOperationEffect(ideology, operation)

    cost = 0
    effects = {}

    req = @dbh.query('
      SELECT te_jauge_id, te_variation_absolue, te_variation_pourcentage, toc_cout
      FROM ideo_territoire_effet, ideo_territoire_operation_cout
      WHERE te_ideologie_id = '+ideology.to_s+'
      AND te_operation_id = '+operation.to_s+'
      AND toc_operation_id = te_operation_id
      AND toc_ideologie_id = te_ideologie_id')

    while(data = req.fetch_hash())
      cost = data['toc_cout'].to_i
      effects.merge!(data['te_jauge_id'] => {
          'abs' => data['te_variation_absolue'].to_i,
          'rel' => data['te_variation_pourcentage'].to_f}
      )
    end

    return cost, effects
  end

  def getRandomEventEffect()

    id = 0
    dest = 0
    effects = {}

    req = @dbh.query('
      SELECT ee_operation_id, ee_jauge_id, ee_variation_absolue, ee_variation_pourcentage, eo_destination
      FROM ideo_evenement_effet
      JOIN ideo_evenement_operation ON eo_id = ee_operation_id
      ORDER BY RAND()
      LIMIT 1')

    while (data = req.fetch_hash())
      id = data['ee_operation_id']
      dest = data['eo_destination']
      effects.merge!(data['ee_jauge_id'] => {
          'abs' => data['ee_variation_absolue'].to_i,
          'rel' => data['ee_variation_pourcentage'].to_f}
      )
    end

    return id, dest, effects
  end
end

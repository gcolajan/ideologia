require 'singleton'

class Datastore
  include Singleton

  def initialize()
    # Loading our JSON data file
    unless File.exist?('data.json')
      system('php data.json.php')
    end

    file = File.read('data.json')
    @data = JSON.parse(file)

    # Divide the operations in two set (positive & negative)
    sortOperations
  end

  # Returns an array with the ID of the chosen operations
  def getOperations(ideology, nbNeg, nbRequired)

    operations = []

    if (nbNeg > 0)
      items = @data['negativeOperations'][ideology.to_s].keys
      operations.push(items.sample(1)[0].to_i)
    end

    items = @data['positiveOperations'][ideology.to_s].keys
    items.sample(nbRequired-nbNeg).each{ |id|
      operations.push(id.to_i)
    }

    return operations
  end


  def getTerritoriesPopulation
    return @data['territories']
  end


  def getIdeologies
    return @data['ideology']
  end


    def getJaugesInfo(ideology)
      return @data['gauges'][ideology.to_s]
    end


  def getOperationEffect(ideology, operation)
    return @data['operations'][ideology.to_s][operation.to_s]['cost'], @data['operations'][ideology.to_s][operation.to_s]['effects']
  end

  def getRandomEventEffect
    items = @data['events'].keys
    id = items.sample(1)[0]
    event = @data['events'][id]

    return id.to_i, event['dest'], event['effects']
  end

  private
  def sortOperations
    @data['negativeOperations'] = {}
    @data['positiveOperations'] = {}

    @data['operations'].each{ |ideology, operations|
      @data['negativeOperations'][ideology] = {}
      @data['positiveOperations'][ideology] = {}
      operations.each{ |id, op|
        if op['cost'] > 0
          @data['positiveOperations'][ideology].merge!(id => op)
        else
          @data['negativeOperations'][ideology].merge!(id => op)
        end
      }
    }
  end
end

class CreateTerrTerritoires < ActiveRecord::Migration
  def change
    create_table :terr_territoires do |t|

      t.timestamps
    end
  end
end

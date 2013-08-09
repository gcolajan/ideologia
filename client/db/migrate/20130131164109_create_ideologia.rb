class CreateIdeologia < ActiveRecord::Migration
  def change
    create_table :ideologia do |t|

      t.timestamps
    end
  end
end

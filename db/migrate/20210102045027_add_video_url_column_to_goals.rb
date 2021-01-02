class AddVideoUrlColumnToGoals < ActiveRecord::Migration[6.0]
  def change
    add_column :goals, :video_url, :string
  end
end

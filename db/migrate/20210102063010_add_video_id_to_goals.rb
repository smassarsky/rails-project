class AddVideoIdToGoals < ActiveRecord::Migration[6.0]
  def change
    add_column :goals, :video_id, :integer
  end
end

class AddColumnsToMatchupsAndUsermatchups < ActiveRecord::Migration[6.0]
  def change
    add_column :matchups, :status, :string
    add_column :user_matchups, :draft_order, :integer
  end
end

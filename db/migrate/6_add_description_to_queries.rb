Sequel.migration do
  change do
    add_column :queries, :description, String
  end
end

Sequel.migration do
  change do
    add_column :queries, :name, String
  end
end

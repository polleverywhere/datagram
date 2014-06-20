Sequel.migration do
  change do
    add_column :queries, :owner, String
  end
end

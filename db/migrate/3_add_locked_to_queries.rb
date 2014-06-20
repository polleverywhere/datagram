Sequel.migration do
  change do
    add_column :queries, :locked_at, DateTime
  end
end

Sequel.migration do
  change do
    create_table(:folders) do
      primary_key :id
      String :name, :null => false
    end

    add_column :queries, :folder_id, Integer
  end
end

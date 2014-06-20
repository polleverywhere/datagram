Sequel.migration do
  change do
    create_table(:queries) do
      primary_key :id
      String :content, :null => false
      String :filter
    end
  end
end

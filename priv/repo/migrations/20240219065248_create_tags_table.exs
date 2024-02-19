defmodule Blog.Repo.Migrations.CreateTagsTable do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :tag, :string
      timestamps()
    end

    create unique_index(:tags, [:tag])
  end
end

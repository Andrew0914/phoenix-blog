defmodule Blog.Repo.Migrations.RemoveUniqueIndexFromUsername do
  use Ecto.Migration

  def change do
    drop index(:users, [:username])
  end
end

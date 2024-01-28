defmodule Blog.Repo.Migrations.UpdateUserAssoc do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :string, null: false, size: 20
    end

    alter table(:posts) do
      add :user_id, references(:users, on_delete: :delete_all)
    end

    alter table(:comments) do
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create unique_index(:users, [:username])
  end
end

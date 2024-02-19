defmodule Blog.Repo.Migrations.UpdatePostsVisibilityFields do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      remove :subtitle
      add :published_on, :utc_datetime
      add :visibility, :boolean, default: true
    end
  end
end

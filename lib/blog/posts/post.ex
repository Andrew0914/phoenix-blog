defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :content, :string
    field :published_on, :utc_datetime
    field :visibility, :boolean, default: true
    has_many :comments, Blog.Comments.Comment

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :content, :published_on, :visibility])
    |> validate_required([:title, :content, :published_on, :visibility])
    |> unique_constraint(:title)
  end
end

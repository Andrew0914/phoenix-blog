defmodule Blog.Posts.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :title, :string
    field :content, :string
    field :published_on, :utc_datetime
    field :visibility, :boolean, default: true

    has_many :comments, Blog.Comments.Comment
    belongs_to :user, Blog.Accounts.User
    many_to_many(:tags, Blog.Tags.Tag, join_through: "posts_tags", on_replace: :delete)
    has_one :cover_image, Blog.CoverImages.CoverImage, on_replace: :update

    timestamps()
  end

  @doc false
  def changeset(post, attrs, tags \\ []) do
    post
    |> cast(attrs, [:title, :content, :published_on, :visibility, :user_id])
    |> cast_assoc(:cover_image)
    |> validate_required([:title, :content, :published_on, :visibility, :user_id])
    |> unique_constraint(:title)
    |> foreign_key_constraint(:user_id)
    |> put_assoc(:tags, tags)
  end
end

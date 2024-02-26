defmodule Blog.Tags.Tag do
  @moduledoc """
  This module   provides functions to handle tags.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "tags" do
    field :tag, :string
    many_to_many :posts, Blog.Posts.Post, join_through: "posts_tags"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(tag, attrs) do
    tag
    |> cast(attrs, [:tag])
    |> validate_required([:tag])
  end
end

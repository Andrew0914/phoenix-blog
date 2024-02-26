defmodule Blog.CoverImages.CoverImage do
  @moduledoc """
  This module provides functions to handle cover images.
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "cover_images" do
    field :url, :string
    belongs_to :post, Blog.Posts.Post

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(cover_image, attrs) do
    cover_image
    |> cast(attrs, [:url, :post_id])
    |> validate_required([:url])
    |> foreign_key_constraint(:post_id)
  end
end

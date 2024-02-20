defmodule BlogWeb.PostHTML do
  alias Blog.Accounts.User
  use BlogWeb, :html

  embed_templates "post_html/*"
  embed_templates "tag_html/tag_form.html"

  @doc """
  Renders a post form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :tag_options, :any
  attr :current_user, User

  def post_form(assigns)
end

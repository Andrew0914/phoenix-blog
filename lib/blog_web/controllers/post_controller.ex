defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  alias Blog.Tags
  alias Blog.Comments
  alias Blog.Posts
  alias Blog.Posts.Post

  plug :require_user_owns_post when action in [:edit, :update, :delete]
  plug :require_authenticated_user when action in [:new, :create]
  plug :requere_user_own_comment when action in [:edit_comment, :update_comment, :delete_comment]

  defp require_authenticated_user(conn, _params) do
    if conn.assigns[:current_user] != nil do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to create a post.")
      |> redirect(to: ~p"/users/log_in")
      |> halt()
    end
  end

  defp require_user_owns_post(conn, _params) do
    post_id = String.to_integer(conn.path_params["id"])
    post = Posts.get_post!(post_id)

    if conn.assigns[:current_user].id == post.user_id do
      conn
    else
      conn
      |> put_flash(:error, "You can only edit or delete your own posts.")
      |> redirect(to: ~p"/posts/#{post_id}")
      |> halt()
    end
  end

  defp requere_user_own_comment(conn, _params) do
    comment_id = String.to_integer(conn.path_params["comment_id"])
    comment = Comments.get_comment!(comment_id)

    if conn.assigns[:current_user].id == comment.user_id do
      conn
    else
      conn
      |> put_flash(:error, "You can only edit or delete your own comments.")
      |> redirect(to: ~p"/posts/#{comment.post_id}")
      |> halt()
    end
  end

  def index(conn, params) do
    selected_tag = params["tag"]

    if selected_tag != nil do
      tag = Tags.get_tag!(selected_tag)
      posts = tag |> Tags.get_posts() |> Enum.map(&Posts.get_post!/1)

      render(conn, :index, posts: posts)
    else
      title = params["title"] || ""
      posts = Posts.list_posts(title)
      render(conn, :index, posts: posts)
    end
  end

  def new(conn, params) do
    changeset = Posts.change_post(%Post{})
    tag_changeset = Tags.change_tag(%Tags.Tag{})

    new_tag_id = Map.get(params, "new_tag_id", "-1") |> String.to_integer()

    render(conn, :new,
      changeset: changeset,
      tag_options: tag_options([new_tag_id]),
      tag_changeset: tag_changeset
    )
  end

  def create(conn, %{"post" => post_params}) do
    tags = Map.get(post_params, "tag_ids", []) |> Enum.map(&Tags.get_tag!/1)
    tag_changeset = Tags.change_tag(%Tags.Tag{})

    case Posts.create_post(post_params, tags) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new,
          changeset: changeset,
          tag_options: tag_options(Enum.map(tags, & &1.id)),
          tag_changeset: tag_changeset
        )
    end
  end

  def show(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    new_comment_changeset = Comments.change_comment(%{%Comments.Comment{} | post_id: post.id})
    render(conn, :show, post: post, new_comment_changeset: new_comment_changeset)
  end

  def edit(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    changeset = Posts.change_post(post)
    render(conn, :edit, post: post, changeset: changeset, tag_options: tag_options())
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)
    tags = Map.get(post_params, "tag_ids", []) |> Enum.map(&Tags.get_tag!/1)

    case Posts.update_post(post, post_params, tags) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit,
          post: post,
          changeset: changeset,
          tag_options: tag_options(Enum.map(tags, & &1.id))
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    post = Posts.get_post!(id)
    {:ok, _post} = Posts.delete_post(post)

    conn
    |> put_flash(:info, "Post deleted successfully.")
    |> redirect(to: ~p"/posts")
  end

  # comments
  def create_comment(conn, params) do
    case Comments.create_comment(params["comment"]) do
      {:ok, _comment} ->
        conn
        |> put_flash(:info, "Comment added successfully.")
        |> redirect(to: ~p"/posts/#{params["id"]}")

      {:error, _} ->
        conn
        |> put_flash(:error, "Cant and comment, try again!")
        |> redirect(to: ~p"/posts/#{params["id"]}")
    end
  end

  def delete_comment(conn, params) do
    comment = Comments.get_comment!(params["comment_id"])

    {:ok, _comment} = Comments.delete_comment(comment)

    post_id = params["id"]

    conn
    |> put_flash(:info, "Commen deleted successfully.")
    |> redirect(to: ~p"/posts/#{post_id}")
  end

  def edit_comment(conn, params) do
    comment = Comments.get_comment!(params["comment_id"])
    changeset = Comments.change_comment(comment)
    render(conn, :edit_comment, comment: comment, changeset: changeset)
  end

  def update_comment(conn, %{"comment" => comment_params, "comment_id" => comment_id}) do
    comment = Comments.get_comment!(comment_id)

    case Comments.update_comment(comment, comment_params) do
      {:ok, comment} ->
        conn
        |> put_flash(:info, "Comment updated successfully.")
        |> redirect(to: ~p"/posts/#{comment.post_id}")

      {:error, _} ->
        conn
        |> put_flash(:error, "Cant update comment")
        |> redirect(to: ~p"/posts/#{comment.post_id}")
    end
  end

  ## TAGS
  defp tag_options(selected_ids \\ []) do
    Tags.list_tags()
    |> Enum.map(fn tag ->
      [key: tag.tag, value: tag.id, selected: tag.id in selected_ids]
    end)
  end
end

defmodule BlogWeb.PostController do
  use BlogWeb, :controller

  alias Blog.Comments
  alias Blog.Posts
  alias Blog.Posts.Post

  def index(conn, params) do
    title = params["title"] || ""
    posts = Posts.list_posts(title)
    render(conn, :index, posts: posts)
  end

  def new(conn, _params) do
    changeset = Posts.change_post(%Post{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"post" => post_params}) do
    case Posts.create_post(post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post created successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
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
    render(conn, :edit, post: post, changeset: changeset)
  end

  def update(conn, %{"id" => id, "post" => post_params}) do
    post = Posts.get_post!(id)

    case Posts.update_post(post, post_params) do
      {:ok, post} ->
        conn
        |> put_flash(:info, "Post updated successfully.")
        |> redirect(to: ~p"/posts/#{post}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, post: post, changeset: changeset)
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
    IO.inspect(params)
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
end

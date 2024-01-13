defmodule BlogWeb.PostControllerTest do
  use BlogWeb.ConnCase

  import Blog.PostsFixtures

  @create_attrs %{content: "some body", title: "some title", subtitle: "some subtitle"}
  @update_attrs %{
    content: "some updated body",
    title: "some updated title",
    subtitle: "some updated subtitle"
  }
  @invalid_attrs %{content: nil, title: nil, subtitle: nil}

  describe "index" do
    test "lists all posts", %{conn: conn} do
      conn = get(conn, ~p"/posts")
      assert html_response(conn, 200) =~ "Listing Posts"
    end
  end

  describe "new post" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/posts/new")
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "create post" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/posts", post: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/posts/#{id}"

      conn = get(conn, ~p"/posts/#{id}")
      assert html_response(conn, 200) =~ "Post #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/posts", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "edit post" do
    setup [:create_post]

    test "renders form for editing chosen post", %{conn: conn, post: post} do
      conn = get(conn, ~p"/posts/#{post}/edit")
      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "update post" do
    setup [:create_post]

    test "redirects when data is valid", %{conn: conn, post: post} do
      conn = put(conn, ~p"/posts/#{post}", post: @update_attrs)
      assert redirected_to(conn) == ~p"/posts/#{post}"

      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ "some updated body"
    end

    test "renders errors when data is invalid", %{conn: conn, post: post} do
      conn = put(conn, ~p"/posts/#{post}", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "delete post" do
    setup [:create_post]

    test "deletes chosen post", %{conn: conn, post: post} do
      conn = delete(conn, ~p"/posts/#{post}")
      assert redirected_to(conn) == ~p"/posts"

      assert_error_sent 404, fn ->
        get(conn, ~p"/posts/#{post}")
      end
    end
  end

  describe "search posts" do
    test "search for posts - non-matching", %{conn: conn} do
      post = post_fixture(title: "some")
      conn = get(conn, ~p"/posts", title: "Non-Matching")
      refute html_response(conn, 200) =~ post.title
    end

    test "search for posts - exact match", %{conn: conn} do
      post = post_fixture(title: "some title")
      conn = get(conn, ~p"/posts", title: "some title")
      assert html_response(conn, 200) =~ post.title
    end

    test "search for posts - partial match", %{conn: conn} do
      post = post_fixture(title: "some title")
      conn = get(conn, ~p"/posts", title: "itl")
      assert html_response(conn, 200) =~ post.title
    end
  end

  defp create_post(_) do
    post = post_fixture()
    %{post: post}
  end
end

defmodule RadiatorWeb.Admin.PodcastController do
  use RadiatorWeb, :controller

  alias Radiator.Directory
  alias Radiator.Directory.Podcast
  alias Radiator.Directory.Editor

  action_fallback RadiatorWeb.FallbackController

  def index(conn, _params) do
    user = authenticated_user(conn)
    podcasts = Editor.list_podcasts_with_episode_counts(user, conn.assigns.current_network)
    render(conn, "index.html", podcasts: podcasts)
  end

  def new(conn, _params) do
    # FIXME: change the source for the changesets
    changeset = Editor.Manager.change_podcast(%Podcast{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"podcast" => podcast_params}) do
    user = authenticated_user(conn)

    case Editor.create_podcast(user, conn.assigns.current_network, podcast_params) do
      {:ok, podcast} ->
        conn
        |> put_flash(:info, "podcast created successfully.")
        |> redirect(
          to: Routes.admin_network_podcast_path(conn, :show, podcast.network_id, podcast)
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    with user <- authenticated_user(conn),
         {:ok, podcast} <- Editor.get_podcast(user, id) do
      # FIXME: only draft episodes, probably bring over the directory options semantic
      draft_episodes = Editor.list_episodes(user, podcast)

      published_episodes =
        Directory.list_episodes(%{
          podcast: podcast,
          order_by: :published_at,
          order: :desc
        })

      published_ids =
        published_episodes
        |> Enum.map(fn episode -> episode.id end)

      draft_episodes =
        draft_episodes
        |> Enum.reject(fn episode -> episode.id in published_ids end)

      render(conn, "show.html",
        podcast: podcast,
        published_episodes: published_episodes,
        draft_episodes: draft_episodes
      )
    end
  end

  def edit(conn, %{"id" => id}) do
    user = authenticated_user(conn)
    {:ok, podcast} = Editor.get_podcast(user, id)
    changeset = Editor.Manager.change_podcast(podcast)

    render(conn, "edit.html", podcast: podcast, changeset: changeset)
  end

  def update(conn, %{"id" => id, "podcast" => podcast_params} = params) do
    user = authenticated_user(conn)
    {:ok, podcast} = Editor.get_podcast(user, id)

    case Map.get(params, "button_action", "change") do
      "change" ->
        case Editor.Manager.update_podcast(podcast, podcast_params) do
          {:ok, podcast} ->
            conn
            |> put_flash(:info, "podcast updated successfully.")
            |> redirect(
              to: Routes.admin_network_podcast_path(conn, :show, podcast.network_id, podcast)
            )

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "edit.html", podcast: podcast, changeset: changeset)
        end

      "delete" ->
        case Editor.delete_podcast(user, podcast) do
          {:ok, podcast} ->
            conn
            |> put_flash(:info, "podcast '#{podcast.title} - #{podcast.subtitle}' deleted")
            |> redirect(to: Routes.admin_network_path(conn, :show, podcast.network_id))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "edit.html", podcast: podcast, changeset: changeset)
        end
    end
  end
end

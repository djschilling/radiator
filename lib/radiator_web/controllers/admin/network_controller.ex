defmodule RadiatorWeb.Admin.NetworkController do
  use RadiatorWeb, :controller

  alias Radiator.Directory
  alias Directory.Network
  alias Directory.Editor

  def index(conn, _params) do
    networks = Directory.list_networks()
    render(conn, "index.html", networks: networks)
  end

  def new(conn, _params) do
    changeset = Editor.Owner.change_network(%Network{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"network" => network_params}) do
    user = Guardian.Plug.current_resource(conn)

    case Editor.Owner.create_network(user, network_params) do
      {:ok, %{network: network}} ->
        conn
        |> put_flash(:info, "Network created successfully.")
        |> redirect(to: Routes.admin_network_path(conn, :show, network.id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    network = Directory.get_network!(id)

    podcasts = Directory.list_podcasts(network)

    render(conn, "show.html",
      network: network,
      podcasts: podcasts
    )
  end

  def edit(conn, %{"id" => id}) do
    network = Directory.get_network!(id)
    changeset = Editor.Owner.change_network(network)

    render(conn, "edit.html", network: network, changeset: changeset)
  end

  def update(conn, %{"id" => id, "network" => network_params}) do
    network = Directory.get_network!(id)

    case Editor.Owner.update_network(network, network_params) do
      {:ok, network} ->
        conn
        |> put_flash(:info, "network updated successfully.")
        |> redirect(to: Routes.admin_network_path(conn, :show, network))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", network: network, changeset: changeset)
    end
  end
end
defmodule RadiatorWeb.UserSettingsController do
  use RadiatorWeb, :controller

  alias Radiator.Auth

  action_fallback RadiatorWeb.Api.FallbackController

  def usersettings_form(conn, _params) do
    render(conn, "usersettings.html", changeset: Auth.Register.change_user(%Auth.User{}))
  end

  def usersettings(conn, params) do
    # user_map = params["user"]

    # cond do
    #   user_map["password"] != user_map["password_repeat"] ->
    #     conn
    #     |> put_flash(:error, "Passwords don't match.")
    #     |> render("signup.html", changeset: Auth.Register.change_user(%Auth.User{}, user_map))

    #   true ->
    #     case Auth.Register.create_user(user_map) do
    #       {:ok, user} ->
    #         user
    #         |> Auth.Email.welcome_email(email_configuration_url(conn, user))
    #         |> Radiator.Mailer.deliver_later()

    #         conn
    #         |> sign_in_valid_user(
    #           user,
    #           "Welcome #{user.name}! A confirmation email has been sent to #{user.email} - please follow the contained link to finish the signup process."
    #         )

    #       {:error, %Ecto.Changeset{} = changeset} ->
    #         conn
    #         |> put_flash(:error, "There were problems creating your account.")
    #         |> render("signup.html", changeset: changeset)
    #     end
    # end
  end
end

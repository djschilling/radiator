defmodule RadiatorWeb.Resolvers.Session do
  def get_authenticated_session(
        _parent,
        %{username_or_email: username_or_email, password: password},
        _resolution
      ) do
    case Radiator.Auth.Register.get_user_by_credentials(username_or_email, password) do
      nil ->
        {:error, "Invalid credentials"}

      valid_user ->
        token = Radiator.Auth.Guardian.api_session_token(valid_user)

        {:ok,
         %{
           username: valid_user.name,
           token: token
         }}
    end
  end
end

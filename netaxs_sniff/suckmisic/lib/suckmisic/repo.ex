defmodule Suckmisic.Repo do
  use Ecto.Repo,
    otp_app: :suckmisic,
    adapter: Ecto.Adapters.Postgres
end

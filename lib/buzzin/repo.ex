defmodule Buzzin.Repo do
  use Ecto.Repo,
    otp_app: :buzzin,
    adapter: Ecto.Adapters.Postgres
end

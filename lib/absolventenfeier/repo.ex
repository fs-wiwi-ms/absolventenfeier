defmodule Absolventenfeier.Repo do
  use Ecto.Repo,
    otp_app: :absolventenfeier,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Callback for dynamic configured options
  """
  def init(_, opts) do
    {:ok, opts}
  end
end

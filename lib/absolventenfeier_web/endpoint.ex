defmodule AbsolventenfeierWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :absolventenfeier

  socket "/socket", AbsolventenfeierWeb.UserSocket,
    websocket: true,
    longpoll: false

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :absolventenfeier,
    gzip: false,
    only: ~w(css fonts images js favicon.png manifest.json robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session,
    store: :cookie,
    key: "_absolventenfeier_key",
    signing_salt: "THszJmjd"

  plug AbsolventenfeierWeb.Router

  @doc """
  Callback invoked for dynamically configuring the endpoint.

  It receives the endpoint configuration and checks if
  configuration should be loaded from the system environment.
  """
  @spec init(atom, Keyword.t()) :: {:ok, Keyword.t()} | no_return
  def init(_key, config) do
    if config[:load_from_system_env] do
      secret_key_base =
        System.get_env("SECRET_KEY_BASE") ||
          raise("expected the SECRET_KEY_BASE environment variable to be set")

      config =
        config
        |> Keyword.put(:secret_key_base, secret_key_base)

      {:ok, config}
    else
      {:ok, config}
    end
  end
end

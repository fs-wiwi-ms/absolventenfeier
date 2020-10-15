defmodule Absolventenfeier.Request do
  require Logger

  @callback get(url :: String.t()) :: {:ok, Map} | {:error, String.t()}
  def get(url), do: get(url, %{})

  @callback get(url :: String.t(), params :: Map.t()) :: {:ok, Map} | {:error, String.t()}
  def get(url, params, header \\ []) do
    HTTPoison.get(
      url,
      header ++ [{"Content-Type", "application/json"}],
      params: params
    )
    |> handle_response
  end

  @callback post(url :: String.t(), params :: Map.t()) :: {:ok, Map} | {:error, String.t()}
  def post(url, params, headers \\ []) do
    HTTPoison.post(
      url,
      Jason.encode!(params),
      headers ++
        [
          {"Content-Type", "application/json"}
        ]
    )
    |> handle_response
  end

  defp handle_response({:ok, response}) do
    try do
      with {:status_code, "2" <> _} <- {:status_code, "#{response.status_code}"},
           {:json, {:ok, response_body}} <- {:json, Jason.decode(response.body)} do
        {:ok, response_body}
      else
        {:status_code, status_code} ->
          Logger.debug(inspect(status_code))
          Logger.debug(inspect(Jason.decode!(response.body)))
          {:error, "status_code"}

        {:json, {:error, message}} ->
          Logger.debug(inspect(message))
          {:error, "decode_failed"}
      end
    rescue
      Jason.DecodeError ->
        {:error, "decode_failed"}
    end
  end

  defp handle_response({:error, message}) do
    Logger.debug(inspect(message))
    {:error, "request_failed"}
  end
end

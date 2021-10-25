defmodule Absolventenfeier.Events.Pretix.Api do
  require Logger

  defp authorization_header, do: {"Authorization", "Token #{System.get_env("PRETIX_TOKEN")}"}
  defp pretix_host, do: System.get_env("PRETIX_HOST")

  @organizer "absolventenfeier"

  def create_voucher_code(event, vouchers) do
    uri =
      "/api/v1/organizers/#{@organizer}/events/#{event.pretix_event_slug}/vouchers/batch_create/"

    header = [{"Content-Type", "application/json"}, authorization_header()]

    body =
      Enum.map(vouchers, fn voucher ->
        comment =
          voucher.registration.user.fore_name <>
            " " <> voucher.registration.user.last_name <> " " <> voucher.ticket.name

        %{
          code: voucher.code,
          max_usages: voucher.ticket.max_per_user,
          block_quota: false,
          allow_ignore_quota: false,
          price_mode: "none",
          comment: comment,
          item: voucher.ticket.pretix_ticket_id
        }
      end)
      |> Jason.encode!()

    HTTPoison.post(
      pretix_host() <> uri,
      body,
      header,
      # 15 seconds
      recv_timeout: 15000
    )
    |> handle_response
  end

  # def delete_voucher_code(voucher) do

  #   uri = "/api/v1/organizers/absolventenfeier/events/#{voucher.event.pretix_event_slug}/vouchers/#{voucher.code}/"
  #   header = Map.merge(%{content_type: "application/json"}, authorization_header())

  #   HTTPoison.post(pretix_host() <> uri, %{}, header)
  #   |> handle_response
  # end

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

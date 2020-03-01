defmodule Absolventenfeier.Token do
  @moduledoc "Module for interacting with tokens (i.e. generating them)"
  @token_length 72

  @doc "Generate a token of the standard token size (#{@token_length} bytes)"
  @spec generate() :: Token.t()
  def generate() do
    @token_length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
  end
end

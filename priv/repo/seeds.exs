# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Absolventenfeier.Repo.insert!(%Absolventenfeier.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Absolventenfeier.Repo
alias Absolventenfeier.Event.{Term}
import Ecto.Query, warn: false
require Logger

terms = [:summer_term, :winter_term]

Enum.map(2020..2030, fn year ->
  Enum.map(terms, fn type ->
    term =
      Term
      |> where([t], t.year == ^year and t.type == ^type)
      |> Repo.one()

    case term do
      nil ->
        %Term{}
        |> Term.changeset(%{"year" => year, "type" => type})
        |> Repo.insert!()

      term ->
        term
    end
  end)
end)

if System.get_env("ENV_NAME") != "production" do
  Code.eval_file(
    __ENV__.file
    |> Path.dirname()
    |> Path.join("seeds_dev.exs")
  )
end

Logger.info("Success!")

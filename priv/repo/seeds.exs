# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     OpinionatedQuotesApi.Repo.insert!(%OpinionatedQuotesApi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
defmodule Seeder do
  alias OpinionatedQuotesApi.QuoteAPI.Quote

  def seed_quotes_from_json() do
    seed_quotes_from_json(Path.join(__DIR__, "quotes.json"))
  end
  def seed_quotes_from_json(flname) do
    get_quotes(flname)
    |> Enum.each(&(
      OpinionatedQuotesApi.Repo.insert!(
        %Quote{}, &1
      )
    ))
  end

  defp get_quotes(flname) do
    File.read!(flname)
    |> Poison.decode!
    |> Map.fetch!("quotes")
  end
end

Seeder.seed_quotes_from_json()

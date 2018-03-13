defmodule OpinionatedQuotesApi.Repo.Migrations.AlterQuoteType do
  use Ecto.Migration

  def change do
    alter table(:quotes) do
      modify :quote, :text
    end
  end
end

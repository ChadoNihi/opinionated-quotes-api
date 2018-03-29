defmodule OpinionatedQuotesApi.Repo.Migrations.AlterQuotesLangDefault do
  use Ecto.Migration

  def change do
    alter table(:quotes) do
      modify :lang, :string, default: "en"
    end
  end
end

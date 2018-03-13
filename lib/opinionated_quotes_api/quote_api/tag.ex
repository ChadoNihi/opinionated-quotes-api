defmodule OpinionatedQuotesApi.QuoteAPI.Tag do
  use Ecto.Schema
  # import Ecto.Changeset
  import Ecto.Query
  alias OpinionatedQuotesApi.QuoteAPI.Tag
  # alias OpinionatedQuotesApi.QuoteAPI.Quote
  alias OpinionatedQuotesApi.Repo


  schema "tags" do
    field :name, :string
    # many_to_many :quotes, Quote, join_through: "quotes_tags"

    timestamps()
  end

  # @doc false
  # def changeset(%Tag{} = tag, attrs) do
  #   tag
  #   |> cast(attrs, [:name])
  #   |> validate_required([:name])
  #   |> unique_constraint(:name)
  # end

  def insert_and_get_all(_changes, params) do
    case parse_all(params["tags"]) do
      [] ->
        {:ok, []}
      names ->
        now = NaiveDateTime.utc_now
        Repo.insert_all(
          Tag,
          Enum.map(names, &%{name: &1, inserted_at: now, updated_at: now}),
          on_conflict: :nothing
        )
        {:ok, Repo.all(from t in Tag, where: t.name in ^names)}
    end
  end

  def parse_all(nil), do: parse_all([])
  # match str
  def parse_all(tags) when is_binary(tags) do
    String.split(tags || "", ",")
    |> parse_all
  end
  def	parse_all(tags)	do
    Enum.map(tags, &String.trim/1)
    |> Enum.reject(& &1 == "")
    |> Enum.uniq()
	end
end

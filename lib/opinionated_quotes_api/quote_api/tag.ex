defmodule OpinionatedQuotesApi.QuoteAPI.Tag do
  use Ecto.Schema
  import Ecto.Changeset
  alias OpinionatedQuotesApi.QuoteAPI.Tag
  alias OpinionatedQuotesApi.QuoteAPI.Quote


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

  def	parse_tags_str(tags)	do
    String.split(tags || "", ",")
    |> Enum.map(&String.trim/1)
    |> Enum.reject(& &1 == "")
    |> Enum.uniq()
	end
end

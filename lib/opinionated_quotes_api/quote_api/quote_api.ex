defmodule OpinionatedQuotesApi.QuoteAPI.QuoteAPI do
  @moduledoc """
  The QuoteAPI context.
  """

  import Ecto.Query, warn: false
  alias OpinionatedQuotesApi.Helpers.Sanitizer
  alias OpinionatedQuotesApi.QuoteAPI.Quote
  alias OpinionatedQuotesApi.Repo

  @doc """
  Returns the list of quotes.

  ## Examples

      iex> list_quotes()
      [%Quote{}, ...]

  """
  def list_quotes(args) do
    build_query_from_args(args)
    |> Repo.all()
  end

  defp build_query_from_args(args) do
    rand = args[:rand]
    n = args[:n] || 1
    offset = args[:offset]
    author = args[:author] && Sanitizer.sanitize_sql_like(args[:author])
    tags = args[:tags]
    lang = Sanitizer.sanitize_sql_like(args[:lang]) |> String.downcase

    where = build_where(author, lang)

    q = from(q in Quote,
      where: ^where,
      offset: ^offset,
      limit: ^n,
      preload: [:tags]
    )

    if rand do
      # TODO: find a way to use faster TABLESAMPLE SYSTEM w/o raw query
      order_by(q, fragment("random()"))
    else
      q
    end
  end

  defp build_where(author, lang) do
    # https://hexdocs.pm/ecto/Ecto.Query.html#dynamic/2
    dynamic = true

    if author do
      dynamic([q], ilike(q.author, ^author) or ^dynamic)
    else
      dynamic
    end

    dynamic([q], (
      (is_nil(q.lang) and ^lang == "en")
      or q.lang == ^lang
    ) or ^dynamic)
  end
  # def list_quotes(false, n \\ 1, offset \\ 0) do
  #   Repo.all(Quote, (from q in Quote, limit: ^n, offset: ^offset))
  # end

  # def list_quotes(rand \\ true, n \\ 1, _) do
  #   case Ecto.Adapters.SQL.query(Quote, "select * from quotes offset random() * (select count(*) from quotes) limit #{n}") do
  #     {:ok, %{rows: rows}} ->
  #       Enum.map(rows, &Repo.load(Quote, &1))
  #     _ ->
  #       "error on fetching quote(s) from DB"
  #   end
  # end

  # @doc """
  # Gets a single quote.
  #
  # Raises `Ecto.NoResultsError` if the Quote does not exist.
  #
  # ## Examples
  #
  #     iex> get_quote!(123)
  #     %Quote{}
  #
  #     iex> get_quote!(456)
  #     ** (Ecto.NoResultsError)
  #
  # """
  # def get_quote!(id), do: Repo.get!(Quote, id)
  #
  # @doc """
  # Creates a quote.
  #
  # ## Examples
  #
  #     iex> create_quote(%{field: value})
  #     {:ok, %Quote{}}
  #
  #     iex> create_quote(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}
  #
  # """
  # def create_quote(attrs \\ %{}) do
  #   %Quote{}
  #   |> Quote.changeset(attrs)
  #   |> Repo.insert()
  # end
  #
  # @doc """
  # Updates a quote.
  #
  # ## Examples
  #
  #     iex> update_quote(quote, %{field: new_value})
  #     {:ok, %Quote{}}
  #
  #     iex> update_quote(quote, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}
  #
  # """
  # def update_quote(%Quote{} = quote, attrs) do
  #   quote
  #   |> Quote.changeset(attrs)
  #   |> Repo.update()
  # end
  #
  # @doc """
  # Deletes a Quote.
  #
  # ## Examples
  #
  #     iex> delete_quote(quote)
  #     {:ok, %Quote{}}
  #
  #     iex> delete_quote(quote)
  #     {:error, %Ecto.Changeset{}}
  #
  # """
  # def delete_quote(%Quote{} = quote) do
  #   Repo.delete(quote)
  # end
  #
  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking quote changes.
  #
  # ## Examples
  #
  #     iex> change_quote(quote)
  #     %Ecto.Changeset{source: %Quote{}}
  #
  # """
  # def change_quote(%Quote{} = quote) do
  #   Quote.changeset(quote, %{})
  # end
end

defmodule OpinionatedQuotesApi.QuoteAPI.QuoteAPI do
  @moduledoc """
  The QuoteAPI context.
  """

  import Ecto.Query, warn: false
  alias OpinionatedQuotesApi.Helpers.Sanitizer
  alias OpinionatedQuotesApi.QuoteAPI.Quote
  alias OpinionatedQuotesApi.QuoteAPI.Tag
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
    # |> filter_nil_fields_shallow()
  end

  defp build_query_from_args(args) do
    rand = args[:rand]
    n = args[:n]
    offset = args[:offset]
    author =
      args[:author] && String.trim(args[:author]) |> Sanitizer.sanitize_sql_like()
    tag_list = Tag.parse_all(args[:tags] || "")
    lang = args[:lang]
      && String.trim(args[:lang])
      |> String.downcase()
      |> Sanitizer.sanitize_sql_like()

    where = build_where(author, lang)

    q = from(q in Quote,
      preload: [:tags],
      join: tag in assoc(q, :tags),
      select: %{q | tags: fragment("array_agg(?)", tag.name)},
      where: ^where,
      offset: ^offset,
      limit: ^n,
      group_by: q.id,
      having: fragment("? <@ array_agg(?)", ^tag_list, tag.name)
    )

    if rand do
      # TODO: find a way to use faster TABLESAMPLE SYSTEM w/o raw query
      order_by(q, fragment("random()"))
    else
      q
    end
  end

  defp build_where(author, lang) do
    author = author && "%#{author}%"
    # https://hexdocs.pm/ecto/Ecto.Query.html#dynamic/2
    dynamic = false

    cond do
      author && lang ->
        dynamic([q], (ilike(q.author, ^author) and (is_nil(q.lang) or q.lang == "en")) or ^dynamic)
      author ->
        dynamic([q], ilike(q.author, ^author) or ^dynamic)
      lang ->
        dynamic([q], q.lang == ^lang or ^dynamic)
      :otherwise ->
        dynamic([q], (is_nil(q.lang) or q.lang == "en") or ^dynamic)
    end

      # if author do
      #   dynamic([q], ilike(q.author, ^author) or ^dynamic)
      # else
      #   dynamic
      # end

    # if lang do
    #   dynamic([q], q.lang == ^lang or ^dynamic)
    # else
    #   dynamic([q], ^dynamic or (is_nil(q.lang) or q.lang == "en"))
    # end
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

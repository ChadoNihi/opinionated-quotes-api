defmodule OpinionatedQuotesApiWeb.V1.QuoteController do
  use OpinionatedQuotesApiWeb, :controller
  alias OpinionatedQuotesApi.QuoteAPI.QuoteAPI
  import OpinionatedQuotesApiWeb.Router.Helpers, only: [v1_quote_path: 3]

  @n_max_re ~r/^max/i
  @true_vals_for_rand MapSet.new(["t", nil, "", "true", "1"])
  @max_n 100

  def get_quotes(conn, %{"rand" => _, "n" => _} = params) do
    case process_params(params) do
      kw_params when is_list(kw_params) ->
        json(conn, %{quotes: QuoteAPI.list_quotes(kw_params)})
      {:error, msg} ->
        put_status(conn, 400)
        |> json(%{error: msg})
    end
    # rand = if MapSet.member?(@true_vals_for_rand, raw_rand), do: true, else: false
    #
    # n = if Regex.match?(@n_max_re, raw_n), do: false, else: (case Integer.parse(raw_n) do
    #   {num, _} ->
    #     (if num > 0, do: num, else: 0)
    #   :error ->
    #     1
    # end)
    #
    # offset = case Integer.parse( Map.get(params, "offset", "0") ) do
    #   {num, _} ->
    #     if num >= 0, do: num, else: 0
    #   :error ->
    #     0
    # end
    #
    # author = case Map.get(params, "author") do
    #   nil -> nil
    #   raw -> String.trim(raw)
    # end
    #
    # lang = Map.get(params, "lang", "en")
    # |> String.trim()
    # |> String.downcase()
    #
    # json(
    #   conn,
    #   %{quotes: QuoteAPI.list_quotes(
    #     rand: rand, n: n, offset: offset, author: author, tags: params["tags"], lang: lang
    #   )}
    # )
  end
  def get_quotes(conn, params) do
    kw_params =
      Enum.reduce(params, [], fn {k, v}, acc ->  [{String.to_atom(k), v} | acc] end)

    redirect(conn, to: v1_quote_path(
      conn, :get_quotes, Keyword.merge([rand: "t", n: 1], kw_params)
    ))
  end

  defp process_params(%{"n" => raw_n} = params) do
    with {n} <- parse_n(raw_n),
      {offset} <- (case Integer.parse( Map.get(params, "offset", "0") ) do
        {num, _} ->
          {(if num >= 0, do: num, else: 0)}
        :error ->
          {:error, "'offset' query parameter should be a non-negative integer if present."}
      end)
    do
      rand = if MapSet.member?(@true_vals_for_rand, params["rand"]), do: true, else: false

      author = case Map.get(params, "author") do
        nil -> nil
        raw -> String.trim(raw)
      end

      lang = Map.get(params, "lang", "en")
      |> String.trim()
      |> String.downcase()

      [rand: rand, n: n, offset: offset, author: author, tags: params["tags"], lang: lang]
    else
      err_tup -> err_tup
    end
  end

  defp parse_n(raw_n) do
    if Regex.match?(@n_max_re, raw_n), do: {@max_n}, else: (case Integer.parse(raw_n) do
      {num, _} ->
        {(if num > 0, do: num, else: 1)}
      :error ->
        {:error, "'n' query parameter (if present) should be a positive integer or 'max'."}
    end)
  end
end

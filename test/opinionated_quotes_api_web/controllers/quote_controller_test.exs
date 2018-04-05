defmodule OpinionatedQuotesApiWeb.QuoteControllerTest do
  use OpinionatedQuotesApiWeb.ConnCase
  # alias OpinionatedQuotesApi.QuoteAPI.Quote

  describe "GET v1_quote_path" do
    test "redirects on no params", %{conn: conn} do
      conn = get conn, v1_quote_path(conn, :get_quotes)
      assert response(conn, 302)
    end

    test "gets one quote", %{conn: conn} do
      response =
        get(conn, v1_quote_path(conn, :get_quotes, rand: "f", n: 1))
        |> json_response(200)

      assert length(response["quotes"]) === 1 and Map.has_key?(hd(response["quotes"]), "quote")
    end

    test "gets many quotes", %{conn: conn} do
      response =
        get(conn, v1_quote_path(conn, :get_quotes, rand: "f", n: "max"))
        |> json_response(200)

      assert length(response["quotes"]) > 1
    end

    test "gets quotes with no nil fields", %{conn: conn} do
      response =
        get(conn, v1_quote_path(conn, :get_quotes, rand: "f", n: "max"))
        |> json_response(200)

      assert length(response["quotes"]) > 1
      assert Enum.all?(response["quotes"], fn(q) ->
        Enum.all?(q, fn({_k, v}) -> v != nil end)
      end)
    end

    test "gets 10 quotes", %{conn: conn} do
      response =
        get(conn, v1_quote_path(conn, :get_quotes, rand: "f", n: "10"))
        |> json_response(200)

      assert length(response["quotes"]) === 10
    end

    test "gets quotes by tags", %{conn: conn} do
      tag_list = ["ethics", "antispeciesism"]

      response =
        get(conn, v1_quote_path(conn, :get_quotes, rand: "f", n: "max", tags: Enum.join(tag_list, ", ")))
        |> json_response(200)

      quotes = response["quotes"]

      assert length(quotes) > 0
      assert Enum.all?(quotes, fn(quote) ->
        Enum.all?(tag_list, &(&1 in quote["tags"]))
      end)
    end

    test "gets quotes by tags, case-insensitive", %{conn: conn} do
      raw_tag_list = ["ethiCs", "AntiSpeciesism"]
      tag_list = Enum.map(raw_tag_list, &String.downcase/1)

      response =
        get(conn, v1_quote_path(conn, :get_quotes, rand: "f", n: "max", tags: Enum.join(raw_tag_list, ", ")))
        |> json_response(200)

      quotes = response["quotes"]

      assert length(quotes) > 0
      assert Enum.all?(quotes, fn(quote) ->
        Enum.all?(tag_list, &(&1 in quote["tags"]))
      end)
    end

    test "gets an empty list when an unknown tag is present", %{conn: conn} do
      tag_list = ["ethics", "lifeissuffering"]

      response =
        get(conn, v1_quote_path(conn, :get_quotes, rand: "f", n: "max", tags: Enum.join(tag_list, ", ")))
        |> json_response(200)

      assert length(response["quotes"]) === 0
    end

    test "gets quotes with EN lang, case-insensitive", %{conn: conn} do
      re_en = ~r/^en$/i

      response =
        get(conn, v1_quote_path(conn, :get_quotes, rand: "f", n: "max", lang: "eN"))
        |> json_response(200)

      quotes = response["quotes"]

      assert length(quotes) > 0
      assert Enum.all?(quotes, fn(quote) ->
        quote["lang"] == nil or Regex.match?(re_en, quote["lang"])
      end)
    end

    test "gets quotes with a matching author", %{conn: conn} do
      surname = "Pearce"

      response =
        get(conn, v1_quote_path(conn, :get_quotes, rand: "f", n: "max", author: String.downcase(surname)))
        |> json_response(200)

      quotes = response["quotes"]

      assert length(quotes) > 0
      assert Enum.all?(quotes, fn(quote) ->
        quote["author"] =~ surname
      end)
    end

    test "gets quotes with a matching author, lang, and tags", %{conn: conn} do
      surname = "Pearce"
      lang = "en"
      re_en = Regex.compile!("^#{lang}$", "i")
      tag_list = ["ethics", "antispeciesism"]

      response =
        get(conn, v1_quote_path(conn, :get_quotes, rand: "f", n: "max", author: String.downcase(surname), lang: lang, tags: Enum.join(tag_list, ", ")))
        |> json_response(200)

      quotes = response["quotes"]

      assert length(quotes) > 0
      assert Enum.all?(quotes, fn(quote) ->
        quote["author"] =~ surname
        and (quote["lang"] == nil or Regex.match?(re_en, quote["lang"]))
        and Enum.all?(tag_list, &(&1 in quote["tags"]))
      end)
    end

    test "returns an error on corrupt 'n'", %{conn: conn} do
      response =
        get(conn, v1_quote_path(conn, :get_quotes, rand: "f", n: "jk77ggggg"))
        |> json_response(400)

      assert response["error"] =~ "'n' query parameter (if present) should be a positive integer or 'max'"
    end

    test "returns an error on corrupt 'offset'", %{conn: conn} do
      response =
        get(conn, v1_quote_path(conn, :get_quotes, rand: "f", n: 1, offset: "jk77ggggg"))
        |> json_response(400)

      assert response["error"] =~ "'offset' query parameter should be a non-negative integer if present"
    end
  end
end

defmodule OpinionatedQuotesApiWeb.QuoteControllerTest do
  use OpinionatedQuotesApiWeb.ConnCase
  # alias OpinionatedQuotesApi.QuoteAPI.Quote

  describe "api_v1_quote_path" do
    test "GET with no params redirects", %{conn: conn} do
      conn = get conn, api_v1_quote_path(conn, :get_quotes)
      assert response(conn, 302)
    end

    test "GET gets one quote", %{conn: conn} do
      response =
        get(conn, api_v1_quote_path(conn, :get_quotes, rand: "t", n: 1))
        |> json_response(200)

      assert length(response["quotes"]) === 1 and Map.has_key?(hd(response["quotes"]), "quote")
    end

    test "GET gets many quotes", %{conn: conn} do
      response =
        get(conn, api_v1_quote_path(conn, :get_quotes, rand: "t", n: "max"))
        |> json_response(200)

      assert length(response["quotes"]) > 1
    end

    test "GET return an error on corrupt 'n'", %{conn: conn} do
      response =
        get(conn, api_v1_quote_path(conn, :get_quotes, rand: "t", n: "jk77ggggg"))
        |> json_response(400)

      assert response["error"] =~ "'n' query parameter (if present) should be a positive integer or 'max'"
    end

    test "GET return an error on corrupt 'offset'", %{conn: conn} do
      response =
        get(conn, api_v1_quote_path(conn, :get_quotes, rand: "t", n: 1, offset: "jk77ggggg"))
        |> json_response(400)

      assert response["error"] =~ "'offset' query parameter should be a non-negative integer if present"
    end
  end
end

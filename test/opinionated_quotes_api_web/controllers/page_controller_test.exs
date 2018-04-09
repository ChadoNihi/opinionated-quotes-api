defmodule OpinionatedQuotesApiWeb.PageControllerTest do
  use OpinionatedQuotesApiWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Routes"
  end
end

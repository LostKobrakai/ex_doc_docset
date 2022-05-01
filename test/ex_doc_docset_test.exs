defmodule ExDocDocsetTest do
  use ExUnit.Case
  alias Exqlite.Basic, as: SQL

  import ExUnit.CaptureIO

  setup_all do
    capture_io(fn ->
      Mix.Project.in_project(:dummy, "test/fixture/dummy", fn _module ->
        Mix.Task.run("docs")
      end)
    end)

    {:ok, dummy: "test/fixture/dummy"}
  end

  test "callback", %{dummy: dummy} do
    {:ok, conn} = SQL.open(Path.join(dummy, "doc/dummy.docset/Contents/Resources/docSet.dsidx"))

    sql = """
    SELECT type, name, path
    FROM searchIndex
    WHERE type = 'Callback' and name = 'Dummy.Behaviour.callback/0';
    """

    assert {:ok, [_row], _columns} = SQL.exec(conn, sql) |> SQL.rows()

    SQL.close(conn)
  end

  test "private module", %{dummy: dummy} do
    {:ok, conn} = SQL.open(Path.join(dummy, "doc/dummy.docset/Contents/Resources/docSet.dsidx"))

    sql = """
    SELECT type, name, path
    FROM searchIndex
    WHERE name LIKE 'Dummy.Private%';
    """

    assert {:ok, [], _columns} = SQL.exec(conn, sql) |> SQL.rows()

    SQL.close(conn)
  end

  test "exception", %{dummy: dummy} do
    {:ok, conn} = SQL.open(Path.join(dummy, "doc/dummy.docset/Contents/Resources/docSet.dsidx"))

    sql = """
    SELECT type, name, path
    FROM searchIndex
    WHERE type = 'Exception' and name = 'Dummy.Error';
    """

    assert {:ok, [_row], _columns} = SQL.exec(conn, sql) |> SQL.rows()

    SQL.close(conn)
  end
end

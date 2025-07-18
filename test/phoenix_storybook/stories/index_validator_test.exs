defmodule PhoenixStorybook.Stories.IndexValidatorTest do
  use ExUnit.Case, async: true

  setup do
    [path: Path.expand("../../fixtures/indexes", __DIR__)]
  end

  test "with valid index it won't raise", %{path: path} do
    Code.compile_file("valid.index.exs", path)
  end

  test "with empty index it won't raise", %{path: path} do
    Code.compile_file("empty.index.exs", path)
  end

  test "with bad folder_icon it will raise", %{path: path} do
    assert_raise CompileError, ~r/icon must be a tuple 2, 3 or 4 items/, fn ->
      Code.compile_file("bad_folder_icon.index.exs", path)
    end
  end

  test "with bad folder_name it will raise", %{path: path} do
    assert_raise CompileError, ~r/folder_name must return a binary/, fn ->
      Code.compile_file("bad_folder_name.index.exs", path)
    end
  end

  test "with bad entry it will raise", %{path: path} do
    assert_raise CompileError, ~r/entry\("colors"\) icon is invalid/, fn ->
      Code.compile_file("bad_entry.index.exs", path)
    end
  end

  test "with bad entry index it will raise", %{path: path} do
    assert_raise CompileError, ~r/entry\("colors"\) index is invalid/, fn ->
      Code.compile_file("bad_entry_index.index.exs", path)
    end
  end

  test "with bad entry icon it will raise", %{path: path} do
    assert_raise CompileError, ~r/icon provider must be either :fa, :hero, or :local/, fn ->
      Code.compile_file("bad_entry_icon_provider.index.exs", path)
    end
  end

  test "with bad local icon class it will raise", %{path: path} do
    assert_raise CompileError, ~r/icon class must be a binary/, fn ->
      Code.compile_file("bad_local_icon_class.index.exs", path)
    end
  end

  test "with bad local icon tuple it will raise", %{path: path} do
    assert_raise CompileError, ~r/local icons only support 2 or 3 elem tuples/, fn ->
      Code.compile_file("bad_local_icon_tuple.index.exs", path)
    end
  end

  test "with bad index it will raise", %{path: path} do
    assert_raise CompileError, ~r/index must return an integer/, fn ->
      Code.compile_file("bad_index.index.exs", path)
    end
  end
end

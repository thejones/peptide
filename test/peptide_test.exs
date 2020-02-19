defmodule HTTPoison.Response do
  defstruct body: nil, headers: nil, status_code: nil
end

defmodule PeptideTest do
  use ExUnit.Case

  test "parses and puts dotenv config in the system environment" do
    Peptide.parse("foo=bar\nbar=foo")

    assert System.get_env("FOO") == "bar"
    assert System.get_env("BAR") == "foo"
  end

  test "parse can handle quotes with comments" do
    Peptide.parse(~s(foo="bar#" # comment))

    assert System.get_env("FOO") == "bar#"

    cleanup_env(["FOO"])
  end

  test "parse can ignore lines containing only comments" do
    assert Peptide.parse(~s(# comment))
  end

  test "parse handle escaped quotes" do
    Peptide.parse(~S(foo="\"awesome\""))

    assert System.get_env("FOO") == ~S("awesome")

    cleanup_env(["FOO"])
  end

  test "parse can handle values with an equals in them" do
    Peptide.parse(~S(foo="asdf=1=2"))

    assert System.get_env("FOO") == "asdf=1=2"

    cleanup_env(["FOO"])
  end

  test "it can parse .env in the current directory" do
    run_in_dir("test-env", fn ->
      File.write(".env", "elixir=awesome", [:write])
      Peptide.config()

      assert System.get_env("ELIXIR") == "awesome"

      cleanup_env(["ELIXIR"])
    end)
  end

  test "it can parse a succesful http response and set env vars" do
    %HTTPoison.Response{status_code: 200, body: body} = %HTTPoison.Response{
      body: "{\"important_value\":\"a_valid_token\"}",
      headers: [],
      status_code: 200
    }

    Peptide.parse_http(body)
    assert System.get_env("IMPORTANT_VALUE") == "a_valid_token"
    cleanup_env(["IMPORTANT_VALUE"])
  end

  defp run_in_dir(dir, func) do
    original_env = System.get_env() |> Map.keys()
    original_directory = File.cwd!()
    File.mkdir(dir)
    File.cd!(dir)

    func.()

    File.cd!(original_directory)
    File.rm_rf(dir)

    new_env = System.get_env() |> Map.keys()
    Enum.each(original_env -- new_env, &cleanup_env/1)
  end

  defp cleanup_env(keys) do
    Enum.each(keys, fn key ->
      System.delete_env(key)
    end)
  end
end

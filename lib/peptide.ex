defmodule Peptide do
  @key_value_delimeter "="

  @moduledoc """
  Provides explicit and auto loading of env files.

  ## Example

  The following will set the `FOO` environment variable with the value of `bar`.

  ```
  foo=bar
  ```

  You can define comments with `#` but can't use `#` in values without wrapping
  the value in double quotes.

  ```
  foo="#bar" # Comment
  ```
  """

  @doc """
  Loads the `.env` and the `Mix.env` specific env file.


  """
  def config do
    Application.ensure_started(:mix)
    [".env"] |> load
  end

  def http_config(url) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        parse_http(body)

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  @doc """
  Loads a list of env files.
  """
  def load(env_files) do
    for path <- env_files do
      if File.exists?(path) do
        File.read!(path) |> parse
      end
    end
  end

  def parse_http(items) do
    {:ok, data} = Jason.decode(items)

    Enum.each(data, fn {key, value} ->
      set_env(key, value)
    end)
  end

  @doc """
  Parses env formatted file.
  """
  def parse(content) do
    content |> get_pairs |> load_env
  end

  defp get_pairs(content) do
    content
    |> String.split("\n")
    |> Enum.reject(&blank_entry?/1)
    |> Enum.reject(&comment_entry?/1)
    |> Enum.map(&parse_line/1)
  end

  defp parse_line(line) do
    [key, value] =
      line
      |> String.trim()
      |> String.split(@key_value_delimeter, parts: 2)

    [key, parse_value(value)]
  end

  defp parse_value(value) do
    if String.starts_with?(value, "\"") do
      unquote_string(value)
    else
      value |> String.split("#", parts: 2) |> List.first()
    end
  end

  defp unquote_string(value) do
    value
    |> String.split(~r{(?<!\\)"}, parts: 3)
    |> Enum.drop(1)
    |> List.first()
    |> String.replace(~r{\\"}, ~S("))
  end

  defp load_env(pairs) when is_list(pairs) do
    Enum.each(pairs, fn [key, value] ->
      set_env(key, value)
    end)
  end

  defp set_env(key, value) do
    System.put_env(String.upcase(key), value)
  end

  defp blank_entry?(string) do
    string == ""
  end

  defp comment_entry?(string) do
    String.match?(string, ~r(^\s*#))
  end
end

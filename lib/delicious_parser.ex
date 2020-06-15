defmodule DeliciousParser do

  def filter_elements(document) do
    document
    |> String.split("\n")
    |> Enum.filter(fn line -> String.match?(line, ~r/<D(T|D)+/) end)
  end

  def strip_markup(lines) do
    Enum.map(lines, fn line ->
      case String.starts_with?(line, "<DT>") do
        true -> strip_link(line)
        false -> strip_comment(line)
      end
    end)
    |> List.flatten
  end

  defp strip_link(line) do
    String.replace(line, "<DT>", "")
    |> String.replace("<A", "")
    |> String.replace("</A>", "")
    |> String.trim
    |> String.split(">")
  end

  defp strip_comment(line) do
    String.replace(line, "<DD>", "")
  end

  def map_anchor(anchor) do
    String.split(anchor)
    |> Enum.map_reduce(%{}, fn a, acc ->
      { anchor, String.split(a, "=") |> map_href_props(acc) }
    end)
    |> elem(1)
  end

  defp map_href_props(props, map) do
    Map.put_new(map,
      List.first(props) |> String.downcase |> String.to_atom,
      List.last(props) |> String.replace("\"", ""))
  end

end

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
    |> List.to_string
    |> String.split(~r/ (?=href)/, trim: true)
  end

  defp strip_link(line) do
    String.replace(line, "<DT>", "")
    |> String.replace("<A", "")
    |> String.replace("</A>", "")
    |> String.trim
    |> String.split(">")
    |> List.update_at(1, &(" TITLE=\"#{&1}\" "))
  end

  defp strip_comment(line) do
    String.split(line, "<DD>")
    |> List.update_at(1, &("COMMENTS=\"#{&1}\" "))
  end

  def map_links(props) do
    Enum.map(props, fn p -> map_link_props(p) end)
  end

  def map_link_props(link) do
    props = String.split(link, ~r/(?<=" )/, trim: true)
    |> Enum.map_reduce(%{}, fn a, acc ->
      { link, String.split(a, "=") |> map_prop(acc) }
    end)
    |> elem(1)
    Map.put(props, :tags, Map.get(props, :tags) |> String.split(","))
  end

  defp map_prop(props, map) do
    Map.put_new(map,
      List.first(props) |> String.downcase |> String.to_atom,
      List.last(props) |> String.replace("\"", "") |> String.trim)
  end

end

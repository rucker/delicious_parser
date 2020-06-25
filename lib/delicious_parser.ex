defmodule DeliciousParser do
  import CSV

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
    |> List.flatten()
    |> List.to_string()
    |> String.split(~r/ (?=HREF)/, trim: true)
  end

  defp strip_link(line) do
    String.replace(line, "<DT>", "")
    |> String.replace("<A", "")
    |> String.replace("</A>", "")
    |> String.trim()
    |> String.split(">")
    |> List.update_at(1, &" TITLE=\"#{&1}\" ")
  end

  defp strip_comment(line) do
    String.split(line, "<DD>")
    |> List.update_at(1, &"COMMENTS=\"#{&1}\" ")
  end

  def map_links(links) do
    Enum.map(links, fn link -> map_link_props(link) end)
  end

  def map_link_props(link) do
    props =
      String.split(
        link,
        ~r/((?=\bHREF\b)|(?=\bADD_DATE\b)|(?=\bPRIVATE\b)|(?=\bTAGS\b)|(?=\bTITLE\b)|(?=\bCOMMENTS\b))/,
        trim: true
      )
      |> Enum.map_reduce(%{}, fn a, acc ->
        {link, String.split(a, "=", parts: 2) |> map_prop(acc)}
      end)
      |> elem(1)

    Map.put(props, :tags, [Map.get(props, :tags)])
  end

  defp map_prop(prop, map) do
    key =
      List.first(prop)
      |> String.downcase()
      |> String.to_atom()

    case key do
      :title ->
        Map.put_new(
          map,
          key,
          List.last(prop)
          |> String.trim()
          |> String.replace("\"", "", global: false)
          |> String.reverse()
          |> String.replace("\"", "", global: false)
          |> String.reverse()
          |> String.replace("\"", "'")
        )

      :add_date ->
        Map.put_new(
          map,
          key,
          List.last(prop)
          |> String.replace("\"", "")
          |> String.trim()
          |> String.to_integer()
          |> DateTime.from_unix!(:second)
          |> DateTime.to_string()
        )

      _ ->
        Map.put_new(
          map,
          key,
          List.last(prop) |> String.replace("\"", "") |> String.trim()
        )
    end
  end

  def encode_csv(bookmarks) do
    header =
      [["href", "title", "add_date", "private", "comments", "tags"]] |> encode |> Enum.to_list()

    contents =
      bookmarks
      |> Enum.map(fn b ->
        [b[:href], b[:title], b[:add_date], b[:private], b[:comments], b[:tags]]
      end)

    [List.first(header) | contents |> encode |> Enum.to_list()]
  end

  def parse(filename) do
    out_filename = String.replace(filename, "html", "csv")

    if File.exists?(out_filename) do
      File.rm(out_filename)
    end

    out_file = File.open!(out_filename, [:write, :append, :utf8])

    File.read!(filename)
    |> filter_elements
    |> strip_markup
    |> map_links
    |> encode_csv
    |> Enum.each(fn link -> IO.write(out_file, link) end)
  end
end

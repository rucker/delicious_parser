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

  end

end

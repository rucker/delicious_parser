defmodule DeliciousParser do

  def open(file_name) do
    File.read(file_name)
  end

  def filter_elements(file_name) do
    File.open(file_name)
    |> String.split("\n")
    |> Enum.filter(fn line -> String.match?(line, ~r/<D(T|D)+/) end)
  end

  def strip_markup(lines) do
    Enum.map(lines, fn line -> String.replace(line, "<DT>", "")
    |> String.replace("<A", "")
    |> String.replace("</A>", "") end)
    |> List.first
    |> String.trim
    |> String.split(">")

  end

end

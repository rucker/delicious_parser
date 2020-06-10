defmodule DeliciousParser do
  def open(file_name) do
    File.read(file_name)
  end

  def filter_elements(file_name) do
    File.open(file_name)
    |> String.split("\n")
    |> Enum.filter(fn line -> String.match?(line, ~r/<D(T|D)+/) end)
  end
end

defmodule DeliciousParser do
  def open(file_name) do
    File.read(file_name)
  end

  def get_elements(file_name) do
    File.open(file_name)
    |> String.split
    |> Enum.filter(fn line -> String.match?(line, ~r/<DT+/) end)
  end
end

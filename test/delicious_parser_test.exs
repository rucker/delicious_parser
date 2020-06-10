defmodule DeliciousParserTest do
  use ExUnit.Case
  use Placebo

  doctest DeliciousParser

  setup do
    document = """
			<!DOCTYPE NETSCAPE-Bookmark-file-1>
			<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
			<!-- This is an automatically generated file.
			It will be read and overwritten.
			Do Not Edit! -->
			<TITLE>Bookmarks</TITLE>
			<H1>Bookmarks</H1>
			<DL><p>
		"""
    allow(File.open(any()), return: document, meck_options: [:passthrough])

    [document: document]
  end

  test "ignores html elements that don't match <DT> or <DD>" do

		assert DeliciousParser.get_elements("some_file") == []
	end

  end
end

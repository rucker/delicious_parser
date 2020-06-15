defmodule DeliciousParserTest do
  use ExUnit.Case

  @document """
  <!DOCTYPE NETSCAPE-Bookmark-file-1>
  <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
  <!-- This is an automatically generated file.
  It will be read and overwritten.
  Do Not Edit! -->
  <TITLE>Bookmarks</TITLE>
  <H1>Bookmarks</H1>
  <DL><p>
  <DT><A href="http://some-url.org" ADD_DATE=\"1498938954\" PRIVATE=\"1\" TAGS=\"foo\">Hey, a description!</A>
  <DD>Some comments
  <DT><A href="http://another-url.org" ADD_DATE=\"1486993837\" PRIVATE=\"0\" TAGS=\"bar,baz\">About the turbo encabulator</A>
  """

  doctest DeliciousParser

  test "filters html elements matching <DT> or <DD>" do
    assert DeliciousParser.filter_elements(@document) == [ ~s|<DT><A href="http://some-url.org" ADD_DATE=\"1498938954\" PRIVATE=\"1\" TAGS=\"foo\">Hey, a description!</A>|, ~s|<DD>Some comments|, ~s|<DT><A href="http://another-url.org" ADD_DATE=\"1486993837\" PRIVATE=\"0\" TAGS=\"bar,baz\">About the turbo encabulator</A>| ]
	end

  test "strips markup from lines, leaving only properties and values" do
    input = DeliciousParser.filter_elements(@document)

    assert DeliciousParser.strip_markup(input) == [ "href=\"http://some-url.org\" ADD_DATE=\"1498938954\" PRIVATE=\"1\" TAGS=\"foo\"", "Hey, a description!", "Some comments", "href=\"http://another-url.org\" ADD_DATE=\"1486993837\" PRIVATE=\"0\" TAGS=\"bar,baz\"", "About the turbo encabulator" ]
  end

end

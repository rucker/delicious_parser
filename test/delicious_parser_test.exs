defmodule DeliciousParserTest do
  use ExUnit.Case

  doctest DeliciousParser

  test "filters html elements matching <DT> or <DD>" do
    document = """
    <!DOCTYPE NETSCAPE-Bookmark-file-1>
    <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
    <!-- This is an automatically generated file.
    It will be read and overwritten.
    Do Not Edit! -->
    <TITLE>Bookmarks</TITLE>
    <H1>Bookmarks</H1>
    <DL><p>
    <DT><A href="http://some-url.org"</A>
    <DD>Hey, a description!
    """
    assert DeliciousParser.filter_elements(document) == [ ~s|<DT><A href="http://some-url.org"</A>|, ~s|<DD>Hey, a description!| ]
	end

  test "strips markup from lines, leaving only properties and values" do
    input = [ "<DT><A href=\"http://some-url.org\" ADD_DATE=\"1498938954\" PRIVATE=\"1\" TAGS=\"foo\">Hey, a description!</A>" ]

    assert DeliciousParser.strip_markup(input) == [ "href=\"http://some-url.org\" ADD_DATE=\"1498938954\" PRIVATE=\"1\" TAGS=\"foo\"", "Hey, a description!" ]
  end

end

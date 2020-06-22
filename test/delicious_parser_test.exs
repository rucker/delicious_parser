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
  <DT><A href="http://some-url.org" ADD_DATE=\"1498938954\" PRIVATE=\"1\" TAGS=\"foo\">Link title</A>
  <DD>Some comments
  <DT><A href="http://another-url.org" ADD_DATE=\"1486993837\" PRIVATE=\"0\" TAGS=\"bar,baz\">About the turbo encabulator</A>
  </DL><p>
  """

  @link_with_comments "href=\"http://some-url.org\" ADD_DATE=\"1498938954\" PRIVATE=\"1\" TAGS=\"foo\" TITLE=\"Link title\" COMMENTS=\"Some comments\""
  @simple_link "href=\"http://another-url.org\" ADD_DATE=\"1486993837\" PRIVATE=\"0\" TAGS=\"bar,baz\" TITLE=\"About the turbo encabulator\" "
  @link_with_urlparams "href=\"http://url-with-params.org/?p1=foo&p2=bar\" ADD_DATE=\"1486993841\" PRIVATE=\"0\" TAGS=\"qux\" TITLE=\"This is a tricksy link\" "

  @link_with_comments_map %{
    href: "http://some-url.org",
    add_date: "1498938954",
    private: "1",
    tags: ["foo"],
    comments: "Some comments",
    title: "Link title"
  }
  @simple_link_map %{
    href: "http://another-url.org",
    add_date: "1486993837",
    private: "0",
    title: "About the turbo encabulator",
    tags: ["bar,baz"]
  }
  @link_with_urlparams_map %{
    href: "http://url-with-params.org/?p1=foo&p2=bar",
    add_date: "1486993841",
    private: "0",
    tags: ["qux"],
    title: "This is a tricksy link"
  }
  doctest DeliciousParser

  test "filters html elements matching <DT> or <DD>" do
    assert DeliciousParser.filter_elements(@document) == [
             ~s|<DT><A href="http://some-url.org" ADD_DATE=\"1498938954\" PRIVATE=\"1\" TAGS=\"foo\">Link title</A>|,
             ~s|<DD>Some comments|,
             ~s|<DT><A href="http://another-url.org" ADD_DATE=\"1486993837\" PRIVATE=\"0\" TAGS=\"bar,baz\">About the turbo encabulator</A>|
           ]
  end

  test "strips markup from lines, leaving only properties and values" do
    input = DeliciousParser.filter_elements(@document)

    assert DeliciousParser.strip_markup(input) == [
             @link_with_comments,
             @simple_link
           ]
  end

  test "maps link properties" do
    input = [
      @simple_link,
      @link_with_comments,
      @link_with_urlparams
    ]

    assert DeliciousParser.map_links(input) == [
             @simple_link_map,
             @link_with_comments_map,
             @link_with_urlparams_map
           ]
  end

  test "encodes links to CSV" do
    input = [
      @link_with_comments_map,
      @simple_link_map,
      @link_with_urlparams_map
    ]

    assert DeliciousParser.encode_csv(input) == [
             "href,title,add_date,private,comments,tags\r\n",
             "http://some-url.org,Link title,1498938954,1,Some comments,foo\r\n",
             "http://another-url.org,About the turbo encabulator,1486993837,0,,\"bar,baz\"\r\n",
             "http://url-with-params.org/?p1=foo&p2=bar,This is a tricksy link,1486993841,0,,qux\r\n"
           ]
  end
end

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
  <DT><A HREF="http://some-url.org" ADD_DATE=\"1498938954\" PRIVATE=\"1\" TAGS=\"foo\">Link title</A>
  <DD>Some comments
  <DT><A HREF="http://another-url.org" ADD_DATE=\"1486993837\" PRIVATE=\"0\" TAGS=\"bar,baz\">About the "Turbo Encabulator." What is this "thing" and why should I care?</A>
  </DL><p>
  """

  @link_with_comments "HREF=\"http://some-url.org\" ADD_DATE=\"1498938954\" PRIVATE=\"1\" TAGS=\"foo\" TITLE=\"Link title\" COMMENTS=\"Some comments\""
  @link_with_quotetitle "HREF=\"http://another-url.org\" ADD_DATE=\"1486993837\" PRIVATE=\"0\" TAGS=\"bar,baz\" TITLE=\"About the \"Turbo Encabulator.\" What is this \"thing\" and why should I care?\" "
  @link_with_urlparams "HREF=\"http://url-with-params.org/?p1=foo&p2=bar\" ADD_DATE=\"1486993841\" PRIVATE=\"0\" TAGS=\"qux\" TITLE=\"This is a tricksy link\" "

  @link_with_comments_map %{
    href: "http://some-url.org",
    add_date: "2017-07-01 19:55:54Z",
    private: "1",
    tags: ["foo"],
    comments: "Some comments",
    title: "Link title"
  }
  @link_with_quotetitle_map %{
    href: "http://another-url.org",
    add_date: "2017-02-13 13:50:37Z",
    private: "0",
    title: "About the 'Turbo Encabulator.' What is this 'thing' and why should I care?",
    tags: ["bar,baz"]
  }
  @link_with_urlparams_map %{
    href: "http://url-with-params.org/?p1=foo&p2=bar",
    add_date: "2017-02-13 13:50:41Z",
    private: "0",
    tags: ["qux"],
    title: "This is a tricksy link"
  }

  test "filters html elements matching <DT> or <DD>" do
    assert DeliciousParser.filter_elements(@document) == [
             ~s|<DT><A HREF="http://some-url.org" ADD_DATE=\"1498938954\" PRIVATE=\"1\" TAGS=\"foo\">Link title</A>|,
             ~s|<DD>Some comments|,
             ~s|<DT><A HREF="http://another-url.org" ADD_DATE=\"1486993837\" PRIVATE=\"0\" TAGS=\"bar,baz\">About the \"Turbo Encabulator.\" What is this \"thing\" and why should I care?</A>|
           ]
  end

  test "strips markup from lines, leaving only properties and values" do
    input = DeliciousParser.filter_elements(@document)

    assert DeliciousParser.strip_markup(input) == [
             @link_with_comments,
             @link_with_quotetitle
           ]
  end

  test "maps link properties" do
    input = [
      @link_with_quotetitle,
      @link_with_comments,
      @link_with_urlparams
    ]

    assert DeliciousParser.map_links(input) == [
             @link_with_quotetitle_map,
             @link_with_comments_map,
             @link_with_urlparams_map
           ]
  end

  test "encodes links to CSV" do
    input = [
      @link_with_comments_map,
      @link_with_quotetitle_map,
      @link_with_urlparams_map
    ]

    assert DeliciousParser.encode_csv(input) == [
             "href,title,add_date,private,comments,tags\r\n",
             "http://some-url.org,Link title,2017-07-01 19:55:54Z,1,Some comments,foo\r\n",
             "http://another-url.org,About the 'Turbo Encabulator.' What is this 'thing' and why should I care?,2017-02-13 13:50:37Z,0,,\"bar,baz\"\r\n",
             "http://url-with-params.org/?p1=foo&p2=bar,This is a tricksy link,2017-02-13 13:50:41Z,0,,qux\r\n"
           ]
  end
end

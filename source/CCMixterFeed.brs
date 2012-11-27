
Function loadFeed()

   aa = CreateObject("roAssociativeArray")
   aa.posteritems = CreateObject("roArray", 10, true)
   feedUrl = "http://ccmixter.org/api/query?datasource=topics&type=podcast&page=podcast&f=rss"
   
   http = NewHttp(feedUrl)

   print "url: " + http.Http.GetUrl()

   rsp = http.GetToStringWithRetry()

   xml=CreateObject("roXMLElement")
   if not xml.Parse(rsp) then
        print "Can't parse feed"
       return invalid
   endif
   
   For Each item In xml.channel.item
      title = item.title.GetText()
      author = item.GetNamedElements("dc:creator").GetText()
      description = processDescription(item.GetNamedElements("content:encoded").GetText())
      file = item.enclosure@url
      releaseDate = item.pubDate.GetText()
      song = CreateSong(title,author,description,"mp3", file, "pkg:/images/ccMpromo.png", releaseDate)
      aa.posteritems.push(song)
   End For
   
   return aa 
End Function

Function processDescription(description As String)
   reEle = CreateObject("roRegex", "<[^>]*>", "")
   reApost = CreateObject("roRegex", "\&\#8217;", "")
   reWhiteSpace = CreateObject("roRegex", "^[ \t]+|[ \t]+$", "")
   reEllipsis = CreateObject("roRegex", "&#8230;", "")
   reEM = CreateObject("roRegex", "&#8212;", "")
   reLF = CreateObject("roRegex", "\n|\r\n|\n\r|\r", "")
   reLFStar = CreateObject("roRegex", "\*[A-Z]", "")
   reQuot = CreateObject("roRegex", "&#822[0-1];", "")
   reExcessSpace = CreateObject("roRegex", " {2,}", "")

   descMarker = instr(0, description, "gd_description")
 
   startDesc = instr(descMarker, description, ">") + 1
   endDesc = instr(startDesc, description, "</div>")
   description = Mid(description, startDesc, endDesc - startDesc)
   description = reLF.ReplaceAll(description, " ")
   description = reLFStar.ReplaceAll(description, "\n")
   description = reEle.ReplaceAll(description, "")
   description = reEM.ReplaceAll(description, "-")
   description = reApost.ReplaceAll(description, "'")
   description = reWhiteSpace.ReplaceAll(description, "")
   description = reEllipsis.ReplaceAll(description, "")
   description = reQuot.ReplaceAll(description, chr(22))
   description = reExcessSpace.ReplaceAll(description, " ")
  
   return description
End Function
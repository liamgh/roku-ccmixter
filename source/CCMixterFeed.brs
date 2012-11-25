
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
   print "title"
   For Each item In xml.channel.item
      title = item.title.GetText()
      author = item.GetNamedElements("dc:creator").GetText()
      description = item.description.GetText()
      file = item.enclosure@url
      
       song = CreateSong(title,author,description,"mp3", file, "pkg:/images/ccMpromo.png")
    aa.posteritems.push(song)
      
   End For
   
   return aa 
End Function
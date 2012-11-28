'**********************************************************
'**  Audio Player Example Application - Audio Playback
'**  November 2009
'**  Copyright (c) 2009 Roku Inc. All Rights Reserved.
'**********************************************************

REM ****************************************************************
REM Create a Song Item
REM return the Song as a Poster Item
REM ****************************************************************
Function CreateSong(title as string, artist as string, description as string, streamformat as string, feedurl as string, imagelocation as string, releaseDate as string, length as Integer) as Object

    item = CreatePosterItem("", title, artist)
    'override Poster pointers
    item.HDPosterUrl = imagelocation
    item.SDPosterUrl = imagelocation
    item.Artist = artist
    item.Description = description
    item.Title = title    ' Song name
    item.feedurl = feedurl
    item.streamformat = streamformat
    item.picture = item.HDPosterUrl      ' default audioscreen picture to PosterScreen Image
    item.ReleaseDate = releaseDate
    item.Length = length
    return item
End Function

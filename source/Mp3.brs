'**********************************************************
'**  Audio Player Example Application - Audio Playback
'**  November 2009
'**  Copyright (c) 2009 Roku Inc. All Rights Reserved.
'**********************************************************

' Mp3 support routines
Sub DoMp3(from as string)
    'Put up poster screen to pick a song to play
    SongList = CreateMp3SongList()
    Pscreen = StartPosterScreen(SongList, from, "Podcasts")

    while true
        song = Pscreen.GetSelection(0)
        if song = -1 exit while
        Show_Audio_Screen(songlist.posteritems[song],"Podcasts")
    end while
End Sub


'**********************************************************
' CCMixter audio playback
'**********************************************************
Function CreateCategories()
    aa = CreateObject("roAssociativeArray")
    aa.PosterItems = CreateObject("roArray", 5, true)

    Category = CreatePosterItem("mp3","MP3","Song List")
    Category.Process = DoMp3
    aa.PosterItems.push(Category)

    return aa
End Function

REM ******************************************************
REM
REM Main - script startup here.
REM 
REM
REM ******************************************************
Sub Main()
    ' Set up the basic color scheme
    SetTheme()
    
     SongList = loadFeed()
     
    Pscreen = StartPosterScreen(SongList, "", "Podcasts")

    while true
        song = Pscreen.GetSelection(0)
        if song = -1 exit while
        Show_Audio_Screen(songlist.posteritems[song],"Podcasts")
    end while
End Sub

REM ******************************************************
REM
REM Setup theme for the application 
REM
REM ******************************************************

Sub SetTheme()
    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    theme.OverhangOffsetSD_X = "72"
    theme.OverhangOffsetSD_Y = "25"
    theme.OverhangSliceSD = "pkg:/images/header-main-b.png"
    theme.OverhangLogoSD  = "pkg:/images/cc-mixter-logo.png"

    theme.OverhangOffsetHD_X = "123"
    theme.OverhangOffsetHD_Y = "68"
    theme.OverhangSliceHD = "pkg:/images/header-main-b.png"
    theme.OverhangLogoHD  = "pkg:/images/cc-mixter-logo.png"
    theme.BackgroundColor = "#FFFFFF"
    theme.BreadcrumbTextRight = "#FFFFFF"
    theme.BreadcrumbTextLeft = "#A0A0A0"

    app.SetTheme(theme)
End Sub

REM ******************************************************
REM
REM Show audio screen
REM
REM Upon entering screen, should start playing first audio stream
REM
REM ******************************************************
Sub Show_Audio_Screen(song as Object, prevLoc as string)
    ' Detect version number, see http://forums.roku.com/viewtopic.php?f=34&t=33697&p=214373
    device = CreateObject("roDeviceInfo")
    canSeek = mid(device.GetVersion(), 3, 3).ToFloat() >= 2.6
    Audio = AudioInit()
    picture = song.HDPosterUrl
    o = CreateObject("roAssociativeArray")
    o.HDPosterUrl = picture
    o.SDPosterUrl = picture
    o.Title = song.shortdescriptionline1
    o.Description = song.Description
    o.contenttype = "episode"
    o.ReleaseDate = song.ReleaseDate
    o.contentType = "audio"
    o.Rating = song.Licence
    If song.Length > 0 Then
       o.Length = song.Length
    EndIf
    
    if (song.artist > "")
        o.Actors = CreateObject("roArray", 1, true)
        o.Actors.Push(song.artist)
    endif
        
    scr = create_springboard(Audio.port, prevLoc)
    scr.ReloadButtons(2) 'set buttons for state "playing"
    scr.screen.SetTitle("Screen Title")
    scr.screen.SetContent(o)
    If song.Length > 0 Then
       scr.screen.SetProgressIndicatorEnabled(true)
       scr.screen.SetProgressIndicator(0,song.Length)
    End If

    scr.Show()

    ' start playing
    
    Audio.setupSong(song.feedurl, song.streamformat)
    Audio.audioplayer.setNext(0)
    Audio.setPlayState(2)               ' start playing
    timePlayed = 0
    isTiming = False    
    while true
        msg = Audio.getMsgEvents(1000, "roSpringboardScreenEvent")
        If isTiming Then timePlayed = timePlayed + 1
        If song.Length > 0 Then
           scr.screen.SetProgressIndicator(timePlayed, song.Length)
        End If 
        if type(msg) = "roAudioPlayerEvent"  then       ' event from audio player
            if msg.isStatusMessage() then
                message = msg.getMessage()
                if message = "start of play" then
                    isTiming = True
                End If
                if message = "end of playlist"
                    print "end of playlist (obsolete status msg event)"
                        ' ignore
                else if message = "end of stream"
                    print "done playing this song (obsolete status msg event)"
                endif
            else if msg.isListItemSelected() then
                print "starting song:"; msg.GetIndex()
            else if msg.isRequestSucceeded()
                print "ending song:"; msg.GetIndex()
                audio.setPlayState(0)   ' stop the player, wait for user input
                scr.ReloadButtons(0)    ' set button to allow play start
                isTiming = False
            else if msg.isRequestFailed()
                print "failed to play song:"; msg.GetData()
            else if msg.isFullResult()
                print "FullResult: End of Playlist"
                timePlayed = 0
                isTiming = False
                audio.setPlayState(0)      ' stop the player, wait for user input
                scr.ReloadButtons(0)    ' set button to allow play start
            else if msg.isPaused()
                isTiming = False
            else if msg.isResumed()
                isTiming = True
            else
                'print "ignored event type:"; msg.getType()
            endif
        else if type(msg) = "roSpringboardScreenEvent" then     ' event from user
            if msg.isScreenClosed()
                Audio.setPlayState(0)
                return
            endif
            if msg.isRemoteKeyPressed() then
                button = msg.GetIndex()
                ' REW/FF Requires firmware 2.6
                If button = 8 And canSeek Then
                   skipBack = 30
                   If timePlayed - skipBack < 0 Then skipBack = timePlayed
                   audio.audioplayer.Seek((timePlayed-skipBack)*1000)
                   timePlayed = timePlayed - skipBack
                Else If button = 9 And canSeek Then
                   skipForward = 30
                   if song.Length > 0 And (timePlayed + skipForward) > song.Length Then skipForward = 0
                   If skipForward > 0 Then 
                       audio.audioplayer.Seek((timePlayed+skipForward)*1000)
                       audio.audioplayer.Seek((timePlayed)*1000)
                   End If
                End If
            else if msg.isButtonPressed() then
                button = msg.GetIndex()
                if button = 1 'pause or resume
                    if Audio.isPlayState < 2    ' stopped or paused?
                        if (Audio.isPlayState = 0)
                              Audio.audioplayer.setNext(0)
                        endif
                        newstate = 2  ' now playing
                    else
                         newstate = 1 ' now paused
                    endif
                else if button = 2 ' stop
                    newstate = 0 ' now stopped
                endif
                audio.setPlayState(newstate)
                scr.ReloadButtons(newstate)
                scr.Show()
            endif
        endif
    end while
End Sub

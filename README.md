Musicd
======

So this is my hack of a media player.. built around mplayer and various shell scripts.

It supports playing any file that mplayer supports, from any directory, without using a database (other than locatedb).

It supports finding album-art (see `songchange.sh`), notify-send popups with album-art, nowplaying scripts, etc.

Now playing song can be `cat`'d from ~/.musicd/current and ~/.musicd/albumart is a symlink to any album-art found, or none.png otherwise.

It is made to integrate into my sawfish config, so for menus with tab completion and all that (if you're using sawfish), you can find all that stuff in my Dotfiles repository.

Steps for running Musicd:
-------------------------

Move all of this into ~/.musicd/

Add ~/.musicd/bin to your $PATH

`cd` into ~/.musicd/bin and `gcc -o songinfo songinfo.c`

Run `mkfifo ~/.musicd/control`

Assuming your locatedb works, you should be able to type `play artistname` and it will find all of those artists and throw them in a playlist.

Now run `musicd`

If all is well.. mplayer should start playing your playlist. You can control it using the `prev/next/pause/play` commands.

`songplay` run without arguments, shows your current playlist with line numbers, and running `songplay <number>` will shuffle around your playlist so that song is played.

It's a mess right now, I rewrote and cleaned it up once and then somehow decided not to back it up and lost it :( I will fix it up soon I promise!

Frontend
--------

There's a Chicken Scheme frontend in the frontend directory, that really just pretty prints a folder full of artist folders.

I threw my conkyrc in there too for good measure.

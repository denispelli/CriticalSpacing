% Mario Keliner's comments on Screen Flip timing
% December 23, 2019
% 
% Hi Denis,
% 
% "you were right that ScreenFlipTest was using 8-bit mode. That was in
% order to make it run on as many computers as possible. It never occurred
% to me that timing and bit depth would interact. I have now enhanced
% ScreenFlipTest to accept an optional 'bits' flag ..."
% 
% It shouldn't interact on a well implemented OS, but this is macOS :/
% 
% The basic principle is simple: In order to get precise and trustworthy
% timing and timestamping, and also tear-free/flicker-free stimulus
% presentation, all these conditions must be satisfied:
% 
% 0. It's a fullscreen window taking over the whole display. At least on
% macOS and Windows. Some modern Linux display servers don't need 0 anymore
% for good timing, although most still do. Non-fullscreen on non-Linux
% always means borked timing.
% 
% 1. Page-flipping is used for image presentation, ie. there are multiple
% memory buffers in the GPU's VRAM memory, one is the
% front-buffer/scanout-buffer that is read by the display engine to
% generate the video signal to drive the display with the current stimulus.
% One is the back-buffer, to which the rendering hardware draws new stimuli
% in response to OpenGL drawing commands. At 'Flip' time, memory pointers
% to these buffers are swapped, or "flipped", so the old back-buffer with
% the new stimulus takes on the role of the display scanout
% buffer/front-buffer, and the old front-buffer turns into the back-buffer
% for the next drawing cycle. This pointer swapping, is not done in
% software, but by the display hardware itself at start of vblank / end of
% scanout of the current video frame. Therefore it is perfectly
% synchronized to vsync, no matter what other timing jitter or delays may
% happen in the system.
% 
% 2. Presentation is strictly double-buffered, ie. there are exactly two
% such buffers, a front-buffer and a back-buffer, not one, three or more
% buffers. Ok, this is only neccessary on primitive operating systems like
% macOS and Windows. Linux with open-source drivers can deal with n >= 2
% buffers without affecting timing, but we're talking about macOS here.
% 
% 3. The page-flipping must be under direct control of PTB (=the OpenGL
% application), with no middle-man or indirection, so we know that when we
% request a flip, it will happen at the next vblank. And if we get the
% feedback that the flip happened, it really happened, so we can calculate
% timestamps based on that.
% 
% 1. was broken in various macOS versions over the last years for some
% graphics cards, usually NVidia gpu's. That seems to be (mostly) fixed
% since 10.13, and doesn't matter anymore, as Apple does no longer support
% NVidia hardware, actually actively prevents use of NVidia hardware since
% 10.14, and even harder on 10.15, because apparently they have some
% private war against NVidia.
% 
% 2 and 3 are correlated, usually either both work or both fail. Whenever
% the macOS desktop compositor kicks in, 3 is violated and 2 goes out of
% the window as well. So all my workarounds are about preventing the
% compositor from getting in the way as some middle-man, ie. we want
% compositor bypass. There are a couple of magic rules to try to prevent
% the compositor from kicking in:
% 
% a) Only non-transparent, fully opaque, decorationless, unoccluded,
% top-level fullscreen windows. That's why PTB tells you timing is gone
% whenever you open a non-fullscreen window or transparent window.
% 
% b) Avoid whatever programming API the morons at Apple break in a given
% macOS version, because of incompetence and lack of QA testing. Of course
% the breakage is shifting in a fun game of whack a mole almost every OS
% release. Using the wrong API means the compositor is used when it doesn't
% need to be used. All that is certain to me now is that Apples
% documentation and "best practice" guides at any given time will usually
% recommend the exact opposite of what one should do to get things working.
% Apparently the OS developers and technical doc writers hate each other or
% don't talk to each other.
% 
% c) Avoid whatever could require some conversion from the size and format
% of the source image buffer (= the OpenGL backbuffer = what PTB renders
% into and sends to the OS for presentation) to the size and format of the
% system framebuffer/display scanout buffer, ie. what the display engines
% are programmed to expect. If any conversion is needed, the desktop
% compositor will kick in and do the conversion and break timing in the
% process. On a setup with broken timing in case a), b) or most commonly
% c), even if the timestamps you collect with your script *seem* to be
% consistent and reasonable, they *don't* represent reality! There's a
% loose correlation at best. If you'd attach photo-diodes or similar (i use
% five different hardware methods of different accuracy/reliability at the
% moment, depending on display type and setup) you'd see that even the
% results that look good in your plots are sometimes off from reality by up
% to 3 video refresh cycle durations. The only way without attaching
% measurement hardware to be pretty confident that the timing is actually
% correct, is if the PTB kernel driver is properly in use and PTB gives no
% errors or warnings at all.
% 
% a) was always the case and is solved by PTB at least since i joined the
% project. b) Is what my fixes were supposed to do when i thought i was
% done and proposed those 7000 Euros for the past work done in fixing b).
% c) Is what took me by surprise due to many extra unexpected macOS bugs
% which only showed up on the MBP 2017 and your machines, and took so much
% extra time to "fix" with all those extra hacks. This because all the
% problems of c) were only introduced for "new" hardware with Retina
% displays etc.
% 
% Many extra hacks solve c) for Retina displays, and the iMacs Retina
% displays which are special snowflakes by making sure that our OpenGL
% backbuffer is always the exact native size of the Retina display, so the
% compositor does not need to kick in to rescale the images from OpenGL
% backbuffer -> system framebuffer. Instead PTB does its own rescaling
% internally.
% 
% Another bunch of hacks try to make sure that the data format of pixels in
% the OpenGL backbuffer match exactly the expected format of the system
% framebuffer, to avoid compositor activity for data format conversion.
% This is done by using system private api's to switch the system
% framebuffer into a format that matches the one of the OpenGL backbuffer.
% 
% Here's the mind-boggling catch: The system framebuffer can only operate
% in two modes: Native 8 bit or native 10 bit. But the OpenGL backbuffer
% can only operate in either 8 bit or 16 bit non-linear half-float. This
% means for standard 8 bit precision mode we can swich the system
% framebuffer to match the format of the OpenGL backbuffer and
% page-flipping can be used directly to "flip" the OpenGL backbuffer to
% become the new system framebuffer. All is good.
% 
% For >8 bit precision, macOS OpenGL implementation does *not* actually
% support 10 bit backbuffers, only 16 bit half-float, whereas the system
% framebuffer does not support 16 bit half-float, only 10 bit. This
% mismatch means there isn't any way to get a matching OpenGL backbuffer ==
% system framebuffer format for high precision mode. This means the Quartz
% compositor will always kick in to do the format conversion from 16 bit
% half-float to 8 bit or 10 bit format. And that means case c) is violated
% and we are not in control of pageflipping and timing anymore and things
% go badly wrong.
% 
% That's why short of Apple improving their OpenGL implementation to
% support 10 bit native, there is no way at all to get correct timing and 
% >8 bit precision output. Given that Apple has deprecated OpenGL
% (inofficially at least 9 years ago, officially since 2018), i assume that
% won't happen.
% 
% The mind-boggling thing to me is that both the 3d graphics hardware and
% the display hardware support 10 bit rendering and display, so this
% mismatch makes no sense at all. Modern display hardware even supports 16
% bit native scanout, and Apple ignores that on the display side
% completely. Also many Macs when operated in "high precision" mode do not
% even switch the system framebuffer to 10 bit scanout mode, but leave it
% in 8 bit mode. All the precision the display hardware has is completely
% thrown out of the window and Apple uses its own proprietary and slow
% dithering method to fake about 10-11 bits precision. Then other macs run
% the system framebuffer in 10 bit mode while only displaying 8 bit OpenGL
% content, which makes just as little sense. And some macs don't support
% >8 bits despite the fact that macOS does not use the actual display
% hardware for it, but it is a software implementation which could perform
% as well (or as badly) on any hardware. Seems to be just a weird way to
% force people to buy more expensive mac's for no technical reason, because
% we all know how cash-strapped Apple is.
% 
% It's as if the people writing the OpenGL graphics drivers, the people
% writing the compositor, and the people writing the low level display
% drivers hate each other deeply and/or never talk to each other. And all
% of them seem to hate the technical documentation writers of course and
% feed them wrong information.
% 
% It means macOS has an implementation that gets the least actual precision
% out of native 10 bit displays, while maximizing memory consumption and
% minimizing performance while increasing latency and breaking timing. It
% needs a lot of special teamwork to achieve such a bad tradeoff.
% 
% integer value that can be 8, 10, or 11 (default is 8 bits). I'm attaching
% timing for 2015 and 2017 MacBook Pros and my 2014 iMac, all with AMD
% graphics, plus my MacBook. In some cases I have used the optional
% argument 'framepersec' 60 to force the fit to assume 60 Hz frame rate.
% 
% I need 11-bit depth for most of my experiments. We cannot measure a
% contrast threshold with 8 bits. I have not tested 10-bit mode. Should I?
% 
% From the above it follows you don't need to try. Regardless if you
% request 10 bit, 11 bit or 16 bit precision from PTB, it will always
% choose the 16 bit non-linear half-float precision mode, because that's
% the only mode supported by macOS OpenGL. Only the status output messages
% will differ between the modes. A 16 bpc half-float framebuffer gives at
% most 11 bits linear precision, so many of these bits are wasted -
% increasing memory consumption and processing load without increasing
% precision. Another mind-boggling thing about Apples OpenGL.
% 
% In that sense it could almost make sense to always request 10 bit
% precision, because on macOS you'll get fake 11 bit anyway, and 10 bits
% are also compatible with the native (= done right) 10 bit support on
% Linux and Windows, so one doesn't need special cases for different
% operating systems.
% 
% Is there a way to test, from software, whether a display supports 10 or
% 11 bit depth?
% 
% 
% No. There are certain low-level ways for me to find out if certain stages
% of the display pipeline from OpenGL rendering code to display do support
% a certain bit depth, but all of these are not standardized at all and
% often change from hardware generation to hardware generation. And there
% are gaps (= bottlenecks where precision can be reduced without easily
% finding this out in software) and various special cases. The only
% half-war reliable way is to measure with a photometer. Even that might
% not be totally free of surprises unless you sample the whole range and
% don't make changes to the display/hardware setup between measurement and
% actual use for visual stimulation.
% 
% What i can tell you is that no consumer hardware display supports 11 bit
% depth, unless they are special pro market displays or projectors.
% 
% You can read out and decode the EDID data block of a display to find out
% what the display manufacturer claims it display can do. That's not
% necessarily what it actually can do. Sometimes it only accepts input
% signals at the "claimed to be supported" bit depth, but then truncates
% the precision before actually driving the display panel, ending with 8
% bits at the end. Or the display implements the > 8 bit extra bits via
% temporal dithering aka FRC (Framerate compensation), so it is only > 8
% bits in a statistical sense when averaging over multiple frame durations
% or even 1 second, ie. for static images. Some more expensive displays do
% support native 10 bit, and some very expensive ones may even do 12 bit.
% 
% E.g., i have a Dell monitor in the lab that claims 10 bit support, but
% measurement shows it only does 8 bits. The Retina panel in the 2017 MBP
% claims via EDID that it is a 10 bit panel. But from the way macOS drives
% that display, with its own software dithering instead of actually using
% the abilities of the gpu's display hardware, i think it can't take
% advantage of those 10 bits. Otoh. the same software dithering also drives
% 8 bit panels to a measured 11 bits precision. And the color depth of the
% system framebuffer seems to have nothing to do with the claimed color
% depth of the display or the requested precision. Nothing in the way Apple
% handles this makes much sense to me.
% 
% I will try to figure out if i can use the 10 bit Retina panel of the MBP
% 2017 with true 10 and 11 bit precision under Linux. My first attempt
% failed due to what seem to be firmware bugs in the MBP 2017, making the
% display schizophrenic about its own capabilities. That should at least
% answer the question if the Retina panel is really 10 bit capable or not
% in the end, and how much precision one can squeeze out of it without
% impairing timing with a proper operating system.
%  
% I've attached seven png files. There is one for my MacBook. There are two
% for each of the computers with AMD graphics. For each of them one of the
% file names ends in "bits-11", meaning 11-bit depth. In the graphics
% below, the number of bits appears in the line below the screen
% dimensions. When the "bits" flag is absent, the bit depth is 8 bits.
% 
% SUMMARY: 8-bit performance is great, except for a few long times in the
% 2017 MacBook Pro. Could that be due to some background process in macOS?
% 
% Could be due to all kind of things. Background processes, OS timing bugs,
% temporarily low memory or problems with gpu dynamic power management,
% other processes using the graphics hardware in parallel. I've also
% observed sporadic page-flipping failures, which will make PTB print some
% scary warnings, but usually only at the very beginning of a work session.
% I'll think about suppressing some of these warnings during the first few
% flips after 'OpenWindow'. If a notification would pop up during a session
% that would also affect timing.
% 
% Your MBP 2015 and iMac 2014 look good at 8 bit, something went wrong on
% the MBP 2017, maybe some sporadic failure? The MacBook looks sensible at
% 8 bit, but without the kernel driver being used, one can't be sure.
% 
% 11-bit performance is diverse. It's pretty good for the iMac out to 30 ms
% requested delay, and pretty good for the MacBook Pros out to 15 or 20 ms.
% 
% All your 11 bit results show complete breakage on all tested machines. I
% can't remember if PTB gives warnings at each failed flip, or if it gives
% just a single warning at startup/OpenWindow that timing is completely
% broken in 11 bit mode and you should not trust any software test of
% timing. I think i implemented a one-time warning for > 8 bit mode to not
% flood the console with warnings that state the obvious. But i can
% guarantee you even the not completely bogus looking results are wrong, as
% measurement with photo-diodes etc. would show you.
%  
% Thoughts?
% 
% Timing is not trustworthy or correct at all in >8 bit modes and this is
% not a solvable problem for us. You would have to convince Apple to make a
% 180 degree turn on all their publicly declared decisions wrt. OpenGL from
% the last 2 years and get them to spend serious engineering time on
% improving their OpenGL implementation with true 10 bit backbuffer
% support. Or make them spend serious engineering time to implement proper
% 16 bit half-float display engine support.
% 
% Of course there's still PTB's built-in "PseudoGray" (= aka Bitstealing)
% support for ~ 10.7 bits grayscale precision on properly calibrated 8 bit
% displays.
% 
% On Linux i hope to get native 10 bit output working on the Retina panel
% sometime not too far away, or even 11, 12 or 12.7 bits with dithering
% methods or PseudoGray mode on top of 10 bit native display. But that's a
% different story, won't apply to macOS.
% 
% Happy christmas! -mario

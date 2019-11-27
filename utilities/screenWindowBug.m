    screen=0;
    %% SET RESOLUTION TO NATIVE
    permissionToChangeResolution=true;
    res=Screen('Resolutions',screen);
    nativeWidth=0;
    nativeHeight=0;
    for i=1:length(res)
        if res(i).width>nativeWidth
            nativeWidth=res(i).width;
            nativeHeight=res(i).height;
        end
    end
    actualScreenRect=Screen('Rect',screen,1);
    oldResolution=Screen('Resolution',screen);
    if nativeWidth==oldResolution.width
        fprintf('Your screen resolution is at its native maximum %d x %d. Excellent!\n',nativeWidth,nativeHeight);
    else
        warning backtrace off
        if permissionToChangeResolution
            s=GetSecs;
            fprintf('WARNING: Trying to use native screen resolution for this test. ... ');
            Screen('Resolution',screen,nativeWidth,nativeHeight);
            res=Screen('Resolution',screen);
            fprintf('Done (%.1f s). ',GetSecs-s);
            if res.width==nativeWidth
                fprintf('SUCCESS!\n');
            else
                warning('FAILED.');
                res
            end
            actualScreenRect=Screen('Rect',screen,1);
        end
        if nativeWidth==RectWidth(actualScreenRect)
            fprintf('Using native screen resolution %d x %d. Good.\n',nativeWidth,nativeHeight);
        else
            if RectWidth(actualScreenRect)<nativeWidth
                warning('Your screen resolution %d x %d is less that its native maximum %d x %d.\n',RectWidth(actualScreenRect),RectHeight(actualScreenRect),nativeWidth,nativeHeight);
            else
                warning('Your screen resolution %d x %d exceeds its native resolution %d x %d.\n',...
                    RectWidth(actualScreenRect),RectHeight(actualScreenRect),nativeWidth,nativeHeight);
            end
            fprintf(['(To use native resolution, set permissionToChangeResolution=true in %s.m, \n'...
                'or use System Preferences:Displays to select "Default" resolution.)\n'],mfilename);
            warning backtrace on
        end
    end
    resolution=Screen('Resolution',screen);
    
    % DRAW A FULL SCREEN X AND LABEL TWO POINTS
    % WE OUGHT TO SEE A FULL SCREEN X, AND TWO LABELED POINTS,
    % ONE AT UPPER LEFT CORNER AND ONE AT LEFT JUST BELOW MIDDLE OF SCREEN.
    % ON MY BIG IMAC I INSTEAD SEE ONLY THE LOWER LEFT QUADRANT OF WHAT I
    % EXPECT TO SEE, AND IT FILLS MY WHOLE SCREEN.
    % THIS PROBLEM OCCURS ONLY AFTER USING THE RESOLUTION CHANGING CODE
    % ABOVE.
    white=255;
    r=Screen('Rect',window)
    Screen('DrawLine',window,0,r(1),r(2),r(3),r(4),4);
    Screen('DrawLine',window,0,r(1),r(4),r(3),r(2),4);
    y=20;
    Screen('DrawText',window,['[0 ' num2str(y) ']'],0,y);
    y=rect(4)/2+20;
    Screen('DrawText',window,['[0 ' num2str(y) ']'],0,y);
    Screen('Flip',window);
    WaitSecs(5);
    sca

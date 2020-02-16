{$mode objfpc}
Program main;
Uses Crt, SysUtils;

Const
    // IMPORTANT *
        LIMIT_DELAY = 1;

    // CUSTOMIZABLE
        MIN_ACCELERATION = 0;
        MAX_ACCELERATION = 0.8;
        INC_ACCELERATION = 0.05;
        DEC_ACCELERATIOR = INC_ACCELERATION * 3;

Type
    EDirection = (dUp, dDown, dLeft, dRight, dNothing);
    ESense = (sPos, sNeg);

    TCoord = Class
        fCoord: Byte;
        Constructor Create(Coord: Byte);
    End;

    TMoviment = Class
        Class Function Move(const Coord: TCoord; Sense: ESense; Amount: Byte): TCoord;
    End;

    TCounter = Class
        Private
            fNow, fMax: Single;
        Public
            fCountingRate: Single;

            Constructor Create(CountingRate, Max: Single);
            Procedure Count;
            Procedure Reset;
            Function CheckEnd: Boolean;
    End;

    TPlayer = Class
        Private
            fHorizontal, fVertical: TCoord;
            fCounter: TCounter;
            fDir: EDirection;

            fNewDir: EDirection;
            fChangingDirection: Boolean;
        Public
            fSpeed: Byte;

            Constructor Create(X, Y, Speed: Byte);
            Procedure Draw;
            Procedure Clear;
            Procedure Move;
            Procedure Accelerate;
            Procedure Desaccelerate;
            Procedure Debug;
            Procedure ChangeDirection(Dir: EDirection);
    End;

    { Classes }
        { TCoord }
            Constructor TCoord.Create(Coord: Byte);
            Begin
                fCoord := Coord;
            End;
        { TMoviment }
            Class Function TMoviment.Move(const Coord: TCoord; Sense: ESense; Amount: Byte): TCoord;
            Begin
                Case (Sense) Of
                    sPos: Result := TCoord.Create(Coord.fCoord + Amount);
                    sNeg: Result := TCoord.Create(Coord.fCoord - Amount);
                End;
            End;
        { TCounter }
            Constructor TCounter.Create(CountingRate, Max: Single);
            Begin
                fCountingRate := CountingRate;
                fMax := Max;
            End;

            Procedure TCounter.Count;
            Begin
                fNow := fNow + fCountingRate;
            End;

            Procedure TCounter.Reset;
            Begin
                fNow := 0;
            End;

            Function TCounter.CheckEnd: Boolean;
            Begin
                Result := (fNow >= fMax);
            End;
        { TPlayer }
            Constructor TPlayer.Create(X, Y, Speed: Byte);
            Begin
                fHorizontal := TCoord.Create(X);
                fVertical := TCoord.Create(Y);
                fDir := dRight;
                fSpeed := Speed;
                fChangingDirection := FALSE;
                fNewDir := dNothing;
                fCounter := TCounter.Create(MIN_ACCELERATION, LIMIT_DELAY);
            End;

            Procedure TPlayer.Draw;
            Begin
                GoToXY(fHorizontal.fCoord, fVertical.fCoord); Write('V');
            End;

            Procedure TPlayer.Clear;
            Begin
                GoToXY(fHorizontal.fCoord, fVertical.fCoord); Write(' ');
            End;

            Procedure TPlayer.Move;
            Begin
                If (fCounter.CheckEnd) Then
                Begin
                    Clear;

                    Case (fDir) Of
                        dLeft: If ((fHorizontal.fCoord - fSpeed) >= 1) Then fHorizontal := TMoviment.Move(fHorizontal, sNeg, fSpeed) Else fHorizontal.fCoord := 1;
                        dDown: If ((fVertical.fCoord + fSpeed) <= 30) Then fVertical := TMoviment.Move(fVertical, sPos, fSpeed) Else fVertical.fCoord := 30;
                        dRight: If ((fHorizontal.fCoord + fSpeed) <= 120) Then fHorizontal := TMoviment.Move(fHorizontal, sPos, fSpeed) Else fHorizontal.fCoord := 120;
                        dUp: If ((fVertical.fCoord - fSpeed) >= 1) Then fVertical := TMoviment.Move(fVertical, sNeg, fSpeed) Else fVertical.fCoord := 1;
                    End;

                    Draw;

                    fCounter.Reset;
                End
                    Else fCounter.Count;
            End;

            Procedure TPlayer.Accelerate;
            Begin
                If ((fCounter.fCountingRate + INC_ACCELERATION) <= MAX_ACCELERATION) Then fCounter.fCountingRate := fCounter.fCountingRate + INC_ACCELERATION Else fCounter.fCountingRate := MAX_ACCELERATION;
            End;

            Procedure TPlayer.Desaccelerate;
            Begin
                If ((fCounter.fCountingRate - DEC_ACCELERATIOR) >= MIN_ACCELERATION) Then fCounter.fCountingRate := fCounter.fCountingRate - DEC_ACCELERATIOR Else fCounter.fCountingRate := MIN_ACCELERATION;
            End;

            Procedure TPlayer.Debug;
            Begin
                 GoToXY(1, 1);  Write('+-- STATUS --+');
                 GoToXY(4, 2);  Write('       ', #13, '| X: ', fHorizontal.fCoord);
                 GoToXY(4, 3);  Write('       ', #13, '| Y: ', fVertical.fCoord);
                 GoToXY(6, 4);  Write('           ', #13, '| DIR: ', fDir);
                 GoToXY(6, 5);  Write('                ', #13, '| NEW DIR: ', fNewDir);
                 GoToXY(10, 6); Write('       ', #13, '| SPEED: ', fSpeed);
                 GoToXY(17, 7); Write('       ', #13, '| ACCELERATION: ', fCounter.fCountingRate*100:1:0);
                 GoToXY(14, 8); Write('    ', #13, '| COUNTING: ', fCounter.fNow*100:1:0);
            End;

            Procedure TPlayer.ChangeDirection(Dir: EDirection);
            Begin
                Case (fChangingDirection) Of
                    True:
                        Begin
                            Case (fCounter.fCountingRate > 0) Of
                                True:  Desaccelerate;
                                False: 
                                    Begin
                                        fChangingDirection := FALSE;
                                        fDir := fNewDir;
                                        fNewDir := dNothing;
                                    End;
                            End;
                        End;
                    False:
                        Begin
                            Case (fDir = Dir) Of
                                True: Accelerate;
                                False:
                                    Begin
                                        fChangingDirection := TRUE;
                                        fNewDir := Dir;
                                    End;
                            End;
                        End;
                End;
            End;

Var
    Player: TPlayer;

Begin
    Cursoroff; Clrscr;

    Try
        Player := TPlayer.Create(60, 1, 1);
        Player.Draw;

        Repeat
            Player.Debug;

            If (KeyPressed()) Then
            Begin
                Case (UpCase(ReadKey())) Of
                    'A': Player.ChangeDirection(dLeft);
                    'D': Player.ChangeDirection(dRight);
                    'W': Player.ChangeDirection(dUp);
                    'S': Player.ChangeDirection(dDown);
                    #27: Break;
                End;
            End;

            Player.Move;

            Delay(1);
        Until (False);
    Finally
        Player.Free;
    End;
End.

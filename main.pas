{$mode objfpc}
Program main;
Uses Crt;

Const 
    // IMPORTANT *
        LIMIT_DELAY = 1;

    // CUSTOMIZABLE 
        INC_ACCELERATION = 0.01;
        MIN_ACCELERATION = 0;
        MAX_ACCELERATION = 0.8; 

Type 
    EDirection = (dUp, dDown, dLeft, dRight);
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
        Public 
            fDir: EDirection;
            fSpeed: Byte;

            Constructor Create(X, Y, Speed: Byte);
            Procedure Draw;
            Procedure Clear;
            Procedure Move;
            Procedure Accelerate;
            Procedure Desaccelerate;
            Procedure Debug;
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
                        dDown: If ((fVertical.fCoord + fSpeed) <= 30) Then fVertical := TMoviment.Move(fVertical, sNeg, fSpeed) Else fVertical.fCoord := 30;
                        dRight: If ((fHorizontal.fCoord + fSpeed) <= 120) Then fHorizontal := TMoviment.Move(fHorizontal, sPos, fSpeed) Else fHorizontal.fCoord := 120;
                        dUp: If ((fVertical.fCoord - fSpeed) >= 1) Then fVertical := TMoviment.Move(fVertical, sPos, fSpeed) Else fVertical.fCoord := 1;
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
                If ((fCounter.fCountingRate - INC_ACCELERATION) >= MIN_ACCELERATION) Then fCounter.fCountingRate := fCounter.fCountingRate - INC_ACCELERATION Else fCounter.fCountingRate := MIN_ACCELERATION;
            End;

            Procedure TPlayer.Debug;
            Begin
                 GoToXY(1, 2); ClrEol; Write(#13, '+-- STATUS --');
                 GoToXY(1, 3); ClrEol; Write(#13, '| X: ', fHorizontal.fCoord);
                 GoToXY(1, 4); ClrEol; Write(#13, '| Y: ', fVertical.fCoord);
                 GoToXY(1, 5); ClrEol; Write(#13, '| SPEED: ', fSpeed);
                 GoToXY(1, 6); ClrEol; Write(#13, '| ACC: ', fCounter.fCountingRate*100:0:1);
                 GoToXY(1, 7); ClrEol; Write(#13, '| COUNTING: ', fCounter.fNow*100:0:1, '/', fCounter.fMax*100:0:1);
            End;
            
Var 
    Player: TPlayer;

Begin
    Cursoroff; Clrscr;

    Try 
        Player := TPlayer.Create(1, 1, 1);
        Player.Draw;

        Repeat
            If (KeyPressed()) Then
            Begin
                Case (UpCase(ReadKey())) Of
                    'A': Player.fDir := dLeft;
                    'D': Player.fDir := dRight;
                    'W': Player.Accelerate;
                    'S': Player.Desaccelerate;
                    #27: Break;
                End;
            End;

            Player.Move;
            Player.Debug;

            Delay(1);
        Until (False);
    Finally
        Player.Free;
    End;
End. 
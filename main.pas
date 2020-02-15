{$mode objfpc}
Program main;
Uses Crt;

Type 
    ESense = (sPos, sNeg);
    EDirection = (dUp, dDown, dLeft, dRight, dNothing);

    TCoord = Class
        fCoord: Byte;
        Constructor Create(Coord: Byte);
    End;

    TMoviment = Class
        Class Function Move(const Coord: TCoord; Sense: ESense; Amount: Byte): TCoord;
    End;

    TPlayer = Class
    Private
        fHorizontal, fVertical: TCoord;
    Public 
        fDir: EDirection;
        fSpeed: Byte;

        Constructor Create(X, Y, Speed: Byte; Dir: EDirection);
        Procedure Draw;
        Procedure Clear;
        Procedure Move;
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
        { TPlayer }
            Constructor TPlayer.Create(X, Y, Speed: Byte; Dir: EDirection);
            Begin
                fHorizontal := TCoord.Create(X);
                fVertical := TCoord.Create(Y);
                fSpeed := Speed;
                fDir := Dir;
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
                Clear;

                Case (fDir) Of
                    dLeft: If ((fHorizontal.fCoord - fSpeed) >= 1) Then fHorizontal := TMoviment.Move(fHorizontal, sNeg, fSpeed) Else fHorizontal.fCoord := 1;
                    dDown: If ((fVertical.fCoord + fSpeed) <= 30) Then fVertical := TMoviment.Move(fVertical, sNeg, fSpeed) Else fVertical.fCoord := 30;
                    dRight: If ((fHorizontal.fCoord + fSpeed) <= 120) Then fHorizontal := TMoviment.Move(fHorizontal, sPos, fSpeed) Else fHorizontal.fCoord := 120;
                    dUp: If ((fVertical.fCoord - fSpeed) >= 1) Then fVertical := TMoviment.Move(fVertical, sPos, fSpeed) Else fVertical.fCoord := 1;
                End;

                Draw;
            End;    

Var 
    Player: TPlayer;

Begin
    Cursoroff; Clrscr;

    Try 
        Player := TPlayer.Create(1, 1, 1, dRight);

        Repeat
            If (KeyPressed()) Then
            Begin
                Case (UpCase(ReadKey())) Of
                    'A': Player.fDir := dLeft;
                    'D': Player.fDir := dRight;
                    'W': Player.fSpeed := 2;
                    'S': Player.fSpeed := 1;
                    ' ': Player.fDir := dNothing;
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
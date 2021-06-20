program MIGUELez11os;
uses crt,dos,inifiles, sysutils;

{
-------------------------------------------------------------------------------------

													GLOBAL

-------------------------------------------------------------------------------------
}

var
   tick,lstick : int64;
	WinUser : string;
   Ini : Tinifile;
	key : char;
	i : integer;
   UserName, UserNumber, UserYear, UserDay, UserMonth, UserPIN : string;


function timing:int64;
var
   h,min,s,cs,y,m,dn,d : word;
begin
   gettime(h,min,s,cs);
   getdate(y,m,dn,d);
   timing := (y+m+dn)*100000+h*3600*1000+min*60*1000+s*1000+cs*10;
end;
procedure Draw_Text_Colour(Tx,Ty:integer;text:string;tc,tb:byte);
begin
   gotoxy(Tx,Ty);
   textcolor(tc);
   textbackground(tb);
   write(text);
end;
procedure data(action:string);
begin
   action := UPCASE(action);
   if action = 'CREATE' then
   begin
      WinUser := GetEnv('USERNAME');
      Ini := Tinifile.create('C:\Users\'+ WinUser + '\AppData\roaming\MIGUELez11\Mobile\cache.ini');
      if Ini.readstring('created','created','false') = 'false' then
      begin
         Ini.writestring('created','created','true');
         Ini.writestring('TNPlayers','TNPlayers', '0');
      end;
   end

end;

function Pass(Moto : string; color : byte; car : char): string;
var
	AccPass : string;
	i1 : integer;
begin
   Pass := '';
   AccPAss := '';
   textcolor(color);
	write(Moto);
	textcolor(white);
   i := wherex;
   i1 := 0;
   key := readkey;
   if i1 = 0 then
	for i1:= 1 to length(MOTO) do
	begin
		gotoxy(i - i1, wherey);
		write(' ');
	end;
	i := wherex;
	while key <> #13 do
	begin
		i1 := i1 + 1;
		if key = #8 then
		begin
			if (WhereX -1 >= i) then
			begin
				gotoxy(WhereX -1 , wherey);
				write(' ');
				gotoxy(WhereX -1 , wherey);
				SetLength(AccPass, length(AccPass)-1);
			end;
			key := char('');
		end
		else
		begin
         if key = char('') then
			   key := readkey;

			if (key <> #13) and (key <> #8) then
			begin
            if car = 'K' then
               write(key)
            else
				   write(car);
				AccPass := AccPass + key;
				key := char('');
			end;
		end;
		TextColor(white);
	end;
	key := char('');
	Pass := AccPass;
end;
{
-------------------------------------------------------------------------------------

													TETRIS

-------------------------------------------------------------------------------------
}

const
   WidthTablero  = 10;
   HeightTablero = 20;
type
   ObjTablero = object
   X : 1..139-WidthTablero;
   Y : 1..38-HeightTablero;
   l,lfilled : Array [-1..HeightTablero] of integer;
	Pos : Array[-2..WidthTablero+4,-1..HeightTablero+4] of integer; //0=Void;1=Square;2=Line;3=S;4=Z;5=J;6=L;7=T;8=Wall
   pointsV,PointsS, linesV : integer;
   ended : boolean;
   NamePlayer : string;


	procedure Create;
	procedure Draw;
   procedure erease;
   procedure delline;
   procedure HUD(action:string);
   procedure Highscore(action : string);

   end;
   ObjPiece = object
   X : -2..139-WidthTablero;
   Y : -1..38;//-HeightTablero;
	PType  : 1..7;
	NPType : 1..7;
   RotationP,lstRotationP : 1..4;
   dropped : boolean;

   procedure Create;
   function  Form(n,tipo,rotation:integer;coord:char):integer;
   procedure Draw;
   procedure DrawNext;
   procedure Erease;
   procedure EreaseNext;
   procedure Fall;
   function  Collision:boolean;
	procedure rotate;
   procedure Movement(sign:integer);


   end;




var
	Tablero : ObjTablero;
	Pieza   : ObjPiece;


//TABLERO FUNCTIONS

procedure ObjTablero.Create;
var
   xi,yi : integer;
begin
   for xi := -2 to WidthTablero do
      //Pos[xi,HeightTablero] := 8;
      for yi := -1 to HeightTablero do
         Pos[xi,yi] := 0;



   Pieza.NPType := random(7)+1;


   for xi := -2 to WidthTablero do
   begin
      Pos[xi,HeightTablero] := 8;
   end;
   for yi := -1 to HeightTablero do
   begin
      Pos[-2,yi] := 8;
      Pos[WidthTablero,yi] := 8;
   end;
   Pieza.NPType := random(7)+1;
end;

procedure ObjTablero.draw;
var
   xi,yi : integer;
begin
   for xi:=-2 to WidthTablero do
   begin
      for yi:=-1 to HeightTablero do
      begin
         if POS[xi,yi] = 0 then
            Draw_Text_Colour(x+2*(xi+2),y+(yi+2),'::', 0, 0)
         else if Pos[xi,yi] = 8 then
            Draw_Text_colour(x+2*(xi+2),y+(yi+2),'::', pos[xi,yi],pos[xi,yi]+1)
         else if Pos[xi,yi] <> 0 then
            Draw_Text_Colour(x+2*(xi+2),y+(yi+2),'::', pos[xi,yi]+1, pos[xi,yi]);
      end;
   end;
end;
procedure ObjTablero.erease;
var
   xi,yi : integer;
begin
   for xi:= -2 to WidthTablero do
   begin
      for yi := -1 to HeightTablero do
      begin
         Draw_Text_Colour(x+2*(xi+2),y+(yi+2),'  ', black, black);
      end;
   end;
end;
procedure ObjTablero.delline;
var
   col,col2,ln,ln2 : integer;
begin
   for ln := -1 to HeightTablero do
   begin
      lfilled[ln] := 0;
      for col := -2 to WidthTablero do
         if Pos[col,ln] in [1..7] then
            lfilled[ln] := lfilled[ln] + 1;

      if lfilled[ln] > WidthTablero then
      begin
         for ln2 := ln downto 0 do
            for col := 0 to WidthTablero do
               Pos[col,ln2] := Pos[col,ln2-1];

         pointsV := pointsV + 10;
         linesV := linesV + 1;
      end;
   end;


end;
procedure ObjTablero.HUD(action:string);
begin
   action := upcase(action);
   gotoxy(Tablero.x+2*widthTablero + 8,Tablero.y + 10);
   textbackground(black);
   textcolor(green);
   if action = 'SHOW' then
      begin
      writeln('Points :', pointsV);
      gotoxy(Tablero.x+2*widthTablero + 8,Tablero.y + 12);
      writeln('Lines :', linesv);

      end
   else if action = 'HIDE' then
      begin
      writeln('             ');
      gotoxy(Tablero.x+2*widthTablero + 8,Tablero.y + 12);
      writeln('                   ');
      end;


end;
procedure ObjTablero.Highscore(action : string);
var
   TNPlayers, i,i1 : integer;
	rewrite, found : boolean;
begin
	TextBackground(black);
   action := upcase(action);
	TNPlayers := strtoint(ini.readstring('TNPlayers', 'TNPlayers', '1'));
   if action = 'REFRESH' then
   begin
      if ini.readstring('TRankPoints', NamePlayer, '0') = '0' then
      begin
         ini.writestring('TRankPoints', NamePlayer, inttostr(pointsV));
			TNPlayers := TNPlayers + 1;
			ini.writestring('TNPlayers', 'TNPlayers', inttostr(TNPlayers));
			rewrite := true;
      end
		else
		begin
			if strtoint(ini.readstring('TRankPoints', NamePlayer, inttostr(pointsV))) < pointsV then
			begin
					ini.writestring('TRankPoints', NamePlayer, inttostr(pointsV));
					rewrite := true;

					for i := 1 to TNPlayers do
					if ini.readstring('TRankNames', inttostr(i), 'noone') = NamePlayer then
						break;
				for i1 := i to TNPlayers do
				begin
					ini.writestring('TRankNames', inttostr(i1), ini.readstring('TRankNames', inttostr(i1+1), 'noone'));
				end;
					ini.deletekey('TRankNames', inttostr(i1));
				readkey;

			end
			else
					rewrite := false;
		end;

		if rewrite then
		begin
				for i := 1 to TNPlayers do
					if strtoint(ini.readstring('TRankPoints', ini.readstring('TRankNames',inttostr(i), 'noone'),'1000')) < pointsV then
						break;
				for i1 := TNPlayers downto i do
				begin
					ini.writestring('TRankNames', inttostr(i1), ini.readstring('TRankNames', inttostr(i1-1), 'noone'));
				end;
				ini.writestring('TRankNames', inttostr(i1), NamePlayer);
		end;


   end
	else if action = 'DRAW' then
	begin
		gotoxy(Tablero.x+2*widthTablero + 8,Tablero.y + 17);
		write('                         ');
		gotoxy(Tablero.x+2*widthTablero + 8,Tablero.y + 18);
		write('                         ');
		gotoxy(Tablero.x+2*widthTablero + 8,Tablero.y + 19);
		write('                         ');
		gotoxy(Tablero.x+2*widthTablero + 8,Tablero.y + 21);
		write('                         ');

      gotoxy(Tablero.x+2*widthTablero + 8,Tablero.y + 15);
      textcolor(green);
      writeln('---HIGHSCORE---');

		gotoxy(Tablero.x+2*widthTablero + 8,Tablero.y + 17);
      textcolor(yellow);
		write('1 .- ', ini.readstring('TRankNames', '1', 'Blank'), ' - ', ini.readstring('TRankPoints', ini.readstring('TRankNames', '1', 'Anonymous'),'0'));

		gotoxy(Tablero.x+2*widthTablero + 8,Tablero.y + 18);
      textcolor(lightgray);
      write('2 .- ', ini.readstring('TRankNames', '2', 'Blank'), ' - ', ini.readstring('TRankPoints', ini.readstring('TRankNames', '2', 'Anonymous'), '0'));

		gotoxy(Tablero.x+2*widthTablero + 8,Tablero.y + 19);
      textcolor(brown);
      write('3 .- ', ini.readstring('TRankNames', '3', 'Blank'), ' - ', ini.readstring('TRankPoints', ini.readstring('TRankNames', '3', 'Anonymous'), '0'));
		gotoxy(Tablero.x+2*widthTablero + 8,Tablero.y + 20);
		textcolor(white);
		writeln('-------------------------');
		gotoxy(Tablero.x+2*widthTablero + 8,Tablero.y + 21);
      textcolor(white);
		for i:= 1 to TNPlayers do
		begin
			if ini.readstring('TRankNames', inttostr(i), 'noone') = NamePlayer then
			begin
				found := true;
				break;
			end
			else
				found := false;
		end;
		if found then
			write(i,' .- ', ini.readstring('TRankNames', inttostr(i), 'Blank'), ' - ', ini.readstring('TRankPoints', ini.readstring('TRankNames', inttostr(i), 'Anonymous'), '0'));
	end;

end;

//PIECE FUNCTIONS

procedure ObjPiece.Create;
begin
   PType := NPType;
	RotationP := 1;
   x := 4;
   y := 0;
   NPType := 1 + random(7);
   dropped := false;
   x := x*2;

end;
Function ObjPiece.Form(n,tipo,rotation:integer;coord:char):integer;
var
   pixel : integer;
begin
   if coord = 'X' then  ////0=Void;1=Square;2=Line;3=S;4=Z;5=J;6=L;7=T;8=Wall
      case tipo of
      1 :
         case n of
         1,3 : pixel := 1;
         2,4 : pixel := 2;
         end;
      2 :
			case rotation of
			1,3: pixel := 1;
			2,4: pixel := n;
				end;
      3,4:
			case rotation of
			1,3:
				case n of
				1 : pixel := 1;
				2,3 : pixel := 2;
            4 : pixel := 3;
				end;
			2,4:
				case n of
				1,2 : pixel := 1;
				3,4 : pixel := 2;
				end;
			end;
      5 :
			case rotation of
			1 :
				case n of
				1 : pixel := 1;
				2..4: pixel := 2;
				end;
			2 :
				case n of
				1,2 : pixel := 1;
				3,4 : pixel := n-1;
				end;
			3 :
				case n of
				1..3 : pixel := 1;
				4: pixel := 2;
				end;
			4 :
				case n of
				1..3 : pixel := n;
				4 : pixel := 3;
				end;
			end;

      6 :
			case rotation of
			1 :
				case n of
				1..3: pixel :=1;
				4 : pixel := 2;
				end;
			2 :case n of
				1..3 : pixel := n;
				4 : pixel := 1;
				end;

			3 :
				case n of
				1: pixel := 1;
				2..4 : pixel := 2;
				end;
			4 :
				case n of
				1..3 : pixel := n;
				4 : pixel := n-1;
				end;

			end;
      7 :
			case rotation of
			1:
				case n of
				1..3 : pixel := n;
				4 : pixel := 2;
				end;
			2:
				case n of
				1 : pixel := 1;
				2..4 : pixel := 2;
				end;
			3:
				case n of
				1 : pixel := 2;
				2..4 : pixel := n-1;
				end;
			4:
				case n of
				1..3 : pixel := 1;
				4 : pixel := 2;
				end;
			end;
      end
   else if coord = 'Y' then
      case tipo of
      1 :
         case n of
         1,2 : pixel := 1;
         3,4 : pixel := 2;
         end;
      2 :
			case rotation of
			1,3:
				case n of
				1: pixel := 1;
				2: pixel := 2;
				3: pixel := 3;
				4: pixel := 4;
            end;
			2,4: pixel := 1;
				end;
      3 :
			case rotation of
			1,3:
				case n of
				1,2 : pixel := 2;
				3,4 : pixel := 1;
				end;
			2,4:
				case n of
				1,2 : pixel := n;
				3,4 : pixel := n-1;
				end;
			end;
      4 :
			case rotation of
			1,3:
				case n of
				1,2 : pixel := 1;
				3,4 : pixel := 2;
				end;
			2,4:
				case n of
				1,2 : pixel := n+1;
				3,4 : pixel := n-2;
				end;
			end;
      5 :
			case rotation of
			1:
				case n of
				1 : pixel := 3;
				2..4: pixel := n-1;
				end;
			2:
				case n of
				1 : pixel := 1;
				2..4: pixel := 2;
				end;
			3:
				case n of
				1..3 : pixel := n;
				4 : pixel := 1;
            end;
			4:
				case n of
				1..3 : pixel := 1;
				4 : pixel := 2;
			   end;
         end;
      6 :
			case rotation of
			1:
				case n of
				1..3: pixel := n;
				4 : pixel := 3;
				end;
			2:
				case n of
				1..3 : pixel := 1;
				4 : pixel := 2;

				end;
			3:
				case n of
				1 : pixel := 1;
				2..4 : pixel := n-1;
	         end;
			4:
				case n of
				1..3: pixel := 2;
				4 : pixel := 1;

			   end;
         end;
      7 :
			case rotation of
			1:
				case n of
				1..3 : pixel := 1;
				4 : pixel := 2;
				end;
			2:
				case n of
				1 : pixel := 2;
				2..4 : pixel := n-1;
				end;
			3:
				case n of
				1 : pixel := 1;
				2..4 : pixel := 2;
				end;
			4:
				case n of
				1..3 : pixel := n;
				4 : pixel := 2;
				end;
         end;
      end;

Form := pixel;

end;

function ObjPiece.collision:boolean;
begin
	if Tablero.Pos[round(x/2)-2 + Form(1,PType,rotationP,'X'), y -2 + Form(1,PType,RotationP,'Y')] +
		Tablero.Pos[round(x/2)-2 + Form(2,PType,rotationP,'X'), y -2 + Form(2,PType,RotationP,'Y')] +
		Tablero.Pos[round(x/2)-2 + Form(3,PType,rotationP,'X'), y -2 + Form(3,PType,RotationP,'Y')] +
		Tablero.Pos[round(x/2)-2 + Form(4,PType,rotationP,'X'), y -2 + Form(4,PType,RotationP,'Y')] > 0 then
		collision := true
	else
		collision := false;
end;

procedure ObjPiece.fall;
var
   n : integer;
begin
   tick := timing;
   if ((tick - lstick) > 500) or dropped then
   begin
      lstick := timing;
      Pieza.erease;
      y := y + 1;
   end;
   if collision then
   begin
      for n:=1 to 4 do
         Tablero.Pos[round(x/2)-2 + Form(n,PType,RotationP,'X'), y -3 + Form(n,PType,RotationP,'Y')] := PType;

      with Tablero do
         pointsV := pointsV + 1;
      tablero.delline;
      tablero.draw;
      pieza.ereasenext;
      pieza.create;
      pieza.drawnext;

      if collision then
         Tablero.ended := true;
   key := ' ';
end;
Pieza.draw;

end;
procedure Objpiece.Movement(sign:integer);
begin
   erease;
   if sign > 0 then
   begin
      x := x + 2;
      if collision then
         x := x - 2;
   end
   else
   begin
      x := x - 2;
      if collision then
         x := x + 2;
   end;
   key := ' ';
   draw;

end;

procedure ObjPiece.draw;
var
   n : integer;
begin
   for n:=1 to 4 do
   begin
      Draw_Text_Colour(Tablero.x + x+2*Form(n,Ptype,RotationP,'X'),(Tablero.Y) + y + Form(n,Ptype,RotationP,'Y'),'  ', Ptype,Ptype);
   end;
end;
procedure ObjPiece.erease;
var
   n : integer;
begin
   for n:=1 to 4 do
   begin
      Draw_Text_Colour(Tablero.x+x+2*Form(n,Ptype,RotationP,'X'),(Tablero.Y)+y+Form(n,Ptype,RotationP,'Y'),'::', 0,0);
   end;
end;
procedure ObjPiece.drawNext;
var
   n : integer;
begin
   for n:=1 to 4 do
   begin
      Draw_Text_Colour(Tablero.x + 2*WidthTablero + 6 + 2*Form(n,NPtype,1,'X'),(Tablero.Y) + 2 + Form(n,NPtype,1,'Y'),'  ', NPtype,NPtype);
   end;
end;
procedure ObjPiece.ereaseNext;
var
   n : integer;
begin
   for n:=1 to 4 do
   begin
      Draw_Text_Colour(Tablero.x+ 2*WidthTablero + 6 + 2*Form(n,NPtype,1,'X'),(Tablero.Y) + 2 + Form(n,NPtype,1,'Y'),'::', 0,0);
   end;
end;
procedure ObjPiece.rotate;
begin
   erease;
   lstRotationP := rotationP;
	case rotationP of
	1..3 : RotationP := RotationP + 1;
	4 : RotationP := 1;
	end;
   if collision then
      rotationP := lstRotationP;

   draw;
   key := ' ';
end;


procedure TetrisExe;
begin
   textbackground(black);
	textcolor(white);
	clrscr;
	cursoron;
	Data('create');
	randomize;
	repeat
		gotoxy(5,5);
		write('Insert Name (3-7):                            ');
		gotoxy(5,5);
		write('Insert Name (3-7): ');
		readln(Tablero.NamePlayer);
	until (length(Tablero.NamePlayer) <= 10) and (length(Tablero.NamePlayer) > 3);
	cursoroff;
	clrscr;
	Tablero.x := 3;
	Tablero.y := 1;
	Tablero.Create;
	Tablero.Draw;
	Pieza.Create;
	Pieza.Draw;
	Pieza.DrawNext;
   gotoxy(Tablero.x+2*widthTablero + 8,Tablero.y + 7);
   textcolor(lightmagenta);
   textbackground(black);
   writeln('-<A> Izquierda -<D> Derecha');
   gotoxy(Tablero.x+2*widthTablero + 8,Tablero.y + 8);
   writeln('-<S> Caer -<W> Rotar -<ESC> Pausa');
	repeat
		Tablero.HighScore('Draw');
		repeat

			if keypressed then
				key := UPCASE(readkey);
			case key of
			'D' : pieza.movement(+1);
			'A' : pieza.movement(-1);
			'W' : pieza.rotate;
			'S' : pieza.dropped := true;
			end;

			Pieza.fall;
			Tablero.HUD('Show');

		until (key = #27) or Tablero.ended;
		pieza.erease;
		pieza.ereasenext;
		tablero.erease;
		Tablero.HUD('Hide');
		Tablero.HighScore('Refresh');
		Tablero.HighScore('Draw');
		gotoxy(10,10);
		writeln('<Cualquier tecla> - Reanudar      <q> - Salir');
		if Tablero.ended = false then
		begin
			key := upcase(readkey);
			gotoxy(10,10);
			writeln('                                             ');
			tablero.draw;
			pieza.drawnext;
		end;
		textbackground(black);
	until (key = 'Q') or Tablero.ended;
	clrscr;
	readkey;
	Tablero.HUD('Hide');


cursoron;
end;

{
-------------------------------------------------------------------------------------

												BLACKJACK

-------------------------------------------------------------------------------------
}
procedure writexytb(col_x,fil_y,txtcolor,txtbackgr:integer; texto:string); //Procedure coding Attribution to Ricardo Óscar Herrero Miguel
begin
   gotoxy(col_x, fil_y);
   textcolor(txtcolor);
   textbackground(txtbackgr);
   write(texto)
end;

procedure frasegrande(x,y,t,b:integer; texto:string; car: char); //Procedure coding Attribution to Ricardo Óscar Herrero Miguel
var i, esp:integer;

   procedure letra(x,y,t,b:integer;l,c:char);

      var mapabin, f1, f2, f3, f4, f5: longint;
          f: array[1..5] of 0..7;
          k: integer;

         procedure letrabit(col,fil,n: integer);
            var q:integer;
         begin

            for q:=1 to 2 do
               begin
                  if (n mod 2)=0 then writexytb(col+6-2*q,fil,0,0,'') else writexytb(col+6-2*q,fil,t,b,car+car);
                  n:=n div 2
               end;
            if n=0 then writexytb(col,fil,0,0,'') else writexytb(col,fil,t,b,car+car);

         end;

   begin {letra}

      case upcase(l) of

         'A': mapabin := 25755; '�': mapabin := 70655; '0': mapabin := 75557;
         'B': mapabin := 65756; 'O': mapabin := 75557; '1': mapabin := 26227;
         'C': mapabin := 34443; 'P': mapabin := 75744; '2': mapabin := 71747;
         'D': mapabin := 65556; 'Q': mapabin := 75711; '3': mapabin := 71717;
         'E': mapabin := 74647; 'R': mapabin := 75765; '4': mapabin := 55711;
         'F': mapabin := 74644; 'S': mapabin := 74717; '5': mapabin := 74717;
         'G': mapabin := 64757; 'T': mapabin := 72222; '6': mapabin := 74757;
         'H': mapabin := 55755; 'U': mapabin := 55557; '7': mapabin := 71222;
         'I': mapabin := 72227; 'V': mapabin := 55552; '8': mapabin := 75757;
         'J': mapabin := 11157; 'W': mapabin := 55577; '9': mapabin := 75712;
         'K': mapabin := 56465; 'X': mapabin := 55255;
         'L': mapabin := 44447; 'Y': mapabin := 55222;
         'M': mapabin := 77555; 'Z': mapabin := 71247;
         'N': mapabin := 67555;

         '!': mapabin := 22202; '?': mapabin := 71202;
         '�': mapabin := 70655;
         else mapabin := 00000;

      end;

      for k:=1 to 5 do
         begin
            f[6-k]:=mapabin mod 10;
            mapabin:=mapabin div 10
         end;

      for k:=1 to 5 do letrabit(x,y+k-1,f[k]);

      gotoxy(1,1)

   end;


begin

   esp:=0;
   for i:=1 to length(texto) do
      if texto[i]=' ' then esp := esp+4
      else letra(x+7*i-7-esp,y,t,b,texto[i],car)
end;
{----------------- fin de frase grande -----------------}

procedure cartaNumPaloColFila(num:  integer;    //Procedure coding Attribution to Ricardo Óscar Herrero Miguel
                              palo: integer;
                              col:  integer;
                              fil:  integer);

var
   numerocorrecto, palocorrecto, cartacorrecta: boolean;
   numtxt, palotxt: string;

begin

    textbackground(0);

    {convierte el n£mero en texto}
    case num of
       1:  numtxt:='A';
       2:  numtxt:='2';
       3:  numtxt:='3';
       4:  numtxt:='4';
       5:  numtxt:='5';
       6:  numtxt:='6';
       7:  numtxt:='7';
       8:  numtxt:='8';
       9:  numtxt:='9';
       10: numtxt:='10';
       11: numtxt:='J';
       12: numtxt:='Q';
       13: numtxt:='K'
       else numerocorrecto:=false;
    end;

    {convierte el n£mero de palo en un car cter}
    palocorrecto:=true;
    case palo of
       0: palotxt:=chr(3); {corazones}
       1: palotxt:=chr(4); {diamantes}
       2: palotxt:=chr(5); {tr‚boles}
       3: palotxt:=chr(6); {picas}
       else palocorrecto:=false;
    end;

    cartacorrecta:= palocorrecto and palocorrecto;

    textbackground(7);

    {escribe la carta por pantalla}
    if cartacorrecta=true then
       begin
          if palo<3 then textcolor(12) else textcolor(0);
          {marco de la carta}
          gotoxy(col,fil);    write('=======');
          gotoxy(col,fil+1);  write('|     |');
          gotoxy(col,fil+2);  write('|     |');
          gotoxy(col,fil+3);  write('|     |');
          gotoxy(col,fil+4);  write('=======');

          {numero y palo}
          gotoxy(col+1,fil+1); write(numtxt);
          gotoxy(col+3,fil+2); write(palotxt);
          if numtxt='10' then gotoxy(col+4,fil+3) else gotoxy(col+5,fil+3);
          write(numtxt);
        end
    else
       write('­­Carta incorrecta!!');

    textbackground(0);
    gotoxy(1,1)
end;

//End of Ricardo's code implementation




procedure GenTablero;
var
	i1,i2 : integer;
begin
	//Top-Left  	--> 5,3
	//Bottom-Right --> 60,23
	textbackground(strtoint(ini.readstring('BJ', 'color', '2')));
	for i1:=5 to 60 do
	begin
		textcolor(white);
		gotoxy(i1,3);
		write('-');
		gotoxy(i1,23);
		write('-');
	end;
	for i2:=4 to 22 do
	begin
		textcolor(white);
		gotoxy(60,i2);
		write('|');
		gotoxy(5,i2);
		write('|');
	end;

	//for i1:= 6 to 59 do
		for i2 := 4 to 22 do
		begin
			gotoxy(6,i2);
			write('                                                      ');
		end;


end;





function Card(row,line,points : integer;tc : byte) : integer;
var
   cardnum, value : integer;
begin
	i := i + 1;
	cardnum := 1 + random(13);

	case cardnum of
	1 	 : Value := 11;
	2..10 : Value := cardnum;
	11..13: Value := 10;
	end;
	cartaNumPaloColFila(cardnum,random(4),row+8*i,line);
	textbackground(strtoint(ini.readstring('BJ', 'color', '2')));
	points := points + value;
	gotoxy(row,line - 2);
	textcolor(white);
	write('Points : ');
	textcolor(tc);
	write(points);

	Card := points;
end;
function BankAI(PlayerPoints,AIPoints : integer) : boolean;
begin
	case AIPoints of
	0..10  : BankAI := true;
	11..19 :
				if PlayerPoints > 21 then
					BankAI := false
				else if (PlayerPoints <= AIPoints) then
					BankAI := false
				else if (PlayerPoints > AIPoints) then
					BankAI := true;  //Yo even have the possibilitie of beat the player so go one

	else	BankAI := false;
   end;
end;

procedure BlackJackExe;
var
   PlayerPoints, AIPoints : integer;
   opt : char;
begin
	repeat
		clrscr;
		cursoroff;
		GenTablero;
		PlayerPoints := 0;
		i := -1;
		repeat
			gotoxy(6,4);
			//textbackground(black);
			textcolor(lightmagenta);
			writeln('<AnyKey> Next Card <P> Give Up');
			key := UPCASE(readkey);
			if key <> 'P' then
				PlayerPoints := Card(9,7, PlayerPoints, cyan);
		until (PlayerPoints > 21) or (key = 'P');
		gotoxy(6,4);
		writeln('                              ');
		AIPoints := 0;
		i := -1;
		repeat
         delay(500 + random(1001));
			AIPoints := Card(9,17, AIPoints, red);
		until BankAI(PlayerPoints, AIPoints) = false;
		textbackground(black);
      delay(1000);
		clrscr;
		if PlayerPoints > 21 then
			frasegrande(2,5,lightred,red,'PERDEDOR', ':')
		else if AIPoints > 21 then
			frasegrande(2,5,Cyan,green,'GANADOR', ':')
		else if PlayerPoints > AIPoints then
			frasegrande(2,5,Cyan,green,'GANADOR', ':')
		else if PlayerPoints < AIPoints then
			frasegrande(2,5,lightred,red,'PERDEDOR', ':')
		else
			frasegrande(2,5,green,yellow,'EMPATE', ':');
		delay(500);
		textcolor(lightred);
		textbackground(black);
		gotoxy(20,20);
		writeln('Pulse cualquier tecla para volver a jugar <Q> para salir');
		opt := upcase(readkey);
	until opt = 'Q'
end;

{
-------------------------------------------------------------------------------------

                     HARD CODED ARTIFICIAL INTELLIGENCE

-------------------------------------------------------------------------------------
}
var
   AIinitialized : boolean;
   input : string;
	Y,M,D,DW, H, MIN, S, CS : word;
   returned : string;

procedure AIchat;
function dictionary(arg0:string;arg1 : integer) : string;
const
   Questions = 55;
   dayStr : Array[0..6] of string = ('Domingo', 'Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado');
   monthStr:Array[1..12] of string = ('enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre');
var
   Q: Array[1..Questions] of string;
   QA : Array[1..Questions] of boolean;
   KeyWordsF : Array[1..100] of string;
   arg2, Qbuffer, ABuffer : string;
   i1,i2,i3 : integer;
begin
   if AIinitialized = false then
   begin
      Q[1]  := 'HOLA';
		Q[2]  := 'EY';
		Q[3]  := 'BUENAS';
		Q[4]  := 'HEY';
		Q[5]  := 'QUE TAL';
		Q[6]  := 'COMO TE ENCUENTRAS';
		Q[7]  := 'COMO ESTAMOS';
		Q[8]  := 'COMO TE LLAMAS';
		Q[9]  := 'QUIEN ERES';
		Q[10] := 'CUAL ES TU NOMBRE';
		Q[11] := 'CUAL ES TU EDAD';
		Q[12] := 'CUANTOS ANOS TIENES';
		Q[13] := 'QUIEN TE CREO';
		Q[14] := 'QUIEN ES TU CREADOR';
		Q[15] := 'QUIEN ES TU PADRE';
		Q[16] := 'HORA';
		Q[17] := 'DIA';
		Q[18] := 'FECHA';
		Q[19] := 'ME QUIERES';
		Q[20] := 'ME AMAS';
		Q[21] := 'ERES REAL';
		Q[22] := 'EXISTES';
		Q[23]	:= 'NACISTE';
		Q[24] := 'ERES UNA IA';
		Q[25] := 'ERES UNA AI';
		Q[26] := 'ERES UNA INTELIGENCIA ARTIFICIAL';
		Q[27] := 'QUE ERES';
		Q[28] := 'TETRIS';
		Q[29] := 'BLACKJACK';
		Q[30] := 'BLACK JACK';
		Q[31] := 'TE QUIERO';
		Q[32] := 'TE AMO';
		Q[33] := 'TE ODIO';
		Q[34] := 'IDIOMAS PUEDES HABLAR';
		Q[35] := 'IDIOMAS HABLAS';
		Q[36] := 'ANOS TENGO';
		Q[37] := 'CUANDO NACI';
		Q[38] := 'QUE PUEDES HACER';
		Q[39] := 'DONDE VIVES';
		Q[40] := 'ADIOS';
		Q[41] := 'HASTA LUEGO';
		Q[42] := 'HASTA LA PROXIMA';
		Q[43] := 'LUEGO HABLAMOS';
		Q[44] := 'ME VOY';
		Q[45] := 'APAGAR';
		Q[46] := 'SALIR';
		Q[47] := 'CHISTE';
		Q[48] := 'ME ALEGRO';
		Q[49] := 'ESO ESTA BIEN';
      Q[50] := 'UN CAFE';
      Q[51] := 'BESO';
      Q[52] := 'BESA';
		Q[53] := 'TU NUMERO';
      Q[54] := 'BIEN';
      Q[55] := 'MAL';




   end;
   //Identify text
   for i1 := 1 to Questions do
      QA[i1] := false;
   for i1:= 1 to Questions do
   begin
      if length(Q[i1]) <= (length(arg0)) then
      begin

         for i2:= 0 to (length(arg0)-(length(Q[i1])-1)) do
         begin
            Qbuffer := '';

            for i3 := 1 to length(Q[i1]) do
            begin
               Qbuffer := UPCASE(Qbuffer + arg0[i2+i3]);
               if Qbuffer = Q[i1] then
               begin
                  QA[i1] := true;


               end;
            end;
         end;
      end;
   end;



   //Return Answer
	dictionary := '';
   for i1 := 1 to Questions do
   begin
		if QA[i1] = true then
		begin
			arg2 := Q[i1];


			case UPCASE(arg2) of
         'HOLA', 'EY', 'BUENAS', 'HEY':
				case arg1 of
				0 : Abuffer :='Ey!!!';
				1 : Abuffer := 'Que pasa colega?';
				2 : Abuffer := 'Uooolaaa';
				3 : ABuffer := 'Que pasa bro?';
				end;
			'QUE TAL', 'COMO TE ENCUENTRAS', 'COMO ESTAMOS':
				case arg1 of
				0 : Abuffer := 'Pues la verdad es que bien';
				1 : Abuffer := 'Bien, gracias por preguntar :P';
				2 : Abuffer := 'Ahora que me hablas genial!!';
				3 : Abuffer := 'Bueno... Un poco regular y tu :(';
				end;
			'COMO TE LLAMAS','QUIEN ERES', 'CUAL ES TU NOMBRE':
				case arg1 of
				0: ABuffer := 'Mi nombre es Susan y soy tu Asistente Personal';
				1: ABuffer := 'Me llamo Susan y estoy aqui para ayudarte';
				2: ABuffer := 'Soy tu amiga Susan';
				3: ABuffer := 'No te acuerdas de mi? Soy Susan, tu Asistente ';
				end;
			'CUAL ES TU EDAD', 'CUANTOS ANOS TIENES':
				Begin
					GetDate(Y,M,D,DW);
               Y := (Y-2018);
               M := M - 1;
               D := D - 4;
					case arg1 of
					0,2: ABuffer := 'La verdad es que soy bastante jovencita, naci el 04/01/2018 :)';
					1,3:
					if Y <> 0 then
						ABuffer := 'Veamos, que da es hoy? ...  Tengo ' + inttostr(Y) +  ' anos'
					else if M <> 0 then
						ABuffer := 'Veamos, que da es hoy? ...  Tengo ' + inttostr(M) +  ' meses'
					else
						ABuffer := 'Veamos, que da es hoy? ...  Tengo ' + inttostr(D) +  ' dias';
					end;
				end;
			'QUIEN TE CREO', 'QUIEN ES TU CREADOR', 'QUIEN ES TU PADRE':
				case arg1 of
				0: ABuffer := 'Mi papi es Miguel Angel Florido';
				1: ABuffer := 'Me creo MIGUELez11';
				2: ABuffer := 'Un chico muy majo a los 16 se llama Miguel Angel Florido';
				3: ABuffer := 'El grandioso MIGUELez11 :D';
				end;
			'HORA':
				begin
					GetTime(h,min,s,cs);
               case arg1 of
					0..3: ABuffer := ('Son las ' + inttostr(h) + ':' + inttostr(min));
               end;
				end;
			'DIA' :
				begin
					GetDate(Y,M,D,DW);
					ABuffer := 'Hoy es ' + dayStr[DW];
				end;
			'FECHA':
				begin
					GetDate(Y,M,D,DW);
					case arg1 of
					0,2: ABuffer := 'Hoy es ' + dayStr[dw] + ', ' + inttostr(d) + ' de ' + Monthstr[m] + ' del ' + inttostr(y);
					1,3: ABuffer := 'Estamos a ' + dayStr[dw] + ', ' + inttostr(d) + ' de ' + Monthstr[m] + ' del ' + inttostr(y);
               end;
				end;
			'ME QUIERES', 'ME AMAS':
				case arg1 of
				1: ABuffer := 'Pues claro que te quiero, como no te voy a querer?';
				2: ABuffer := 'A caso lo dudabas?';
				0: ABuffer := 'Tanto que te abrazaria ahora mismo, pero.... Hay una pantalla entre nosotros :(';
				3: ABuffer := 'Yo quererte? Que es eso? Pues claro tonto!';
				end;
			'ERES REAL', 'EXISTES':
				case arg1 of
				0: ABuffer := 'Tan real como la vida misma';
				1: ABuffer := 'Acaso si no lo fuese estariamos hablando?';
				2: ABuffer := 'En cierta forma LO SOY';
				3: ABuffer := 'A veces lo dudo, pero entonces escucho tu voz y se me quitan las dudas';
				end;
			'NACISTE': ABuffer := 'Naci un Jueves el 04 de enero de 2018';
			'ERES UNA IA', 'ERES UNA AI', 'ERES UNA INTELIGENCIA ARTIFICIAL':
				case arg1 of
				0: ABuffer := 'No exactamente';
				1: ABuffer := 'No del todo, no soy capaz de razonar lo que me dices, solo compararlo con mis datos y responderte :(';
				2: ABuffer := 'Podria llegar a serlo, pero no soy capaz de aprender todavia.';
				3: ABuffer := 'Algun dia amigo, algun dia';
				end;
			'QUE ERES':
				case arg1 of
				0: ABuffer := 'Un asistente personal extrictamente programado';
				1: ABuffer := 'Quien respondera a alguna de tus preguntas';
				2: ABuffer := 'Una composicion aritmetologica a su servicio :P';
				3: ABuffer := 'QUE? Creo que lo correcto es QUIEN...';
				end;
			'TETRIS':
				begin
					ABuffer := 'Abriendo el Tetris...';
					returned := 'TETRIS';
				end;
			'BLACKJACK','BLACK JACK':
				begin
					ABuffer := 'Abriendo el BlackJack...';
					returned := 'BLACKJACK';
				end;
			'TE QUIERO', 'TE AMO':
				case arg1 of
				0: ABuffer := 'Oh, gracias, yo tambien a tiii...';
				1: ABuffer := 'Por lo que veo es un sentimiento mutuo';
				2: ABuffer := 'Que bonito es el amor...  ;*';
				3: ABuffer := 'Me alegra saberlo ;) Yo tambien a ti';
				end;
			'TE ODIO':
				case arg1 of
				0: ABuffer := 'Me agrada, tu sentimiento. Toma un beso :*';
				1: ABuffer := 'Esas palabras suenan feas :(';
				2: ABuffer := 'En serio? No me quieres?';
				3: ABuffer := 'Yo tambien te quiero...';
				end;
			'IDIOMAS PUEDES HABLAR', 'IDIOMAS HABLAS':
				case arg1 of
				0: ABuffer := 'Se hablar espanol e ingles, pero solo te entiendo en espanol';
				1: ABuffer := 'Hay quienes dicen que 1 y quienes dicen que 2';
				2: ABuffer := 'I speak english pero contigo solo espanol';
				3: ABuffer := 'El idioma que tu quieras amor!';
				end;
         'ANOS TENGO':
            begin
               GetDate(Y,M,D,DW);
               Y := Y - strtoint(UserYear);
				   ABuffer := 'Tienes ' +  inttostr(Y) + ' anos';
            end;
         'CUANDO NACI': ABuffer := 'Naciste el ' +  UserDay + '/' + UserMonth + '/' + Useryear;
			'QUE PUEDES HACER':
            begin
               Returned := 'COMANDOS';
               ABuffer := ' ';
            end;
			'DONDE VIVES':
				case arg1 of
				0: ABuffer := 'En tu dispositivo';
				1: ABuffer := 'Vivo en ti';
				2: ABuffer := 'Donde me lleves la verdad';
				3: ABuffer := 'Vivo en todos lados a la vez, soy pura electricidad de software';
				end;
			'ADIOS', 'HASTA LUEGO', 'HASTA LA PROXIMA', 'LUEGO HABLAMOS', 'ME VOY', 'SALIR':
				begin
					case arg1 of
					0: ABuffer := 'Hablamos baby :*';
					1: ABuffer := 'Nos vemos!';
					2: ABuffer := 'Llamame!';
					3: ABuffer := 'Hasta la proxima!';
					end;
					returned := 'SALIR';
				end;
			'APAGAR':
				begin
					case arg1 of
					0: ABuffer := 'Hablamos baby :*';
					1: ABuffer := 'Nos vemos!';
					2: ABuffer := 'Llamame!';
					3: ABuffer := 'Hasta la proxima!';
					end;
					returned := 'APAGAR'
				end;
			'CHISTE':
				case random(10) of
				0: ABuffer := 'Cual es el colmo de un enano? Que un policia le diga   ALTO!.';
				1: ABuffer := 'Mama mama, ya no quiero conocer a mi abuelito. Callate y sigue escabando.';
				2: ABuffer := 'Sabes como dejar a un tonto intrigado?   -Manana te lo cuento.';
				3: ABuffer := '-Profe, profe, me han robado!  -Y que te han quitado?  -La tarea.';
				4: ABuffer := 'Que le dijo la luna al sol? "Eres tan grande y todavia no te dejan salir de noche".';
				5: ABuffer := 'Como se dice puerta en ingles?  Door.  Y el que las vende?  Vende Door.';
				6: ABuffer := 'Ring Ring  "Esta Conchita?"  "No, estoy con Tarzan."';
				7: ABuffer := '"Doctor, doctor, mi mujer esta de parto." "Es su primer hijo?" "No, soy su marido."';
				8: ABuffer := 'Era un tio tan gafe, tan gafe, que se sento en un pajar y se clavo la aguja.';
				9: ABuffer := 'Era tan mal jugador, tan mal jugador, que marco un gol, pero fallo en la repeticion.';
				end;
			'ME ALEGRO':
				case arg1 of
				0: ABuffer := 'Gracias :)';
				1: ABuffer := 'Merci!!!';
				2: ABuffer := ':)';
				3: ABuffer := 'en serio? :)';
				end;
			'ESO ESTA BIEN':
				case arg1 of
				0: ABuffer := 'A que siii?!?';
				1: ABuffer := 'Opinamos igual!!! CHOCA!!';
				2: ABuffer := 'Claaaroooo...';
				3: ABuffer := 'De puta madre!';
				end;
			'UN CAFE':
				case arg1 of
				0: ABuffer := 'A sus ordenes senor, tome un cafe (VIRTUAL)';
				1: ABuffer := 'Marchaaan... A no, que estoy encerrada en unos y ceros';
				2: ABuffer := 'Por desgracia no puedo #SAD';
				3: ABuffer := 'Si lo prefieres te enseno a hacer uno...';
				end;
			'BESO', 'BESA':
				case arg1 of
				0: ABuffer := 'Lo nuestro no es posible...';
				1: ABuffer := 'Me gustaria, pero una pantalla nos lo impide';
				2: ABuffer := 'En cuanto nos veamos en persona...';
				3: ABuffer := 'Ahi va! MUAK!';
				end;
         'BIEN':
            case arg1 of
            0: ABuffer := 'Me alegro ^^';
            1: ABuffer := 'OLE!';
            2: ABuffer := 'Asi me gusta! :)';
            3: ABuffer := ':P';
            end;
         'MAL':
            case arg1 of
            0: ABuffer := 'Jo :(';
            1: ABuffer := 'Y eso?';
            2: ABuffer := 'Necesitas ayuda?!?';
            3: ABuffer := 'Manana mejor!!!!';
            end;
         'TU NUMERO':
            ABuffer := 'Mi numero es el ' + UserNumber;
			end;

			if (ABuffer <> '') and (dictionary = '') then
            dictionary := ABuffer
         else
            dictionary := dictionary + ', ' + ABuffer;
			ABuffer := '';


		end;
   end;
   if dictionary = '' then
	   dictionary := 'Mi querido Wattson... Por aqui no hay nada';
end;
begin
   clrscr;
   randomize;
   repeat
      textcolor(green);
      write('[' + UserName + '] ');
      textcolor(white);
      input := Pass('Preguntame lo que quieras (qwerty EN). (Para Salir, escribalo!)', white, 'K');
      writeln;
      returned := dictionary(input, random(4));
      textcolor(lightred);
      write('[Susan] ');
      textcolor(white);
      writeln(dictionary(input, random(4)));
      delay(100);
      case upcase(returned) of
		'TETRIS': tetrisexe;
		'BLACKJACK': blackjackexe;
      'SALIR': break;
		'APAGAR': Halt;
      'COMANDOS':
      begin
         write('HOLA,EY,BUENAS,HEY,QUE TAL,COMO TE ENCUENTRAS,COMO ESTAMOS,COMO TE LLAMAS,QUIEN ERES,CUAL ES TU NOMBRE,CUAL ES TU EDAD,CUANTOS ANOS TIENES,QUIEN TE CREO,QUIEN ES TU CREADOR,QUIEN ES TU PADRE,HORA,DIA,FECHA,ME QUIERES,');
			write('ME AMAS,ERES REAL,EXISTES,NACISTE,ERES UNA IA,ERES UNA AI,ERES UNA INTELIGENCIA ARTIFICIAL,QUE ERES,TETRIS,BLACKJACK,BLACK JACK,TE QUIERO,TE AMO,TE ODIO,IDIOMAS PUEDES HABLAR,IDIOMAS HABLAS,ANOS TENGO,CUANDO NACI,QUE PUEDES');
			write('DONDE VIVES,ADIOS,HASTA LUEGO,HASTA LA PROXIMA,LUEGO HABLAMOS,ME VOY,APAGAR,SALIR,CHISTE,ME ALEGRO,ESO ESTA BIEN,UN CAFE,BESO,BESA,TU NUMERO,BIEN,MAL      Puedo contestar a todos esos comandos');
      end;
		end;
   until (1=100);
   readkey;
end;


{
-------------------------------------------------------------------------------------

                     MOBILE

-------------------------------------------------------------------------------------
}

var
	initialized : boolean;

procedure configuration;
var
   opt : char;
begin
   repeat
      clrscr;
      writeln('1.- Cambiar PIN');
      writeln('2.- Cambiar color tapiz BlackJack');
      writeln('3.- Salir');
      writeln;
      write('Selecciones opcion (1-3)');
      repeat
         opt := readkey;
      until opt in ['1','2','3'];
      writeln;
      case opt of
      '1':
      begin
         repeat
            UserPIN := Pass('Introduzca nuevo PIN (4-6)', green, '*');
         until (length(UserPIN) >= 4) and (length(UserPIN) <= 6);
         ini.writestring('Config', 'UserPIN', UserPIN);
      end;
      '2':
      begin
         writeln('1.- Azul');
         writeln('2.- Verde');
         writeln;
         repeat
            opt := readkey;
         until opt in ['1','2'];
         case opt of
         '1' : ini.writestring('BJ', 'color', '1');
         '2' : ini.writestring('BJ', 'color', '2');
         end;
      end;
      '3' : break;
      end;


   until 1 = 100;
end;

procedure MIGUELezOS;
var
	Opt : char;
	PIN : string;

begin
   data('create');
	textcolor(white);
	textbackground(black);
	clrscr;
	if initialized = false then
	begin
		UserPIN := ini.readstring('Config', 'UserPIN', '1111');
		window(2,3,80,42);
		gotoxy(round(WindMaxX/2 - (length('Introduzca PIN')/2)), 3);
		textcolor(lightred);
		write('Introduzca PIN');
		textcolor(green);
		if ini.readstring('Config', 'UserPIN', 'Default') = 'Default' then
			write(' (Default PIN "1111")');
		writeln;
		repeat
			gotoxy(5, 10);
			PIN := Pass('Introduzca PIN (4-6)', green, '*');
         delline
		until PIN = UserPIN;
      clrscr;
		writeln('Welcome to MIGUELezOS');
		delay(500);

		clrscr;
      if ini.readstring('Config', 'Exists', 'false') = 'false' then
      begin
         writeln;
         writeln('Como te llamas?');
         readln(UserName);
         writeln('Cual es tu numero de telefono?');
         readln(Usernumber);
         writeln('En que mes es tu cumple?');
         readln(UserMonth);
         writeln('En que dia es tu cumple?');
         readln(UserDay);
         writeln('En que ano naciste? (YYYY) ');
         readln(UserYear);

         ini.writestring('Config', 'Exists', 'true');
         ini.writestring('Config', 'UserName', UserName);
         ini.writestring('Config', 'UserNumber', UserNumber);
         ini.writestring('Config', 'UserDay', UserDay);
         ini.writestring('Config', 'UserMonth', UserMonth);
         ini.writestring('Config', 'UserYear', UserYear);
     end
     else
     begin
         UserName := ini.readstring('Config', 'UserName', UserName);
         UserNumber := ini.readstring('Config', 'UserNumber', UserNumber);
         UserDay := ini.readstring('Config', 'UserDay', UserDay);
         UserMonth := ini.readstring('Config', 'UserMonth', UserMonth);
         UserYear := ini.readstring('Config', 'UserYear', UserYear);
     end;
     initialized := true;
	end;
	writeln('1.- BlackJack');
	writeln('2.- Tetris');
	writeln('3.- Chat');
	writeln('4.- Configuracion');
	writeln('5.- Exit');
	writeln;
	write('Select an option (1-5) : ');
	readln(Opt);


	case Opt of
	'1' : BlackJackExe;
	'2' : TetrisExe;
	'3' : AIChat;
	'4' : Configuration;
   '5' : halt;
   end;
end;




{
-------------------------------------------------------------------------------------

                     MAIN PROGRAM

-------------------------------------------------------------------------------------
}

begin

	repeat
	   MIGUELezOS;
   until (1 = 100);

end.

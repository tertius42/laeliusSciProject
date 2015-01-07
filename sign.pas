{
   sign.pas
   
   Copyright 2015 Louis Thomas <lthomas@mail.swvgs.us>
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
   MA 02110-1301, USA.
   
   
}


program sign;
{$mode objfpc}
uses sysutils, crt;
label finish;
type
	dataContainer = array [0..0] of byte;
var
	i: longint;
	dir, name: String;
	data: ^dataContainer;
	datLen,returned: longint;
	aFile: file;
	aText: text;
	go: boolean; //periodic passed or failed boolean

function byteSign(b1: byte; b2: byte; b3: byte; b4: byte): String;
var
	res: longword;
	buf: String;
	bi,r1: byte;
begin
	res:= b1 * b2 + b2 * b3 + b3 * b1;
	if b4 <> 0 then
		res := res DIV b4;
	Str(res,buf);
	bi:=0;
	byteSign:='';
	repeat
		inc(bi);
		Val(Copy(buf,bi,1),r1);
		case r1 of
			0: begin
			end;
			1: begin
				Val(Copy(buf,bi,3),r1);
				byteSign:=byteSign + Chr(r1);
				bi:= bi + 2
			end;
			2: begin
				Val(Copy(buf,bi+1,2),r1);
				if r1 < 55 then
				begin
					Val(Copy(buf,bi,3),r1);
					byteSign:=byteSign+Chr(r1);
					bi:=bi+2
				end
				else
				begin
					Val(Copy(buf,bi,2),r1);
					byteSign:=byteSign+Chr(r1);
					bi:=bi+1
				end
			end;
			3..9: begin
				Val(Copy(buf,b1,2),r1);
				byteSign:=byteSign + Chr(r1);
				bi:=bi+1
			end
		end
	until bi > Length(buf)
end;

BEGIN
	dir := getCurrentDir;
	
	{$IFDEF WINDOWS}
	dir := dir + '\';
	{$ENDIF WINDOWS}
	{$IFDEF UNIX}
	dir := dir + '/';
	{$ENDIF UNIX}
	
	writeln('Sign: v0.1');
  writeln('This program comes with ABSOLUTELY NO WARRANTY.');
	writeln('This is free software, and you are welcome to redistribute it');
  writeln('under certain conditons.');
	
	if paramCount <> 1 then
	begin
		write('File: ');
		readln(name);
	end
	else
		name:= paramStr(1);
	
	{$IFDEF UNIX}
	if Copy(name,1,1) <> '/' then
	{$ENDIF UNIX}
	{$IFDEF WINDOWS}
	if Copy(name,1,1) <> '\' then
	{$ENDIF WINDOWS}
		name := dir + name;
	
	go := true;
	
	Assign(aFile,name);
	
	try
		Reset(aFile,1);
	except
		on E: Exception do
		begin
			writeln(E.Classname + ': ' + E.Message);
			go := false;
		end;
	end;
	
	if not go then goto finish;
	
	datLen:=FileSize(aFile);
	
	data := GetMem(datLen);
	
	repeat
		BlockRead(aFile,data^,datLen,returned)
	until returned < datLen;
	
	Close(aFile);
	
	i:=0;
	
	Assign(aText,name + '.sig');
	
	try
		Rewrite(aText);
	except
		on E: Exception do
			writeln(E.Classname + ': ' + E.Message)
	end;
	
	repeat
		write(aText, byteSign(data^[i],data^[i+1],data^[i+2],data^[i+3]));
		i := i + 4
	until i > datLen;
	
	Close(aText);
	
	Assign(aFile,name+'.sig');
	
	try
		Reset(aFile,1);
	except
		on E: Exception do
		begin
			writeln(E.Classname + ': ' + E.Message);
			go := false;
		end;
	end;
	
	if not go then goto finish;
	
	datLen:=FileSize(aFile);
	
	data := GetMem(datLen);
	
	repeat
		BlockRead(aFile,data^,datLen,returned)
	until returned < datLen;
	
	Close(aFile);
	
	i:=0;
	
	Assign(aText,name + '.sig');
	
	try
		Rewrite(aText);
	except
		on E: Exception do
			writeln(E.Classname + ': ' + E.Message)
	end;
	
	repeat
		write(aText, byteSign(data^[i],data^[i+1],data^[i+2],data^[i+3]));
		i := i + 4
	until i > datLen;
	
	Close(aText);
	
	Assign(aFile,name + '.sig');
	
	try
		Reset(aFile,1);
	except
		on E: Exception do
		begin
			writeln(E.Classname + ': ' + E.Message);
			go := false;
		end;
	end;
	
	writeln('Size of ' + name + '.sig: ', FileSize(aFile));
	
	Close(aFile);
	
	finish: //THIS STAYS HERE AT THE END!!!!
	writeln('Done!')
END.

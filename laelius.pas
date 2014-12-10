{
	laelius.pas

	Copyright 2014 Louis Thomas <lthomas@mail.swvgs.us>
	Sponser: Mr. Rick Fisher

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

	Purpose: Essentially, look for a virus in a file.
}


program laelius;

uses crt, sysutils;
const
	ver = 0.1;
	datLen = 13;
var
	i, j: integer;
	dir, buffer: String;
	isUnix: boolean;
	aFile: file;
	data: array [0..datLen] of byte;
	aText: text;
	
BEGIN
	clrscr;//clear the terminal
	
	dir := getCurrentDir; //get directory and determine OS
	if Copy(dir,1,1) = '/' then
		isUnix := true
	else isUnix := false;
	
	if isUnix then //add a slash at the end of the directory
		dir := dir + '/'
	else dir := dir + '\';
	
	writeln('Laelius ',ver:2:1); //announce program and version
  writeln('This program comes with ABSOLUTELY NO WARRANTY.');
	writeln('This is free software, and you are welcome to redistribute it');
  writeln('under certain conditons.');
	
	try
		Assign(aFile,'test');
		Reset(aFile, 1);
	except
		on E: EInOutError do
			writeln('File could not be accessed. Details: ' + E.ClassName + ':' + E.Message);
	end;
	
	try
		repeat
			BlockRead(aFile, data, SizeOf(data))
		until (eof(aFile));
	except
		on E: EInOutError do
		begin
			writeln('Error. Details: ' + E.ClassName + ':' + E.Message);
			Close(aFile);
		end;
	end;
	
	try
		Assign(aText, dir + 'out');
		Rewrite(aText);
		
		for i := 0 to datLen do
		begin
			if (i) MOD 256 = 0 then
			begin
				buffer:='';
				for j := i to i + 256 do
				begin
					if data[j] <> 0 then
						buffer := buffer + chr(data[j]);
					write(chr(data[j]));
				end;
				write(aText, buffer);
			end;
		end;
		
		Close(aText);
	except
		on E: EInOutError do
		begin
			writeln('ERROR: Details: ' + E.ClassName + ':' + E.Message);
		end
	end;
	writeln('Done...');
END.

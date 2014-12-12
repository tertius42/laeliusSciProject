{
	compare.pas

	Copyright 2014 Louis Thomas <lthomas@mail.swvgs.us>
	Sponsor: Mr. Rick Fisher

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

	Purpose: Scan two files and output the net differences
}


program compare;
{$mode objfpc}

uses crt,sysutils;

label ending;

type
	dataContainer = array [0..0] of byte;
var
	i,j: longint;
	returned: longint;
	aText: text;
	greater: byte;
	name: array [0..1] of string;
	aFile: array [0..1] of file;
	data: array [0..1] of ^dataContainer;
	datLen: array [0..1] of longint;
BEGIN
	writeln('Compare');
  writeln('This program comes with ABSOLUTELY NO WARRANTY.');
	writeln('This is free software, and you are welcome to redistribute it');
  writeln('under certain conditons.');
	
	if ParamCount <> 2 then
	begin
		writeln('Usage: compare <file1> <file2>');
	end
	else
	begin
		
		name[0]:=ParamStr(0);
		name[1]:=ParamStr(1);
		
		Assign(aFile[0], name[0]);
		Assign(aFile[1], name[1]);
		
		try
			Reset(aFile[0])
		except
			on E: EInOutError do
				writeln('Error on file: ' + name[0] + '. Details: ' + E.ClassName + ':' + E.Message)
		end;
		
		try
			Reset(aFile[1])
		except
			on E: EInOutError do
				writeln('Error on file: ' + name[1] + '. Details: ' + E.ClassName + ':' + E.Message)
		end;
		
		datLen[0] := FileSize(aFile[0]);
		datLen[1] := FileSize(aFile[1]);
		
		data[0] := GetMem(datLen[0]);
		data[1] := GetMem(datLen[1]);
		
		repeat
			BlockRead(aFile[0],data[0]^,datLen[0],returned);
		until returned < datLen[0];
		
		repeat
			BlockRead(aFile[1],data[1]^,datLen[1],returned);
		until returned < datLen[1];
		
		Close(aFile[0]);
		Close(aFile[1]);
		
		{if datLen[0] < datLen[1]
			datLen[0] := datLen[1];}
		
		Assign(aText, 'out');
		try
			Rewrite(aText)
		except 
			on E: EInOutError do
			begin
				writeln('Error. Details: ' + E.ClassName + ':' + E.Message);
				goto ending
			end
		end;
		
		//datLen[2] is the index of the greater
		if datLen[0] > datLen[1] then
			greater := 0
		else greater := 1;
		
		for i:= 0 to datLen[greater] do
		begin
			if data[0]^[i] <> data[1]^[i] then
				for j := i to datLen[greater] do
					if  then
						break;
			
		end;
		
	end
	
	ending:
END.


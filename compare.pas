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
	i,j,k: longint;
	returned: longint;
	aText: text;
	getOut, isUnix, equal: boolean;
	dir: String;
	diff: array [0..1] of longint;
	index: array [0..1] of byte;
	name: array [0..1] of string;
	aFile0, aFile1: file;
	data: array [0..1] of ^dataContainer;
	comp: array [0..1] of array [0..31] of byte;
	datLen: array [0..2] of longint;
BEGIN
	writeln('Compare'); //Announce program and GPL
  writeln('This program comes with ABSOLUTELY NO WARRANTY.');
	writeln('This is free software, and you are welcome to redistribute it');
  writeln('under certain conditons.');
	
	dir := getCurrentDir; //get directory and determine OS
	if Copy(dir,1,1) = '/' then
		isUnix := true
	else isUnix := false;
	
	writeln(isUnix);
	
	if isUnix then //add a slash at the end of the directory
		dir := dir + '/'
	else //not unix (windows)
		dir := dir + '\';
	
	if ParamCount <> 2 then //if not enough parameters, quit
	begin
		writeln('Usage: compare <file1> <file2>');
	end
	else
	begin
		
		name[0]:=ParamStr(1);
		name[1]:=ParamStr(2);
		
		writeln(GetCurrentDir());
		Assign(aFile0, name[0]);
		Assign(aFile1, name[1]);
		
		//writeln(dir + name[0]);
		//writeln(dir + name[1]);
		
		//readln;
		
		try
			Reset(aFile0,1)
		except
			on E: Exception do
			begin
				writeln('Error on file: ' + name[0] + '. Details: ' + E.ClassName + ':' + E.Message);
				getOut := true;
			end
		end;
		
		try
			Reset(aFile1,1)
		except
			on E: Exception do
			begin
				writeln('Error on file: ' + name[1] + '. Details: ' + E.ClassName + ':' + E.Message);
				getOut := true;
			end
		end;
		
		if getOut then
			goto ending;
		
		datLen[0] := FileSize(aFile0);
		datLen[1] := FileSize(aFile1);
		
		writeln(FileSize(aFile0));
		writeln(FileSize(aFile1));
		
		data[0] := GetMem(datLen[0]);
		data[1] := GetMem(datLen[1]);
		repeat
			BlockRead(aFile0,data[0]^,datLen[0],returned)
		until returned < datLen[0];
		
		repeat
			BlockRead(aFile1,data[1]^,datLen[1],returned)
		until returned < datLen[1];
		
		Close(aFile0);
		Close(aFile1);
		
		{if datLen[0] < datLen[1]
			datLen[0] := datLen[1];}
		Assign(aText, 'out');
		try
			Rewrite(aText)
		except 
			on E: EInOutError do
			begin
				writeln('Error. Details: ' + E.ClassName + ':' + E.Message);
				getOut := true;
			end
		end;
		
		if getOut then
			goto ending;
		
		//index[x] is the index of the greater
		if datLen[0] > datLen[1] then
		begin
			index[1] := 0; //0 is greater
			index[0] := 1
		end
		else 
		begin
			index[1] := 1; //1 is greater
			index[0] := 0
		end;
		
		diff[0] := 0;
		diff[1] := 0;
		j:=0;
		returned := 0;
		
		datLen[2] := datLen[index[1]] DIV 32;
		
		equal := false;
		
		for i := 0 to datLen[2] do
		begin
			for j := 0 to 31 do
				comp[0,j] := data[index[1]]^[(i)*32 + j];
			if comp[0,0] <> data[index[0]]^[i*32] then
				for j := 1 to 31 do
					if comp[0,j] = data[index[0]]^[i*32 + j] then
					begin
						break;
						equal := false
					end
					else
						equal := true;
			if equal then
				for j := 0 to 31 do
					write(aText, chr(comp[0,j]))
		end;
		
		{for i := 0 to datLen[index[0]] do
			if ((data[index[1]]^[i] <> data[index[0]]^[i-diff[0]+returned]) and (data[index[1]]^[i] <> data[index[0]]^[i])) and (i >= j) then
			begin
				j := i;
				returned := 1;
				writeln(aText,i);
				diff[1]:=diff[1];
				repeat
					write(aText, chr(data[index[1]]^[j]));
					inc(j);
					inc(diff[1])
				until ((data[index[1]]^[j] = data[index[0]]^[i-diff[0]+1]) and (data[index[1]]^[j+1] = data[index[0]]^[i-diff[0]+2]))
					or ((data[index[1]]^[j] = data[index[0]]^[j]) and (data[index[1]]^[j+1] = data[index[0]]^[j+1]))
					or (datLen[index[1]] <= j);
				diff[0]:=diff[1];
				writeln(aText);
				writeln(aText,j, ' length: ',j - i);
				writeln(aText)
			end;}
		writeln(i);
		writeln(j);
		Assign(aFile1,'out');
		reset(aFile1, 1);
		writeln(FileSize(aFile1));
		Close(aFile1);
		writeln(aText,i);
		Close(aText);
		writeln('Done!');
		exit
	end;
	
	ending:
END.


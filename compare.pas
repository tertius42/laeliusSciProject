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
	getOut, isUnix: boolean;
	dir: String;
	diff: array [0..1] of longint;
	index: array [0..1] of byte;
	name: array [0..1] of string;
	aFile0, aFile1: file;
	data: array [0..1] of ^dataContainer;
	comp: array [0..1] of array [0..15] of byte;
	datLen: array [0..2] of longint;
BEGIN
	writeln('Compare'); //Announce program and GPL
  writeln('This program comes with ABSOLUTELY NO WARRANTY.');
	writeln('This is free software, and you are welcome to redistribute it');
  writeln('under certain conditons.');
	
	{for i := 0 to 255 do
		write(chr(i));}
	
	dir := getCurrentDir; //get directory and determine OS
	if Copy(dir,1,1) = '/' then
		isUnix := true
	else isUnix := false;
	
	
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
		
		datLen[2] := datLen[index[1]] DIV 16;
		
		for i := 0 to datLen[2] do 											//from i to datLen / 16
		begin
			for j := 0 to 15 do 													//from 1 to 16
				comp[0,j] := data[index[0]]^[i*16 + j]; 		//load comparison array wtih bytes (16)
			for j := 0 to datLen[index[1]] do 						//to the length of the program
				if (comp[0,0] = data[index[1]]^[j]) and (diff[0] <= j) then  		//if the first byte EVER equals ANY byte in the other
				begin
					for k := 1 to 15 do 											//compare each byte with each consecutive bytes in BOTH arrays (16 bytes)
						if comp[0,k] <> data[index[1]]^[j+k] then 	//if they are EVER not equal to each other 
							break; 																//get out of here!
					if k <> 15 then break 										//if k ever reached its end, exit
					else 																			//if k DIDN'T work...
					begin																			//write differences to output
						{if j <> diff[0] then
						begin
							writeln(aText);
							writeln(aText,diff[0])
						end;
						for k := 0 to 15 do											//write everything in the comparison array to the text file
							write(aText,chr(comp[0,k]));					//of course, as a character}
						for k := 0 to 15 do
							data[index[1]]^[j + k] := 255;
						{if j <> diff[0] then
						begin
							writeln(aText);
							writeln(aText, j + 16)
						end;}
						diff[0] := j + 16;
						break
					end
				end
		end; //parent for-loop ends here (just 5 easy for-loops!)
		
		for i := 0 to datLen[index[0]] do
			if data[index[1]]^[i] <> 255 then
				write(aText,chr(data[index[0]]^[i]));
		
		writeln(i);
		writeln(j);
		
		
		writeln(aText,i);
		Close(aText);
		Assign(aFile1,'out');
		reset(aFile1, 1);
		
		writeln(FileSize(aFile1));
		Close(aFile1);
		
		writeln('Done!');
		exit
	end;
	
	ending:
END.


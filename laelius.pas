{
	laelius.pas
	
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
	
	Purpose: Scan a file and see if it is (or isn't) malicious.
}


program laelius;
{$mode objfpc}

uses crt,sysutils;
type
	dataContainer = array [0..0] of byte;
const
	version = '0.1.1';
var
	data: ^dataContainer;
	i, datLen, filLen, returned: longint;
	dir, name: string;
	isUnix, isGreat: boolean;
	aFile: file;
	aText: text;
BEGIN
	clrscr;//clear the terminal
	
	isGreat := true;
	
	dir := getCurrentDir; //get directory and determine OS
	if Copy(dir,1,1) = '/' then
		isUnix := true
	else isUnix := false;
	
	if isUnix then //add a slash at the end of the directory
		dir := dir + '/'
	else dir := dir + '\';
	
	writeln('Laelius Verison: ' + version); //Announce program and version
  writeln('This program comes with ABSOLUTELY NO WARRANTY.');
	writeln('This is free software, and you are welcome to redistribute it');
  writeln('under certain conditons.');
  
  if ParamCount = 0 then
  begin
		write('Name (dir optional) of file: ');
		readln(name)
  end
  else name := ParamStr(0);
  
  try
		Assign(aFile, name);
		Reset(aFile,1);
  except
		on E: EInOutError do
		begin
			writeln('Error. details: ' + E.ClassName + ':' + E.Message);
			isGreat := false //don't use the rest of the program if this is false.
		end
  end;
  
  if isGreat then //pretty much the rest of the project will be inside of this conditional
  begin
		datLen := FileSize(aFile);
		if datLen > 536870912 then //half a GiB is too much!
			datLen := 536870912;
		
		filLen := FileSize(aFile);
		
		try
			data := GetMem(datLen);
		except
			on E: EAccessViolation do
				writeln('Error. details: ' + E.ClassName + ':' + E.Message)
		end;
		
		try					//for now, we definitely want another file
			if datLen < 0 then //okay to use RAM if datLen is less than .5 GiB
				repeat
					BlockRead(aFile,data^,datLen,returned)//read
				until returned < datLen//until data read is less than data per BlockRead
			else
			begin
				Assign(aText,'out'); //we need to store the (large) file into a buffer on the hard disk
				Rewrite(aText); 
				
				repeat
					BlockRead(aFile,data^,datLen,returned);
					for i := 0 to returned do
						write(aText, chr(data^[i]))
				until returned < datLen;
				
				Close(aText)
			end
		except
			on E: EInOutError do //errors
				writeln('Error. details: ' + E.ClassName + ':' + E.Message);
			on E: EAccessViolation do
				writeln('Error. details: ' + E.ClassName + ':' + E.Message)
		end;
		
		Close(aFile);
		
		//for debugging and seeing if it worked...
		for i := 0 to filLen do
			write(chr(data^[i]))
		
		//Just a fun-fact, Length(data^) returns 1, so we have to keep track of its length with datLen
		
		
		
  end
  
END.

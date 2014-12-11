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
{$mode objfpc}

uses crt, sysutils;
type
	dataContainer = array [0..0] of byte;
const
	ver = 0.1;
	//datLen = 158720;
var
	i, j: integer; //counters
	dir: String;
	isUnix: boolean; //probably important
	aFile: file;
	data: ^dataContainer;
	datLen,fileLen: longint;
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
	
	try //assign file to test binary readings
		Assign(aFile,'test');
		Reset(aFile, 1);
		if FileSize(aFile) < 536870912 then //don't want to allocate more than 512MB of memory!
			datLen := (FileSize(aFile) DIV 1024 + 1) * 1024
		else datLen := 536870912;
		fileLen := FileSize(aFile);
		//datLen := 13;
		writeln('File size: ', FileSize(aFile), ' bytes'); //report size of file in bytes
	except
		on E: EInOutError do //report erros if any
			writeln('File could not be accessed. Details: ' + E.ClassName + ':' + E.Message);
	end;
	
	try
		data:=GetMem(datLen);//dynamically resize array
		//FillByte(data^,datLen,0);
		writeln(datLen);
		writeln('Length of data: ', Length(data^));
		writeln('Size of data: ', SizeOf(data));
	except
		on E: EAccessViolation do
			writeln('Error. Details: ' + E.ClassName + ':' + E.Message)
	end;
	
	try
		repeat
			BlockRead(aFile, data^, datLen, j);
			//write(j);
		until j = 0;
	except
		on E: EInOutError do //report errors if able to
		begin
			writeln('Error. Details: ' + E.ClassName + ':' + E.Message);
			Close(aFile) //and close file?
		end
	end;
	
	try
		Assign(aText, 'out');
		Rewrite(aText);
		
		try
			for i := 0 to datLen do
			begin
				//if data^[i] <> 0 then
				if i <= fileLen then
				begin
					write(aText, chr(data^[i]));
					write(chr(data^[i]));
				end;
			end
		except
			on E: EAccessViolation do
			begin
				writeln('Error. Details: ' + E.ClassName + ':' + E.Message);
				Close(aText);
			end;
		end;
	except 
		on E: EInOutError do
		begin
			writeln('Error. Details: ' + E.ClassName + ':' + E.Message);
		end
	end;
	
	(*try //try to write new file (from output of the test file)
		Assign(aText, dir + 'out');
		Rewrite(aText);
		
		for i := 0 to Length(data) do
		begin
		
			if i MOD  = 0 then
			begin
				buffer:=''; //clear buffer
				
				for j := i to i + 256 do
				begin
					writeln(j);//debug
					
					try
						if data[j] <> 0 then
							buffer := buffer + chr(data[j]); //parse bytes to a character, then add to buffer
						write(chr(data[j])); //write parse to screen
					except
						on E: EAccessViolation do
							writeln('Error. Details: ' + E.ClassName + ':' + E.Message);
					end; //try
					
				end; //for j
				
				write(aText, buffer); //write buffer to file
			end; //if i MOD 256
			
		end; //for i to datLen
		
		Close(aText);
	except
		on E: EInOutError do //on error, display details
		begin
			writeln('ERROR: Details: ' + E.ClassName + ':' + E.Message);
		end
	end;*)
	
	writeln('Done...'); //Anounce ending of program
END.

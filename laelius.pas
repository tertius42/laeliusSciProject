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
const
	ver = 0.1;
var
	i, j: integer; //counters
	dir, buffer: String;
	isUnix: boolean; //probably important
	aFile: file;
	data: array of byte;
	datLen: longint;
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
		datLen := FileSize(aFile);
		writeln('File size: ', datLen, ' bytes'); //report size of file in bytes
	except
		on E: EInOutError do //report erros if any
			writeln('File could not be accessed. Details: ' + E.ClassName + ':' + E.Message);
	end;
	
	try
		SetLength(data, datLen + 1);
		writeln('Size of data: ', Length(data));
		for i := 0 to Length(data) do
		begin
			writeln(i);
			data[i] := 0;
		end;
	except
		on E: EAccessViolation do
			writeln('Error. Details: ' + E.ClassName + ':' + E.Message);
	end;
	
	try
		repeat //try to read file
			BlockRead(aFile, data, SizeOf(data))
		until (eof(aFile)); //to ending (doesn't really work with binary)
	except
		on E: EInOutError do //report errors if able to
		begin
			writeln('Error. Details: ' + E.ClassName + ':' + E.Message);
			Close(aFile); //and close file?
		end;
	end;
		writeln(data[0]);
	
	try
		Assign(aText, 'out');
		Reset(aText);
		
		try
			for i := 0 to datLen do
			begin
				writeln(i);
				writeln(data[0]);
					if data[i] <> 0 then
						write(aText, chr(data[i]));
			end
		except
			on E: EAccessViolation do
				writeln('Error. Details: ' + E.ClassName + ':' + E.Message);
		end;
		
		Close(aText);
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

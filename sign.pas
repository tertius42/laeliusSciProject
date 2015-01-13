{
	sign.pas

	Copyright 2015 Louis Thomas <lthomas@mail.swvgs.us>
	Date: 1 January 2015					Sponsor: Mr. Rick Fisher

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

	Purpose: Take a file and compress it not for uncompression, but to 
	keep in store for virus detection later.
	
	Odd fact: Compressing once results 3x compression (appr.).
	Compressing twice result appr. 20..24x compression! Amazing!
}
program sign;
{$mode objfpc}
uses sysutils, crt;
label finish;
type
	dataContainer = array [0..0] of byte; //almost a static array!
var
	i: longword;
	dir, name, result: String;
	data: ^dataContainer;
	datLen,returned: longword;
	aFile: file;
	aText: text;
	go: boolean; //periodic passed or failed boolean
	init: double;

{ * String := byteSign(b1, b2, b3, b4);
	* Converts 4 bytes into something less than four bytes
	* Returns a small String that contains (hopefully) less than 4 characters
	* that correspond to their binary counterparts }
function byteSign(b1: byte; b2: byte; b3: byte; b4: byte): String;
var
	res: longword;
	buf: String;
	bi,r1: byte;
begin

	res:= b1 * b2 + b2 * b3 + b3 * b1; //sum the products of the first three bytes
	
	if b4 > 0 then //don't want DIV BY 0 error
		res := res DIV b4;//}
		
	Str(res,buf);
	
	bi:=0; //initialize
	byteSign:='';
	
	repeat
		inc(bi);
		Val(Copy(buf,bi,1),r1);
		
		case r1 of
			0: begin //do nothing (for something such as 081)
			end;
			
			1: begin //if 1, 100..199 are okay as a byte, so we know the next 2 numbers are good
				if Length(buf) - bi >= 3 then //don't want to try and get numbers from nothing!
					Val(Copy(buf,bi,3),r1) //convert 3 numbers to one number
				else Val(Copy(buf,bi,Length(buf) - bi),r1);
				byteSign:=byteSign + Chr(r1); //add to net output
				bi:= bi + 2 //increase counter (net) by 3
			end;
			
			2: begin //if 2, 200..255 are okay, but 256..299 aren't...
				Val(Copy(buf,bi+1,2),r1);
				if r1 <= 55 then //so evaluate the next two numbers
				begin
					if Length(buf) - bi >= 3 then //likewise
						Val(Copy(buf,bi,3),r1)
					else Val(Copy(buf,bi,Length(buf) - bi),r1);
					byteSign:=byteSign+Chr(r1);
					bi:=bi+2
				end
				else //if greater than 55
				begin
					Val(Copy(buf,bi,2),r1);
					byteSign:=byteSign+Chr(r1);
					bi:=bi+1
				end
			end;
			
			3..9: begin //300..999 will never exist as bytes, but 30..99 will
				if Length(buf) - bi >= 2 then
					Val(Copy(buf,bi,2),r1)
				else Val(Copy(buf,bi,1),r1);
				byteSign:=byteSign + Chr(r1);
				bi:=bi+1
			end //ends 3..9
			
		end //ends case
	until bi > Length(buf)
end;//ends byteSign

BEGIN
	dir := getCurrentDir; //get directory
	
	{$IFDEF WINDOWS} //correct directory for use with files
	dir := dir + '\'; //good for misceallaneous operating systems
	{$ENDIF WINDOWS}
	{$IFDEF UNIX}
	dir := dir + '/';
	{$ENDIF UNIX}
	
	writeln('Sign: v0.1'); //Announce title and GPL
  writeln('This program comes with ABSOLUTELY NO WARRANTY.');
	writeln('This is free software, and you are welcome to redistribute it');
  writeln('under certain conditons.');
	
	if (paramCount > 2) or (paramCount < 1) then //if it got odd input
	begin
		write('File: '); //directly prompt for a file
		readln(name);
	end
	else //get filename from parameter
	begin
		name:= paramStr(1);
		result:= paramStr(2);
	end;
	
	//Important: Let the user know that the program is grinding!
	writeln('Working...');
	
	//Get an initial time value
	init:=TimeStampToMSecs(DateTimeToTimeStamp(Time));
	
	go := true; //initialize
	
	Assign(aFile,name); //initialize
	
	try //open file with provisions for errors
		Reset(aFile,1);
	except
		on E: Exception do
		begin
			writeln(E.Classname + ': ' + E.Message);
			go := false; //we don't want the rest of the program to execute!
			writeln('Nothing to do!')
		end
	end;
	
	if not go then goto finish; //label is at the VERY END
	//love statements like that
	
	datLen:=FileSize(aFile); //set length of buffer to the file size
	
	data := GetMem(datLen); //get the same amount of data from the memory
	
	repeat //read the file into memory
		BlockRead(aFile,data^,datLen,returned)
	until returned < datLen;
	
	Close(aFile); //done with the file!
	
	i:=0;
	
	if paramCount = 2 then
	begin
		Assign(aText,result); //output file

		try //rewrite a new file with provisions for errors
			Rewrite(aText);
		except
			on E: Exception do
			begin
				writeln(E.Classname + ': ' + E.Message);
				go := false
			end
		end
	end
	else
	begin
		Assign(aText,name + '.sig'); //output file

		try //rewrite a new file with provisions for errors
			Rewrite(aText);
		except
			on E: Exception do
			begin
				writeln(E.Classname + ': ' + E.Message);
				go := false
			end
		end
	end;
	
	if not go then goto finish; //exit
	
	repeat //byteSign every four bytes to get lossy compression
		write(aText, byteSign(data^[i],data^[i+1],data^[i+2],data^[i+3]));
		i := i + 4
	until i > datLen;
	
	Close(aText);
	
	{//for file size (more or less debug info)
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
	
	//write to stdout
	writeln('Size of ' + name + '.sig: ', FileSize(aFile));
	
	Close(aFile);//}
	
	//Report the time in seconds how long it took to complete
	writeln('Took ', ((TimeStampToMSecs(DateTimeToTimeStamp(Time)) - init) / 1000):0:3, ' seconds');
	
	finish: //THIS STAYS HERE AT THE END!!!!
	writeln('Done!') //Annouce that the program has indeed finished
END.

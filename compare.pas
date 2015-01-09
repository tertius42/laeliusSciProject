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

label ending; //go to end!

type
	dataContainer = array [0..0] of byte;
var
	i,j,k: longword;//counters
	returned: longword; //returned length data, necessary to prevent errors
	init: double; //timer
	block: word; //size of read block
	aText: text; //output file
	getOut, isUnix, go: boolean; //misc booleans (isUnix is of now deprecated!)
	dir: String; //current directory
	diff: array [0..0] of longword; //array for compatibility with earlier versions
	comp: array [0..127] of byte; //to handle both block sizes
	index: array [0..1] of byte; //wait till ye see the nested arrays
	name: array [0..1] of string; //names of both the files
	aFile0, aFile1, aFile2: file; //byte files
	data: array [0..2] of ^dataContainer; //again, the nested arrays
	datLen: array [0..2] of longword; //size of the files
BEGIN
	writeln('Compare'); //Announce program and GPL
  writeln('This program comes with ABSOLUTELY NO WARRANTY.');
	writeln('This is free software, and you are welcome to redistribute it');
  writeln('under certain conditons.');
	
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
		writeln('Usage: compare <file1> <file2>'); //explain how to use the program
	end
	else
	begin
		
		name[0]:=ParamStr(1);//get file names into the program safely!
		name[1]:=ParamStr(2);
		
		//writeln(GetCurrentDir()); //Report current working directory
		Assign(aFile0, name[0]);
		Assign(aFile1, name[1]);
		
		try //open the file with provisions for errors
			Reset(aFile0,1)
		except
			on E: Exception do
			begin
				writeln('Error on file: ' + name[0] + '. Details: ' + E.ClassName + ':' + E.Message);
				getOut := true //need to get out as soon as possible
			end
		end;
		
		try //both files
			Reset(aFile1,1)
		except
			on E: Exception do
			begin
				writeln('Error on file: ' + name[1] + '. Details: ' + E.ClassName + ':' + E.Message);
				getOut := true
			end
		end;
		
		if getOut then //get out as soon a possible
			goto ending;
		
		datLen[0] := FileSize(aFile0); //get files sizes
		datLen[1] := FileSize(aFile1);
		
		writeln(FileSize(aFile0)); //report file sizes in bytes
		writeln(FileSize(aFile1));
		
		data[0] := GetMem(datLen[0]); //get memory from RAM in the size of the files
		data[1] := GetMem(datLen[1]);
		repeat //get files into the RAM
			BlockRead(aFile0,data[0]^,datLen[0],returned)
		until returned < datLen[0];
		
		repeat //again
			BlockRead(aFile1,data[1]^,datLen[1],returned)
		until returned < datLen[1];
		
		Close(aFile0); //Don't need the files any more!
		Close(aFile1);
		
		{if datLen[0] < datLen[1]
			datLen[0] := datLen[1];}
		Assign(aText, 'out'); //open the output file
		try
			Rewrite(aText) //to put output in
		except 
			on E: EInOutError do
			begin
				writeln('Error. Details: ' + E.ClassName + ':' + E.Message);
				getOut := true
			end
		end;
		
		if getOut then//get out as soon as possible
			goto ending;
		
		//index[1] is the index of the greater
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
		
		diff[0] := 0; //initializations
		i:=0;
		j:=0;
		returned := 0;
		
		writeln('Determining differences...'); //report status
		
		//get initial time stamp
		init:=TimeStampToMSecs(DateTimeToTimeStamp(Time));
		
		go := true;//more initializations
		
		block := 128; //we will first look over the program in 128-byte blocks, later 16
		
		//The nastiest, stenchiest for-loop ye ever laid eyes on!
		//This be the part where we get to compare bytes!
		//There a direct copy underneath without all the comments
		for i := 0 to datLen[index[1]] DIV block do //for the length of the longer byte sequence divided by the block size
		begin
			for j := 0 to block-1 do //load the block
				comp[j] := data[index[1]]^[i*block+j];
			go := true; //initialize go and diff[0]
			diff[0] := 0;
			for j := 0 to datLen[index[0]] do //for the length of the smaller byte sequence
			begin
				if (comp[0] = data[index[0]]^[j]) and (j >= diff[0]) then //if the first byte of the block is EVER equal to ANYTHING in the other byte ssequence
					for k := 1 to block-1 do // for the remaining block
						if (comp[k] = data[index[0]]^[j+k]) then //compare against the sequence
							go := false //if never equal, go will remain false
						else
						begin //otherwise, go will become true, this for-loop will break,
							go := true;
							diff[0] := j + 1; //and we will wait a little-bit to compare again
							break
						end;
				if not go then break //if the block had equaled SOMETHING in the sequence, break
				else if (j = datLen[0]) then //else, write to file as a difference
					for k := 0 to block-1 do
						write(aText,chr(comp[k]))
			end
		end; //Ain't ye a buet?
		
		Assign(aFile2,'./out'); //assign the output
		Reset(aFile2,1); //got lazy here, but the program will essentially do the same thing, anyways
		
		datLen[2] := FileSize(aFile2); //get file size
		data[2] := GetMem(datLen[2]); //get same amount from RAM
		
		repeat //put file into RAM
			BlockRead(aFile2,data[2]^,datLen[2],returned)
		until returned < datLen[2];
		
		block:=16; //Now ye's goin' ta observe in 16-byte blocks!
		
		Close(aFile2); //Close the file
		Rewrite(aText);//So that we can write to it again
		
		for i := 0 to datLen[2] DIV block do //Same for-loop from before
		begin
			for j := 0 to block-1 do
				comp[j] := data[2]^[i*block+j];
			go := true;
			diff[0] := 0;
			for j := 0 to datLen[index[0]] do
			begin
				if (comp[0] = data[index[0]]^[j]) and (j >= diff[0]) then
					for k := 1 to block-1 do
						if (comp[k] = data[index[0]]^[j+k]) then
							go := false
						else
						begin
							go := true;
							diff[0] := j + 1;
							break
						end;
				if not go then break
				else if (j = datLen[0]) then
					for k := 0 to block-1 do
						write(aText,chr(comp[k]))
			end
		end;// Ends here!}
		
		Close(aText); //save
		reset(aFile2, 1);
		
		//Report size (in bytes) of the output
		writeln('Size of ''out'': ', FileSize(aFile2), ' bytes');
		Close(aFile2);
		
		//Report length in time
		writeln('Took ',((TimeStampToMSecs(DateTimeToTimeStamp(Time)) - init)/1000):0:3,' seconds');
		writeln('Done!');
		exit
	end;
	
	ending:
END.

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
	
	Purpose: Scan a file and see if it has (or hasn't) been maliciously modified.
}


program laelius;
{$mode objfpc}

uses crt, sysutils, process, math;
var
	exe: TProcess;
	//i: byte;
	dir, name, little: String;
	newSize, oldSize, diffSize, comparison, margin: double;
	exboo, check: boolean;
	separator: char;
	aText: text;
	sess: File;

{ String := hexName(hName);
* Purpose: Returns a string that is the conversion of the input into hexadecimal.
* 	It watches for OS-specific directory separators and separates the hexadecimal accordingly.
*}
function hexName(hName: String): String;
var
	hi,hj: byte; //counters
	hSum,hLeft: word; //sums for keeping track of numbers
	hPow: byte; //power of the current digit
	hBuf: char; //buffer character
begin
	hSum:=0; //initializations
	hi:=0;
	hexName:='';
	repeat
		inc(hi); //increment counter
		{$IFDEF WINDOWS} //if a separator or line ending
		if ((Copy(hName,hi,1) = '\') or (Copy(hName,hi,1) = '')) and (hSum <> 0) then
		{$ENDIF WINDOWS}
		{$IFDEF UNIX}
		if ((Copy(hName,hi,1) = '/') or (Copy(hName,hi,1) = '')) and (hSum <> 0) then
		{$ENDIF UNIX}
		begin //convert to hexadecimal
			hLeft:=hSum; //hLeft is hSum in the beginning
			hPow:=0;//initialization
			
			repeat
				inc(hPow) //get maximum power
			until intPower(16,hPow) > hLeft;
			
			repeat
				dec(hPow); //decrease the working power as the digit goes to zero
				hj := 0;
				repeat //get digit
					inc(hj)
				until intPower(16,hPow) * hj > hLeft;
				
				dec(hj); //decrement counter for over-counting in the last repeat
				
				if hj > 9 then //convert to character
					hBuf:=Chr(hj - 10 + 65)
				else hBuf := Chr(hj + 48);
				
				hexName:=hexName + hBuf; //add buffer to output
				
				dec(hLeft,Round(intPower(16,hPow) * hj)) //decrease the hLeft by much the digit took
				
			until (hLeft = 0) and (hPow = 0); //repeat until there is nothing left of hSum; power should also be zero
			hSum:=0
		end
		else
			inc(hSum,Ord(Copy(hName,hi,1)[1]))//get sum by increasing by the byte value of the character{;
		//write(hSum,' ');//}
	until hi > Length(hName) //until the string is ended
end;

BEGIN
	dir:=GetCurrentDir; //get directory
	
	{$IFDEF UNIX} //and add a separator to the end
	dir := dir + '/';
	{$ENDIF UNIX}
	{$IFDEF WINDOWS}
	dir := dir + '\';
	{$ENDIF WINDOWS}
	
	writeln('Laelius'); //announce program and GPL
  writeln('This program comes with ABSOLUTELY NO WARRANTY.');
	writeln('This is free software, and you are welcome to redistribute it');
  writeln('under certain conditons.');
  
  repeat //file in question comes from parameters
		
		if ParamCount < 1 then
		begin
			writeln('Usage: laelius <file>');
			exit
		end
		else name := paramStr(1); //get file name from parameter
		
		{writeln('ESC to exit, or');
		writeln('Press any key to continue...');
		if readkey = #27 then
			exit;}
		
		{$IFDEF UNIX} //determine separators in OS
		separator:='/';
		{$ENDIF UNIX}
		{$IFDEF WINDOWS}
		separator:='\';
		{$ENDIF WINDOWS}
		
		exboo := false; //never exits, apparently
		
		little := hexName(name); //little version of file name (hexadecimal name!)
		
		Assign(aText,dir + little + separator + '.lae');//.lae file designates existence (Laelius Exists)
		
		check := true; //initialization
		
		try
			Reset(aText); //try to open the file
			Close(aText); //will close if it exists
		except 
			on E: Exception do 
				if (E.ClassName = 'EInOutError') and (E.Message = 'File not found') then //file does not exist
				begin
					Mkdir(dir + little); //if the file doesn't exist, the directory doesn't exist
					check := false //which means this is an initialization session for the file in question
				end
				else
				begin
					writeln(E.ClassName + ' : ' + E.Message); //otherwise, system got a serious error
					exit //will exit
				end
		end;
		
		if not check then //if file not determined before...
		begin
			Rewrite(aText); //create the .lae file
			Close(aText);
			
			exe := TProcess.create(nil); //create a new TProcess object
			
			{$IFDEF WINDOWS}
			exe.Executable:='./sign.exe';
			{$ENDIF WINDOWS}
			{$IFDEF UNIX}
			exe.Executable:='./sign';
			{$ENDIF UNIX}
			
			exe.Options := exe.Options + [poWaitOnExit];
			
			exe.Parameters.add(name); //parameters: sign <name of file> [<output file>]
			exe.Parameters.add(dir + little + separator + little + '.las'); //.las = Laelius Signature
			
			exe.Execute; //this will create a signature of the file in question for the first time
			
		end
		else
		begin //assume the files already exist 
			
			exe := TProcess.create(nil);//create a signature of the file that exists now
			
			{$IFDEF WINDOWS}
			exe.Executable:='./sign.exe';
			{$ENDIF WINDOWS}
			{$IFDEF UNIX}
			exe.Executable:='./sign';
			{$ENDIF UNIX}
			
			exe.Options := exe.Options + [poWaitOnExit]; //wait on exit (don't get ahead of yourself!)
			
			exe.Parameters.add(name); //parameters: sign <name of file> [<output file>]
			exe.Parameters.add(dir + little + separator + little + '.lan'); //.lan = Laelius New
			
			exe.Execute; //run
			
			exe := TProcess.create(nil); //Compare the signatures and output to directory
			
			{$IFDEF WINDOWS}
			exe.Executable:='./compare.exe';
			{$ENDIF WINDOWS}
			{$IFDEF UNIX}
			exe.Executable:='./compare';
			{$ENDIF UNIX}
			
			exe.Options := exe.Options + [poWaitOnExit];
			
			//Parameters: compare <file 1> <file 2> [<output file>]
			exe.Parameters.add(dir + little + separator + little + '.las'); //order is not specific
			exe.Parameters.add(dir + little + separator + little + '.lan');
			exe.Parameters.add(dir + little + separator + 'out'); //output must be in the end, though!
			
			exe.Execute; //run
			
			//next three blocks gets the output file sizes of each of the files
			Assign(sess, dir + little + separator + 'out'); //output from compare
			Reset(sess,1);
			diffSize := FileSize(sess);
			Close(sess);
			
			Assign(sess, dir + little + separator + little + '.las'); //output from old signature
			Reset(sess,1);
			oldSize := FileSize(sess);
			Close(sess);
			
			Assign(sess, dir + little + separator + little + '.lan'); //output from new signature
			Reset(sess,1);
			newSize := FileSize(sess);
			Close(sess);
			
			comparison := abs(newSize - oldSize);
			margin := 0.05 * diffSize; //margin of error (5%)
			
			//if Change in file sizes are about equal to the Compare output
			//or Compare output is the same size as either file
			if ((comparison < diffSize + margin) and (comparison > diffSize - margin)) or ((diffSize < newSize * 0.05 + newSize) and (diffSize > newSize - newSize * 0.05)) or ((diffSize < oldSize * 0.05 + oldSize) and (diffSize > oldSize - oldSize * 0.05)) then
			begin
				writeln(TimeToStr(Time));//report time of detection
				beep;//system bell (Windows only???)
				writeln('WARNING: Tracked file sizes and comparitive file size indicate a problem!'); //report
				writeln('File location: ' + name); //file in question 
				writeln('Press any key to continue...');//readkey to continue program execution
				readkey;
				writeln
			end
			else//if okay, then
			begin
				exe := TProcess.create(nil); //get a new signature of what exists now
				
				{$IFDEF WINDOWS}
				exe.Executable:='./sign.exe';
				{$ENDIF WINDOWS}
				{$IFDEF UNIX}
				exe.Executable:='./sign';
				{$ENDIF UNIX}
				
				exe.Options := exe.Options + [poWaitOnExit];
				
				exe.Parameters.add(name); //and use the old .las as the new signature
				exe.Parameters.add(dir + little + separator + little + '.las');
				
				exe.Execute
			end;
			
			//30 sec delay between ticks
			delay(30000)
			
		end
		
	until exboo //never exits, by the way: Kill the process, ALT+F4, or program in a way to exit the program (Free Pascal)
	
END.

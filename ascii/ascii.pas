{
   ascii.pas
   
   Copyright 2015 Louis Thomas <lthomas@mail.swvgs.us>
   
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
   
   
}


program ascii;
var i : byte;
	aText: text;
BEGIN
	Assign(aText,'./out');
	Rewrite(aText);
	i:=0;
	write(aText,chr(i));
	repeat
		i:=i+1;
		
		if Chr(i) = 'A' then
		begin
			writeln(aText);
			writeln(aText,i);
			writeln(aText);
		end;
		
		write(aText,chr(i))
	until i = 255;
	Close(aText);
	
END.


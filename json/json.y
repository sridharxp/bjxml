%{
(*
Copyright (C) 2014, Sridharan S

This file is part of Json2Xml.

Json2Xml is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Json2Xml is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License version 3
along with Tamil Keyboard.  If not, see <http://www.gnu.org/licenses/>.
*)
unit json;

interface

uses
  SysUtils, LexLib, YaccLib, jsonlex;

%}

%token LCB RCB LSB RSB COMMA COLON QUOTE
%token TEXT QTEXT

%%

object:    LCB bson_list RCB
	;
bson_list:      bson {writeln('Bson');}
        |       bson_list COMMA bson
        ;                
element_list: element
        |     element_list COMMA element
        ;
value:     element | object | arr
        ;
bson:      element COLON value
        ;
arr:      LSB element_list RSB
        ;
element:   TEXT  {writeln('TEXT');}
        |  QUOTE QTEXT QUOTE {writeln('QTEXT');}
        ;
%%
end.

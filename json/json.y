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
  SysUtils, LexLib, YaccLib, jsonlex, Contnrs;
const
  preamble = '<?xml version="1.0" encoding="UTF-8"?>';
%}

%token LCB RCB LSB RSB COMMA COLON QUOTE
%token TEXT QTEXT COMMENT
%{
type YYSType = AnsiString;
var
  xmlText: ansiString;
%}
%%

root:      object {$$ := $1 ; xmlText := preamble + #13#10 + '<root>' + #13#10 + $$ + #13#10 + '</root>';} 
        |  arr    {$$ := $1 ; xmlText := preamble + #13#10 + '<root>' + #13#10 + $$ + #13#10 + '</root>';} 
        ;        
object:    LCB 
           bson_list 
           RCB {$$ := $2;} 
	;
bson_list:      bson 
        |       bson_list COMMA bson {$$ := $1 + #13#10 + $3;}
        ;                
arr_list:  aitem 
        |  arr_list COMMA aitem {$$ :=  $1 + #13#10 + $3;}
        ;
value:     element
        |  object  {$$ := #13#10 + $1 + #13#10;}
        |  arr     {$$ := #13#10 + $1 + #13#10;}
        ;
bson:      element COLON value
           {
             $$ := '<'+ $1 +'>'+  $3 + '</'+ $1 +'>';
           }
        ;
arr:      LSB 
          arr_list RSB {$$ := $2;}
        ;
aitem:    element
           { 
           $$ := '<element>' +  $1 + '</element>';
           }
        | object
           {
           $$ :=  '<element>' + #13#10 + $1 + #13#10 + '</element>';
           }                                     
        ;
element:   QUOTE QTEXT {$2 := yytext;} QUOTE {$$ := $2;}
        |  TEXT {$$ := yytext;} 
        ;
%%
end.

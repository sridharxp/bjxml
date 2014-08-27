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
unit jsonlex;

interface

uses
  SysUtils, LexLib;

const
      LCB = 257;
      RCB = 258;
      LSB = 259;
      RSB = 260;
      COMMA = 261;
      COLON = 262;
      QUOTE = 263;
      TEXT = 264;
      QTEXT = 265;
      COMMENT = 266;
%}
CE              \*\/
LAS             [^*]
LAC             \*[^/]
WS              [ \t\n]
CS              \/\*

%start STR REMARK

 var
   cline: AnsiString;
 function yylex: integer;

 implementation

%%
<REMARK>{CE}          begin     cline := cline + yytext + #13#10; start(0);              end;   
<REMARK>({LAS}|{LAC}|{WS})+     begin     cline := cline + yytext; start(REMARK);end;
{CS}                  begin     cline := cline + #13#10 + yytext; start(REMARK);         end;

<STR>\"     begin
              start(0);
              return(QUOTE);
            end;

\"          begin
              start(STR);
              return(QUOTE);
            end;

<STR>[^"\n]+   begin
                  return(QTEXT);
               end;

{           begin
              return(LCB);
            end;

}           begin
              return(RCB);
            end;

\[          begin
              return(LSB);
            end;

\]           begin
              return(RSB);
            end;

:           begin
              return(COLON);
            end;

,           begin
              return(COMMA);
            end;

[^" \n:,{}[\]]+   begin
              return(TEXT);
            end;

{WS}+       ;


%%
end.


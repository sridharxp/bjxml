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
%start STR REMARK

 function yylex: integer;

 implementation

%%
<REMARK>\*\/          begin     start(0);             end;   
<REMARK>[^*]+        begin     start(REMARK);end;
<REMARK>*[^/]+      begin     start(REMARK);end;
<REMARK>[ \t\n]+        begin     start(REMARK);end;
\/\*                begin    start(REMARK);end;

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

]           begin
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

[ \t\n]+    ;


%%
initialization
  AssignFile(yyinput, 'json.txt');
  FileMode := 0;  {Set file access to read only }
  Reset(yyinput);
  AssignFile(yyoutput, 'xml.txt');
  Rewrite(yyoutput);
finalization
end.


program json2xml;

{$APPTYPE CONSOLE}

uses
//  System,
  SysUtils,
  Json,
  lexlib,
//  Dialogs,
  bjxml2 in 'F:\DL\bjxml\bjxml2.pas';

var
//  xdb: IbjXml;
  jsonFN: string;
  xmlFN: string;
begin
  { TODO -oUser -cConsole Main : Insert code here }
  if ParamCount = 0 then
  begin
    writeln('Sytax: json2xml <jsonFileName> [xmlFileName]');
    Exit;
  end;
  if ParamCount = 1 then
  begin
    writeln('Sytax: json2xml <jsonFileName> [xmlFileName]');
    writeln('       Translating to xml.txt');
    jsonFN := ParamStr(1);
    xmlFN := 'xml.txt';
  end;
  if ParamCount = 2 then
  begin
    jsonFN := ParamStr(1);
    xmlFN := ParamStr(2);
  end;
  AssignFile(yyinput, jsonFN);
  FileMode := 0;  {Set file access to read only }
  Reset(yyinput);
  AssignFile(yyoutput, xmlFN);
  FileMode := fmOpenRead or fmShareDenyWrite;
  Rewrite(yyoutput);
//  while yyparse = 0 do
  yyparse;
//  xdb := TbjXml.Create;
//  xdb.LoadXml(xmlText);
//  ShowMessage(xdb.GetXml);
//  xdb.SaveXmlFile('xml.txt');
end.

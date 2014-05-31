{ ************************************************************

 SimpleXML - By Michael Vlasov. Library for XML parsing and convertion to
   XML objects hierarchy and vise versa. Worthy replacement for MSXML.
   While using ANSI strings works much faster.

 (c) Copyrights 2002, 2003 Michail Vlasov.
   This Library is free and can be used for any needs. The introduction of
   any changes and the use of those changed library is permitted without
   limitations. Only requirement:
   This text must be present without changes in all modifications of library.

   All wishes I greet to misha@integro.ru So I recommend to visit my page: http://mv.rb.ru
   There you will always find the quite last version of library. I desire pleasant programming,
   Michail Vlasov. It must be present without changes in all modifications of library.

   -----------------------------------------------------------------------------------------------

   What's new:
   03-Dec-2009 so - Support for Delphi 2007/2009
                  - Character set conversions included (only some few)
                  - Make library thread safe by removing some global vars
                  - SelectSingleNode and SelectNodes understand XML Pathes
                  - FullPath return XML Path of current Node
                  - License change to Mozilla Public License Version 1.1
   23-Dec-2009 so - CloneNode copy data
   24-Dec-2009 so - Improved performance for parsing
   27-Dec-2009 so - Improved performance for hash and save
   03-Jan-2010 so - Minor bugs in russian error messages fixed

   -----------------------------------------------------------------------------------------------

 (c) Copyrights 2009 Samuel Soldat.

                     Latest releases of SimpleXml.pas are made available through the
                      distribution site at: http://www.audio-data.de/simplexml.html

                        See readme.txt for an introduction and documentation.

              *********************************************************************
              * The contents of this file are used with permission, subject to    *
              * the Mozilla Public License Version 1.1 (the "License"); you may   *
              * not use this file except in compliance with the License. You may  *
              * obtain a copy of the License at                                   *
              * http:  www.mozilla.org/MPL/MPL-1.1.html                           *
              *                                                                   *
              * Software distributed under the License is distributed on an       *
              * "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or    *
              * implied. See the License for the specific language governing      *
              * rights and limitations under the License.                         *
              *                                                                   *
              *  Contributor(s)                                                   *
              *  (mv)  Michail Vlasov    <misha@integro.ru>                       *
              *  (so)  Samuel Soldat     <samuel.soldat@audio-data.de>            *
              *                                                                   *
              *********************************************************************

   -----------------------------------------------------------------------------------------------

 (c) Copyrights 2013 Sridharan S.

              *********************************************************************
              * The contents of this file are used with permission, subject to    *
              * the Mozilla Public License Version 1.1 (the "License"); you may   *
              * not use this file except in compliance with the License. You may  *
              * obtain a copy of the License at                                   *
              * http:  www.mozilla.org/MPL/MPL-1.1.html                           *
              *                                                                   *
              * Software distributed under the License is distributed on an       *
              * "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or    *
              * implied. See the License for the specific language governing      *
              * rights and limitations under the License.                         *
              *                                                                   *
              *  Contributor(s)                                                   *
              *  (mv)  Michail Vlasov    <misha@integro.ru>                       *
              *  (so)  Samuel Soldat     <samuel.soldat@audio-data.de>            *
              *        Sridharan S       <aurosridhar@gmail.com>            *
              *                                                                   *
              *********************************************************************
Kept for archival purpose only.
}
unit bjXml;

interface

uses
  Types, Windows, Classes, Dialogs;
{$IF CompilerVersion>=18}{$DEFINE Regions}{$IFEND}
{$IFDEF Regions}{$REGION 'Constantes Declaration'}{$ENDIF}
const
  BinXmlSignatureSize = Length('< binary-xml >');
  BinXmlSignature: AnsiString = '< binary-xml >';

  BINXML_USE_WIDE_CHARS = 1;
  BINXML_COMPRESSED = 2;
  DefaultHashSize = 1009;

  XSTR_NULL = '{{null}}';

  SourceBufferSize=$4000;

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Interfaces'}{$ENDIF}
type
  // TbjXmlString - The type of the string variables, used in SimpleXML.
  //  There can be String or WideString

  {$DEFINE English}

  {$IFNDEF Unicode}
    {.$DEFINE XML_WIDE_CHARS}
    {$IFDEF XML_WIDE_CHARS}
    PbjXmlChar = PWideChar;
    TbjXmlChar = WideChar;
    TbjXmlString = WideString;
    {$ELSE}
    PbjXmlChar = PChar;
    TbjXmlChar = Char;
    TbjXmlString = String;
    {$ENDIF}
  {$ELSE}
  PbjXmlChar = PChar;
  TbjXmlChar = Char;
  TbjXmlString = String;
  {$ENDIF}

  {$IF not Declared(RawByteString)}
  RawByteString=AnsiString;
  {$IFEND}
  {$IF not Declared(TBytes)}
  TBytes = TByteDynArray;
  {$IFEND}
  {$IF (CompilerVersion<20.00)}
  NativeInt = type Integer;     //Override NativeInt because in Delphi2007 SizeOf(NativeInt)<>SizeOf(Pointer)
  {$IFEND}

  TbjXmlNodeType = (NODE_INVALID, NODE_ELEMENT, NODE_TEXT, NODE_CDATA_SECTION,
                  NODE_PROCESSING_INSTRUCTION, NODE_COMMENT, NODE_DOCUMENT);

  IbjXml = interface;
  IbjXmlElement = interface;
  IbjXmlText = interface;
  IbjXmlCDATASection = interface;
  IbjXmlComment = interface;
  IbjXmlProcessingInstruction = interface;

  IbjXmlBase = interface
    function GetObject: TObject;
  end;

  IbjXmlNameTable = interface(IbjXmlBase)
    function GetID(const aName: TbjXmlString): NativeInt;
    function GetName(anID: NativeInt): TbjXmlString;
  end;

  // IbjXmlNodeList - список узлов. Список организован в виде массива.
  // Доступ к элементам списка по индексу
  IbjXmlNodeList = interface(IbjXmlBase)
    // Get_Count - количество узлов в списке
    function Get_Count: Integer;
    // Get_Item - получить узел по индексу
    function Get_Item(anIndex: Integer): IbjXml;
     procedure Exchange(Index1, Index2: Integer);
    // Get_XML - возвращает представление элементов списка в формате XML
    function Get_XML: TbjXmlString;

    property Count: Integer read Get_Count;
    property Item[anIndex: Integer]: IbjXml read Get_Item; default;
    property XML: TbjXmlString read Get_XML;
  end;

  TbjXml = class;
  TbjXmlNodeList = class;
  IbjXml = interface(IbjXmlBase)
//  IbjXmlNode = interface(IbjXmlBase)
    function Get_NameTable: IbjXmlNameTable;
    function Get_NodeName: TbjXmlString;
    function GetTag: TbjXmlString;
    function Get_NodeNameID: NativeInt;
    function Get_NodeType: TbjXmlNodeType;
//    function Get_Text: TbjXmlString;
    function GetContent: TbjXmlString;
//    procedure Set_Text(const aValue: TbjXmlString);
    procedure SetContent(const aValue: TbjXmlString);
    function Get_DataType: Integer;
    function Get_TypedValue: Variant;
    procedure Set_TypedValue(const aValue: Variant);
    function Get_XML: TbjXmlString;
    function GetXML: TbjXmlString;

    function CloneNode(aDeep: Boolean = True): IbjXml;

//    function Get_CurrentNode: IbjXml;
//    function Get_ParentNode: IbjXml;
    function GetParent: IbjXml;
    function Get_OwnerDocument: IbjXml;
//    function Get_ChildNodes: IbjXmlNodeList;
    function GetChilds: TbjXmlNodeList;
    function GetChildwithTag(const aName: TbjXmlString): IbjXml;
    procedure AppendChild(const aChild: IbjXml);
    procedure InsertBefore(const aChild, aBefore: IbjXml);
    procedure ReplaceChild(const aNewChild, anOldChild: IbjXml);
    procedure RemoveChild(const aChild: IbjXml);

    // created an element and add it to the end of the list as child node
    function AppendElement(aNameID: NativeInt): IbjXmlElement; overload;
    function AppendElement(const aName: TbjXmlString): IbjXmlElement; overload;
    function NewChild(const aName: TbjXmlString; const aText: TbjXmlString): IbjXml;
    procedure NewChild2(const aName: TbjXmlString; const aText: TbjXmlString);

    function AppendText(const aData: TbjXmlString): IbjXmlText;

    function AppendCDATA(const aData: TbjXmlString): IbjXmlCDATASection;

    function AppendComment(const aData: TbjXmlString): IbjXmlComment;

    function AppendProcessingInstruction(aTargetID: NativeInt;
      const aData: TbjXmlString): IbjXmlProcessingInstruction; overload;
    function AppendProcessingInstruction(const aTarget: TbjXmlString;
      const aData: TbjXmlString): IbjXmlProcessingInstruction; overload;

    function GetChildText(const aName: TbjXmlString; const aDefault: TbjXmlString = ''): TbjXmlString; overload;
    function GetChildText(aNameID: NativeInt; const aDefault: TbjXmlString = ''): TbjXmlString; overload;
    function GetChildContent(const aName: TbjXmlString): TbjXmlString;
    procedure SetChildText(const aName, aValue: TbjXmlString); overload;
    procedure SetChildText(aNameID: NativeInt; const aValue: TbjXmlString); overload;

    function NeedChild(aNameID: NativeInt): IbjXml; overload;
    function NeedChild(const aName: TbjXmlString): IbjXml; overload;

    function EnsureChild(aNameID: NativeInt): IbjXml; overload;
    function EnsureChild(const aName: TbjXmlString): IbjXml; overload;

    procedure RemoveAllChilds;

    function SelectNodes(const anExpression: TbjXmlString): IbjXmlNodeList;
    // SelectSingleNode - Get specified Node. You can indicate a complete path
    function SelectSingleNode(const anExpression: TbjXmlString): IbjXml;
    // FullPath - Return full XML path to the XML Node - can used as anExpression
    function FullPath: TbjXmlString;
    // FindElement - производит поиск первого узла, удовлетворяющего
    //  указанным критериям
    function FindElement(const anElementName, anAttrName: String; const anAttrValue: Variant): IbjXmlElement;

    // Get_AttrCount - возвращает количество атрибутов
    function Get_AttrCount: Integer;
    // Get_AttrNameID - возвращает код названия атрибута
    function Get_AttrNameID(anIndex: Integer): NativeInt;
    // Get_AttrName - возвращает название атрибута
    function Get_AttrName(anIndex: Integer): TbjXmlString;
    // RemoveAttr - удаляет атрибут
    procedure RemoveAttr(const aName: TbjXmlString); overload;
    procedure RemoveAttr(aNameID: NativeInt); overload;
    // RemoveAllAttrs - удаляет все атрибуты
    procedure RemoveAllAttrs;
    Procedure Clear;
    
    // AttrExists - проверяет, задан ли указанный атрибут.
    function AttrExists(aNameID: NativeInt): Boolean; overload;
    function AttrExists(const aName: TbjXmlString): Boolean; overload;

    // GetAttrType -
    function GetAttrType(aNameID: NativeInt): Integer; overload;
    function GetAttrType(const aName: TbjXmlString): Integer; overload;

    // GetAttrType - возвращает тип атрибута
    //  Result
    // GetVarAttr - возвращает типизированное значение указанного атрибута.
    //  Если атрибут не задан, то возвращается значение по умолчанию
    // SetAttr - изменяет или добавляет указанный атрибут
    function GetVarAttr(aNameID: NativeInt; const aDefault: Variant): Variant; overload;
    function GetVarAttr(const aName: TbjXmlString; const aDefault: Variant): Variant; overload;
    procedure SetVarAttr(aNameID: NativeInt; const aValue: Variant); overload;
    procedure SetVarAttr(const aName: TbjXmlString; aValue: Variant); overload;
    function AddAttribute(const aName: TbjXmlString; const aText: TbjXmlString): integer;

    // NeedAttr - возвращает строковое значение указанного атрибута.
    //  Если атрибут не задан, то генерируется исключение
    function NeedAttr(aNameID: NativeInt): TbjXmlString; overload;
    function NeedAttr(const aName: TbjXmlString): TbjXmlString; overload;

    // GetAttr - возвращает строковое значение указанного атрибута.
    //  Если атрибут не задан, то возвращается значение по умолчанию
    // SetAttr - изменяет или добавляет указанный атрибут
    function GetAttr(aNameID: NativeInt; const aDefault: TbjXmlString = ''): TbjXmlString; overload;
    function GetAttr(const aName: TbjXmlString; const aDefault: TbjXmlString = ''): TbjXmlString; overload;
    function GetAttrValue(const aName: TbjXmlString): TbjXmlString;
    procedure SetAttr(aNameID: NativeInt; const aValue: TbjXmlString); overload;
    procedure SetAttr(const aName, aValue: TbjXmlString); overload;

    // GetBoolAttr - возвращает целочисленное значение указанного атрибута
    // SetBoolAttr - изменяет или добавляет указанный атрибут целочисленным
    //  значением
    function GetBoolAttr(aNameID: NativeInt; aDefault: Boolean = False): Boolean; overload;
    function GetBoolAttr(const aName: TbjXmlString; aDefault: Boolean = False): Boolean; overload;
    procedure SetBoolAttr(aNameID: NativeInt; aValue: Boolean = False); overload;
    procedure SetBoolAttr(const aName: TbjXmlString; aValue: Boolean); overload;

    // GetIntAttr - возвращает целочисленное значение указанного атрибута
    // SetIntAttr - изменяет или добавляет указанный атрибут целочисленным
    //  значением
    function GetIntAttr(aNameID: NativeInt; aDefault: Integer = 0): Integer; overload;
    function GetIntAttr(const aName: TbjXmlString; aDefault: Integer = 0): Integer; overload;
    procedure SetIntAttr(aNameID: NativeInt; aValue: Integer); overload;
    procedure SetIntAttr(const aName: TbjXmlString; aValue: Integer); overload;

    // GetDateTimeAttr - возвращает целочисленное значение указанного атрибута
    // SetDateTimeAttr - изменяет или добавляет указанный атрибут целочисленным
    //  значением
    function GetDateTimeAttr(aNameID: NativeInt; aDefault: TDateTime = 0): TDateTime; overload;
    function GetDateTimeAttr(const aName: TbjXmlString; aDefault: TDateTime = 0): TDateTime; overload;
    procedure SetDateTimeAttr(aNameID: NativeInt; aValue: TDateTime); overload;
    procedure SetDateTimeAttr(const aName: TbjXmlString; aValue: TDateTime); overload;

    // GetFloatAttr - возвращает значение указанного атрибута в виде
    //  вещественного числа
    // SetFloatAttr - изменяет или добавляет указанный атрибут вещественным
    //  значением
    function GetFloatAttr(aNameID: NativeInt; aDefault: Double = 0): Double; overload;
    function GetFloatAttr(const aName: TbjXmlString; aDefault: Double = 0): Double; overload;
    procedure SetFloatAttr(aNameID: NativeInt; aValue: Double); overload;
    procedure SetFloatAttr(const aName: TbjXmlString; aValue: Double); overload;

    // GetHexAttr - получение значения указанного атрибута в целочисленном виде.
    //  Строковое значение атрибута преобразуется в целое число. Исходная
    //  строка должна быть задана в шестнадцатиричном виде без префиксов
    //  ("$", "0x" и пр.) Если преобразование не может быть выполнено,
    //  генерируется исключение.
    //  Если атрибут не задан, возвращается значение параметра aDefault.
    // SetHexAttr - изменение значения указанного атрибута на строковое
    //  представление целого числа в шестнадцатиричном виде без префиксов
    //    ("$", "0x" и пр.) Если преобразование не может быть выполнено,
    //    генерируется исключение.
    //    Если атрибут не был задан, до он будет добавлен.
    //    Если был задан, то будет изменен.
    function GetHexAttr(const aName: TbjXmlString; aDefault: Integer = 0): Integer; overload;
    function GetHexAttr(aNameID: NativeInt; aDefault: Integer = 0): Integer; overload;
    procedure SetHexAttr(const aName: TbjXmlString; aValue: Integer; aDigits: Integer = 8); overload;
    procedure SetHexAttr(aNameID: NativeInt; aValue: Integer; aDigits: Integer = 8); overload;

    //  GetEnumAttr - ищет значение атрибута в указанном списке строк и
    //    возвращает индекс  найденной строки. Если атрибут задан но не найден
    //    в списке, то генерируется исключение.
    //    Если атрибут не задан, возвращается значение параметра aDefault.
    function GetEnumAttr(const aName: TbjXmlString;
      const aValues: array of TbjXmlString; aDefault: Integer = 0): Integer; overload;
    function GetEnumAttr(aNameID: NativeInt;
      const aValues: array of TbjXmlString; aDefault: Integer = 0): Integer; overload;

    function NeedEnumAttr(const aName: TbjXmlString;
      const aValues: array of TbjXmlString): Integer; overload;
    function NeedEnumAttr(aNameID: NativeInt;
      const aValues: array of TbjXmlString): Integer; overload;

    function Get_Values(const aName: String): Variant;
    procedure Set_Values(const aName: String; const aValue: Variant);

    function AsElement: IbjXmlElement;
    function AsText: IbjXmlText;
    function AsCDATASection: IbjXmlCDATASection;
    function AsComment: IbjXmlComment;
    function AsProcessingInstruction: IbjXmlProcessingInstruction;

    function Get_DocumentElement: IbjXmlElement;
    function Get_BinaryXML: RawByteString;
    function Get_PreserveWhiteSpace: Boolean;
    procedure Set_PreserveWhiteSpace(aValue: Boolean);

    function NewDocument(const aVersion, anEncoding: TbjXmlString;
      aRootElementNameID: NativeInt): IbjXmlElement; overload;
    function NewDocument(const aVersion, anEncoding,
      aRootElementName: TbjXmlString): IbjXmlElement; overload;

    function CreateElement(aNameID: NativeInt): IbjXmlElement; overload;
    function CreateElement(const aName: TbjXmlString): IbjXmlElement; overload;
    function CreateText(const aData: TbjXmlString): IbjXmlText;
    function CreateCDATASection(const aData: TbjXmlString): IbjXmlCDATASection;
    function CreateComment(const aData: TbjXmlString): IbjXmlComment;
    function CreateProcessingInstruction(const aTarget,
      aData: TbjXmlString): IbjXmlProcessingInstruction; overload;
    function CreateProcessingInstruction(aTargetID: NativeInt;
      const aData: TbjXmlString): IbjXmlProcessingInstruction; overload;

    procedure LoadXML(const aXML: RawByteString);
    {$IF Defined(XML_WIDE_CHARS) or Defined(Unicode)}
    procedure LoadXML(const aXML: TbjXmlString);
    {$IFEND}
    procedure LoadBinaryXML(const aXML: RawByteString);

    procedure Load(aStream: TStream); overload;
    procedure LoadUTF(aStream: TStream); 
    procedure LoadXMLFile(const aFileName: String);
    procedure LoadUTF16XMLFile(const aFileName: String);

    procedure LoadResource(aType, aName: PChar);

    procedure Save(aStream: TStream); overload;
//    procedure Save(const aFileName: String); overload;
    procedure SaveXmlFile(const aFileName: String);

    procedure SaveBinary(aStream: TStream; anOptions: LongWord = 0); overload;
    procedure SaveBinary(const aFileName: String; anOptions: LongWord = 0); overload;

    function SearchForTag(const fromwhere: IbjXml; const aName: TbjXmlString): IbjXml;
    function GoToTag(const aName: TbjXmlString): IbjXml;
//    function SearchForTag(fromwhere: IbjXml; const NodeName: TbjXmlString): TbjXml;
    function GetNumChildren: integer;
    function GetChild(const index: Integer): IbjXml;
    function GetNextSibling: IbjXml;
    function GetFirstChild: IbjXml;
    function GetLastChild: IbjXml;
    function GetPrevousSibling: IbjXml;

    property PreserveWhiteSpace: Boolean read Get_PreserveWhiteSpace write Set_PreserveWhiteSpace;
    property DocumentElement: IbjXmlElement read Get_DocumentElement;
    property BinaryXML: RawByteString read Get_BinaryXML;
//    property NodeName: TbjXmlString read Get_NodeName;
//    property Tag: TbjXmlString read Get_NodeName;
    property Tag: TbjXmlString read GetTag;
    property NodeNameID: NativeInt read Get_NodeNameID;
    property NodeType: TbjXmlNodeType read Get_NodeType;
//    property CurrentNode: IbjXml read Get_CurrentNode;
//    property ParentNode: IbjXml read Get_ParentNode;
    property Parent: IbjXml read GetParent;
    property OwnerDocument: IbjXml read Get_OwnerDocument;
    property NameTable: IbjXmlNameTable read Get_NameTable;
    property AttrCount: Integer read Get_AttrCount;
    property AttrNames[anIndex: Integer]: TbjXmlString read Get_AttrName;
    property AttrNameIDs[anIndex: Integer]: NativeInt read Get_AttrNameID;
//    property Text: TbjXmlString read Get_Text write Set_Text;
    property Content: TbjXmlString read GetContent write SetContent;
    property DataType: Integer read Get_DataType;
    property TypedValue: Variant read Get_TypedValue write Set_TypedValue;
    property XML: TbjXmlString read Get_XML;
    property Values[const aName: String]: Variant read Get_Values write Set_Values; default;
    property NumChildren: integer read GetNumChildren;
  end;

  IbjXmlElement = interface(IbjXml)
    //  ReplaceTextByCDATASection - удаляет все текстовые элементы и добавляет
    //    одну секцию CDATA, содержащую указанный текст
    procedure ReplaceTextByCDATASection(const aText: TbjXmlString);

    //  ReplaceTextByBinaryData - удаляет все текстовые элементы и добавляет
    //    один текстовый элемент, содержащий указанные двоичные данные
    //    в формате "base64".
    //    Если параметр aMaxLineLength не равен нулю, то производится разбивка
    //    полученой строки на строки длиной aMaxLineLength.
    //    Строки разделяются парой символов #13#10 (CR,LF).
    //    После последней строки указанные символы не вставляются.
    procedure ReplaceTextByBinaryData(const aData; aSize: Integer;
                                      aMaxLineLength: Integer);

    //  GetTextAsBinaryData - cобирает все текстовые элементы в одну строку и
    //    производит преобразование из формата "base64" в двоичные данные.
    //    При преобразовании игнорируются все пробельные символы (с кодом <= ' '),
    //    содержащиеся в исходной строке.
    function GetTextAsBinaryData: TBytes;

  end;

  IbjXmlCharacterData = interface(IbjXml)
  end;

  IbjXmlText = interface(IbjXmlCharacterData)
  end;

  IbjXmlCDATASection = interface(IbjXmlCharacterData)
  end;

  IbjXmlComment = interface(IbjXmlCharacterData)
  end;

  IbjXmlProcessingInstruction = interface(IbjXml)
  end;

  TbjXmlBase = class(TInterfacedObject, IbjXmlBase)
  protected
    // реализация интерфейса IbjXmlBase
    function GetObject: TObject;
  public
  end;

  TBinXmlReader = class
  private
    FOptions: LongWord;
  public
    procedure Read(var aBuf; aSize: Integer); virtual; abstract;

    function ReadLongint: Longint;
    function ReadAnsiString: String;
    function ReadWideString: WideString;
    function ReadXmlString: TbjXmlString;
    procedure ReadVariant(var v: TVarData);
  end;

  TStmXmlReader = class(TBinXmlReader)
  private
    FStream: TStream;
    FBufStart: PAnsiChar;
//    FBufEnd,
    FBufPtr: PAnsiChar;
    FBufSize: Integer;
    FBufRemain: Integer;
    FRemainSize: Integer;
  public
    constructor Create(aStream: TStream; aBufSize: Integer);
    destructor Destroy; override;

    procedure Read(var aBuf; aSize: Integer); override;
  end;

  TStrXmlReader = class(TBinXmlReader)
  private
    FData: RawByteString;
    FPtr: PByte;
    FRemain: Integer;
  public
    constructor Create(const aData: RawByteString);

    procedure Read(var aBuf; aSize: Integer); override;
  end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Writer Declaration'}{$ENDIF}
  TBinXmlWriter = class
  private
    FOptions: LongWord;
  public
    procedure Write(const aBuf; aSize: Integer); virtual; abstract;

    procedure WriteLongint(aValue: Longint);
    procedure WriteAnsiString(const aValue: String);
    procedure WriteWideString(const aValue: WideString);
    procedure WriteXmlString(const aValue: TbjXmlString);
    procedure WriteVariant(const v: TVarData);
  end;

  TStmXmlWriter = class(TBinXmlWriter)
  private
    FStream: TStream;
    FBufStart: PAnsiChar;
    FBufPtr: PAnsiChar;
    FBufSize: Integer;
    FRemain: Integer;
  public
    constructor Create(aStream: TStream; anOptions: LongWord; aBufSize: Integer);
    destructor Destroy; override;

    procedure Write(const aBuf; aSize: Integer); override;
  end;

  TStrXmlWriter = class(TBinXmlWriter)
  private
    FData: RawByteString;
    FBufPtr: PByte;
    FBufSize: Integer;
    FRemain: Integer;
    procedure FlushBuf;
  public
    constructor Create(anOptions: LongWord; aBufSize: Integer);

    procedure Write(const aBuf; aSize: Integer); override;
  end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Base Classes'}{$ENDIF}

  TbjXmlStringDynArray = array of TbjXmlString;

  TbjXmlNameTable = class(TbjXmlBase, IbjXmlNameTable)
  private
    FNames: array of TbjXmlStringDynArray;
    FHashTable: array of TCardinalDynArray;

    FXmlTextNameID: NativeInt;
    FXmlCDATASectionNameID: NativeInt;
    FXmlCommentNameID: NativeInt;
    FXmlDocumentNameID: NativeInt;
    FXmlNameID: NativeInt;
    FEncodingNameId: NativeInt;
    {$IFDEF ADDebug}
    FDebugId: Integer;
    {$ENDIF}
  protected
    function GetKeyID(NameID: NativeInt): Integer;
    function GetNameID(aHashKey: Cardinal): NativeInt;
    function GetID(const aName: TbjXmlString): NativeInt;
    function GetName(anID: NativeInt): TbjXmlString;
  public
    constructor Create(aHashTableSize: Integer);
    {$IFDEF ADDebug}
    destructor Destroy; override;
    {$ENDIF}

    procedure LoadBinXml(aReader: TBinXmlReader);
    procedure SaveBinXml(aWriter: TBinXmlWriter);
  end;

  TbjXmlToken = class
  private
    FValueBuf: TbjXmlString;
    FSize: Integer;
    FLength: Integer;
  public
    constructor Create;
    procedure Clear;
    procedure AppendChar(aChar: TbjXmlChar);
    procedure AppendText(aText: PbjXmlChar; aCount: Integer);
    function Text: TbjXmlString;
    property Length: Integer read FLength;
  end;

  TbjXmlSource = class
  private
    FTokenStack: array of TbjXmlToken;
    FTokenStackTop: Integer;
    FToken: TbjXmlToken;
    FStream: TStream;
    FBuffer: PbjXmlChar;
    FBufPtr: PbjXmlChar;
    FBufSize: Integer;
    FRemainBuff: array [0..3] of AnsiChar;
    FRemainSize: Integer;
    FCodepage: Word;
    FStreamOwner: Boolean;
    function ExpectQuotedText(aQuote: TbjXmlChar): TbjXmlString;
  protected
  public
    CurChar: TbjXmlChar;
    AutoCodepage: Boolean;
    constructor Create(aStream: TStream); overload;
    constructor Create(aString: RawByteString); overload;
    destructor Destroy; override;

    function EOF: Boolean;
    function Next: Boolean;
    procedure SetCodepage(Codepage: Word);

    procedure SkipBlanks;
    function ExpecTbjXmlName: TbjXmlString;
    function ExpecTbjXmlEntity: TbjXmlChar;
    procedure ExpectChar(aChar: TbjXmlChar);
    procedure ExpectText(aText: PbjXmlChar);
    function ExpectDecimalInteger: Integer;
    function ExpectHexInteger: Integer;
    function ParseTo(aText: PbjXmlChar): TbjXmlString;
    procedure ParseAttrs(aNode: TbjXml);

    procedure NewToken;
    procedure AppendTokenChar(aChar: TbjXmlChar);
    procedure AppendTokenText(aText: PbjXmlChar; aCount: Integer);
    function AcceptToken: TbjXmlString;
    procedure DropToken;
  end;

  TbjXmlSaver = class
  private
    FCodepage: Word;
    FBuffer: Pointer;
    FBufferPtr: PAnsiChar;
    FBuffersize: Integer;
    FRemain: Integer;
    procedure SaveToBuffer(XmlStr: PbjXmlChar; L: Integer);
    procedure Save(const XmlStr: TbjXmlString); virtual; abstract;
    procedure FlushBuffer; virtual; abstract;
  public
    constructor Create(aBufSize: Integer);
    destructor Destroy; override;
  end;

  TbjXmlStmSaver = class(TbjXmlSaver)
  private
    FStream: TStream;
    procedure Save(const XmlStr: TbjXmlString); override;
    procedure FlushBuffer; override;
  public
    constructor Create(aStream: TStream; aBufSize: Integer);
  end;

  TbjXmlNodeList = class(TbjXmlBase, IbjXmlNodeList)
  private
    FOwnerNode: TbjXml;

    FItems: array of TbjXml;
    FCount: Integer;
    {$IFDEF ADDebug}
    FDebugId: Integer;
    {$ENDIF}
    procedure Grow;
  protected
    function Get_Count: Integer;
    function Get_Item(anIndex: Integer): IbjXml;
    function Get_XML: TbjXmlString;
  public
    constructor Create(anOwnerNode: TbjXml);
    destructor Destroy; override;

    function IndexOf(aNode: TbjXml): Integer;
    procedure ParseXML(aXML: TbjXmlSource; aNames: TbjXmlNameTable; aPreserveWhiteSpace: Boolean);
    procedure SaveXML(aXML: TbjXmlSaver);

    procedure LoadBinXml(aReader: TBinXmlReader; aCount: Integer; aNames: TbjXmlNameTable);
    procedure SaveBinXml(aWriter: TBinXmlWriter);

    procedure Insert(aNode: TbjXml; anIndex: Integer);
    function Remove(aNode: TbjXml): Integer;
    procedure Delete(anIndex: Integer);
    procedure Replace(anIndex: Integer; aNode: TbjXml);
    procedure Exchange(Index1, Index2: Integer);
    procedure Clear;
  end;


  PXmlAttrData = ^TbjXmlAttrData;
  TbjXmlAttrData = record
    NameID: NativeInt;
    Value: Variant;
  end;

  TbjXml = class(TbjXmlBase, IbjXml)
  private
    FParentNode: TbjXml;
    // FNames -
    FNames: TbjXmlNameTable;
    // FAttrs
    FAttrCount: Integer;
    FAttrs: array of TbjXmlAttrData;
    FChilds: TbjXmlNodeList;
    {$IFDEF ADDebug}
    FDebugId: Integer;
    {$ENDIF}

    FPreserveWhiteSpace: Boolean;
    FisDocument: boolean;

    function FindFirstChild(aNameID: NativeInt): TbjXml;
    function GetAttrsXML: TbjXmlString;
    function FindAttrData(aNameID: NativeInt): PXmlAttrData;
    function GetOwnerDocument: TbjXml;
    function GeTbjXmlIntend: Integer;
    procedure SetNameTable(aValue: TbjXmlNameTable);
    procedure SetNodeNameID(aValue: Integer); virtual;
    function DoCloneNode(aDeep: Boolean): IbjXml; virtual;

//  function DoCloneNode(aDeep: Boolean): IbjXml; override;
//   virtual;
  protected
    // IbjXmlNode
    function Get_NodeName: TbjXmlString;

    function Get_NodeNameID: NativeInt; virtual;
    function Get_NodeType: TbjXmlNodeType;
    function Get_Text: TbjXmlString; virtual;
//    procedure Set_Text(const aValue: TbjXmlString); virtual;
    function CloneNode(aDeep: Boolean): IbjXml;

    procedure LoadBinXml(aReader: TBinXmlReader);
    procedure SaveBinXml(aWriter: TBinXmlWriter);
    procedure SaveXML(aXMLSaver: TbjXmlSaver); virtual;

    function Get_DataType: Integer; virtual;
    function Get_TypedValue: Variant; virtual;
    procedure Set_TypedValue(const aValue: Variant); virtual;

    function Get_XML: TbjXmlString; virtual;
    function GetXML: TbjXmlString;

    function Get_OwnerDocument: IbjXml;
//  function Get_CurrentNode: IbjXml;
    function Get_ParentNode: IbjXml;

//    function Get_ChildNodes: IbjXmlNodeList; virtual;
    procedure AppendChild(const aChild: IbjXml);

    function AppendElement(aNameID: NativeInt): IbjXmlElement; overload;
    function AppendElement(const aName: TbjXmlString): IbjXmlElement; overload;
    function AppendText(const aData: TbjXmlString): IbjXmlText;
    function AppendCDATA(const aData: TbjXmlString): IbjXmlCDATASection;
    function AppendComment(const aData: TbjXmlString): IbjXmlComment;
    function AppendProcessingInstruction(aTargetID: NativeInt;
      const aData: TbjXmlString): IbjXmlProcessingInstruction; overload;
    function AppendProcessingInstruction(const aTarget: TbjXmlString;
      const aData: TbjXmlString): IbjXmlProcessingInstruction; overload;

    procedure InsertBefore(const aChild, aBefore: IbjXml);
    procedure ReplaceChild(const aNewChild, anOldChild: IbjXml);
    procedure RemoveChild(const aChild: IbjXml);
    function GetChildText(const aName: TbjXmlString; const aDefault: TbjXmlString = ''): TbjXmlString; overload;
    function GetChildText(aNameID: NativeInt; const aDefault: TbjXmlString = ''): TbjXmlString; overload;
    function GetChildContent(const aName: TbjXmlString): TbjXmlString;
    procedure SetChildText(const aName, aValue: TbjXmlString); overload;
    procedure SetChildText(aNameID: NativeInt; const aValue: TbjXmlString); overload;

    function NeedChild(aNameID: NativeInt): IbjXml; overload;
    function NeedChild(const aName: TbjXmlString): IbjXml; overload;
    function EnsureChild(aNameID: NativeInt): IbjXml; overload;
    function EnsureChild(const aName: TbjXmlString): IbjXml; overload;

    procedure RemoveAllChilds;

    function SelectNodes(const anExpression: TbjXmlString): IbjXmlNodeList;
    function SelectSingleNode(const anExpression: TbjXmlString): IbjXml;
    function FullPath: TbjXmlString;
    function FindElement(const anElementName, anAttrName: String; const anAttrValue: Variant): IbjXmlElement;

    function Get_AttrCount: Integer;
    function Get_AttrNameID(anIndex: Integer): NativeInt;
    function Get_AttrName(anIndex: Integer): TbjXmlString;
    procedure RemoveAttr(const aName: TbjXmlString); overload;
    procedure RemoveAttr(aNameID: NativeInt); overload;
    procedure RemoveAllAttrs;

    function AttrExists(aNameID: NativeInt): Boolean; overload;
    function AttrExists(const aName: TbjXmlString): Boolean; overload;

    function GetAttrType(aNameID: NativeInt): Integer; overload;
    function GetAttrType(const aName: TbjXmlString): Integer; overload;

    function GetVarAttr(aNameID: NativeInt; const aDefault: Variant): Variant; overload;
    function GetVarAttr(const aName: TbjXmlString; const aDefault: Variant): Variant; overload;
    procedure SetVarAttr(aNameID: NativeInt; const aValue: Variant); overload;
    procedure SetVarAttr(const aName: TbjXmlString; aValue: Variant); overload;

    function NeedAttr(aNameID: NativeInt): TbjXmlString; overload;
    function NeedAttr(const aName: TbjXmlString): TbjXmlString; overload;

    function GetAttr(aNameID: NativeInt; const aDefault: TbjXmlString = ''): TbjXmlString; overload;
    function GetAttr(const aName: TbjXmlString; const aDefault: TbjXmlString = ''): TbjXmlString; overload;
    function GetAttrValue(const aName: TbjXmlString): TbjXmlString;
    procedure SetAttr(aNameID: NativeInt; const aValue: TbjXmlString); overload;
    procedure SetAttr(const aName, aValue: TbjXmlString); overload;

    function GetBoolAttr(aNameID: NativeInt; aDefault: Boolean = False): Boolean; overload;
    function GetBoolAttr(const aName: TbjXmlString; aDefault: Boolean = False): Boolean; overload;
    procedure SetBoolAttr(aNameID: NativeInt; aValue: Boolean = False); overload;
    procedure SetBoolAttr(const aName: TbjXmlString; aValue: Boolean); overload;

    function GetIntAttr(aNameID: NativeInt; aDefault: Integer = 0): Integer; overload;
    function GetIntAttr(const aName: TbjXmlString; aDefault: Integer = 0): Integer; overload;
    procedure SetIntAttr(aNameID: NativeInt; aValue: Integer); overload;
    procedure SetIntAttr(const aName: TbjXmlString; aValue: Integer); overload;

    function GetDateTimeAttr(aNameID: NativeInt; aDefault: TDateTime = 0): TDateTime; overload;
    function GetDateTimeAttr(const aName: TbjXmlString; aDefault: TDateTime = 0): TDateTime; overload;
    procedure SetDateTimeAttr(aNameID: NativeInt; aValue: TDateTime); overload;
    procedure SetDateTimeAttr(const aName: TbjXmlString; aValue: TDateTime); overload;

    function GetFloatAttr(aNameID: NativeInt; aDefault: Double = 0): Double; overload;
    function GetFloatAttr(const aName: TbjXmlString; aDefault: Double = 0): Double; overload;
    procedure SetFloatAttr(aNameID: NativeInt; aValue: Double); overload;
    procedure SetFloatAttr(const aName: TbjXmlString; aValue: Double); overload;

    function GetHexAttr(const aName: TbjXmlString; aDefault: Integer = 0): Integer; overload;
    function GetHexAttr(aNameID: NativeInt; aDefault: Integer = 0): Integer; overload;
    procedure SetHexAttr(const aName: TbjXmlString; aValue: Integer; aDigits: Integer = 8); overload;
    procedure SetHexAttr(aNameID: NativeInt; aValue: Integer; aDigits: Integer = 8); overload;

    function GetEnumAttr(const aName: TbjXmlString;
      const aValues: array of TbjXmlString; aDefault: Integer = 0): Integer; overload;
    function GetEnumAttr(aNameID: NativeInt;
      const aValues: array of TbjXmlString; aDefault: Integer = 0): Integer; overload;
    function NeedEnumAttr(const aName: TbjXmlString;
      const aValues: array of TbjXmlString): Integer; overload;
    function NeedEnumAttr(aNameID: NativeInt;
      const aValues: array of TbjXmlString): Integer; overload;


    function Get_Values(const aName: String): Variant;
    procedure Set_Values(const aName: String; const aValue: Variant);

    function AsElement: IbjXmlElement; virtual;
    function AsText: IbjXmlText; virtual;
    function AsCDATASection: IbjXmlCDATASection; virtual;
    function AsComment: IbjXmlComment; virtual;
    function AsProcessingInstruction: IbjXmlProcessingInstruction; virtual;

//    function Get_NodeNameID: NativeInt; override;
//    function Get_Text: TbjXmlString; override;
    procedure Set_Text(const aText: TbjXmlString);  virtual;
    //    function Get_XML: TbjXmlString; override;
//    procedure SaveXML(aXMLSaver: TbjXmlSaver); override;
    function Get_PreserveWhiteSpace: Boolean;
    procedure Set_PreserveWhiteSpace(aValue: Boolean);

    function NewDocument(const aVersion, anEncoding: TbjXmlString;
      aRootElementNameID: NativeInt): IbjXmlElement; overload;
    function NewDocument(const aVersion, anEncoding,
      aRootElementName: TbjXmlString): IbjXmlElement; overload;

    function CreateElement(aNameID: NativeInt): IbjXmlElement; overload;
    function CreateElement(const aName: TbjXmlString): IbjXmlElement; overload;
    function CreateText(const aData: TbjXmlString): IbjXmlText;
    function CreateCDATASection(const aData: TbjXmlString): IbjXmlCDATASection;
    function CreateComment(const aData: TbjXmlString): IbjXmlComment;
    function Get_DocumentElement: IbjXmlElement;
    function CreateProcessingInstruction(const aTarget,
      aData: TbjXmlString): IbjXmlProcessingInstruction; overload;
    function CreateProcessingInstruction(aTargetID: NativeInt;
      const aData: TbjXmlString): IbjXmlProcessingInstruction; overload;

    procedure Load(aStream: TStream); 
    procedure LoadUTF(aStream: TStream);
    procedure LoadXMLFile(const aFileName: String);
    procedure LoadUTF16XMLFile(const aFileName: String);

    procedure LoadResource(aType, aName: PChar);

    procedure SaveBinary(aStream: TStream; anOptions: LongWord); overload;
    procedure SaveBinary(const aFileName: String; anOptions: LongWord); overload;

    function Get_BinaryXML: RawByteString;
    procedure LoadBinaryXML(const aXML: RawByteString);

//    function SearchForTag(fromwhere: IbjXml; const NodeName: TbjXmlString): TbjXml;
    function Get_Childs: TbjXmlNodeList; virtual;
//    procedure MoveToObject(obj: TObject); virtual;

  public
    constructor CreateNode(aNames: TbjXmlNameTable);
    destructor Destroy; override;
    constructor Create(aNames: TbjXmlNameTable=nil);
    function GetTag: TbjXmlString;
    function GetContent: TbjXmlString;
    procedure SetContent(const aText: TbjXmlString);
    function GetParent: IbjXml;
    function NewChild(const aName: TbjXmlString; const aText: TbjXmlString): IbjXml;
    procedure NewChild2(const aName: TbjXmlString; const aText: TbjXmlString);
    function AddAttribute(const aName: TbjXmlString; const aText: TbjXmlString): integer;
    procedure Clear;
    function GetChildwithTag(const aName: TbjXmlString): IbjXml;
    procedure Save(aStream: TStream); overload;
//    procedure Save(const aFileName: String); overload;
    procedure SaveXmlFile(const aFileName: String);
    function SearchForTag(const fromwhere: IbjXml; const aName: TbjXmlString): IbjXml;
    function GoToTag(const aName: TbjXmlString): IbjXml;
    procedure LoadXML(const aXML: RawByteString); overload;
    {$IF Defined(XML_WIDE_CHARS) or Defined(Unicode)}
    procedure LoadXML(const aXML: TbjXmlString); overload;
    {$IFEND}
    function GetNumChildren: integer;
    function GetChilds: TbjXmlNodeList;
//    function Get_Childs: TbjXmlNodeList; virtual;
    function Get_NameTable: IbjXmlNameTable;
    property isDocument: boolean read FisDocument write FisDocument;
    function GetChild(const index: Integer): IbjXml;
    function GetNextSibling: IbjXml;
    function GetFirstChild: IbjXml;
    function GetLastChild: IbjXml;
    function GetPrevousSibling: IbjXml;
  end;

  TbjXmlElement = class(TbjXml, IbjXmlElement)
  private
    FNameID: NativeInt;
    FData: Variant;
    procedure RemoveTextNodes;
    procedure SetNodeNameID(aValue: Integer); override;
    function DoCloneNode(aDeep: Boolean): IbjXml; override;
  protected
//    function GetChilds: TbjXmlNodeList; override;
    function Get_Childs: TbjXmlNodeList; override;

    function Get_NodeNameID: NativeInt; override;
    function Get_Text: TbjXmlString; override;
    procedure Set_Text(const aValue: TbjXmlString); override;
    function Get_DataType: Integer; override;
    function Get_TypedValue: Variant; override;
    procedure Set_TypedValue(const aValue: Variant); override;
    function Get_XML: TbjXmlString; override;
    function AsElement: IbjXmlElement; override;
//    function Get_ChildNodes: IbjXmlNodeList; override;
    procedure SaveXML(aXMLSaver: TbjXmlSaver); override;

    // IbjXmlElement
    procedure ReplaceTextByCDATASection(const aText: TbjXmlString);
    procedure ReplaceTextByBinaryData(const aData; aSize: Integer;
                                      aMaxLineLength: Integer);
    function GetTextAsBinaryData: TBytes;
  public
    constructor Create(aNames: TbjXmlNameTable; aNameID: NativeInt);
  end;

  TbjXmlCharacterData = class(TbjXml, IbjXmlCharacterData)
  private
    FData: TbjXmlString;
  protected
    function Get_Text: TbjXmlString; override;
    procedure Set_Text(const aValue: TbjXmlString); override;
  public
    constructor Create(aNames: TbjXmlNameTable; const aData: TbjXmlString);
  end;

  TbjXmlText = class(TbjXml, IbjXmlText)
  private
    FData: Variant;
    function DoCloneNode(aDeep: Boolean): IbjXml; override;
  protected
    function Get_NodeNameID: NativeInt; override;
    function Get_Text: TbjXmlString; override;
    procedure Set_Text(const aValue: TbjXmlString); override;
    function Get_DataType: Integer; override;
    function Get_TypedValue: Variant; override;
    procedure Set_TypedValue(const aValue: Variant); override;
    function Get_XML: TbjXmlString; override;
    procedure SaveXML(aXMLSaver: TbjXmlSaver); override;
    function AsText: IbjXmlText; override;
  public
    constructor Create(aNames: TbjXmlNameTable; const aData: Variant);
  end;

  TbjXmlCDATASection = class(TbjXmlCharacterData, IbjXmlCDATASection)
  protected
    function Get_NodeNameID: NativeInt; override;
    function Get_XML: TbjXmlString; override;
    procedure SaveXML(aXMLSaver: TbjXmlSaver); override;
    function AsCDATASection: IbjXmlCDATASection; override;
    function DoCloneNode(aDeep: Boolean): IbjXml; override;
  public
  end;

  TbjXmlComment = class(TbjXmlCharacterData, IbjXmlComment)
  protected
    function Get_NodeNameID: NativeInt; override;
    function Get_XML: TbjXmlString; override;
    procedure SaveXML(aXMLSaver: TbjXmlSaver); override;
    function AsComment: IbjXmlComment; override;
    function DoCloneNode(aDeep: Boolean): IbjXml; override;
  public
  end;

  TbjXmlProcessingInstruction = class(TbjXml, IbjXmlProcessingInstruction)
  private
    FTargetNameID: NativeInt;
    FData: TbjXmlString;
    procedure SetNodeNameID(aValue: Integer); override;
    function DoCloneNode(aDeep: Boolean): IbjXml; override;
  protected
    function Get_NodeNameID: NativeInt; override;
    function Get_Text: TbjXmlString; override;
    procedure Set_Text(const aText: TbjXmlString); override;
    function Get_XML: TbjXmlString; override;
    procedure SaveXML(aXMLSaver: TbjXmlSaver); override;
    function AsProcessingInstruction: IbjXmlProcessingInstruction; override;

  public
    constructor Create(aNames: TbjXmlNameTable; aTargetID: NativeInt;
      const aData: TbjXmlString);
  end;

const
  NodeClasses: array [TbjXmlNodeType] of TClass=
    (TObject, TbjXmlElement, TbjXmlText, TbjXmlCDATASection,
     TbjXmlProcessingInstruction, TbjXmlComment, TbjXml);

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Document Creation Functions'}{$ENDIF}
function CreateNameTable(aHashTableSize: Integer = DefaultHashSize): IbjXmlNameTable;
function CreateXmlDocument(const aRootElementName: String = '';
                           const aVersion: String = '';    // '1.0'
                           const anEncoding: String = '';  // 'UTF-8'
                           const aNameTable: IbjXmlNameTable = nil): IbjXml;

function CreateXmlElement(const aName: TbjXmlString; const aNameTable: IbjXmlNameTable = nil): IbjXmlElement;
function LoadXmlDocumentFromXML(const aXML: RawByteString): IbjXml;
function LoadXmlDocumentFromBinaryXML(const aXML: RawByteString): IbjXml;

function LoadXmlDocument(aStream: TStream): IbjXml; overload;
function LoadXmlDocument(const aFileName: String): IbjXml; overload;
function LoadXmlDocument(aResType, aResName: PChar): IbjXml; overload;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Globle Variables'}{$ENDIF}
var
  DefaultPreserveWhiteSpace: Boolean = False;
//  DefaultIndentText: TbjXmlString = #9;
  DefaultIndentText: TbjXmlString = '    ';
  XMLPathDelimiter: TbjXmlString = '\';

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Helper Functions'}{$ENDIF}
function XSTRToFloat(const s: TbjXmlString): Double;
function FloatToXSTR(v: Double): TbjXmlString;
function DateTimeToXSTR(v: TDateTime): TbjXmlString;
function VarToXSTR(const v: TVarData): TbjXmlString;

function TextToXML(const aText: TbjXmlString): TbjXmlString;
function BinToBase64(const aBin; aSize: Integer; aMaxLineLength: Integer=80): TbjXmlString;
function Base64ToBin(const aBase64: TbjXmlString): TBytes;
function IsXmlDataString(const aData: RawByteString): Boolean;
function XmlIsInBinaryFormat(const aData: RawByteString): Boolean;
procedure PrepareToSaveXml(var anElem: IbjXmlElement; const aChildName: String);
function PrepareToLoadXml(var anElem: IbjXmlElement; const aChildName: String): Boolean;
function RSearchForTag(aNode: IbjXml; const fromwhere: IbjXml;
                       const aName: TbjXmlString; var found: boolean): IbjXml;
function RGoToTag(aNode: IbjXml; const aName: TbjXmlString): IbjXml;
function RHopNode(aNode: IbjXml; const aName: TbjXmlString): IbjXml;
//function RSearchForTag2(var aNode: IbjXml; const fromwhere: IbjXml;
//                       const aName: TbjXmlString; var found: boolean): IbjXml;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}

implementation

uses
  SysConst, SysUtils, Variants, DateUtils;

{$IFDEF Regions}{$REGION 'Error Messages'}{$ENDIF}
resourcestring
  {$IFDEF English}
  SSimpleXmlError1 = 'Error obtaining the element the list: Index out of range';
  SSimpleXmlError2 = 'The determination of the element is not completed';
  SSimpleXmlError3 = 'Invalid symbol in the name of the element';
  SSimpleXmlError4 = 'Error of reading binary XML: incorrect node-type';
  SSimpleXmlError5 = 'Error of the record of binary XML: incorrect node-type';
  SSimpleXmlError6 = 'Incorrect value of the attribute "%0:s" at element "%1:s".'#13#10 +
                     'Allowed values are: '#13#10 + '%2:s';
  SSimpleXmlError7 = 'Attribute "%s" not found';
  SSimpleXmlError8 = 'Attribute "%s" not assigned';
  SSimpleXmlError9 = 'This feature is not supported by SimpleXML';
  SSimpleXmlError10 = 'Error: Child node "%s" not found';
  SSimpleXmlError11 = 'Name must start with letter or " _"';
  SSimpleXmlError12 = 'Number expected';
  SSimpleXmlError13 = 'Hexadecimal number expected';
  SSimpleXmlError14 = '"#" or XML entity symbol name expected';
  SSimpleXmlError15 = 'Unknown XML entity symbol name "%s" found';
  SSimpleXmlError16 = 'Character "%s" expected';
  SSimpleXmlError17 = 'Text "%s" expected';
  SSimpleXmlError18 = 'Character "<" cannot be used in the values of attributes';
  SSimpleXmlError19 = '"%s" expected';
  SSimpleXmlError20 = 'The value of the attribute is expected';
  SSimpleXmlError21 = 'Line constant expected';
  SSimpleXmlError22 = '"%s" expected';
  SSimpleXmlError23 = 'Error reading data';
  SSimpleXmlError24 = 'Error reading value: incorrect type';
  SSimpleXmlError25 = 'Unknown data type in variant';
  SSimpleXmlError26 = 'Encoding "%s" is not supported by SimpleXML';
  {$ELSE}
  {$IF CompilerVersion>=18}
  SSimpleXmlError1 = 'Ошибка получения элемента списка: индекс выходит за пределы';
  SSimpleXmlError2 = 'Не завершено определение элемента';
  SSimpleXmlError3 = 'Некорретный символ в имени элемента';
  SSimpleXmlError4 = 'Ошибка чтения двоичного XML: некорректный тип узла';
  SSimpleXmlError5 = 'Ошибка записи двоичного XML: некорректный тип узла';
  SSimpleXmlError6 = 'Неверное значение атрибута "%0:s" элемента "%1:s".'#13#10 +
                     'Допустимые значения:'#13#10 + '%2:s';
  SSimpleXmlError7 = 'Не найден атрибут "%s"';
  SSimpleXmlError8 = 'Не задан атрибут "%s"';
  SSimpleXmlError9 = 'Данная возможность не поддерживается SimpleXML';
  SSimpleXmlError10 = 'Ошибка: не найден дочерний элемент "%s".';
  SSimpleXmlError11 = 'Имя должно начинаться с буквы или "_"';
  SSimpleXmlError12 = 'Ожидается число';
  SSimpleXmlError13 = 'Ожидается шестнадцатеричное число';
  SSimpleXmlError14 = 'Ожидается "#" или имя упрамляющего символа';
  SSimpleXmlError15 = 'Некорректное имя управляющего символа "%s"';
  SSimpleXmlError16 = 'Ожидается "%s"';
  SSimpleXmlError17 = 'Ожидается "%s"';
  SSimpleXmlError18 = 'Символ "<" не может использоваться в значениях атрибутов';
  SSimpleXmlError19 = 'Ожидается "%s"';
  SSimpleXmlError20 = 'Ожидается значение атрибута';
  SSimpleXmlError21 = 'Ожидается строковая константа';
  SSimpleXmlError22 = 'Ожидается "%s"';
  SSimpleXmlError23 = 'Ошибка чтения данных.';
  SSimpleXmlError24 = 'Ошибка чтения значения: некорректный тип.';
  SSimpleXmlError25 = 'Ошибка записи значения: некорректный тип.';
  SSimpleXmlError26 = 'Данная Зашифрование "%s" не поддерживается SimpleXML';
  {$ELSE}
  {$INCLUDE *_Cyrillic.inc}
  {$IFEND}
  {$ENDIF}
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Codepage Support'}{$ENDIF}
const
  XMLEncodingData: Array [0..19] of 
      record
        Encoding: TbjXmlString;
        CodePage: Word;
      end = ((Encoding: 'UTF-8';        CodePage: CP_UTF8),
             (Encoding: 'WINDOWS-1250'; CodePage:  1250),
             (Encoding: 'WINDOWS-1251'; CodePage:  1251),
             (Encoding: 'WINDOWS-1252'; CodePage:  1252),
             (Encoding: 'WINDOWS-1253'; CodePage:  1253),
             (Encoding: 'WINDOWS-1254'; CodePage:  1254),
             (Encoding: 'WINDOWS-1255'; CodePage:  1255),
             (Encoding: 'WINDOWS-1256'; CodePage:  1256),
             (Encoding: 'WINDOWS-1257'; CodePage:  1257),
             (Encoding: 'WINDOWS-1258'; CodePage:  1258),
             (Encoding: 'ISO-8859-1';   CodePage: 28591),
             (Encoding: 'ISO-8859-2';   CodePage: 28592),
             (Encoding: 'ISO-8859-3';   CodePage: 28593),
             (Encoding: 'ISO-8859-4';   CodePage: 28594),
             (Encoding: 'ISO-8859-5';   CodePage: 28595),
             (Encoding: 'ISO-8859-6';   CodePage: 28596),
             (Encoding: 'ISO-8859-7';   CodePage: 28597),
             (Encoding: 'ISO-8859-8';   CodePage: 28598),
             (Encoding: 'ISO-8859-9';   CodePage: 28599),
             (Encoding: 'ISO-2022-JP';  CodePage: 50220));
  
function FindCodepage(const s: TbjXmlString): Word;
var 
  i: Integer;
begin
  Result := 0;
  for i := 0 to High(XMLEncodingData) do
  begin
    if SameText(s, XMLEncodingData[i].Encoding)
    then begin
      Result := XMLEncodingData[i].CodePage;
      break;
    end;
  end;
end;

function Utf8ToUnicode(Dest: PWideChar; MaxDestChars: Integer; Source: PByte; var SourceBytes: Integer): Integer;
//After call SourceBytes is the number of bytes not transfered to dest
begin
  Result := 0;
  if (Source <> nil) and (Dest <> nil)
  then begin
    while (SourceBytes>0) and (Result < MaxDestChars) do
    begin
      if (Source^ and $80=0)
      then begin //1 Byte Source
        Dest^ := WideChar(Source^);
      end
      else
      if (Source^ and $E0=$C0)
      then begin //2 Byte Source
        if (SourceBytes>=2)
        then begin
          Dest^ := WideChar((Word(Source^) and $1F) shl 6); inc(Source);
          Dest^ := WideChar(Word(Dest^) or Word(Source^) and $3F);
          dec(SourceBytes);
        end
        else
          break;
      end
      else
      if (Source^ and $F0=$E0) and (SourceBytes>2)
      then begin //3 Byte Source
        if (SourceBytes>=3)
        then begin
          Dest^ := WideChar((Word(Source^) and $F) shl 12); inc(Source);
          Dest^ := WideChar(Word(Dest^) or (Word(Source^) and $3F) shl 6); inc(Source);
          Dest^ := WideChar(Word(Dest^) or (Word(Source^) and $3F));
          dec(SourceBytes, 2);
        end;
      end;
      inc(Source);
      dec(SourceBytes);
      inc(Dest);
      Inc(Result);
    end;
  end;
end;

{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Helper functions'}{$ENDIF}
function TextToXML(const aText: TbjXmlString): TbjXmlString;
const
  cLowerThan: TbjXmlString='&lt;';
  cGreaterThan: TbjXmlString='&gt;';
  cAmpersand: TbjXmlString='&amp;';
  cQuote: TbjXmlString='&quot;';
var
  i, j: Integer;
begin
  j := 0;
  for i := 1 to Length(aText) do
    case aText[i] of
      '<', '>': Inc(j, 4);
      '&': Inc(j, 5);
      '"': Inc(j, 6);
      else
        Inc(j);
    end;
  if j = Length(aText) then
    Result := aText
  else begin
    SetLength(Result, j);
    j := 1;
    for i := 1 to Length(aText) do
      case aText[i] of
        '<': begin Move(PbjXmlChar(cLowerThan)^, Result[j], 4*SizeOf(TbjXmlChar)); Inc(j, 4) end;
        '>': begin Move(PbjXmlChar(cGreaterThan)^, Result[j], 4*SizeOf(TbjXmlChar)); Inc(j, 4) end;
        '&': begin Move(PbjXmlChar(cAmpersand)^, Result[j], 5*SizeOf(TbjXmlChar)); Inc(j, 5) end;
        '"': begin Move(PbjXmlChar(cQuote)^, Result[j], 6*SizeOf(TbjXmlChar)); Inc(j, 6) end;
        else begin Result[j] := aText[i]; Inc(j) end;
      end;
  end;
end;

function XSTRToFloat(const s: TbjXmlString): Double;
var
  code: Integer;
begin
  Val(s,  result, code);
  if (code>0) and (code<=2)
  then begin
    code := 0;
    if SameText(s, 'INF') or SameText(s, '+INF')
    then
      result :=  (1.0 / 0.0)
    else
    if SameText(s, '-INF')
    then
      result :=  (-1.0 / 0.0)
    else
    if SameText(s, 'NAN')
    then
      result :=  (0.0 / 0.0)
    else
      code := 1;
  end;
  if (code>0)
  then
    raise Exception.CreateFmt(SInvalidFloat, [s]);
end;

function FloatToXSTR(v: Double): TbjXmlString;
var
  i: Integer;
begin
  Str(v, Result);
  i := 1;
  while (Result[i]<=' ') do //Str(NaN, Result) => Result = '                    Nan'
    inc(i);
  if Result[i]<>'+' then dec(i);
  if i>0
  then
    Delete(Result, 1, i);
end;

function XSTRToDateTime(const s: String): TDateTime;
var
  aPos: Integer;

  function FetchTo(aStop: Char): Integer;
  var
    i: Integer;
  begin
    i := aPos;
    while (i <= Length(s)) and (s[i]>='0') and (s[i]<='9') do
      Inc(i);
    if i > aPos then
      Result := StrToInt(Copy(s, aPos, i - aPos))
    else
      Result := 0;
    if (i <= Length(s)) and (s[i] = aStop) then
      aPos := i + 1
    else
      aPos := Length(s) + 1;
  end;

var
  y, m, d, h, n, ss: Integer;
begin
  aPos := 1;
  y := FetchTo('-'); m := FetchTo('-'); d := FetchTo('T');
  h := FetchTo('-'); n := FetchTo('-'); ss := FetchTo('-');
  Result := EncodeDateTime(y, m, d, h, n, ss, 0);
end;

function DateTimeToXSTR(v: TDateTime): TbjXmlString;
var
  y, m, d, h, n, s, ms: Word;
begin
  DecodeDateTime(v, y, m, d, h, n, s, ms);
  Result := Format('%.4d-%.2d-%.2dT%.2d-%.2d-%.2d', [y, m, d, h, n, s])
end;

function VarToXSTR(const v: TVarData): TbjXmlString;
const
  BoolStr: array[Boolean] of TbjXmlString = ('0', '1');
var
  p: Pointer;
begin
  case v.VType of
    varNull: Result := XSTR_NULL;
    varSmallint: Result := IntToStr(v.VSmallInt);
    varInteger: Result := IntToStr(v.VInteger);
    varSingle: Result := FloatToXSTR(v.VSingle);
    varDouble: Result := FloatToXSTR(v.VDouble);
    varCurrency: Result := FloatToXSTR(v.VCurrency);
    varDate: Result := DateTimeToXSTR(v.VDate);
    varOleStr: Result := v.VOleStr;
    varBoolean: Result := BoolStr[v.VBoolean = True];
    varShortInt: Result := IntToStr(v.VShortInt);
    varByte: Result := IntToStr(v.VByte);
    varWord: Result := IntToStr(v.VWord);
    varLongWord: Result := IntToStr(v.VLongWord);
    varInt64: Result := IntToStr(v.VInt64);
    varString: Result := TbjXmlString(AnsiString(v.VString));
    {$IFDEF Unicode}
    varUString: Result := String(v.VUString);
    {$ENDIF}
    varArray + varByte:
      begin
        p := VarArrayLock(Variant(v));
        try
          Result := BinToBase64(p^, VarArrayHighBound(Variant(v), 1) - VarArrayLowBound(Variant(v), 1) + 1, 0);
        finally
          VarArrayUnlock(Variant(v))
        end
      end;
    else
      Result := Variant(v)
  end;
end;

procedure PrepareToSaveXml(var anElem: IbjXmlElement; const aChildName: String);
begin
  if aChildName <> '' then
    anElem := anElem.AppendElement(aChildName);
end;

function PrepareToLoadXml(var anElem: IbjXmlElement; const aChildName: String): Boolean;
begin
  if (aChildName <> '') and Assigned(anElem) then
    anElem := anElem.selectSingleNode(aChildName).AsElement;
  Result := Assigned(anElem);
end;

function LoadXMLResource(aModule: HMODULE; aName, aType: PChar; const aXMLDoc: IbjXml): boolean;
var
  aRSRC: HRSRC;
  aGlobal: HGLOBAL;
  aSize: DWORD;
  aPointer: Pointer;
  AStr: RawByteString;
begin
  Result := false;

  aRSRC := FindResource(aModule, aName, aType);
  if aRSRC <> 0 then begin
    aGlobal := LoadResource(aModule, aRSRC);
    aSize := SizeofResource(aModule, aRSRC);
    if (aGlobal <> 0) and (aSize <> 0) then begin
      aPointer := LockResource(aGlobal);
      if Assigned(aPointer) then begin
        SetLength(AStr, aSize);
        move(aPointer^, Pointer(AStr), aSize);
//        aXMLDoc.LoadXMLRB(AStr);
        aXMLDoc.LoadXML(AStr);
        Result := true;
      end;
    end;
  end;
end;

function IsXmlDataString(const aData: RawByteString): Boolean;
var
  i: Integer;
begin
  Result := Copy(aData, 1, BinXmlSignatureSize) = BinXmlSignature;
  if not Result then begin
    i := 1;
    while (i <= Length(aData)) and (aData[i] in [#10, #13, #9, ' ']) do
      Inc(i);
    Result := Copy(aData, i, Length('<?xml ')) = '<?xml ';
  end;
end;

function XmlIsInBinaryFormat(const aData: RawByteString): Boolean;
begin
  if Length(AData)>BinXmlSignatureSize
  then
    Result := CompareMem(Pointer(aData), Pointer(BinXmlSignature), BinXmlSignatureSize)
  else
    Result := False;
end;

type
  PChars = ^TChars;
  TChars = packed record a, b, c, d: TbjXmlChar end;
  POctet = ^TOctet;
  TOctet = packed record a, b, c: Byte; end;

const
  Base64Map: array [0..63] of AnsiChar = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

{$IFDEF ADDebug}
var
  DebugId: Integer;
{$ENDIF}

procedure OctetToChars(po: POctet; aCount: Integer; pc: PChars);
var
  o: Integer;
begin
  if aCount = 1 then begin
    o := po.a shl 16;
    pc^.a := TbjXmlChar(Base64Map[(o shr 18) and $3F]);
    pc^.b := TbjXmlChar(Base64Map[(o shr 12) and $3F]);
    pc^.c := '=';
    pc^.d := '=';
  end
  else if aCount = 2 then begin
    o := po.a shl 16 or po.b shl 8;
    pc^.a := TbjXmlChar(Base64Map[(o shr 18) and $3F]);
    pc^.b := TbjXmlChar(Base64Map[(o shr 12) and $3F]);
    pc^.c := TbjXmlChar(Base64Map[(o shr 6) and $3F]);
    pc^.d := '=';
  end
  else if aCount > 2 then begin
    o := po.a shl 16 or po.b shl 8 or po.c;
    pc^.a := TbjXmlChar(Base64Map[(o shr 18) and $3F]);
    pc^.b := TbjXmlChar(Base64Map[(o shr 12) and $3F]);
    pc^.c := TbjXmlChar(Base64Map[(o shr 6) and $3F]);
    pc^.d := TbjXmlChar(Base64Map[o and $3F]);
  end;
end;

function BinToBase64(const aBin; aSize, aMaxLineLength: Integer): TbjXmlString;
var
  o: POctet;
  c: PChars;
  aCount: Integer;
  i: Integer;
begin
  o := @aBin;
  aCount := aSize;
  SetLength(Result, ((aCount + 2) div 3)*4);
  c := PChars(Result);
  while aCount > 0 do begin
    OctetToChars(o, aCount, c);
    Inc(o);
    Inc(c);
    Dec(aCount, 3);
  end;
  if aMaxLineLength > 0 then begin
    i := aMaxLineLength;
    while i <= Length(Result) do begin
      Insert(#13#10, Result, i);
      Inc(i, 2 + aMaxLineLength);
    end
  end;
end;

function CharTo6Bit(c: TbjXmlChar): Byte;
begin
  if (c >= 'A') and (c <= 'Z') then
    Result := Ord(c) - Ord('A')
  else if (c >= 'a') and (c <= 'z') then
    Result := Ord(c) - Ord('a') + 26
  else if (c >= '0') and (c <= '9') then
    Result := Ord(c) - Ord('0') + 52
  else if c = '+' then
    Result := 62
  else if c = '/' then
    Result := 63
  else
    Result := 0
end;

procedure CharsToOctet(c: PChars; o: POctet);
var
  i: Integer;
begin
  if c.c = '=' then begin // 1 byte
    i := CharTo6Bit(c.a) shl 18 or CharTo6Bit(c.b) shl 12;
    o.a := (i shr 16) and $FF;
  end
  else if c.d = '=' then begin // 2 bytes
    i := CharTo6Bit(c.a) shl 18 or CharTo6Bit(c.b) shl 12 or CharTo6Bit(c.c) shl 6;
    o.a := (i shr 16) and $FF;
    o.b := (i shr 8) and $FF;
  end
  else begin // 3 bytes
    i := CharTo6Bit(c.a) shl 18 or CharTo6Bit(c.b) shl 12 or CharTo6Bit(c.c) shl 6 or CharTo6Bit(c.d);
    o.a := (i shr 16) and $FF;
    o.b := (i shr 8) and $FF;
    o.c := i and $FF;
  end;
end;

function Base64ToBin(const aBase64: TbjXmlString): TBytes;
var
  o: POctet;
  c: PChars;
  aCount: Integer;
  TempBase64: TbjXmlString;
  p1, p2: PbjXmlChar;
  N: Integer;
begin
  SetLength(TempBase64, Length(aBase64));
  N := Length(aBase64);
  p1 := Pointer(aBase64);
  p2 := Pointer(TempBase64);
  while N > 0  do
  begin
    if p1^>' '
    then begin
      p2^ := p1^;
      inc(p2);
    end;
    inc(p1);
    dec(N);
  end;
  N := NativeInt(p2 - Pointer(TempBase64));

  if N < 4 then
    SetLength(Result, 0)
  else begin
    SetLength(TempBase64, N);
    aCount := ((N + 3) div 4)*3;
    if TempBase64[N - 1] = TbjXmlChar('=')
    then
      Dec(aCount, 2)
    else
    if TempBase64[N] = TbjXmlChar('=')
    then
      Dec(aCount);
    SetLength(Result, aCount);
    FillChar(Pointer(Result)^, aCount, '*');
    c := Pointer(TempBase64);
    o := Pointer(Result);
    while aCount > 0 do begin
      CharsToOctet(c, o);
      Inc(o);
      Inc(c);
      Dec(aCount, 3);
    end;
  end;
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Reader Declaration'}{$ENDIF}

{ TbjXmlBase }

function TbjXmlBase.GetObject: TObject;
begin
  Result := Self;
end;

{ TbjXmlNameTable }

constructor TbjXmlNameTable.Create(aHashTableSize: Integer);
begin
  inherited Create;
  {$IFDEF ADDebug}
  FDebugId := InterlockedIncrement(DebugId);
  outputdebugstring(PChar(Format('Create %s (%d)', [Classname, FDebugId])));
  {$ENDIF}
  SetLength(FNames, aHashTableSize);
  SetLength(FHashTable, aHashTableSize);
  FXmlTextNameID := GetID('#text');
  FXmlCDATASectionNameID := GetID('#cdata-section');
  FXmlCommentNameID := GetID('#comment');
  FXmlDocumentNameID := GetID('#document');
  FXmlNameID := GetID('xml');
  FEncodingNameId := GetID('encoding');
end;

procedure TbjXmlNameTable.LoadBinXml(aReader: TBinXmlReader);
var
  aCount: LongInt;
  i: Integer;
begin
  for i := 0 to High(FNames) do
  begin
    SetLength(FNames[i], 0);
    SetLength(FHashTable[i], 0);
  end;
  aCount := aReader.ReadLongint;
  for i := 0 to aCount - 1 do
  begin
    GetID(aReader.ReadXmlString);
  end;
end;

procedure TbjXmlNameTable.SaveBinXml(aWriter: TBinXmlWriter);
var
  aCount: LongInt;
  i, j: Integer;
begin
  aCount := 0;
  for i := 0 to High(FNames) do
  begin
    inc(aCount, Length(FNames[i]));
  end;
  aWriter.WriteLongint(aCount);
  for i := 0 to High(FNames) do
  begin
    for j := 0 to High(FNames[i]) do
    begin
      aWriter.WriteXmlString(FNames[i][j]);
    end;
  end;
end;

function NameHashKey(const aName: TbjXmlString): Cardinal;{$IF CompilerVersion>=18}inline;{$IFEND}
var
  i: Integer;
  p: PbjXmlChar;
begin
  p := Pointer(aName);
  Result := 0;
  for i := 1 to Length(aName) do
  begin
    Inc(Result, Result shl 6 xor Ord(p^));
//    Result := Result shl 5 + Result + Ord(p^);
    inc(p);
  end;
end;

function TbjXmlNameTable.GetKeyID(NameID: NativeInt): Integer;
begin
  Result := NameHashKey(GetName(NameID));
end;

{$IFDEF ADDebug}
destructor TbjXmlNameTable.Destroy;
begin
  outputdebugstring(PChar(Format('Destroy %s (%d)', [Classname, FDebugId])));
  inherited;
end;
{$ENDIF}

function TbjXmlNameTable.GetID(const aName: TbjXmlString): NativeInt;
var
  i, L: Integer;
  aHashKey: Cardinal;
  aHashIndex: Integer;
  aHashKeyList: ^TCardinalDynArray;
  NameList: ^TbjXmlStringDynArray;
begin
  Result := 0;
  if aName <> ''
  then begin
    aHashKey := NameHashKey(aName);
    aHashIndex := aHashKey mod Cardinal(Length(FHashTable));
    NameList := @FNames[aHashIndex];
    aHashKeyList := @FHashTable[aHashIndex];
    L := Length(aHashKeyList^);
    for i := 0 to L-1 do
    begin
      if (aHashKeyList^[i] = aHashKey) and (NameList^[i]=aName)
      then begin
        Result := NativeInt(Pointer(NameList^[i]));
        exit;
      end;
    end;
    SetLength(aHashKeyList^, L+1);
    aHashKeyList^[L] := aHashKey;
    SetLength(NameList^, L+1);
    NameList^[L] := aName;
    Result := NativeInt(Pointer(NameList^[L]));
  end;
end;

function TbjXmlNameTable.GetName(anID: NativeInt): TbjXmlString;
begin
  if anID = 0
  then
    Result := ''
  else
    Result := TbjXmlString(Pointer(anID));
end;

function TbjXmlNameTable.GetNameID(aHashKey: Cardinal): NativeInt;
var
  i: Integer;
  aHashIndex: Integer;
  aHashKeyList: ^TCardinalDynArray;
  NameList: ^TbjXmlStringDynArray;
begin
  Result := 0;
  aHashIndex := aHashKey mod Cardinal(Length(FHashTable));
  NameList := @FNames[aHashIndex];
  aHashKeyList := @FHashTable[aHashIndex];
  for i := 0 to High(aHashKeyList^) do
  begin
    if aHashKeyList^[i] = aHashKey
    then begin
      Result := NativeInt(Pointer(NameList^[i]));
      exit;
    end;
  end;
end;

function CreateNameTable(aHashTableSize: Integer): IbjXmlNameTable;
begin
  Result := TbjXmlNameTable.Create(aHashTableSize)
end;


{ TbjXmlNodeList }

procedure TbjXmlNodeList.Clear;
var
  i: Integer;
  aNode: TbjXml;
begin
  for i := 0 to FCount - 1 do begin
    aNode := FItems[i];
    if Assigned(FOwnerNode) then
      aNode.FParentNode := nil;
    aNode._Release;
  end;
  FCount := 0;
end;

procedure TbjXmlNodeList.Delete(anIndex: Integer);
var
  aNode: TbjXml;
begin
  aNode := FItems[anIndex];
  Dec(FCount);
  if anIndex < FCount then
    Move(FItems[anIndex + 1], FItems[anIndex],
      (FCount - anIndex)*SizeOf(TbjXml));
  if Assigned(aNode) then begin
    if Assigned(FOwnerNode) then
      aNode.FParentNode := nil;
    aNode._Release;
  end;
end;

constructor TbjXmlNodeList.Create(anOwnerNode: TbjXml);
begin
  inherited Create;
  {$IFDEF ADDebug}
  FDebugId := InterlockedIncrement(DebugId);
  outputdebugstring(PChar(Format('Create %s (%d)', [Classname, FDebugId])));
  {$ENDIF}
  FOwnerNode := anOwnerNode;
end;

destructor TbjXmlNodeList.Destroy;
begin
  {$IFDEF ADDebug}
  outputdebugstring(PChar(Format('Destroy %s (%d)', [Classname, FDebugId])));
  {$ENDIF}
  Clear;
  inherited;
end;

procedure TbjXmlNodeList.Exchange(Index1, Index2: Integer);
var
  Temp: TbjXml;
begin
  Temp := FItems[Index1];
  FItems[Index1] := FItems[Index2];
  FItems[Index2] := Temp;
end;

function TbjXmlNodeList.Get_Item(anIndex: Integer): IbjXml;
begin
  if (anIndex < 0) or (anIndex >= FCount) then
    raise Exception.Create(SSimpleXmlError1);
  Result := FItems[anIndex];
end;

function TbjXmlNodeList.Get_Count: Integer;
begin
  Result := FCount
end;

function TbjXmlNodeList.IndexOf(aNode: TbjXml): Integer;
var
  i: Integer;
begin
  for i := 0 to FCount - 1 do
    if FItems[i] = aNode then begin
      Result := i;
      Exit
    end;
  Result := -1;
end;

procedure TbjXmlNodeList.Grow;
var
  aDelta: Integer;
begin
  if Length(FItems) > 64 then
    aDelta := Length(FItems) div 4
  else
    if Length(FItems) > 8 then
      aDelta := 16
    else
      aDelta := 4;
  SetLength(FItems, Length(FItems) + aDelta);
end;

procedure TbjXmlNodeList.Insert(aNode: TbjXml; anIndex: Integer);
var
  aClone: IbjXml;
begin
  if aNode <> nil
  then begin
    if ((aNode.FParentNode<>nil) and (aNode.FParentNode <> FOwnerNode)) or
       ((FOwnerNode<>nil) and (FOwnerNode.FNames<>aNode.FNames))
    then begin
      aClone := aNode.DoCloneNode(True);
      aNode := aClone.GetObject as TbjXml;
      aNode.SetNameTable(FOwnerNode.FNames);
    end
    else
      aNode._AddRef;
    aNode.FParentNode := FOwnerNode;
  end;
  if anIndex = -1 then
    anIndex := FCount;
  if FCount = Length(FItems) then
    Grow;
  if anIndex < FCount then
    Move(FItems[anIndex], FItems[anIndex + 1],
         (FCount - anIndex)*SizeOf(TbjXml));
  FItems[anIndex] := aNode;
  Inc(FCount);
end;

function TbjXmlNodeList.Remove(aNode: TbjXml): Integer;
begin
  Result := IndexOf(aNode);
  if Result <> -1 then
    Delete(Result);
end;

procedure TbjXmlNodeList.Replace(anIndex: Integer; aNode: TbjXml);
var
  anOldNode: TbjXml;
begin
  anOldNode := FItems[anIndex];
  if aNode <> anOldNode
  then begin
    if Assigned(anOldNode)
    then begin
      if Assigned(FOwnerNode)
      then
        anOldNode.FParentNode := nil;
      anOldNode._Release;
    end;
    FItems[anIndex] := aNode;
    if (aNode<>nil)
    then begin
      if ((aNode.FParentNode<>nil) and (aNode.FParentNode <> FOwnerNode)) or
         ((FOwnerNode<>nil) and (FOwnerNode.FNames<>aNode.FNames))
      then begin
        aNode := aNode.DoCloneNode(True).GetObject as TbjXml;
        aNode.FParentNode := FOwnerNode;
        aNode.SetNameTable(FOwnerNode.FNames);
      end
      else
        aNode._AddRef;
    end;
  end;
end;

function TbjXmlNodeList.Get_XML: TbjXmlString;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to FCount - 1 do
    Result := Result + FItems[i].Get_XML;
end;

procedure TbjXmlNodeList.ParseXML(aXML: TbjXmlSource; aNames: TbjXmlNameTable; aPreserveWhiteSpace: Boolean);

  procedure ParseText;
  var
    aText: TbjXmlString;
  begin
    aXml.NewToken;
    while not aXML.EOF and (aXML.CurChar <> '<') do
      if aXML.CurChar = '&' then
        aXml.AppendTokenChar(aXml.ExpecTbjXmlEntity)
      else begin
        aXml.AppendTokenChar(aXML.CurChar);
        aXML.Next;
      end;
    if aPreserveWhiteSpace
    then
      aText := aXml.AcceptToken
    else
      aText := Trim(aXml.AcceptToken);
    if (aText<>'') 
    then
      Insert(TbjXmlText.Create(aNames, aText), -1);
  end;

  // CurChar - '?'
  procedure ParseProcessingInstruction;
  var
    aTarget: TbjXmlString;
    aNode: TbjXmlProcessingInstruction;
    EncodingValue: TbjXmlString;
    NewCodepage: Word;
  begin
    aXML.Next;
    aTarget := aXML.ExpecTbjXmlName;
    aNode := TbjXmlProcessingInstruction.Create(aNames, aNames.GetID(aTarget), '');
    Insert(aNode, -1);
    if aNode.FTargetNameID = aNames.FXmlNameID
    then begin
      aXml.ParseAttrs(aNode);
      aXml.ExpectText('?>');
      if aXML.AutoCodepage
      then begin
        EncodingValue := aNode.GetVarAttr(aNames.FEncodingNameId, '');
        if EncodingValue<>''
        then begin
          NewCodepage := FindCodepage(EncodingValue);
          if NewCodepage=0
          then
            raise Exception.CreateFmt(SSimpleXmlError26, [EncodingValue]);
          aXML.SetCodepage(NewCodepage);
        end
        else
          aXML.SetCodepage(CP_UTF8);
      end;
    end
    else
      aNode.FData := aXml.ParseTo('?>');
  end;

  // на входе: первый '--'
  // на выходе: символ после '-->'
  procedure ParseComment;
  begin
    aXml.ExpectText('--');
    Insert(TbjXmlComment.Create(aNames, aXml.ParseTo('-->')), -1);
  end;

  // на входе: '[CDATA['
  // на выходе: символ после ']]>'
  procedure ParseCDATA;
  begin
    aXml.ExpectText('[CDATA[');
    Insert(TbjXmlCDATASection.Create(aNames, aXml.ParseTo(']]>')), -1);
  end;

  // на входе: 'DOCTYPE'
  // на выходе: символ после '>'
  procedure ParseDOCTYPE;
  begin
    aXml.ExpectText('DOCTYPE');
    aXml.ParseTo('>');
  end;

  // на входе: 'имя-элемента'
  // на выходе: символ после '>'
  procedure ParseElement;
  var
    aNameID: NativeInt;
    aNode: TbjXmlElement;
  begin
    aNameID := aNames.GetID(aXml.ExpecTbjXmlName);
    if aXml.EOF then
      raise Exception.Create(SSimpleXMLError2);
    if not ((aXml.CurChar <= ' ') or (aXml.CurChar = '/') or (aXml.CurChar = '>')) then
      raise Exception.Create(SSimpleXMLError3);
    aNode := TbjXmlElement.Create(aNames, aNameID);
    Insert(aNode, -1);
    aXml.ParseAttrs(aNode);
    if aXml.CurChar = '/' then
      aXml.ExpectText('/>')
    else begin
      aXml.ExpectChar('>');
      aNode.Get_Childs.ParseXML(aXml, aNames, aPreserveWhiteSpace);
      aXml.ExpectChar('/');
      aXml.ExpectText(PbjXmlChar(aNames.GetName(aNameID)));
      aXml.SkipBlanks;
      aXml.ExpectChar('>');
    end;
  end;

begin
  while not aXML.EOF do
  begin
    ParseText;
    if aXML.CurChar = '<'
    then begin// символ разметки
      if aXML.Next
      then begin
        if aXML.CurChar = '/' 
        then // закрывающий тэг элемента
          Exit
        else 
        if aXML.CurChar = '?'
        then begin// инструкция
          ParseProcessingInstruction;
        end
        else 
        if aXML.CurChar = '!' 
        then begin
          if aXML.Next 
          then begin
            if aXML.CurChar = '-' 
            then // коментарий
              ParseComment
            else 
            if aXML.CurChar = '[' 
            then // секция CDATA
              ParseCDATA
            else
              ParseDOCTYPE;
          end;
        end
        else // открывающий тэг элемента
          ParseElement;
      end;
    end;
  end;
end;

procedure TbjXmlNodeList.LoadBinXml(aReader: TBinXmlReader; aCount: Integer; aNames: TbjXmlNameTable);
var
  i: Integer;
  aNodeType: TbjXmlNodeType;
  aNode: TbjXml;
  aNameID: LongInt;
begin
  Clear;
  SetLength(FItems, aCount);
  for i := 0 to aCount - 1 do begin
    aReader.Read(aNodeType, sizeof(aNodeType));
    case aNodeType of
      NODE_ELEMENT:
        begin
          aNameID := aNames.GetNameID(aReader.ReadLongint);
          aNode := TbjXmlElement.Create(aNames, aNameID);
          Insert(aNode, -1);
          aReader.ReadVariant(TVarData(TbjXmlElement(aNode).FData));
          aNode.LoadBinXml(aReader);
        end;
      NODE_TEXT:
        begin
          aNode := TbjXmlText.Create(aNames, Unassigned);
          Insert(aNode, -1);
          aReader.ReadVariant(TVarData(TbjXmlText(aNode).FData));
        end;
      NODE_CDATA_SECTION:
        Insert(TbjXmlCDATASection.Create(aNames, aReader.ReadXmlString), -1);
      NODE_PROCESSING_INSTRUCTION:
        begin
          aNameID := aNames.GetNameID(aReader.ReadLongint);
          aNode := TbjXmlProcessingInstruction.Create(aNames, aNameID,
            aReader.ReadXmlString);
          Insert(aNode, -1);
          aNode.LoadBinXml(aReader);
        end;
      NODE_COMMENT:
        Insert(TbjXmlComment.Create(aNames, aReader.ReadXmlString), -1);
      else
        raise Exception.Create(SSimpleXMLError4);
    end
  end;
end;

procedure TbjXmlNodeList.SaveBinXml(aWriter: TBinXmlWriter);
const
  EmptyVar: TVarData = (VType:varEmpty);
var
  aCount: LongInt;
  i: Integer;
  aNodeType: TbjXmlNodeType;
  aNode: TbjXml;
begin
  aCount := FCount;
  for i := 0 to aCount - 1 do begin
    aNode := FItems[i];
    aNodeType := aNode.Get_NodeType;
    aWriter.Write(aNodeType, sizeof(aNodeType));
    case aNodeType of
      NODE_ELEMENT:
        with TbjXmlElement(aNode) do begin
          aWriter.WriteLongint(FNames.GetKeyID(FNameID));
          if Assigned(FChilds) and (FChilds.FCount > 0) or VarIsEmpty(FData) then
            aWriter.WriteVariant(EmptyVar)
          else
            aWriter.WriteVariant(TVarData(FData));
          SaveBinXml(aWriter);
        end;
      NODE_TEXT:
        aWriter.WriteVariant(TVarData(TbjXmlText(aNode).FData));
      NODE_CDATA_SECTION:
        aWriter.WriteXmlString(TbjXmlCDATASection(aNode).FData);
      NODE_PROCESSING_INSTRUCTION:
        begin
          with TbjXmlProcessingInstruction(aNode) do
          begin
            aWriter.WriteLongint(FNames.GetKeyID(FTargetNameID));
            aWriter.WriteXmlString(FData);
          end;
          aNode.SaveBinXml(aWriter);
        end;
      NODE_COMMENT:
        aWriter.WriteXmlString(TbjXmlComment(aNode).FData);
      else
        raise Exception.Create(SSimpleXmlError5);
    end
  end;
end;

procedure TbjXmlNodeList.SaveXML(aXML: TbjXmlSaver);
var
  i: Integer;
begin
  for i := 0 to FCount - 1 do
    FItems[i].SaveXML(aXML);
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'XML Node Implementation'}{$ENDIF}
{ TbjXml }

constructor TbjXml.CreateNode(aNames: TbjXmlNameTable);
begin
  inherited Create;
  {$IFDEF ADDebug}
  FDebugId := InterlockedIncrement(DebugId);
  outputdebugstring(PChar(Format('Create %s (%d)', [Classname, FDebugId])));
  {$ENDIF}
  if aNames<>nil
  then
    FNames := aNames
  else
    FNames := TbjXmlNameTable.Create(DefaultHashSize);
  FNames._AddRef;
end;

destructor TbjXml.Destroy;
begin
  {$IFDEF ADDebug}
  outputdebugstring(PChar(Format('Destroy %s (%d)', [Classname, FDebugId])));
  {$ENDIF}
  if Assigned(FChilds) then
    FChilds._Release;
  FNames._Release;
  inherited;
end;

function TbjXml.Get_Childs: TbjXmlNodeList;
begin
  if not Assigned(FChilds) then begin
    FChilds := TbjXmlNodeList.Create(Self);
    FChilds._AddRef;
  end;
  Result := FChilds;
end;

function TbjXml.GetChilds: TbjXmlNodeList;
begin
  Result := Get_Childs;
end;

function TbjXml.GetChildWithTag(const aName: TbjXmlString): IbjXml;
var
  i: integer;
  aNode: IbjXml;
  aChilds: TbjXmlNodeList;
begin
  aChilds := Get_Childs;
  Result := nil;
// Loop through all subnodes
  for i := 0 to aChilds.FCount - 1 do
  begin
    aNode := aChilds.Get_Item(i);
    if aNode.Tag = aName then
    begin
      Result := aNode;
    end;
  end;
//  FindFirstChild(FNames.GetID(aName));
end;

procedure TbjXml.AppendChild(const aChild: IbjXml);
begin
  Get_Childs.Insert(aChild.GetObject as TbjXml, -1);
end;

function TbjXml.Get_AttrCount: Integer;
begin
  Result := FAttrCount;
end;

function TbjXml.Get_AttrName(anIndex: Integer): TbjXmlString;
begin
  Result := FNames.GetName(FAttrs[anIndex].NameID);
end;

function TbjXml.Get_AttrNameID(anIndex: Integer): NativeInt;
begin
  Result := FAttrs[anIndex].NameID;
end;

//function TbjXml.Get_ChildNodes: IbjXmlNodeList;
//begin
//  Result := GetChilds
//end;

function TbjXml.Get_NameTable: IbjXmlNameTable;
begin
  Result := FNames;
//  Result._AddRef;
end;

function TbjXml.GetAttr(const aName, aDefault: TbjXmlString): TbjXmlString;
begin
  Result := GetAttr(FNames.GetID(aName), aDefault)
end;

function TbjXml.GetAttrValue(const aName: TbjXmlString): TbjXmlString;
begin
  Result := GetAttr(FNames.GetID(aName))
end;

function TbjXml.GetAttr(aNameID: NativeInt; const aDefault: TbjXmlString): TbjXmlString;
var
  aData: PXmlAttrData;
begin
  aData := FindAttrData(aNameID);
  if Assigned(aData) then
    Result := aData.Value
  else
    Result := aDefault
end;

function TbjXml.GetBoolAttr(aNameID: NativeInt; aDefault: Boolean): Boolean;
var
  aData: PXmlAttrData;
begin
  aData := FindAttrData(aNameID);
  if Assigned(aData) then
    Result := aData.Value
  else
    Result := aDefault
end;

function TbjXml.GetBoolAttr(const aName: TbjXmlString; aDefault: Boolean): Boolean;
begin
  Result := GetBoolAttr(FNames.GetID(aName), aDefault)
end;

function TbjXml.FindFirstChild(aNameID: NativeInt): TbjXml;
var
  i: Integer;
begin
  if Assigned(FChilds) then
    for i := 0 to FChilds.FCount - 1 do begin
      Result := FChilds.FItems[i];
      if Result.Get_NodeNameID = aNameID then
        Exit
    end;
  Result := nil
end;

function TbjXml.FullPath: TbjXmlString;
var
  aParent: TbjXml;
begin
  aParent := FParentNode;
  if (aParent<>nil)
  then begin
    Result := Get_NodeName;
    while (aParent<>nil) and (aParent.ClassType<>TbjXml) do
    begin
      Result := aParent.Get_NodeName + XMLPathDelimiter + Result;
      aParent := aParent.FParentNode;
    end;
  end;
end;

function TbjXml.GetChildText(aNameID: NativeInt;
                               const aDefault: TbjXmlString): TbjXmlString;
var
  aChild: TbjXml;
begin
  aChild := FindFirstChild(aNameID);
  if Assigned(aChild) then
    Result := aChild.Get_Text
  else
    Result := aDefault
end;

function TbjXml.GetChildText(const aName: TbjXmlString;
                               const aDefault: TbjXmlString): TbjXmlString;
begin
  Result := GetChildText(FNames.GetID(aName), aDefault);
end;

function TbjXml.GetChildContent(const aName: TbjXmlString): TbjXmlString;
begin
  Result := GetChildText(FNames.GetID(aName));
end;

function TbjXml.GetEnumAttr(const aName: TbjXmlString;
                              const aValues: array of TbjXmlString;
                              aDefault: Integer): Integer;
begin
  Result := GetEnumAttr(FNames.GetID(aName), aValues, aDefault);
end;

function EnumAttrValue(aNode: TbjXml; anAttrData: PXmlAttrData;
                       const aValues: array of TbjXmlString): Integer;
var
  anAttrValue: TbjXmlString;
  s: TbjXmlString;
  i: Integer;
begin
  anAttrValue := anAttrData.Value;
  for Result := 0 to Length(aValues) - 1 do
    if AnsiCompareText(anAttrValue, aValues[Result]) = 0 then
      Exit;
  if Length(aValues) = 0 then
    s := ''
  else begin
    s := aValues[0];
    for i := 1 to Length(aValues) - 1 do
      s := s + #13#10 + aValues[i];
  end;
  raise Exception.CreateFmt(SSimpleXmlError6,
    [aNode.FNames.GetName(anAttrData.NameID), aNode.Get_NodeName, s]);
end;

function TbjXml.GetEnumAttr(aNameID: NativeInt;
                              const aValues: array of TbjXmlString; 
                              aDefault: Integer): Integer;
var
  anAttrData: PXmlAttrData;
begin
  anAttrData := FindAttrData(aNameID);
  if Assigned(anAttrData) then
    Result := EnumAttrValue(Self, anAttrData, aValues)
  else
    Result := aDefault;
end;

function TbjXml.NeedEnumAttr(const aName: TbjXmlString;
                               const aValues: array of TbjXmlString): Integer;
begin
  Result := NeedEnumAttr(FNames.GetID(aName), aValues)
end;

function TbjXml.NeedEnumAttr(aNameID: NativeInt;
                               const aValues: array of TbjXmlString): Integer;
var
  anAttrData: PXmlAttrData;
begin
  anAttrData := FindAttrData(aNameID);
  if Assigned(anAttrData) then
    Result := EnumAttrValue(Self, anAttrData, aValues)
  else
    raise Exception.CreateFmt(SSimpleXMLError7, [FNames.GetName(aNameID)]);
end;

function TbjXml.GetFloatAttr(const aName: TbjXmlString; aDefault: Double): Double;
begin
  Result := GetFloatAttr(FNames.GetID(aName), aDefault);
end;

function TbjXml.GetFloatAttr(aNameID: NativeInt; aDefault: Double): Double;
var
  aData: PXmlAttrData;
begin
  aData := FindAttrData(aNameID);
  if Assigned(aData) then
    if VarIsNumeric(aData.Value) then
      Result := aData.Value
    else
      Result := XSTRToFloat(aData.Value)
  else
    Result := aDefault
end;

function TbjXml.GetHexAttr(aNameID: NativeInt; aDefault: Integer): Integer;
var
  anAttr: PXmlAttrData;
begin
  anAttr := FindAttrData(aNameID);
  if Assigned(anAttr) then
    Result := StrToInt('$' + anAttr.Value)
  else
    Result := aDefault;
end;

function TbjXml.GetHexAttr(const aName: TbjXmlString; aDefault: Integer): Integer;
begin
  Result := GetHexAttr(FNames.GetID(aName), aDefault)
end;

function TbjXml.GetIntAttr(aNameID: NativeInt; aDefault: Integer): Integer;
var
  anAttr: PXmlAttrData;
begin
  anAttr := FindAttrData(aNameID);
  if Assigned(anAttr) then
    Result := anAttr.Value
  else
    Result := aDefault;
end;

function TbjXml.GetIntAttr(const aName: TbjXmlString; aDefault: Integer): Integer;
begin
  Result := GetIntAttr(FNames.GetID(aName), aDefault)
end;

function TbjXml.NeedAttr(aNameID: NativeInt): TbjXmlString;
var
  anAttr: PXmlAttrData;
begin
  anAttr := FindAttrData(aNameID);
  if not Assigned(anAttr) then
    raise Exception.CreateFmt(SSimpleXmlError8, [FNames.GetName(aNameID)]);
  Result := anAttr.Value
end;

function TbjXml.NeedAttr(const aName: TbjXmlString): TbjXmlString;
begin
  Result := NeedAttr(FNames.GetID(aName))
end;

function TbjXml.GetVarAttr(aNameID: NativeInt; const aDefault: Variant): Variant;
var
  anAttr: PXmlAttrData;
begin
  anAttr := FindAttrData(aNameID);
  if Assigned(anAttr) then
    Result := anAttr.Value
  else
    Result := aDefault;
end;

function TbjXml.GetVarAttr(const aName: TbjXmlString; 
                             const aDefault: Variant): Variant;
begin
  Result := GetVarAttr(FNames.GetID(aName), aDefault)
end;

function TbjXml.GeTbjXmlIntend: Integer;
var
  aParentNode: TbjXml;
begin
//  Result := 0;
  Result := -1;
  aParentNode := FParentNode;
  while (aParentNode<>nil) and not (aParentNode.isDocument) do
  begin
    aParentNode := aParentNode.FParentNode;
    inc(Result);
  end;
end;

function TbjXml.Get_NodeName: TbjXmlString;
begin
  Result := FNames.GetName(Get_NodeNameID);
end;

function TbjXml.GetTag: TbjXmlString;
begin
  Result := Get_NodeName;
end;

function TbjXml.Get_NodeType: TbjXmlNodeType;
begin
  Result := High(TbjXmlNodeType);
  while (Result>Low(TbjXmlNodeType)) and (NodeClasses[Result]<>ClassType) do
    dec(Result);
end;

function TbjXml.GetOwnerDocument: TbjXml;
var
  aResult: TbjXml;
begin
  aResult := Self;
  while (aResult<>nil) and not (aResult.isDocument) do
    aResult := aResult.FParentNode;
  Result := TbjXml(aResult);
end;

function TbjXml.Get_OwnerDocument: IbjXml;
var
  aDoc: TbjXml;
begin
  aDoc := GetOwnerDocument;
  if Assigned(aDoc) then
    Result := aDoc
  else
    Result := nil;
end;

function TbjXml.Get_ParentNode: IbjXml;
begin
  Result := FParentNode;
end;

function TbjXml.GetParent: IbjXml;
begin
  Result := Get_ParentNode;
end;

function TbjXml.Get_TypedValue: Variant;
begin
  Result := Get_Text
end;

procedure TbjXml.InsertBefore(const aChild, aBefore: IbjXml);
var
  i: Integer;
  aChilds: TbjXmlNodeList;
begin
  aChilds := Get_Childs;
  if Assigned(aBefore) then
    i := aChilds.IndexOf(aBefore.GetObject as TbjXml)
  else
    i := aChilds.FCount;
  Get_Childs.Insert(aChild.GetObject as TbjXml, i)
end;

procedure TbjXml.RemoveAllAttrs;
begin
  FAttrCount := 0;
end;

procedure TbjXml.RemoveAllChilds;
begin
  if Assigned(FChilds) then
    FChilds.Clear
end;

procedure TbjXml.Clear;
begin
  GetOwnerDocument;
  RemoveAllChilds;
  RemoveAllAttrs;
end;

procedure TbjXml.RemoveAttr(const aName: TbjXmlString);
begin
  RemoveAttr(FNames.GetID(aName));
end;

procedure TbjXml.RemoveAttr(aNameID: NativeInt);
var
  a1, a2: PXmlAttrData;
  i: Integer;
begin
  a1 := @FAttrs[0];
  i := 0;
  while (i < FAttrCount) and (a1.NameID <> aNameID) do begin
    Inc(a1);
    Inc(i)
  end;
  if i < FAttrCount then begin
    a2 := a1;
    Inc(a2);
    while i < FAttrCount - 1 do begin
      a1^ := a2^;
      Inc(a1);
      Inc(a2);
      Inc(i)
    end;
    VarClear(a1.Value);
    Dec(FAttrCount);
  end;
end;

procedure TbjXml.RemoveChild(const aChild: IbjXml);
begin
  Get_Childs.Remove(aChild.GetObject as TbjXml)
end;

procedure TbjXml.ReplaceChild(const aNewChild, anOldChild: IbjXml);
var
  i: Integer;
  aChilds: TbjXmlNodeList;
begin
  aChilds := Get_Childs;
  i := aChilds.IndexOf(anOldChild.GetObject as TbjXml);
  if i <> -1 then
    aChilds.Replace(i, aNewChild.GetObject as TbjXml)
end;

function TbjXml.NewChild(const aName: TbjXmlString; const aText: TbjXmlString): IbjXml;
var
  aChild: TbjXml;
begin
  aChild := TbjXmlElement.Create(FNames, FNames.GetID(aName));
  aChild.Set_Text(aText);
  GetChilds.Insert(aChild, -1);
  Result := aChild;
end;

procedure TbjXml.NewChild2(const aName: TbjXmlString; const aText: TbjXmlString);
var
  aChild: TbjXml;
begin
  aChild := TbjXmlElement.Create(FNames, FNames.GetID(aName));
  aChild.Set_Text(aText);
  GetChilds.Insert(aChild, -1);
end;

function NameCanBeginWith(aChar: TbjXmlChar): Boolean;
begin
  {$IFDEF XML_WIDE_CHARS}
  Result := (aChar = '_') or IsCharAlphaW(aChar)
  {$ELSE}
  Result := (aChar = '_') or IsCharAlpha(aChar)
  {$ENDIF}
end;

function NameCanContain(aChar: TbjXmlChar): Boolean;
begin
  {$IFDEF XML_WIDE_CHARS}
  Result := (aChar = '_') or (aChar = '-') or (aChar = ':') or (aChar = '.') or
    IsCharAlphaNumericW(aChar)
  {$ELSE}
    {$IFDEF Unicode}
    Result := CharInSet(aChar, ['_', '-', ':', '.']) or IsCharAlphaNumeric(aChar)
    {$ELSE}
    Result := (aChar in ['_', '-', ':', '.']) or IsCharAlphaNumeric(aChar)
    {$ENDIF}
  {$ENDIF}
end;

function IsName(const s: TbjXmlString): Boolean;
var
  i: Integer;
begin
  if s = '' then
    Result := False
  else if not NameCanBeginWith(s[1]) then
    Result := False
  else begin
    for i := 2 to Length(s) do
      if not NameCanContain(s[i]) then begin
        Result := False;
        Exit
      end;
    Result := True;
  end;
end;

const
  ntComment = -2;
  ntNode = -3;
  ntProcessingInstruction = -4;
  ntText = -5;

type
  TAxis = (axAncestor, axAncestorOrSelf, axAttribute, axChild,
    axDescendant, axDescendantOrSelf, axFollowing, axFollowingSibling,
    axParent, axPreceding, axPrecedingSibling, axSelf);

  TPredicate = class
    function Check(aNode: TbjXml): Boolean; virtual; abstract;
  end;

  TLocationStep = class
    Next: TLocationStep;
    Axis: TAxis;
    NodeTest: Integer;
    Predicates: TList;
  end;



function TbjXml.SelectNodes(const anExpression: TbjXmlString): IbjXmlNodeList;
var
  aNodes: TbjXmlNodeList;
  aChilds: TbjXmlNodeList;
  aChild: TbjXml;
  iChild: IbjXml;
  aNameID: NativeInt;
  i, p: Integer;
begin
  if IsName(anExpression)
  then begin
    aNodes := TbjXmlNodeList.Create(nil);
    Result := aNodes;
    aChilds := Get_Childs;
    aNameID := FNames.GetID(anExpression);
    for i := 0 to aChilds.FCount - 1 do begin
      aChild := aChilds.FItems[i];
      if (aChild.ClassType = TbjXmlElement) and (aChild.Get_NodeNameID = aNameID) then
        aNodes.Insert(aChild, aNodes.FCount);
    end;
  end
  else begin
    p := Pos(XMLPathDelimiter, anExpression);
    if p>0
    then begin
      iChild := SelectSingleNode(copy(anExpression, 1, p-1));
      if iChild<>nil
      then
        Result := iChild.SelectNodes(copy(anExpression, p+1, MaxInt));
    end
    else
      raise Exception.Create(SSimpleXmlError9)
  end;
end;

function TbjXml.SelectSingleNode(const anExpression: TbjXmlString): IbjXml;
var
  aChilds: TbjXmlNodeList;
  aChild: TbjXml;
  aNameID: NativeInt;
  i, p: Integer;
begin
  Result := nil;
  if IsName(anExpression)
  then begin
    aChilds := Get_Childs;
    aNameID := FNames.GetID(anExpression);
    for i := 0 to aChilds.FCount - 1 do
    begin
      aChild := aChilds.FItems[i];
      if (aChild.ClassType = TbjXmlElement) and (aChild.Get_NodeNameID = aNameID)
      then begin
        Result := aChild;
        Exit;
      end
    end;
  end
  else begin
    p := Pos(XMLPathDelimiter, anExpression);
    if p>0
    then begin
      Result := SelectSingleNode(copy(anExpression, 1, p-1));
      if Result<>nil
      then
        Result := Result.SelectSingleNode(copy(anExpression, p+1, MaxInt));
    end
    else
      raise Exception.Create(SSimpleXmlError9)
  end
end;

function TbjXml.FindElement(const anElementName, anAttrName: String;
                              const anAttrValue: Variant): IbjXmlElement;
var
  aChild: TbjXml;
  aNameID, anAttrNameID: NativeInt;
  i: Integer;
  pa: PXmlAttrData;
begin
  if Assigned(FChilds) then begin
    aNameID := FNames.GetID(anElementName);
    anAttrNameID := FNames.GetID(anAttrName);

    for i := 0 to FChilds.FCount - 1 do begin
      aChild := FChilds.FItems[i];
      if (aChild.ClassType = TbjXmlElement) and (aChild.Get_NodeNameID = aNameID) then begin
        pa := aChild.FindAttrData(anAttrNameID);
        try
          if Assigned(pa) and VarSameValue(pa.Value, anAttrValue) then begin
            Result := aChild.AsElement;
            Exit
          end
        except
          // Исключительная ситуация может возникнуть в том случае,
          // если произойдет сбой в функции VarSameValue.
          // Иными словами - если значения нельзя сравнивать.
        end;
      end
    end;
  end;
  Result := nil;
end;

procedure TbjXml.Set_TypedValue(const aValue: Variant);
begin
  Set_Text(aValue)
end;

procedure TbjXml.SetAttr(const aName, aValue: TbjXmlString);
begin
  SetVarAttr(FNames.GetID(aName), aValue)
end;

procedure TbjXml.SetAttr(aNameID: NativeInt; const aValue: TbjXmlString);
begin
  SetVarAttr(aNameID, aValue)
end;

procedure TbjXml.SetBoolAttr(aNameID: NativeInt; aValue: Boolean);
begin
  SetVarAttr(aNameID, aValue)
end;

procedure TbjXml.SetBoolAttr(const aName: TbjXmlString; aValue: Boolean);
begin
  SetVarAttr(FNames.GetID(aName), aValue)
end;

procedure TbjXml.SetChildText(const aName: TbjXmlString;
                                const aValue: TbjXmlString);
begin
  SetChildText(FNames.GetID(aName), aValue)
end;

procedure TbjXml.SetChildText(aNameID: NativeInt; const aValue: TbjXmlString);
var
  aChild: TbjXml;
begin
  aChild := FindFirstChild(aNameID);
  if not Assigned(aChild) then begin
    aChild := TbjXmlElement.Create(FNames, aNameID);
    with Get_Childs do
      Insert(aChild, FCount);
  end;
  aChild.Set_Text(aValue)
end;

procedure TbjXml.SetFloatAttr(aNameID: NativeInt; aValue: Double);
begin
  SetVarAttr(aNameID, aValue)
end;

procedure TbjXml.SetFloatAttr(const aName: TbjXmlString; aValue: Double);
begin
  SetVarAttr(FNames.GetID(aName), aValue);
end;

procedure TbjXml.SetHexAttr(const aName: TbjXmlString;
                              aValue, aDigits: Integer);
begin
  SetVarAttr(FNames.GetID(aName), IntToHex(aValue, aDigits))
end;

procedure TbjXml.SetHexAttr(aNameID: NativeInt; aValue, aDigits: Integer);
begin
  SetVarAttr(aNameID, IntToHex(aValue, aDigits))
end;

procedure TbjXml.SetIntAttr(aNameID: NativeInt; aValue: Integer);
begin
  SetVarAttr(aNameID, aValue)
end;

procedure TbjXml.SetIntAttr(const aName: TbjXmlString; aValue: Integer);
begin
  SetVarAttr(FNames.GetID(aName), aValue)
end;

procedure TbjXml.SetVarAttr(const aName: TbjXmlString; aValue: Variant);
begin
  SetVarAttr(FNames.GetID(aName), aValue)
end;

function TbjXml.AddAttribute(const aName: TbjXmlString; const aText: TbjXmlString): integer;
var
  aNameID: NativeInt;
  anAttr: PXmlAttrData;
  aDelta: Integer;
begin
  aNameID := FNames.GetID(aName);
  anAttr := FindAttrData(aNameID);
  if not Assigned(anAttr) then begin
    if FAttrCount = Length(FAttrs) then begin
      if FAttrCount > 64 then
        aDelta := FAttrCount div 4
      else if FAttrCount > 8 then
        aDelta := 16
      else
        aDelta := 4;
      SetLength(FAttrs, FAttrCount + aDelta);
    end;
    anAttr := @FAttrs[FAttrCount];
    anAttr.NameID := aNameID;
    Inc(FAttrCount);
  end;
  anAttr.Value := aText;
  Result := ANameID;
end;

procedure TbjXml.SetVarAttr(aNameID: NativeInt; const aValue: Variant);
var
  anAttr: PXmlAttrData;
var
  aDelta: Integer;
begin
  anAttr := FindAttrData(aNameID);
  if not Assigned(anAttr) then begin
    if FAttrCount = Length(FAttrs) then begin
      if FAttrCount > 64 then
        aDelta := FAttrCount div 4
      else if FAttrCount > 8 then
        aDelta := 16
      else
        aDelta := 4;
      SetLength(FAttrs, FAttrCount + aDelta);
    end;
    anAttr := @FAttrs[FAttrCount];
    anAttr.NameID := aNameID;
    Inc(FAttrCount);
  end;
  anAttr.Value := aValue
end;

function TbjXml.FindAttrData(aNameID: NativeInt): PXmlAttrData;
var
  i: Integer;
begin
  Result := @FAttrs[0];
  for i := 0 to FAttrCount - 1 do
    if Result.NameID = aNameID then
      Exit
    else
      Inc(Result);
  Result := nil;
end;

function TbjXml.AsElement: IbjXmlElement;
begin
  Result := nil
end;

function TbjXml.AsCDATASection: IbjXmlCDATASection;
begin
  Result := nil
end;

function TbjXml.AsComment: IbjXmlComment;
begin
  Result := nil
end;

function TbjXml.AsText: IbjXmlText;
begin
  Result := nil
end;

function TbjXml.AsProcessingInstruction: IbjXmlProcessingInstruction;
begin
  Result := nil
end;

function TbjXml.AppendCDATA(const aData: TbjXmlString): IbjXmlCDATASection;
var
  aChild: TbjXmlCDATASection;
begin
  aChild := TbjXmlCDATASection.Create(FNames, aData);
  Get_Childs.Insert(aChild, -1);
  Result := aChild
end;

function TbjXml.AppendComment(const aData: TbjXmlString): IbjXmlComment;
var
  aChild: TbjXmlComment;
begin
  aChild := TbjXmlComment.Create(FNames, aData);
  Get_Childs.Insert(aChild, -1);
  Result := aChild
end;

function TbjXml.AppendElement(const aName: TbjXmlString): IbjXmlElement;
var
  aChild: TbjXmlElement;
begin
  aChild := TbjXmlElement.Create(FNames, FNames.GetID(aName));
  Get_Childs.Insert(aChild, -1);
  Result := aChild
end;

function TbjXml.AppendElement(aNameID: NativeInt): IbjXmlElement;
var
  aChild: TbjXmlElement;
begin
  aChild := TbjXmlElement.Create(FNames, aNameID);
  Get_Childs.Insert(aChild, -1);
  Result := aChild
end;

function TbjXml.AppendProcessingInstruction(const aTarget,
  aData: TbjXmlString): IbjXmlProcessingInstruction;
var
  aChild: TbjXmlProcessingInstruction;
begin
  aChild := TbjXmlProcessingInstruction.Create(FNames, FNames.GetID(aTarget), aData);
  Get_Childs.Insert(aChild, -1);
  Result := aChild
end;

function TbjXml.AppendProcessingInstruction(aTargetID: NativeInt;
  const aData: TbjXmlString): IbjXmlProcessingInstruction;
var
  aChild: TbjXmlProcessingInstruction;
begin
  aChild := TbjXmlProcessingInstruction.Create(FNames, aTargetID, aData);
  Get_Childs.Insert(aChild, -1);
  Result := aChild
end;

function TbjXml.AppendText(const aData: TbjXmlString): IbjXmlText;
var
  aChild: TbjXmlText;
begin
  aChild := TbjXmlText.Create(FNames, aData);
  Get_Childs.Insert(aChild, -1);
  Result := aChild
end;

function TbjXml.GetAttrsXML: TbjXmlString;
var
  a: PXmlAttrData;
  i: Integer;
begin
  Result := '';
  if FAttrCount > 0 then begin
    a := @FAttrs[0];
    for i := 0 to FAttrCount - 1 do begin
      Result := Result + ' ' + FNames.GetName(a.NameID) + '="' + TextToXML(VarToXSTR(TVarData(a.Value))) + '"';
      Inc(a);
    end;
  end;
end;

procedure TbjXml.LoadBinXml(aReader: TBinXmlReader);
var
  aCount: LongInt;
  a: PXmlAttrData;
  i: Integer;
begin
  // Считать атрибуты //Load attributes
  RemoveAllAttrs;
  aCount := aReader.ReadLongint;
  SetLength(FAttrs, aCount);
  FAttrCount := aCount;
  a := @FAttrs[0];
  for i := 0 to aCount - 1 do begin
    a.NameID := FNames.GetNameID(aReader.ReadLongint);
    aReader.ReadVariant(TVarData(a.Value));
    Inc(a);
  end;

  // Считать дочерние узлы //Load childs
  aCount := aReader.ReadLongint;
  if aCount > 0 then
    Get_Childs.LoadBinXml(aReader, aCount, FNames);
end;

procedure TbjXml.SaveBinXml(aWriter: TBinXmlWriter);
var
  aCount: LongInt;
  a: PXmlAttrData;
  i: Integer;
begin
  // Считать атрибуты  //Save attributes
  aCount := FAttrCount;
  aWriter.WriteLongint(aCount);
  a := @FAttrs[0];
  for i := 0 to aCount - 1 do begin
    aWriter.WriteLongint(FNames.GetKeyID(a.NameID));
    aWriter.WriteVariant(TVarData(a.Value));
    Inc(a);
  end;

  // Записать дочерние узлы //Save Childs
  if Assigned(FChilds) then begin
    aWriter.WriteLongint(FChilds.FCount);
    FChilds.SaveBinXml(aWriter);
  end
  else
    aWriter.WriteLongint(0);
end;

function TbjXml.Get_DataType: Integer;
begin
  {$IF Defined(Unicode)}
  Result := varUString;
  {$ELSEIF Defined(XML_WIDE_CHARS)}
  Result := varOleStr;
  {$ELSE}
  Result := varString;
  {$IFEND}
end;

function TbjXml.AttrExists(aNameID: NativeInt): Boolean;
begin
  Result := FindAttrData(aNameID) <> nil
end;

function TbjXml.AttrExists(const aName: TbjXmlString): Boolean;
begin
  Result := FindAttrData(FNames.GetID(aName)) <> nil
end;

function TbjXml.GetAttrType(aNameID: NativeInt): Integer;
var
  a: PXmlAttrData;
begin
  a := FindAttrData(aNameID);
  if Assigned(a) then
    Result := TVarData(a.Value).VType
  else
    {$IF Defined(Unicode)}
    Result := varUString;
    {$ELSEIF Defined(XML_WIDE_CHARS)}
    Result := varOleStr;
    {$ELSE}
    Result := varString;
    {$IFEND}
end;

function TbjXml.GetAttrType(const aName: TbjXmlString): Integer;
begin
  Result := GetAttrType(FNames.GetID(aName));
end;

function TbjXml.Get_Values(const aName: String): Variant;
var
  aChild: IbjXml;
begin
  if aName = '' then
    Result := Get_TypedValue
  else if aName[1] = '@' then
    Result := GetVarAttr(Copy(aName, 2, Length(aName) - 1), '')
  else begin
    aChild := SelectSingleNode(aName);
    if Assigned(aChild) then
      Result := aChild.TypedValue
    else
      Result := ''
  end
end;

procedure TbjXml.Set_Values(const aName: String; const aValue: Variant);
var
  aChild: IbjXml;
begin
  if aName = '' then
    Set_TypedValue(aValue)
  else if aName[1] = '@' then
    SetVarAttr(Copy(aName, 2, Length(aName) - 1), aValue)
  else begin
    aChild := SelectSingleNode(aName);
    if not Assigned(aChild) then
      aChild := AppendElement(aName);
    aChild.TypedValue := aValue;
  end
end;

function TbjXml.GetDateTimeAttr(aNameID: NativeInt; aDefault: TDateTime): TDateTime;
var
  anAttr: PXmlAttrData;
  aVarType: Word;
begin
  anAttr := FindAttrData(aNameID);
  if Assigned(anAttr) then begin
    aVarType := VarType(anAttr.Value);
    {$IFDEF Unicode}
    if (aVarType=varUString) or (aVarType=varString) or (aVarType=varOleStr) then
    {$ELSE}
    if (aVarType=varString) or (aVarType=varOleStr) then
    {$ENDIF}
      Result := XSTRToDateTime(anAttr.Value)
    else
      Result := VarAsType(anAttr.Value, varDate)
  end
  else
    Result := aDefault;
end;

function TbjXml.GetDateTimeAttr(const aName: TbjXmlString;
  aDefault: TDateTime): TDateTime;
begin
  Result := GetDateTimeAttr(FNames.GetID(aName), aDefault)
end;

procedure TbjXml.SetDateTimeAttr(aNameID: NativeInt; aValue: TDateTime);
begin
  SetVarAttr(aNameID, VarAsType(aValue, varDate))
end;

procedure TbjXml.SetDateTimeAttr(const aName: TbjXmlString;
                                         aValue: TDateTime);
begin
  SetVarAttr(aName, VarAsType(aValue, varDate))
end;

function TbjXml.EnsureChild(aNameID: NativeInt): IbjXml;
var
  aChild: TbjXml;
begin
  aChild := FindFirstChild(aNameID);
  if Assigned(aChild) then
    Result := aChild
  else
    Result := AppendElement(aNameID)
end;

function TbjXml.EnsureChild(const aName: TbjXmlString): IbjXml;
begin
  Result := EnsureChild(FNames.GetID(aName))
end;

function TbjXml.NeedChild(aNameID: NativeInt): IbjXml;
var
  aChild: TbjXml;
begin
  aChild := FindFirstChild(aNameID);
  if not Assigned(aChild) then
    raise Exception.CreateFmt(SSimpleXmlError10, [FNames.GetName(aNameID)]);
  Result := aChild
end;

function TbjXml.NeedChild(const aName: TbjXmlString): IbjXml;
begin
  Result := NeedChild(FNames.GetID(aName));
end;

procedure TbjXml.SetNameTable(aValue: TbjXmlNameTable);
var
  i: Integer;
begin
  if aValue <> FNames
  then begin
    //Merge different Nametables
    SetNodeNameID(aValue.GetID(Get_NodeName));
    for i := 0 to High(FAttrs) do
      with FAttrs[i] do
        NameID := aValue.GetID(FNames.GetName(NameID));
    if Assigned(FChilds) then
      for i := 0 to FChilds.FCount - 1 do
        FChilds.FItems[i].SetNameTable(aValue);
    FNames._Release;
    FNames := aValue;
    FNames._AddRef;
  end;
end;

procedure TbjXml.SetNodeNameID(aValue: Integer);
begin
//Do nothing here for Classes with read only name - like '#text'
end;

function TbjXml.CloneNode(aDeep: Boolean): IbjXml;
begin
  Result := DoCloneNode(aDeep)
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'XML Element Implementation'}{$ENDIF}
{ TbjXmlElement }

constructor TbjXmlElement.Create(aNames: TbjXmlNameTable; aNameID: NativeInt);
begin
  {$IFDEF ADDebug}
  outputdebugstring(PChar(Format('Create %s (%s)', [Classname, aNames.GetName(aNameID)])));
  {$ENDIF}
  inherited CreateNode(aNames);
  FNameID := aNameID;
end;

function TbjXmlElement.Get_NodeNameID: NativeInt;
begin
  Result := FNameID
end;

function TbjXmlElement.Get_Childs: TbjXmlNodeList;
begin
  Result := inherited Get_Childs;
  if not TVarData(FData).VType in [varEmpty, varNull] then begin
    AppendChild(TbjXmlText.Create(FNames, FData));
    VarClear(FData);
  end;
end;

function TbjXmlElement.Get_Text: TbjXmlString;
var
  aChilds: TbjXmlNodeList;
  aChild: TbjXml;
  aChildText: TbjXmlString;
  i: Integer;
begin
  Result := '';
  aChilds := FChilds;
  if Assigned(aChilds)
  then begin
    for i := 0 to aChilds.FCount - 1 do begin
      aChild := aChilds.FItems[i];
      if (aChild.ClassType=TbjXmlText) or (aChild.ClassType=TbjXmlCDATASection)//or (aChild.ClassType=TbjXmlElement)
      then begin
        aChildText := aChild.Get_Text;
        if aChildText <> ''
        then begin
          if Result = ''
          then
            Result := aChildText
          else
            Result := Result + ' ' + aChildText
        end;
      end
    end;
  end
  else if VarIsEmpty(FData) then
    Result := ''
  else
    Result := VarToXSTR(TVarData(FData))
end;

function TbjXmlElement.GetTextAsBinaryData: TBytes;
begin
  Result := Base64ToBin(Get_Text);
end;

procedure TbjXmlElement.ReplaceTextByBinaryData(const aData; aSize: Integer;
                                              aMaxLineLength: Integer);
begin
  RemoveTextNodes;
  Get_Childs.Insert(TbjXmlText.Create(FNames, BinToBase64(aData, aSize, aMaxLineLength)), -1);
end;

procedure TbjXmlElement.RemoveTextNodes;
var
  i: Integer;
  aNode: TbjXml;
begin
  if Assigned(FChilds) then
    for i := FChilds.FCount - 1 downto 0 do begin
      aNode := FChilds.FItems[i];
      if (aNode.ClassType=TbjXmlText) or (aNode.ClassType=TbjXmlCDATASection)
      then
        FChilds.Remove(aNode);
    end;
end;

procedure TbjXmlElement.ReplaceTextByCDATASection(const aText: TbjXmlString);

  procedure AddCDATASection(const aText: TbjXmlString);
  var
    i: Integer;
    aChilds: TbjXmlNodeList;
  begin
    i := Pos(']]>', aText);
    aChilds := Get_Childs;
    if i = 0 then
      aChilds.Insert(TbjXmlCDATASection.Create(FNames, aText), aChilds.FCount)
    else begin
      aChilds.Insert(TbjXmlCDATASection.Create(FNames, Copy(aText, 1, i)), aChilds.FCount);
      AddCDATASection(Copy(aText, i + 1, Length(aText) - i - 1));
    end;
  end;

begin
  RemoveTextNodes;
  AddCDATASection(aText);
end;

procedure TbjXmlElement.Set_Text(const aValue: TbjXmlString);
begin
  if Assigned(FChilds) then
    FChilds.Clear;
  FData := aValue;
end;

function TbjXmlElement.AsElement: IbjXmlElement;
begin
  Result := Self
end;

function GetIndentStr(XMLIntend: Integer): TbjXmlString;
var
  i: Integer;
begin
  SetLength(Result, XMLIntend*Length(DefaultIndentText));
  for i := 0 to XMLIntend - 1 do
    Move(DefaultIndentText[1], Result[i*Length(DefaultIndentText) + 1], Length(DefaultIndentText)*SizeOf(TbjXmlChar));
end;

function HasCRLF(const s: TbjXmlString): Boolean;
var
  i: Integer;
begin
  for i := 1 to Length(s) do
    if (s[i] = #13) or (s[i] = #10) then begin
      Result := True;
      Exit
    end;
  Result := False;
end;

function EndWithCRLF(const s: TbjXmlString): Boolean;
begin
  Result :=
    (Length(s) > 1) and
    (s[Length(s) - 1] = #13) and
    (s[Length(s)] = #10);
end;

function TbjXmlElement.Get_XML: TbjXmlString;
var
  aChildsXML: TbjXmlString;
  aTag: TbjXmlString;
  aXMLIntend: Integer;
begin
  if GetOwnerDocument.Get_PreserveWhiteSpace
  then begin
    if Assigned(FChilds) and (FChilds.FCount > 0) then
      aChildsXML := FChilds.Get_XML
    else if VarIsEmpty(FData) then
      aChildsXML := ''
    else
      aChildsXML := TextToXML(VarToXSTR(TVarData(FData)));

    aTag := FNames.GetName(FNameID);
    Result := '<' + aTag + GetAttrsXML;
    if aChildsXML = '' then
      Result := Result + '/>'
    else
      Result := Result + '>' + aChildsXML + '</' + aTag + '>'
  end
  else begin
    aXMLIntend := GeTbjXmlIntend;
    if Assigned(FChilds) and (FChilds.FCount > 0)
    then
      aChildsXML := FChilds.Get_XML
    else
    if VarIsEmpty(FData)
    then
      aChildsXML := ''
    else
      aChildsXML := TextToXML(VarToXSTR(TVarData(FData)));
    aTag := FNames.GetName(FNameID);
    Result := #13#10 + GetIndentStr(aXMLIntend) + '<' + aTag + GetAttrsXML;
    if aChildsXML = '' then
      Result := Result + '/>'
    else if HasCRLF(aChildsXML) then
      if EndWithCRLF(aChildsXML) then
        Result := Result + '>' + aChildsXML + GetIndentStr(aXMLIntend) + '</' + aTag + '>'
      else
        Result := Result + '>' + aChildsXML + #13#10 + GetIndentStr(aXMLIntend) + '</' + aTag + '>'
    else
      Result := Result + '>' + aChildsXML + '</' + aTag + '>';
  end;
end;

function TbjXmlElement.Get_TypedValue: Variant;
begin
  if Assigned(FChilds) and (FChilds.FCount > 0) then
    Result := Get_Text
  else
    Result := FData
end;

procedure TbjXmlElement.Set_TypedValue(const aValue: Variant);
begin
  if Assigned(FChilds) then
    FChilds.Clear;
  FData := aValue;
end;

function TbjXmlElement.Get_DataType: Integer;
begin
  if (Assigned(FChilds) and (FChilds.FCount > 0)) or VarIsEmpty(FData)
  then begin
    {$IF Defined(Unicode)}
    Result := varUString;
    {$ELSEIF Defined(XML_WIDE_CHARS)}
    Result := varOleStr;
    {$ELSE}
    Result := varString;
    {$IFEND}
  end
  else
    Result := TVarData(FData).VType;
end;

//function TbjXmlElement.Get_ChildNodes: IbjXmlNodeList;
//begin
//  Result := inherited Get_ChildNodes;
//end;

procedure TbjXmlElement.SaveXML(aXMLSaver: TbjXmlSaver);
var
  aTag: TbjXmlString;
  aXMLIntend: TbjXmlString;
begin
  aTag := FNames.GetName(FNameID);
  if GetOwnerDocument.Get_PreserveWhiteSpace
  then begin
    if Assigned(FChilds) and (FChilds.FCount > 0)
    then begin
      aXMLSaver.Save('<' + aTag + GetAttrsXML + '>');
      FChilds.SaveXML(aXMLSaver);
      aXMLSaver.Save('</' + aTag + '>');
    end
    else
    if VarIsEmpty(FData)
    then
      aXMLSaver.Save('<' + aTag + GetAttrsXML + '/>')
    else begin
      aXMLSaver.Save('<' + aTag + GetAttrsXML + '>');
      aXMLSaver.Save(TextToXML(VarToXSTR(TVarData(FData))));
      aXMLSaver.Save('</' + aTag + '>');
    end;
  end
  else begin
    aXMLIntend := #13#10 + GetIndentStr(GeTbjXmlIntend);
    if Assigned(FChilds) and (FChilds.FCount > 0)
    then begin
      aXMLSaver.Save(aXMLIntend + '<' + aTag + GetAttrsXML + '>');
      FChilds.SaveXML(aXMLSaver);
      if (FChilds.FCount > 1) or (FChilds.FItems[0] is TbjXmlElement)
      then
        aXMLSaver.Save(aXMLIntend + '</' + aTag + '>')
      else
        aXMLSaver.Save('</' + aTag + '>');
    end
    else
    if VarIsEmpty(FData)
    then
      aXMLSaver.Save(aXMLIntend + '<' + aTag + GetAttrsXML + '/>')
    else begin
      aXMLSaver.Save(aXMLIntend + '<' + aTag + GetAttrsXML + '>');
      aXMLSaver.Save(TextToXML(VarToXSTR(TVarData(FData))));
      aXMLSaver.Save('</' + aTag + '>');
    end;
  end;
end;

procedure TbjXmlElement.SetNodeNameID(aValue: Integer);
begin
  FNameID := aValue
end;

function TbjXmlElement.DoCloneNode(aDeep: Boolean): IbjXml;
var
  aClone: TbjXmlElement;
  i: Integer;
begin
  aClone := TbjXmlElement.Create(FNames, FNameID);
  Result := aClone;
  aClone.FData := FData;
  SetLength(aClone.FAttrs, FAttrCount);
  aClone.FAttrCount := FAttrCount;
  for i := 0 to FAttrCount - 1 do
    aClone.FAttrs[i] := FAttrs[i];
  if aDeep and Assigned(FChilds) and (FChilds.FCount > 0) then
    for i := 0 to FChilds.FCount - 1 do
      aClone.AppendChild(FChilds.FItems[i].CloneNode(True));
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TbjXmlCharacterData Implementation'}{$ENDIF}

constructor TbjXmlCharacterData.Create(aNames: TbjXmlNameTable;
  const aData: TbjXmlString);
begin
  inherited CreateNode(aNames);
  FData := aData;
end;

function TbjXmlCharacterData.Get_Text: TbjXmlString;
begin
  if GetOwnerDocument.Get_PreserveWhiteSpace  
  then
    Result := FData
  else
    Result := Trim(FData);
end;

procedure TbjXmlCharacterData.Set_Text(const aValue: TbjXmlString);
begin
  FData := aValue
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TbjXmlText Implementation'}{$ENDIF}

function TbjXmlText.AsText: IbjXmlText;
begin
  Result := Self;
end;

constructor TbjXmlText.Create(aNames: TbjXmlNameTable; const aData: Variant);
begin
  inherited CreateNode(aNames);
  FData := aData;
end;

function TbjXmlText.DoCloneNode(aDeep: Boolean): IbjXml;
begin
  Result := TbjXmlText.Create(FNames, FData);
end;

function TbjXmlText.Get_DataType: Integer;
begin
  Result := TVarData(FData).VType
end;

function TbjXmlText.Get_NodeNameID: NativeInt;
begin
  Result := FNames.FXmlTextNameID
end;

function TbjXmlText.Get_Text: TbjXmlString;
begin
  if GetOwnerDocument.Get_PreserveWhiteSpace
  then
    Result := VarToXSTR(TVarData(FData))
  else
    Result := Trim(VarToXSTR(TVarData(FData)));
end;

function TbjXmlText.Get_TypedValue: Variant;
begin
  Result := FData
end;

function TbjXmlText.Get_XML: TbjXmlString;
begin
  Result := TextToXML(VarToXSTR(TVarData(FData)));
end;

procedure TbjXmlText.SaveXML(aXMLSaver: TbjXmlSaver);
begin
  aXMLSaver.Save(Get_XML);
end;

procedure TbjXmlText.Set_Text(const aValue: TbjXmlString);
begin
  FData := aValue
end;

procedure TbjXmlText.Set_TypedValue(const aValue: Variant);
begin
  FData := aValue
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TbjXmlCDATASection Implementation'}{$ENDIF}
function TbjXmlCDATASection.AsCDATASection: IbjXmlCDATASection;
begin
  Result := Self
end;

function TbjXmlCDATASection.DoCloneNode(aDeep: Boolean): IbjXml;
begin
  Result := TbjXmlCDATASection.Create(FNames, FData);
end;

function TbjXmlCDATASection.Get_NodeNameID: NativeInt;
begin
  Result := FNames.FXmlCDATASectionNameID
end;

function GenCDATAXML(const aValue: TbjXmlString): TbjXmlString;
var
  i: Integer;
begin
  i := Pos(']]>', aValue);
  if i = 0 then
    Result := '<![CDATA[' + aValue + ']]>'
  else
    Result := '<![CDATA[' + Copy(aValue, 1, i) + ']]>' + GenCDATAXML(Copy(aValue, i + 1, Length(aValue) - i - 1));
end;

function TbjXmlCDATASection.Get_XML: TbjXmlString;
begin
  Result := GenCDATAXML(FData); 
end;

procedure TbjXmlCDATASection.SaveXML(aXMLSaver: TbjXmlSaver);
begin
  aXMLSaver.Save(Get_XML);
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TbjXmlComment Implementation'}{$ENDIF}

function TbjXmlComment.AsComment: IbjXmlComment;
begin
  Result := Self
end;

function TbjXmlComment.DoCloneNode(aDeep: Boolean): IbjXml;
begin
  Result := TbjXmlComment.Create(FNames, FData);
end;

function TbjXmlComment.Get_NodeNameID: NativeInt;
begin
  Result := FNames.FXmlCommentNameID
end;

function TbjXmlComment.Get_XML: TbjXmlString;
begin
  Result := '<!--' + FData + '-->'
end;

procedure TbjXmlComment.SaveXML(aXMLSaver: TbjXmlSaver);
begin
  aXMLSaver.Save(Get_XML);
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TbjXml Implementation'}{$ENDIF}

constructor TbjXml.Create(aNames: TbjXmlNameTable);
begin
//  inherited;
   CreateNode(aNames);
  FPreserveWhiteSpace := DefaultPreserveWhiteSpace;
end;

function TbjXml.CreateCDATASection(
  const aData: TbjXmlString): IbjXmlCDATASection;
begin
  Result := TbjXmlCDATASection.Create(FNames, aData)
end;

function TbjXml.CreateComment(const aData: TbjXmlString): IbjXmlComment;
begin
  Result := TbjXmlComment.Create(FNames, aData) 
end;

function TbjXml.CreateElement(aNameID: NativeInt): IbjXmlElement;
begin
  Result := TbjXmlElement.Create(FNames, aNameID)
end;

function TbjXml.CreateElement(const aName: TbjXmlString): IbjXmlElement;
begin
  Result := TbjXmlElement.Create(FNames, FNames.GetID(aName));
end;

function TbjXml.CreateProcessingInstruction(const aTarget,
  aData: TbjXmlString): IbjXmlProcessingInstruction;
begin
  Result := TbjXmlProcessingInstruction.Create(FNames, FNames.GetID(aTarget), aData)
end;

function TbjXml.CreateProcessingInstruction(aTargetID: NativeInt;
  const aData: TbjXmlString): IbjXmlProcessingInstruction;
begin
  Result := TbjXmlProcessingInstruction.Create(FNames, aTargetID, aData)
end;

function TbjXml.CreateText(const aData: TbjXmlString): IbjXmlText;
begin
  Result := TbjXmlText.Create(FNames, aData)
end;

function TbjXml.DoCloneNode(aDeep: Boolean): IbjXml;
var
  aClone: TbjXml;
  i: Integer;
begin
  aClone := TbjXml.Create(FNames);
  Result := aClone;
  if aDeep and Assigned(FChilds) and (FChilds.FCount > 0) then
    for i := 0 to FChilds.FCount - 1 do
      aClone.AppendChild(FChilds.FItems[i].CloneNode(True));
end;

function TbjXml.Get_BinaryXML: RawByteString;
var
  aWriter: TStrXmlWriter;
begin
  aWriter := TStrXmlWriter.Create(0, $10000);
  try
    FNames.SaveBinXml(aWriter);
    SaveBinXml(aWriter);
    aWriter.FlushBuf;
    Result := aWriter.FData;
  finally
    aWriter.Free
  end
end;

function TbjXml.Get_DocumentElement: IbjXmlElement;
var
  aChilds: TbjXmlNodeList;
  aChild: TbjXml;
  i: Integer;
begin
  aChilds := Get_Childs;
  for i := 0 to aChilds.FCount - 1 do begin
    aChild := aChilds.FItems[i];
    if aChild.ClassType = TbjXmlElement then begin
      Result := TbjXmlElement(aChild);
      Exit
    end
  end;
  Result := nil;
end;

function TbjXml.Get_NodeNameID: NativeInt;
begin
  Result := FNames.FXmlDocumentNameID
end;

function TbjXml.Get_PreserveWhiteSpace: Boolean;
begin
  if Self<>nil
  then
    Result := FPreserveWhiteSpace
  else
    Result := DefaultPreserveWhiteSpace;
end;

function TbjXml.Get_Text: TbjXmlString;
var
  aChilds: TbjXmlNodeList;
  aChild: TbjXml;
  aChildText: TbjXmlString;
  i: Integer;
begin
  Result := '';
  aChilds := Get_Childs;
  for i := 0 to aChilds.FCount - 1 do begin
    aChild := aChilds.FItems[i];
    if  (aChild.ClassType=TbjXmlText) or (aChild.ClassType=TbjXmlCDATASection) //or (aChild.ClassType=TbjXmlElement)
    then begin
      aChildText := aChild.Get_Text;
      if aChildText <> ''
      then begin
        if Result = ''
        then
          Result := aChildText
        else
          Result := Result + ' ' + aChildText
      end;
    end
  end;
end;

function TbjXml.GetContent: TbjXmlString;
begin
//  if not Assigned(Self) then
//    Result := '';
  Result := Get_Text;
end;

function TbjXml.Get_XML: TbjXmlString;
begin
  Result := Get_Childs.Get_XML
end;

function TbjXml.GetXML: TbjXmlString;
begin
  Result := Get_XML;
end;

procedure TbjXml.Load(aStream: TStream);
var
  aXml: TbjXmlSource;
  aBinarySign: AnsiString;
  aReader: TBinXmlReader;
begin
  RemoveAllChilds;
  RemoveAllAttrs;
  if aStream.Size > BinXmlSignatureSize
  then begin
    SetLength(aBinarySign, BinXmlSignatureSize);
    aStream.ReadBuffer(Pointer(aBinarySign)^, BinXmlSignatureSize);
    if aBinarySign = BinXmlSignature
    then begin
      aReader := TStmXmlReader.Create(aStream, $10000);
      try
        FNames.LoadBinXml(aReader);
        LoadBinXml(aReader);
      finally
        aReader.Free
      end;
      Exit;
    end;
    aStream.Position := aStream.Position - BinXmlSignatureSize;
  end;
  aXml := TbjXmlSource.Create(aStream);
  try
    Get_Childs.ParseXML(aXml, FNames, FPreserveWhiteSpace);
  finally
    aXml.Free
  end
end;

procedure TbjXml.LoadUTF(aStream: TStream);
var
  L: integer;
  axmlStr: string;
  astr: PChar;
begin
    l := aStream.Size;
    SetString(axmlStr, nil, l);
    aStream.Seek(0,0);
    aStream.Read(aStr,l);
    UnicodeToUtf8(PChar(axmlStr), PWideChar(aStr),l+1);
    l := Trunc((l+1)/2);
//    SetLength(axmlStr, l);
//    axmlStr := copy(axmlStr,4,length(axmlStr)-3 );
    axmlStr := copy(axmlStr,4,l-3 );
    LoadXML(axmlStr);
end;

procedure TbjXml.LoadXMLFile(const aFileName: String);
var
  aFile: TFileStream;
begin
  aFile := TFileStream.Create(aFileName, fmOpenRead or fmShareDenyWrite);
  try
    Load(aFile);
  finally
    aFile.Free
  end
end;

procedure TbjXml.LoadUTF16XMLFile(const aFileName: String);
var
  aFile: TMemoryStream;
  L: integer;
  axmlStr: string;
begin
  aFile := TMemoryStream.Create;
  try
    aFile.LoadFromFile(aFileName);
    l := aFile.Size;
    SetString(axmlStr, nil, l);
    UnicodeToUtf8(PChar(axmlStr), PWideChar(aFile.Memory),l+1);
    l := Trunc((l+1)/2);
//    SetLength(axmlStr, l);
//    axmlStr := copy(axmlStr,4,length(axmlStr)-3 );
    axmlStr := copy(axmlStr,4,l-3 );
    LoadXML(axmlStr);
  finally
    aFile.Free
  end
end;

procedure TbjXml.LoadBinaryXML(const aXML: RawByteString);
var
  aReader: TStrXmlReader;
begin
  RemoveAllChilds;
  RemoveAllAttrs;
  aReader := TStrXmlReader.Create(aXML);
  try
    FNames.LoadBinXml(aReader);
    LoadBinXml(aReader);
  finally
    aReader.Free
  end
end;

procedure TbjXml.LoadResource(aType, aName: PChar);
var
  aRSRC: HRSRC;
  aGlobal: HGLOBAL;
  aSize: DWORD;
  aPointer: Pointer;
  AStr: RawByteString;
begin
  aRSRC := FindResource(HInstance, aName, aType);
  if aRSRC <> 0 then begin
    aGlobal := Windows.LoadResource(HInstance, aRSRC);
    aSize := SizeofResource(HInstance, aRSRC);
    if (aGlobal <> 0) and (aSize <> 0) then begin
      aPointer := LockResource(aGlobal);
      if Assigned(aPointer) then begin
        SetLength(AStr, aSize);
        move(aPointer^, Pointer(AStr)^, aSize);
//        LoadXMLRB(AStr);
        LoadXML(AStr);
      end;
    end;
  end;
end;

procedure TbjXml.LoadXML(const aXML: RawByteString);
var
  aSource: TbjXmlSource;
begin
//  if Length(aXML) = 0 then
//    exit;
  if XmlIsInBinaryFormat(aXML)
  then begin
    LoadBinaryXML(aXML)
  end
  else begin
    RemoveAllChilds;
    RemoveAllAttrs;
    aSource := TbjXmlSource.Create(aXML);
    try
      Get_Childs.ParseXML(aSource, FNames, FPreserveWhiteSpace);
    finally
      aSource.Free
    end
  end
end;

procedure CopyWordToByteArray(s: PWord; d: PByte; Size: Integer);
begin
  while Size>0 do
  begin
    d^ := PByte(s)^;
    inc(s); inc(d); dec(Size);
  end;
end;

{$IF Defined(XML_WIDE_CHARS) or Defined(Unicode)}
procedure TbjXml.LoadXML(const aXML: TbjXmlString);
var
  aSource: TbjXmlSource;
  Temp: RawByteString;
begin
  if XmlIsInBinaryFormat(AnsiString(copy(aXml, 1, BinXmlSignatureSize)))
  then begin
    SetLength(Temp, Length(aXML));
    CopyWordToByteArray(Pointer(aXML), Pointer(Temp), Length(aXML));
    LoadBinaryXML(Temp);
  end
  else begin
    RemoveAllChilds;
    RemoveAllAttrs;
    aSource := TbjXmlSource.Create(AnsiToUTF8(aXML));
    try
      aSource.AutoCodepage := False;
      Get_Childs.ParseXML(aSource, FNames, FPreserveWhiteSpace);
    finally
      aSource.Free
    end
  end
end;
{$IFEND}


function TbjXml.NewDocument(const aVersion, anEncoding,
                                  aRootElementName: TbjXmlString): IbjXmlElement;
begin
  Result := NewDocument(aVersion, anEncoding, FNames.GetID(aRootElementName));
end;

function TbjXml.NewDocument(const aVersion, anEncoding: TbjXmlString;
                                  aRootElementNameID: NativeInt): IbjXmlElement;
var
  aChilds: TbjXmlNodeList;
  aNode: TbjXml;
  aValue: TbjXmlString;
begin
  aChilds := Get_Childs;
  aChilds.Clear;
  aNode := TbjXmlProcessingInstruction.Create(FNames, FNames.FXmlNameID, '');
  if aVersion = '' then
    aValue := '1.0'
  else
    aValue := aVersion;
  aNode.SetAttr('version', aValue);
  if anEncoding = '' then
    aValue := XMLEncodingData[0].Encoding
  else
    aValue := anEncoding;
  aNode.SetAttr(FNames.FEncodingNameId, aValue);
  aChilds.Insert(aNode, 0);
  aNode := TbjXmlElement.Create(FNames, aRootElementNameID);
  aChilds.Insert(aNode, 1);
  Result := TbjXmlElement(aNode);
end;

procedure TbjXml.Save(aStream: TStream);
var
  EncodingStr: TbjXmlString;
  aNode: TbjXml;
  XMLSaver: TbjXmlSaver;
begin
  XMLSaver := TbjXmlStmSaver.Create(aStream, 4096);
  try
    aNode := FindFirstChild(FNames.FXmlNameID);
    if aNode<>nil
    then begin
      EncodingStr := aNode.GetVarAttr(FNames.FEncodingNameId, '');
      if EncodingStr<>''
      then begin
        XMLSaver.FCodepage := FindCodepage(EncodingStr);
        if XMLSaver.FCodepage=0
        then
          raise Exception.CreateFmt(SSimpleXmlError26, [EncodingStr]);
      end;
    end;
    SaveXML(XMLSaver);
  finally
    XMLSaver.Free;
  end;
end;

procedure TbjXml.SaveXMLFile(const aFileName: String);
var
  aFile: TFileStream;
begin
  aFile := TFileStream.Create(aFileName, fmCreate or fmShareDenyWrite);
  try
    Save(aFile);
  finally
    aFile.Free
  end
end;

//procedure TbjXml.SaveXmlFile(const aFileName: String);
//begin
//  save(aFileName);
//end;

procedure TbjXml.SaveBinary(aStream: TStream; anOptions: LongWord);
var
  aWriter: TBinXmlWriter;
begin
  aWriter := TStmXmlWriter.Create(aStream, anOptions, 65536);
  try
    FNames.SaveBinXml(aWriter);
    SaveBinXml(aWriter);
  finally
    aWriter.Free
  end
end;

procedure TbjXml.SaveBinary(const aFileName: String; anOptions: LongWord);
var
  aFile: TFileStream;
begin
  aFile := TFileStream.Create(aFileName, fmCreate or fmShareDenyWrite);
  try
    SaveBinary(aFile, anOptions);
  finally
    aFile.Free
  end
end;

procedure TbjXml.SaveXML(aXMLSaver: TbjXmlSaver);
begin
  Get_Childs.SaveXML(aXMLSaver);
end;

procedure TbjXml.Set_PreserveWhiteSpace(aValue: Boolean);
begin
  FPreserveWhiteSpace := aValue;
end;

procedure TbjXml.Set_Text(const aText: TbjXmlString);
var
  aChilds: TbjXmlNodeList;
begin
  aChilds := Get_Childs;
  aChilds.Clear;
  aChilds.Insert(TbjXmlText.Create(FNames, aText), 0);
end;

procedure TbjXml.SetContent(const aText: TbjXmlString);
begin
  Set_Text(aText);
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TbjXmlProcessingInstruction Implementation'}{$ENDIF}

function TbjXmlProcessingInstruction.AsProcessingInstruction: IbjXmlProcessingInstruction;
begin
  Result := Self
end;

constructor TbjXmlProcessingInstruction.Create(aNames: TbjXmlNameTable;
  aTargetID: NativeInt; const aData: TbjXmlString);
begin
  inherited CreateNode(aNames);
  FTargetNameID := aTargetID;
  FData := aData;
end;

function TbjXmlProcessingInstruction.DoCloneNode(aDeep: Boolean): IbjXml;
begin
  Result := TbjXmlProcessingInstruction.Create(FNames, FTargetNameID, FData);
end;

function TbjXmlProcessingInstruction.Get_NodeNameID: NativeInt;
begin
  Result := FTargetNameID
end;

function TbjXmlProcessingInstruction.Get_Text: TbjXmlString;
begin
  Result := FData;
end;

function TbjXmlProcessingInstruction.Get_XML: TbjXmlString;
begin
  if FData = '' then
    Result := '<?' + FNames.GetName(FTargetNameID) + GetAttrsXML + '?>'
  else
    Result := '<?' + FNames.GetName(FTargetNameID) + ' ' + FData + '?>'
end;

procedure TbjXmlProcessingInstruction.SaveXML(aXMLSaver: TbjXmlSaver);
begin
  aXMLSaver.Save(Get_XML);
end;

procedure TbjXmlProcessingInstruction.SetNodeNameID(aValue: Integer);
begin
  FTargetNameID := aValue
end;

procedure TbjXmlProcessingInstruction.Set_Text(const aText: TbjXmlString);
begin
  FData := aText
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TbjXmlSource Implementation'}{$ENDIF}

procedure TbjXmlSource.NewToken;
begin
  Inc(FTokenStackTop);
  if FTokenStackTop < Length(FTokenStack) then begin
    FToken := FTokenStack[FTokenStackTop];
    FToken.Clear
  end
  else begin
    SetLength(FTokenStack, FTokenStackTop + 1);
    FToken := TbjXmlToken.Create;
    FTokenStack[FTokenStackTop] := FToken;
  end
end;

function TbjXmlSource.Next: Boolean;
  procedure FillBuffer;
  var
    TempSrc: array [0..SourceBufferSize-1] of AnsiChar;
    {$IF not Defined(XML_WIDE_CHARS) and not Defined(Unicode)}
    TempDest: array [0..SourceBufferSize-1] of WideChar;
    {$IFEND}
    Size: Integer;
    P: PByte;
  begin
    if FCodePage=0
    then begin
      FBufSize := FStream.Read(TempSrc, 1);
      FBuffer^ := TbjXmlChar(TempSrc[0]);
    end
    else begin
      if FRemainSize>0
      then begin
        move(FRemainBuff, TempSrc, FRemainSize);
        P := @TempSrc;
        inc(P, FRemainSize);
        Size := FStream.Read(P^, SourceBufferSize - FRemainSize) + FRemainSize;
        FRemainSize := 0;
      end
      else
        Size := FStream.Read(TempSrc, SourceBufferSize);
      if Size>0
      then begin
        if FCodepage=CP_UTF8
        then begin
          P := @TempSrc; inc(P, Size);
          {$IF Defined(XML_WIDE_CHARS) or Defined(Unicode)}
          FBufSize := Utf8ToUnicode(FBuffer, SourceBufferSize, @TempSrc, Size);
          {$ELSE}
          FBufSize := Utf8ToUnicode(@TempDest, SourceBufferSize, @TempSrc, Size);
          {$IFEND}
          if (Size>0) and (Size<=SizeOf(FRemainBuff))
          then begin
            dec(P, Size);
            move(P^, FRemainBuff, Size);
            FRemainSize := Size;
          end;
        end
        else begin
          {$IF Defined(XML_WIDE_CHARS) or Defined(Unicode)}
          FBufSize := MultiByteToWideChar(FCodepage, 0, @TempSrc, Size, FBuffer, SourceBufferSize);
          {$ELSE}
          FBufSize := MultiByteToWideChar(FCodepage, 0, @TempSrc, Size, @TempDest, SourceBufferSize);
          {$IFEND}
        end;
      end;
      {$IF not Defined(XML_WIDE_CHARS) and not Defined(Unicode)}
      FBufSize := WideCharToMultiByte(CP_ACP, 0, @TempDest, FBufSize, FBuffer, SourceBufferSize, nil, nil);
      {$IFEND}
    end;
    if FBufSize=0
    then
      FBufSize := -1;
    FBufPtr := FBuffer;
  end;
begin
  Result := FBufSize>0;
  if Result
  then begin
    CurChar := FBufPtr^;
    dec(FBufSize);
    Inc(FBufPtr);
  end
  else
  if FBufSize=0
  then begin
    FillBuffer;
    Result := Next;
  end
  else begin
    CurChar := #0;
    Result := False;
  end;
end;

function TbjXmlSource.AcceptToken: TbjXmlString;
begin
  Result := FToken.Text;
  DropToken;
end;

procedure TbjXmlSource.SetCodepage(Codepage: Word);
begin
  FCodepage := Codepage;
end;

procedure TbjXmlSource.SkipBlanks;
begin
  while not EOF and (CurChar <= ' ') do
    Next;
end;

// на входе - первый символ имени
// на выходе - первый символ, который не является допустимым для имен
function TbjXmlSource.ExpecTbjXmlName: TbjXmlString;
begin
  if not NameCanBeginWith(CurChar) then
    raise Exception.Create(SSimpleXmlError11);
  NewToken;
  AppendTokenChar(CurChar);
  while Next and NameCanContain(CurChar) do
    AppendTokenChar(CurChar);
  Result := AcceptToken;
end;

// на входе - первый символ числа
// на выходе - первый символ, который не является допустимым для чисел
function TbjXmlSource.ExpectDecimalInteger: Integer;
var
  s: TbjXmlString;
  e: Integer;
begin
  NewToken;
  while (CurChar >= '0') and (CurChar <= '9') do begin
    AppendTokenChar(CurChar);
    Next;
  end;
  s := AcceptToken;
  if Length(s) = 0 then
    raise Exception.Create(SSimpleXmlError12);
  Val(s, Result, e);
end;

// на входе - первый символ числа
// на выходе - первый символ, который не является допустимым для
// щестнадцатиричных чисел
function TbjXmlSource.ExpectHexInteger: Integer;
var
  s: TbjXmlString;
  e: Integer;
begin
  NewToken;
  {$IFDEF XML_WIDE_CHARS}
  while (CurChar >= '0') and (CurChar <= '9') or
    (CurChar >= 'A') and (CurChar <= 'F') or
    (CurChar >= 'a') and (CurChar <= 'f') do begin
  {$ELSE}
  {$IFDEF Unicode}
  while CharInSet(CurChar, ['0'..'9', 'A'..'F', 'a'..'f']) do begin
  {$ELSE}
  while CurChar in ['0'..'9', 'A'..'F', 'a'..'f'] do begin
  {$ENDIF}
  {$ENDIF}
    AppendTokenChar(CurChar);
    Next;
  end;
  s := '$';
  s := s + AcceptToken;
  if Length(s) = 1 then
    raise Exception.Create(SSimpleXmlError13);
  Val(s, Result, e);
end;

// на входе: "&"
// на выходе: следующий за ";"
function TbjXmlSource.ExpecTbjXmlEntity: TbjXmlChar;
var
  s: TbjXmlString;
begin
  if not Next then
    raise Exception.Create(SSimpleXmlError14);
  if CurChar = '#' then begin
    if not Next then
      raise Exception.Create(SSimpleXmlError12);
    if CurChar = 'x' then begin
      Next;
      Result := TbjXmlChar(ExpectHexInteger);
    end
    else
      Result := TbjXmlChar(ExpectDecimalInteger);
    ExpectChar(';');
  end
  else begin
    s := ExpecTbjXmlName;
    ExpectChar(';');
    if s = 'amp' then
      Result := '&'
    else if s = 'quot' then
      Result := '"'
    else if s = 'lt' then
      Result := '<'
    else if s = 'gt' then
      Result := '>'
    else if s = 'apos' then
      Result := ''''
    else
      raise Exception.CreateFmt(SSimpleXmlError15, [s]);
  end
end;

function TbjXmlSource.EOF: Boolean;
begin
  Result := FBufSize<0;
end;

procedure TbjXmlSource.ExpectChar(aChar: TbjXmlChar);
begin
  if EOF or (CurChar <> aChar) then
    raise Exception.CreateFmt(SSimpleXmlError16, [aChar]);
  Next;
end;

procedure TbjXmlSource.ExpectText(aText: PbjXmlChar);
begin
  while aText^ <> #0 do begin
    if (CurChar <> aText^) or EOF then
      raise Exception.CreateFmt(SSimpleXmlError17, [aText]);
    Inc(aText);
    Next;
  end;
end;

// на входе: открывающая кавычка
// на выходе: символ, следующий за закрывающей кавычкой
function TbjXmlSource.ExpectQuotedText(aQuote: TbjXmlChar): TbjXmlString;
begin
  NewToken;
  Next;
  while not EOF and (CurChar <> aQuote) do begin
    if CurChar = '&' then
      AppendTokenChar(ExpecTbjXmlEntity)
    else if CurChar = '<' then
      raise Exception.Create(SSimpleXmlError18)
    else begin
      AppendTokenChar(CurChar);
      Next;
    end
  end;
  if EOF then
    raise Exception.CreateFmt(SSimpleXmlError19, [aQuote]);
  Next;
  Result := AcceptToken;
end;
 
procedure TbjXmlSource.ParseAttrs(aNode: TbjXml);
var
  aName: TbjXmlString;
  aValue: TbjXmlString;
begin
  SkipBlanks;
  while not EOF and NameCanBeginWith(CurChar) do begin
    aName := ExpecTbjXmlName;
    SkipBlanks;
    ExpectChar('=');
    SkipBlanks;
    if EOF then
      raise Exception.Create(SSimpleXmlError20);
    if (CurChar = '''') or (CurChar = '"') then
      aValue := ExpectQuotedText(CurChar)
    else
      raise Exception.Create(SSimpleXmlError21);
    aNode.SetAttr(aName, aValue);
    SkipBlanks;
  end;
end;

function StrEquals(p1, p2: PbjXmlChar; aLen: Integer): Boolean;
begin
  {$IFDEF XML_WIDE_CHARS}
  while aLen > 0 do
    if p1^ <> p2^ then begin
      Result := False;
      Exit
    end
    else if (p1^ = #0) or (p2^ = #0) then begin
      Result := p1^ = p2^;
      Exit
    end
    else begin
      Inc(p1);
      Inc(p2);
      Dec(aLen);
    end;
  Result := True;
  {$ELSE}
  Result := StrLComp(p1, p2, aLen) = 0
  {$ENDIF}
end;

// на входе: первый символ текста
// на выходе: символ, следующий за последним символом ограничителя
function TbjXmlSource.ParseTo(aText: PbjXmlChar): TbjXmlString;
var
  aCheck: PbjXmlChar;
  p: PbjXmlChar;
begin
  NewToken;
  aCheck := aText;
  while not EOF do begin
    if CurChar = aCheck^ then begin
      Inc(aCheck);
      Next;
      if aCheck^ = #0 then begin
        Result := AcceptToken;
        Exit;
      end;
    end
    else if aCheck = aText then begin
      AppendTokenChar(CurChar);
      Next;
    end
    else begin
      p := aText + 1;
      while (p < aCheck) and not StrEquals(p, aText, aCheck - p) do
        Inc(p);
      AppendTokenText(aText, p - aText);
      if p < aCheck then
        aCheck := p
      else
        aCheck := aText;
    end;
  end;
  raise Exception.CreateFmt(SSimpleXmlError22, [aText]);
end;

function CalcUTF8Len(c: AnsiChar): Integer;
begin
  if Byte(c) and $80=0
  then
    Result := 1
  else
  if Byte(c) and $E0=$C0
  then
    Result := 2
  else
  if Byte(c) and $F0=$E0
  then
    Result := 3
  else
  if Byte(c) and $F8=$F0
  then
    Result := 4
  else
    Result := 0;
end;

procedure TbjXmlSource.AppendTokenChar(aChar: TbjXmlChar);
begin
  FToken.AppendChar(aChar);
end;

procedure TbjXmlSource.AppendTokenText(aText: PbjXmlChar; aCount: Integer);
begin
  FToken.AppendText(aText, aCount)
end;

constructor TbjXmlSource.Create(aStream: TStream);
begin
  inherited Create;
  FStream := aStream;
  FTokenStackTop := -1;
  FCodepage := 0;
  AutoCodepage := True;  //Set Codepage according XML encoding property
  GetMem(FBuffer, SourceBufferSize*SizeOf(TbjXmlChar));
  FBufPtr := FBuffer;
  Next;
end;

constructor TbjXmlSource.Create(aString: RawByteString);
var
  aStream: TStream;
begin
  aStream := TMemoryStream.Create;
  aStream.WriteBuffer(Pointer(aString)^, Length(aString));
  aStream.Position := 0;
  FStreamOwner := True;
  Create(aStream);
end;

procedure TbjXmlSource.DropToken;
begin
  Dec(FTokenStackTop);
  if FTokenStackTop >= 0 then
    FToken := FTokenStack[FTokenStackTop]
  else
    FToken := nil
end;

destructor TbjXmlSource.Destroy;
var
  i: Integer;
begin
  for i := 0 to Length(FTokenStack) - 1 do
    FTokenStack[i].Free;
  FreeMem(FBuffer);
  if FStreamOwner
  then
    FStream.Free;
  inherited;
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TbjXmlToken Implementation'}{$ENDIF}

procedure TbjXmlToken.AppendChar(aChar: TbjXmlChar);
begin
  if FLength >= FSize
  then begin
    Inc(FSize);
    SetLength(FValueBuf, FSize);
  end;
  Inc(FLength);
  FValueBuf[FLength] := aChar;
end;

procedure TbjXmlToken.AppendText(aText: PbjXmlChar; aCount: Integer);
begin
  if FLength >= System.Length(FValueBuf) 
  then begin
    Inc(FSize, aCount);
    SetLength(FValueBuf, FSize);
  end;
  Move(aText^, FValueBuf[FLength+1], aCount*sizeof(TbjXmlChar));
  Inc(FLength, aCount);
end;

procedure TbjXmlToken.Clear;
begin
  FLength := 0;
end;

constructor TbjXmlToken.Create;
begin
  inherited Create;
  SetLength(FValueBuf, 32);
  FSize := 32;
end;

function TbjXmlToken.Text: TbjXmlString;
begin
  SetLength(Result, FLength);
  if FLength>0 
  then
    Move(Pointer(FValueBuf)^, Pointer(Result)^, FLength*sizeof(TbjXmlChar));
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TbjXmlSaver Implementation'}{$ENDIF}

constructor TbjXmlSaver.Create(aBufSize: Integer);
begin
  GetMem(FBuffer, aBufSize);
  FBufferPtr := FBuffer;
  FBuffersize := aBufSize;
  FRemain := aBufSize;
  FCodepage := CP_UTF8;
end;

destructor TbjXmlSaver.Destroy;
begin
  FlushBuffer;
  FreeMem(FBuffer);
  inherited;
end;

procedure TbjXmlSaver.SaveToBuffer(XmlStr: PbjXmlChar; L: Integer);
var
  P: Integer;
{$IF not Defined(XML_WIDE_CHARS) and not Defined(Unicode)}
  Temp: PWideChar;
{$IFEND}
begin
  if L>(FRemain div 3)
  then
    FlushBuffer;
  P := FBuffersize div 3;
  if L>P
  then begin
    while L>P do
    begin
      SaveToBuffer(XmlStr, P);
      FlushBuffer;
      dec(L, P);
      inc(XmlStr, P);
    end;
  end
  else
  if (L<>0)
  then begin
    {$IF not Defined(XML_WIDE_CHARS) and not Defined(Unicode)}
    GetMem(Temp, L*SizeOf(WideChar));
    try
      L := MultiByteToWideChar(CP_ACP, 0, XmlStr, L, Temp, L);
      L := WideCharToMultiByte(FCodepage, 0, Temp, L, FBufferPtr, FRemain, nil, nil);
    finally
      FreeMem(Temp);
    end;
    {$ELSE}
    L := WideCharToMultiByte(FCodepage, 0, XmlStr, L, FBufferPtr, FRemain, nil, nil);
    {$IFEND}
    inc(FBufferPtr, L);
    dec(FRemain, L);
  end;
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'TbjXmlStmSaver Implementation'}{$ENDIF}

constructor TbjXmlStmSaver.Create(aStream: TStream; aBufSize: Integer);
begin
  inherited Create(aBufSize);
  FStream := aStream;
end;

procedure TbjXmlStmSaver.FlushBuffer;
begin
  if FRemain<FBuffersize
  then begin
    FStream.WriteBuffer(FBuffer^, FBuffersize-FRemain);
    FBufferPtr := FBuffer;
    FRemain := FBuffersize;
  end;
end;

procedure TbjXmlStmSaver.Save(const XmlStr: TbjXmlString);
begin
  SaveToBuffer(Pointer(XmlStr), Length(XmlStr));
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Binary Reader Implementation'}{$ENDIF}
{ TStmXmlReader }

constructor TStmXmlReader.Create(aStream: TStream; aBufSize: Integer);
begin
  inherited Create;
  FStream := aStream;
  FRemainSize := aStream.Size - aStream.Position;
  FBufSize := aBufSize;
  GetMem(FBufStart, aBufSize);
  Read(FOptions, sizeof(FOptions));
end;

destructor TStmXmlReader.Destroy;
begin
  FreeMem(FBufStart);
  inherited;
end;

procedure TStmXmlReader.Read(var aBuf; aSize: Integer);
var
  aDst: PAnsiChar;
begin
  if aSize > FRemainSize then
    raise Exception.Create(SSimpleXmlError23);

  if aSize <= FBufRemain
  then begin
    Move(FBufPtr^, aBuf, aSize);
    Inc(Integer(FBufPtr), aSize);
    Dec(FRemainSize, aSize);
    Dec(FBufRemain, aSize);
  end
  else begin
    aDst := @aBuf;
    Move(FBufPtr^, aDst^, FBufRemain);
    Inc(aDst, FBufRemain);
    FStream.ReadBuffer(aDst^, aSize - FBufRemain);
    Dec(FRemainSize, aSize);

    if FRemainSize < FBufSize
    then
      FBufRemain := FRemainSize
    else
      FBufRemain := FBufSize;
    FBufPtr := FBufStart;
    if FBufRemain > 0
    then
      FStream.ReadBuffer(FBufStart^, FBufRemain);
  end;
end;

{ TStrXmlReader }

constructor TStrXmlReader.Create(const aData: RawByteString);
var
  aSig: array [1..BinXmlSignatureSize] of AnsiChar;
begin
  inherited Create;
  FData := aData;
  FRemain := Length(aData);
  FPtr := Pointer(FData);
  Read(aSig, BinXmlSignatureSize);
  Read(FOptions, sizeof(FOptions));
end;

procedure TStrXmlReader.Read(var aBuf; aSize: Integer);
begin
  if aSize > FRemain then
    raise Exception.Create(SSimpleXmlError23);
  Move(FPtr^, aBuf, aSize);
  Inc(Integer(FPtr), aSize);
  Dec(FRemain, aSize);
end;

{ TBinXmlReader }

function TBinXmlReader.ReadAnsiString: String;
var
  aLength: LongInt;
  Temp: RawByteString;
begin
  aLength := ReadLongint;
  if aLength = 0 then
    Result := ''
  else begin
    SetLength(Temp, aLength);
    Read(Pointer(Temp)^, aLength);
    Result := UTF8ToAnsi(Temp);
  end
end;

function TBinXmlReader.ReadLongint: Longint;
var
  b: Byte;
begin
  Result := 0;
  Read(Result, 1);
  if Result >= $80 then
    if Result = $FF then
      Read(Result, sizeof(Result))
    else begin
      Read(b, 1);
      Result := (Result and $7F) shl 8 or b;
    end
end;

procedure TBinXmlReader.ReadVariant(var v: TVarData);
var
  aDataType: Word;
  aSize: Longint;
  p: Pointer;
begin
  VarClear(Variant(v));
  aDataType := ReadLongint;
  case aDataType of
    varEmpty: ;
    varNull: ;
    varSmallint:
      Read(v.VSmallint, sizeof(SmallInt));
    varInteger:
      Read(v.VInteger, sizeof(Integer));
    varSingle:
      Read(v.VSingle, sizeof(Single));
    varDouble:
      Read(v.VDouble, sizeof(Double));
    varCurrency:
      Read(v.VCurrency, sizeof(Currency));
    varDate:
      Read(v.VDate, sizeof(TDateTime));
    varOleStr:
      Variant(v) := ReadWideString;
    varBoolean:
      Read(v.VBoolean, sizeof(WordBool));
    varShortInt:
      Read(v.VShortInt, sizeof(ShortInt));
    varByte:
      Read(v.VByte, sizeof(Byte));
    varWord:
      Read(v.VWord, sizeof(Word));
    varLongWord:
      Read(v.VLongWord, sizeof(LongWord));
    varInt64:
      Read(v.VInt64, sizeof(Int64));
    varString:
      Variant(v) := ReadAnsiString;
    {$IFDEF Unicode}
    varUString: 
      Variant(v) := ReadAnsiString;
    {$ENDIF}
    varArray + varByte:
      begin
        aSize := ReadLongint;
        Variant(v) := VarArrayCreate([0, aSize - 1], varByte);
        p := VarArrayLock(Variant(v));
        try
          Read(p^, aSize);
        finally
          VarArrayUnlock(Variant(v))
        end
      end;
    else
      raise Exception.Create(SSimpleXmlError24);
  end;
  v.VType := aDataType;
end;

function TBinXmlReader.ReadWideString: WideString;
var
  aLength: LongInt;
begin
  aLength := ReadLongint;
  if aLength = 0 then
    Result := ''
  else begin
    SetLength(Result, aLength);
    Read(Pointer(Result)^, aLength*sizeof(WideChar));
  end
end;

function TBinXmlReader.ReadXmlString: TbjXmlString;
begin
  if (FOptions and BINXML_USE_WIDE_CHARS) <> 0 then
    Result := ReadWideString
  else
    Result := TbjXmlString(ReadAnsiString)
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Binary Writer Implementation'}{$ENDIF}
{ TStmXmlWriter }

constructor TStmXmlWriter.Create(aStream: TStream; anOptions: LongWord;
                                 aBufSize: Integer);
begin
  inherited Create;
  FStream := aStream;
  FOptions := anOptions;
  FBufSize := aBufSize;
  FRemain := aBufSize;
  GetMem(FBufStart, aBufSize);
  FBufPtr := FBufStart;
  Write(Pointer(BinXmlSignature)^, BinXmlSignatureSize);
  Write(FOptions, sizeof(FOptions));
end;

destructor TStmXmlWriter.Destroy;
begin
  if Cardinal(FBufPtr) > Cardinal(FBufStart) then
    FStream.WriteBuffer(FBufStart^, Integer(FBufPtr) - Integer(FBufStart));
  FreeMem(FBufStart);
  inherited;
end;

procedure TStmXmlWriter.Write(const aBuf; aSize: Integer);
begin
  if aSize <= FRemain
  then begin
    Move(aBuf, FBufPtr^, aSize);
    Inc(FBufPtr, aSize);
    Dec(FRemain, aSize);
  end
  else begin
    if FRemain < FBufSize
    then begin
      FStream.WriteBuffer(FBufStart^, FBufSize-FRemain);
      FBufPtr := FBufStart;
      FRemain := FBufSize;
    end;
    FStream.WriteBuffer(aBuf, aSize);
  end
end;

{ TStrXmlWriter }

constructor TStrXmlWriter.Create(anOptions: LongWord; aBufSize: Integer);
begin
  inherited Create;
  SetLength(FData, aBufSize);
  FRemain := aBufSize;
  FOptions := anOptions;
  FBufPtr := Pointer(FData);
  Write(Pointer(BinXmlSignature)^, BinXmlSignatureSize);
  Write(FOptions, sizeof(FOptions));
end;

procedure TStrXmlWriter.FlushBuf;
begin
  if FRemain>0
  then
    SetLength(FData, Length(FData)-FRemain);
end;

procedure TStrXmlWriter.Write(const aBuf; aSize: Integer);
begin
  if aSize <= FRemain
  then begin
    Move(aBuf, FBufPtr^, aSize);
    Inc(Integer(FBufPtr), aSize);
    Dec(FRemain, aSize);
  end
  else begin
    SetLength(FData, Length(FData) + FBufSize + aSize);
    Move(aBuf, FBufPtr^, aSize);
    Inc(Integer(FBufPtr), aSize);
    FRemain := FBufSize;
  end
end;

{ TBinXmlWriter }

procedure TBinXmlWriter.WriteAnsiString(const aValue: String);
var
  Temp: RawByteString;
begin
  if Length(aValue) > 0 
  then begin
    Temp := AnsiToUTF8(aValue);
    WriteLongint(Length(Temp));
    Write(Pointer(Temp)^, Length(Temp));
  end
  else
    WriteLongint(0);
end;

procedure TBinXmlWriter.WriteLongint(aValue: Longint);
var
  b: array [0..1] of Byte;
begin
  if aValue < 0 then begin
    b[0] := $FF;
    Write(b[0], 1);
    Write(aValue, SizeOf(aValue));
  end
  else if aValue < $80 then
    Write(aValue, 1)
  else if aValue <= $7FFF then begin
    b[0] := (aValue shr 8) or $80;
    b[1] := aValue and $FF;
    Write(b, 2);
  end
  else begin
    b[0] := $FF;
    Write(b[0], 1);
    Write(aValue, SizeOf(aValue));
  end;
end;

procedure TBinXmlWriter.WriteVariant(const v: TVarData);
var
  aSize: Integer;
  p: Pointer;
begin
  WriteLongint(v.VType);
  case v.VType of
    varEmpty: ;
    varNull: ;
    varSmallint:
      Write(v.VSmallint, sizeof(SmallInt));
    varInteger:
      Write(v.VInteger, sizeof(Integer));
    varSingle:
      Write(v.VSingle, sizeof(Single));
    varDouble:
      Write(v.VDouble, sizeof(Double));
    varCurrency:
      Write(v.VCurrency, sizeof(Currency));
    varDate:
      Write(v.VDate, sizeof(TDateTime));
    varOleStr:
      WriteWideString(Variant(v));
    varBoolean:
      Write(v.VBoolean, sizeof(WordBool));
    varShortInt:
      Write(v.VShortInt, sizeof(ShortInt));
    varByte:
      Write(v.VByte, sizeof(Byte));
    varWord:
      Write(v.VWord, sizeof(Word));
    varLongWord:
      Write(v.VLongWord, sizeof(LongWord));
    varInt64:
      Write(v.VInt64, sizeof(Int64));
    varString:
      WriteAnsiString(String(AnsiString(v.VString)));
    {$IFDEF Unicode}
    varUString: 
      WriteAnsiString(String(v.VUString));
    {$ENDIF}
    varArray + varByte:
      begin
        aSize := VarArrayHighBound(Variant(v), 1) - VarArrayLowBound(Variant(v), 1) + 1;
        WriteLongint(aSize);
        p := VarArrayLock(Variant(v));
        try
          Write(p^, aSize);
        finally
          VarArrayUnlock(Variant(v))
        end
      end;
    else
      raise Exception.Create(SSimpleXmlError25);
  end;
end;

procedure TBinXmlWriter.WriteWideString(const aValue: WideString);
var
  aLength: LongInt;
begin
  aLength := Length(aValue);
  WriteLongint(aLength);
  if aLength > 0 then
    Write(Pointer(aValue)^, aLength*sizeof(WideChar));
end;


procedure TBinXmlWriter.WriteXmlString(const aValue: TbjXmlString);
begin
  if (FOptions and BINXML_USE_WIDE_CHARS) <> 0 then
    WriteWideString(aValue)
  else
    WriteAnsiString(aValue)
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}
{$IFDEF Regions}{$REGION 'Document Creation Function Implementation'}{$ENDIF}

function CreateXmlElement(const aName: TbjXmlString; const aNameTable: IbjXmlNameTable): IbjXmlElement;
var
  aNameTableImpl: TbjXmlNameTable;
begin
  if Assigned(aNameTable) then
    aNameTableImpl := aNameTable.GetObject as TbjXmlNameTable
  else
    aNameTableImpl := TbjXmlNameTable.Create(DefaultHashSize);
  Result := TbjXmlElement.Create(aNameTableImpl, aNameTableImpl.GetID(aName));
end;

function CreateXmlDocument(const aRootElementName: String;
                           const aVersion: String;
                           const anEncoding: String;
                           const aNameTable: IbjXmlNameTable): IbjXml;
var
  aNameTableImpl: TbjXmlNameTable;
begin
  if Assigned(aNameTable)
  then
    aNameTableImpl := aNameTable.GetObject as TbjXmlNameTable
  else
    aNameTableImpl := nil;
  Result := TbjXml.CreateNode(aNameTableImpl);
  if aRootElementName <> '' then
    Result.NewDocument(aVersion, anEncoding, aRootElementName);
end;

function LoadXmlDocumentFromXML(const aXML: RawByteString): IbjXml;
begin
  Result := TbjXml.Create;
  Result.LoadXML(aXML);
end;

function LoadXmlDocumentFromBinaryXML(const aXML: RawByteString): IbjXml;
begin
  Result := TbjXml.Create;
  Result.LoadBinaryXML(aXML);
end;

function LoadXmlDocument(aStream: TStream): IbjXml;
begin
  Result := TbjXml.Create;
  Result.Load(aStream);
end;

function LoadXmlDocument(const aFileName: String): IbjXml; overload;
begin
  Result := TbjXml.Create;
  Result.LoadXMLFile(aFileName);
end;

function LoadXmlDocument(aResType, aResName: PChar): IbjXml; overload;
begin
  Result := TbjXml.Create;
  Result.LoadResource(aResType, aResName);
end;
{$IFDEF Regions}{$ENDREGION}{$ENDIF}


function TbjXml.SearchForTag(const fromwhere: IbjXml; const aName: TbjXmlString): IbjXml;
// Find the first node which has name NodeName. Contrary to the NodeByName
// function, this function will search the whole subnode tree, using the
// DepthFirst method.
var
aNode: IbjXml;
isfromroot: boolean;
begin
  aNode := IbjXml(self);
  if assigned(fromwhere) then
  isfromroot := False
  else
  isfromroot := True;
  Result := RSearchForTag(aNode, fromwhere, aName, isfromroot);
//aNode._Release;
//  mynode.Get_ownerdocument;
end;

function RSearchForTag(aNode: IbjXml; const fromwhere: IbjXml;
                       const aName: TbjXmlString; var found: boolean): IbjXml;
// Find the first node which has name NodeName. Contrary to the NodeByName
// function, this function will search the whole subnode tree, using the
// DepthFirst method.
var
  i: integer;
  aChilds: TbjXmlNodeList;
  aNameID: NativeInt;
begin
  aChilds := aNode.GetChilds;
  aNameID := (aNode.GetObject as TbjXml).FNames.GetID(aName);
//  aNameID := aNode.NameTable.GetID(aName);
  Result := nil;
// Loop through all subnodes
  for i := 0 to aChilds.FCount - 1 do
  begin
    aNode := aChilds.Get_Item(i);
    if not found then
      if aNode = fromwhere then
        found := True;
    if found then
//    if mynode.NodeName = NodeName then
      if aNode.Get_NodeNameID = aNameID then
//    if aNode.Tag = aName then
        if  aNode <> fromwhere then
        begin
          Result := aNode;
          exit;
        end;
//    aNode._Release;
// If not, we will search the subtree of this node
    aNode := RSearchForTag(aNode, fromwhere, aName, found);
    if assigned(aNode) then
      begin
        Result := aNode;
        exit;
    end;
  end;
end;

function TbjXml.GoToTag(const aName: TbjXmlString): IbjXml;
// Find the first node which has name NodeName. Contrary to the NodeByName
// function, this function will search the whole subnode tree, using the
// DepthFirst method.
var
  aNode: IbjXml;
  Done: boolean;
  aNameID: NativeInt;
begin
  Done := False;
  aNode := IbjXml(self);
  Result := RGoToTag(aNode, aName);
  aNameID := Get_NameTable.GetID(aName);
  while not done do
  begin
    if Assigned(Result) then
      exit;
    if not Assigned(Result) then
    begin
      aNode := RHopNode(aNode, aName);
      if aNode.Get_NodeNameID = aNameID then
      begin
        Result := aNode;
        exit;
      end;
      if not Assigned(aNode) then
      begin
        Done := True;
        continue;
      end;
    end;
    Result := RGoToTag(aNode, aName);
  end;
end;

function RGoToTag(aNode: IbjXml; const aName: TbjXmlString): IbjXml;
var
  i: integer;
  aChilds: TbjXmlNodeList;
  aNameID: NativeInt;
begin
  aChilds := aNode.GetChilds;
//  aNameID := Get_NameTable.GetID(aName);
  aNameID := (aNode.GetObject as TbjXml).FNames.GetID(aName);
  Result := nil;
// Loop through all subnodes
  for i := 0 to aChilds.FCount - 1 do
  begin
    Result := aChilds.Get_Item(i);
//    if mynode.NodeName = NodeName then
    if Result.Get_NodeNameID = aNameID then
      exit;
// If not, we will search the subtree of this node
    Result := RGoToTag(Result, aName);
    if assigned(Result) then
      exit;
  end;
end;

function RHopNode(aNode: IbjXml; const aName: TbjXmlString): IbjXml;
var
  i: integer;
  aChilds: TbjXmlNodeList;
  checknode: IbjXml;
  Done: boolean;
begin
  Done := False;
  while not Done do
  begin
    CheckNode := aNode;
    aNode := aNode.GetParent;
    if aNode.Get_NodeName = '#document' then
      exit;
    aChilds := aNode.GetChilds;
    for i := 0 to aChilds.FCount - 1 do
      if aChilds.Get_Item(i) <> CheckNode then
         continue
       else
       if (aChilds.FCount-1 > i) then
       begin
         Result := aChilds.Get_Item(i+1);
         exit;
       end;
    aNode := Result.GetParent;
    if aNode.Get_NodeName = '#document' then
      exit;
//      ShowMessage(anode.Get_NodeName);
  end;
end;

function TbjXml.GetNumChildren: integer;
var
  aChilds: TbjXmlNodeList;
begin
  aChilds := GetChilds;
  Result := aChilds.FCount;
end;

function TbjXml.GetChild(const index: Integer): IbjXml;
var
  aChilds: TbjXmlNodeList;
  aNode: IbjXml;
begin
  Result := nil;
  aChilds := GetChilds;
  if achilds.FCount >= index then
  begin
    aNode := aChilds.Get_Item(index);
    if Assigned(aNode) then
    Result :=  aNode;
  end;
end;

//To be ested
function TbjXml.GetFirstChild: IbjXml;
var
  aChilds: TbjXmlNodeList;
//  aNode: IbjXml;
begin
  Result := nil;
  aChilds := GetChilds;
//if achilds.FCount >= 0 then
  if achilds.FCount > 0 then
  begin
//    aNode := aChilds.Get_Item(0);
//    if Assigned(aNode) then
//      Result :=  aNode;
      Result :=  aChilds.Get_Item(0);
  end;
end;

//To be ested
function TbjXml.GetLastChild: IbjXml;
var
  aChilds: TbjXmlNodeList;
//  aNode: IbjXml;
  cnt: integer;
begin
  Result := nil;
  aChilds := GetChilds;
  cnt := achilds.FCount;
  if cnt > 0 then
  begin
//    aNode := aChilds.Get_Item(cnt-1);
//    if Assigned(aNode) then
//      Result :=  aNode;
      Result :=  aChilds.Get_Item(cnt-1);
  end;
end;

function TbjXml.GetNextSibling: IbjXml;
var
  aChilds: TbjXmlNodeList;
  aNode, TempNode: IbjXml;
  aNameID: NativeInt;
  i, cnt: integer;
begin
  Result := nil;
  aNode := IbjXml(self);
  aNameID := Get_NameTable.GetID(aNode.GetTag);
  aChilds := GetParent.GetChilds;
  cnt := aChilds.FCount - 1;
  for i := 0 to  cnt do
  begin
    TempNode := aChilds.Get_Item(i);
    if TempNode.Get_NodeNameID = aNameID then
    begin
      if TempNode <> aNode then
        Continue;
      if i < cnt then
      begin
        Result := aChilds.Get_Item(i+1);
        exit;
      end;
    end;
  end;
end;

//To be ested
function TbjXml.GetPrevousSibling: IbjXml;
var
  aChilds: TbjXmlNodeList;
  aNode, TempNode: IbjXml;
  aNameID: NativeInt;
  i, cnt: integer;
begin
  Result := nil;
  aNode := IbjXml(self);
  aNameID := Get_NameTable.GetID(aNode.GetTag);
  aChilds := GetParent.GetChilds;
  cnt := aChilds.FCount - 1;
  for i := cnt downto  0 do
  begin
    TempNode := aChilds.Get_Item(i);
    if TempNode.Get_NodeNameID = aNameID then
    begin
      if TempNode <> aNode then
        Continue;
      if i < cnt then
      begin
        Result := aChilds.Get_Item(i-1);
        exit;
      end;
    end;
  end;
end;

end.



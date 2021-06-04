/// <summary>
/// 实现参考https://segmentfault.com/a/1190000004881457
/// </summary>

unit uArabicNumAndChineseNumInterchange;

interface

uses
  Generics.Collections;

const
  // 单个数字转换用数组
  chnNumChar: array[0..9] of string = ('零', '一', '二', '三', '四', '五', '六', '七', '八', '九');
  // 节权位数组
  chnUnitSection: array[0..4] of string = ('', '万', '亿', '万亿', '亿亿');
  // 节内权位数组
  chnUnitChar: array[0..3] of string = ('', '十', '百', '千');
  arabNumChar: array[0..9] of Integer = (0, 1, 2, 3, 4, 5, 6, 7, 8, 9);

type
  TChnNameValueRec = record
    value: Integer;
    secUnit: Boolean;
  end;

  pChnNameValueRec = ^TChnNameValueRec;

  TArabicNumAndChineseNumInterchange = class
  private
    FNumCharContrastDic: TDictionary<string, Integer>;
    FChnNameValueMap: TDictionary<string, pChnNameValueRec>;
    /// <summary>
    /// 节内转换算法
    /// </summary>
    function SectionToChinese(section: Integer): string;
    procedure InitFChnNameValueMap();
  public
    constructor Create();
    destructor Destroy; override;
    /// <summary>
    /// 阿拉伯数字转中文小写数字
    /// </summary>
    function ArabicNumToChineseNum(AArabicNum: Integer): string;

    /// <summary>
    /// 中文小写数字转阿拉伯数字
    /// </summary>
    function ChineseNumToArabicNum(const AChineseNum: string): Integer;
  end;

implementation

uses
  Math, Types, StrUtils;

{ TArabicNumAndChineseNumInterchange }

function TArabicNumAndChineseNumInterchange.ArabicNumToChineseNum(
  AArabicNum: Integer): string;
var
  strIns, chnStr: string;
  unitPos, section: Integer;
  needZero: Boolean;
begin
  Result := '';

  unitPos := 0;
  needZero := False;

  if AArabicNum = 0 then
    chnStr := chnNumChar[0];

  while (AArabicNum > 0) do
  begin
    section := AArabicNum mod 10000;
    if needZero then
      chnStr := chnNumChar[0] + chnStr;

    strIns := SectionToChinese(section);
    if section <> 0 then
      strIns := strIns + chnUnitSection[unitPos]
    else
      strIns := strIns + chnUnitSection[0];

    chnStr := strIns + chnStr;
    needZero := (section < 1000) and (section > 0);
    AArabicNum := Math.floor(AArabicNum / 10000);
    Inc(unitPos);
  end;

  Result := chnStr;

  // 处理十输出为一十问题
  if ((Copy(Result, 1, 1) = '一') and (Copy(Result, 2, 1) = '十')) then
    Result := Copy(Result, 2, Length(Result));
end;

function TArabicNumAndChineseNumInterchange.ChineseNumToArabicNum(
  const AChineseNum: string): Integer;
var
  I: Integer;
  rtn, section, number, num, iUnit: Integer;
  secUnit: Boolean;
  sChineseNum: string;
  aChnNameValueRec: pChnNameValueRec;
begin
  Result := 0;

  rtn := 0;
  section := 0;
  number := 0;
  secUnit := False;
  
  sChineseNum := AChineseNum;
  
  if Copy(sChineseNum, 1, 1) = '十' then
    sChineseNum := '一' + sChineseNum;

  for I := 1 to Length(sChineseNum) do
  begin
    if FNumCharContrastDic.ContainsKey(sChineseNum[I]) then
    begin
      num := FNumCharContrastDic.Items[sChineseNum[I]];
      number := num;
      if (I = Length(sChineseNum)) then
        section := section + number;
    end
    else
    begin
      aChnNameValueRec := FChnNameValueMap.Items[sChineseNum[I]];
      iUnit := aChnNameValueRec^.value;
      secUnit := aChnNameValueRec^.secUnit;
      if secUnit then
      begin
         section := (section + number) * iUnit;
         rtn := rtn + section;
         section := 0;
      end
      else
      begin
        section := section + (number * iUnit);
      end;
      number := 0;
    end;
  end;

  Result := rtn + section;
end;

constructor TArabicNumAndChineseNumInterchange.Create;
var
  I: Integer;
begin
  FNumCharContrastDic := TDictionary<string, Integer>.Create;
  FChnNameValueMap := TDictionary<string, pChnNameValueRec>.Create;

  for I := Low(chnNumChar) to High(chnNumChar) do
    FNumCharContrastDic.Add(chnNumChar[I], arabNumChar[I]);

  InitFChnNameValueMap();
end;

destructor TArabicNumAndChineseNumInterchange.Destroy;
var
  sKey: string;
begin
  for sKey in FChnNameValueMap.Keys do
  begin
    Dispose(FChnNameValueMap.Items[sKey]);
    FChnNameValueMap.Items[sKey] := nil;
  end;
  FChnNameValueMap.Clear;
  FChnNameValueMap.Free;
  FNumCharContrastDic.Clear;
  FNumCharContrastDic.Free;
  inherited;
end;

procedure TArabicNumAndChineseNumInterchange.InitFChnNameValueMap;
const
  chnNameKey: array[0..4] of string = ('十', '百', '千', '万', '亿');
  chnNameValue: array[0..4] of Integer = (10, 100, 1000, 10000, 100000000);
var
  I, iValue: Integer;
  aChnNameValueRec: pChnNameValueRec;
begin
  // 中文权位转换成10的位数及节权标志
  for I := Low(chnNameKey) to High(chnNameKey) do
  begin
    New(aChnNameValueRec);
    iValue := chnNameValue[I];
    aChnNameValueRec^.value := iValue;
    aChnNameValueRec^.secUnit := iValue >= 10000;
    FChnNameValueMap.Add(chnNameKey[I], aChnNameValueRec);
  end;
end;

function TArabicNumAndChineseNumInterchange.SectionToChinese(
  section: Integer): string;
var
  strIns, chnStr: string;
  unitPos, v: Integer;
  zero: Boolean;
begin
  Result := '';

  unitPos := 0;
  zero := True;

  while (section > 0) do
  begin
    v := section mod 10;
    if v = 0 then
    begin
      if not zero then
      begin
        zero := True;
        chnStr := chnNumChar[v] + chnStr;
      end
    end
    else
    begin
      zero := False;
      strIns := chnNumChar[v];
      strIns := strIns + chnUnitChar[unitPos];
      chnStr := strIns + chnStr;
    end;
    Inc(unitPos);
    section := Math.floor(section / 10);
  end;

  Result := chnStr;
end;

end.


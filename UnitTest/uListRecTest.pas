unit uListRecTest;

interface

{$DEFINE TEST_INTLIST}
{$DEFINE TEST_FLOATLIST}
{$DEFINE TEST_STRINGLIST}
{$DEFINE TEST_POINTERLIST}
{$DEFINE TEST_RECORDLIST}
{$DEFINE TEST_OBJECTLIST}

{$DEFINE TEST_RAPIDGENERICS}

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  WinAPI.Windows,
  {$IFDEF TEST_RAPIDGENERICS}
  Rapid.Generics,
  {$ELSE}
  System.Generics.Collections,
  System.Generics.Defaults,
  {$ENDIF}
  DUnitX.TestFramework,
  uTestTypes;

type
  // Basic test class to test records of different sizes
  TListTest<TRec> = class
  protected
    FList: TList<TRec>;
    procedure SaveToTextFile(const AFileName: string);
    // Each concrete test must provide these
    function CreateRecord(aIndex: Integer; aValue: Double): TRec; virtual; abstract;
    function GetComparerByIndex: IComparer<TRec>; virtual; abstract;
    function GetComparerByValue: IComparer<TRec>; virtual; abstract;
    procedure PopulateListRandom; virtual; abstract;
    function GetIndex(i: Integer): Integer; virtual; abstract;
    function GetValue(i: Integer): Double; virtual; abstract;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestAddRecord;
    [Test]
    procedure TestRemoveRecord;
    [Test]
    procedure TestRecordFieldsPreserved;
    [Test]
    procedure TestListCount;
    [Test]
    procedure TestClearList;
    [Test]
    procedure TestBinarySearch;
    [Test]
    procedure TestBinarySearchHuge;
    [Test]
    procedure TestSortDescending;
    [Test]
    procedure TestAddRange;
    [Test]
    procedure TestDeleteRange;
  end;

  T12ByteRecord = record
    Index: Integer;
    Value: Double;
  end;

  TListTest12ByteRecord = class(TListTest<T12ByteRecord>)
  protected
    function CreateRecord(aIndex: Integer; aValue: Double): T12ByteRecord; override;
    function GetComparerByIndex: IComparer<T12ByteRecord>; override;
    function GetComparerByValue: IComparer<T12ByteRecord>; override;
    procedure PopulateListRandom; override;
    function GetIndex(i: Integer): Integer; override;
    function GetValue(i: Integer): Double; override;
  end;

  T13ByteRecord = record
    Index: Integer;
    Value: Double;
    Filler: array[0..0] of byte;
  end;

  TListTest13ByteRecord = class(TListTest<T13ByteRecord>)
  protected
    function CreateRecord(aIndex: Integer; aValue: Double): T13ByteRecord; override;
    function GetComparerByIndex: IComparer<T13ByteRecord>; override;
    function GetComparerByValue: IComparer<T13ByteRecord>; override;
    procedure PopulateListRandom; override;
    function GetIndex(i: Integer): Integer; override;
    function GetValue(i: Integer): Double; override;
  end;

  T16ByteRecord = record
    Index: Integer;
    Value: Double;
    Filler: array[0..3] of byte;
  end;

  TListTest16ByteRecord = class(TListTest<T16ByteRecord>)
  protected
    function CreateRecord(aIndex: Integer; aValue: Double): T16ByteRecord; override;
    function GetComparerByIndex: IComparer<T16ByteRecord>; override;
    function GetComparerByValue: IComparer<T16ByteRecord>; override;
    procedure PopulateListRandom; override;
    function GetIndex(i: Integer): Integer; override;
    function GetValue(i: Integer): Double; override;
  end;

  T40ByteRecord = record
    Index: Integer;
    Value: Double;
    Filler: array[0..27] of byte;
  end;

  TListTest40ByteRecord = class(TListTest<T40ByteRecord>)
  protected
    function CreateRecord(aIndex: Integer; aValue: Double): T40ByteRecord; override;
    function GetComparerByIndex: IComparer<T40ByteRecord>; override;
    function GetComparerByValue: IComparer<T40ByteRecord>; override;
    procedure PopulateListRandom; override;
    function GetIndex(i: Integer): Integer; override;
    function GetValue(i: Integer): Double; override;
  end;

  T121ByteRecord = record
    Index: Integer;
    Value: Double;
    s: string;
    {$IFDEF CPUX64}
    Filler: array[0..100] of byte;
    {$ELSE}
    Filler: array[0..104] of byte;
    {$ENDIF}
  end;

  TListTest121ByteRecord = class(TListTest<T121ByteRecord>)
  protected
    function CreateRecord(aIndex: Integer; aValue: Double): T121ByteRecord; override;
    function GetComparerByIndex: IComparer<T121ByteRecord>; override;
    function GetComparerByValue: IComparer<T121ByteRecord>; override;
    procedure PopulateListRandom; override;
    function GetIndex(i: Integer): Integer; override;
    function GetValue(i: Integer): Double; override;
  end;

implementation

uses
  Variants,
  Math;

const
  Data: array[0..279] of record
    Index: Int64;
    Value: Double;
  end = (
    (Index: 0; Value: 0.001650),
    (Index: 1; Value: 1.001650),
    (Index: 2; Value: 2.001650),
    (Index: 3; Value: 4.001650),
    (Index: 4; Value: 3.001650),
    (Index: 5; Value: 2.001650),
    (Index: 6; Value: 2.001650),
    (Index: 7; Value: 2.001650),
    (Index: 8; Value: 2.001650),
    (Index: 9; Value: 2.001650),
    (Index: 10; Value: 2.001650),
    (Index: 11; Value: 2.001650),
    (Index: 12; Value: 2.001650),
    (Index: 13; Value: 2.001650),
    (Index: 14; Value: 2.001650),
    (Index: 15; Value: 2.001650),
    (Index: 16; Value: 2.001650),
    (Index: 17; Value: 2.001650),
    (Index: 18; Value: 57.952785),
    (Index: 19; Value: 58.027480),
    (Index: 20; Value: 57.562582),
    (Index: 21; Value: 57.506470),
    (Index: 22; Value: 2.001650),
    (Index: 23; Value: 58.134150),
    (Index: 24; Value: 57.380290),
    (Index: 25; Value: 57.790051),
    (Index: 26; Value: 2.001650),
    (Index: 27; Value: 2.001650),
    (Index: 28; Value: 2.001650),
    (Index: 29; Value: 2.001650),
    (Index: 30; Value: 2.001650),
    (Index: 31; Value: 57.924468),
    (Index: 32; Value: 57.894126),
    (Index: 33; Value: 2.001650),
    (Index: 34; Value: 2.001650),
    (Index: 35; Value: 2.001650),
    (Index: 36; Value: 2.001650),
    (Index: 37; Value: 2.001650),
    (Index: 38; Value: 2.001650),
    (Index: 39; Value: 57.861291),
    (Index: 40; Value: 2.001650),
    (Index: 41; Value: 2.001650),
    (Index: 42; Value: 2.001650),
    (Index: 43; Value: 2.001650),
    (Index: 44; Value: 2.001650),
    (Index: 45; Value: 2.001650),
    (Index: 46; Value: 2.001650),
    (Index: 47; Value: 2.001650),
    (Index: 48; Value: 2.001650),
    (Index: 49; Value: 2.001650),
    (Index: 50; Value: 2.001650),
    (Index: 51; Value: 2.001650),
    (Index: 52; Value: 2.001650),
    (Index: 53; Value: 2.001650),
    (Index: 54; Value: 2.001650),
    (Index: 55; Value: 2.001650),
    (Index: 56; Value: 2.001650),
    (Index: 57; Value: 2.001650),
    (Index: 58; Value: 2.001650),
    (Index: 59; Value: 2.001650),
    (Index: 60; Value: 2.001650),
    (Index: 61; Value: 2.001650),
    (Index: 62; Value: 2.001650),
    (Index: 63; Value: 2.001650),
    (Index: 64; Value: 2.001650),
    (Index: 65; Value: 2.001650),
    (Index: 66; Value: 2.001650),
    (Index: 67; Value: 2.001650),
    (Index: 68; Value: 2.001650),
    (Index: 69; Value: 2.001650),
    (Index: 70; Value: 2.001650),
    (Index: 71; Value: 57.229394),
    (Index: 72; Value: 57.308523),
    (Index: 73; Value: 2.001650),
    (Index: 74; Value: 2.001650),
    (Index: 75; Value: 58.844215),
    (Index: 76; Value: 2.001650),
    (Index: 77; Value: 2.001650),
    (Index: 78; Value: 56.776358),
    (Index: 79; Value: 2.001650),
    (Index: 80; Value: 57.750084),
    (Index: 81; Value: 2.001650),
    (Index: 82; Value: 58.835284),
    (Index: 83; Value: 2.001650),
    (Index: 84; Value: 58.830818),
    (Index: 85; Value: 2.001650),
    (Index: 86; Value: 57.141201),
    (Index: 87; Value: 2.001650),
    (Index: 88; Value: 58.844215),
    (Index: 89; Value: 58.848681),
    (Index: 90; Value: 58.857613),
    (Index: 91; Value: 58.857613),
    (Index: 92; Value: 58.963006),
    (Index: 93; Value: 58.839750),
    (Index: 94; Value: 58.839750),
    (Index: 95; Value: 58.839750),
    (Index: 96; Value: 58.963006),
    (Index: 97; Value: 2.001650),
    (Index: 98; Value: 56.922141),
    (Index: 99; Value: 58.214535),
    (Index: 100; Value: 56.571091),
    (Index: 101; Value: 58.049471),
    (Index: 102; Value: 58.830818),
    (Index: 103; Value: 58.848681),
    (Index: 104; Value: 2.001650),
    (Index: 105; Value: 58.268125),
    (Index: 106; Value: 58.087428),
    (Index: 107; Value: 58.068916),
    (Index: 108; Value: 57.826707),
    (Index: 109; Value: 57.614811),
    (Index: 110; Value: 58.174342),
    (Index: 111; Value: 58.227932),
    (Index: 112; Value: 58.254727),
    (Index: 113; Value: 58.004418),
    (Index: 114; Value: 58.201137),
    (Index: 115; Value: 58.187740),
    (Index: 116; Value: 58.281522),
    (Index: 117; Value: 2.001650),
    (Index: 118; Value: 57.707747),
    (Index: 119; Value: 57.662765),
    (Index: 120; Value: 57.445955),
    (Index: 121; Value: 58.147547),
    (Index: 122; Value: 58.294920),
    (Index: 123; Value: 2.001650),
    (Index: 124; Value: 2.001650),
    (Index: 125; Value: 58.104396),
    (Index: 126; Value: 2.001650),
    (Index: 127; Value: 57.979757),
    (Index: 128; Value: 2.001650),
    (Index: 129; Value: 57.040994),
    (Index: 130; Value: 2.001650),
    (Index: 131; Value: 2.001650),
    (Index: 132; Value: 58.119632),
    (Index: 133; Value: 58.348509),
    (Index: 134; Value: 58.388702),
    (Index: 135; Value: 2.001650),
    (Index: 136; Value: 58.160945),
    (Index: 137; Value: 58.241330),
    (Index: 138; Value: 58.321714),
    (Index: 139; Value: 58.482484),
    (Index: 140; Value: 58.495881),
    (Index: 141; Value: 58.428894),
    (Index: 142; Value: 58.308317),
    (Index: 143; Value: 58.402099),
    (Index: 144; Value: 58.683446),
    (Index: 145; Value: 58.375304),
    (Index: 146; Value: 58.361907),
    (Index: 147; Value: 58.656651),
    (Index: 148; Value: 58.335112),
    (Index: 149; Value: 58.643253),
    (Index: 150; Value: 58.469086),
    (Index: 151; Value: 58.455689),
    (Index: 152; Value: 58.603061),
    (Index: 153; Value: 58.415497),
    (Index: 154; Value: 58.522676),
    (Index: 155; Value: 58.589664),
    (Index: 156; Value: 59.152357),
    (Index: 157; Value: 58.549471),
    (Index: 158; Value: 58.576266),
    (Index: 159; Value: 58.562869),
    (Index: 160; Value: 58.710241),
    (Index: 161; Value: 58.750433),
    (Index: 162; Value: 58.629856),
    (Index: 163; Value: 59.232742),
    (Index: 164; Value: 59.741845),
    (Index: 165; Value: 59.380114),
    (Index: 166; Value: 58.509279),
    (Index: 167; Value: 58.670048),
    (Index: 168; Value: 58.442292),
    (Index: 169; Value: 58.723638),
    (Index: 170; Value: 58.763831),
    (Index: 171; Value: 58.911203),
    (Index: 172; Value: 59.125562),
    (Index: 173; Value: 58.536074),
    (Index: 174; Value: 58.616459),
    (Index: 175; Value: 58.777228),
    (Index: 176; Value: 58.817420),
    (Index: 177; Value: 58.857613),
    (Index: 178; Value: 58.844215),
    (Index: 179; Value: 58.830818),
    (Index: 180; Value: 58.871010),
    (Index: 181; Value: 58.804023),
    (Index: 182; Value: 58.897805),
    (Index: 183; Value: 58.884408),
    (Index: 184; Value: 58.924600),
    (Index: 185; Value: 58.964792),
    (Index: 186; Value: 58.951395),
    (Index: 187; Value: 59.018382),
    (Index: 188; Value: 58.978190),
    (Index: 189; Value: 59.071972),
    (Index: 190; Value: 59.004985),
    (Index: 191; Value: 58.937998),
    (Index: 192; Value: 59.098767),
    (Index: 193; Value: 58.737036),
    (Index: 194; Value: 59.112164),
    (Index: 195; Value: 58.991587),
    (Index: 196; Value: 59.031780),
    (Index: 197; Value: 59.179152),
    (Index: 198; Value: 58.790625),
    (Index: 199; Value: 59.045177),
    (Index: 200; Value: 59.085370),
    (Index: 201; Value: 59.058575),
    (Index: 202; Value: 59.219344),
    (Index: 203; Value: 59.339921),
    (Index: 204; Value: 59.326524),
    (Index: 205; Value: 58.696843),
    (Index: 206; Value: 59.138959),
    (Index: 207; Value: 59.701653),
    (Index: 208; Value: 59.192549),
    (Index: 209; Value: 59.259537),
    (Index: 210; Value: 59.433703),
    (Index: 211; Value: 59.527486),
    (Index: 212; Value: 59.246139),
    (Index: 213; Value: 59.313126),
    (Index: 214; Value: 59.487293),
    (Index: 215; Value: 59.366716),
    (Index: 216; Value: 59.286331),
    (Index: 217; Value: 59.393511),
    (Index: 218; Value: 59.540883),
    (Index: 219; Value: 59.473896),
    (Index: 220; Value: 59.299729),
    (Index: 221; Value: 2.001650),
    (Index: 222; Value: 59.205947),
    (Index: 223; Value: 2.001650),
    (Index: 224; Value: 59.406909),
    (Index: 225; Value: 59.500691),
    (Index: 226; Value: 59.648063),
    (Index: 227; Value: 59.621268),
    (Index: 228; Value: 2.001650),
    (Index: 229; Value: 2.001650),
    (Index: 230; Value: 2.001650),
    (Index: 231; Value: 59.581076),
    (Index: 232; Value: 59.514088),
    (Index: 233; Value: 2.001650),
    (Index: 234; Value: 2.001650),
    (Index: 235; Value: 59.420306),
    (Index: 236; Value: 59.447101),
    (Index: 237; Value: 59.607870),
    (Index: 238; Value: 59.460498),
    (Index: 239; Value: 59.353319),
    (Index: 240; Value: 59.916012),
    (Index: 241; Value: 59.688255),
    (Index: 242; Value: 59.768640),
    (Index: 243; Value: 59.956204),
    (Index: 244; Value: 59.755242),
    (Index: 245; Value: 59.715050),
    (Index: 246; Value: 59.594473),
    (Index: 247; Value: 59.795435),
    (Index: 248; Value: 59.728448),
    (Index: 249; Value: 59.661460),
    (Index: 250; Value: 59.862422),
    (Index: 251; Value: 59.634665),
    (Index: 252; Value: 59.782037),
    (Index: 253; Value: 59.822230),
    (Index: 254; Value: 59.942807),
    (Index: 255; Value: 59.902615),
    (Index: 256; Value: 59.889217),
    (Index: 257; Value: 59.554281),
    (Index: 258; Value: 59.272934),
    (Index: 259; Value: 59.567678),
    (Index: 260; Value: 59.165754),
    (Index: 261; Value: 59.929409),
    (Index: 262; Value: 58.834391),
    (Index: 263; Value: 58.848681),
    (Index: 264; Value: 59.835627),
    (Index: 265; Value: 59.875820),
    (Index: 266; Value: 59.964358),
    (Index: 267; Value: 59.849025),
    (Index: 268; Value: 59.674858),
    (Index: 269; Value: 58.830818),
    (Index: 270; Value: 59.808832),
    (Index: 271; Value: 58.857613),
    (Index: 272; Value: 58.832604),
    (Index: 273; Value: 58.963006),
    (Index: 274; Value: 58.836177),
    (Index: 275; Value: 58.830818),
    (Index: 276; Value: 58.839750),
    (Index: 277; Value: 58.839750),
    (Index: 278; Value: 58.839750),
    (Index: 279; Value: 58.837963)
  );

{ TListTest<TRec> }

procedure TListTest<TRec>.Setup;
begin
  FList := TList<TRec>.Create;
end;

procedure TListTest<TRec>.TearDown;
begin
  FreeAndNil(FList);
end;

procedure TListTest<TRec>.TestBinarySearch;
var
  Comparer: IComparer<TRec>;
  Index: Integer;
  Rec1, Rec2, Rec3, SearchRec: TRec;
begin
  Comparer := GetComparerByIndex;

  Rec1 := CreateRecord(1, 1.1);
  Rec2 := CreateRecord(3, 3.3);
  Rec3 := CreateRecord(2, 2.2);

  FList.AddRange([Rec1, Rec2, Rec3]);
  FList.Sort(Comparer);

  SearchRec := CreateRecord(2, 0);
  Assert.IsTrue(FList.BinarySearch(SearchRec, Index, Comparer));
  Assert.AreEqual(1, Index);

  SearchRec := CreateRecord(5, 0);
  Assert.IsFalse(FList.BinarySearch(SearchRec, Index, Comparer));
end;

procedure TListTest<TRec>.TestBinarySearchHuge;
var
  i: Integer;
  Comparer: IComparer<TRec>;
begin
  Comparer := GetComparerByValue;

  PopulateListRandom;

  FList.Sort(Comparer);

  for i := 0 to FList.Count - 2 do
    Assert.IsTrue(GetValue(i) <= GetValue(i + 1),
      Format('List not sorted at index %d: %f > %f', [i, GetValue(i), GetValue(i + 1)]));

  Assert.IsTrue(FList.BinarySearch(CreateRecord(0, 0.001650), i, Comparer),
    'Should find existing record');
  Assert.AreEqual(0, i, 'Index should be 0 for x=0.001650');

  Assert.IsTrue(FList.BinarySearch(CreateRecord(279, 59.964358), i, Comparer),
    'Should find existing record');
  Assert.AreEqual(279, i, 'Index should be 279 for x=59.964358');

  Assert.IsFalse(FList.BinarySearch(CreateRecord(0, 8), i, Comparer),
    'Should not find non-existing record');
end;

procedure TListTest<TRec>.TestSortDescending;
var
  i: Integer;
  Comparer: IComparer<TRec>;
begin
  Comparer := GetComparerByValue;

  PopulateListRandom;

  FList.SortDescending(Comparer);

  for i := 0 to FList.Count - 2 do
    Assert.IsTrue(GetValue(i) >= GetValue(i + 1),
      Format('List not sorted (descending) at index %d: %f > %f', [i, GetValue(i), GetValue(i + 1)]));
end;

procedure TListTest<TRec>.TestAddRecord;
var
  Rec: TRec;
begin
  Rec := CreateRecord(1, 1.1);
  FList.Add(Rec);
  Assert.AreEqual(1, FList.Count);
end;

procedure TListTest<TRec>.TestRemoveRecord;
var
  Rec1, Rec2: TRec;
begin
  Rec1 := CreateRecord(1, 1.1);
  Rec2 := CreateRecord(2, 2.2);
  FList.AddRange([Rec1, Rec2]);
  Assert.AreEqual(2, FList.Count);
  FList.Remove(Rec1);
  Assert.AreEqual(1, FList.Count);
end;

procedure TListTest<TRec>.TestRecordFieldsPreserved;
var
  Rec: TRec;
begin
  Rec := CreateRecord(1234, 5.67);
  FList.Add(Rec);
  Assert.AreEqual(1234, GetIndex(0));
  Assert.AreEqual(5.67, GetValue(0), 0.00001);
end;

procedure TListTest<TRec>.TestListCount;
begin
  Assert.AreEqual(0, FList.Count);
  FList.Add(CreateRecord(1, 1.1));
  Assert.AreEqual(1, FList.Count);
  FList.Add(CreateRecord(2, 2.2));
  Assert.AreEqual(2, FList.Count);
end;

procedure TListTest<TRec>.TestClearList;
begin
  FList.Add(CreateRecord(1, 1.1));
  FList.Add(CreateRecord(2, 2.2));
  Assert.AreEqual(2, FList.Count);
  FList.Clear;
  Assert.AreEqual(0, FList.Count);
end;

procedure TListTest<TRec>.TestAddRange;
var
  Rec1, Rec2: TRec;
begin
  Rec1 := CreateRecord(1, 1.1);
  Rec2 := CreateRecord(2, 2.2);
  FList.AddRange([Rec1, Rec2]);
  Assert.AreEqual(2, FList.Count);
end;

procedure TListTest<TRec>.TestDeleteRange;
var
  Rec1, Rec2, Rec3: TRec;
begin
  Rec1 := CreateRecord(1, 1.1);
  Rec2 := CreateRecord(2, 2.2);
  Rec3 := CreateRecord(3, 3.3);
  FList.AddRange([Rec1, Rec2, Rec3]);

  FList.DeleteRange(0, 2);

  Assert.AreEqual(1, FList.Count);
  Assert.AreEqual(3, GetIndex(0));
end;

procedure TListTest<TRec>.SaveToTextFile(const AFileName: string);
var
  SL: TStringList;
  I: Integer;
begin
  SL := TStringList.Create;
  try
    for I := 0 to FList.Count - 1 do
    begin
      SL.Add(Format('%d,%d,%.6f',  [I, GetIndex(I), GetValue(I)]));
    end;
    SL.SaveToFile(AFileName, TEncoding.UTF8);
  finally
    SL.Free;
  end;
end;

{ TListTest12ByteRecord }

function TListTest12ByteRecord.CreateRecord(aIndex: Integer; aValue: Double): T12ByteRecord;
var
  Rec: T12ByteRecord;
begin
  Rec.Index := aIndex;
  Rec.Value := aValue;

  Result := Rec;
end;

function TListTest12ByteRecord.GetComparerByIndex: IComparer<T12ByteRecord>;
begin
  Result := TComparer<T12ByteRecord>.Construct(
    function(const L, R: T12ByteRecord): Integer
    begin
      Result := CompareValue(L.Index, R.Index);
    end);
end;

function TListTest12ByteRecord.GetComparerByValue: IComparer<T12ByteRecord>;
begin
  Result := TComparer<T12ByteRecord>.Construct(
    function(const L, R: T12ByteRecord): Integer
    begin
      Result := CompareValue(L.Value, R.Value);
    end);
end;

function TListTest12ByteRecord.GetIndex(i: Integer): Integer;
begin
  Result := FList[i].Index;
end;

function TListTest12ByteRecord.GetValue(i: Integer): Double;
begin
  Result := FList[i].Value;
end;

procedure TListTest12ByteRecord.PopulateListRandom;
var
  Temp: TArray<T12ByteRecord>;
  i, j: Integer;
  R: T12ByteRecord;
begin
  SetLength(Temp, Length(Data));
  for i := 0 to High(Data) do
  begin
    Temp[i].Index := Data[i].Index;
    Temp[i].Value := Data[i].Value;
  end;

  Randomize;
  for i := High(Temp) downto 1 do
  begin
    j := Random(i + 1);
    R := Temp[i];
    Temp[i] := Temp[j];
    Temp[j] := R;
  end;

  FList.Clear;
  for i := 0 to High(Temp) do
    FList.Add(Temp[i]);
end;

{ TListTest13ByteRecord }

function TListTest13ByteRecord.CreateRecord(aIndex: Integer; aValue: Double): T13ByteRecord;
var
  Rec: T13ByteRecord;
begin
  Rec.Index := aIndex;
  Rec.Value := aValue;

  Result := Rec;
end;

function TListTest13ByteRecord.GetComparerByIndex: IComparer<T13ByteRecord>;
begin
  Result := TComparer<T13ByteRecord>.Construct(
    function(const L, R: T13ByteRecord): Integer
    begin
      Result := CompareValue(L.Index, R.Index);
    end);
end;

function TListTest13ByteRecord.GetComparerByValue: IComparer<T13ByteRecord>;
begin
  Result := TComparer<T13ByteRecord>.Construct(
    function(const L, R: T13ByteRecord): Integer
    begin
      Result := CompareValue(L.Value, R.Value);
    end);
end;

function TListTest13ByteRecord.GetIndex(i: Integer): Integer;
begin
  Result := FList[i].Index;
end;

function TListTest13ByteRecord.GetValue(i: Integer): Double;
begin
  Result := FList[i].Value;
end;

procedure TListTest13ByteRecord.PopulateListRandom;
var
  Temp: TArray<T13ByteRecord>;
  i, j: Integer;
  R: T13ByteRecord;
begin
  SetLength(Temp, Length(Data));
  for i := 0 to High(Data) do
  begin
    Temp[i].Index := Data[i].Index;
    Temp[i].Value := Data[i].Value;
  end;

  Randomize;
  for i := High(Temp) downto 1 do
  begin
    j := Random(i + 1);
    R := Temp[i];
    Temp[i] := Temp[j];
    Temp[j] := R;
  end;

  FList.Clear;
  for i := 0 to High(Temp) do
    FList.Add(Temp[i]);
end;

{ TListTest16ByteRecord }

function TListTest16ByteRecord.CreateRecord(aIndex: Integer; aValue: Double): T16ByteRecord;
var
  Rec: T16ByteRecord;
begin
  Rec.Index := aIndex;
  Rec.Value := aValue;

  Result := Rec;
end;

function TListTest16ByteRecord.GetComparerByIndex: IComparer<T16ByteRecord>;
begin
  Result := TComparer<T16ByteRecord>.Construct(
    function(const L, R: T16ByteRecord): Integer
    begin
      Result := CompareValue(L.Index, R.Index);
    end);
end;

function TListTest16ByteRecord.GetComparerByValue: IComparer<T16ByteRecord>;
begin
  Result := TComparer<T16ByteRecord>.Construct(
    function(const L, R: T16ByteRecord): Integer
    begin
      Result := CompareValue(L.Value, R.Value);
    end);
end;

function TListTest16ByteRecord.GetIndex(i: Integer): Integer;
begin
  Result := FList[i].Index;
end;

function TListTest16ByteRecord.GetValue(i: Integer): Double;
begin
  Result := FList[i].Value;
end;

procedure TListTest16ByteRecord.PopulateListRandom;
var
  Temp: TArray<T16ByteRecord>;
  i, j: Integer;
  R: T16ByteRecord;
begin
  SetLength(Temp, Length(Data));
  for i := 0 to High(Data) do
  begin
    Temp[i].Index := Data[i].Index;
    Temp[i].Value := Data[i].Value;
  end;

  Randomize;
  for i := High(Temp) downto 1 do
  begin
    j := Random(i + 1);
    R := Temp[i];
    Temp[i] := Temp[j];
    Temp[j] := R;
  end;

  FList.Clear;
  for i := 0 to High(Temp) do
    FList.Add(Temp[i]);
end;

{ TListTest40ByteRecord }

function TListTest40ByteRecord.CreateRecord(aIndex: Integer; aValue: Double): T40ByteRecord;
var
  Rec: T40ByteRecord;
begin
  Rec.Index := aIndex;
  Rec.Value := aValue;

  Result := Rec;
end;

procedure TListTest40ByteRecord.PopulateListRandom;
var
  Temp: TArray<T40ByteRecord>;
  i, j: Integer;
  R: T40ByteRecord;
begin
  SetLength(Temp, Length(Data));
  for i := 0 to High(Data) do
  begin
    Temp[i].Index := Data[i].Index;
    Temp[i].Value := Data[i].Value;
  end;

  Randomize;
  for i := High(Temp) downto 1 do
  begin
    j := Random(i + 1);
    R := Temp[i];
    Temp[i] := Temp[j];
    Temp[j] := R;
  end;

  FList.Clear;
  for i := 0 to High(Temp) do
    FList.Add(Temp[i]);
end;

function TListTest40ByteRecord.GetComparerByIndex: IComparer<T40ByteRecord>;
begin
  Result := TComparer<T40ByteRecord>.Construct(
    function(const L, R: T40ByteRecord): Integer
    begin
      Result := CompareValue(L.Index, R.Index);
    end);
end;

function TListTest40ByteRecord.GetComparerByValue: IComparer<T40ByteRecord>;
begin
  Result := TComparer<T40ByteRecord>.Construct(
    function(const L, R: T40ByteRecord): Integer
    begin
      Result := CompareValue(L.Value, R.Value);
    end);
end;

function TListTest40ByteRecord.GetIndex(i: Integer): Integer;
begin
  Result := FList[i].Index;
end;

function TListTest40ByteRecord.GetValue(i: Integer): Double;
begin
  Result := FList[i].Value;
end;

{ TListTest121ByteRecord }

function TListTest121ByteRecord.CreateRecord(aIndex: Integer; aValue: Double): T121ByteRecord;
var
  Rec: T121ByteRecord;
begin
  Rec.Index := aIndex;
  Rec.Value := aValue;
  Rec.s := 'String ' + IntToStr(aIndex);
  Result := Rec;
end;

procedure TListTest121ByteRecord.PopulateListRandom;
var
  Temp: TArray<T121ByteRecord>;
  i, j: Integer;
  R: T121ByteRecord;
begin
  SetLength(Temp, Length(Data));
  for i := 0 to High(Data) do
  begin
    Temp[i].Index := Data[i].Index;
    Temp[i].Value := Data[i].Value;
  end;

  Randomize;
  for i := High(Temp) downto 1 do
  begin
    j := Random(i + 1);
    R := Temp[i];
    Temp[i] := Temp[j];
    Temp[j] := R;
  end;

  FList.Clear;
  for i := 0 to High(Temp) do
    FList.Add(Temp[i]);
end;

function TListTest121ByteRecord.GetComparerByIndex: IComparer<T121ByteRecord>;
begin
  Result := TComparer<T121ByteRecord>.Construct(
    function(const L, R: T121ByteRecord): Integer
    begin
      Result := CompareValue(L.Index, R.Index);
    end);
end;

function TListTest121ByteRecord.GetComparerByValue: IComparer<T121ByteRecord>;
begin
  Result := TComparer<T121ByteRecord>.Construct(
    function(const L, R: T121ByteRecord): Integer
    begin
      Result := CompareValue(L.Value, R.Value);
    end);
end;

function TListTest121ByteRecord.GetIndex(i: Integer): Integer;
begin
  Result := FList[i].Index;
end;

function TListTest121ByteRecord.GetValue(i: Integer): Double;
begin
  Result := FList[i].Value;
end;

initialization
  TDUnitX.RegisterTestFixture(TListTest12ByteRecord);
  TDUnitX.RegisterTestFixture(TListTest13ByteRecord);
  TDUnitX.RegisterTestFixture(TListTest16ByteRecord);
  TDUnitX.RegisterTestFixture(TListTest40ByteRecord);
  TDUnitX.RegisterTestFixture(TListTest121ByteRecord);

end.

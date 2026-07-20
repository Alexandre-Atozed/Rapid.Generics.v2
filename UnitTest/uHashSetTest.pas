unit uHashSetTest;

interface

uses
  DUnitX.TestFramework,
  System.Generics.Collections,
  System.SysUtils,
  Rapid.Generics;

type
  TTestHashSetBase<T> = class
  protected
    FSet: THashSet<T>;
    // Five distinct sample values, must all be different from one another.
    function V1: T; virtual; abstract;
    function V2: T; virtual; abstract;
    function V3: T; virtual; abstract;
    function V4: T; virtual; abstract;
    function V5: T; virtual; abstract;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;

    [Test]
    procedure Test_NewSet_IsEmpty;
    [Test]
    procedure Test_Add_IncreasesCount;
    [Test]
    procedure Test_Add_Duplicate_DoesNotIncreaseCount;
    [Test]
    procedure Test_Contains_TrueForAddedItem;
    [Test]
    procedure Test_Contains_FalseForMissingItem;
    [Test]
    procedure Test_Remove_ExistingItem;
    [Test]
    procedure Test_Remove_NonExistingItem_NoOp;
    [Test]
    procedure Test_Clear_ResetsCountAndEmptiness;
    [Test]
    procedure Test_ToArray_ContainsAllItems;

    [Test]
    procedure Test_UnionWith_EmptySelf;
    [Test]
    procedure Test_UnionWith_Overlapping;
    [Test]
    procedure Test_UnionWith_Self_NoOp;

    [Test]
    procedure Test_IntersectWith_Basic;
    [Test]
    procedure Test_IntersectWith_Disjoint_ResultsEmpty;
    [Test]
    procedure Test_IntersectWith_NoOtherElementsMoveNext_ClearsSet;
    [Test]
    procedure Test_IntersectWith_Self_NoOp;

    [Test]
    procedure Test_Overlaps_True;
    [Test]
    procedure Test_Overlaps_False;
    [Test]
    procedure Test_Overlaps_EmptySet_False;
    [Test]
    procedure Test_Overlaps_Self_True;

    [Test]
    procedure Test_SetEquals_EqualSets;
    [Test]
    procedure Test_SetEquals_DifferentSizes;
    [Test]
    procedure Test_SetEquals_SameSizeDifferentContent;
    [Test]
    procedure Test_SetEquals_Self_True;

    [Test]
    procedure Test_IsSubsetOf_True;
    [Test]
    procedure Test_IsSubsetOf_False;
    [Test]
    procedure Test_IsSubsetOf_EmptySet_AlwaysTrue;
    [Test]
    procedure Test_IsSubsetOf_Self_True;

    [Test]
    procedure Test_IsSupersetOf_True;
    [Test]
    procedure Test_IsSupersetOf_False;
    [Test]
    procedure Test_IsSupersetOf_Self_True;

    [Test]
    procedure Test_NilArgument_RaisesArgumentException;
  end;

  [TestFixture]
  TTestHashSetInteger = class(TTestHashSetBase<Integer>)
  protected
    function V1: Integer; override;
    function V2: Integer; override;
    function V3: Integer; override;
    function V4: Integer; override;
    function V5: Integer; override;
  end;

  [TestFixture]
  TTestHashSetInt64 = class(TTestHashSetBase<Int64>)
  protected
    function V1: Int64; override;
    function V2: Int64; override;
    function V3: Int64; override;
    function V4: Int64; override;
    function V5: Int64; override;
  end;

  [TestFixture]
  TTestHashSetDouble = class(TTestHashSetBase<Double>)
  protected
    function V1: Double; override;
    function V2: Double; override;
    function V3: Double; override;
    function V4: Double; override;
    function V5: Double; override;
  end;

  [TestFixture]
  TTestHashSetSingle = class(TTestHashSetBase<Single>)
  protected
    function V1: Single; override;
    function V2: Single; override;
    function V3: Single; override;
    function V4: Single; override;
    function V5: Single; override;
  end;

  [TestFixture]
  TTestHashSetExtended = class(TTestHashSetBase<Extended>)
  protected
    function V1: Extended; override;
    function V2: Extended; override;
    function V3: Extended; override;
    function V4: Extended; override;
    function V5: Extended; override;
  end;

  [TestFixture]
  TTestHashSetString = class(TTestHashSetBase<string>)
  protected
    function V1: string; override;
    function V2: string; override;
    function V3: string; override;
    function V4: string; override;
    function V5: string; override;
  end;

// Add to the same unit, before `implementation`, near other type declarations:

type
  TRec8 = packed record
    Field1: Integer;
    Field2: Integer;
    class operator Equal(const A, B: TRec8): Boolean;
    constructor Create(AField1, AField2: Integer);
  end;

  TRec16 = packed record
    Field1: Integer;
    Field2: Integer;
    Field3: Integer;
    Field4: Integer;
    class operator Equal(const A, B: TRec16): Boolean;
    constructor Create(AField1, AField2, AField3, AField4: Integer);
  end;

  [TestFixture]
  TTestHashSetRec8 = class(TTestHashSetBase<TRec8>)
  protected
    function V1: TRec8; override;
    function V2: TRec8; override;
    function V3: TRec8; override;
    function V4: TRec8; override;
    function V5: TRec8; override;
  end;

  [TestFixture]
  TTestHashSetRec16 = class(TTestHashSetBase<TRec16>)
  protected
    function V1: TRec16; override;
    function V2: TRec16; override;
    function V3: TRec16; override;
    function V4: TRec16; override;
    function V5: TRec16; override;
  end;

implementation

{ TTestHashSetBase<T> }

procedure TTestHashSetBase<T>.Setup;
begin
  FSet := THashSet<T>.Create;
end;

procedure TTestHashSetBase<T>.TearDown;
begin
  FSet.Free;
end;

procedure TTestHashSetBase<T>.Test_NewSet_IsEmpty;
begin
  Assert.AreEqual(0, Integer(FSet.Count));
  Assert.IsTrue(FSet.IsEmpty);
end;

procedure TTestHashSetBase<T>.Test_Add_IncreasesCount;
begin
  FSet.Add(V1);
  Assert.AreEqual(1, Integer(FSet.Count));
  FSet.Add(V2);
  Assert.AreEqual(2, Integer(FSet.Count));
end;

procedure TTestHashSetBase<T>.Test_Add_Duplicate_DoesNotIncreaseCount;
begin
  FSet.Add(V1);
  FSet.Add(V1);
  Assert.AreEqual(1, Integer(FSet.Count));
end;

procedure TTestHashSetBase<T>.Test_Contains_TrueForAddedItem;
begin
  FSet.Add(V1);
  Assert.IsTrue(FSet.Contains(V1));
end;

procedure TTestHashSetBase<T>.Test_Contains_FalseForMissingItem;
begin
  FSet.Add(V1);
  Assert.IsFalse(FSet.Contains(V2));
end;

procedure TTestHashSetBase<T>.Test_Remove_ExistingItem;
begin
  FSet.Add(V1);
  FSet.Add(V2);
  FSet.Remove(V1);
  Assert.AreEqual(1, Integer(FSet.Count));
  Assert.IsFalse(FSet.Contains(V1));
  Assert.IsTrue(FSet.Contains(V2));
end;

procedure TTestHashSetBase<T>.Test_Remove_NonExistingItem_NoOp;
begin
  FSet.Add(V1);
  FSet.Remove(V2);
  Assert.AreEqual(1, Integer(FSet.Count));
end;

procedure TTestHashSetBase<T>.Test_Clear_ResetsCountAndEmptiness;
begin
  FSet.Add(V1);
  FSet.Add(V2);
  FSet.Clear;
  Assert.AreEqual(0, Integer(FSet.Count));
  Assert.IsTrue(FSet.IsEmpty);
end;

procedure TTestHashSetBase<T>.Test_ToArray_ContainsAllItems;
var
  arr: TArray<T>;
  Comparer: IEqualityComparer<T>;
  Found1, Found2: Boolean;
  v: T;
begin
  FSet.Add(V1);
  FSet.Add(V2);
  arr := FSet.ToArray;
  Assert.AreEqual(2, Integer(Length(arr)));
  Comparer := TEqualityComparer<T>.Default;
  Found1 := False;
  Found2 := False;
  for v in arr do
  begin
    if Comparer.Equals(v, V1) then Found1 := True;
    if Comparer.Equals(v, V2) then Found2 := True;
  end;
  Assert.IsTrue(Found1);
  Assert.IsTrue(Found2);
end;

procedure TTestHashSetBase<T>.Test_UnionWith_EmptySelf;
var
  Other: THashSet<T>;
begin
  Other := THashSet<T>.Create;
  try
    Other.Add(V1);
    Other.Add(V2);
    FSet.UnionWith(Other);
    Assert.AreEqual(2, Integer(FSet.Count));
    Assert.IsTrue(FSet.Contains(V1));
    Assert.IsTrue(FSet.Contains(V2));
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_UnionWith_Overlapping;
var
  Other: THashSet<T>;
begin
  FSet.Add(V1);
  FSet.Add(V2);
  Other := THashSet<T>.Create;
  try
    Other.Add(V2);
    Other.Add(V3);
    FSet.UnionWith(Other);
    Assert.AreEqual(3, Integer(FSet.Count));
    Assert.IsTrue(FSet.Contains(V1));
    Assert.IsTrue(FSet.Contains(V2));
    Assert.IsTrue(FSet.Contains(V3));
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_UnionWith_Self_NoOp;
begin
  FSet.Add(V1);
  FSet.UnionWith(FSet);
  Assert.AreEqual(1, Integer(FSet.Count));
end;

procedure TTestHashSetBase<T>.Test_IntersectWith_Basic;
var
  Other: THashSet<T>;
begin
  FSet.Add(V1);
  FSet.Add(V2);
  FSet.Add(V3);
  Other := THashSet<T>.Create;
  try
    Other.Add(V2);
    Other.Add(V3);
    Other.Add(V4);
    FSet.IntersectWith(Other);
    Assert.AreEqual(2, Integer(FSet.Count));
    Assert.IsFalse(FSet.Contains(V1));
    Assert.IsTrue(FSet.Contains(V2));
    Assert.IsTrue(FSet.Contains(V3));
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_IntersectWith_Disjoint_ResultsEmpty;
var
  Other: THashSet<T>;
begin
  FSet.Add(V1);
  FSet.Add(V2);
  Other := THashSet<T>.Create;
  try
    Other.Add(V3);
    Other.Add(V4);
    FSet.IntersectWith(Other);
    Assert.AreEqual(0, Integer(FSet.Count));
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_IntersectWith_NoOtherElementsMoveNext_ClearsSet;
var
  Other: THashSet<T>;
begin
  FSet.Add(V1);
  FSet.Add(V2);
  Other := THashSet<T>.Create; // empty
  try
    FSet.IntersectWith(Other);
    Assert.AreEqual(0, Integer(FSet.Count));
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_IntersectWith_Self_NoOp;
begin
  FSet.Add(V1);
  FSet.Add(V2);
  FSet.IntersectWith(FSet);
  Assert.AreEqual(2, Integer(FSet.Count));
end;

procedure TTestHashSetBase<T>.Test_Overlaps_True;
var
  Other: THashSet<T>;
begin
  FSet.Add(V1);
  FSet.Add(V2);
  Other := THashSet<T>.Create;
  try
    Other.Add(V2);
    Other.Add(V3);
    Assert.IsTrue(FSet.Overlaps(Other));
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_Overlaps_False;
var
  Other: THashSet<T>;
begin
  FSet.Add(V1);
  Other := THashSet<T>.Create;
  try
    Other.Add(V2);
    Other.Add(V3);
    Assert.IsFalse(FSet.Overlaps(Other));
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_Overlaps_EmptySet_False;
var
  Other: THashSet<T>;
begin
  Other := THashSet<T>.Create;
  try
    Other.Add(V1);
    Assert.IsFalse(FSet.Overlaps(Other)); // FSet is empty
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_Overlaps_Self_True;
begin
  FSet.Add(V1);
  Assert.IsTrue(FSet.Overlaps(FSet));
end;

procedure TTestHashSetBase<T>.Test_SetEquals_EqualSets;
var
  Other: THashSet<T>;
begin
  FSet.Add(V1);
  FSet.Add(V2);
  Other := THashSet<T>.Create;
  try
    Other.Add(V2);
    Other.Add(V1);
    Assert.IsTrue(FSet.SetEquals(Other));
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_SetEquals_DifferentSizes;
var
  Other: THashSet<T>;
begin
  FSet.Add(V1);
  FSet.Add(V2);
  Other := THashSet<T>.Create;
  try
    Other.Add(V1);
    Assert.IsFalse(FSet.SetEquals(Other));
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_SetEquals_SameSizeDifferentContent;
var
  Other: THashSet<T>;
begin
  FSet.Add(V1);
  FSet.Add(V2);
  Other := THashSet<T>.Create;
  try
    Other.Add(V1);
    Other.Add(V3);
    Assert.IsFalse(FSet.SetEquals(Other));
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_SetEquals_Self_True;
begin
  FSet.Add(V1);
  Assert.IsTrue(FSet.SetEquals(FSet));
end;

procedure TTestHashSetBase<T>.Test_IsSubsetOf_True;
var
  Other: THashSet<T>;
begin
  FSet.Add(V1);
  Other := THashSet<T>.Create;
  try
    Other.Add(V1);
    Other.Add(V2);
    Other.Add(V3);
    Assert.IsTrue(FSet.IsSubsetOf(Other));
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_IsSubsetOf_False;
var
  Other: THashSet<T>;
begin
  FSet.Add(V1);
  FSet.Add(V4);
  Other := THashSet<T>.Create;
  try
    Other.Add(V1);
    Other.Add(V2);
    Assert.IsFalse(FSet.IsSubsetOf(Other));
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_IsSubsetOf_EmptySet_AlwaysTrue;
var
  Other: THashSet<T>;
begin
  Other := THashSet<T>.Create;
  try
    Other.Add(V1);
    Assert.IsTrue(FSet.IsSubsetOf(Other)); // FSet is empty
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_IsSubsetOf_Self_True;
begin
  FSet.Add(V1);
  Assert.IsTrue(FSet.IsSubsetOf(FSet));
end;

procedure TTestHashSetBase<T>.Test_IsSupersetOf_True;
var
  Other: THashSet<T>;
begin
  FSet.Add(V1);
  FSet.Add(V2);
  FSet.Add(V3);
  Other := THashSet<T>.Create;
  try
    Other.Add(V1);
    Other.Add(V2);
    Assert.IsTrue(FSet.IsSupersetOf(Other));
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_IsSupersetOf_False;
var
  Other: THashSet<T>;
begin
  FSet.Add(V1);
  Other := THashSet<T>.Create;
  try
    Other.Add(V1);
    Other.Add(V2);
    Assert.IsFalse(FSet.IsSupersetOf(Other));
  finally
    Other.Free;
  end;
end;

procedure TTestHashSetBase<T>.Test_IsSupersetOf_Self_True;
begin
  FSet.Add(V1);
  Assert.IsTrue(FSet.IsSupersetOf(FSet));
end;

procedure TTestHashSetBase<T>.Test_NilArgument_RaisesArgumentException;
begin
  Assert.WillRaise(
    procedure
    begin
      FSet.UnionWith(nil);
    end,
    EArgumentException);

  Assert.WillRaise(
    procedure
    begin
      FSet.IntersectWith(nil);
    end,
    EArgumentException);

  Assert.WillRaise(
    procedure
    begin
      FSet.Overlaps(nil);
    end,
    EArgumentException);

  Assert.WillRaise(
    procedure
    begin
      FSet.SetEquals(nil);
    end,
    EArgumentException);

  Assert.WillRaise(
    procedure
    begin
      FSet.IsSubsetOf(nil);
    end,
    EArgumentException);

  Assert.WillRaise(
    procedure
    begin
      FSet.IsSupersetOf(nil);
    end,
    EArgumentException);
end;

{ TTestHashSetInteger }

function TTestHashSetInteger.V1: Integer; begin Result := 10; end;
function TTestHashSetInteger.V2: Integer; begin Result := 20; end;
function TTestHashSetInteger.V3: Integer; begin Result := 30; end;
function TTestHashSetInteger.V4: Integer; begin Result := 40; end;
function TTestHashSetInteger.V5: Integer; begin Result := 50; end;

{ TTestHashSetInt64 }

function TTestHashSetInt64.V1: Int64; begin Result := Int64(1) shl 40; end;
function TTestHashSetInt64.V2: Int64; begin Result := Int64(2) shl 40; end;
function TTestHashSetInt64.V3: Int64; begin Result := Int64(3) shl 40; end;
function TTestHashSetInt64.V4: Int64; begin Result := Int64(4) shl 40; end;
function TTestHashSetInt64.V5: Int64; begin Result := Int64(5) shl 40; end;

{ TTestHashSetDouble }

function TTestHashSetDouble.V1: Double; begin Result := 1.5; end;
function TTestHashSetDouble.V2: Double; begin Result := 2.5; end;
function TTestHashSetDouble.V3: Double; begin Result := 3.5; end;
function TTestHashSetDouble.V4: Double; begin Result := 4.5; end;
function TTestHashSetDouble.V5: Double; begin Result := 5.5; end;

{ TTestHashSetSingle }

function TTestHashSetSingle.V1: Single; begin Result := 1.25; end;
function TTestHashSetSingle.V2: Single; begin Result := 2.25; end;
function TTestHashSetSingle.V3: Single; begin Result := 3.25; end;
function TTestHashSetSingle.V4: Single; begin Result := 4.25; end;
function TTestHashSetSingle.V5: Single; begin Result := 5.25; end;

{ TTestHashSetExtended }

function TTestHashSetExtended.V1: Extended; begin Result := 1.125; end;
function TTestHashSetExtended.V2: Extended; begin Result := 2.125; end;
function TTestHashSetExtended.V3: Extended; begin Result := 3.125; end;
function TTestHashSetExtended.V4: Extended; begin Result := 4.125; end;
function TTestHashSetExtended.V5: Extended; begin Result := 5.125; end;

{ TTestHashSetString }

function TTestHashSetString.V1: string; begin Result := 'Alpha'; end;
function TTestHashSetString.V2: string; begin Result := 'Bravo'; end;
function TTestHashSetString.V3: string; begin Result := 'Charlie'; end;
function TTestHashSetString.V4: string; begin Result := 'Delta'; end;
function TTestHashSetString.V5: string; begin Result := 'Echo'; end;

// Add to `implementation`:

{ TRec8 }

constructor TRec8.Create(AField1, AField2: Integer);
begin
  Field1 := AField1;
  Field2 := AField2;
end;

class operator TRec8.Equal(const A, B: TRec8): Boolean;
begin
  Result := (A.Field1 = B.Field1) and (A.Field2 = B.Field2);
end;

{ TRec16 }

constructor TRec16.Create(AField1, AField2, AField3, AField4: Integer);
begin
  Field1 := AField1;
  Field2 := AField2;
  Field3 := AField3;
  Field4 := AField4;
end;

class operator TRec16.Equal(const A, B: TRec16): Boolean;
begin
  Result := (A.Field1 = B.Field1) and (A.Field2 = B.Field2)
        and (A.Field3 = B.Field3) and (A.Field4 = B.Field4);
end;

{ TTestHashSetRec8 }

function TTestHashSetRec8.V1: TRec8; begin Result := TRec8.Create(1, 100); end;
function TTestHashSetRec8.V2: TRec8; begin Result := TRec8.Create(2, 200); end;
function TTestHashSetRec8.V3: TRec8; begin Result := TRec8.Create(3, 300); end;
function TTestHashSetRec8.V4: TRec8; begin Result := TRec8.Create(4, 400); end;
function TTestHashSetRec8.V5: TRec8; begin Result := TRec8.Create(5, 500); end;

{ TTestHashSetRec16 }

function TTestHashSetRec16.V1: TRec16; begin Result := TRec16.Create(1, 10, 100, 1000); end;
function TTestHashSetRec16.V2: TRec16; begin Result := TRec16.Create(2, 20, 200, 2000); end;
function TTestHashSetRec16.V3: TRec16; begin Result := TRec16.Create(3, 30, 300, 3000); end;
function TTestHashSetRec16.V4: TRec16; begin Result := TRec16.Create(4, 40, 400, 4000); end;
function TTestHashSetRec16.V5: TRec16; begin Result := TRec16.Create(5, 50, 500, 5000); end;

initialization
  TDUnitX.RegisterTestFixture(TTestHashSetInteger);
  TDUnitX.RegisterTestFixture(TTestHashSetInt64);
  TDUnitX.RegisterTestFixture(TTestHashSetDouble);
  TDUnitX.RegisterTestFixture(TTestHashSetSingle);
  TDUnitX.RegisterTestFixture(TTestHashSetExtended);
  TDUnitX.RegisterTestFixture(TTestHashSetString);
  TDUnitX.RegisterTestFixture(TTestHashSetRec8);
  TDUnitX.RegisterTestFixture(TTestHashSetRec16);

end.

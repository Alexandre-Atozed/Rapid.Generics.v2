unit uDefaultComparerTest;

// Regression tests for the default comparers:
//  #8  8-byte sets compared/hashed by address on Win64
//  #9  TComparer<T>.Default for 8-byte records/sets compared addresses on Win64
//  #10 TEqualityComparer<T>.Default unguarded before its class constructor ran
//  #11 sets over anonymous subranges (no type info) crashed the class constructors

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  Rapid.Generics;

type
  TBit = 0..63;
  TSet8 = set of TBit;           // 8 bytes, has type info
  TAnonSet3 = set of 0..23;      // 3 bytes, no type info
  TAnonSet8 = set of 0..63;      // 8 bytes, no type info

  TRec8 = record
    A, B: Integer;
  end;

  [TestFixture]
  TDefaultComparerTest = class
  private
    procedure CheckSortedMatchesDirectSort(const Explicit, Direct: TArray<TRec8>);
  public
    // #8
    [Test]
    procedure Test_Set8_Equals_EqualValues;
    [Test]
    procedure Test_Set8_Equals_DifferentValues;
    [Test]
    procedure Test_Set8_HashCode_EqualValues;
    [Test]
    procedure Test_Set8_Dictionary_LookupThroughCopy;
    [Test]
    procedure Test_Rec8_HashCode_IsWellDistributed;

    // #9
    [Test]
    procedure Test_Rec8_Compare_EqualValuesReturnZero;
    [Test]
    procedure Test_Rec8_Compare_Ordering;
    [Test]
    procedure Test_Rec8_Sort_WithExplicitDefaultComparer;
    [Test]
    procedure Test_Set8_Compare_EqualValuesReturnZero;
    [Test]
    procedure Test_Set8_Compare_IsAntisymmetric;

    // #10
    [Test]
    procedure Test_EqualityComparerDefault_BeforeClassConstructor;
    [Test]
    procedure Test_SortAndSearch_BeforeClassConstructor;

    // #11
    [Test]
    procedure Test_AnonSet3_Equals_And_HashCode;
    [Test]
    procedure Test_AnonSet3_Compare;
    [Test]
    procedure Test_AnonSet3_Dictionary;
    [Test]
    procedure Test_AnonSet8_Equals_And_HashCode;
    [Test]
    procedure Test_AnonSet8_Compare;
    [Test]
    procedure Test_AnonSet8_Dictionary;
  end;

implementation

uses
  uInitOrderEarly;

{ TDefaultComparerTest }

procedure TDefaultComparerTest.CheckSortedMatchesDirectSort(const Explicit, Direct: TArray<TRec8>);
var
  I: Integer;
begin
  Assert.AreEqual(Length(Direct), Length(Explicit));
  for I := 0 to High(Direct) do
  begin
    Assert.AreEqual(Direct[I].A, Explicit[I].A, 'A at index ' + IntToStr(I));
    Assert.AreEqual(Direct[I].B, Explicit[I].B, 'B at index ' + IntToStr(I));
  end;
end;

// ---------------------------------------------------------------- #8

procedure TDefaultComparerTest.Test_Set8_Equals_EqualValues;
var
  A, B: TSet8;
begin
  A := [1, 40];
  B := [1, 40];
  Assert.IsTrue(TEqualityComparer<TSet8>.Default.Equals(A, B));
end;

procedure TDefaultComparerTest.Test_Set8_Equals_DifferentValues;
var
  A, B: TSet8;
begin
  A := [1, 40];
  B := [1, 41];
  Assert.IsFalse(TEqualityComparer<TSet8>.Default.Equals(A, B));
end;

procedure TDefaultComparerTest.Test_Set8_HashCode_EqualValues;
var
  A, B: TSet8;
begin
  A := [1, 40];
  B := [1, 40];
  Assert.AreEqual(TEqualityComparer<TSet8>.Default.GetHashCode(A),
    TEqualityComparer<TSet8>.Default.GetHashCode(B));
end;

procedure TDefaultComparerTest.Test_Set8_Dictionary_LookupThroughCopy;
var
  D: TDictionary<TSet8, Integer>;
  Key: TSet8;
  I, V, Misses: Integer;
begin
  D := TDictionary<TSet8, Integer>.Create;
  try
    for I := 0 to 62 do
      D.Add([I, 63], I);

    Misses := 0;
    for I := 0 to 62 do
    begin
      Key := [I, 63];
      if not D.TryGetValue(Key, V) then
        Inc(Misses)
      else
        Assert.AreEqual(I, V);
    end;
    Assert.AreEqual(0, Misses);
  finally
    D.Free;
  end;
end;

procedure TDefaultComparerTest.Test_Rec8_HashCode_IsWellDistributed;
const
  COUNT = 1000;
var
  Seen: TDictionary<Integer, Boolean>;
  R: TRec8;
  H, I: Integer;
begin
  // A degenerate hash yields only a few hundred distinct values for 1000 different keys
  Seen := TDictionary<Integer, Boolean>.Create;
  try
    for I := 0 to COUNT - 1 do
    begin
      R.A := I;
      R.B := I * 7919;
      H := TEqualityComparer<TRec8>.Default.GetHashCode(R);
      if not Seen.ContainsKey(H) then
        Seen.Add(H, True);
    end;
    Assert.IsTrue(Seen.Count > 512, 'Distinct hashes: ' + IntToStr(Seen.Count));
  finally
    Seen.Free;
  end;
end;

// ---------------------------------------------------------------- #9

procedure TDefaultComparerTest.Test_Rec8_Compare_EqualValuesReturnZero;
var
  X, Y: TRec8;
begin
  X.A := 5;
  X.B := 0;
  Y := X;
  Assert.AreEqual(0, TComparer<TRec8>.Default.Compare(X, Y));
end;

procedure TDefaultComparerTest.Test_Rec8_Compare_Ordering;
var
  X, Y: TRec8;
begin
  X.A := 2;
  X.B := 0;
  Y.A := 1;
  Y.B := 0;
  Assert.IsTrue(TComparer<TRec8>.Default.Compare(X, Y) > 0, 'Compare(2, 1) > 0');
  Assert.IsTrue(TComparer<TRec8>.Default.Compare(Y, X) < 0, 'Compare(1, 2) < 0');
end;

procedure TDefaultComparerTest.Test_Rec8_Sort_WithExplicitDefaultComparer;
var
  Explicit, Direct: TArray<TRec8>;
  I, Bad: Integer;
begin
  SetLength(Explicit, 50);
  SetLength(Direct, 50);
  for I := 0 to 49 do
  begin
    Explicit[I].A := (I * 37) mod 50;
    Explicit[I].B := 0;
    Direct[I] := Explicit[I];
  end;

  TArray.Sort<TRec8>(Explicit, TComparer<TRec8>.Default);
  TArray.Sort<TRec8>(Direct);

  Bad := 0;
  for I := 1 to 49 do
    if Explicit[I - 1].A > Explicit[I].A then
      Inc(Bad);
  Assert.AreEqual(0, Bad, 'Adjacent pairs out of order');

  CheckSortedMatchesDirectSort(Explicit, Direct);
end;

procedure TDefaultComparerTest.Test_Set8_Compare_EqualValuesReturnZero;
var
  A, B: TSet8;
begin
  A := [1, 40];
  B := [1, 40];
  Assert.AreEqual(0, TComparer<TSet8>.Default.Compare(A, B));
end;

procedure TDefaultComparerTest.Test_Set8_Compare_IsAntisymmetric;
var
  A, B: TSet8;
  AB, BA: Integer;
begin
  A := [1, 40];
  B := [1, 41];
  AB := TComparer<TSet8>.Default.Compare(A, B);
  BA := TComparer<TSet8>.Default.Compare(B, A);
  Assert.AreNotEqual(0, AB);
  Assert.IsTrue((AB < 0) = (BA > 0), 'Compare(A, B) and Compare(B, A) must have opposite signs');
end;

// ---------------------------------------------------------------- #10

procedure TDefaultComparerTest.Test_EqualityComparerDefault_BeforeClassConstructor;
begin
  Assert.AreEqual('', EarlyInitError, 'Exception raised from an early initialization section');
  Assert.IsTrue(EarlyEqualityResult);
end;

procedure TDefaultComparerTest.Test_SortAndSearch_BeforeClassConstructor;
begin
  Assert.AreEqual('', EarlyInitError, 'Exception raised from an early initialization section');
  Assert.IsTrue(EarlySortSearchResult);
end;

// ---------------------------------------------------------------- #11

procedure TDefaultComparerTest.Test_AnonSet3_Equals_And_HashCode;
var
  A, B, C: TAnonSet3;
begin
  A := [1, 20];
  B := [1, 20];
  C := [1, 21];
  Assert.IsTrue(TEqualityComparer<TAnonSet3>.Default.Equals(A, B));
  Assert.IsFalse(TEqualityComparer<TAnonSet3>.Default.Equals(A, C));
  Assert.AreEqual(TEqualityComparer<TAnonSet3>.Default.GetHashCode(A),
    TEqualityComparer<TAnonSet3>.Default.GetHashCode(B));
end;

procedure TDefaultComparerTest.Test_AnonSet3_Compare;
var
  A, B, C: TAnonSet3;
begin
  A := [1, 20];
  B := [1, 20];
  C := [1, 21];
  Assert.AreEqual(0, TComparer<TAnonSet3>.Default.Compare(A, B));
  Assert.AreNotEqual(0, TComparer<TAnonSet3>.Default.Compare(A, C));
end;

procedure TDefaultComparerTest.Test_AnonSet3_Dictionary;
var
  D: TDictionary<TAnonSet3, Integer>;
  Key: TAnonSet3;
  I, V: Integer;
begin
  D := TDictionary<TAnonSet3, Integer>.Create;
  try
    for I := 0 to 22 do
      D.Add([I, 23], I);
    Assert.AreEqual(23, D.Count);

    for I := 0 to 22 do
    begin
      Key := [I, 23];
      Assert.IsTrue(D.TryGetValue(Key, V), 'Lookup ' + IntToStr(I));
      Assert.AreEqual(I, V);
    end;
  finally
    D.Free;
  end;
end;

procedure TDefaultComparerTest.Test_AnonSet8_Equals_And_HashCode;
var
  A, B, C: TAnonSet8;
begin
  A := [1, 40];
  B := [1, 40];
  C := [1, 41];
  Assert.IsTrue(TEqualityComparer<TAnonSet8>.Default.Equals(A, B));
  Assert.IsFalse(TEqualityComparer<TAnonSet8>.Default.Equals(A, C));
  Assert.AreEqual(TEqualityComparer<TAnonSet8>.Default.GetHashCode(A),
    TEqualityComparer<TAnonSet8>.Default.GetHashCode(B));
end;

procedure TDefaultComparerTest.Test_AnonSet8_Compare;
var
  A, B, C: TAnonSet8;
begin
  A := [1, 40];
  B := [1, 40];
  C := [1, 41];
  Assert.AreEqual(0, TComparer<TAnonSet8>.Default.Compare(A, B));
  Assert.AreNotEqual(0, TComparer<TAnonSet8>.Default.Compare(A, C));
end;

procedure TDefaultComparerTest.Test_AnonSet8_Dictionary;
var
  D: TDictionary<TAnonSet8, Integer>;
  Key: TAnonSet8;
  I, V: Integer;
begin
  D := TDictionary<TAnonSet8, Integer>.Create;
  try
    for I := 0 to 62 do
      D.Add([I, 63], I);

    for I := 0 to 62 do
    begin
      Key := [I, 63];
      Assert.IsTrue(D.TryGetValue(Key, V), 'Lookup ' + IntToStr(I));
      Assert.AreEqual(I, V);
    end;
  finally
    D.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TDefaultComparerTest);

end.

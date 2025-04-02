unit uListTest;

interface

{$DEFINE TEST_INTLIST}
{$DEFINE TEST_FLOATLIST}
{$DEFINE TEST_STRINGLIST}
{$DEFINE TEST_POINTERLIST}
{$DEFINE TEST_RECORDLIST}

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
  DUnitX.TestFramework;

type
  TListHelper<T> = class
    class function CreateSampleList(const Values: array of T; const NilIndex: array of Integer): TList<T>;
  end;

  {$IFDEF TEST_INTLIST}
  [TestFixture]
  TListTestInteger = class
  private
    FList: TList<Integer>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestAdd;
    [Test]
    procedure TestRemove;
    [Test]
    procedure TestDelete;
    [Test]
    procedure TestClear;
    [Test]
    procedure TestInsert;
    [Test]
    procedure TestContains;
    [Test]
    procedure TestCount;
    [Test]
    procedure TestMany;
    [Test]
    procedure TestHuge;
    [Test]
    procedure TestBinarySearch;
    [Test]
    procedure TestPack;
    [Test]
    procedure TestAddRange;
    [Test]
    procedure TestDeleteRange;
  end;
  {$ENDIF TEST_INTLIST}

  {$IFDEF TEST_FLOATLIST}
  [TestFixture]
  TListTestDouble = class
  private
    FList: TList<Double>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestFloatAdd;
    [Test]
    procedure TestFloatRemove;
    [Test]
    procedure TestFloatClear;
    [Test]
    procedure TestFloatInsert;
    [Test]
    procedure TestFloatContains;
    [Test]
    procedure TestFloatCount;
    [Test]
    procedure TestFloatMany;
    [Test]
    procedure TestFloatHuge;
    [Test]
    procedure TestFloatBinarySearch;
    [Test]
    procedure TestFloatPack;
    [Test]
    procedure TestFloatAddRange;
    [Test]
    procedure TestFloatDeleteRange;
  end;
  {$ENDIF TEST_FLOATLIST}

  {$IFDEF TEST_STRINGLIST}
  [TestFixture]
  TListTestString = class
  private
    FList: TList<string>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestStringAdd;
    [Test]
    procedure TestStringRemove;
    [Test]
    procedure TestStringClear;
    [Test]
    procedure TestStringInsert;
    [Test]
    procedure TestStringContains;
    [Test]
    procedure TestStringCount;
    [Test]
    procedure TestStringMany;
    [Test]
    procedure TestStringHuge;
    [Test]
    procedure TestStringBinarySearch;
    [Test]
    procedure TestStringPack;
    [Test]
    procedure TestStringAddRange;
  end;
  {$ENDIF TEST_STRINGLIST}

  {$IFDEF TEST_POINTERLIST}
  [TestFixture]
  TListTestPointer = class
  private
    FList: TList<Pointer>;
    procedure DoTestPointerHuge;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestPointerAdd;
    [Test]
    procedure TestPointerRemove;
    [Test]
    procedure TestPointerClear;
    [Test]
    procedure TestPointerInsert;
    [Test]
    procedure TestPointerContains;
    [Test]
    procedure TestPointerCount;
    [Test]
    procedure TestPointerBinarySearch;
    [Test]
    procedure TestPointerHuge;
    [Test]
    procedure TestPointerPack;
    [Test]
    procedure TestPointerAddRange;
    [Test]
    procedure TestPointerDeleteRange;
  end;
  {$ENDIF TEST_POINTERLIST}

  {$IFDEF TEST_RECORDLIST}
  TTestRecord = record
    x: Integer;
    y: string;
  end;

  TTestRecordComparer = class(TInterfacedObject, IComparer<TTestRecord>)
  public
    function Compare(const Left, Right: TTestRecord): Integer;
  end;

  [TestFixture]
  TListTestRecord = class
  private
    FList: TList<TTestRecord>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestAdd;
    [Test]
    procedure TestRemove;
    [Test]
    procedure TestDelete;
    [Test]
    procedure TestClear;
    [Test]
    procedure TestInsert;
    [Test]
    procedure TestContains;
    [Test]
    procedure TestCount;
    [Test]
    procedure TestMany;
    [Test]
    procedure TestHuge;
    [Test]
    procedure TestBinarySearch;
    [Test]
    procedure TestPack;
    [Test]
    procedure TestAddRange;
    [Test]
    procedure TestDeleteRange;
  end;

  TTestRecord2 = record
    x: Integer;
    y: array[0..4] of Integer;  // Static array of integers
  end;

  TTestRecord2Comparer = class(TInterfacedObject, IComparer<TTestRecord2>)
  public
    function Compare(const Left, Right: TTestRecord2): Integer;
  end;

  TListTestRecord2 = class
  private
    FList: TList<TTestRecord2>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestAdd;
    [Test]
    procedure TestRemove;
    [Test]
    procedure TestDelete;
    [Test]
    procedure TestClear;
    [Test]
    procedure TestInsert;
    [Test]
    procedure TestContains;
    [Test]
    procedure TestCount;
    [Test]
    procedure TestMany;
    [Test]
    procedure TestHuge;
    [Test]
    procedure TestBinarySearch;
    [Test]
    procedure TestPack;
    [Test]
    procedure TestAddRange;
    [Test]
    procedure TestDeleteRange;
  end;
  {$ENDIF TEST_RECORDLIST}

implementation

const
  MANY_ITEMS_COUNT = 1000;
  HUGE_ITEMS_COUNT = 100000;

class function TListHelper<T>.CreateSampleList(const Values: array of T; const NilIndex: array of Integer): TList<T>;
var
  I: Integer;
begin
  Result := TList<T>.Create;
  for I := Low(Values) to High(Values) do
    Result.Add(Values[I]);
  for I in NilIndex do
    Result[I] := Default(T);
end;

{$Region 'TList<Integer> Tests'}
{$IFDEF TEST_INTLIST}
procedure TListTestInteger.Setup;
begin
  FList := TList<Integer>.Create;
end;

procedure TListTestInteger.TearDown;
begin
  FreeAndNil(FList);
end;

procedure TListTestInteger.TestAdd;
begin
  FList.Add(10);
  Assert.AreEqual(Integer(1), Integer(FList.Count));
  Assert.AreEqual(Integer(10), Integer(FList[0]));
end;

procedure TListTestInteger.TestRemove;
begin
  FList.Add(10);
  FList.Add(20);
  Assert.AreEqual(Integer(2), Integer(FList.Count));
  Assert.IsTrue(FList.Remove(10) >= 0);
  Assert.AreEqual(Integer(1), Integer(FList.Count));
  Assert.AreEqual(Integer(20), FList[0]);
end;

procedure TListTestInteger.TestDelete;
begin
  FList.Add(10);
  FList.Add(20);
  FList.Add(30);
  Assert.AreEqual(3, Integer(FList.Count));
  FList.Delete(0);
  Assert.AreEqual(2, Integer(FList.Count));
  Assert.AreEqual(20, FList[0]);
  FList.Delete(1);
  Assert.AreEqual(1, Integer(FList.Count));
  Assert.AreEqual(20, FList[0]);
  FList.Delete(0);
  Assert.AreEqual(0, Integer(FList.Count));
end;

procedure TListTestInteger.TestClear;
begin
  FList.Add(1);
  FList.Add(2);
  FList.Add(3);
  FList.Clear;
  Assert.AreEqual(Integer(0), Integer(FList.Count));
end;

procedure TListTestInteger.TestInsert;
begin
  FList.Add(10);
  FList.Insert(0, 5);
  Assert.AreEqual(Integer(2), Integer(FList.Count));
  Assert.AreEqual(Integer(5), Integer(FList[0]));
  Assert.AreEqual(Integer(10), Integer(FList[1]));
end;

procedure TListTestInteger.TestContains;
begin
  FList.Add(42);
  Assert.IsTrue(FList.Contains(42));
  Assert.IsFalse(FList.Contains(99));
end;

procedure TListTestInteger.TestCount;
begin
  Assert.AreEqual(Integer(0), Integer(FList.Count));
  FList.Add(100);
  Assert.AreEqual(Integer(1), Integer(FList.Count));
  FList.Add(200);
  Assert.AreEqual(Integer(2), Integer(FList.Count));
end;

procedure TListTestInteger.TestMany;
var
  i: Integer;
begin
  for i := 1 to MANY_ITEMS_COUNT do
    FList.Add(i);

  Assert.AreEqual(MANY_ITEMS_COUNT, Integer(FList.Count));

  Assert.IsTrue(FList.Contains(MANY_ITEMS_COUNT));

  for i := MANY_ITEMS_COUNT - 1 downto 0 do
    FList.Delete(i);

  Assert.AreEqual(0, Integer(FList.Count));

  Assert.IsFalse(FList.Contains(MANY_ITEMS_COUNT));

  for i := 1 to MANY_ITEMS_COUNT do
    FList.Add(i);

  Assert.AreEqual(MANY_ITEMS_COUNT, Integer(FList.Count));

  for i := 1 to MANY_ITEMS_COUNT do
    FList.Remove(i);

  Assert.AreEqual(Integer(0), Integer(FList.Count));
end;

procedure TListTestInteger.TestHuge;
var
  I: Integer;
begin
  // Add 1 million elements
  for I := HUGE_ITEMS_COUNT downto 1 do
    FList.Add(I);

  Assert.AreEqual(HUGE_ITEMS_COUNT, Integer(FList.Count));

  // Insert in the middle
  FList.Insert(HUGE_ITEMS_COUNT div 2, MaxInt);
  Assert.AreEqual(HUGE_ITEMS_COUNT + 1, Integer(FList.Count));
  Assert.AreEqual(MaxInt, Integer(FList[HUGE_ITEMS_COUNT div 2]));

  // Remove first 100,000 elements
  for I := 1 to MANY_ITEMS_COUNT do
    FList.Delete(0);

  Assert.AreEqual(HUGE_ITEMS_COUNT - MANY_ITEMS_COUNT + 1, Integer(FList.Count));

  // Sort the list
  FList.Sort;
  Assert.AreEqual(1, FList[0]);
  Assert.AreEqual(Integer(FList.Count div 2), Integer(FList[FList.Count div 2 - 1]));
  Assert.AreEqual(MaxInt, Integer(FList[FList.Count-1]));

  {$IFDEF TEST_RAPIDGENERICS}    // Std TList<> does not have SortDescending
  // Sort descending
  FList.SortDescending;
  Assert.AreEqual(MaxInt, FList[0]);
  Assert.AreEqual(Integer(FList.Count div 2), Integer(FList[FList.Count div 2 + 1]));
  Assert.AreEqual(1, Integer(FList[FList.Count-1]));
  {$ENDIF}
end;

procedure TListTestInteger.TestBinarySearch;
var
  Index: Integer;
begin
  FList.AddRange([1, 3, 5, 7, 9]);
  FList.Sort; // Ensure it's sorted before searching

  Assert.IsTrue(FList.BinarySearch(5, Index));
  Assert.AreEqual(2, Index);

  Assert.IsFalse(FList.BinarySearch(4, Index)); // Not in the list
end;

procedure TListTestInteger.TestPack;
begin
  FreeAndNil(FList);
  FList := TListHelper<Integer>.CreateSampleList([1, 0, 2, 0, 3], [1, 3]);
  FList.Pack;
  Assert.AreEqual(3, Integer(FList.Count));
  Assert.IsTrue(FList.Contains(1) and FList.Contains(2) and FList.Contains(3));
end;

procedure TListTestInteger.TestAddRange;
begin
  FList.AddRange([4, 5, 6]);
  Assert.AreEqual(3, Integer(FList.Count));
  FList.AddRange([1, 2, 3]);
  Assert.AreEqual(6, Integer(FList.Count));
  FList.AddRange([7, 8, 9, 10]);
  Assert.AreEqual(10, Integer(FList.Count));
  Assert.IsTrue(FList.Contains(4) and FList.Contains(5) and FList.Contains(6));
  Assert.IsTrue(FList.Contains(1) and FList.Contains(2) and FList.Contains(3));
end;

procedure TListTestInteger.TestDeleteRange;
begin
  FList.AddRange([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
  FList.DeleteRange(3, 4);
  Assert.AreEqual(6, Integer(FList.Count));
  Assert.IsTrue(FList.Contains(1) and FList.Contains(2) and FList.Contains(3));
  Assert.IsTrue(FList.Contains(8) and FList.Contains(9) and FList.Contains(10));
  Assert.IsFalse(FList.Contains(4) or FList.Contains(5) or FList.Contains(6) or FList.Contains(7));
end;
{$ENDIF TEST_INTLIST}
{$EndRegion 'TList<Integer> Tests'}

{$Region 'TList<Double> Tests'}
{$IFDEF TEST_FLOATLIST}
procedure TListTestDouble.Setup;
begin
  FList := TList<Double>.Create;
end;

procedure TListTestDouble.TearDown;
begin
  FreeAndNil(FList);
end;

procedure TListTestDouble.TestFloatAdd;
begin
  FList.Add(10);
  Assert.AreEqual(1, Integer(FList.Count));
  Assert.AreEqual(Double(10.0), FList[0]);
end;

procedure TListTestDouble.TestFloatRemove;
begin
  FList.Add(10);
  FList.Add(20);
  Assert.AreEqual(2, Integer(FList.Count));
  Assert.IsTrue(FList.Remove(10) >= 0);
  Assert.AreEqual(1, Integer(FList.Count));
  Assert.AreEqual(Double(20.0), FList[0]);
end;

procedure TListTestDouble.TestFloatClear;
begin
  FList.Add(1);
  FList.Add(2);
  FList.Add(3);
  FList.Clear;
  Assert.AreEqual(0, Integer(FList.Count));
end;

procedure TListTestDouble.TestFloatInsert;
begin
  FList.Add(10);
  FList.Insert(0, 5);
  Assert.AreEqual(2, Integer(FList.Count));
  Assert.AreEqual(Double(5.0), FList[0]);
  Assert.AreEqual(Double(10.0), FList[1]);
end;

procedure TListTestDouble.TestFloatContains;
begin
  FList.Add(42);
  Assert.IsTrue(FList.Contains(42));
  Assert.IsFalse(FList.Contains(99));
end;

procedure TListTestDouble.TestFloatCount;
begin
  Assert.AreEqual(0, Integer(FList.Count));
  FList.Add(100);
  Assert.AreEqual(1, Integer(FList.Count));
  FList.Add(200);
  Assert.AreEqual(2, Integer(FList.Count));
end;

procedure TListTestDouble.TestFloatMany;
var
  i: Integer;
begin
  for i := 1 to MANY_ITEMS_COUNT do
    FList.Add(i);

  Assert.AreEqual(MANY_ITEMS_COUNT, Integer(FList.Count));

  Assert.IsTrue(FList.Contains(MANY_ITEMS_COUNT));

  for i := MANY_ITEMS_COUNT - 1 downto 0 do
    FList.Delete(i);

  Assert.AreEqual(0, Integer(FList.Count));

  Assert.IsFalse(FList.Contains(MANY_ITEMS_COUNT));

  for i := 1 to MANY_ITEMS_COUNT do
    FList.Add(i);

  Assert.AreEqual(MANY_ITEMS_COUNT, Integer(FList.Count));

  for i := 1 to MANY_ITEMS_COUNT do
    FList.Remove(i);

  Assert.AreEqual(0, Integer(FList.Count));
end;

procedure TListTestDouble.TestFloatHuge;
var
  I: Integer;
begin
  // Add 1 million elements
  for I := HUGE_ITEMS_COUNT downto 1 do
    FList.Add(I);

  Assert.AreEqual(HUGE_ITEMS_COUNT, Integer(FList.Count));

  // Insert in the middle
  FList.Insert(HUGE_ITEMS_COUNT div 2, MaxInt);
  Assert.AreEqual(HUGE_ITEMS_COUNT + 1, Integer(FList.Count));
  Assert.AreEqual(Double(MaxInt), Double(FList[HUGE_ITEMS_COUNT div 2]));

  // Remove first 100,000 elements
  for I := 1 to MANY_ITEMS_COUNT do
    FList.Delete(0);

  Assert.AreEqual(HUGE_ITEMS_COUNT - MANY_ITEMS_COUNT + 1, Integer(FList.Count));

  // Sort the list
  FList.Sort;
  Assert.AreEqual(Double(1.0), Double(FList[0]));
  Assert.AreEqual(Double(FList.Count div 2), Double(FList[FList.Count div 2 - 1]));
  Assert.AreEqual(Double(MaxInt), Double(FList[FList.Count-1]));

  {$IFDEF TEST_RAPIDGENERICS}    // Std TList<> does not have SortDescending
  // Sort descending
  FList.SortDescending;
  Assert.AreEqual(Double(MaxInt), Double(FList[0]));
  Assert.AreEqual(Double(FList.Count div 2), Double(FList[FList.Count div 2 + 1]));
  Assert.AreEqual(Double(1.0), Double(FList[FList.Count-1]));
  {$ENDIF TEST_RAPIDGENERICS}
end;

procedure TListTestDouble.TestFloatBinarySearch;
var
  Index: Integer;
begin
  FList.AddRange([1, 3, 5, 7, 9]);
  FList.Sort; // Ensure it's sorted before searching

  Assert.IsTrue(FList.BinarySearch(5, Index));
  Assert.AreEqual(Double(2), Double(Index));

  Assert.IsFalse(FList.BinarySearch(4, Index)); // Not in the list
end;

procedure TListTestDouble.TestFloatPack;
begin
  FreeAndNil(FList);
  FList := TListHelper<Double>.CreateSampleList([1.1, 0.0, 2.2, 0.0, 3.3], [1, 3]);
  FList.Pack;
  Assert.AreEqual(3, Integer(FList.Count));
  Assert.IsTrue(FList.Contains(1.1) and FList.Contains(2.2) and FList.Contains(3.3));
end;

procedure TListTestDouble.TestFloatAddRange;
begin
  FList.AddRange([7.7, 8.8, 9.9]);
  Assert.AreEqual(3, Integer(FList.Count));
  Assert.IsTrue(FList.Contains(7.7) and FList.Contains(8.8) and FList.Contains(9.9));
end;

procedure TListTestDouble.TestFloatDeleteRange;
begin
  FList.AddRange([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
  FList.DeleteRange(3, 4);
  Assert.AreEqual(6, Integer(FList.Count));
  Assert.IsTrue(FList.Contains(1) and FList.Contains(2) and FList.Contains(3));
  Assert.IsTrue(FList.Contains(8) and FList.Contains(9) and FList.Contains(10));
  Assert.IsFalse(FList.Contains(4) or FList.Contains(5) or FList.Contains(6) or FList.Contains(7));
end;
{$ENDIF TEST_FLOATLIST}
{$EndRegion 'Test<Double> Tests'}

{$Region 'TList<String> Tests'}
{$IFDEF TEST_STRINGLIST}
procedure TListTestString.Setup;
begin
  FList := TList<string>.Create;
end;

procedure TListTestString.TearDown;
begin
  FreeAndNil(FList);
end;

procedure TListTestString.TestStringAdd;
begin
  FList.Add('Hello');
  Assert.AreEqual(Integer(1), Integer(FList.Count));
  Assert.AreEqual('Hello', FList[0]);
end;

procedure TListTestString.TestStringRemove;
begin
  FList.Add('Hello');
  FList.Add('World');
  Assert.AreEqual(Integer(2), Integer(FList.Count));
  Assert.IsTrue(FList.Remove('Hello') >= 0);
  Assert.AreEqual(Integer(1), Integer(FList.Count));
  Assert.AreEqual('World', FList[0]);
end;

procedure TListTestString.TestStringClear;
begin
  FList.Add('One');
  FList.Add('Two');
  FList.Clear;
  Assert.AreEqual(Integer(0), Integer(FList.Count));
end;

procedure TListTestString.TestStringInsert;
begin
  FList.Add('B');
  FList.Insert(0, 'A');
  Assert.AreEqual(Integer(2), Integer(FList.Count));
  Assert.AreEqual('A', FList[0]);
  Assert.AreEqual('B', FList[1]);
end;

procedure TListTestString.TestStringContains;
begin
  FList.Add('Found');
  Assert.IsTrue(FList.Contains('Found'));
  Assert.IsFalse(FList.Contains('Missing'));
end;

procedure TListTestString.TestStringCount;
begin
  FList.Add('One');
  Assert.AreEqual(Integer(1), Integer(FList.Count));
  FList.Add('Two');
  Assert.AreEqual(Integer(2), Integer(FList.Count));
end;

procedure TListTestString.TestStringMany;
var
  i: Integer;
begin
  for i := 0 to MANY_ITEMS_COUNT - 1 do
    FList.Add('Item ' + IntToStr(i));

  Assert.AreEqual(Integer(MANY_ITEMS_COUNT), Integer(FList.Count));

  Assert.IsTrue(FList.Contains('Item ' + IntToStr(MANY_ITEMS_COUNT - 1)));

  for i := MANY_ITEMS_COUNT - 1 downto 0 do
    FList.Delete(i);

  Assert.AreEqual(Integer(0), Integer(FList.Count));

  Assert.IsFalse(FList.Contains('Item ' + IntToStr(MANY_ITEMS_COUNT - 1)));

  for i := 1 to MANY_ITEMS_COUNT do
    FList.Add('Item ' + IntToStr(i));

  Assert.AreEqual(Integer(MANY_ITEMS_COUNT), Integer(FList.Count));

  for i := 1 to MANY_ITEMS_COUNT do
    FList.Remove('Item ' + IntToStr(i));

  Assert.AreEqual(Integer(0), Integer(FList.Count));
end;

procedure TListTestString.TestStringHuge;
var
  I: Integer;
begin
  // Add 1 million elements
  for I := 1 to HUGE_ITEMS_COUNT do
    FList.Add('Item' + IntToStr(I));

  Assert.AreEqual(HUGE_ITEMS_COUNT, Integer(FList.Count));

  // Insert in the middle
  FList.Insert(HUGE_ITEMS_COUNT div 2, 'InsertedItem');
  Assert.AreEqual(HUGE_ITEMS_COUNT + 1, Integer(FList.Count));
  Assert.AreEqual('InsertedItem', FList[HUGE_ITEMS_COUNT div 2]);

  // Remove first 100,000 elements
  for I := 1 to MANY_ITEMS_COUNT do
    FList.Delete(0);

  Assert.AreEqual(HUGE_ITEMS_COUNT - MANY_ITEMS_COUNT + 1, Integer(FList.Count));

  // Sort the list
  FList.Sort;
  Assert.AreEqual('InsertedItem', FList[0]); // Since it doesn't have "ItemX" pattern

  {$IFDEF TEST_RAPIDGENERICS}    // Std TList<> does not have SortDescending
  // Sort the list
  FList.SortDescending;
  Assert.AreEqual('InsertedItem', FList[FList.Count-1]); // Since it doesn't have "ItemX" pattern
  {$ENDIF TEST_RAPIDGENERICS}
end;

procedure TListTestString.TestStringBinarySearch;
var
  Index: Integer;
begin
  FList.Clear;
  Assert.IsFalse(FList.BinarySearch('Anything', Index));

  FList.AddRange(['Apple', 'Banana', 'Grape', 'Orange', 'Peach']);
  FList.Sort; // Sorting ensures BinarySearch works correctly

  Assert.IsTrue(FList.BinarySearch('Grape', Index));
  Assert.AreEqual(2, Index);

  Assert.IsFalse(FList.BinarySearch('Mango', Index)); // Not in the list
end;

procedure TListTestString.TestStringPack;
begin
  FreeAndNil(FList);
  FList := TListHelper<string>.CreateSampleList(['A', '', 'B', '', 'C'], [1, 3]);
  FList.Pack;
  Assert.AreEqual(3, Integer(FList.Count));
  Assert.IsTrue(FList.Contains('A') and FList.Contains('B') and FList.Contains('C'));
end;

procedure TListTestString.TestStringAddRange;
var
  List: TList<string>;
begin
  List := TList<string>.Create;
  try
    List.AddRange(['X', 'Y', 'Z']);
    Assert.AreEqual(3, Integer(List.Count));
    Assert.IsTrue(List.Contains('X') and List.Contains('Y') and List.Contains('Z'));
  finally
    List.Free;
  end;
end;
{$ENDIF TEST_STRINGLIST}
{$EndRegion 'TList<String> Tests'}

{$Region 'TList<Pointer> Tests'}
{$IFDEF TEST_POINTERLIST}

procedure TListTestPointer.Setup;
begin
  FList := TList<Pointer>.Create;
end;

procedure TListTestPointer.TearDown;
begin
  FreeAndNil(FList);
end;

procedure TListTestPointer.TestPointerAdd;
var
  P: Pointer;
begin
  GetMem(P, 4);
  try
    FList.Add(P);
    Assert.AreEqual(1, Integer(FList.Count));
    Assert.AreEqual(P, FList[0]);
  finally
    FreeMem(P);
  end;
end;

procedure TListTestPointer.TestPointerRemove;
var
  P: Pointer;
begin
  GetMem(P, 4);
  try
    FList.Add(P);
    Assert.AreEqual(1, Integer(FList.Count));
    Assert.IsTrue(FList.Remove(P) >= 0);
    Assert.AreEqual(0, Integer(FList.Count));
  finally
    FreeMem(P);
  end;
end;

procedure TListTestPointer.TestPointerClear;
begin
  FList.Add(@Self);
  FList.Clear;
  Assert.AreEqual(0, Integer(FList.Count));
end;

procedure TListTestPointer.TestPointerInsert;
begin
  FList.Add(@Self);
  FList.Insert(0, nil);
  Assert.AreEqual(2, Integer(FList.Count));
  Assert.AreEqual(nil, FList[0]);
  Assert.AreEqual(@Self, FList[1]);
end;

procedure TListTestPointer.TestPointerContains;
begin
  FList.Add(@Self);
  Assert.IsTrue(FList.Contains(@Self));
  Assert.IsFalse(FList.Contains(nil));
end;

procedure TListTestPointer.TestPointerCount;
begin
  Assert.AreEqual(0, Integer(FList.Count));
  FList.Add(@Self);
  Assert.AreEqual(1, Integer(FList.Count));
end;

procedure TListTestPointer.TestPointerBinarySearch;
var
  P1, P2, P3: Pointer;
  Index: Integer;
begin
  P1 := Pointer(2);
  P2 := Pointer(3);
  P3 := Pointer(1);

  FList.Add(P1);
  FList.Add(P2);
  FList.Add(P3);

  Assert.IsTrue(FList.Contains(P1));
  Assert.IsTrue(FList.Contains(P2));
  Assert.IsTrue(FList.Contains(P3));

  FList.Sort;
  Assert.IsTrue(FList.BinarySearch(P3, Index));
  Assert.IsTrue(Index = 0);

  Assert.IsTrue(FList.BinarySearch(P1, Index));
  Assert.IsTrue(Index = 1);

  Assert.IsTrue(FList.BinarySearch(P2, Index));
  Assert.IsTrue(Index = 2);

  FList.Clear;
  Assert.IsFalse(FList.BinarySearch(P2, Index));
end;

type
  PInteger = ^Integer;

function ComparePointers(Item1, Item2: Pointer): Integer;
var
  Int1, Int2: Integer;
begin
  if (Item1 = nil) or (Item2 = nil) then
    raise Exception.Create('Nil pointer encountered in CompareItems');

  Int1 := Integer(Item1);
  Int2 := Integer(Item2);

  Result := Int1 - Int2;
end;

function ComparePointersDescending(Item1, Item2: Pointer): Integer;
var
  Int1, Int2: Integer;
begin
  if (Item1 = nil) or (Item2 = nil) then
    raise Exception.Create('Nil pointer encountered in CompareItems');

  Int1 := Integer(Item1);
  Int2 := Integer(Item2);

  Result := Int2 - Int1;
end;

procedure TListTestPointer.DoTestPointerHuge;
var
  I, MaxCount, Index, IndexFound, RemoveCount: Integer;
  Ptr: Pointer;
  PointerList: TList<Pointer>;
  ExpectedList: TList;  // For validation
  ItemValues: array of Pointer;
  RemovedValues: array of Pointer;
begin
  // Initialize
  MaxCount := HUGE_ITEMS_COUNT;
  PointerList := FList;
  ExpectedList := TList.Create;
  try
    SetLength(ItemValues, MaxCount);
    for I := 0 to MaxCount - 1 do
    begin
      ItemValues[I] := Pointer(MaxCount-I);
    end;

    // Add pointers to both lists
    for I := 0 to MaxCount - 1 do
    begin
      Ptr := ItemValues[I];
      PointerList.Add(Ptr);
      ExpectedList.Add(Ptr);
    end;

    // Verify initial contents
    Assert.AreEqual(MaxCount, Integer(PointerList.Count), 'Initial count mismatch');
    for I := 0 to MaxCount - 1 do
      Assert.IsTrue(PointerList.Contains(ItemValues[I]), 'Contains failed before sort');

    // Sort both lists
    PointerList.Sort;
    ExpectedList.Sort(ComparePointers);  // Reference sort for comparison

    // Verify sorting
    Assert.AreEqual(MaxCount, Integer(PointerList.Count), 'Count changed after sort');
    for I := 0 to MaxCount - 1 do
      Assert.AreEqual(NativeInt(ExpectedList[I]), NativeInt(PointerList[I]),
        Format('Sort failed at index %d', [I]));

   {$IFDEF TEST_RAPIDGENERICS}    // Std TList<> does not have SortDescending
    // Sort again, descending
    PointerList.SortDescending;
    ExpectedList.Sort(ComparePointersDescending);

    // Verify sorting descending
    Assert.AreEqual(MaxCount, Integer(PointerList.Count), 'Count changed after sort');
    for I := MaxCount - 1 downto 0 do
      Assert.AreEqual(NativeInt(ExpectedList[I]), NativeInt(PointerList[I]),
        Format('Sort failed at index %d', [I]));
    {$ENDIF TEST_RAPIDGENERICS}

    // Sort ascending again for other tests
    PointerList.Sort;
    ExpectedList.Sort(ComparePointers);

    // Test BinarySearch on random samples
    for I := 1 to 100 do
    begin
      Index := Random(MaxCount);
      Ptr := ExpectedList[Index];
      Assert.IsTrue(PointerList.BinarySearch(Ptr, IndexFound), Format('BinarySearch failed for value %d', [NativeInt(Ptr)]));
      if Index <> IndexFound then
        Assert.AreEqual(Integer(Index), Integer(IndexFound), Format('BinarySearch returned wrong index. Expected %d, found %d', [Index, IndexFound]));
    end;

    // Remove random items
    RemoveCount := MaxCount div 2;  // Remove half the items
    SetLength(RemovedValues, RemoveCount);
    for I := 1 to RemoveCount do
    begin
      Index := Random(PointerList.Count);
      Ptr := PointerList[Index];
      RemovedValues[I-1] := Ptr;
      PointerList.Delete(Index);
      ExpectedList.Remove(Ptr);  // Remove same value from reference
    end;

    // Verify after removals
    Assert.AreEqual(Integer(ExpectedList.Count), Integer(PointerList.Count), 'Count mismatch after removals');
    for I := 0 to PointerList.Count - 1 do
      Assert.AreEqual(NativeInt(ExpectedList[I]), NativeInt(PointerList[I]),
        Format('List mismatch after removals at index %d', [I]));

    // Test BinarySearch after removals
    for I := 1 to 50 do
    begin
      Index := Random(PointerList.Count);
      Ptr := PointerList[Index];
      Assert.IsTrue(PointerList.BinarySearch(Ptr, IndexFound),
        Format('BinarySearch failed post-removal for value %d', [NativeInt(Ptr)]));
      if Index <> IndexFound then
        Assert.AreEqual(Integer(Index), Integer(IndexFound), Format('BinarySearch wrong index post-removal. Expected %d, found %d', [Index, IndexFound]));
    end;

    // Test search on removed item
    for i := Low(RemovedValues) to High(RemovedValues) do
    begin
      Ptr := RemovedValues[i];
      Assert.IsFalse(PointerList.Contains(Ptr) and PointerList.BinarySearch(Ptr, Index),
        'BinarySearch found a removed item');
    end;

    // Clear and verify
    PointerList.Clear;
    Assert.AreEqual(0, Integer(PointerList.Count), 'Clear failed');
    Assert.IsFalse(PointerList.BinarySearch(Pointer(500), Index), 'BinarySearch on empty list');
  finally
    ExpectedList.Free;
  end;
end;

procedure TListTestPointer.TestPointerHuge;
var
  i: Integer;
begin
  for i := 1 to 1 do
  begin
    FreeAndNil(FList);
    FList := TList<Pointer>.Create;
    try
      DoTestPointerHuge;
    finally
      FreeAndNil(FList);
    end;
  end;
end;

procedure TListTestPointer.TestPointerPack;
var
  P1, P2, P3: Pointer;
begin
  P1 := Pointer(1);
  P2 := Pointer(2);
  P3 := Pointer(3);
  FreeAndNil(FList);
  FList := TListHelper<Pointer>.CreateSampleList([P1, nil, P2, nil, P3], [1, 3]);
  Assert.AreEqual(5, Integer(FList.Count));
  FList.Pack;
  Assert.AreEqual(3, Integer(FList.Count));
  Assert.IsTrue(FList.Contains(P1) and FList.Contains(P2) and FList.Contains(P3));
end;

procedure TListTestPointer.TestPointerAddRange;
var
  List: TList<Pointer>;
  P1, P2, P3, P4, P5: Pointer;
begin
  P1 := Pointer(10);
  P2 := Pointer(20);
  P3 := Pointer(30);
  P4 := Pointer(30);
  P5 := Pointer(30);
  List := TList<Pointer>.Create;
  try
    List.AddRange([P1, P2, P3]);
    Assert.AreEqual(3, Integer(List.Count));
    List.AddRange([P4, P5]);
    Assert.AreEqual(5, Integer(List.Count));
    Assert.IsTrue(List.Contains(P1) and List.Contains(P2) and List.Contains(P3));
    Assert.IsTrue(List.Contains(P5) and List.Contains(P4));
  finally
    List.Free;
  end;
end;

procedure TListTestPointer.TestPointerDeleteRange;
var
  PArray: array[1..10] of pointer;
begin
  PArray[1] := Pointer(1);
  PArray[2] := Pointer(2);
  PArray[3] := Pointer(3);
  PArray[4] := Pointer(4);
  PArray[5] := Pointer(5);
  PArray[6] := Pointer(6);
  PArray[7] := Pointer(7);
  PArray[8] := Pointer(8);
  PArray[9] := Pointer(9);
  PArray[10] := Pointer(10);

  FList.AddRange(PArray);
  FList.DeleteRange(3, 4);
  Assert.AreEqual(6, Integer(FList.Count));
  Assert.IsTrue(FList.Contains(PArray[1]) and FList.Contains(PArray[2]) and FList.Contains(PArray[3]));
  Assert.IsTrue(FList.Contains(PArray[8]) and FList.Contains(PArray[9]) and FList.Contains(PArray[10]));
  Assert.IsFalse(FList.Contains(PArray[4]) or FList.Contains(PArray[5]) or FList.Contains(PArray[6]) or FList.Contains(PArray[7]));
end;

{$ENDIF TEST_POINTERLIST}

{$EndRegion 'TList<Pointer> Tests'}

{$Region 'TList<TTestRecord> Tests'}

{$IFDEF TEST_RECORDLIST}

{ TTestRecordComparer }

function TTestRecordComparer.Compare(const Left, Right: TTestRecord): Integer;
begin
  Result := Left.x - Right.x;
  if Result = 0 then
    Result := CompareText(Left.y, Right.y);
end;

{ TListTestRecord }

procedure TListTestRecord.SetUp;
var
  Comparer: IComparer<TTestRecord>;
begin
  Comparer := TTestRecordComparer.Create;
  FList := TList<TTestRecord>.Create(Comparer);
end;

procedure TListTestRecord.TearDown;
begin
  FList.Free;
end;

procedure TListTestRecord.TestAdd;
var
  Rec: TTestRecord;
begin
  Rec.x := 10;
  Rec.y := 'Hello';
  FList.Add(Rec);
  Assert.AreEqual(1, Integer(FList.Count));
  Assert.AreEqual(10, FList[0].x);
  Assert.AreEqual('Hello', FList[0].y);
end;

procedure TListTestRecord.TestRemove;
var
  Rec1, Rec2: TTestRecord;
  idx: Integer;
begin
  Rec1.x := 10; Rec1.y := 'Hello';
  Rec2.x := 20; Rec2.y := 'World';
  FList.Add(Rec1);
  FList.Add(Rec2);
  Assert.AreEqual(2, Integer(FList.Count));
  idx := FList.Remove(Rec1);
  Assert.IsTrue(idx >= 0);
  Assert.AreEqual(1, Integer(FList.Count));
  Assert.AreEqual(20, FList[0].x);
  Assert.AreEqual('World', FList[0].y);
end;

procedure TListTestRecord.TestDelete;
var
  Rec1, Rec2, Rec3: TTestRecord;
begin
  Rec1.x := 10; Rec1.y := 'Hello';
  Rec2.x := 20; Rec2.y := 'World';
  Rec3.x := 30; Rec3.y := '!';
  FList.Add(Rec1);
  FList.Add(Rec2);
  FList.Add(Rec3);
  Assert.AreEqual(3, Integer(FList.Count));
  FList.Delete(0);
  Assert.AreEqual(2, Integer(FList.Count));
  Assert.AreEqual('World', FList[0].y);
  FList.Delete(1);
  Assert.AreEqual(1, Integer(FList.Count));
  Assert.AreEqual('World', FList[0].y);
  FList.Delete(0);
  Assert.AreEqual(0, Integer(FList.Count));
end;

procedure TListTestRecord.TestClear;
var
  Rec: TTestRecord;
begin
  Rec.x := 1; Rec.y := 'One'; FList.Add(Rec);
  Rec.x := 2; Rec.y := 'Two'; FList.Add(Rec);
  Rec.x := 3; Rec.y := 'Three'; FList.Add(Rec);
  FList.Clear;
  Assert.AreEqual(0, Integer(FList.Count));
end;

procedure TListTestRecord.TestInsert;
var
  Rec1, Rec2: TTestRecord;
begin
  Rec1.x := 10; Rec1.y := 'Ten';
  Rec2.x := 5;  Rec2.y := 'Five';
  FList.Add(Rec1);
  FList.Insert(0, Rec2);
  Assert.AreEqual(2, Integer(FList.Count));
  Assert.AreEqual(5, FList[0].x);
  Assert.AreEqual('Five', FList[0].y);
  Assert.AreEqual(10, FList[1].x);
  Assert.AreEqual('Ten', FList[1].y);
end;

procedure TListTestRecord.TestContains;
var
  Rec: TTestRecord;
begin
  Rec.x := 42; Rec.y := 'Answer';
  FList.Add(Rec);
  Assert.IsTrue(FList.Contains(Rec));
  Rec.x := 99; Rec.y := 'Nope';
  Assert.IsFalse(FList.Contains(Rec));
end;

procedure TListTestRecord.TestCount;
var
  Rec: TTestRecord;
begin
  Assert.AreEqual(0, Integer(FList.Count));
  Rec.x := 100; Rec.y := 'Hundred';
  FList.Add(Rec);
  Assert.AreEqual(1, Integer(FList.Count));
  Rec.x := 200; Rec.y := 'TwoHundred';
  FList.Add(Rec);
  Assert.AreEqual(2, Integer(FList.Count));
end;

procedure TListTestRecord.TestMany;
var
  i: Integer;
  Rec: TTestRecord;
begin
  for i := 1 to MANY_ITEMS_COUNT do
  begin
    Rec.x := i;
    Rec.y := 'Item' + IntToStr(i);
    FList.Add(Rec);
  end;

  Assert.AreEqual(MANY_ITEMS_COUNT, Integer(FList.Count));

  Rec.x := MANY_ITEMS_COUNT; Rec.y := 'Item' + IntToStr(MANY_ITEMS_COUNT);
  Assert.IsTrue(FList.Contains(Rec));

  for i := MANY_ITEMS_COUNT downto 1 do
  begin
    Rec.x := i;
    FList.Remove(Rec);
  end;

  Assert.AreEqual(0, Integer(FList.Count));

  Assert.IsFalse(FList.Contains(Rec));

  for i := 1 to MANY_ITEMS_COUNT do
  begin
    Rec.x := i;
    Rec.y := 'Item' + IntToStr(i);
    FList.Add(Rec);
  end;

  Assert.AreEqual(MANY_ITEMS_COUNT, Integer(FList.Count));

  for i := 1 to MANY_ITEMS_COUNT do
  begin
    Rec.x := i;
    Rec.y := 'Item' + IntToStr(i);
    FList.Remove(Rec);
  end;

  Assert.AreEqual(0, Integer(FList.Count));
end;

procedure TListTestRecord.TestHuge;
var
  i: Integer;
  Rec: TTestRecord;
begin
  for i := HUGE_ITEMS_COUNT downto 1 do
  begin
    Rec.x := i;
    Rec.y := 'Item' + IntToStr(i);
    FList.Add(Rec);
  end;

  Assert.AreEqual(HUGE_ITEMS_COUNT, Integer(FList.Count));

  // Insert in the middle
  Rec.x := MaxInt; Rec.y := 'Max';
  FList.Insert(HUGE_ITEMS_COUNT div 2, Rec);
  Assert.AreEqual(HUGE_ITEMS_COUNT + 1, Integer(FList.Count));
  Assert.AreEqual(MaxInt, FList[HUGE_ITEMS_COUNT div 2].x);
  Assert.AreEqual('Max', FList[HUGE_ITEMS_COUNT div 2].y);

  for i := 1 to MANY_ITEMS_COUNT do
    FList.Delete(0);

  Assert.AreEqual(HUGE_ITEMS_COUNT - MANY_ITEMS_COUNT + 1, Integer(FList.Count));

  FList.Sort;
  Assert.AreEqual(1, FList[0].x);
end;

procedure TListTestRecord.TestBinarySearch;
var
  Index: Integer;
  Rec1, Rec2, Rec3, Rec4, Rec5, SearchRec: TTestRecord;
begin
  Rec1.x := 1; Rec1.y := 'A';
  Rec2.x := 3; Rec2.y := 'B';
  Rec3.x := 5; Rec3.y := 'C';
  Rec4.x := 7; Rec4.y := 'D';
  Rec5.x := 9; Rec5.y := 'E';
  FList.AddRange([Rec1, Rec2, Rec3, Rec4, Rec5]);
  FList.Sort;

  SearchRec.x := 5; SearchRec.y := 'C';
  Assert.IsTrue(FList.BinarySearch(SearchRec, Index));
  Assert.AreEqual(2, Index);

  SearchRec.x := 4; SearchRec.y := 'X';
  Assert.IsFalse(FList.BinarySearch(SearchRec, Index));
end;

procedure TListTestRecord.TestPack;
var
  Rec1, Rec2, Rec3, ZeroRec: TTestRecord;
begin
  Rec1.x := 1; Rec1.y := 'One';
  Rec2.x := 2; Rec2.y := 'Two';
  Rec3.x := 3; Rec3.y := 'Three';
  ZeroRec.x := 0; ZeroRec.y := '';
  FList.AddRange([Rec1, ZeroRec, Rec2, ZeroRec, Rec3]);
  FList.Pack;
  Assert.AreEqual(3, Integer(FList.Count));
  Assert.IsTrue(FList.Contains(Rec1) and FList.Contains(Rec2) and FList.Contains(Rec3));
end;

procedure TListTestRecord.TestAddRange;
var
  Rec1, Rec2, Rec3: TTestRecord;
begin
  Rec1.x := 4; Rec1.y := 'Four';
  Rec2.x := 5; Rec2.y := 'Five';
  Rec3.x := 6; Rec3.y := 'Six';
  FList.AddRange([Rec1, Rec2, Rec3]);
  Assert.AreEqual(3, Integer(FList.Count));
  Assert.AreEqual(4, FList[0].x);
  Assert.AreEqual('Four', FList[0].y);
  Assert.AreEqual(5, FList[1].x);
  Assert.AreEqual('Five', FList[1].y);
end;

procedure TListTestRecord.TestDeleteRange;
var
  Rec: TTestRecord;
  i: Integer;
begin
  for i := 1 to 10 do
  begin
    Rec.x := i;
    Rec.y := 'Item' + IntToStr(i);
    FList.Add(Rec);
  end;
  FList.DeleteRange(3, 4);
  Assert.AreEqual(6, Integer(FList.Count));
  Assert.AreEqual(1, FList[0].x);
  Assert.AreEqual('Item1', FList[0].y);
  Assert.AreEqual(8, FList[3].x);
  Assert.AreEqual('Item8', FList[3].y);
end;

{ TTestRecord2Comparer }

function TTestRecord2Comparer.Compare(const Left, Right: TTestRecord2): Integer;
var
  i: Integer;
begin
  Result := Left.x - Right.x;
  if Result <> 0 then
    Exit;

  if CompareMem(@Left.y, @Right.y, SizeOf(Left.y)) then
    Exit(0);

  for i := Low(Left.y) to High(Left.y) do
  begin
    Result := Left.y[i] - Right.y[i];
    if Result <> 0 then
      Exit;
  end;
end;

{ TListTestRecord2 }

procedure TListTestRecord2.SetUp;
var
  Comparer: IComparer<TTestRecord2>;
begin
  Comparer := TTestRecord2Comparer.Create;
  FList := TList<TTestRecord2>.Create(Comparer);
end;

procedure TListTestRecord2.TearDown;
begin
  FList.Free;
end;

procedure FillArray(var Arr: array of Integer);
var
  i: Integer;
begin
  for i := 0 to High(Arr) do
    Arr[i] := i;
end;

procedure TListTestRecord2.TestAdd;
var
  Rec: TTestRecord2;
begin
  Rec.x := 10;
  FillArray(Rec.y);  // y becomes [0, 1, 2, 3, 4]
  FList.Add(Rec);
  Assert.AreEqual(1, Integer(FList.Count));
  Assert.AreEqual(10, FList[0].x);
  Assert.AreEqual(0, FList[0].y[0]);
  Assert.AreEqual(4, FList[0].y[4]);
end;

procedure TListTestRecord2.TestRemove;
var
  Rec1, Rec2: TTestRecord2;
  idx: Integer;
begin
  Rec1.x := 10; FillArray(Rec1.y);
  Rec2.x := 20; FillArray(Rec2.y);
  FList.Add(Rec1);
  FList.Add(Rec2);
  Assert.AreEqual(2, Integer(FList.Count));
  idx := FList.Remove(Rec1);
  Assert.IsTrue(idx >= 0);
  Assert.AreEqual(1, Integer(FList.Count));
  Assert.AreEqual(20, FList[0].x);
  Assert.AreEqual(0, FList[0].y[0]);
  Assert.AreEqual(4, FList[0].y[4]);
end;

procedure TListTestRecord2.TestDelete;
var
  Rec1, Rec2, Rec3: TTestRecord2;
begin
  Rec1.x := 10; FillArray(Rec1.y);
  Rec2.x := 20; FillArray(Rec2.y);
  Rec3.x := 30; FillArray(Rec3.y);
  FList.Add(Rec1);
  FList.Add(Rec2);
  FList.Add(Rec3);
  Assert.AreEqual(3, Integer(FList.Count));
  FList.Delete(0);
  Assert.AreEqual(2, Integer(FList.Count));
  Assert.AreEqual(20, FList[0].x);
  Assert.AreEqual(0, FList[0].y[0]);
  FList.Delete(1);
  Assert.AreEqual(1, Integer(FList.Count));
  Assert.AreEqual(20, FList[0].x);
  Assert.AreEqual(0, FList[0].y[0]);
  FList.Delete(0);
  Assert.AreEqual(0, Integer(FList.Count));
end;

procedure TListTestRecord2.TestClear;
var
  Rec: TTestRecord2;
begin
  Rec.x := 1; FillArray(Rec.y); FList.Add(Rec);
  Rec.x := 2; FillArray(Rec.y); FList.Add(Rec);
  Rec.x := 3; FillArray(Rec.y); FList.Add(Rec);
  FList.Clear;
  Assert.AreEqual(0, Integer(FList.Count));
end;

procedure TListTestRecord2.TestInsert;
var
  Rec1, Rec2: TTestRecord2;
begin
  Rec1.x := 10; FillArray(Rec1.y);
  Rec2.x := 5;  FillArray(Rec2.y);
  FList.Add(Rec1);
  FList.Insert(0, Rec2);
  Assert.AreEqual(2, Integer(FList.Count));
  Assert.AreEqual(5, FList[0].x);
  Assert.AreEqual(0, FList[0].y[0]);
  Assert.AreEqual(10, FList[1].x);
  Assert.AreEqual(0, FList[1].y[0]);
end;

procedure TListTestRecord2.TestContains;
var
  Rec: TTestRecord2;
begin
  Rec.x := 42; FillArray(Rec.y);
  FList.Add(Rec);
  Assert.IsTrue(FList.Contains(Rec));
  Rec.x := 99; FillArray(Rec.y);
  Assert.IsFalse(FList.Contains(Rec));
end;

procedure TListTestRecord2.TestCount;
var
  Rec: TTestRecord2;
begin
  Assert.AreEqual(0, Integer(FList.Count));
  Rec.x := 100; FillArray(Rec.y);
  FList.Add(Rec);
  Assert.AreEqual(1, Integer(FList.Count));
  Rec.x := 200; FillArray(Rec.y);
  FList.Add(Rec);
  Assert.AreEqual(2, Integer(FList.Count));
end;

procedure TListTestRecord2.TestMany;
var
  i: Integer;
  Rec: TTestRecord2;
begin
  for i := 1 to MANY_ITEMS_COUNT do
  begin
    Rec.x := i;
    FillArray(Rec.y);
    FList.Add(Rec);
  end;

  Assert.AreEqual(MANY_ITEMS_COUNT, Integer(FList.Count));

  Rec.x := MANY_ITEMS_COUNT; FillArray(Rec.y);
  Assert.IsTrue(FList.Contains(Rec));

  for i := MANY_ITEMS_COUNT downto 1 do
  begin
    Rec.x := i;
    FillArray(Rec.y);
    FList.Remove(Rec);
  end;

  Assert.AreEqual(0, Integer(FList.Count));

  Assert.IsFalse(FList.Contains(Rec));

  for i := 1 to MANY_ITEMS_COUNT do
  begin
    Rec.x := i;
    FillArray(Rec.y);
    FList.Add(Rec);
  end;

  Assert.AreEqual(MANY_ITEMS_COUNT, Integer(FList.Count));

  for i := 1 to MANY_ITEMS_COUNT do
  begin
    Rec.x := i;
    FillArray(Rec.y);
    FList.Remove(Rec);
  end;

  Assert.AreEqual(0, Integer(FList.Count));
end;

procedure TListTestRecord2.TestHuge;
var
  i: Integer;
  Rec: TTestRecord2;
begin
  for i := HUGE_ITEMS_COUNT downto 1 do
  begin
    Rec.x := i;
    FillArray(Rec.y);
    FList.Add(Rec);
  end;

  Assert.AreEqual(HUGE_ITEMS_COUNT, Integer(FList.Count));

  Rec.x := MaxInt; FillArray(Rec.y);
  FList.Insert(HUGE_ITEMS_COUNT div 2, Rec);
  Assert.AreEqual(HUGE_ITEMS_COUNT + 1, Integer(FList.Count));
  Assert.AreEqual(MaxInt, FList[HUGE_ITEMS_COUNT div 2].x);
  Assert.AreEqual(0, FList[HUGE_ITEMS_COUNT div 2].y[0]);

  for i := 1 to MANY_ITEMS_COUNT do
    FList.Delete(0);

  Assert.AreEqual(HUGE_ITEMS_COUNT - MANY_ITEMS_COUNT + 1, Integer(FList.Count));

  FList.Sort;
  Assert.AreEqual(1, FList[0].x);
end;

procedure TListTestRecord2.TestBinarySearch;
var
  Index: Integer;
  Rec1, Rec2, Rec3, Rec4, Rec5, SearchRec: TTestRecord2;
begin
  Rec1.x := 1; FillArray(Rec1.y);
  Rec2.x := 3; FillArray(Rec2.y);
  Rec3.x := 5; FillArray(Rec3.y);
  Rec4.x := 7; FillArray(Rec4.y);
  Rec5.x := 9; FillArray(Rec5.y);
  FList.AddRange([Rec1, Rec2, Rec3, Rec4, Rec5]);
  FList.Sort;

  SearchRec.x := 5; FillArray(SearchRec.y);
  Assert.IsTrue(FList.BinarySearch(SearchRec, Index));
  Assert.AreEqual(2, Index);

  SearchRec.x := 4; FillArray(SearchRec.y);
  Assert.IsFalse(FList.BinarySearch(SearchRec, Index));
end;

procedure TListTestRecord2.TestPack;
var
  Rec1, Rec2, Rec3, ZeroRec: TTestRecord2;
begin
  Rec1.x := 1; FillArray(Rec1.y);
  Rec2.x := 2; FillArray(Rec2.y);
  Rec3.x := 3; FillArray(Rec3.y);
  ZeroRec := default(TTestRecord2);
  FList.AddRange([Rec1, ZeroRec, Rec2, ZeroRec, Rec3]);
  FList.Pack;
  Assert.AreEqual(3, Integer(FList.Count));
  Assert.IsTrue(FList.Contains(Rec1) and FList.Contains(Rec2) and FList.Contains(Rec3));
end;

procedure TListTestRecord2.TestAddRange;
var
  Rec1, Rec2, Rec3: TTestRecord2;
begin
  Rec1.x := 4; FillArray(Rec1.y);
  Rec2.x := 5; FillArray(Rec2.y);
  Rec3.x := 6; FillArray(Rec3.y);
  FList.AddRange([Rec1, Rec2, Rec3]);
  Assert.AreEqual(3, Integer(FList.Count));
  Assert.AreEqual(4, FList[0].x);
  Assert.AreEqual(0, FList[0].y[0]);
  Assert.AreEqual(5, FList[1].x);
  Assert.AreEqual(0, FList[1].y[0]);
end;

procedure TListTestRecord2.TestDeleteRange;
var
  Rec: TTestRecord2;
  i: Integer;
begin
  for i := 1 to 10 do
  begin
    Rec.x := i;
    FillArray(Rec.y);
    FList.Add(Rec);
  end;
  FList.DeleteRange(3, 4);
  Assert.AreEqual(6, Integer(FList.Count));
  Assert.AreEqual(1, FList[0].x);
  Assert.AreEqual(0, FList[0].y[0]);
  Assert.AreEqual(8, FList[3].x);
  Assert.AreEqual(0, FList[3].y[0]);
end;

{$ENDIF TEST_RECORDLIST}

{$EndRegion 'TList<TTestRecord> Tests'}


initialization
  TDUnitX.RegisterTestFixture(TListTestInteger);
  TDUnitX.RegisterTestFixture(TListTestDouble);
  TDUnitX.RegisterTestFixture(TListTestString);
  TDUnitX.RegisterTestFixture(TListTestPointer);
  TDUnitX.RegisterTestFixture(TListTestRecord);
  TDUnitX.RegisterTestFixture(TListTestRecord2);

end.

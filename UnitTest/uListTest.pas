unit uListTest;

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

  // Test for lists of records with strings (managed types)
  TTestRecordString = record
    x: Integer;
    y: string;
  end;

  TTestRecordStringComparer = class(TInterfacedObject, IComparer<TTestRecordString>)
  public
    function Compare(const Left, Right: TTestRecordString): Integer;
  end;

  [TestFixture]
  TListTestRecordString = class
  private
    FList: TList<TTestRecordString>;
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

  // Test for lists of records with static arrays
  TTestRecordStaticArray = record
    x: Integer;
    y: array[0..4] of Integer;  // Static array of integers
  end;

  TTestRecordStaticArrayComparer = class(TInterfacedObject, IComparer<TTestRecordStaticArray>)
  public
    function Compare(const Left, Right: TTestRecordStaticArray): Integer;
  end;

  [TestFixture]
  TListTestRecordStaticArray = class
  private
    FList: TList<TTestRecordStaticArray>;
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

  // Test for lists of records with dynamic arrays
  TTestRecordDynamicArray = record
    x: Integer;
    y: TArray<Integer>; // Dynamic array of integers
  end;

  TTestRecordDynamicComparer = class(TInterfacedObject, IComparer<TTestRecordDynamicArray>)
  public
    function Compare(const Left, Right: TTestRecordDynamicArray): Integer;
  end;

  [TestFixture]
  TListTestRecordDynamicArray = class
  private
    FList: TList<TTestRecordDynamicArray>;
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

type
  TMyEnum = (meRed, meGreen, meBlue);
  TMyEnumSet = set of TMyEnum;

  TNestedRecord = record
    A: Integer;
    B: string;
  end;

  IMyInterfacedObject = Interface
  ['{6563A9CF-4259-4CD1-BACB-B5D89E66497B}']
    procedure DoSomeStuff();
  end;

  TMyInterfacedObject = class(TInterfacedObject, IMyInterfacedObject)
  public
    procedure DoSomeStuff();
  end;

  TComplexRecord = record
    ID: Integer;
    Name: string;
    FixedArray: array[0..3] of Integer;
    DynArray: TArray<Integer>;
    VariantValue: Variant;
    EnumSet: TMyEnumSet;
    Nested: TNestedRecord;
    Intf: IMyInterfacedObject;
  end;

  TListTestRecordComplex = class
  private
    FList: TList<TComplexRecord>;
    function CreateComplexRecord(AID: Integer; const AName: string): TComplexRecord;
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
    procedure TestPack;
    [Test]
    procedure TestAddRange;
    [Test]
    procedure TestDeleteRange;
  end;

  {$ENDIF TEST_RECORDLIST}

  {$IFDEF TEST_OBJECTLIST}

  TMyObject = class
  public
    ID: Integer;
    constructor Create(AID: Integer);
    destructor Destroy; override;
  end;

  TObjectListTestObjectComparer = class(TInterfacedObject, IComparer<TMyObject>)
  public
    function Compare(const Left, Right: TMyObject): Integer;
  end;

  [TestFixture]
  TObjectListTestObject = class
  private
    FList: TObjectList<TMyObject>;
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
    procedure TestSetOwnsObjects;
    [Test]
    procedure TestAddRange;
    [Test]
    procedure TestDeleteRange;
    [Test]
    procedure TestPack;
    [Test]
    procedure TestMany;
    [Test]
    procedure TestHuge;
  end;

  {$ENDIF TEST_OBJECTLIST}

implementation

uses
  Variants;

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

function TTestRecordStringComparer.Compare(const Left, Right: TTestRecordString): Integer;
begin
  Result := Left.x - Right.x;
  if Result = 0 then
    Result := CompareText(Left.y, Right.y);
end;

{ TListTestRecord }

procedure TListTestRecordString.SetUp;
var
  Comparer: IComparer<TTestRecordString>;
begin
  Comparer := TTestRecordStringComparer.Create;
  FList := TList<TTestRecordString>.Create(Comparer);
end;

procedure TListTestRecordString.TearDown;
begin
  FList.Free;
end;

procedure TListTestRecordString.TestAdd;
var
  Rec: TTestRecordString;
begin
  Rec.x := 10;
  Rec.y := 'Hello';
  FList.Add(Rec);
  Assert.AreEqual(1, Integer(FList.Count));
  Assert.AreEqual(10, FList[0].x);
  Assert.AreEqual('Hello', FList[0].y);
end;

procedure TListTestRecordString.TestRemove;
var
  Rec1, Rec2: TTestRecordString;
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

procedure TListTestRecordString.TestDelete;
var
  Rec1, Rec2, Rec3: TTestRecordString;
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

procedure TListTestRecordString.TestClear;
var
  Rec: TTestRecordString;
begin
  Rec.x := 1; Rec.y := 'One'; FList.Add(Rec);
  Rec.x := 2; Rec.y := 'Two'; FList.Add(Rec);
  Rec.x := 3; Rec.y := 'Three'; FList.Add(Rec);
  FList.Clear;
  Assert.AreEqual(0, Integer(FList.Count));
end;

procedure TListTestRecordString.TestInsert;
var
  Rec1, Rec2: TTestRecordString;
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

procedure TListTestRecordString.TestContains;
var
  Rec: TTestRecordString;
begin
  Rec.x := 42; Rec.y := 'Answer';
  FList.Add(Rec);
  Assert.IsTrue(FList.Contains(Rec));
  Rec.x := 99; Rec.y := 'Nope';
  Assert.IsFalse(FList.Contains(Rec));
end;

procedure TListTestRecordString.TestCount;
var
  Rec: TTestRecordString;
begin
  Assert.AreEqual(0, Integer(FList.Count));
  Rec.x := 100; Rec.y := 'Hundred';
  FList.Add(Rec);
  Assert.AreEqual(1, Integer(FList.Count));
  Rec.x := 200; Rec.y := 'TwoHundred';
  FList.Add(Rec);
  Assert.AreEqual(2, Integer(FList.Count));
end;

procedure TListTestRecordString.TestMany;
var
  i: Integer;
  Rec: TTestRecordString;
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

  // This will remove only 1 element because all the others have the wrong Rec.y string ;-)
  // so in the end the actuall count must be the original List.Count - 1
  for i := MANY_ITEMS_COUNT downto 1 do
  begin
    Rec.x := i;
    FList.Remove(Rec);
  end;
  Assert.AreEqual(MANY_ITEMS_COUNT - 1, Integer(FList.Count));

  // Now removes everything as it should
  for i := MANY_ITEMS_COUNT downto 1 do
  begin
    Rec.x := i;
    Rec.y := 'Item' + IntToStr(i);
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

procedure TListTestRecordString.TestHuge;
var
  i: Integer;
  Rec: TTestRecordString;
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

procedure TListTestRecordString.TestBinarySearch;
var
  Index: Integer;
  Rec1, Rec2, Rec3, Rec4, Rec5, SearchRec: TTestRecordString;
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

procedure TListTestRecordString.TestPack;
var
  Rec1, Rec2, Rec3, ZeroRec: TTestRecordString;
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

procedure TListTestRecordString.TestAddRange;
var
  Rec1, Rec2, Rec3: TTestRecordString;
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

procedure TListTestRecordString.TestDeleteRange;
var
  Rec: TTestRecordString;
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

function TTestRecordStaticArrayComparer.Compare(const Left, Right: TTestRecordStaticArray): Integer;
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

procedure TListTestRecordStaticArray.SetUp;
var
  Comparer: IComparer<TTestRecordStaticArray>;
begin
  Comparer := TTestRecordStaticArrayComparer.Create;
  FList := TList<TTestRecordStaticArray>.Create(Comparer);
end;

procedure TListTestRecordStaticArray.TearDown;
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

procedure TListTestRecordStaticArray.TestAdd;
var
  Rec: TTestRecordStaticArray;
begin
  Rec.x := 10;
  FillArray(Rec.y);  // y becomes [0, 1, 2, 3, 4]
  FList.Add(Rec);
  Assert.AreEqual(1, Integer(FList.Count));
  Assert.AreEqual(10, FList[0].x);
  Assert.AreEqual(0, FList[0].y[0]);
  Assert.AreEqual(4, FList[0].y[4]);
end;

procedure TListTestRecordStaticArray.TestRemove;
var
  Rec1, Rec2: TTestRecordStaticArray;
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

procedure TListTestRecordStaticArray.TestDelete;
var
  Rec1, Rec2, Rec3: TTestRecordStaticArray;
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

procedure TListTestRecordStaticArray.TestClear;
var
  Rec: TTestRecordStaticArray;
begin
  Rec.x := 1; FillArray(Rec.y); FList.Add(Rec);
  Rec.x := 2; FillArray(Rec.y); FList.Add(Rec);
  Rec.x := 3; FillArray(Rec.y); FList.Add(Rec);
  FList.Clear;
  Assert.AreEqual(0, Integer(FList.Count));
end;

procedure TListTestRecordStaticArray.TestInsert;
var
  Rec1, Rec2: TTestRecordStaticArray;
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

procedure TListTestRecordStaticArray.TestContains;
var
  Rec: TTestRecordStaticArray;
begin
  Rec.x := 42; FillArray(Rec.y);
  FList.Add(Rec);
  Assert.IsTrue(FList.Contains(Rec));
  Rec.x := 99; FillArray(Rec.y);
  Assert.IsFalse(FList.Contains(Rec));
end;

procedure TListTestRecordStaticArray.TestCount;
var
  Rec: TTestRecordStaticArray;
begin
  Assert.AreEqual(0, Integer(FList.Count));
  Rec.x := 100; FillArray(Rec.y);
  FList.Add(Rec);
  Assert.AreEqual(1, Integer(FList.Count));
  Rec.x := 200; FillArray(Rec.y);
  FList.Add(Rec);
  Assert.AreEqual(2, Integer(FList.Count));
end;

procedure TListTestRecordStaticArray.TestMany;
var
  i: Integer;
  Rec: TTestRecordStaticArray;
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

procedure TListTestRecordStaticArray.TestHuge;
var
  i: Integer;
  Rec: TTestRecordStaticArray;
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

procedure TListTestRecordStaticArray.TestBinarySearch;
var
  Index: Integer;
  Rec1, Rec2, Rec3, Rec4, Rec5, SearchRec: TTestRecordStaticArray;
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

procedure TListTestRecordStaticArray.TestPack;
var
  Rec1, Rec2, Rec3, ZeroRec: TTestRecordStaticArray;
begin
  Rec1.x := 1; FillArray(Rec1.y);
  Rec2.x := 2; FillArray(Rec2.y);
  Rec3.x := 3; FillArray(Rec3.y);
  ZeroRec := default(TTestRecordStaticArray);
  FList.AddRange([Rec1, ZeroRec, Rec2, ZeroRec, Rec3]);
  FList.Pack;
  Assert.AreEqual(3, Integer(FList.Count));
  Assert.IsTrue(FList.Contains(Rec1) and FList.Contains(Rec2) and FList.Contains(Rec3));
end;

procedure TListTestRecordStaticArray.TestAddRange;
var
  Rec1, Rec2, Rec3: TTestRecordStaticArray;
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

procedure TListTestRecordStaticArray.TestDeleteRange;
var
  Rec: TTestRecordStaticArray;
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

{ TTestRecordDynamicComparer }

function TTestRecordDynamicComparer.Compare(const Left, Right: TTestRecordDynamicArray): Integer;
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

{ TListTestRecordDynamicArray }

procedure TListTestRecordDynamicArray.SetUp;
var
  Comparer: IComparer<TTestRecordDynamicArray>;
begin
  Comparer := TTestRecordDynamicComparer.Create;
  FList := TList<TTestRecordDynamicArray>.Create(Comparer);
end;

procedure TListTestRecordDynamicArray.TearDown;
begin
  FList.Free;
end;

procedure FillDynamicArray(var Arr: TArray<Integer>);
var
  i: Integer;
begin
  SetLength(Arr, 5);
  for i := 0 to High(Arr) do
    Arr[i] := i;
end;

procedure TListTestRecordDynamicArray.TestAdd;
var
  Rec: TTestRecordDynamicArray;
begin
  Rec.x := 10;
  FillDynamicArray(Rec.y);
  FList.Add(Rec);
  Assert.AreEqual(1, Integer(FList.Count));
  Assert.AreEqual(10, FList[0].x);
  Assert.AreEqual(0, FList[0].y[0]);
  Assert.AreEqual(4, FList[0].y[4]);
end;

procedure TListTestRecordDynamicArray.TestRemove;
var
  Rec1, Rec2: TTestRecordDynamicArray;
  idx: Integer;
begin
  Rec1.x := 10; FillDynamicArray(Rec1.y);
  Rec2.x := 20; FillDynamicArray(Rec2.y);
  FList.Add(Rec1);
  FList.Add(Rec2);
  Assert.AreEqual(2, Integer(FList.Count));
  idx := FList.Remove(Rec1);
  Assert.IsTrue(idx >= 0);
  Assert.AreEqual(1, Integer(FList.Count));
  Assert.AreEqual(20, FList[0].x);
end;

procedure TListTestRecordDynamicArray.TestDelete;
var
  Rec1, Rec2: TTestRecordDynamicArray;
begin
  Rec1.x := 10; FillDynamicArray(Rec1.y);
  Rec2.x := 20; FillDynamicArray(Rec2.y);
  FList.Add(Rec1);
  FList.Add(Rec2);
  FList.Delete(0);
  Assert.AreEqual(1, Integer(FList.Count));
  Assert.AreEqual(20, FList[0].x);
  FList.Delete(0);
  Assert.AreEqual(0, Integer(FList.Count));
end;

procedure TListTestRecordDynamicArray.TestClear;
var
  Rec: TTestRecordDynamicArray;
begin
  Rec.x := 1; FillDynamicArray(Rec.y); FList.Add(Rec);
  Rec.x := 2; FillDynamicArray(Rec.y); FList.Add(Rec);
  FList.Clear;
  Assert.AreEqual(0, Integer(FList.Count));
end;

procedure TListTestRecordDynamicArray.TestInsert;
var
  Rec1, Rec2: TTestRecordDynamicArray;
begin
  Rec1.x := 10; FillDynamicArray(Rec1.y);
  Rec2.x := 5;  FillDynamicArray(Rec2.y);
  FList.Add(Rec1);
  FList.Insert(0, Rec2);
  Assert.AreEqual(2, Integer(FList.Count));
  Assert.AreEqual(5, FList[0].x);
  Assert.AreEqual(10, FList[1].x);
end;

procedure TListTestRecordDynamicArray.TestContains;
var
  Rec: TTestRecordDynamicArray;
begin
  Rec.x := 42; FillDynamicArray(Rec.y);
  FList.Add(Rec);
  Assert.IsTrue(FList.Contains(Rec));
  Rec.x := 99; FillDynamicArray(Rec.y);
  Assert.IsFalse(FList.Contains(Rec));
end;

procedure TListTestRecordDynamicArray.TestCount;
var
  Rec: TTestRecordDynamicArray;
begin
  Assert.AreEqual(0, Integer(FList.Count));
  Rec.x := 100; FillDynamicArray(Rec.y);
  FList.Add(Rec);
  Assert.AreEqual(1, Integer(FList.Count));
end;

procedure TListTestRecordDynamicArray.TestMany;
var
  i: Integer;
  Rec: TTestRecordDynamicArray;
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

procedure TListTestRecordDynamicArray.TestHuge;
var
  i: Integer;
  Rec: TTestRecordDynamicArray;
begin
  for i := HUGE_ITEMS_COUNT downto 1 do
  begin
    Rec.x := i;
    FillDynamicArray(Rec.y);
    FList.Add(Rec);
  end;

  Assert.AreEqual(HUGE_ITEMS_COUNT, Integer(FList.Count));

  Rec.x := MaxInt; FillDynamicArray(Rec.y);
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

procedure TListTestRecordDynamicArray.TestBinarySearch;
var
  Index: Integer;
  Rec1, Rec2, Rec3, Rec4, Rec5, SearchRec: TTestRecordDynamicArray;
begin
  Rec1.x := 1; FillDynamicArray(Rec1.y);
  Rec2.x := 3; FillDynamicArray(Rec2.y);
  Rec3.x := 5; FillDynamicArray(Rec3.y);
  Rec4.x := 7; FillDynamicArray(Rec4.y);
  Rec5.x := 9; FillDynamicArray(Rec5.y);
  FList.AddRange([Rec1, Rec2, Rec3, Rec4, Rec5]);
  FList.Sort;

  SearchRec.x := 5; FillDynamicArray(SearchRec.y);
  Assert.IsTrue(FList.BinarySearch(SearchRec, Index));
  Assert.AreEqual(2, Index);

  SearchRec.x := 4; FillDynamicArray(SearchRec.y);
  Assert.IsFalse(FList.BinarySearch(SearchRec, Index));
end;

procedure TListTestRecordDynamicArray.TestPack;
var
  Rec1, Rec2, Rec3, ZeroRec: TTestRecordDynamicArray;
begin
  Rec1.x := 1; FillDynamicArray(Rec1.y);
  Rec2.x := 2; FillDynamicArray(Rec2.y);
  Rec3.x := 3; FillDynamicArray(Rec3.y);
  ZeroRec := default(TTestRecordDynamicArray);
  FList.AddRange([Rec1, ZeroRec, Rec2, ZeroRec, Rec3]);
  FList.Pack;
  Assert.AreEqual(3, Integer(FList.Count));
  Assert.IsTrue(FList.Contains(Rec1) and FList.Contains(Rec2) and FList.Contains(Rec3));
end;

procedure TListTestRecordDynamicArray.TestAddRange;
var
  Rec1, Rec2, Rec3: TTestRecordDynamicArray;
begin
  Rec1.x := 4; FillDynamicArray(Rec1.y);
  Rec2.x := 5; FillDynamicArray(Rec2.y);
  Rec3.x := 6; FillDynamicArray(Rec3.y);
  FList.AddRange([Rec1, Rec2, Rec3]);
  Assert.AreEqual(3, Integer(FList.Count));
  Assert.AreEqual(4, FList[0].x);
  Assert.AreEqual(0, FList[0].y[0]);
  Assert.AreEqual(5, FList[1].x);
  Assert.AreEqual(0, FList[1].y[0]);
end;

procedure TListTestRecordDynamicArray.TestDeleteRange;
var
  Rec: TTestRecordDynamicArray;
  i: Integer;
begin
  for i := 1 to 10 do
  begin
    Rec.x := i;
    FillDynamicArray(Rec.y);
    FList.Add(Rec);
  end;
  FList.DeleteRange(3, 4);
  Assert.AreEqual(6, Integer(FList.Count));
  Assert.AreEqual(1, FList[0].x);
  Assert.AreEqual(0, FList[0].y[0]);
  Assert.AreEqual(8, FList[3].x);
  Assert.AreEqual(0, FList[3].y[0]);
end;

{ TMyInterfacedObject }

procedure TMyInterfacedObject.DoSomeStuff;
begin
  // do nothing
end;

{ TComplexRecordListTests }

procedure TListTestRecordComplex.Setup;
begin
  FList := TList<TComplexRecord>.Create;
end;

procedure TListTestRecordComplex.TearDown;
begin
  FreeAndNil(FList);
end;

function TListTestRecordComplex.CreateComplexRecord(AID: Integer; const AName: string): TComplexRecord;
var
  Rec: TComplexRecord;
begin
  Rec.ID := AID;
  Rec.Name := AName;
  Rec.FixedArray[0] := 1;
  Rec.FixedArray[1] := 2;
  Rec.FixedArray[2] := 3;
  Rec.FixedArray[3] := 4;
  Rec.DynArray := TArray<Integer>.Create(5, 6, 7);
  Rec.VariantValue := 'TestVariant';
  Rec.EnumSet := [meRed, meBlue];
  Rec.Nested.A := 42;
  Rec.Nested.B := 'Nested';
  Rec.Intf := TMyInterfacedObject.Create;

  Result := Rec;
end;

procedure TListTestRecordComplex.TestAddRecord;
var
  Rec: TComplexRecord;
begin
  Rec := CreateComplexRecord(1, 'Test1');
  FList.Add(Rec);

  Assert.AreEqual(1, FList.Count);
  Assert.AreEqual(1, FList[0].ID);
  Assert.AreEqual('Test1', FList[0].Name);
end;

procedure TListTestRecordComplex.TestRemoveRecord;
var
  Rec: TComplexRecord;
begin
  Rec := CreateComplexRecord(1, 'Test1');
  FList.Add(Rec);
  FList.Delete(0);

  Assert.AreEqual(0, FList.Count);
end;

procedure TListTestRecordComplex.TestRecordFieldsPreserved;
var
  Rec: TComplexRecord;
  I: Integer;
begin
  Rec := CreateComplexRecord(1, 'Test1');
  FList.Add(Rec);

  Assert.AreEqual(1, FList[0].ID);
  Assert.AreEqual('Test1', FList[0].Name);

  // Test fixed array
  Assert.AreEqual(4, Length(FList[0].FixedArray));
  for I := 0 to 3 do
    Assert.AreEqual(I + 1, FList[0].FixedArray[I]);

  // Test dynamic array
  Assert.AreEqual(3, Integer(Length(FList[0].DynArray)));
  Assert.AreEqual(5, Integer(FList[0].DynArray[0]));

  // Test variant
  Assert.AreEqual('TestVariant', string(FList[0].VariantValue));

  // Test enum set
  Assert.IsTrue(meRed in FList[0].EnumSet);
  Assert.IsFalse(meGreen in FList[0].EnumSet);
  Assert.IsTrue(meBlue in FList[0].EnumSet);

  // Test nested record
  Assert.AreEqual(42, FList[0].Nested.A);
  Assert.AreEqual('Nested', FList[0].Nested.B);

  // Test interface
  Assert.IsNotNull(FList[0].Intf);
end;

procedure TListTestRecordComplex.TestListCount;
var
  I: Integer;
begin
  for I := 1 to 3 do
    FList.Add(CreateComplexRecord(I, 'Test' + I.ToString));

  Assert.AreEqual(3, FList.Count);
end;

procedure TListTestRecordComplex.TestClearList;
begin
  FList.Add(CreateComplexRecord(1, 'Test1'));
  FList.Add(CreateComplexRecord(2, 'Test2'));
  FList.Clear;

  Assert.AreEqual(0, FList.Count);
end;

procedure TListTestRecordComplex.TestBinarySearch;
var
  Index: Integer;
  Rec1, Rec2, Rec3, Rec4, Rec5, SearchRec: TComplexRecord;
  Comparer: IComparer<TComplexRecord>;
begin
  // Create a comparer that sorts by ID
  Comparer := TComparer<TComplexRecord>.Construct(
    function(const Left, Right: TComplexRecord): Integer
    begin
      Result := Left.ID - Right.ID;
    end);

  // Create and add records
  Rec1 := CreateComplexRecord(1, 'Test1');
  Rec2 := CreateComplexRecord(3, 'Test3');
  Rec3 := CreateComplexRecord(5, 'Test5');
  Rec4 := CreateComplexRecord(7, 'Test7');
  Rec5 := CreateComplexRecord(9, 'Test9');

  FList.AddRange([Rec1, Rec2, Rec3, Rec4, Rec5]);
  FList.Sort(Comparer);

  // Test finding existing record
  SearchRec := CreateComplexRecord(5, 'Test5');
  Assert.IsTrue(FList.BinarySearch(SearchRec, Index, Comparer), 'Should find existing record');
  Assert.AreEqual(2, Index, 'Index should be 2 for ID=5');

  // Test searching for non-existing record
  SearchRec := CreateComplexRecord(4, 'Test4');
  Assert.IsFalse(FList.BinarySearch(SearchRec, Index, Comparer), 'Should not find non-existing record');
end;

procedure TListTestRecordComplex.TestPack;
var
  Rec1, Rec2, Rec3, ZeroRec: TComplexRecord;
begin
  // Create records with some nil pointers to test packing
  Rec1 := CreateComplexRecord(1, 'Test1');
  Rec2 := CreateComplexRecord(2, 'Test2');
  Rec3 := CreateComplexRecord(3, 'Test3');
  ZeroRec := default(TComplexRecord);

  FList.AddRange([Rec1, ZeroRec, Rec2, ZeroRec, Rec3]);
  Assert.AreEqual(5, FList.Count, 'Initial count should be 5');

  FList.Pack;
  Assert.AreEqual(3, FList.Count, 'After pack, count should be 3');

  Flist.Clear;
  Assert.AreEqual(0, FList.Count, 'After clear, count should be 0');
end;

procedure TListTestRecordComplex.TestAddRange;
var
  Records: array of TComplexRecord;
  I: Integer;
begin
  // Create an array of records
  SetLength(Records, 3);
  for I := 0 to 2 do
    Records[I] := CreateComplexRecord(I + 1, 'Test' + IntToStr(I + 1));

  // Add range
  FList.AddRange(Records);

  Assert.AreEqual(3, FList.Count, 'Count should be 3 after AddRange');

  // Verify all records were added correctly
  for I := 0 to 2 do
  begin
    Assert.AreEqual(I + 1, FList[I].ID, 'ID should match');
    Assert.AreEqual('Test' + IntToStr(I + 1), FList[I].Name, 'Name should match');
  end;
end;

procedure TListTestRecordComplex.TestDeleteRange;
var
  Rec1, Rec2, Rec3, Rec4, Rec5: TComplexRecord;
begin
  // Add 5 records
  Rec1 := CreateComplexRecord(1, 'Test1');
  Rec2 := CreateComplexRecord(2, 'Test2');
  Rec3 := CreateComplexRecord(3, 'Test3');
  Rec4 := CreateComplexRecord(4, 'Test4');
  Rec5 := CreateComplexRecord(5, 'Test5');

  FList.AddRange([Rec1, Rec2, Rec3, Rec4, Rec5]);

  Assert.AreEqual(5, FList.Count, 'Initial count should be 5');

  // Delete 2 records starting at index 1
  FList.DeleteRange(1, 2);

  Assert.AreEqual(3, FList.Count, 'Count should be 3 after DeleteRange');

  // Verify remaining records
  Assert.AreEqual(1, FList[0].ID, 'First record should be ID 1');
  Assert.AreEqual(4, FList[1].ID, 'Second record should be ID 4');
  Assert.AreEqual(5, FList[2].ID, 'Third record should be ID 5');
end;

{$ENDIF TEST_RECORDLIST}

{$EndRegion 'TList<TTestRecord> Tests'}

{$Region 'TObjectList<TMyObject> Tests'}

{$IFDEF TEST_OBJECTLIST}

{ TMyObject }

constructor TMyObject.Create(AID: Integer);
begin
  inherited Create;
  ID := AID;
end;

destructor TMyObject.Destroy;
begin
  inherited;
end;

{ TObjectListTestObjectComparer }

function TObjectListTestObjectComparer.Compare(const Left,
  Right: TMyObject): Integer;
begin
  if (Left = nil) then
  begin
    if Right = nil then
      Exit(0)
    else
      Exit(-1);
  end
  else
  if (Right = nil) then
    Exit(1);

  Result := Left.ID - Right.ID;
end;

{ TObjectListTestObject }

procedure TObjectListTestObject.Setup;
var
  Comparer: IComparer<TMyObject>;
begin
  Comparer := TObjectListTestObjectComparer.Create;
  FList := TObjectList<TMyObject>.Create(Comparer);
end;

procedure TObjectListTestObject.TearDown;
begin
  FreeAndNil(FList);
end;

procedure TObjectListTestObject.TestAdd;
begin
  FList.Add(TMyObject.Create(10));
  Assert.AreEqual(1, FList.Count);
  Assert.AreEqual(10, FList[0].ID);
end;

procedure TObjectListTestObject.TestRemove;
var
  Obj10, Obj20: TMyObject;
begin
  Obj10 := TMyObject.Create(10);
  Obj20 := TMyObject.Create(20);
  FList.Add(Obj10);
  FList.Add(Obj20);
  Assert.AreEqual(2, FList.Count);
  Assert.IsTrue(FList.Remove(Obj10) >= 0);
  Assert.AreEqual(1, FList.Count);
  Assert.AreEqual(20, FList[0].ID);
end;

procedure TObjectListTestObject.TestDelete;
begin
  FList.Add(TMyObject.Create(10));
  FList.Add(TMyObject.Create(20));
  FList.Add(TMyObject.Create(30));
  Assert.AreEqual(3, FList.Count);
  FList.Delete(0);
  Assert.AreEqual(2, FList.Count);
  Assert.AreEqual(20, FList[0].ID);
  FList.Delete(1);
  Assert.AreEqual(1, FList.Count);
  Assert.AreEqual(20, FList[0].ID);
  FList.Delete(0);
  Assert.AreEqual(0, FList.Count);
end;

procedure TObjectListTestObject.TestClear;
begin
  FList.Add(TMyObject.Create(1));
  FList.Add(TMyObject.Create(2));
  FList.Add(TMyObject.Create(3));
  FList.Clear;
  Assert.AreEqual(0, FList.Count);
end;

procedure TObjectListTestObject.TestInsert;
begin
  FList.Add(TMyObject.Create(10));
  FList.Insert(0, TMyObject.Create(5));
  Assert.AreEqual(2, FList.Count);
  Assert.AreEqual(5, FList[0].ID);
  Assert.AreEqual(10, FList[1].ID);
end;

procedure TObjectListTestObject.TestContains;
var
  Obj: TMyObject;
  TestObj: TMyObject;
begin
  Obj := TMyObject.Create(42);
  FList.Add(Obj);
  Assert.IsTrue(FList.Contains(Obj));
  TestObj := TMyObject.Create(99);
  Assert.IsFalse(FList.Contains(TestObj)); // not added
  TestObj.Free;
end;

procedure TObjectListTestObject.TestCount;
begin
  Assert.AreEqual(0, FList.Count);
  FList.Add(TMyObject.Create(100));
  Assert.AreEqual(1, FList.Count);
  FList.Add(TMyObject.Create(200));
  Assert.AreEqual(2, FList.Count);
end;

procedure TObjectListTestObject.TestSetOwnsObjects;
var
  Obj10, Obj20: TMyObject;
begin
  Obj10 := TMyObject.Create(10);
  Obj20 := TMyObject.Create(20);
  // change OwnsObjects
  FList.OwnsObjects := False;
  FList.Add(Obj10);
  FList.Add(Obj20);
  Assert.AreEqual(2, FList.Count);
  Assert.IsTrue(FList.Remove(Obj10) >= 0);
  Assert.IsTrue(FList.Remove(Obj20) >= 0);
  // It's safe to access them because they shouldn't have been removed
  Assert.IsTrue(Obj10.ID = 10);
  Assert.IsTrue(Obj20.ID = 20);
  // Change OwnsObjects again
  FList.OwnsObjects := True;
  FList.Add(Obj10);
  FList.Add(Obj20);
  Assert.AreEqual(2, FList.Count);
  // No memory leak here
  FList.Clear;
  Assert.AreEqual(0, FList.Count);
end;

procedure TObjectListTestObject.TestPack;
begin
  FList.Add(TMyObject.Create(1));
  FList.Add(nil);
  FList.Add(TMyObject.Create(2));
  FList.Add(nil);
  FList.Add(TMyObject.Create(3));

  FList.Pack;

  Assert.AreEqual(3, FList.Count);
  Assert.IsTrue(Assigned(FList[0]) and (FList[0].ID = 1));
  Assert.IsTrue(Assigned(FList[1]) and (FList[1].ID = 2));
  Assert.IsTrue(Assigned(FList[2]) and (FList[2].ID = 3));
end;

procedure TObjectListTestObject.TestAddRange;
begin
  FList.AddRange([
    TMyObject.Create(4),
    TMyObject.Create(5),
    TMyObject.Create(6)
  ]);
  Assert.AreEqual(3, FList.Count);

  FList.AddRange([
    TMyObject.Create(1),
    TMyObject.Create(2),
    TMyObject.Create(3)
  ]);
  Assert.AreEqual(6, FList.Count);

  FList.AddRange([
    TMyObject.Create(7),
    TMyObject.Create(8),
    TMyObject.Create(9),
    TMyObject.Create(10)
  ]);
  Assert.AreEqual(10, FList.Count);
end;

procedure TObjectListTestObject.TestDeleteRange;
var
  I: Integer;
begin
  for I := 1 to 10 do
    FList.Add(TMyObject.Create(I));

  FList.DeleteRange(3, 4); // Deletes items at index 3..6

  Assert.AreEqual(6, FList.Count);

  Assert.AreEqual(1, FList[0].ID);
  Assert.AreEqual(2, FList[1].ID);
  Assert.AreEqual(3, FList[2].ID);
  Assert.AreEqual(8, FList[3].ID);
  Assert.AreEqual(9, FList[4].ID);
  Assert.AreEqual(10, FList[5].ID);
end;

procedure TObjectListTestObject.TestMany;
const
  Count = 1000;
var
  I: Integer;
begin
  for I := 1 to Count do
    FList.Add(TMyObject.Create(I));

  Assert.AreEqual(Count, FList.Count);

  for I := 0 to Count - 1 do
    Assert.AreEqual(I + 1, FList[I].ID);
end;

procedure TObjectListTestObject.TestHuge;
const
  Count = 500000;
var
  I: Integer;
begin
  for I := 1 to Count do
    FList.Add(TMyObject.Create(I));

  Assert.AreEqual(Count, FList.Count);

  // Sample a few to ensure correctness
  Assert.AreEqual(1, FList[0].ID);
  Assert.AreEqual(Count, FList.Last.ID);
  Assert.AreEqual(Count div 2, FList[Count div 2 - 1].ID);
end;

{$ENDIF TEST_OBJECTLIST}

{$EndRegion 'TObjectList<TMyObject> Tests'}

initialization
  TDUnitX.RegisterTestFixture(TListTestInteger);
  TDUnitX.RegisterTestFixture(TListTestDouble);
  TDUnitX.RegisterTestFixture(TListTestString);
  TDUnitX.RegisterTestFixture(TListTestPointer);
  TDUnitX.RegisterTestFixture(TListTestRecordString);
  TDUnitX.RegisterTestFixture(TListTestRecordStaticArray);
  TDUnitX.RegisterTestFixture(TListTestRecordDynamicArray);
  TDUnitX.RegisterTestFixture(TListTestRecordComplex);
  TDUnitX.RegisterTestFixture(TObjectListTestObject);

end.

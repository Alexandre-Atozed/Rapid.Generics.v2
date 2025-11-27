unit uArrayTest;

interface

{$DEFINE TEST_RAPIDGENERICS}

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  {$IFDEF TEST_RAPIDGENERICS}
  Rapid.Generics,
  {$ELSE}
  System.Generics.Collections,
  System.Generics.Defaults,
  {$ENDIF}
  DUnitX.TestFramework,
  uTestTypes;

type
  [TestFixture]
  TArrayTest = class
  private
    const BIG_TEST_LENGTH = 100000;
  public
    [Test]
    procedure TestSortInteger0;
    [Test]
    procedure TestSortInteger1;
    [Test]
    procedure TestSortInteger2;
    [Test]
    procedure TestSortIntegerOrdered;
    [Test]
    procedure TestSortIntegerOrderedReverse;
    [Test]
    procedure TestSortIntegerOrderedDescending;
    [Test]
    procedure TestSortIntegerOrderedReverseDescending;
    [Test]
    procedure TestSortInteger;
    [Test]
    procedure TestSortIntegerBig;
    [Test]
    procedure TestSortDescendingInteger;
    [Test]
    procedure TestSortDescendingIntegerBig;
    [Test]
    procedure TestBinarySearchInteger;
    [Test]
    procedure TestBinarySearchDescendingInteger;
    [Test]
    procedure TestIndexOfInteger;
    [Test]
    procedure TestContainsInteger;
    [Test]
    procedure TestCopyInteger;
    [Test]
    procedure TestSortDouble;
    [Test]
    procedure TestSortDoubleBig;
    [Test]
    procedure TestSortDescendingDouble;
    [Test]
    procedure TestSortDescendingDoubleBig;
    [Test]
    procedure TestBinarySearchDouble;
    [Test]
    procedure TestBinarySearchDescendingDouble;
    [Test]
    procedure TestIndexOfDouble;
    [Test]
    procedure TestContainsDouble;
    [Test]
    procedure TestCopyDouble;
    [Test]
    procedure TestSortString;
    [Test]
    procedure TestSortDescendingString;
    [Test]
    procedure TestBinarySearchString;
    [Test]
    procedure TestBinarySearchDescendingString;
    [Test]
    procedure TestIndexOfString;
    [Test]
    procedure TestContainsString;
    [Test]
    procedure TestCopyString;
    [Test]
    procedure TestSortRecordString;
    [Test]
    procedure TestSortDescendingRecordString;
    [Test]
    procedure TestBinarySearchRecordString;
    [Test]
    procedure TestBinarySearchDescendingRecordString;
    [Test]
    procedure TestIndexOfRecordString;
    [Test]
    procedure TestContainsRecordString;
    [Test]
    procedure TestCopyRecordString;
    [Test]
    procedure TestSortSmallIntBig;
    [Test]
    procedure TestSortDescendingSmallIntBig;
    [Test]
    procedure TestSortCardinalBig;
    [Test]
    procedure TestSortDescendingCardinalBig;
    [Test]
    procedure TestSortExtendedBig;
    [Test]
    procedure TestSortDescendingExtendedBig;
    [Test]
    procedure TestSortSingleBig;
    [Test]
    procedure TestSortDescendingSingleBig;
    [Test]
    procedure TestSortInt64Big;
    [Test]
    procedure TestSortDescendingInt64Big;
    [Test]
    procedure TestSortUInt64Big;
    [Test]
    procedure TestSortDescendingUInt64Big;
  end;

implementation

uses
  Math;

{ TArrayTest }

procedure TArrayTest.TestSortInteger0;
var
  Arr: TArray<Integer>;
begin
  // corner case: empty array
  Arr := [];
  TArray.Sort<Integer>(Arr);
  Assert.AreEqual(0, Integer(Length(Arr)));
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Integer>(Arr, soAscending));
end;

procedure TArrayTest.TestSortInteger1;
var
  Arr: TArray<Integer>;
begin
  // corner case: 1 element array
  Arr := [1];
  TArray.Sort<Integer>(Arr);
  Assert.AreEqual(1, Integer(Length(Arr)));
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Integer>(Arr, soAscending));
end;

procedure TArrayTest.TestSortInteger2;
var
  Arr: TArray<Integer>;
begin
  // corner case: 2 element array
  Arr := [2, 1];
  TArray.Sort<Integer>(Arr);
  Assert.AreEqual(2, Integer(Length(Arr)));
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Integer>(Arr, soAscending));
end;

procedure TArrayTest.TestSortIntegerOrdered;
var
  Arr: TArray<Integer>;
begin
   // corner case: ordered array
  Arr := [
    1, 2, 3, 4, 5, 6, 7, 8,
    9, 10, 11, 12, 13, 14, 15, 16,
    17, 18, 19, 20, 21, 22, 23, 24,
    25, 26, 27, 28, 29, 30, 31, 32
  ];
  TArray.Sort<Integer>(Arr);
  Assert.AreEqual(32, Integer(Length(Arr)));
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Integer>(Arr, soAscending));
end;

procedure TArrayTest.TestSortIntegerOrderedReverse;
var
  Arr: TArray<Integer>;
begin
  // corner case: reverse ordered array
  Arr := [
    32, 31, 30, 29, 28, 27, 26, 25,
    24, 23, 22, 21, 20, 19, 18, 17,
    16, 15, 14, 13, 12, 11, 10, 9,
    8, 7, 6, 5, 4, 3, 2, 1
  ];
  TArray.Sort<Integer>(Arr);
  Assert.AreEqual(32, Integer(Length(Arr)));
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Integer>(Arr, soAscending));
end;

procedure TArrayTest.TestSortIntegerOrderedDescending;
var
  Arr: TArray<Integer>;
begin
  // corner case: ordered array, descending
  Arr := [
    32, 31, 30, 29, 28, 27, 26, 25,
    24, 23, 22, 21, 20, 19, 18, 17,
    16, 15, 14, 13, 12, 11, 10, 9,
    8, 7, 6, 5, 4, 3, 2, 1
  ];
  TArray.SortDescending<Integer>(Arr);
  Assert.AreEqual(32, Integer(Length(Arr)));
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Integer>(Arr, soDescending));
end;

procedure TArrayTest.TestSortIntegerOrderedReverseDescending;
var
  Arr: TArray<Integer>;
begin
  // corner case: reverse ordered array, descending
  Arr := [
    1, 2, 3, 4, 5, 6, 7, 8,
    9, 10, 11, 12, 13, 14, 15, 16,
    17, 18, 19, 20, 21, 22, 23, 24,
    25, 26, 27, 28, 29, 30, 31, 32
  ];
  TArray.SortDescending<Integer>(Arr);
  Assert.AreEqual(32, Integer(Length(Arr)));
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Integer>(Arr, soDescending));
end;

procedure TArrayTest.TestSortInteger;
var
  Arr: TArray<Integer>;
begin
  Arr := [3, 1, 4, 1, 5, 9, 2, 6];
  TArray.Sort<Integer>(Arr);
  Assert.AreEqual(8, Integer(Length(Arr)));
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Integer>(Arr, soAscending));
end;

procedure TArrayTest.TestSortIntegerBig;
var
  Arr: TArray<Integer>;
begin
  Arr := TArrayBuilder.RandomInteger(BIG_TEST_LENGTH);
  TArray.Sort<Integer>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Integer>(Arr, soAscending));
end;

procedure TArrayTest.TestSortDescendingInteger;
var
  Arr: TArray<Integer>;
begin
  Arr := [3, 1, 4, 1, 5, 9, 2, 6];
  TArray.SortDescending<Integer>(Arr);
  Assert.AreEqual(8, Integer(Length(Arr)));
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Integer>(Arr, soDescending));
end;

procedure TArrayTest.TestSortDescendingIntegerBig;
var
  Arr: TArray<Integer>;
begin
  Arr := TArrayBuilder.RandomInteger(BIG_TEST_LENGTH);
  TArray.SortDescending<Integer>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Integer>(Arr, soDescending));
end;

procedure TArrayTest.TestBinarySearchInteger;
var
  Arr: TArray<Integer>;
  Index: Integer;
begin
  Arr := [1, 2, 3, 4, 5, 6, 7, 8, 9];
  Assert.IsTrue(TArray.BinarySearch<Integer>(Arr, 5, Index));
  Assert.AreEqual(4, Index);
  Assert.IsFalse(TArray.BinarySearch<Integer>(Arr, 10, Index));
end;

procedure TArrayTest.TestBinarySearchDescendingInteger;
var
  Arr: TArray<Integer>;
  Index: Integer;
begin
  Arr := [9, 8, 7, 6, 5, 4, 3, 2, 1];
  Assert.IsTrue(TArray.BinarySearchDescending<Integer>(Arr, 5, Index));
  Assert.AreEqual(4, Index);
  Assert.IsFalse(TArray.BinarySearchDescending<Integer>(Arr, 10, Index));
end;

procedure TArrayTest.TestIndexOfInteger;
var
  Arr: TArray<Integer>;
begin
  Arr := [1, 2, 3, 4, 5];
  Assert.AreEqual(2, TArray.IndexOf<Integer>(Arr, 3));
  Assert.AreEqual(-1, TArray.IndexOf<Integer>(Arr, 6));
end;

procedure TArrayTest.TestContainsInteger;
var
  Arr: TArray<Integer>;
begin
  Arr := [1, 2, 3, 4, 5];
  Assert.IsTrue(TArray.Contains<Integer>(Arr, 3));
  Assert.IsFalse(TArray.Contains<Integer>(Arr, 6));
end;

procedure TArrayTest.TestCopyInteger;
var
  Source, Dest: TArray<Integer>;
begin
  Source := [1, 2, 3, 4, 5];
  SetLength(Dest, Length(Source));
  TArray.Copy<Integer>(Source, Dest, 0, 0, Length(Source));
  Assert.AreEqual(5, Integer(Length(Dest)));
  Assert.AreEqual(1, Dest[0]);
  Assert.AreEqual(2, Dest[1]);
  Assert.AreEqual(3, Dest[2]);
  Assert.AreEqual(4, Dest[3]);
  Assert.AreEqual(5, Dest[4]);
end;

procedure TArrayTest.TestSortDouble;
var
  Arr: TArray<Double>;
begin
  Arr := [3.1, 1.5, 4.2, 1.1, 5.9, 9.0, 2.7, 6.3];
  TArray.Sort<Double>(Arr);
  Assert.AreEqual(8, Integer(Length(Arr)));
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Double>(Arr, soAscending));
end;

procedure TArrayTest.TestSortDoubleBig;
var
  Arr: TArray<Double>;
begin
  Arr := TArrayBuilder.RandomDouble(BIG_TEST_LENGTH);
  TArray.Sort<Double>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Double>(Arr, soAscending));
end;

procedure TArrayTest.TestSortDescendingDouble;
var
  Arr: TArray<Double>;
begin
  Arr := [3.1, 1.5, 4.2, 1.1, 5.9, 9.0, 2.7, 6.3];
  TArray.SortDescending<Double>(Arr);
  Assert.AreEqual(8, Integer(Length(Arr)));
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Double>(Arr, soDescending));
end;

procedure TArrayTest.TestSortDescendingDoubleBig;
var
  Arr: TArray<Double>;
begin
  Arr := TArrayBuilder.RandomDouble(BIG_TEST_LENGTH);
  TArray.SortDescending<Double>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Double>(Arr, soDescending));
end;

procedure TArrayTest.TestBinarySearchDouble;
var
  Arr: TArray<Double>;
  Index: Integer;
begin
  Arr := [1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7, 8.8, 9.9];
  Assert.IsTrue(TArray.BinarySearch<Double>(Arr, 5.5, Index));
  Assert.AreEqual(4, Index);
  Assert.IsFalse(TArray.BinarySearch<Double>(Arr, 10.0, Index));
end;

procedure TArrayTest.TestBinarySearchDescendingDouble;
var
  Arr: TArray<Double>;
  Index: Integer;
begin
  Arr := [9.9, 8.8, 7.7, 6.6, 5.5, 4.4, 3.3, 2.2, 1.1];
  Assert.IsTrue(TArray.BinarySearchDescending<Double>(Arr, 5.5, Index));
  Assert.AreEqual(4, Index);
  Assert.IsFalse(TArray.BinarySearchDescending<Double>(Arr, 10.0, Index));
end;

procedure TArrayTest.TestIndexOfDouble;
var
  Arr: TArray<Double>;
begin
  Arr := [1.1, 2.2, 3.3, 4.4, 5.5];
  Assert.AreEqual(2, TArray.IndexOf<Double>(Arr, 3.3));
  Assert.AreEqual(-1, TArray.IndexOf<Double>(Arr, 6.6));
end;

procedure TArrayTest.TestContainsDouble;
var
  Arr: TArray<Double>;
begin
  Arr := [1.1, 2.2, 3.3, 4.4, 5.5];
  Assert.IsTrue(TArray.Contains<Double>(Arr, 3.3));
  Assert.IsFalse(TArray.Contains<Double>(Arr, 6.6));
end;

procedure TArrayTest.TestCopyDouble;
var
  Source, Dest: TArray<Double>;
begin
  Source := [1.1, 2.2, 3.3, 4.4, 5.5];
  SetLength(Dest, Length(Source));
  TArray.Copy<Double>(Source, Dest, 0, 0, Length(Source));
  Assert.AreEqual(5, Integer(Length(Dest)));
  Assert.AreEqual(Double(1.1), Dest[0]);
  Assert.AreEqual(Double(2.2), Dest[1]);
  Assert.AreEqual(Double(3.3), Dest[2]);
  Assert.AreEqual(Double(4.4), Dest[3]);
  Assert.AreEqual(Double(5.5), Dest[4]);
end;

procedure TArrayTest.TestSortString;
var
  Arr: TArray<string>;
begin
  Arr := ['c', 'a', 'd', 'b'];
  TArray.Sort<string>(Arr);
  Assert.AreEqual(4, Integer(Length(Arr)));
  Assert.AreEqual('a', Arr[0]);
  Assert.AreEqual('b', Arr[1]);
  Assert.AreEqual('c', Arr[2]);
  Assert.AreEqual('d', Arr[3]);
end;

procedure TArrayTest.TestSortDescendingString;
var
  Arr: TArray<string>;
begin
  Arr := ['c', 'a', 'd', 'b'];
  TArray.SortDescending<string>(Arr);
  Assert.AreEqual(4, Integer(Length(Arr)));
  Assert.AreEqual('d', Arr[0]);
  Assert.AreEqual('c', Arr[1]);
  Assert.AreEqual('b', Arr[2]);
  Assert.AreEqual('a', Arr[3]);
end;

procedure TArrayTest.TestBinarySearchString;
var
  Arr: TArray<string>;
  Index: Integer;
begin
  Arr := ['a', 'b', 'c', 'd', 'e'];
  Assert.IsTrue(TArray.BinarySearch<string>(Arr, 'c', Index));
  Assert.AreEqual(2, Index);
  Assert.IsFalse(TArray.BinarySearch<string>(Arr, 'z', Index));
end;

procedure TArrayTest.TestBinarySearchDescendingString;
var
  Arr: TArray<string>;
  Index: Integer;
begin
  Arr := ['e', 'd', 'c', 'b', 'a'];
  Assert.IsTrue(TArray.BinarySearchDescending<string>(Arr, 'c', Index));
  Assert.AreEqual(2, Index);
  Assert.IsFalse(TArray.BinarySearchDescending<string>(Arr, 'z', Index));
end;

procedure TArrayTest.TestIndexOfString;
var
  Arr: TArray<string>;
begin
  Arr := ['a', 'b', 'c'];
  Assert.AreEqual(1, TArray.IndexOf<string>(Arr, 'b'));
  Assert.AreEqual(-1, TArray.IndexOf<string>(Arr, 'z'));
end;

procedure TArrayTest.TestContainsString;
var
  Arr: TArray<string>;
begin
  Arr := ['a', 'b', 'c'];
  Assert.IsTrue(TArray.Contains<string>(Arr, 'b'));
  Assert.IsFalse(TArray.Contains<string>(Arr, 'z'));
end;

procedure TArrayTest.TestCopyString;
var
  Source, Dest: TArray<string>;
begin
  Source := ['a', 'b', 'c'];
  SetLength(Dest, Length(Source));
  TArray.Copy<string>(Source, Dest, 0, 0, Length(Source));
  Assert.AreEqual(3, Integer(Length(Dest)));
  Assert.AreEqual('a', Dest[0]);
  Assert.AreEqual('b', Dest[1]);
  Assert.AreEqual('c', Dest[2]);
end;

procedure TArrayTest.TestSortRecordString;
var
  Arr: TArray<TTestRecordString>;
  Comparer: IComparer<TTestRecordString>;
begin
  Comparer := TTestRecordStringComparer.Create;
  SetLength(Arr, 4);
  Arr[0].x := 3;
  Arr[0].y := 'c';
  Arr[1].x := 1;
  Arr[1].y := 'a';
  Arr[2].x := 2;
  Arr[2].y := 'b';
  Arr[3].x := 1;
  Arr[3].y := 'z';
  TArray.Sort<TTestRecordString>(Arr, Comparer);
  Assert.AreEqual(4, Integer(Length(Arr)));
  Assert.AreEqual(1, Arr[0].x);
  Assert.AreEqual('a', Arr[0].y);
  Assert.AreEqual(1, Arr[1].x);
  Assert.AreEqual('z', Arr[1].y);
  Assert.AreEqual(2, Arr[2].x);
  Assert.AreEqual('b', Arr[2].y);
  Assert.AreEqual(3, Arr[3].x);
  Assert.AreEqual('c', Arr[3].y);
end;

procedure TArrayTest.TestSortDescendingRecordString;
var
  Arr: TArray<TTestRecordString>;
  Comparer: IComparer<TTestRecordString>;
begin
  Comparer := TTestRecordStringComparer.Create;
  SetLength(Arr, 4);
  Arr[0].x := 3;
  Arr[0].y := 'c';
  Arr[1].x := 1;
  Arr[1].y := 'a';
  Arr[2].x := 2;
  Arr[2].y := 'b';
  Arr[3].x := 1;
  Arr[3].y := 'z';
  TArray.SortDescending<TTestRecordString>(Arr, Comparer);
  Assert.AreEqual(4, Integer(Length(Arr)));
  Assert.AreEqual(3, Arr[0].x);
  Assert.AreEqual('c', Arr[0].y);
  Assert.AreEqual(2, Arr[1].x);
  Assert.AreEqual('b', Arr[1].y);
  Assert.AreEqual(1, Arr[2].x);
  Assert.AreEqual('z', Arr[2].y);
  Assert.AreEqual(1, Arr[3].x);
  Assert.AreEqual('a', Arr[3].y);
end;

procedure TArrayTest.TestBinarySearchRecordString;
var
  Arr: TArray<TTestRecordString>;
  Index: Integer;
  Comparer: IComparer<TTestRecordString>;
  SearchItem: TTestRecordString;
begin
  Comparer := TTestRecordStringComparer.Create;
  SetLength(Arr, 4);
  Arr[0].x := 1;
  Arr[0].y := 'a';
  Arr[1].x := 2;
  Arr[1].y := 'b';
  Arr[2].x := 3;
  Arr[2].y := 'c';
  Arr[3].x := 4;
  Arr[3].y := 'd';
  SearchItem.x := 3;
  SearchItem.y := 'c';
  Assert.IsTrue(TArray.BinarySearch<TTestRecordString>(Arr, SearchItem, Index, Comparer));
  Assert.AreEqual(2, Index);
  SearchItem.x := 5;
  SearchItem.y := 'e';
  Assert.IsFalse(TArray.BinarySearch<TTestRecordString>(Arr, SearchItem, Index, Comparer));
end;

procedure TArrayTest.TestBinarySearchDescendingRecordString;
var
  Arr: TArray<TTestRecordString>;
  Index: Integer;
  Comparer: IComparer<TTestRecordString>;
  SearchItem: TTestRecordString;
begin
  Comparer := TTestRecordStringComparer.Create;
  SetLength(Arr, 4);
  Arr[0].x := 4;
  Arr[0].y := 'd';
  Arr[1].x := 3;
  Arr[1].y := 'c';
  Arr[2].x := 2;
  Arr[2].y := 'b';
  Arr[3].x := 1;
  Arr[3].y := 'a';
  SearchItem.x := 3;
  SearchItem.y := 'c';
  Assert.IsTrue(TArray.BinarySearchDescending<TTestRecordString>(Arr, SearchItem, Index, Comparer));
  Assert.AreEqual(1, Index);
  SearchItem.x := 5;
  SearchItem.y := 'e';
  Assert.IsFalse(TArray.BinarySearchDescending<TTestRecordString>(Arr, SearchItem, Index, Comparer));
end;

procedure TArrayTest.TestIndexOfRecordString;
var
  Arr: TArray<TTestRecordString>;
  SearchItem: TTestRecordString;
  Comparer: IComparer<TTestRecordString>;
begin
  Comparer := TTestRecordStringComparer.Create;
  SetLength(Arr, 3);
  Arr[0].x := 1;
  Arr[0].y := 'a';
  Arr[1].x := 2;
  Arr[1].y := 'b';
  Arr[2].x := 3;
  Arr[2].y := 'c';
  SearchItem.x := 2;
  SearchItem.y := 'b';
  Assert.AreEqual(1, TArray.IndexOf<TTestRecordString>(Arr, SearchItem, Comparer));
  SearchItem.x := 4;
  SearchItem.y := 'd';
  Assert.AreEqual(-1, TArray.IndexOf<TTestRecordString>(Arr, SearchItem, Comparer));
end;

procedure TArrayTest.TestContainsRecordString;
var
  Arr: TArray<TTestRecordString>;
  SearchItem: TTestRecordString;
  Comparer: IComparer<TTestRecordString>;
begin
  Comparer := TTestRecordStringComparer.Create;
  SetLength(Arr, 3);
  Arr[0].x := 1;
  Arr[0].y := 'a';
  Arr[1].x := 2;
  Arr[1].y := 'b';
  Arr[2].x := 3;
  Arr[2].y := 'c';
  SearchItem.x := 2;
  SearchItem.y := 'b';
  Assert.IsTrue(TArray.Contains<TTestRecordString>(Arr, SearchItem, Comparer));
  SearchItem.x := 4;
  SearchItem.y := 'd';
  Assert.IsFalse(TArray.Contains<TTestRecordString>(Arr, SearchItem, Comparer));
end;

procedure TArrayTest.TestCopyRecordString;
var
  Source, Dest: TArray<TTestRecordString>;
begin
  SetLength(Source, 3);
  Source[0].x := 1;
  Source[0].y := 'a';
  Source[1].x := 2;
  Source[1].y := 'b';
  Source[2].x := 3;
  Source[2].y := 'c';
  SetLength(Dest, Length(Source));
  TArray.Copy<TTestRecordString>(Source, Dest, 0, 0, Length(Source));
  Assert.AreEqual(3, Integer(Length(Dest)));
  Assert.AreEqual(1, Dest[0].x);
  Assert.AreEqual('a', Dest[0].y);
  Assert.AreEqual(2, Dest[1].x);
  Assert.AreEqual('b', Dest[1].y);
  Assert.AreEqual(3, Dest[2].x);
  Assert.AreEqual('c', Dest[2].y);
end;

procedure TArrayTest.TestSortSmallIntBig;
var
  Arr: TArray<SmallInt>;
begin
  Arr := TArrayBuilder.RandomSmallInt(BIG_TEST_LENGTH);
  TArray.Sort<SmallInt>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<SmallInt>(Arr, soAscending));
end;

procedure TArrayTest.TestSortDescendingSmallIntBig;
var
  Arr: TArray<SmallInt>;
begin
  Arr := TArrayBuilder.RandomSmallInt(BIG_TEST_LENGTH);
  TArray.SortDescending<SmallInt>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<SmallInt>(Arr, soDescending));
end;

procedure TArrayTest.TestSortCardinalBig;
var
  Arr: TArray<Cardinal>;
begin
  Arr := TArrayBuilder.RandomCardinal(BIG_TEST_LENGTH);
  TArray.Sort<Cardinal>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Cardinal>(Arr, soAscending));
end;

procedure TArrayTest.TestSortDescendingCardinalBig;
var
  Arr: TArray<Cardinal>;
begin
  Arr := TArrayBuilder.RandomCardinal(BIG_TEST_LENGTH);
  TArray.SortDescending<Cardinal>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Cardinal>(Arr, soDescending));
end;

procedure TArrayTest.TestSortExtendedBig;
var
  Arr: TArray<Extended>;
begin
  Arr := TArrayBuilder.RandomExtended(BIG_TEST_LENGTH);
  TArray.Sort<Extended>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Extended>(Arr, soAscending));
end;

procedure TArrayTest.TestSortDescendingExtendedBig;
var
  Arr: TArray<Extended>;
begin
  Arr := TArrayBuilder.RandomExtended(BIG_TEST_LENGTH);
  TArray.SortDescending<Extended>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Extended>(Arr, soDescending));
end;

procedure TArrayTest.TestSortSingleBig;
var
  Arr: TArray<Single>;
begin
  Arr := TArrayBuilder.RandomSingle(BIG_TEST_LENGTH);
  TArray.Sort<Single>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Single>(Arr, soAscending));
end;

procedure TArrayTest.TestSortDescendingSingleBig;
var
  Arr: TArray<Single>;
begin
  Arr := TArrayBuilder.RandomSingle(BIG_TEST_LENGTH);
  TArray.SortDescending<Single>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Single>(Arr, soDescending));
end;

procedure TArrayTest.TestSortInt64Big;
var
  Arr: TArray<Int64>;
begin
  Arr := TArrayBuilder.RandomInt64(BIG_TEST_LENGTH);
  TArray.Sort<Int64>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Int64>(Arr, soAscending));
end;

procedure TArrayTest.TestSortDescendingInt64Big;
var
  Arr: TArray<Int64>;
begin
  Arr := TArrayBuilder.RandomInt64(BIG_TEST_LENGTH);
  TArray.SortDescending<Int64>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<Int64>(Arr, soDescending));
end;

procedure TArrayTest.TestSortUInt64Big;
var
  Arr: TArray<UInt64>;
begin
  Arr := TArrayBuilder.RandomUInt64(BIG_TEST_LENGTH);
  TArray.Sort<UInt64>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<UInt64>(Arr, soAscending));
end;

procedure TArrayTest.TestSortDescendingUInt64Big;
var
  Arr: TArray<UInt64>;
begin
  Arr := TArrayBuilder.RandomUInt64(BIG_TEST_LENGTH);
  TArray.SortDescending<UInt64>(Arr);
  Assert.IsTrue(Length(Arr) = BIG_TEST_LENGTH);
  Assert.IsTrue(TArrayBuilder.IsArraySorted<UInt64>(Arr, soDescending));
end;

initialization
  TDUnitX.RegisterTestFixture(TArrayTest);

end.

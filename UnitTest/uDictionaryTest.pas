unit uDictionaryTest;

{$DEFINE TEST_RAPIDGENERICS}

interface

uses
  System.SysUtils,
  System.Classes,
  {$IFDEF TEST_RAPIDGENERICS}
  Rapid.Generics,
  {$ELSE}
  System.Generics.Collections,
  {$ENDIF}
  DUnitX.TestFramework,
  uTestTypes;

type
  [TestFixture]
  TDictionaryISTest = class
  private
    FDictionary: TDictionary<Integer, string>;
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
    procedure TestFind;
    [Test]
    procedure TestFindOrAdd;
    [Test]
    procedure TestExtractPair;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestAddOrSetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestMany;
  end;

  [TestFixture]
  TDictionarySSTest = class
  private
    FDictionary: TDictionary<string, string>;
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
    procedure TestFind;
    [Test]
    procedure TestFindOrAdd;
    [Test]
    procedure TestExtractPair;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestAddOrSetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestMany;
  end;

  [TestFixture]
  TDictionaryIITest = class
  private
    FDictionary: TDictionary<Integer, Integer>;
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
    procedure TestFind;
    [Test]
    procedure TestFindOrAdd;
    [Test]
    procedure TestExtractPair;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestAddOrSetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestMany;
  end;

  [TestFixture]
  TDictionaryIDTest = class
  private
    FDictionary: TDictionary<Integer, Double>;
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
    procedure TestFind;
    [Test]
    procedure TestFindOrAdd;
    [Test]
    procedure TestExtractPair;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestAddOrSetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestMany;
  end;

  [TestFixture]
  TDictionaryIPTest = class
  private
    FDictionary: TDictionary<Integer, Pointer>;
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
    procedure TestFind;
    [Test]
    procedure TestFindOrAdd;
    [Test]
    procedure TestExtractPair;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestAddOrSetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestMany;
  end;

  [TestFixture]
  TDictionaryIIntfTest = class
  private
    FDictionary: TDictionary<Integer, ITestInterface>;
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
    procedure TestFind;
    [Test]
    procedure TestFindOrAdd;
    [Test]
    procedure TestExtractPair;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestAddOrSetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestMany;
  end;

  [TestFixture]
  TObjectDictionaryIOTest = class
  private
    FDictionary: TObjectDictionary<Integer, TTestObject>;
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
    procedure TestFind;
    [Test]
    procedure TestFindOrAdd;
    [Test]
    procedure TestExtractPair;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestAddOrSetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestMany;
  end;

  TCustomObjectDictionary = class(TObjectDictionary<Integer, TTestObject>)
  protected
    procedure KeyNotify(const Key: Integer; Action: TCollectionNotification); override;
    procedure ValueNotify(const Value: TTestObject; Action: TCollectionNotification); override;
  end;

  [TestFixture]
  TCustomObjectDictionaryIOTest = class
  private
    FDictionary: TCustomObjectDictionary;
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
    procedure TestFind;
    [Test]
    procedure TestFindOrAdd;
    [Test]
    procedure TestExtractPair;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestAddOrSetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestMany;
  end;

  [TestFixture]
  TObjectDictionaryOITest = class
  private
    FDictionary: TObjectDictionary<TTestObject, Integer>;
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
    procedure TestFind;
    [Test]
    procedure TestFindOrAdd;
    [Test]
    procedure TestExtractPair;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestAddOrSetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestMany;
  end;

  TCustomObjectDictionary2 = class(TObjectDictionary<TTestObject, Integer>)
  protected
    procedure KeyNotify(const Key: TTestObject; Action: TCollectionNotification); override;
    procedure ValueNotify(const Value: Integer; Action: TCollectionNotification); override;
  end;

  [TestFixture]
  TCustomObjectDictionaryOITest = class
  private
    FDictionary: TCustomObjectDictionary2;
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
    procedure TestFind;
    [Test]
    procedure TestFindOrAdd;
    [Test]
    procedure TestExtractPair;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestAddOrSetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestMany;
  end;

type
  TTestRecord = record
    Field1: Integer;
    Field2: Integer;
  end;

  [TestFixture]
  TRecordDictionaryITest = class
  private
    FDictionary: TDictionary<TTestRecord, Integer>;
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
    procedure TestFind;
    [Test]
    procedure TestFindOrAdd;
    [Test]
    procedure TestExtractPair;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestAddOrSetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestDuplicateKey;
    [Test]
    procedure TestDifferentRecordsSameFirstField;
    [Test]
    procedure TestDifferentRecordsSameSecondField;
    [Test]
    procedure TestOverwriteValue;
    [Test]
    procedure TestMany;

    // Additional stress tests
    [Test]
    procedure TestNegativeValues;
    [Test]
    procedure TestZeroValues;
    [Test]
    procedure TestMinMaxValues;
    [Test]
    procedure TestSwappedFields;
    [Test]
    procedure TestManySameFirstField;
    [Test]
    procedure TestInsertRemoveInsert;
    [Test]
    procedure TestRandomized;
  end;

  TTestObject2 = class
  private
    FValue: Integer;
  public
    constructor Create(const AValue: Integer);
    property Value: Integer read FValue write FValue;
  end;

  [TestFixture]
  TObjectDictionaryITest = class
  private
    FDictionary: TObjectDictionary<TTestRecord, TTestObject2>;

    function MakeKey(const AField1, AField2: Integer): TTestRecord;
    function MakeValue(const AValue: Integer): TTestObject2;
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
    procedure TestFind;
    [Test]
    procedure TestFindOrAdd;
    [Test]
    procedure TestExtractPair;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestAddOrSetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestDuplicateKey;
    [Test]
    procedure TestDifferentRecordsSameFirstField;
    [Test]
    procedure TestDifferentRecordsSameSecondField;
    [Test]
    procedure TestOverwriteValue;
    [Test]
    procedure TestMany;
    [Test]
    procedure TestNegativeValues;
    [Test]
    procedure TestZeroValues;
    [Test]
    procedure TestMinMaxValues;
    [Test]
    procedure TestSwappedFields;
    [Test]
    procedure TestManySameFirstField;
    [Test]
    procedure TestInsertRemoveInsert;
    [Test]
    procedure TestRandomized;

    // Ownership / lifetime tests
    [Test]
    procedure TestDictionaryOwnsValues;
    [Test]
    procedure TestRemoveDestroysValue;
    [Test]
    procedure TestExtractPairTransfersValueOwnership;
  end;

  TTestRecord4 = packed record
    Field1: SmallInt;
    Field2: SmallInt;
  end;

  TObjectDictionary4ByteITest = class
  private
    FDictionary: TObjectDictionary<TTestRecord4, TTestObject2>;
    function MakeKey(const AField1, AField2: SmallInt): TTestRecord4;
    function MakeValue(const AValue: Integer): TTestObject2;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestRecordSize;
    [Test]
    procedure TestFind;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestRemove;
    [Test]
    procedure TestDuplicateKey;
    [Test]
    procedure TestDifferentRecordsSameFirstField;
    [Test]
    procedure TestDifferentRecordsSameSecondField;
    [Test]
    procedure TestNegativeValues;
    [Test]
    procedure TestMinMaxValues;
    [Test]
    procedure TestMany;
    [Test]
    procedure TestOverwriteValue;
    [Test]
    procedure TestExtractPair;
  end;

type
  TTestRecord2 = packed record
    Field1: Byte;
    Field2: Byte;
  end;

  TObjectDictionary2ByteITest = class
  private
    FDictionary: TObjectDictionary<TTestRecord2, TTestObject2>;
    function MakeKey(const AField1, AField2: Byte): TTestRecord2;
    function MakeValue(const AValue: Integer): TTestObject2;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestRecordSize;
    [Test]
    procedure TestFind;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestRemove;
    [Test]
    procedure TestDuplicateKey;
    [Test]
    procedure TestDifferentRecordsSameFirstField;
    [Test]
    procedure TestDifferentRecordsSameSecondField;
    [Test]
    procedure TestZeroValues;
    [Test]
    procedure TestMinMaxValues;
    [Test]
    procedure TestMany;
    [Test]
    procedure TestOverwriteValue;
    [Test]
    procedure TestExtractPair;
  end;

  TSomeKind = (
    kind1,  kind2,  kind3,  kind4,  kind5,  kind6,
    kind7,  kind8,  kind9,  kind10, kind11,
    kind12, kind13, kind14, kind15, kind16, kind17,
    kind18, kind19, kind20, kind21, kind22,
    kind23, kind24, kind25, kind26, kind27,
    kind28, kind29, kind30, kind31
  );

  TDictionarySetTest = class
  private
    FDictionary: TDictionary<Pointer, TSomeKind>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestAdd;
    [Test]
    procedure TestRecordSize;
    [Test]
    procedure TestFind;
    [Test]
    procedure TestTryGetValue;
    [Test]
    procedure TestContainsKey;
    [Test]
    procedure TestRemove;
    [Test]
    procedure TestDuplicateKey;
    [Test]
    procedure TestDifferentRecordsSameFirstField;
    [Test]
    procedure TestDifferentRecordsSameSecondField;
    [Test]
    procedure TestZeroValues;
    [Test]
    procedure TestMinMaxValues;
    [Test]
    procedure TestMany;
    [Test]
    procedure TestOverwriteValue;
    [Test]
    procedure TestExtractPair;
  end;

  TDictionaryClassTest = class
  private
    FDictionary: TDictionary<TClass, Integer>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestAdd;
  end;

implementation

uses
  Windows;

{$REGION 'TDictionaryISTest' }

procedure TDictionaryISTest.Setup;
begin
  FDictionary := TDictionary<Integer, string>.Create;
end;

procedure TDictionaryISTest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TDictionaryISTest.TestAdd;
begin
  FDictionary.Add(1, 'One');
  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual('One', FDictionary.Items[1]);
end;

procedure TDictionaryISTest.TestRemove;
begin
  FDictionary.Add(1, 'One');
  FDictionary.Remove(1);
  Assert.IsFalse(FDictionary.ContainsKey(1));
end;

procedure TDictionaryISTest.TestFind;
begin
  {$IFDEF TEST_RAPIDGENERICS}
  FDictionary.Add(1, 'One');
  Assert.IsNotNull(FDictionary.Find(1));
  {$ENDIF}
end;

procedure TDictionaryISTest.TestFindOrAdd;
begin
  {$IFDEF TEST_RAPIDGENERICS}
  var P := FDictionary.FindOrAdd(2);
  Assert.IsNotNull(P);
  {$ENDIF}
end;

procedure TDictionaryISTest.TestExtractPair;
begin
  FDictionary.Add(3, 'Three');
  var Pair := FDictionary.ExtractPair(3);
  Assert.AreEqual(3, Pair.Key);
  Assert.AreEqual('Three', Pair.Value);
  Assert.IsFalse(FDictionary.ContainsKey(3));
end;

procedure TDictionaryISTest.TestTryGetValue;
begin
  FDictionary.Add(4, 'Four');
  var Value: string;
  Assert.IsTrue(FDictionary.TryGetValue(4, Value));
  Assert.AreEqual('Four', Value);
end;

procedure TDictionaryISTest.TestAddOrSetValue;
begin
  FDictionary.AddOrSetValue(5, 'Five');
  Assert.AreEqual('Five', FDictionary.Items[5]);
  FDictionary.AddOrSetValue(5, 'NewFive');
  Assert.AreEqual('NewFive', FDictionary.Items[5]);
end;

procedure TDictionaryISTest.TestContainsKey;
begin
  FDictionary.Add(6, 'Six');
  Assert.IsTrue(FDictionary.ContainsKey(6));
  Assert.IsFalse(FDictionary.ContainsKey(7));
end;

procedure TDictionaryISTest.TestMany;
const
  ItemCount = 100000;
var
  I: Integer;
  Value: string;
begin
  // Add items
  for I := 1 to ItemCount do
    FDictionary.Add(I, 'Value' + I.ToString);
  Assert.AreEqual(ItemCount, FDictionary.Count);

  // Verify all items exist
  for I := 1 to ItemCount do
  begin
    Assert.IsTrue(FDictionary.TryGetValue(I, Value));
    Assert.AreEqual('Value' + I.ToString, Value);
  end;

  // Remove all items
  for I := 1 to ItemCount do
    FDictionary.Remove(I);
  Assert.AreEqual(0, FDictionary.Count);
end;

{$ENDREGION 'TDictionaryISTest' }

{$REGION 'TDictionarySSTest' }

procedure TDictionarySSTest.Setup;
begin
  FDictionary := TDictionary<string, string>.Create;
end;

procedure TDictionarySSTest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TDictionarySSTest.TestAdd;
begin
  FDictionary.Add('Key1', 'One');
  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual('One', FDictionary.Items['Key1']);
end;

procedure TDictionarySSTest.TestRemove;
begin
  FDictionary.Add('Key1', 'One');
  FDictionary.Remove('Key1');
  Assert.IsFalse(FDictionary.ContainsKey('Key1'));
end;

procedure TDictionarySSTest.TestFind;
begin
  {$IFDEF TEST_RAPIDGENERICS}
  FDictionary.Add('Key1', 'One');
  Assert.IsNotNull(FDictionary.Find('Key1'));
  {$ENDIF}
end;

procedure TDictionarySSTest.TestFindOrAdd;
begin
  {$IFDEF TEST_RAPIDGENERICS}
  var P := FDictionary.FindOrAdd('Key2');
  Assert.IsNotNull(P);
  {$ENDIF}
end;

procedure TDictionarySSTest.TestExtractPair;
begin
  FDictionary.Add('Key3', 'Three');
  var Pair := FDictionary.ExtractPair('Key3');
  Assert.AreEqual('Key3', Pair.Key);
  Assert.AreEqual('Three', Pair.Value);
  Assert.IsFalse(FDictionary.ContainsKey('Key3'));
end;

procedure TDictionarySSTest.TestTryGetValue;
begin
  FDictionary.Add('Key4', 'Four');
  var Value: string;
  Assert.IsTrue(FDictionary.TryGetValue('Key4', Value));
  Assert.AreEqual('Four', Value);
end;

procedure TDictionarySSTest.TestAddOrSetValue;
begin
  FDictionary.AddOrSetValue('Key5', 'Five');
  Assert.AreEqual('Five', FDictionary.Items['Key5']);
  FDictionary.AddOrSetValue('Key5', 'NewFive');
  Assert.AreEqual('NewFive', FDictionary.Items['Key5']);
end;

procedure TDictionarySSTest.TestContainsKey;
begin
  FDictionary.Add('Key6', 'Six');
  Assert.IsTrue(FDictionary.ContainsKey('Key6'));
  Assert.IsFalse(FDictionary.ContainsKey('Key7'));
end;

procedure TDictionarySSTest.TestMany;
const
  ItemCount = 100000;
var
  I: Integer;
  Value: string;
begin
  // Add items
  for I := 1 to ItemCount do
    FDictionary.Add('Key' + I.ToString, 'Value' + I.ToString);
  Assert.AreEqual(ItemCount, FDictionary.Count);

  // Verify all items exist
  for I := 1 to ItemCount do
  begin
    Assert.IsTrue(FDictionary.TryGetValue('Key' + I.ToString, Value));
    Assert.AreEqual('Value' + I.ToString, Value);
  end;

  // Remove all items
  for I := 1 to ItemCount do
    FDictionary.Remove('Key' + I.ToString);
  Assert.AreEqual(0, FDictionary.Count);
end;

{$ENDREGION 'TDictionarySSTest' }

{$REGION 'TDictionaryIITest' }

procedure TDictionaryIITest.Setup;
begin
  FDictionary := TDictionary<Integer, Integer>.Create;
end;

procedure TDictionaryIITest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TDictionaryIITest.TestAdd;
begin
  FDictionary.Add(1, 11);
  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(11, FDictionary.Items[1]);
end;

procedure TDictionaryIITest.TestRemove;
begin
  FDictionary.Add(1, 11);
  FDictionary.Remove(1);
  Assert.IsFalse(FDictionary.ContainsKey(1));
end;

procedure TDictionaryIITest.TestFind;
begin
  {$IFDEF TEST_RAPIDGENERICS}
  FDictionary.Add(1, 11);
  Assert.IsNotNull(FDictionary.Find(1));
  {$ENDIF}
end;

procedure TDictionaryIITest.TestFindOrAdd;
begin
  {$IFDEF TEST_RAPIDGENERICS}
  var P := FDictionary.FindOrAdd(2);
  Assert.IsNotNull(P);
  {$ENDIF}
end;

procedure TDictionaryIITest.TestExtractPair;
begin
  FDictionary.Add(3, 33);
  var Pair := FDictionary.ExtractPair(3);
  Assert.AreEqual(3, Pair.Key);
  Assert.AreEqual(33, Pair.Value);
  Assert.IsFalse(FDictionary.ContainsKey(3));
end;

procedure TDictionaryIITest.TestTryGetValue;
begin
  FDictionary.Add(4, 44);
  var Value: Integer;
  Assert.IsTrue(FDictionary.TryGetValue(4, Value));
  Assert.AreEqual(44, Value);
end;

procedure TDictionaryIITest.TestAddOrSetValue;
begin
  FDictionary.AddOrSetValue(5, 55);
  Assert.AreEqual(55, FDictionary.Items[5]);
  FDictionary.AddOrSetValue(5, 56);
  Assert.AreEqual(56, FDictionary.Items[5]);
end;

procedure TDictionaryIITest.TestContainsKey;
begin
  FDictionary.Add(6, 66);
  Assert.IsTrue(FDictionary.ContainsKey(6));
  Assert.IsFalse(FDictionary.ContainsKey(7));
end;

procedure TDictionaryIITest.TestMany;
const
  ItemCount = 100000;
var
  I: Integer;
  Value: Integer;
begin
  // Add items
  for I := 1 to ItemCount do
    FDictionary.Add(I, I * 10 + I);
  Assert.AreEqual(ItemCount, FDictionary.Count);

  // Verify all items exist
  for I := 1 to ItemCount do
  begin
    Assert.IsTrue(FDictionary.TryGetValue(I, Value));
    Assert.AreEqual(I * 10 + I, Value);
  end;

  // Remove all items
  for I := 1 to ItemCount do
    FDictionary.Remove(I);
  Assert.AreEqual(0, FDictionary.Count);
end;

{$ENDREGION 'TDictionaryIITest' }

{$REGION 'TDictionaryIDTest' }

procedure TDictionaryIDTest.Setup;
begin
  FDictionary := TDictionary<Integer, Double>.Create;
end;

procedure TDictionaryIDTest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TDictionaryIDTest.TestAdd;
begin
  FDictionary.Add(1, 11.1);
  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(Double(11.1), FDictionary.Items[1]);
end;

procedure TDictionaryIDTest.TestRemove;
begin
  FDictionary.Add(1, 11.1);
  FDictionary.Remove(1);
  Assert.IsFalse(FDictionary.ContainsKey(1));
end;

procedure TDictionaryIDTest.TestFind;
begin
  {$IFDEF TEST_RAPIDGENERICS}
  FDictionary.Add(1, 11.1);
  Assert.IsNotNull(FDictionary.Find(1));
  {$ENDIF}
end;

procedure TDictionaryIDTest.TestFindOrAdd;
begin
  {$IFDEF TEST_RAPIDGENERICS}
  var P := FDictionary.FindOrAdd(2);
  Assert.IsNotNull(P);
  {$ENDIF}
end;

procedure TDictionaryIDTest.TestExtractPair;
begin
  FDictionary.Add(3, 33.3);
  var Pair := FDictionary.ExtractPair(3);
  Assert.AreEqual(3, Pair.Key);
  Assert.AreEqual(Double(33.3), Pair.Value);
  Assert.IsFalse(FDictionary.ContainsKey(3));
end;

procedure TDictionaryIDTest.TestTryGetValue;
begin
  FDictionary.Add(4, 44.4);
  var Value: Double;
  Assert.IsTrue(FDictionary.TryGetValue(4, Value));
  Assert.AreEqual(Double(44.4), Value);
end;

procedure TDictionaryIDTest.TestAddOrSetValue;
begin
  FDictionary.AddOrSetValue(5, 55.5);
  Assert.AreEqual(Double(55.5), FDictionary.Items[5]);
  FDictionary.AddOrSetValue(5, 56.6);
  Assert.AreEqual(Double(56.6), FDictionary.Items[5]);
end;

procedure TDictionaryIDTest.TestContainsKey;
begin
  FDictionary.Add(6, 66.6);
  Assert.IsTrue(FDictionary.ContainsKey(6));
  Assert.IsFalse(FDictionary.ContainsKey(7));
end;

procedure TDictionaryIDTest.TestMany;
const
  ItemCount = 100000;
var
  I: Integer;
  Value: Double;
begin
  // Add items
  for I := 1 to ItemCount do
    FDictionary.Add(I, I * 10 + I + (I / 10));
  Assert.AreEqual(ItemCount, FDictionary.Count);

  // Verify all items exist
  for I := 1 to ItemCount do
  begin
    Assert.IsTrue(FDictionary.TryGetValue(I, Value));
    Assert.AreEqual(Double(I * 10 + I + (I / 10)), Value);
  end;

  // Remove all items
  for I := 1 to ItemCount do
    FDictionary.Remove(I);
  Assert.AreEqual(0, FDictionary.Count);
end;

{$ENDREGION 'TDictionaryIDTest' }

{$REGION 'TDictionaryIPTest' }

procedure TDictionaryIPTest.Setup;
begin
  FDictionary := TDictionary<Integer, Pointer>.Create;
end;

procedure TDictionaryIPTest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TDictionaryIPTest.TestAdd;
begin
  FDictionary.Add(1, Pointer(11));
  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(Pointer(11), FDictionary.Items[1]);
end;

procedure TDictionaryIPTest.TestRemove;
begin
  FDictionary.Add(1, Pointer(11));
  FDictionary.Remove(1);
  Assert.IsFalse(FDictionary.ContainsKey(1));
end;

procedure TDictionaryIPTest.TestFind;
begin
  {$IFDEF TEST_RAPIDGENERICS}
  FDictionary.Add(1, Pointer(11));
  Assert.IsNotNull(FDictionary.Find(1));
  {$ENDIF}
end;

procedure TDictionaryIPTest.TestFindOrAdd;
begin
  {$IFDEF TEST_RAPIDGENERICS}
  var P := FDictionary.FindOrAdd(2);
  Assert.IsNotNull(P);
  {$ENDIF}
end;

procedure TDictionaryIPTest.TestExtractPair;
begin
  FDictionary.Add(3, Pointer(11));
  var Pair := FDictionary.ExtractPair(3);
  Assert.AreEqual(3, Pair.Key);
  Assert.AreEqual(Pointer(11), Pair.Value);
  Assert.IsFalse(FDictionary.ContainsKey(3));
end;

procedure TDictionaryIPTest.TestTryGetValue;
begin
  FDictionary.Add(4, Pointer(44));
  var Value: Pointer;
  Assert.IsTrue(FDictionary.TryGetValue(4, Value));
  Assert.AreEqual(Pointer(44), Value);
end;

procedure TDictionaryIPTest.TestAddOrSetValue;
begin
  FDictionary.AddOrSetValue(5, Pointer(55));
  Assert.AreEqual(Pointer(55), FDictionary.Items[5]);
  FDictionary.AddOrSetValue(5, Pointer(56));
  Assert.AreEqual(Pointer(56), FDictionary.Items[5]);
end;

procedure TDictionaryIPTest.TestContainsKey;
begin
  FDictionary.Add(6, Pointer(66));
  Assert.IsTrue(FDictionary.ContainsKey(6));
  Assert.IsFalse(FDictionary.ContainsKey(7));
end;

procedure TDictionaryIPTest.TestMany;
const
  ItemCount = 100000;
var
  I: Integer;
  Value: Pointer;
begin
  // Add items
  for I := 1 to ItemCount do
    FDictionary.Add(I, Pointer(I * 10 + I));
  Assert.AreEqual(ItemCount, FDictionary.Count);

  // Verify all items exist
  for I := 1 to ItemCount do
  begin
    Assert.IsTrue(FDictionary.TryGetValue(I, Value));
    Assert.AreEqual(Pointer(I * 10 + I), Value);
  end;

  // Remove all items
  for I := 1 to ItemCount do
    FDictionary.Remove(I);
  Assert.AreEqual(0, FDictionary.Count);
end;

{$ENDREGION 'TDictionaryIPTest' }

{$REGION 'TDictionaryIIntfTest'}

{ TDictionaryIIntfTest }

procedure TDictionaryIIntfTest.Setup;
begin
  FDictionary := TDictionary<Integer, ITestInterface>.Create;
end;

procedure TDictionaryIIntfTest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TDictionaryIIntfTest.TestAdd;
begin
  FDictionary.Add(1, TTestInterfacedObject.Create(11));
  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(11, FDictionary.Items[1].Value);
end;

procedure TDictionaryIIntfTest.TestRemove;
begin
  FDictionary.Add(1, TTestInterfacedObject.Create(11));
  FDictionary.Remove(1);
  Assert.IsFalse(FDictionary.ContainsKey(1));
end;

procedure TDictionaryIIntfTest.TestFind;
var
  FoundValue: ITestInterface;
begin
  FDictionary.Add(1, TTestInterfacedObject.Create(11));
  FoundValue := FDictionary.Items[1]; // Direct access as "Find" is not standard
  Assert.IsNotNull(FoundValue);
  Assert.AreEqual(11, FoundValue.Value);
end;

procedure TDictionaryIIntfTest.TestFindOrAdd;
var
  FoundValue: ITestInterface;
begin
  // AddOrSetValue simulates FindOrAdd behavior
  FDictionary.AddOrSetValue(2, TTestInterfacedObject.Create(22));
  FoundValue := FDictionary.Items[2];
  Assert.IsNotNull(FoundValue);
  Assert.AreEqual(22, FoundValue.Value);
end;

procedure TDictionaryIIntfTest.TestExtractPair;
var
  Pair: TPair<Integer, ITestInterface>;
begin
  FDictionary.Add(3, TTestInterfacedObject.Create(33));
  Pair := FDictionary.ExtractPair(3);
  Assert.AreEqual(3, Pair.Key);
  Assert.AreEqual(33, Pair.Value.Value);
  Assert.IsFalse(FDictionary.ContainsKey(3));
end;

procedure TDictionaryIIntfTest.TestTryGetValue;
var
  Value: ITestInterface;
begin
  FDictionary.Add(4, TTestInterfacedObject.Create(44));
  Assert.IsTrue(FDictionary.TryGetValue(4, Value));
  Assert.AreEqual(44, Value.Value);
end;

procedure TDictionaryIIntfTest.TestAddOrSetValue;
begin
  FDictionary.AddOrSetValue(5, TTestInterfacedObject.Create(55));
  Assert.AreEqual(55, FDictionary.Items[5].Value);
  FDictionary.AddOrSetValue(5, TTestInterfacedObject.Create(56));
  Assert.AreEqual(56, FDictionary.Items[5].Value);
end;

procedure TDictionaryIIntfTest.TestContainsKey;
begin
  FDictionary.Add(6, TTestInterfacedObject.Create(66));
  Assert.IsTrue(FDictionary.ContainsKey(6));
  Assert.IsFalse(FDictionary.ContainsKey(7));
end;

procedure TDictionaryIIntfTest.TestMany;
const
  ItemCount = 100000;
var
  I: Integer;
  Value: ITestInterface;
begin
  // Add items
  for I := 1 to ItemCount do
    FDictionary.Add(I, TTestInterfacedObject.Create(I * 10 + I));
  Assert.AreEqual(ItemCount, FDictionary.Count);

  // Verify all items exist
  for I := 1 to ItemCount do
  begin
    Assert.IsTrue(FDictionary.TryGetValue(I, Value));
    Assert.AreEqual(I * 10 + I, Value.Value);
  end;

  // Remove all items
  for I := 1 to ItemCount do
    FDictionary.Remove(I);
  Assert.AreEqual(0, FDictionary.Count);
end;

{$ENDREGION 'TDictionaryIIntfTest'}

{ TObjectDictionaryIOTest } // Owns Values

procedure TObjectDictionaryIOTest.Setup;
begin
  // Create dictionary with ownership of values
  FDictionary := TObjectDictionary<Integer, TTestObject>.Create([doOwnsValues]);
end;

procedure TObjectDictionaryIOTest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TObjectDictionaryIOTest.TestAdd;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(1, Obj);
  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(11, FDictionary.Items[1].ID);
end;

procedure TObjectDictionaryIOTest.TestRemove;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(1, Obj);
  FDictionary.Remove(1); // Dictionary frees the object
  Assert.IsFalse(FDictionary.ContainsKey(1));
end;

procedure TObjectDictionaryIOTest.TestFind;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(1, Obj);
  Assert.IsNotNull(FDictionary.Items[1]);
  Assert.AreEqual(11, FDictionary.Items[1].ID);
end;

procedure TObjectDictionaryIOTest.TestFindOrAdd;
var
  Obj: TTestObject;
begin
  // Since FindOrAdd doesn't exist in Delphi's TDictionary, simulate it
  if not FDictionary.TryGetValue(2, Obj) then
  begin
    Obj := TTestObject.Create(22);
    FDictionary.Add(2, Obj);
  end;
  Assert.IsNotNull(Obj);
  Assert.AreEqual(22, FDictionary.Items[2].ID);
end;

procedure TObjectDictionaryIOTest.TestExtractPair;
var
  Obj: TTestObject;
  Pair: TPair<Integer, TTestObject>;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(3, Obj);
  Pair := FDictionary.ExtractPair(3); // Extracted object is not freed
  Assert.AreEqual(3, Pair.Key);
  Assert.AreEqual(11, Pair.Value.ID);
  Assert.IsFalse(FDictionary.ContainsKey(3));
  Pair.Value.Free; // Manually free extracted object
end;

procedure TObjectDictionaryIOTest.TestTryGetValue;
var
  Obj: TTestObject;
  Value: TTestObject;
begin
  Obj := TTestObject.Create(44);
  FDictionary.Add(4, Obj);
  Assert.IsTrue(FDictionary.TryGetValue(4, Value));
  Assert.AreEqual(44, Value.ID);
end;

procedure TObjectDictionaryIOTest.TestAddOrSetValue;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(55);
  FDictionary.AddOrSetValue(5, Obj);
  Assert.AreEqual(55, FDictionary.Items[5].ID);
  Obj := TTestObject.Create(56);
  FDictionary.AddOrSetValue(5, Obj); // Previous object is freed by dictionary
  Assert.AreEqual(56, FDictionary.Items[5].ID);
end;

procedure TObjectDictionaryIOTest.TestContainsKey;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(66);
  FDictionary.Add(6, Obj);
  Assert.IsTrue(FDictionary.ContainsKey(6));
  Assert.IsFalse(FDictionary.ContainsKey(7));
end;

procedure TObjectDictionaryIOTest.TestMany;
const
  ItemCount = 100000;
var
  I: Integer;
  Value: TTestObject;
  Obj: TTestObject;
begin
  // Add items
  for I := 1 to ItemCount do
  begin
    Obj := TTestObject.Create(I * 10 + I);
    FDictionary.Add(I, Obj);
  end;
  Assert.AreEqual(ItemCount, FDictionary.Count);

  // Verify all items exist
  for I := 1 to ItemCount do
  begin
    Assert.IsTrue(FDictionary.TryGetValue(I, Value));
    Assert.AreEqual(I * 10 + I, Value.ID);
  end;

  // Remove all items (dictionary frees objects)
  for I := 1 to ItemCount do
    FDictionary.Remove(I);
  Assert.AreEqual(0, FDictionary.Count);
end;

{ TCustomObjectDictionary }

procedure TCustomObjectDictionary.KeyNotify(const Key: Integer;
  Action: TCollectionNotification);
begin
  // Just need a different method
  inherited;
end;

procedure TCustomObjectDictionary.ValueNotify(const Value: TTestObject;
  Action: TCollectionNotification);
begin
  // Just need a different method
  inherited;
end;

{ TCustomObjectDictionaryIOTest } // Owns Values, overridden KeyNotify and ValueNotify

procedure TCustomObjectDictionaryIOTest.Setup;
begin
  // Create dictionary with ownership of values
  FDictionary := TCustomObjectDictionary.Create([doOwnsValues]);
end;

procedure TCustomObjectDictionaryIOTest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TCustomObjectDictionaryIOTest.TestAdd;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(1, Obj);
  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(11, FDictionary.Items[1].ID);
end;

procedure TCustomObjectDictionaryIOTest.TestRemove;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(1, Obj);
  FDictionary.Remove(1); // Dictionary frees the object
  Assert.IsFalse(FDictionary.ContainsKey(1));
end;

procedure TCustomObjectDictionaryIOTest.TestFind;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(1, Obj);
  Assert.IsNotNull(FDictionary.Items[1]);
  Assert.AreEqual(11, FDictionary.Items[1].ID);
end;

procedure TCustomObjectDictionaryIOTest.TestFindOrAdd;
var
  Obj: TTestObject;
begin
  // Since FindOrAdd doesn't exist in Delphi's TDictionary, simulate it
  if not FDictionary.TryGetValue(2, Obj) then
  begin
    Obj := TTestObject.Create(22);
    FDictionary.Add(2, Obj);
  end;
  Assert.IsNotNull(Obj);
  Assert.AreEqual(22, FDictionary.Items[2].ID);
end;

procedure TCustomObjectDictionaryIOTest.TestExtractPair;
var
  Obj: TTestObject;
  Pair: TPair<Integer, TTestObject>;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(3, Obj);
  Pair := FDictionary.ExtractPair(3); // Extracted object is not freed
  Assert.AreEqual(3, Pair.Key);
  Assert.AreEqual(11, Pair.Value.ID);
  Assert.IsFalse(FDictionary.ContainsKey(3));
  Pair.Value.Free; // Manually free extracted object
end;

procedure TCustomObjectDictionaryIOTest.TestTryGetValue;
var
  Obj: TTestObject;
  Value: TTestObject;
begin
  Obj := TTestObject.Create(44);
  FDictionary.Add(4, Obj);
  Assert.IsTrue(FDictionary.TryGetValue(4, Value));
  Assert.AreEqual(44, Value.ID);
end;

procedure TCustomObjectDictionaryIOTest.TestAddOrSetValue;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(55);
  FDictionary.AddOrSetValue(5, Obj);
  Assert.AreEqual(55, FDictionary.Items[5].ID);
  Obj := TTestObject.Create(56);
  FDictionary.AddOrSetValue(5, Obj); // Previous object is freed by dictionary
  Assert.AreEqual(56, FDictionary.Items[5].ID);
end;

procedure TCustomObjectDictionaryIOTest.TestContainsKey;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(66);
  FDictionary.Add(6, Obj);
  Assert.IsTrue(FDictionary.ContainsKey(6));
  Assert.IsFalse(FDictionary.ContainsKey(7));
end;

procedure TCustomObjectDictionaryIOTest.TestMany;
const
  ItemCount = 100000;
var
  I: Integer;
  Value: TTestObject;
  Obj: TTestObject;
begin
  // Add items
  for I := 1 to ItemCount do
  begin
    Obj := TTestObject.Create(I * 10 + I);
    FDictionary.Add(I, Obj);
  end;
  Assert.AreEqual(ItemCount, FDictionary.Count);

  // Verify all items exist
  for I := 1 to ItemCount do
  begin
    Assert.IsTrue(FDictionary.TryGetValue(I, Value));
    Assert.AreEqual(I * 10 + I, Value.ID);
  end;

  // Remove all items (dictionary frees objects)
  for I := 1 to ItemCount do
    FDictionary.Remove(I);
  Assert.AreEqual(0, FDictionary.Count);
end;

{ TObjectDictionaryOITest } // Owns keys

procedure TObjectDictionaryOITest.Setup;
begin
  // Create dictionary with ownership of keys
  FDictionary := TObjectDictionary<TTestObject, Integer>.Create([doOwnsKeys]);
end;

procedure TObjectDictionaryOITest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TObjectDictionaryOITest.TestAdd;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(Obj, 1);
  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(1, FDictionary.Items[Obj]);
end;

procedure TObjectDictionaryOITest.TestRemove;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(Obj, 1);
  FDictionary.Remove(Obj); // Dictionary frees the object

  Assert.IsTrue(FDictionary.Count = 0);
end;

procedure TObjectDictionaryOITest.TestFind;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(Obj, 1);
  Assert.AreEqual(1, FDictionary.Items[Obj]);
end;

procedure TObjectDictionaryOITest.TestFindOrAdd;
var
  Obj: TTestObject;
  Value: Integer;
begin
  Obj := TTestObject.Create(22);
  if not FDictionary.TryGetValue(Obj, Value) then
    FDictionary.Add(Obj, 2);
  Assert.IsTrue(FDictionary.TryGetValue(Obj, Value));
  Assert.AreEqual(2, Value);
end;

procedure TObjectDictionaryOITest.TestExtractPair;
var
  Obj: TTestObject;
  Pair: TPair<TTestObject, Integer>;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(Obj, 3);
  Pair := FDictionary.ExtractPair(Obj); // Extracted key is not freed
  Assert.AreEqual(3, Pair.Value);
  Assert.AreEqual(11, Pair.Key.ID);
  Assert.IsFalse(FDictionary.ContainsKey(Pair.Key));
  Pair.Key.Free; // Manually free extracted key
end;

procedure TObjectDictionaryOITest.TestTryGetValue;
var
  Obj: TTestObject;
  Value: Integer;
begin
  Obj := TTestObject.Create(44);
  FDictionary.Add(Obj, 4);
  Assert.IsTrue(FDictionary.TryGetValue(Obj, Value));
  Assert.AreEqual(4, Value);
end;

procedure TObjectDictionaryOITest.TestAddOrSetValue;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(55);
  FDictionary.AddOrSetValue(Obj, 5);
  Assert.AreEqual(5, FDictionary.Items[Obj]);

  Obj := TTestObject.Create(56);
  FDictionary.AddOrSetValue(Obj, 6); // Previous key is freed
  Assert.AreEqual(6, FDictionary.Items[Obj]);
end;

procedure TObjectDictionaryOITest.TestContainsKey;
var
  Obj1, Obj2: TTestObject;
begin
  Obj1 := TTestObject.Create(66);
  Obj2 := TTestObject.Create(77);
  FDictionary.Add(Obj1, 6);
  Assert.IsTrue(FDictionary.ContainsKey(Obj1));
  Assert.IsFalse(FDictionary.ContainsKey(Obj2));
  Obj2.Free;
end;

procedure TObjectDictionaryOITest.TestMany;
const
  ItemCount = 100000;
var
  I: Integer;
  Obj: TTestObject;
  Value: Integer;
begin
  // Add items
  for I := 1 to ItemCount do
  begin
    Obj := TTestObject.Create(I * 10 + I);
    FDictionary.Add(Obj, I);
  end;
  Assert.AreEqual(ItemCount, FDictionary.Count);

  // Verify all items exist
  for Obj in FDictionary.Keys do
  begin
    Assert.IsTrue(FDictionary.TryGetValue(Obj, Value));
    Assert.AreEqual(Obj.ID, Value * 10 + Value);
  end;

  // Remove all items (dictionary frees keys)
  for Obj in FDictionary.Keys.ToArray do
    FDictionary.Remove(Obj);
  Assert.AreEqual(0, FDictionary.Count);
end;

{ TCustomObjectDictionary2 }

procedure TCustomObjectDictionary2.KeyNotify(const Key: TTestObject;
  Action: TCollectionNotification);
begin
  inherited;
end;

procedure TCustomObjectDictionary2.ValueNotify(const Value: Integer;
  Action: TCollectionNotification);
begin
  inherited;
end;

{ TCustomObjectDictionaryOITest } // Owns keys, overrides KeyNotify and ValueNotify

procedure TCustomObjectDictionaryOITest.Setup;
begin
  // Create dictionary with ownership of keys
  FDictionary := TCustomObjectDictionary2.Create([doOwnsKeys]);
end;

procedure TCustomObjectDictionaryOITest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TCustomObjectDictionaryOITest.TestAdd;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(Obj, 1);
  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(1, FDictionary.Items[Obj]);
end;

procedure TCustomObjectDictionaryOITest.TestRemove;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(Obj, 1);
  FDictionary.Remove(Obj); // Dictionary frees the object

  Assert.IsTrue(FDictionary.Count = 0);
end;

procedure TCustomObjectDictionaryOITest.TestFind;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(Obj, 1);
  Assert.AreEqual(1, FDictionary.Items[Obj]);
end;

procedure TCustomObjectDictionaryOITest.TestFindOrAdd;
var
  Obj: TTestObject;
  Value: Integer;
begin
  Obj := TTestObject.Create(22);
  if not FDictionary.TryGetValue(Obj, Value) then
    FDictionary.Add(Obj, 2);
  Assert.IsTrue(FDictionary.TryGetValue(Obj, Value));
  Assert.AreEqual(2, Value);
end;

procedure TCustomObjectDictionaryOITest.TestExtractPair;
var
  Obj: TTestObject;
  Pair: TPair<TTestObject, Integer>;
begin
  Obj := TTestObject.Create(11);
  FDictionary.Add(Obj, 3);
  Pair := FDictionary.ExtractPair(Obj); // Extracted key is not freed
  Assert.AreEqual(3, Pair.Value);
  Assert.AreEqual(11, Pair.Key.ID);
  Assert.IsFalse(FDictionary.ContainsKey(Pair.Key));
  Pair.Key.Free; // Manually free extracted key
end;

procedure TCustomObjectDictionaryOITest.TestTryGetValue;
var
  Obj: TTestObject;
  Value: Integer;
begin
  Obj := TTestObject.Create(44);
  FDictionary.Add(Obj, 4);
  Assert.IsTrue(FDictionary.TryGetValue(Obj, Value));
  Assert.AreEqual(4, Value);
end;

procedure TCustomObjectDictionaryOITest.TestAddOrSetValue;
var
  Obj: TTestObject;
begin
  Obj := TTestObject.Create(55);
  FDictionary.AddOrSetValue(Obj, 5);
  Assert.AreEqual(5, FDictionary.Items[Obj]);

  Obj := TTestObject.Create(56);
  FDictionary.AddOrSetValue(Obj, 6); // Previous key is freed
  Assert.AreEqual(6, FDictionary.Items[Obj]);
end;

procedure TCustomObjectDictionaryOITest.TestContainsKey;
var
  Obj1, Obj2: TTestObject;
begin
  Obj1 := TTestObject.Create(66);
  Obj2 := TTestObject.Create(77);
  FDictionary.Add(Obj1, 6);
  Assert.IsTrue(FDictionary.ContainsKey(Obj1));
  Assert.IsFalse(FDictionary.ContainsKey(Obj2));
  Obj2.Free;
end;

procedure TCustomObjectDictionaryOITest.TestMany;
const
  ItemCount = 100000;
var
  I: Integer;
  Obj: TTestObject;
  Value: Integer;
begin
  // Add items
  for I := 1 to ItemCount do
  begin
    Obj := TTestObject.Create(I * 10 + I);
    FDictionary.Add(Obj, I);
  end;
  Assert.AreEqual(ItemCount, FDictionary.Count);

  // Verify all items exist
  for Obj in FDictionary.Keys do
  begin
    Assert.IsTrue(FDictionary.TryGetValue(Obj, Value));
    Assert.AreEqual(Obj.ID, Value * 10 + Value);
  end;

  // Remove all items (dictionary frees keys)
  for Obj in FDictionary.Keys.ToArray do
    FDictionary.Remove(Obj);
  Assert.AreEqual(0, FDictionary.Count);
end;

{ TRecordDictionaryITest }

procedure TRecordDictionaryITest.Setup;
begin
  FDictionary := TDictionary<TTestRecord, Integer>.Create;
end;

procedure TRecordDictionaryITest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TRecordDictionaryITest.TestAdd;
var
  Key: TTestRecord;
begin
  Key.Field1 := 10;
  Key.Field2 := 20;

  FDictionary.Add(Key, 1);

  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(1, FDictionary[Key]);
end;

procedure TRecordDictionaryITest.TestRemove;
var
  Key: TTestRecord;
begin
  Key.Field1 := 10;
  Key.Field2 := 20;

  FDictionary.Add(Key, 1);
  FDictionary.Remove(Key);

  Assert.AreEqual(0, FDictionary.Count);
end;

procedure TRecordDictionaryITest.TestFind;
var
  Key: TTestRecord;
begin
  Key.Field1 := 11;
  Key.Field2 := 22;

  FDictionary.Add(Key, 99);

  Assert.AreEqual(99, FDictionary[Key]);
end;

procedure TRecordDictionaryITest.TestFindOrAdd;
var
  Key: TTestRecord;
  Value: Integer;
begin
  Key.Field1 := 3;
  Key.Field2 := 7;

  if not FDictionary.TryGetValue(Key, Value) then
    FDictionary.Add(Key, 15);

  Assert.IsTrue(FDictionary.TryGetValue(Key, Value));
  Assert.AreEqual(15, Value);
end;

procedure TRecordDictionaryITest.TestExtractPair;
var
  Key: TTestRecord;
  Pair: TPair<TTestRecord, Integer>;
begin
  Key.Field1 := 100;
  Key.Field2 := 200;

  FDictionary.Add(Key, 7);

  Pair := FDictionary.ExtractPair(Key);

  Assert.AreEqual(7, Pair.Value);
  Assert.AreEqual(100, Pair.Key.Field1);
  Assert.AreEqual(200, Pair.Key.Field2);
  Assert.IsFalse(FDictionary.ContainsKey(Key));
end;

procedure TRecordDictionaryITest.TestTryGetValue;
var
  Key: TTestRecord;
  Value: Integer;
begin
  Key.Field1 := 44;
  Key.Field2 := 55;

  FDictionary.Add(Key, 8);

  Assert.IsTrue(FDictionary.TryGetValue(Key, Value));
  Assert.AreEqual(8, Value);
end;

procedure TRecordDictionaryITest.TestAddOrSetValue;
var
  Key: TTestRecord;
begin
  Key.Field1 := 10;
  Key.Field2 := 11;

  FDictionary.AddOrSetValue(Key, 5);
  Assert.AreEqual(5, FDictionary[Key]);

  FDictionary.AddOrSetValue(Key, 123);

  Assert.AreEqual(123, FDictionary[Key]);
  Assert.AreEqual(1, FDictionary.Count);
end;

procedure TRecordDictionaryITest.TestContainsKey;
var
  K1, K2: TTestRecord;
begin
  K1.Field1 := 1;
  K1.Field2 := 2;

  K2.Field1 := 1;
  K2.Field2 := 3;

  FDictionary.Add(K1, 1);

  Assert.IsTrue(FDictionary.ContainsKey(K1));
  Assert.IsFalse(FDictionary.ContainsKey(K2));
end;

procedure TRecordDictionaryITest.TestDuplicateKey;
var
  Key: TTestRecord;
begin
  Key.Field1 := 5;
  Key.Field2 := 6;

  FDictionary.Add(Key, 1);

  Assert.WillRaise(
    procedure
    begin
      FDictionary.Add(Key, 2);
    end,
    EListError);
end;

procedure TRecordDictionaryITest.TestDifferentRecordsSameFirstField;
var
  K1, K2: TTestRecord;
begin
  K1.Field1 := 10;
  K1.Field2 := 20;

  K2.Field1 := 10;
  K2.Field2 := 21;

  FDictionary.Add(K1, 1);
  FDictionary.Add(K2, 2);

  Assert.AreEqual(2, FDictionary.Count);
  Assert.AreEqual(1, FDictionary[K1]);
  Assert.AreEqual(2, FDictionary[K2]);
end;

procedure TRecordDictionaryITest.TestDifferentRecordsSameSecondField;
var
  K1, K2: TTestRecord;
begin
  K1.Field1 := 30;
  K1.Field2 := 40;

  K2.Field1 := 31;
  K2.Field2 := 40;

  FDictionary.Add(K1, 5);
  FDictionary.Add(K2, 6);

  Assert.AreEqual(5, FDictionary[K1]);
  Assert.AreEqual(6, FDictionary[K2]);
end;

procedure TRecordDictionaryITest.TestOverwriteValue;
var
  Key: TTestRecord;
begin
  Key.Field1 := 8;
  Key.Field2 := 9;

  FDictionary.Add(Key, 1);
  FDictionary[Key] := 999;

  Assert.AreEqual(999, FDictionary[Key]);
end;

procedure TRecordDictionaryITest.TestMany;
const
  ItemCount = 100000;
var
  I: Integer;
  Key: TTestRecord;
  Value: Integer;
begin
  for I := 1 to ItemCount do
  begin
    Key.Field1 := I;
    Key.Field2 := I * 3 + 7;
    FDictionary.Add(Key, I);
  end;

  Assert.AreEqual(ItemCount, FDictionary.Count);

  for I := 1 to ItemCount do
  begin
    Key.Field1 := I;
    Key.Field2 := I * 3 + 7;

    Assert.IsTrue(FDictionary.TryGetValue(Key, Value));
    Assert.AreEqual(I, Value);
  end;

  for I := 1 to ItemCount do
  begin
    Key.Field1 := I;
    Key.Field2 := I * 3 + 7;
    FDictionary.Remove(Key);
  end;

  Assert.AreEqual(0, FDictionary.Count);
end;

procedure TRecordDictionaryITest.TestNegativeValues;
var
  Key: TTestRecord;
begin
  Key.Field1 := -12345;
  Key.Field2 := -98765;

  FDictionary.Add(Key, 42);

  Assert.IsTrue(FDictionary.ContainsKey(Key));
  Assert.AreEqual(42, FDictionary[Key]);
end;

procedure TRecordDictionaryITest.TestZeroValues;
var
  Key: TTestRecord;
begin
  Key.Field1 := 0;
  Key.Field2 := 0;

  FDictionary.Add(Key, 100);

  Assert.IsTrue(FDictionary.ContainsKey(Key));
  Assert.AreEqual(100, FDictionary[Key]);
end;

procedure TRecordDictionaryITest.TestMinMaxValues;
var
  K1, K2: TTestRecord;
begin
  K1.Field1 := Low(Integer);
  K1.Field2 := High(Integer);

  K2.Field1 := High(Integer);
  K2.Field2 := Low(Integer);

  FDictionary.Add(K1, 1);
  FDictionary.Add(K2, 2);

  Assert.AreEqual(1, FDictionary[K1]);
  Assert.AreEqual(2, FDictionary[K2]);
end;

procedure TRecordDictionaryITest.TestSwappedFields;
var
  K1, K2: TTestRecord;
begin
  K1.Field1 := 1;
  K1.Field2 := 2;

  K2.Field1 := 2;
  K2.Field2 := 1;

  FDictionary.Add(K1, 10);
  FDictionary.Add(K2, 20);

  Assert.AreEqual(2, FDictionary.Count);
  Assert.AreEqual(10, FDictionary[K1]);
  Assert.AreEqual(20, FDictionary[K2]);
end;

procedure TRecordDictionaryITest.TestManySameFirstField;
const
  Count = 10000;
var
  I: Integer;
  Key: TTestRecord;
  Value: Integer;
begin
  for I := 1 to Count do
  begin
    Key.Field1 := 12345;
    Key.Field2 := I;

    FDictionary.Add(Key, I);
  end;

  Assert.AreEqual(Count, FDictionary.Count);

  for I := 1 to Count do
  begin
    Key.Field1 := 12345;
    Key.Field2 := I;

    Assert.IsTrue(FDictionary.TryGetValue(Key, Value));
    Assert.AreEqual(I, Value);
  end;
end;

procedure TRecordDictionaryITest.TestInsertRemoveInsert;
var
  Key: TTestRecord;
begin
  Key.Field1 := 111;
  Key.Field2 := 222;

  FDictionary.Add(Key, 1);

  Assert.AreEqual(1, FDictionary[Key]);

  FDictionary.Remove(Key);

  Assert.IsFalse(FDictionary.ContainsKey(Key));

  FDictionary.Add(Key, 999);

  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(999, FDictionary[Key]);
end;

procedure TRecordDictionaryITest.TestRandomized;
const
  Count = 50000;
var
  RefDict: TDictionary<TTestRecord, Integer>;
  Key: TTestRecord;
  Value,
  ValueRef: Integer;
  I: Integer;
  Res: Boolean;
begin
  RandSeed := 123456;

  RefDict := TDictionary<TTestRecord, Integer>.Create;
  try
    while RefDict.Count < Count do
    begin
      Key.Field1 := Random(MaxInt);
      Key.Field2 := Random(MaxInt);

      if not RefDict.ContainsKey(Key) then
      begin
        I := RefDict.Count;
        RefDict.Add(Key, I);
        FDictionary.Add(Key, I);
      end;
    end;

    Assert.AreEqual(RefDict.Count, FDictionary.Count);

    for Key in RefDict.Keys do
    begin
      Res := FDictionary.TryGetValue(Key, Value);
      Assert.IsTrue(Res, 'Key not found in FDictionary');
      Res := RefDict.TryGetValue(Key, ValueRef);
      Assert.IsTrue(Res, 'Key not found in RefDict');
      Assert.AreEqual(ValueRef, Value);
      Assert.AreEqual(RefDict[Key], Value, 'RefDict[Key] call failed');
    end;

    // Remove half of the entries
    I := 0;
    for Key in RefDict.Keys.ToArray do
    begin
      if Odd(I) then
      begin
        RefDict.Remove(Key);
        FDictionary.Remove(Key);
      end;
      Inc(I);
    end;

    Assert.AreEqual(RefDict.Count, FDictionary.Count);

    for Key in RefDict.Keys do
    begin
      Assert.IsTrue(FDictionary.TryGetValue(Key, Value));
      Assert.AreEqual(RefDict[Key], Value);
    end;
  finally
    RefDict.Free;
  end;
end;

{ TObjectDictionaryITest }

{ TTestObject2 }

constructor TTestObject2.Create(const AValue: Integer);
begin
  inherited Create;
  FValue := AValue;
end;

{ TObjectDictionaryITest }

function TObjectDictionaryITest.MakeKey(
  const AField1, AField2: Integer): TTestRecord;
begin
  Result.Field1 := AField1;
  Result.Field2 := AField2;
end;

function TObjectDictionaryITest.MakeValue(
  const AValue: Integer): TTestObject2;
begin
  Result := TTestObject2.Create(AValue);
end;

procedure TObjectDictionaryITest.Setup;
begin
  FDictionary := TObjectDictionary<TTestRecord, TTestObject2>.Create(
    [doOwnsValues]);
end;

procedure TObjectDictionaryITest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TObjectDictionaryITest.TestAdd;
var
  AddKey: TTestRecord;
  FindKey: TTestRecord;
begin
  AddKey := MakeKey(10, 20);
  FDictionary.Add(AddKey, MakeValue(1));

  FindKey := MakeKey(10, 20);

  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(1, FDictionary[FindKey].Value);
end;

procedure TObjectDictionaryITest.TestRemove;
var
  AddKey: TTestRecord;
  RemoveKey: TTestRecord;
begin
  AddKey := MakeKey(10, 20);
  FDictionary.Add(AddKey, MakeValue(1));

  RemoveKey := MakeKey(10, 20);
  FDictionary.Remove(RemoveKey);

  Assert.AreEqual(0, FDictionary.Count);
end;

procedure TObjectDictionaryITest.TestFind;
var
  Key1: TTestRecord;
  Key2: TTestRecord;
begin
  Key1 := MakeKey(-1, -3);
  FDictionary.Add(Key1, MakeValue(99));

  Key2 := MakeKey(-1, -3);
  Assert.AreEqual(99, FDictionary[Key2].Value);
end;

procedure TObjectDictionaryITest.TestFindOrAdd;
var
  LookupKey: TTestRecord;
  AddKey: TTestRecord;
  VerifyKey: TTestRecord;
  Value: TTestObject2;
begin
  LookupKey := MakeKey(3, 7);

  if not FDictionary.TryGetValue(LookupKey, Value) then
  begin
    AddKey := MakeKey(3, 7);
    FDictionary.Add(AddKey, MakeValue(15));
  end;

  VerifyKey := MakeKey(3, 7);

  Assert.IsTrue(FDictionary.TryGetValue(VerifyKey, Value));
  Assert.AreEqual(15, Value.Value);
end;

procedure TObjectDictionaryITest.TestExtractPair;
var
  AddKey: TTestRecord;
  ExtractKey: TTestRecord;
  ContainsKey: TTestRecord;
  Pair: TPair<TTestRecord, TTestObject2>;
begin
  AddKey := MakeKey(100, 200);
  FDictionary.Add(AddKey, MakeValue(7));

  ExtractKey := MakeKey(100, 200);
  Pair := FDictionary.ExtractPair(ExtractKey);
  try
    ContainsKey := MakeKey(100, 200);

    Assert.AreEqual(7, Pair.Value.Value);
    Assert.AreEqual(100, Pair.Key.Field1);
    Assert.AreEqual(200, Pair.Key.Field2);
    Assert.IsFalse(FDictionary.ContainsKey(ContainsKey));
  finally
    Pair.Value.Free;
  end;
end;

procedure TObjectDictionaryITest.TestTryGetValue;
var
  AddKey: TTestRecord;
  FindKey: TTestRecord;
  Value: TTestObject2;
begin
  AddKey := MakeKey(44, 55);
  FDictionary.Add(AddKey, MakeValue(8));

  FindKey := MakeKey(44, 55);

  Assert.IsTrue(FDictionary.TryGetValue(FindKey, Value));
  Assert.AreEqual(8, Value.Value);
end;

procedure TObjectDictionaryITest.TestAddOrSetValue;
var
  AddKey: TTestRecord;
  FirstFindKey: TTestRecord;
  SetKey: TTestRecord;
  FinalFindKey: TTestRecord;
begin
  AddKey := MakeKey(10, 11);
  FDictionary.AddOrSetValue(AddKey, MakeValue(5));

  FirstFindKey := MakeKey(10, 11);
  Assert.AreEqual(5, FDictionary[FirstFindKey].Value);

  SetKey := MakeKey(10, 11);
  FDictionary.AddOrSetValue(SetKey, MakeValue(123));

  FinalFindKey := MakeKey(10, 11);

  Assert.AreEqual(123, FDictionary[FinalFindKey].Value);
  Assert.AreEqual(1, FDictionary.Count);
end;

procedure TObjectDictionaryITest.TestContainsKey;
var
  AddKey: TTestRecord;
  ExistingKey: TTestRecord;
  MissingKey: TTestRecord;
begin
  AddKey := MakeKey(1, 2);
  FDictionary.Add(AddKey, MakeValue(1));

  ExistingKey := MakeKey(1, 2);
  MissingKey := MakeKey(1, 3);

  Assert.IsTrue(FDictionary.ContainsKey(ExistingKey));
  Assert.IsFalse(FDictionary.ContainsKey(MissingKey));
end;

procedure TObjectDictionaryITest.TestDuplicateKey;
var
  AddKey: TTestRecord;
  DuplicateKey: TTestRecord;
  DuplicateValue: TTestObject2;
begin
  AddKey := MakeKey(5, 6);
  FDictionary.Add(AddKey, MakeValue(1));

  DuplicateKey := MakeKey(5, 6);
  DuplicateValue := MakeValue(2);
  try
    Assert.WillRaise(
      procedure
      begin
        FDictionary.Add(DuplicateKey, DuplicateValue);
      end,
      EListError);
  finally
    DuplicateValue.Free;
  end;
end;

procedure TObjectDictionaryITest.TestDifferentRecordsSameFirstField;
var
  AddKey1: TTestRecord;
  AddKey2: TTestRecord;
  FindKey1: TTestRecord;
  FindKey2: TTestRecord;
begin
  AddKey1 := MakeKey(10, 20);
  AddKey2 := MakeKey(10, 21);

  FDictionary.Add(AddKey1, MakeValue(1));
  FDictionary.Add(AddKey2, MakeValue(2));

  FindKey1 := MakeKey(10, 20);
  FindKey2 := MakeKey(10, 21);

  Assert.AreEqual(2, FDictionary.Count);
  Assert.AreEqual(1, FDictionary[FindKey1].Value);
  Assert.AreEqual(2, FDictionary[FindKey2].Value);
end;

procedure TObjectDictionaryITest.TestDifferentRecordsSameSecondField;
var
  AddKey1: TTestRecord;
  AddKey2: TTestRecord;
  FindKey1: TTestRecord;
  FindKey2: TTestRecord;
begin
  AddKey1 := MakeKey(30, 40);
  AddKey2 := MakeKey(31, 40);

  FDictionary.Add(AddKey1, MakeValue(5));
  FDictionary.Add(AddKey2, MakeValue(6));

  FindKey1 := MakeKey(30, 40);
  FindKey2 := MakeKey(31, 40);

  Assert.AreEqual(5, FDictionary[FindKey1].Value);
  Assert.AreEqual(6, FDictionary[FindKey2].Value);
end;

procedure TObjectDictionaryITest.TestOverwriteValue;
var
  AddKey: TTestRecord;
  SetKey: TTestRecord;
  FindKey: TTestRecord;
begin
  AddKey := MakeKey(8, 9);
  FDictionary.Add(AddKey, MakeValue(1));

  SetKey := MakeKey(8, 9);
  FDictionary[SetKey] := MakeValue(999);

  FindKey := MakeKey(8, 9);
  Assert.AreEqual(999, FDictionary[FindKey].Value);
end;

procedure TObjectDictionaryITest.TestMany;
const
  ItemCount = 100000;
var
  I: Integer;
  AddKey: TTestRecord;
  FindKey: TTestRecord;
  RemoveKey: TTestRecord;
  Value: TTestObject2;
begin
  for I := 1 to ItemCount do
  begin
    AddKey := MakeKey(I, I * 3 + 7);
    FDictionary.Add(AddKey, MakeValue(I));
  end;

  Assert.AreEqual(ItemCount, FDictionary.Count);

  for I := 1 to ItemCount do
  begin
    FindKey := MakeKey(I, I * 3 + 7);

    Assert.IsTrue(FDictionary.TryGetValue(FindKey, Value));
    Assert.AreEqual(I, Value.Value);
  end;

  for I := 1 to ItemCount do
  begin
    RemoveKey := MakeKey(I, I * 3 + 7);
    FDictionary.Remove(RemoveKey);
  end;

  Assert.AreEqual(0, FDictionary.Count);
end;

procedure TObjectDictionaryITest.TestNegativeValues;
var
  AddKey: TTestRecord;
  ContainsKey: TTestRecord;
  FindKey: TTestRecord;
begin
  AddKey := MakeKey(-12345, -98765);
  FDictionary.Add(AddKey, MakeValue(42));

  ContainsKey := MakeKey(-12345, -98765);
  FindKey := MakeKey(-12345, -98765);

  Assert.IsTrue(FDictionary.ContainsKey(ContainsKey));
  Assert.AreEqual(42, FDictionary[FindKey].Value);
end;

procedure TObjectDictionaryITest.TestZeroValues;
var
  AddKey: TTestRecord;
  ContainsKey: TTestRecord;
  FindKey: TTestRecord;
begin
  AddKey := MakeKey(0, 0);
  FDictionary.Add(AddKey, MakeValue(100));

  ContainsKey := MakeKey(0, 0);
  FindKey := MakeKey(0, 0);

  Assert.IsTrue(FDictionary.ContainsKey(ContainsKey));
  Assert.AreEqual(100, FDictionary[FindKey].Value);
end;

procedure TObjectDictionaryITest.TestMinMaxValues;
var
  AddKey1: TTestRecord;
  AddKey2: TTestRecord;
  FindKey1: TTestRecord;
  FindKey2: TTestRecord;
begin
  AddKey1 := MakeKey(Low(Integer), High(Integer));
  AddKey2 := MakeKey(High(Integer), Low(Integer));

  FDictionary.Add(AddKey1, MakeValue(1));
  FDictionary.Add(AddKey2, MakeValue(2));

  FindKey1 := MakeKey(Low(Integer), High(Integer));
  FindKey2 := MakeKey(High(Integer), Low(Integer));

  Assert.AreEqual(1, FDictionary[FindKey1].Value);
  Assert.AreEqual(2, FDictionary[FindKey2].Value);
end;

procedure TObjectDictionaryITest.TestSwappedFields;
var
  AddKey1: TTestRecord;
  AddKey2: TTestRecord;
  FindKey1: TTestRecord;
  FindKey2: TTestRecord;
begin
  AddKey1 := MakeKey(1, 2);
  AddKey2 := MakeKey(2, 1);

  FDictionary.Add(AddKey1, MakeValue(10));
  FDictionary.Add(AddKey2, MakeValue(20));

  FindKey1 := MakeKey(1, 2);
  FindKey2 := MakeKey(2, 1);

  Assert.AreEqual(2, FDictionary.Count);
  Assert.AreEqual(10, FDictionary[FindKey1].Value);
  Assert.AreEqual(20, FDictionary[FindKey2].Value);
end;

procedure TObjectDictionaryITest.TestManySameFirstField;
const
  Count = 10000;
var
  I: Integer;
  AddKey: TTestRecord;
  FindKey: TTestRecord;
  Value: TTestObject2;
begin
  for I := 1 to Count do
  begin
    AddKey := MakeKey(12345, I);
    FDictionary.Add(AddKey, MakeValue(I));
  end;

  Assert.AreEqual(Count, FDictionary.Count);

  for I := 1 to Count do
  begin
    FindKey := MakeKey(12345, I);

    Assert.IsTrue(FDictionary.TryGetValue(FindKey, Value));
    Assert.AreEqual(I, Value.Value);
  end;
end;

procedure TObjectDictionaryITest.TestInsertRemoveInsert;
var
  AddKey1: TTestRecord;
  FindKey1: TTestRecord;
  RemoveKey: TTestRecord;
  ContainsKey: TTestRecord;
  AddKey2: TTestRecord;
  FindKey2: TTestRecord;
begin
  AddKey1 := MakeKey(111, 222);
  FDictionary.Add(AddKey1, MakeValue(1));

  FindKey1 := MakeKey(111, 222);
  Assert.AreEqual(1, FDictionary[FindKey1].Value);

  RemoveKey := MakeKey(111, 222);
  FDictionary.Remove(RemoveKey);

  ContainsKey := MakeKey(111, 222);
  Assert.IsFalse(FDictionary.ContainsKey(ContainsKey));

  AddKey2 := MakeKey(111, 222);
  FDictionary.Add(AddKey2, MakeValue(999));

  FindKey2 := MakeKey(111, 222);

  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(999, FDictionary[FindKey2].Value);
end;

procedure TObjectDictionaryITest.TestRandomized;
const
  Count = 50000;
var
  RefDict: TDictionary<TTestRecord, Integer>;
  AddKey: TTestRecord;
  LookupKey: TTestRecord;
  RemoveKey: TTestRecord;
  Value: TTestObject2;
  I: Integer;
begin
  RandSeed := 123456;

  RefDict := TDictionary<TTestRecord, Integer>.Create;
  try
    while RefDict.Count < Count do
    begin
      AddKey := MakeKey(Random(MaxInt), Random(MaxInt));

      if not RefDict.ContainsKey(AddKey) then
      begin
        I := RefDict.Count;
        RefDict.Add(AddKey, I);

        LookupKey := MakeKey(AddKey.Field1, AddKey.Field2);
        FDictionary.Add(LookupKey, MakeValue(I));
      end;
    end;

    Assert.AreEqual(RefDict.Count, FDictionary.Count);

    for LookupKey in RefDict.Keys do
    begin
      AddKey := MakeKey(LookupKey.Field1, LookupKey.Field2);

      Assert.IsTrue(FDictionary.TryGetValue(AddKey, Value));
      Assert.AreEqual(RefDict[LookupKey], Value.Value);
    end;

    I := 0;
    for LookupKey in RefDict.Keys.ToArray do
    begin
      if Odd(I) then
      begin
        RefDict.Remove(LookupKey);

        RemoveKey := MakeKey(LookupKey.Field1, LookupKey.Field2);
        FDictionary.Remove(RemoveKey);
      end;
      Inc(I);
    end;

    Assert.AreEqual(RefDict.Count, FDictionary.Count);

    for LookupKey in RefDict.Keys do
    begin
      AddKey := MakeKey(LookupKey.Field1, LookupKey.Field2);

      Assert.IsTrue(FDictionary.TryGetValue(AddKey, Value));
      Assert.AreEqual(RefDict[LookupKey], Value.Value);
    end;
  finally
    RefDict.Free;
  end;
end;

procedure TObjectDictionaryITest.TestDictionaryOwnsValues;
var
  AddKey: TTestRecord;
  FindKey: TTestRecord;
begin
  AddKey := MakeKey(1, 2);
  FDictionary.Add(AddKey, MakeValue(100));

  FindKey := MakeKey(1, 2);

  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(100, FDictionary[FindKey].Value);
end;

procedure TObjectDictionaryITest.TestRemoveDestroysValue;
var
  AddKey: TTestRecord;
  RemoveKey: TTestRecord;
  Value: TTestObject2;
begin
  AddKey := MakeKey(10, 20);
  Value := MakeValue(123);

  FDictionary.Add(AddKey, Value);

  RemoveKey := MakeKey(10, 20);
  FDictionary.Remove(RemoveKey);

  Assert.AreEqual(0, FDictionary.Count);

  // Value was freed by Remove because doOwnsValues is enabled.
end;

procedure TObjectDictionaryITest.TestExtractPairTransfersValueOwnership;
var
  AddKey: TTestRecord;
  ExtractKey: TTestRecord;
  Pair: TPair<TTestRecord, TTestObject2>;
begin
  AddKey := MakeKey(10, 20);
  FDictionary.Add(AddKey, MakeValue(123));

  ExtractKey := MakeKey(10, 20);
  Pair := FDictionary.ExtractPair(ExtractKey);
  try
    Assert.AreEqual(0, FDictionary.Count);
    Assert.AreEqual(123, Pair.Value.Value);
  finally
    Pair.Value.Free;
  end;
end;

{ TObjectDictionary4ByteITest }

function TObjectDictionary4ByteITest.MakeKey(const AField1, AField2: SmallInt): TTestRecord4;
begin
  Result.Field1 := AField1;
  Result.Field2 := AField2;
end;

function TObjectDictionary4ByteITest.MakeValue(const AValue: Integer): TTestObject2;
begin
  Result := TTestObject2.Create(AValue);
end;

procedure TObjectDictionary4ByteITest.Setup;
begin
  FDictionary := TObjectDictionary<TTestRecord4, TTestObject2>.Create([doOwnsValues]);
end;

procedure TObjectDictionary4ByteITest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TObjectDictionary4ByteITest.TestRecordSize;
begin
  Assert.AreEqual(4, SizeOf(TTestRecord4));
end;

procedure TObjectDictionary4ByteITest.TestFind;
var
  AddKey: TTestRecord4;
  FindKey: TTestRecord4;
begin
  AddKey := MakeKey(-1, -3);
  FDictionary.Add(AddKey, MakeValue(99));

  FindKey := MakeKey(-1, -3);

  Assert.AreEqual(99, FDictionary[FindKey].Value);
end;

procedure TObjectDictionary4ByteITest.TestTryGetValue;
var
  AddKey: TTestRecord4;
  FindKey: TTestRecord4;
  Value: TTestObject2;
begin
  AddKey := MakeKey(44, 55);
  FDictionary.Add(AddKey, MakeValue(8));

  FindKey := MakeKey(44, 55);

  Assert.IsTrue(FDictionary.TryGetValue(FindKey, Value));
  Assert.AreEqual(8, Value.Value);
end;

procedure TObjectDictionary4ByteITest.TestContainsKey;
var
  AddKey: TTestRecord4;
  ExistingKey: TTestRecord4;
  MissingKey: TTestRecord4;
begin
  AddKey := MakeKey(1, 2);
  FDictionary.Add(AddKey, MakeValue(1));

  ExistingKey := MakeKey(1, 2);
  MissingKey := MakeKey(1, 3);

  Assert.IsTrue(FDictionary.ContainsKey(ExistingKey));
  Assert.IsFalse(FDictionary.ContainsKey(MissingKey));
end;

procedure TObjectDictionary4ByteITest.TestRemove;
var
  AddKey: TTestRecord4;
  RemoveKey: TTestRecord4;
  FindKey: TTestRecord4;
begin
  AddKey := MakeKey(10, 20);
  FDictionary.Add(AddKey, MakeValue(1));

  RemoveKey := MakeKey(10, 20);
  FDictionary.Remove(RemoveKey);

  FindKey := MakeKey(10, 20);

  Assert.AreEqual(0, FDictionary.Count);
  Assert.IsFalse(FDictionary.ContainsKey(FindKey));
end;

procedure TObjectDictionary4ByteITest.TestDuplicateKey;
var
  AddKey: TTestRecord4;
  DuplicateKey: TTestRecord4;
  DuplicateValue: TTestObject2;
begin
  AddKey := MakeKey(5, 6);
  FDictionary.Add(AddKey, MakeValue(1));

  DuplicateKey := MakeKey(5, 6);
  DuplicateValue := MakeValue(2);
  try
    Assert.WillRaise(
      procedure
      begin
        FDictionary.Add(DuplicateKey, DuplicateValue);
      end,
      EListError);
  finally
    DuplicateValue.Free;
  end;
end;

procedure TObjectDictionary4ByteITest.TestDifferentRecordsSameFirstField;
var
  AddKey1: TTestRecord4;
  AddKey2: TTestRecord4;
  FindKey1: TTestRecord4;
  FindKey2: TTestRecord4;
begin
  AddKey1 := MakeKey(10, 20);
  AddKey2 := MakeKey(10, 21);

  FDictionary.Add(AddKey1, MakeValue(1));
  FDictionary.Add(AddKey2, MakeValue(2));

  FindKey1 := MakeKey(10, 20);
  FindKey2 := MakeKey(10, 21);

  Assert.AreEqual(2, FDictionary.Count);
  Assert.AreEqual(1, FDictionary[FindKey1].Value);
  Assert.AreEqual(2, FDictionary[FindKey2].Value);
end;

procedure TObjectDictionary4ByteITest.TestDifferentRecordsSameSecondField;
var
  AddKey1: TTestRecord4;
  AddKey2: TTestRecord4;
  FindKey1: TTestRecord4;
  FindKey2: TTestRecord4;
begin
  AddKey1 := MakeKey(30, 40);
  AddKey2 := MakeKey(31, 40);

  FDictionary.Add(AddKey1, MakeValue(5));
  FDictionary.Add(AddKey2, MakeValue(6));

  FindKey1 := MakeKey(30, 40);
  FindKey2 := MakeKey(31, 40);

  Assert.AreEqual(5, FDictionary[FindKey1].Value);
  Assert.AreEqual(6, FDictionary[FindKey2].Value);
end;

procedure TObjectDictionary4ByteITest.TestNegativeValues;
var
  AddKey: TTestRecord4;
  ContainsKey: TTestRecord4;
  FindKey: TTestRecord4;
begin
  AddKey := MakeKey(-12345, -23456);
  FDictionary.Add(AddKey, MakeValue(42));

  ContainsKey := MakeKey(-12345, -23456);
  FindKey := MakeKey(-12345, -23456);

  Assert.IsTrue(FDictionary.ContainsKey(ContainsKey));
  Assert.AreEqual(42, FDictionary[FindKey].Value);
end;

procedure TObjectDictionary4ByteITest.TestMinMaxValues;
var
  AddKey1: TTestRecord4;
  AddKey2: TTestRecord4;
  FindKey1: TTestRecord4;
  FindKey2: TTestRecord4;
begin
  AddKey1 := MakeKey(Low(SmallInt), High(SmallInt));
  AddKey2 := MakeKey(High(SmallInt), Low(SmallInt));

  FDictionary.Add(AddKey1, MakeValue(1));
  FDictionary.Add(AddKey2, MakeValue(2));

  FindKey1 := MakeKey(Low(SmallInt), High(SmallInt));
  FindKey2 := MakeKey(High(SmallInt), Low(SmallInt));

  Assert.AreEqual(1, FDictionary[FindKey1].Value);
  Assert.AreEqual(2, FDictionary[FindKey2].Value);
end;

procedure TObjectDictionary4ByteITest.TestMany;
const
  ItemCount = 50000;
var
  I: Integer;
  AddKey: TTestRecord4;
  FindKey: TTestRecord4;
  RemoveKey: TTestRecord4;
  Value: TTestObject2;

  function MakeUniqueKey(const AIndex: Integer): TTestRecord4;
  var
    N: Cardinal;
  begin
    N := Cardinal(AIndex - 1);

    Result := MakeKey(
      SmallInt(N and $FF),
      SmallInt((N shr 8) and $FF));
  end;

begin
  for I := 1 to ItemCount do
  begin
    AddKey := MakeUniqueKey(I);
    FDictionary.Add(AddKey, MakeValue(I));
  end;

  Assert.AreEqual(ItemCount, FDictionary.Count);

  for I := 1 to ItemCount do
  begin
    FindKey := MakeUniqueKey(I);

    Assert.IsTrue(FDictionary.TryGetValue(FindKey, Value));
    Assert.AreEqual(I, Value.Value);
  end;

  for I := 1 to ItemCount do
  begin
    RemoveKey := MakeUniqueKey(I);
    FDictionary.Remove(RemoveKey);
  end;

  Assert.AreEqual(0, FDictionary.Count);
end;

procedure TObjectDictionary4ByteITest.TestOverwriteValue;
var
  AddKey: TTestRecord4;
  SetKey: TTestRecord4;
  FindKey: TTestRecord4;
begin
  AddKey := MakeKey(8, 9);
  FDictionary.Add(AddKey, MakeValue(1));

  SetKey := MakeKey(8, 9);
  FDictionary[SetKey] := MakeValue(999);

  FindKey := MakeKey(8, 9);

  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(999, FDictionary[FindKey].Value);
end;

procedure TObjectDictionary4ByteITest.TestExtractPair;
var
  AddKey: TTestRecord4;
  ExtractKey: TTestRecord4;
  ContainsKey: TTestRecord4;
  Pair: TPair<TTestRecord4, TTestObject2>;
begin
  AddKey := MakeKey(100, 200);
  FDictionary.Add(AddKey, MakeValue(7));

  ExtractKey := MakeKey(100, 200);
  Pair := FDictionary.ExtractPair(ExtractKey);
  try
    ContainsKey := MakeKey(100, 200);

    Assert.AreEqual(0, FDictionary.Count);
    Assert.AreEqual(7, Pair.Value.Value);
    Assert.AreEqual(Integer(100), Integer(Pair.Key.Field1));
    Assert.AreEqual(Integer(200), Integer(Pair.Key.Field2));
    Assert.IsFalse(FDictionary.ContainsKey(ContainsKey));
  finally
    Pair.Value.Free;
  end;
end;

{ TObjectDictionary2ByteITest }

function TObjectDictionary2ByteITest.MakeKey(
  const AField1, AField2: Byte): TTestRecord2;
begin
  Result.Field1 := AField1;
  Result.Field2 := AField2;
end;

function TObjectDictionary2ByteITest.MakeValue(
  const AValue: Integer): TTestObject2;
begin
  Result := TTestObject2.Create(AValue);
end;

procedure TObjectDictionary2ByteITest.Setup;
begin
  FDictionary := TObjectDictionary<TTestRecord2, TTestObject2>.Create(
    [doOwnsValues]);
end;

procedure TObjectDictionary2ByteITest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TObjectDictionary2ByteITest.TestRecordSize;
begin
  Assert.AreEqual(2, SizeOf(TTestRecord2));
end;

procedure TObjectDictionary2ByteITest.TestFind;
var
  AddKey: TTestRecord2;
  FindKey: TTestRecord2;
begin
  AddKey := MakeKey(1, 3);
  FDictionary.Add(AddKey, MakeValue(99));

  FindKey := MakeKey(1, 3);

  Assert.AreEqual(99, FDictionary[FindKey].Value);
end;

procedure TObjectDictionary2ByteITest.TestTryGetValue;
var
  AddKey: TTestRecord2;
  FindKey: TTestRecord2;
  Value: TTestObject2;
begin
  AddKey := MakeKey(44, 55);
  FDictionary.Add(AddKey, MakeValue(8));

  FindKey := MakeKey(44, 55);

  Assert.IsTrue(FDictionary.TryGetValue(FindKey, Value));
  Assert.AreEqual(8, Value.Value);
end;

procedure TObjectDictionary2ByteITest.TestContainsKey;
var
  AddKey: TTestRecord2;
  ExistingKey: TTestRecord2;
  MissingKey: TTestRecord2;
begin
  AddKey := MakeKey(1, 2);
  FDictionary.Add(AddKey, MakeValue(1));

  ExistingKey := MakeKey(1, 2);
  MissingKey := MakeKey(1, 3);

  Assert.IsTrue(FDictionary.ContainsKey(ExistingKey));
  Assert.IsFalse(FDictionary.ContainsKey(MissingKey));
end;

procedure TObjectDictionary2ByteITest.TestRemove;
var
  AddKey: TTestRecord2;
  RemoveKey: TTestRecord2;
  FindKey: TTestRecord2;
begin
  AddKey := MakeKey(10, 20);
  FDictionary.Add(AddKey, MakeValue(1));

  RemoveKey := MakeKey(10, 20);
  FDictionary.Remove(RemoveKey);

  FindKey := MakeKey(10, 20);

  Assert.AreEqual(0, FDictionary.Count);
  Assert.IsFalse(FDictionary.ContainsKey(FindKey));
end;

procedure TObjectDictionary2ByteITest.TestDuplicateKey;
var
  AddKey: TTestRecord2;
  DuplicateKey: TTestRecord2;
  DuplicateValue: TTestObject2;
begin
  AddKey := MakeKey(5, 6);
  FDictionary.Add(AddKey, MakeValue(1));

  DuplicateKey := MakeKey(5, 6);
  DuplicateValue := MakeValue(2);
  try
    Assert.WillRaise(
      procedure
      begin
        FDictionary.Add(DuplicateKey, DuplicateValue);
      end,
      EListError);
  finally
    DuplicateValue.Free;
  end;
end;

procedure TObjectDictionary2ByteITest.TestDifferentRecordsSameFirstField;
var
  AddKey1: TTestRecord2;
  AddKey2: TTestRecord2;
  FindKey1: TTestRecord2;
  FindKey2: TTestRecord2;
begin
  AddKey1 := MakeKey(10, 20);
  AddKey2 := MakeKey(10, 21);

  FDictionary.Add(AddKey1, MakeValue(1));
  FDictionary.Add(AddKey2, MakeValue(2));

  FindKey1 := MakeKey(10, 20);
  FindKey2 := MakeKey(10, 21);

  Assert.AreEqual(2, FDictionary.Count);
  Assert.AreEqual(1, FDictionary[FindKey1].Value);
  Assert.AreEqual(2, FDictionary[FindKey2].Value);
end;

procedure TObjectDictionary2ByteITest.TestDifferentRecordsSameSecondField;
var
  AddKey1: TTestRecord2;
  AddKey2: TTestRecord2;
  FindKey1: TTestRecord2;
  FindKey2: TTestRecord2;
begin
  AddKey1 := MakeKey(30, 40);
  AddKey2 := MakeKey(31, 40);

  FDictionary.Add(AddKey1, MakeValue(5));
  FDictionary.Add(AddKey2, MakeValue(6));

  FindKey1 := MakeKey(30, 40);
  FindKey2 := MakeKey(31, 40);

  Assert.AreEqual(5, FDictionary[FindKey1].Value);
  Assert.AreEqual(6, FDictionary[FindKey2].Value);
end;

procedure TObjectDictionary2ByteITest.TestZeroValues;
var
  AddKey: TTestRecord2;
  FindKey: TTestRecord2;
begin
  AddKey := MakeKey(0, 0);
  FDictionary.Add(AddKey, MakeValue(100));

  FindKey := MakeKey(0, 0);

  Assert.IsTrue(FDictionary.ContainsKey(FindKey));
  Assert.AreEqual(100, FDictionary[FindKey].Value);
end;

procedure TObjectDictionary2ByteITest.TestMinMaxValues;
var
  AddKey1: TTestRecord2;
  AddKey2: TTestRecord2;
  FindKey1: TTestRecord2;
  FindKey2: TTestRecord2;
begin
  AddKey1 := MakeKey(Low(Byte), High(Byte));
  AddKey2 := MakeKey(High(Byte), Low(Byte));

  FDictionary.Add(AddKey1, MakeValue(1));
  FDictionary.Add(AddKey2, MakeValue(2));

  FindKey1 := MakeKey(Low(Byte), High(Byte));
  FindKey2 := MakeKey(High(Byte), Low(Byte));

  Assert.AreEqual(1, FDictionary[FindKey1].Value);
  Assert.AreEqual(2, FDictionary[FindKey2].Value);
end;

procedure TObjectDictionary2ByteITest.TestMany;
const
  ItemCount = 65536;
var
  I: Integer;
  AddKey: TTestRecord2;
  FindKey: TTestRecord2;
  RemoveKey: TTestRecord2;
  Value: TTestObject2;

  function MakeUniqueKey(const AIndex: Integer): TTestRecord2;
  var
    N: Cardinal;
  begin
    N := Cardinal(AIndex - 1);

    Result := MakeKey(
      Byte(N and $FF),
      Byte((N shr 8) and $FF));
  end;

begin
  for I := 1 to ItemCount do
  begin
    AddKey := MakeUniqueKey(I);
    FDictionary.Add(AddKey, MakeValue(I));
  end;

  Assert.AreEqual(ItemCount, FDictionary.Count);

  for I := 1 to ItemCount do
  begin
    FindKey := MakeUniqueKey(I);

    Assert.IsTrue(FDictionary.TryGetValue(FindKey, Value));
    Assert.AreEqual(I, Value.Value);
  end;

  for I := 1 to ItemCount do
  begin
    RemoveKey := MakeUniqueKey(I);
    FDictionary.Remove(RemoveKey);
  end;

  Assert.AreEqual(0, FDictionary.Count);
end;

procedure TObjectDictionary2ByteITest.TestOverwriteValue;
var
  AddKey: TTestRecord2;
  SetKey: TTestRecord2;
  FindKey: TTestRecord2;
begin
  AddKey := MakeKey(8, 9);
  FDictionary.Add(AddKey, MakeValue(1));

  SetKey := MakeKey(8, 9);
  FDictionary[SetKey] := MakeValue(999);

  FindKey := MakeKey(8, 9);

  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(999, FDictionary[FindKey].Value);
end;

procedure TObjectDictionary2ByteITest.TestExtractPair;
var
  AddKey: TTestRecord2;
  ExtractKey: TTestRecord2;
  ContainsKey: TTestRecord2;
  Pair: TPair<TTestRecord2, TTestObject2>;
begin
  AddKey := MakeKey(100, 200);
  FDictionary.Add(AddKey, MakeValue(7));

  ExtractKey := MakeKey(100, 200);
  Pair := FDictionary.ExtractPair(ExtractKey);
  try
    ContainsKey := MakeKey(100, 200);

    Assert.AreEqual(0, FDictionary.Count);
    Assert.AreEqual(7, Pair.Value.Value);
    Assert.AreEqual(Byte(100), Byte(Pair.Key.Field1));
    Assert.AreEqual(Byte(200), Byte(Pair.Key.Field2));
    Assert.IsFalse(FDictionary.ContainsKey(ContainsKey));
  finally
    Pair.Value.Free;
  end;
end;

{ TDictionarySetTest }

procedure TDictionarySetTest.Setup;
begin
  FDictionary := TDictionary<Pointer, TSomeKind>.Create;
end;

procedure TDictionarySetTest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TDictionarySetTest.TestAdd;
const
  Count = 100000;
var
  I: Integer;
begin
  for I := 1 to Count do
    FDictionary.Add(Pointer(NativeInt(I)), TSomeKind(I mod 31));

  Assert.AreEqual(Count, FDictionary.Count);
end;

procedure TDictionarySetTest.TestRecordSize;
begin
  Writeln(Format('SizeOf(TPair<Pointer,TSomeKind>) = %d',
    [SizeOf(TPair<Pointer, TSomeKind>)]));
end;

procedure TDictionarySetTest.TestFind;
var
  Value: TSomeKind;
begin
  FDictionary.Add(Pointer(1), kind10);

  Value := FDictionary.Items[Pointer(1)];

  Assert.AreEqual(kind10, Value);
end;

procedure TDictionarySetTest.TestTryGetValue;
var
  Value: TSomeKind;
begin
  FDictionary.Add(Pointer(1), kind20);

  Assert.IsTrue(FDictionary.TryGetValue(Pointer(1), Value));
  Assert.AreEqual(kind20, Value);

  Assert.IsFalse(FDictionary.TryGetValue(Pointer(2), Value));
end;

procedure TDictionarySetTest.TestContainsKey;
begin
  FDictionary.Add(Pointer(1), kind1);

  Assert.IsTrue(FDictionary.ContainsKey(Pointer(1)));
  Assert.IsFalse(FDictionary.ContainsKey(Pointer(2)));
end;

procedure TDictionarySetTest.TestRemove;
begin
  FDictionary.Add(Pointer(1), kind1);

  Assert.IsTrue(FDictionary.ContainsKey(Pointer(1)));

  FDictionary.Remove(Pointer(1));

  Assert.IsFalse(FDictionary.ContainsKey(Pointer(1)));
  Assert.AreEqual(0, FDictionary.Count);
end;

procedure TDictionarySetTest.TestDuplicateKey;
begin
  FDictionary.Add(Pointer(1), kind1);

  Assert.WillRaise(
    procedure
    begin
      FDictionary.Add(Pointer(1), kind2);
    end,
    EListError);
end;

procedure TDictionarySetTest.TestDifferentRecordsSameFirstField;
begin
  FDictionary.Add(Pointer(1), kind1);
  FDictionary.Add(Pointer(2), kind1);

  Assert.AreEqual(2, FDictionary.Count);
  Assert.AreEqual(kind1, FDictionary[Pointer(1)]);
  Assert.AreEqual(kind1, FDictionary[Pointer(2)]);
end;

procedure TDictionarySetTest.TestDifferentRecordsSameSecondField;
begin
  FDictionary.Add(Pointer(1), kind5);
  FDictionary.Add(Pointer(1), kind5);
end;

procedure TDictionarySetTest.TestZeroValues;
begin
  FDictionary.Add(nil, kind1);

  Assert.IsTrue(FDictionary.ContainsKey(nil));
  Assert.AreEqual(kind1, FDictionary[nil]);
end;

procedure TDictionarySetTest.TestMinMaxValues;
begin
  FDictionary.Add(Pointer(1), Low(TSomeKind));
  FDictionary.Add(Pointer(2), High(TSomeKind));

  Assert.AreEqual(Low(TSomeKind), FDictionary[Pointer(1)]);
  Assert.AreEqual(High(TSomeKind), FDictionary[Pointer(2)]);
end;

procedure TDictionarySetTest.TestMany;
const
  Count = 100000;
var
  I: Integer;
  Value: TSomeKind;
begin
  for I := 1 to Count do
    FDictionary.Add(Pointer(NativeInt(I)), TSomeKind(I mod 31));

  Assert.AreEqual(Count, FDictionary.Count);

  for I := 1 to Count do
  begin
    Assert.IsTrue(FDictionary.TryGetValue(Pointer(NativeInt(I)), Value));
    Assert.AreEqual(TSomeKind(I mod 31), Value);
  end;
end;

procedure TDictionarySetTest.TestOverwriteValue;
begin
  FDictionary.Add(Pointer(1), kind1);

  FDictionary[Pointer(1)] := kind31;

  Assert.AreEqual(kind31, FDictionary[Pointer(1)]);
end;

procedure TDictionarySetTest.TestExtractPair;
var
  Pair: TPair<Pointer, TSomeKind>;
begin
  FDictionary.Add(Pointer(1), kind7);

  Pair := FDictionary.ExtractPair(Pointer(1));

  Assert.AreEqual(Pointer(1), Pair.Key);
  Assert.AreEqual(kind7, Pair.Value);

  Assert.IsFalse(FDictionary.ContainsKey(Pointer(1)));
  Assert.AreEqual(0, FDictionary.Count);
end;

{ TDictionaryClassTest }

procedure TDictionaryClassTest.Setup;
begin
  FDictionary := TDictionary<TClass, Integer>.Create;
end;

procedure TDictionaryClassTest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TDictionaryClassTest.TestAdd;
begin
  FDictionary.Add(TObject, 1);
  FDictionary.Add(TPersistent, 2);

  Assert.AreEqual(2, FDictionary.Count);
end;

initialization
  TDUnitX.RegisterTestFixture(TDictionaryISTest);
  TDUnitX.RegisterTestFixture(TDictionarySSTest);
  TDUnitX.RegisterTestFixture(TDictionaryIITest);
  TDUnitX.RegisterTestFixture(TDictionaryIDTest);
  TDUnitX.RegisterTestFixture(TDictionaryIPTest);
  TDUnitX.RegisterTestFixture(TDictionaryIIntfTest);
  TDUnitX.RegisterTestFixture(TObjectDictionaryIOTest);
  TDUnitX.RegisterTestFixture(TCustomObjectDictionaryIOTest);
  TDUnitX.RegisterTestFixture(TObjectDictionaryOITest);
  TDUnitX.RegisterTestFixture(TCustomObjectDictionaryOITest);
  TDUnitX.RegisterTestFixture(TRecordDictionaryITest);
  TDUnitX.RegisterTestFixture(TObjectDictionaryITest);
  TDUnitX.RegisterTestFixture(TObjectDictionary4ByteITest);
  TDUnitX.RegisterTestFixture(TObjectDictionary2ByteITest);
  TDUnitX.RegisterTestFixture(TDictionarySetTest);
  TDUnitX.RegisterTestFixture(TDictionaryClassTest);

end.


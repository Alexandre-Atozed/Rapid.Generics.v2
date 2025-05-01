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
  DUnitX.TestFramework;

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

// Define the interface
  ITestInterface = interface
    ['{DFB870C1-D271-44FA-9C5D-627FC2407B0A}']
    function GetValue: Integer;
    procedure SetValue(AValue: Integer);
    property Value: Integer read GetValue write SetValue;
  end;

  // Implementation class for the interface
  TTestObject = class(TInterfacedObject, ITestInterface)
  private
    FValue: Integer;
    function GetValue: Integer;
    procedure SetValue(AValue: Integer);
  public
    constructor Create(AValue: Integer);
    procedure BeforeDestruction; override;
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

  TTestObject2 = class
  private
    FId: Integer;
  public
    constructor Create(AValue: Integer);
    property ID: Integer read FId;
  end;

  [TestFixture]
  TObjectDictionaryIOTest = class
  private
    FDictionary: TObjectDictionary<Integer, TTestObject2>;
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

  TCustomObjectDictionary = class(TObjectDictionary<Integer, TTestObject2>)
  protected
    procedure KeyNotify(const Key: Integer; Action: TCollectionNotification); override;
    procedure ValueNotify(const Value: TTestObject2; Action: TCollectionNotification); override;
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
    FDictionary: TObjectDictionary<TTestObject2, Integer>;
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

  TCustomObjectDictionary2 = class(TObjectDictionary<TTestObject2, Integer>)
  protected
    procedure KeyNotify(const Key: TTestObject2; Action: TCollectionNotification); override;
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

{ TMyObjectType }

constructor TTestObject.Create(AValue: Integer);
begin
  inherited Create;
  FValue := AValue;
end;

procedure TTestObject.BeforeDestruction;
begin
  // For debugging
  inherited;
end;

function TTestObject.GetValue: Integer;
begin
  Result := FValue;
end;

procedure TTestObject.SetValue(AValue: Integer);
begin
  FValue := AValue;
end;

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
  FDictionary.Add(1, TTestObject.Create(11));
  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(11, FDictionary.Items[1].Value);
end;

procedure TDictionaryIIntfTest.TestRemove;
begin
  FDictionary.Add(1, TTestObject.Create(11));
  FDictionary.Remove(1);
  Assert.IsFalse(FDictionary.ContainsKey(1));
end;

procedure TDictionaryIIntfTest.TestFind;
var
  FoundValue: ITestInterface;
begin
  FDictionary.Add(1, TTestObject.Create(11));
  FoundValue := FDictionary.Items[1]; // Direct access as "Find" is not standard
  Assert.IsNotNull(FoundValue);
  Assert.AreEqual(11, FoundValue.Value);
end;

procedure TDictionaryIIntfTest.TestFindOrAdd;
var
  FoundValue: ITestInterface;
begin
  // AddOrSetValue simulates FindOrAdd behavior
  FDictionary.AddOrSetValue(2, TTestObject.Create(22));
  FoundValue := FDictionary.Items[2];
  Assert.IsNotNull(FoundValue);
  Assert.AreEqual(22, FoundValue.Value);
end;

procedure TDictionaryIIntfTest.TestExtractPair;
var
  Pair: TPair<Integer, ITestInterface>;
begin
  FDictionary.Add(3, TTestObject.Create(33));
  Pair := FDictionary.ExtractPair(3);
  Assert.AreEqual(3, Pair.Key);
  Assert.AreEqual(33, Pair.Value.Value);
  Assert.IsFalse(FDictionary.ContainsKey(3));
end;

procedure TDictionaryIIntfTest.TestTryGetValue;
var
  Value: ITestInterface;
begin
  FDictionary.Add(4, TTestObject.Create(44));
  Assert.IsTrue(FDictionary.TryGetValue(4, Value));
  Assert.AreEqual(44, Value.Value);
end;

procedure TDictionaryIIntfTest.TestAddOrSetValue;
begin
  FDictionary.AddOrSetValue(5, TTestObject.Create(55));
  Assert.AreEqual(55, FDictionary.Items[5].Value);
  FDictionary.AddOrSetValue(5, TTestObject.Create(56));
  Assert.AreEqual(56, FDictionary.Items[5].Value);
end;

procedure TDictionaryIIntfTest.TestContainsKey;
begin
  FDictionary.Add(6, TTestObject.Create(66));
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
    FDictionary.Add(I, TTestObject.Create(I * 10 + I));
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

{ TTestObject2 }

constructor TTestObject2.Create(AValue: Integer);
begin
  FID := AValue;
end;

{ TObjectDictionaryIOTest }   // Owns Values

procedure TObjectDictionaryIOTest.Setup;
begin
  // Create dictionary with ownership of values
  FDictionary := TObjectDictionary<Integer, TTestObject2>.Create([doOwnsValues]);
end;

procedure TObjectDictionaryIOTest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TObjectDictionaryIOTest.TestAdd;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(1, Obj);
  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(11, FDictionary.Items[1].ID);
end;

procedure TObjectDictionaryIOTest.TestRemove;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(1, Obj);
  FDictionary.Remove(1); // Dictionary frees the object
  Assert.IsFalse(FDictionary.ContainsKey(1));
end;

procedure TObjectDictionaryIOTest.TestFind;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(1, Obj);
  Assert.IsNotNull(FDictionary.Items[1]);
  Assert.AreEqual(11, FDictionary.Items[1].ID);
end;

procedure TObjectDictionaryIOTest.TestFindOrAdd;
var
  Obj: TTestObject2;
begin
  // Since FindOrAdd doesn't exist in Delphi's TDictionary, simulate it
  if not FDictionary.TryGetValue(2, Obj) then
  begin
    Obj := TTestObject2.Create(22);
    FDictionary.Add(2, Obj);
  end;
  Assert.IsNotNull(Obj);
  Assert.AreEqual(22, FDictionary.Items[2].ID);
end;

procedure TObjectDictionaryIOTest.TestExtractPair;
var
  Obj: TTestObject2;
  Pair: TPair<Integer, TTestObject2>;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(3, Obj);
  Pair := FDictionary.ExtractPair(3); // Extracted object is not freed
  Assert.AreEqual(3, Pair.Key);
  Assert.AreEqual(11, Pair.Value.ID);
  Assert.IsFalse(FDictionary.ContainsKey(3));
  Pair.Value.Free; // Manually free extracted object
end;

procedure TObjectDictionaryIOTest.TestTryGetValue;
var
  Obj: TTestObject2;
  Value: TTestObject2;
begin
  Obj := TTestObject2.Create(44);
  FDictionary.Add(4, Obj);
  Assert.IsTrue(FDictionary.TryGetValue(4, Value));
  Assert.AreEqual(44, Value.ID);
end;

procedure TObjectDictionaryIOTest.TestAddOrSetValue;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(55);
  FDictionary.AddOrSetValue(5, Obj);
  Assert.AreEqual(55, FDictionary.Items[5].ID);
  Obj := TTestObject2.Create(56);
  FDictionary.AddOrSetValue(5, Obj); // Previous object is freed by dictionary
  Assert.AreEqual(56, FDictionary.Items[5].ID);
end;

procedure TObjectDictionaryIOTest.TestContainsKey;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(66);
  FDictionary.Add(6, Obj);
  Assert.IsTrue(FDictionary.ContainsKey(6));
  Assert.IsFalse(FDictionary.ContainsKey(7));
end;

procedure TObjectDictionaryIOTest.TestMany;
const
  ItemCount = 100000;
var
  I: Integer;
  Value: TTestObject2;
  Obj: TTestObject2;
begin
  // Add items
  for I := 1 to ItemCount do
  begin
    Obj := TTestObject2.Create(I * 10 + I);
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

procedure TCustomObjectDictionary.ValueNotify(const Value: TTestObject2;
  Action: TCollectionNotification);
begin
  // Just need a different method
  inherited;
end;

{ TCustomObjectDictionaryIOTest }  // Owns Values, overriden KeyNotify and ValueNotify

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
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(1, Obj);
  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(11, FDictionary.Items[1].ID);
end;

procedure TCustomObjectDictionaryIOTest.TestRemove;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(1, Obj);
  FDictionary.Remove(1); // Dictionary frees the object
  Assert.IsFalse(FDictionary.ContainsKey(1));
end;

procedure TCustomObjectDictionaryIOTest.TestFind;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(1, Obj);
  Assert.IsNotNull(FDictionary.Items[1]);
  Assert.AreEqual(11, FDictionary.Items[1].ID);
end;

procedure TCustomObjectDictionaryIOTest.TestFindOrAdd;
var
  Obj: TTestObject2;
begin
  // Since FindOrAdd doesn't exist in Delphi's TDictionary, simulate it
  if not FDictionary.TryGetValue(2, Obj) then
  begin
    Obj := TTestObject2.Create(22);
    FDictionary.Add(2, Obj);
  end;
  Assert.IsNotNull(Obj);
  Assert.AreEqual(22, FDictionary.Items[2].ID);
end;

procedure TCustomObjectDictionaryIOTest.TestExtractPair;
var
  Obj: TTestObject2;
  Pair: TPair<Integer, TTestObject2>;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(3, Obj);
  Pair := FDictionary.ExtractPair(3); // Extracted object is not freed
  Assert.AreEqual(3, Pair.Key);
  Assert.AreEqual(11, Pair.Value.ID);
  Assert.IsFalse(FDictionary.ContainsKey(3));
  Pair.Value.Free; // Manually free extracted object
end;

procedure TCustomObjectDictionaryIOTest.TestTryGetValue;
var
  Obj: TTestObject2;
  Value: TTestObject2;
begin
  Obj := TTestObject2.Create(44);
  FDictionary.Add(4, Obj);
  Assert.IsTrue(FDictionary.TryGetValue(4, Value));
  Assert.AreEqual(44, Value.ID);
end;

procedure TCustomObjectDictionaryIOTest.TestAddOrSetValue;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(55);
  FDictionary.AddOrSetValue(5, Obj);
  Assert.AreEqual(55, FDictionary.Items[5].ID);
  Obj := TTestObject2.Create(56);
  FDictionary.AddOrSetValue(5, Obj); // Previous object is freed by dictionary
  Assert.AreEqual(56, FDictionary.Items[5].ID);
end;

procedure TCustomObjectDictionaryIOTest.TestContainsKey;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(66);
  FDictionary.Add(6, Obj);
  Assert.IsTrue(FDictionary.ContainsKey(6));
  Assert.IsFalse(FDictionary.ContainsKey(7));
end;

procedure TCustomObjectDictionaryIOTest.TestMany;
const
  ItemCount = 100000;
var
  I: Integer;
  Value: TTestObject2;
  Obj: TTestObject2;
begin
  // Add items
  for I := 1 to ItemCount do
  begin
    Obj := TTestObject2.Create(I * 10 + I);
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

{ TObjectDictionaryOITest }  // Owns keys

procedure TObjectDictionaryOITest.Setup;
begin
  // Create dictionary with ownership of keys
  FDictionary := TObjectDictionary<TTestObject2, Integer>.Create([doOwnsKeys]);
end;

procedure TObjectDictionaryOITest.TearDown;
begin
  FreeAndNil(FDictionary);
end;

procedure TObjectDictionaryOITest.TestAdd;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(Obj, 1);
  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(1, FDictionary.Items[Obj]);
end;

procedure TObjectDictionaryOITest.TestRemove;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(Obj, 1);
  FDictionary.Remove(Obj); // Dictionary frees the object

  Assert.IsTrue(FDictionary.Count = 0);
end;

procedure TObjectDictionaryOITest.TestFind;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(Obj, 1);
  Assert.AreEqual(1, FDictionary.Items[Obj]);
end;

procedure TObjectDictionaryOITest.TestFindOrAdd;
var
  Obj: TTestObject2;
  Value: Integer;
begin
  Obj := TTestObject2.Create(22);
  if not FDictionary.TryGetValue(Obj, Value) then
    FDictionary.Add(Obj, 2);
  Assert.IsTrue(FDictionary.TryGetValue(Obj, Value));
  Assert.AreEqual(2, Value);
end;

procedure TObjectDictionaryOITest.TestExtractPair;
var
  Obj: TTestObject2;
  Pair: TPair<TTestObject2, Integer>;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(Obj, 3);
  Pair := FDictionary.ExtractPair(Obj); // Extracted key is not freed
  Assert.AreEqual(3, Pair.Value);
  Assert.AreEqual(11, Pair.Key.ID);
  Assert.IsFalse(FDictionary.ContainsKey(Pair.Key));
  Pair.Key.Free; // Manually free extracted key
end;

procedure TObjectDictionaryOITest.TestTryGetValue;
var
  Obj: TTestObject2;
  Value: Integer;
begin
  Obj := TTestObject2.Create(44);
  FDictionary.Add(Obj, 4);
  Assert.IsTrue(FDictionary.TryGetValue(Obj, Value));
  Assert.AreEqual(4, Value);
end;

procedure TObjectDictionaryOITest.TestAddOrSetValue;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(55);
  FDictionary.AddOrSetValue(Obj, 5);
  Assert.AreEqual(5, FDictionary.Items[Obj]);

  Obj := TTestObject2.Create(56);
  FDictionary.AddOrSetValue(Obj, 6); // Previous key is freed
  Assert.AreEqual(6, FDictionary.Items[Obj]);
end;

procedure TObjectDictionaryOITest.TestContainsKey;
var
  Obj1, Obj2: TTestObject2;
begin
  Obj1 := TTestObject2.Create(66);
  Obj2 := TTestObject2.Create(77);
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
  Obj: TTestObject2;
  Value: Integer;
begin
  // Add items
  for I := 1 to ItemCount do
  begin
    Obj := TTestObject2.Create(I * 10 + I);
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

procedure TCustomObjectDictionary2.KeyNotify(const Key: TTestObject2;
  Action: TCollectionNotification);
begin
  inherited;
end;

procedure TCustomObjectDictionary2.ValueNotify(const Value: Integer;
  Action: TCollectionNotification);
begin
  inherited;
end;

{ TCustomObjectDictionaryOITest }  // Owns keys, overrides KeyNotify and ValueNotify

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
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(Obj, 1);
  Assert.AreEqual(1, FDictionary.Count);
  Assert.AreEqual(1, FDictionary.Items[Obj]);
end;

procedure TCustomObjectDictionaryOITest.TestRemove;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(Obj, 1);
  FDictionary.Remove(Obj); // Dictionary frees the object

  Assert.IsTrue(FDictionary.Count = 0);
end;

procedure TCustomObjectDictionaryOITest.TestFind;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(Obj, 1);
  Assert.AreEqual(1, FDictionary.Items[Obj]);
end;

procedure TCustomObjectDictionaryOITest.TestFindOrAdd;
var
  Obj: TTestObject2;
  Value: Integer;
begin
  Obj := TTestObject2.Create(22);
  if not FDictionary.TryGetValue(Obj, Value) then
    FDictionary.Add(Obj, 2);
  Assert.IsTrue(FDictionary.TryGetValue(Obj, Value));
  Assert.AreEqual(2, Value);
end;

procedure TCustomObjectDictionaryOITest.TestExtractPair;
var
  Obj: TTestObject2;
  Pair: TPair<TTestObject2, Integer>;
begin
  Obj := TTestObject2.Create(11);
  FDictionary.Add(Obj, 3);
  Pair := FDictionary.ExtractPair(Obj); // Extracted key is not freed
  Assert.AreEqual(3, Pair.Value);
  Assert.AreEqual(11, Pair.Key.ID);
  Assert.IsFalse(FDictionary.ContainsKey(Pair.Key));
  Pair.Key.Free; // Manually free extracted key
end;

procedure TCustomObjectDictionaryOITest.TestTryGetValue;
var
  Obj: TTestObject2;
  Value: Integer;
begin
  Obj := TTestObject2.Create(44);
  FDictionary.Add(Obj, 4);
  Assert.IsTrue(FDictionary.TryGetValue(Obj, Value));
  Assert.AreEqual(4, Value);
end;

procedure TCustomObjectDictionaryOITest.TestAddOrSetValue;
var
  Obj: TTestObject2;
begin
  Obj := TTestObject2.Create(55);
  FDictionary.AddOrSetValue(Obj, 5);
  Assert.AreEqual(5, FDictionary.Items[Obj]);

  Obj := TTestObject2.Create(56);
  FDictionary.AddOrSetValue(Obj, 6); // Previous key is freed
  Assert.AreEqual(6, FDictionary.Items[Obj]);
end;

procedure TCustomObjectDictionaryOITest.TestContainsKey;
var
  Obj1, Obj2: TTestObject2;
begin
  Obj1 := TTestObject2.Create(66);
  Obj2 := TTestObject2.Create(77);
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
  Obj: TTestObject2;
  Value: Integer;
begin
  // Add items
  for I := 1 to ItemCount do
  begin
    Obj := TTestObject2.Create(I * 10 + I);
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

end.


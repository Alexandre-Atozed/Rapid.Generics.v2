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

implementation

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
  FDictionary.Add(1, 'One');
  Assert.IsNotNull(FDictionary.Find(1));
end;

procedure TDictionaryISTest.TestFindOrAdd;
begin
  var P := FDictionary.FindOrAdd(2);
  Assert.IsNotNull(P);
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
  FDictionary.Add('Key1', 'One');
  Assert.IsNotNull(FDictionary.Find('Key1'));
end;

procedure TDictionarySSTest.TestFindOrAdd;
begin
  var P := FDictionary.FindOrAdd('Key2');
  Assert.IsNotNull(P);
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
  FDictionary.Add(1, 11);
  Assert.IsNotNull(FDictionary.Find(1));
end;

procedure TDictionaryIITest.TestFindOrAdd;
begin
  var P := FDictionary.FindOrAdd(2);
  Assert.IsNotNull(P);
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
  FDictionary.Add(1, 11.1);
  Assert.IsNotNull(FDictionary.Find(1));
end;

procedure TDictionaryIDTest.TestFindOrAdd;
begin
  var P := FDictionary.FindOrAdd(2);
  Assert.IsNotNull(P);
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
  FDictionary.Add(1, Pointer(11));
  Assert.IsNotNull(FDictionary.Find(1));
end;

procedure TDictionaryIPTest.TestFindOrAdd;
begin
  var P := FDictionary.FindOrAdd(2);
  Assert.IsNotNull(P);
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

initialization
  TDUnitX.RegisterTestFixture(TDictionaryISTest);
  TDUnitX.RegisterTestFixture(TDictionarySSTest);
  TDUnitX.RegisterTestFixture(TDictionaryIITest);
  TDUnitX.RegisterTestFixture(TDictionaryIDTest);
  TDUnitX.RegisterTestFixture(TDictionaryIPTest);

end.


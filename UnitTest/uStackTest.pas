unit uStackTest;

interface

{$DEFINE TEST_RAPIDGENERICS}

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
  TTestTStack = class
  private
    FStack: TStack<Integer>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestPush;
    [Test]
    procedure TestPop;
    [Test]
    procedure TestExtract;
    [Test]
    procedure TestPeek;
    [Test]
    procedure TestMany;
  end;

  [TestFixture]
  TTestTObjectStack = class
  private
    FStack: TObjectStack<TTestObject>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestPush;
    [Test]
    procedure TestPop;
    [Test]
    procedure TestExtract;
    [Test]
    procedure TestPeek;
    [Test]
    procedure TestMany;
  end;

  TCustomObjectStack = class(TObjectStack<TTestObject>)
    procedure Notify(const Item: TTestObject; Action: TCollectionNotification); override;
  end;

  [TestFixture]
  TTestTCustomObjectStack = class
  private
    FStack: TCustomObjectStack;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestPush;
    [Test]
    procedure TestPop;
    [Test]
    procedure TestExtract;
    [Test]
    procedure TestPeek;
    [Test]
    procedure TestMany;
  end;

implementation

procedure TTestTStack.Setup;
begin
  FStack := TStack<Integer>.Create;
end;

procedure TTestTStack.TearDown;
begin
  FStack.Free;
end;

procedure TTestTStack.TestPush;
begin
  FStack.Push(10);
  Assert.AreEqual(10, FStack.Peek);
end;

procedure TTestTStack.TestPop;
begin
  FStack.Push(20);
  FStack.Push(30);
  FStack.Push(40);
  Assert.AreEqual(3, FStack.Count);
  Assert.AreEqual(40, FStack.Pop);
  Assert.AreEqual(2, FStack.Count);
  Assert.AreEqual(30, FStack.Pop);
  Assert.AreEqual(1, FStack.Count);
  Assert.AreEqual(20, FStack.Pop);
  Assert.AreEqual(0, FStack.Count);
end;

procedure TTestTStack.TestExtract;
begin
  FStack.Push(30);
  FStack.Push(60);

  Assert.AreEqual(60, FStack.Extract);
  Assert.AreEqual(1, FStack.Count);

  Assert.AreEqual(30, FStack.Extract);
  Assert.AreEqual(0, FStack.Count);
end;

procedure TTestTStack.TestPeek;
begin
  FStack.Push(40);
  Assert.AreEqual(40, FStack.Peek);
  Assert.AreEqual(1, FStack.Count);
end;

procedure TTestTStack.TestMany;
const
  ItemCount = 10000;
var
  I: Integer;
begin
  // Add items
  for I := 1 to ItemCount do
    FStack.Push(I);
  Assert.AreEqual(ItemCount, FStack.Count);

  // Remove all items
  for I := ItemCount downto 1 do
    Assert.AreEqual(I, FStack.Pop);
  Assert.AreEqual(0, FStack.Count);
end;

{ TTestTObjectStack }

procedure TTestTObjectStack.Setup;
begin
  FStack := TObjectStack<TTestObject>.Create(True); // OwnsObjects = True
end;

procedure TTestTObjectStack.TearDown;
begin
  FStack.Free;
end;

procedure TTestTObjectStack.TestPush;
begin
  FStack.Push(TTestObject.Create(10));
  Assert.AreEqual(10, FStack.Peek.ID);
end;

{$Hints off}
procedure TTestTObjectStack.TestPop;
var
  Obj: TTestObject;
  RefCounter: Integer;
begin
  FStack.Push(TTestObject.Create(20, RefCounter));
  FStack.Push(TTestObject.Create(30, RefCounter));
  FStack.Push(TTestObject.Create(40, RefCounter));

  Assert.AreEqual(3, FStack.Count);

  Obj := FStack.Pop;
  Assert.AreEqual(40, RefCounter);

  Assert.AreEqual(2, FStack.Count);

  Obj := FStack.Pop;
  Assert.AreEqual(30, RefCounter);

  Assert.AreEqual(1, FStack.Count);

  Obj := FStack.Pop;
  Assert.AreEqual(20, RefCounter);

  Assert.AreEqual(0, FStack.Count);
end;

procedure TTestTObjectStack.TestExtract;
var
  Obj: TTestObject;
begin
  FStack.Push(TTestObject.Create(30));
  FStack.Push(TTestObject.Create(60));

  Obj := FStack.Extract;
  try
    Assert.AreEqual(60, Obj.ID);
  finally
    Obj.Free;
  end;
  Assert.AreEqual(1, FStack.Count);

  Obj := FStack.Extract;
  try
    Assert.AreEqual(30, Obj.ID);
  finally
    Obj.Free;
  end;
  Assert.AreEqual(0, FStack.Count);
end;

procedure TTestTObjectStack.TestPeek;
begin
  FStack.Push(TTestObject.Create(40));
  Assert.AreEqual(40, FStack.Peek.ID);
  Assert.AreEqual(1, FStack.Count);
end;

procedure TTestTObjectStack.TestMany;
const
  ItemCount = 10000;
var
  I: Integer;
  Obj: TTestObject;
  RefCounter: Integer;
begin
  for I := 1 to ItemCount do
    FStack.Push(TTestObject.Create(I, RefCounter));
  Assert.AreEqual(ItemCount, FStack.Count);

  for I := ItemCount downto 1 do
  begin
    Obj := FStack.Pop;
    Assert.AreEqual(I, RefCounter);
  end;

  Assert.AreEqual(0, FStack.Count);
end;

{ TCustomObjectStack }

procedure TCustomObjectStack.Notify(const Item: TTestObject; Action: TCollectionNotification);
begin
  inherited;
end;

{ TTestTCustomObjectStack }

// Test to detect memory leaks once Notify internal methods are different
procedure TTestTCustomObjectStack.Setup;
begin
  FStack := TCustomObjectStack.Create(True); // OwnsObjects = True
end;

procedure TTestTCustomObjectStack.TearDown;
begin
  FStack.Free;
end;

procedure TTestTCustomObjectStack.TestPush;
begin
  FStack.Push(TTestObject.Create(10));
  Assert.AreEqual(10, FStack.Peek.ID);
end;

procedure TTestTCustomObjectStack.TestPop;
var
  Obj: TTestObject;
  RefCounter: Integer;
begin
  FStack.Push(TTestObject.Create(20, RefCounter));
  FStack.Push(TTestObject.Create(30, RefCounter));
  FStack.Push(TTestObject.Create(40, RefCounter));

  Assert.AreEqual(3, FStack.Count);

  Obj := FStack.Pop;
  Assert.AreEqual(40, RefCounter);

  Assert.AreEqual(2, FStack.Count);

  Obj := FStack.Pop;
  Assert.AreEqual(30, RefCounter);

  Assert.AreEqual(1, FStack.Count);

  Obj := FStack.Pop;
  Assert.AreEqual(20, RefCounter);

  Assert.AreEqual(0, FStack.Count);
end;

procedure TTestTCustomObjectStack.TestExtract;
var
  Obj: TTestObject;
begin
  FStack.Push(TTestObject.Create(30));
  FStack.Push(TTestObject.Create(60));

  Obj := FStack.Extract;
  try
    Assert.AreEqual(60, Obj.ID);
  finally
    Obj.Free;
  end;
  Assert.AreEqual(1, FStack.Count);

  Obj := FStack.Extract;
  try
    Assert.AreEqual(30, Obj.ID);
  finally
    Obj.Free;
  end;
  Assert.AreEqual(0, FStack.Count);
end;

procedure TTestTCustomObjectStack.TestPeek;
begin
  FStack.Push(TTestObject.Create(40));
  Assert.AreEqual(40, FStack.Peek.ID);
  Assert.AreEqual(1, FStack.Count);
end;

procedure TTestTCustomObjectStack.TestMany;
const
  ItemCount = 10000;
var
  I: Integer;
  Obj: TTestObject;
  RefCounter: Integer;
begin
  for I := 1 to ItemCount do
    FStack.Push(TTestObject.Create(I, RefCounter));
  Assert.AreEqual(ItemCount, FStack.Count);

  for I := ItemCount downto 1 do
  begin
    Obj := FStack.Pop;
    Assert.AreEqual(I, RefCounter);
  end;

  Assert.AreEqual(0, FStack.Count);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTStack);
  TDUnitX.RegisterTestFixture(TTestTObjectStack);
  TDUnitX.RegisterTestFixture(TTestTCustomObjectStack);

end.

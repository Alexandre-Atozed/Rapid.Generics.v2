unit uQueueTest;

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
  TTestTQueue = class
  private
    FQueue: TQueue<Integer>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestEnqueue;
    [Test]
    procedure TestDequeue;
    [Test]
    procedure TestExtract;
    [Test]
    procedure TestPeek;
    [Test]
    procedure TestMany;
  end;

  [TestFixture]
  TTestTObjectQueue = class
  private
    FQueue: TQueue<TTestObject>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestEnqueue;
    [Test]
    procedure TestDequeue;
    [Test]
    procedure TestExtract;
    [Test]
    procedure TestPeek;
    [Test]
    procedure TestMany;
  end;

  TCustomObjectQueue = class(TObjectQueue<TTestObject>)
    procedure Notify(const Item: TTestObject; Action: TCollectionNotification); override;
  end;

  [TestFixture]
  TTestTCustomObjectQueue = class
  private
    FQueue: TQueue<TTestObject>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestEnqueue;
    [Test]
    procedure TestDequeue;
    [Test]
    procedure TestExtract;
    [Test]
    procedure TestPeek;
    [Test]
    procedure TestMany;
  end;

implementation

procedure TTestTQueue.Setup;
begin
  FQueue := TQueue<Integer>.Create;
end;

procedure TTestTQueue.TearDown;
begin
  FQueue.Free;
end;

procedure TTestTQueue.TestEnqueue;
begin
  FQueue.Enqueue(10);
  Assert.AreEqual(10, FQueue.Peek);
end;

procedure TTestTQueue.TestDequeue;
begin
  FQueue.Enqueue(20);
  Assert.AreEqual(20, FQueue.Dequeue);
  Assert.AreEqual(0, FQueue.Count);
end;

procedure TTestTQueue.TestExtract;
begin
  FQueue.Enqueue(30);
  Assert.AreEqual(30, FQueue.Extract);
  Assert.AreEqual(0, FQueue.Count);
end;

procedure TTestTQueue.TestPeek;
begin
  FQueue.Enqueue(40);
  Assert.AreEqual(40, FQueue.Peek);
  Assert.AreEqual(1, FQueue.Count);
end;

procedure TTestTQueue.TestMany;
const
  ItemCount = 10000;
var
  I: Integer;
begin
  // Add items
  for I := 1 to ItemCount do
    FQueue.Enqueue(I);
  Assert.AreEqual(ItemCount, FQueue.Count);

  // Remove all items
  for I := 1 to ItemCount do
    Assert.AreEqual(I, FQueue.Dequeue);
  Assert.AreEqual(0, FQueue.Count);
end;

{ TTestObjectQueue }

procedure TTestTObjectQueue.Setup;
begin
  FQueue := TObjectQueue<TTestObject>.Create(True); // OwnsObjects = True
end;

procedure TTestTObjectQueue.TearDown;
begin
  FQueue.Free;
end;

procedure TTestTObjectQueue.TestEnqueue;
begin
  FQueue.Enqueue(TTestObject.Create(10));
  Assert.AreEqual(10, FQueue.Peek.ID);
end;

{$HINTS off}

procedure TTestTObjectQueue.TestDequeue;
var
  Obj: TTestObject;
  RefCounter: Integer;
begin
  FQueue.Enqueue(TTestObject.Create(20, RefCounter));
  Obj := FQueue.Dequeue;
  // Any access to the object after Dequeue is not valid because the object has been destroyed
  // so we use the RefCounter. A correct RefCounter also guarantees that dequeue actually destroyed
  // the object
  Assert.AreEqual(20, RefCounter);
  Assert.AreEqual(0, FQueue.Count);
  // Dequeue frees the object. No memory leaks should occur here
end;

procedure TTestTObjectQueue.TestExtract;
var
  Obj: TTestObject;
begin
  FQueue.Enqueue(TTestObject.Create(30));
  Obj := FQueue.Extract;
  try
    Assert.AreEqual(30, Obj.ID);
    Assert.AreEqual(0, FQueue.Count);
  finally
    Obj.Free; // Still need to free after Extract
  end;
end;

procedure TTestTObjectQueue.TestPeek;
begin
  FQueue.Enqueue(TTestObject.Create(40));
  Assert.AreEqual(40, FQueue.Peek.ID);
  Assert.AreEqual(1, FQueue.Count);
end;

procedure TTestTObjectQueue.TestMany;
const
  ItemCount = 10000;
var
  I: Integer;
  Obj: TTestObject;
  RefCounter: Integer;
begin
  for I := 1 to ItemCount do
    FQueue.Enqueue(TTestObject.Create(I, RefCounter));

  Assert.AreEqual(ItemCount, FQueue.Count);

  for I := 1 to ItemCount do
  begin
    RefCounter := 0;
    Obj := FQueue.Dequeue;
    // Any access to the object after Dequeue is not valid because the object has been destroyed
    // so we use the RefCounter. A correct RefCounter also guarantees that dequeue actually destroyed
    // the object
    Assert.AreEqual(I, RefCounter);
    // Dequeue frees the object. No memory leaks should occur here
  end;

  Assert.AreEqual(0, FQueue.Count);
end;

{ TCustomObjectQueue }

procedure TCustomObjectQueue.Notify(const Item: TTestObject; Action: TCollectionNotification);
begin
  inherited;
end;

{ TTestTCustomObjectQueue }

procedure TTestTCustomObjectQueue.Setup;
begin
  FQueue := TObjectQueue<TTestObject>.Create(True); // OwnsObjects = True
end;

procedure TTestTCustomObjectQueue.TearDown;
begin
  FQueue.Free;
end;

procedure TTestTCustomObjectQueue.TestEnqueue;
begin
  FQueue.Enqueue(TTestObject.Create(10));
  Assert.AreEqual(10, FQueue.Peek.ID);
end;

procedure TTestTCustomObjectQueue.TestDequeue;
var
  Obj: TTestObject;
  RefCounter: Integer;
begin
  FQueue.Enqueue(TTestObject.Create(20, RefCounter));
  Obj := FQueue.Dequeue;
  // Any access to the object after Dequeue is not valid because the object has been destroyed
  // so we use the RefCounter. A correct RefCounter also guarantees that dequeue actually destroyed
  // the object
  Assert.AreEqual(20, RefCounter);
  Assert.AreEqual(0, FQueue.Count);
  // Dequeue frees the object. No memory leaks should occur here
end;

procedure TTestTCustomObjectQueue.TestExtract;
var
  Obj: TTestObject;
begin
  FQueue.Enqueue(TTestObject.Create(30));
  Obj := FQueue.Extract;
  try
    Assert.AreEqual(30, Obj.ID);
    Assert.AreEqual(0, FQueue.Count);
  finally
    Obj.Free; // Still need to free after Extract
  end;
end;

procedure TTestTCustomObjectQueue.TestPeek;
begin
  FQueue.Enqueue(TTestObject.Create(40));
  Assert.AreEqual(40, FQueue.Peek.ID);
  Assert.AreEqual(1, FQueue.Count);
end;

procedure TTestTCustomObjectQueue.TestMany;
const
  ItemCount = 10000;
var
  I: Integer;
  Obj: TTestObject;
  RefCounter: Integer;
begin
  for I := 1 to ItemCount do
    FQueue.Enqueue(TTestObject.Create(I, RefCounter));

  Assert.AreEqual(ItemCount, FQueue.Count);

  for I := 1 to ItemCount do
  begin
    RefCounter := 0;
    Obj := FQueue.Dequeue;
    // Any access to the object after Dequeue is not valid because the object has been destroyed
    // so we use the RefCounter. A correct RefCounter also guarantees that dequeue actually destroyed
    // the object
    Assert.AreEqual(I, RefCounter);
    // Dequeue frees the object. No memory leaks should occur here
  end;

  Assert.AreEqual(0, FQueue.Count);
end;

initialization
  TDUnitX.RegisterTestFixture(TTestTQueue);
  TDUnitX.RegisterTestFixture(TTestTObjectQueue);
  TDUnitX.RegisterTestFixture(TTestTCustomObjectQueue);

end.


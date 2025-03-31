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
  DUnitX.TestFramework;

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

initialization
  TDUnitX.RegisterTestFixture(TTestTQueue);

end.

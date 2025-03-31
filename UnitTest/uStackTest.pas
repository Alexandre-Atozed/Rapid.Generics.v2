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
  DUnitX.TestFramework;

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

initialization
  TDUnitX.RegisterTestFixture(TTestTStack);

end.


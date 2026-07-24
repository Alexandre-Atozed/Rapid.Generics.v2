unit uQueueWrapGrowTest;

interface

uses
  DUnitX.TestFramework,
  System.SysUtils,
  System.Generics.Collections,
  Rapid.Generics;

type
  // Simple refcounted probe to detect Defect B (silent nil / leaked interface ref)
  IProbe = interface
    ['{9E2B6B2E-1A2B-4C3D-8E5F-000000000001}']
    function Tag: Integer;
  end;

  TProbe = class(TInterfacedObject, IProbe)
  private
    FTag: Integer;
  public
    constructor Create(ATag: Integer);
    function Tag: Integer;
    class var LiveCount: Integer;
    destructor Destroy; override;
  end;

  [TestFixture]
  TQueueWrapGrowBugTests = class
  public
    // Defect A: FULL + wrapped queue (FTail = FHead <> 0) misrouted to
    // "contiguous" branch, causing System.Move to read out-of-bounds.
    [Test]
    procedure Test_FullWrapped_GrowthCorruptsOrder_Rapid;
    [Test]
    procedure Test_FullWrapped_GrowthCorruptsOrder_System;

    // Defect B: PARTIAL wrapped queue growth: FillChar of new slots
    // overlaps the just-moved tail segment, nilling a live interface ref.
    [Test]
    procedure Test_PartialWrapped_GrowthLeaksInterfaceRef_Rapid;
    [Test]
    procedure Test_PartialWrapped_GrowthLeaksInterfaceRef_System;

    // Regression gate matching the production scenario: repeated
    // enqueue/dequeue interleaving forces wraps, then a burst forces growth.
    [Test]
    procedure Test_InterleavedEnqueueDequeue_ThenBurstGrowth_PreservesAllItems_Rapid;
    [Test]
    procedure Test_InterleavedEnqueueDequeue_ThenBurstGrowth_PreservesAllItems_System;
  end;

  [TestFixture]
  TQueueWrapGrowExtraTests_Rapid = class
  public
    [Test]
    procedure Test_ContiguousWrapped_GrowthCompactsCorrectly;
    [Test]
    procedure Test_EmptyQueue_GrowthAfterFullDrain;
    [Test]
    procedure Test_WrappedQueue_ShrinkCapacity;
    [Test]
    procedure Test_RepeatedGrowthCycles_MaintainsFIFOOrder;
    [Test]
    procedure Test_GrowWhileFull_NotWrapped;
  end;

  [TestFixture]
  TQueueWrapGrowExtraTests_System = class
  public
    [Test]
    procedure Test_ContiguousWrapped_GrowthCompactsCorrectly_System;
    [Test]
    procedure Test_EmptyQueue_GrowthAfterFullDrain_System;
    [Test]
    procedure Test_WrappedQueue_ShrinkCapacity_System;
    [Test]
    procedure Test_RepeatedGrowthCycles_MaintainsFIFOOrder_System;
    [Test]
    procedure Test_GrowWhileFull_NotWrapped_System;
  end;

implementation

{ TProbe }

constructor TProbe.Create(ATag: Integer);
begin
  inherited Create;
  FTag := ATag;
  Inc(LiveCount);
end;

destructor TProbe.Destroy;
begin
  Dec(LiveCount);
  inherited;
end;

function TProbe.Tag: Integer;
begin
  Result := FTag;
end;

{ TQueueWrapGrowBugTests }

procedure TQueueWrapGrowBugTests.Test_FullWrapped_GrowthCorruptsOrder_Rapid;
var
  Q: Rapid.Generics.TQueue<Integer>;
  i: Integer;
  Expected, Actual: TArray<Integer>;
begin
  // Force a FULL, wrapped queue at capacity 4:
  //   Enqueue A,B,C,D (tail=0,head=0->4, cap grows once already: ignore, start clean)
  Q := Rapid.Generics.TQueue<Integer>.Create;
  try
    Q.Capacity := 4;

    // Fill to capacity contiguously: A,B,C,D  (tail=0, head=0 "full")
    Q.Enqueue(1); // A
    Q.Enqueue(2); // B
    Q.Enqueue(3); // C
    Q.Enqueue(4); // D

    // Dequeue 2, enqueue 2 -> rotates the ring so tail=head=2 and it's FULL+wrapped
    Assert.AreEqual(1, Q.Dequeue); // remove A
    Assert.AreEqual(2, Q.Dequeue); // remove B
    Q.Enqueue(5); // E -> occupies old A slot
    Q.Enqueue(6); // F -> occupies old B slot
    // Logical order now: C, D, E, F ; tail=head=2 ; Count=4 (FULL, wrapped)

    Expected := [3, 4, 5, 6];

    // Trigger growth while full+wrapped
    Q.Capacity := 8;

    SetLength(Actual, Q.Count);
    for i := 0 to Q.Count - 1 do
      Actual[i] := Q.Dequeue;

    Assert.AreEqual<TArray<Integer>>(Expected, Actual,
      'SetCapacity corrupted a FULL wrapped queue on growth (Defect A: ' +
      'FTail<=FHead misroutes FTail=FHead to contiguous branch, reading OOB)');
  finally
    Q.Free;
  end;
end;

procedure TQueueWrapGrowBugTests.Test_FullWrapped_GrowthCorruptsOrder_System;
var
  Q: System.Generics.Collections.TQueue<Integer>;
  i: Integer;
  Expected, Actual: TArray<Integer>;
begin
  // Force a FULL, wrapped queue at capacity 4:
  //   Enqueue A,B,C,D (tail=0,head=0->4, cap grows once already: ignore, start clean)
  Q := System.Generics.Collections.TQueue<Integer>.Create;
  try
    Q.Capacity := 4;

    // Fill to capacity contiguously: A,B,C,D  (tail=0, head=0 "full")
    Q.Enqueue(1); // A
    Q.Enqueue(2); // B
    Q.Enqueue(3); // C
    Q.Enqueue(4); // D

    // Dequeue 2, enqueue 2 -> rotates the ring so tail=head=2 and it's FULL+wrapped
    Assert.AreEqual(1, Q.Dequeue); // remove A
    Assert.AreEqual(2, Q.Dequeue); // remove B
    Q.Enqueue(5); // E -> occupies old A slot
    Q.Enqueue(6); // F -> occupies old B slot
    // Logical order now: C, D, E, F ; tail=head=2 ; Count=4 (FULL, wrapped)

    Expected := [3, 4, 5, 6];

    // Trigger growth while full+wrapped
    Q.Capacity := 8;

    SetLength(Actual, Q.Count);
    for i := 0 to Q.Count - 1 do
      Actual[i] := Q.Dequeue;

    Assert.AreEqual<TArray<Integer>>(Expected, Actual,
      'SetCapacity corrupted a FULL wrapped queue on growth (Defect A: ' +
      'FTail<=FHead misroutes FTail=FHead to contiguous branch, reading OOB)');
  finally
    Q.Free;
  end;
end;

procedure TQueueWrapGrowBugTests.Test_PartialWrapped_GrowthLeaksInterfaceRef_Rapid;
var
  Q: Rapid.Generics.TQueue<IProbe>;
  P0, P1: IProbe;
  Survivor: IProbe;
  Discard: IProbe;
begin
  // Force a PARTIAL wrapped queue: cap=4, tail=3, head=1, count=2
  // i.e. logical items occupy array slots [3] and [0].
  TProbe.LiveCount := 0;
  Q := Rapid.Generics.TQueue<IProbe>.Create;
  try
    Q.Capacity := 4;

    Q.Enqueue(TProbe.Create(1)); // slot 0
    Q.Enqueue(TProbe.Create(2)); // slot 1
    Q.Enqueue(TProbe.Create(3)); // slot 2
    Q.Enqueue(TProbe.Create(4)); // slot 3

    Discard := Q.Dequeue;  Discard := nil; // remove slot0 item -> head moves to 1
    Discard := Q.Dequeue;  Discard := nil;  // remove slot1 item -> head moves to 2
    Discard := Q.Dequeue;  Discard := nil;  // remove slot2 item -> head moves to 3
    // Now Count=1, tail=3 (only slot3 item 'T0' remains, at array index 3)

    P0 := TProbe.Create(100);
    Q.Enqueue(P0); // wraps: goes to slot 0 -> tail=3, head=1, Count=2

    Assert.AreEqual(2, TProbe.LiveCount,
      'Sanity check before growth: exactly 2 live probes should exist');

    // Trigger growth while PARTIAL wrapped (tail=3 > head=1)
    Q.Capacity := 8;

    // The originally-remaining item at old slot 3 ('T0'-equivalent, tag=4)
    // should still be dequeue-able and its ref should still be valid.
    Survivor := Q.Dequeue;
    Assert.IsNotNull(Survivor,
      'Defect B: FillChar of new slots overlapped the just-moved tail ' +
      'segment and nilled the live interface reference');
    Assert.AreEqual(4, Survivor.Tag);

    Assert.AreEqual(P0.Tag, Q.Dequeue.Tag);
  finally
    Q.Free;
    P0 := nil;
    Survivor := nil;
  end;
end;

procedure TQueueWrapGrowBugTests.Test_PartialWrapped_GrowthLeaksInterfaceRef_System;
var
  Q: System.Generics.Collections.TQueue<IProbe>;
  P0, P1: IProbe;
  Survivor: IProbe;
  Discard: IProbe;
begin
  // Force a PARTIAL wrapped queue: cap=4, tail=3, head=1, count=2
  // i.e. logical items occupy array slots [3] and [0].
  TProbe.LiveCount := 0;
  Q := System.Generics.Collections.TQueue<IProbe>.Create;
  try
    Q.Capacity := 4;

    Q.Enqueue(TProbe.Create(1)); // slot 0
    Q.Enqueue(TProbe.Create(2)); // slot 1
    Q.Enqueue(TProbe.Create(3)); // slot 2
    Q.Enqueue(TProbe.Create(4)); // slot 3

    Discard := Q.Dequeue;  Discard := nil; // remove slot0 item -> head moves to 1
    Discard := Q.Dequeue;  Discard := nil;  // remove slot1 item -> head moves to 2
    Discard := Q.Dequeue;  Discard := nil;  // remove slot2 item -> head moves to 3
    // Now Count=1, tail=3 (only slot3 item 'T0' remains, at array index 3)

    P0 := TProbe.Create(100);
    Q.Enqueue(P0); // wraps: goes to slot 0 -> tail=3, head=1, Count=2

    Assert.AreEqual(2, TProbe.LiveCount,
      'Sanity check before growth: exactly 2 live probes should exist');

    // Trigger growth while PARTIAL wrapped (tail=3 > head=1)
    Q.Capacity := 8;

    // The originally-remaining item at old slot 3 ('T0'-equivalent, tag=4)
    // should still be dequeue-able and its ref should still be valid.
    Survivor := Q.Dequeue;
    Assert.IsNotNull(Survivor,
      'Defect B: FillChar of new slots overlapped the just-moved tail ' +
      'segment and nilled the live interface reference');
    Assert.AreEqual(4, Survivor.Tag);

    Assert.AreEqual(P0.Tag, Q.Dequeue.Tag);
  finally
    Q.Free;
    P0 := nil;
    Survivor := nil;
  end;
end;

procedure TQueueWrapGrowBugTests.Test_InterleavedEnqueueDequeue_ThenBurstGrowth_PreservesAllItems_Rapid;
var
  Q: Rapid.Generics.TQueue<Integer>;
  i, Expected, Got: Integer;
  Produced, Consumed: TList<Integer>;
begin
  // Single-threaded reproduction of the production pattern:
  // interleave enqueue/dequeue at small capacity to force repeated wraps,
  // then flood past capacity to force growth mid-wrap.
  Q := Rapid.Generics.TQueue<Integer>.Create;
  Produced := TList<Integer>.Create;
  Consumed := TList<Integer>.Create;
  try
    Q.Capacity := 4;
    Expected := 0;

    // Steady interleave: enqueue 2, dequeue 1, repeatedly -> guarantees wrap
    for i := 1 to 20 do
    begin
      Q.Enqueue(i);
      Produced.Add(i);
      Q.Enqueue(i + 1000);
      Produced.Add(i + 1000);
      Consumed.Add(Q.Dequeue);
    end;

    // Burst: flood well past current capacity to force one or more
    // growths while the ring is in whatever wrap state it's in.
    for i := 1 to 50 do
    begin
      Q.Enqueue(i + 2000);
      Produced.Add(i + 2000);
    end;

    while Q.Count > 0 do
      Consumed.Add(Q.Dequeue);

    Assert.AreEqual(Produced.Count, Consumed.Count,
      'Item count mismatch after wrap+growth: items were lost or duplicated');

    Produced.Sort;
    Consumed.Sort;
    for i := 0 to Produced.Count - 1 do
      Assert.AreEqual(Produced[i], Consumed[i],
        Format('Mismatch at position %d: expected %d, got %d ' +
          '(ring buffer corruption on wrap+growth)',
          [i, Produced[i], Consumed[i]]));
  finally
    Q.Free;
    Produced.Free;
    Consumed.Free;
  end;
end;

procedure TQueueWrapGrowBugTests.Test_InterleavedEnqueueDequeue_ThenBurstGrowth_PreservesAllItems_System;
var
  Q: System.Generics.Collections.TQueue<Integer>;
  i, Expected, Got: Integer;
  Produced, Consumed: TList<Integer>;
begin
  // Single-threaded reproduction of the production pattern:
  // interleave enqueue/dequeue at small capacity to force repeated wraps,
  // then flood past capacity to force growth mid-wrap.
  Q := System.Generics.Collections.TQueue<Integer>.Create;
  Produced := TList<Integer>.Create;
  Consumed := TList<Integer>.Create;
  try
    Q.Capacity := 4;
    Expected := 0;

    // Steady interleave: enqueue 2, dequeue 1, repeatedly -> guarantees wrap
    for i := 1 to 20 do
    begin
      Q.Enqueue(i);
      Produced.Add(i);
      Q.Enqueue(i + 1000);
      Produced.Add(i + 1000);
      Consumed.Add(Q.Dequeue);
    end;

    // Burst: flood well past current capacity to force one or more
    // growths while the ring is in whatever wrap state it's in.
    for i := 1 to 50 do
    begin
      Q.Enqueue(i + 2000);
      Produced.Add(i + 2000);
    end;

    while Q.Count > 0 do
      Consumed.Add(Q.Dequeue);

    Assert.AreEqual(Produced.Count, Consumed.Count,
      'Item count mismatch after wrap+growth: items were lost or duplicated');

    Produced.Sort;
    Consumed.Sort;
    for i := 0 to Produced.Count - 1 do
      Assert.AreEqual(Produced[i], Consumed[i],
        Format('Mismatch at position %d: expected %d, got %d ' +
          '(ring buffer corruption on wrap+growth)',
          [i, Produced[i], Consumed[i]]));
  finally
    Q.Free;
    Produced.Free;
    Consumed.Free;
  end;
end;

{ ============ Rapid.Generics versions ============ }

procedure TQueueWrapGrowExtraTests_Rapid.Test_ContiguousWrapped_GrowthCompactsCorrectly;
var
  Q: Rapid.Generics.TQueue<Integer>;
  Actual: TArray<Integer>;
  i: Integer;
begin
  // cap=4, fill A,B,C,D, dequeue 1 (A) -> tail=1, head=4 (contiguous, wrapped-branch
  // eligible since FTail<FHead), items B,C,D live in [1..3].
  Q := Rapid.Generics.TQueue<Integer>.Create;
  try
    Q.Capacity := 4;
    Q.Enqueue(1); // A
    Q.Enqueue(2); // B
    Q.Enqueue(3); // C
    Q.Enqueue(4); // D
    Q.Dequeue;    // remove A -> tail=1, head=4

    Q.Capacity := 8; // triggers compaction: Move(FItems[1],FItems[0],3), tail:=0

    SetLength(Actual, Q.Count);
    for i := 0 to Q.Count - 1 do
      Actual[i] := Q.Dequeue;

    Assert.AreEqual<TArray<Integer>>([2, 3, 4], Actual,
      'Contiguous (non-full) wrapped-eligible growth failed to compact correctly');
  finally
    Q.Free;
  end;
end;

procedure TQueueWrapGrowExtraTests_Rapid.Test_EmptyQueue_GrowthAfterFullDrain;
var
  Q: Rapid.Generics.TQueue<Integer>;
begin
  // Force FTail/FHead to a non-zero wrapped position, then fully drain,
  // then grow. FCount=0 branch should reset FTail/FHead to 0 regardless
  // of their pre-drain values.
  Q := Rapid.Generics.TQueue<Integer>.Create;
  try
    Q.Capacity := 4;
    Q.Enqueue(1);
    Q.Enqueue(2);
    Q.Enqueue(3);
    Q.Dequeue;
    Q.Dequeue;
    Q.Dequeue; // now empty, FTail=FHead=3 (or wherever it landed)

    Q.Capacity := 8; // FCount=0 branch

    Q.Enqueue(100);
    Q.Enqueue(200);

    Assert.AreEqual(100, Q.Dequeue,
      'Growth after full drain did not reset ring position correctly');
    Assert.AreEqual(200, Q.Dequeue);
  finally
    Q.Free;
  end;
end;

procedure TQueueWrapGrowExtraTests_Rapid.Test_WrappedQueue_ShrinkCapacity;
var
  Q: Rapid.Generics.TQueue<Integer>;
  Actual: TArray<Integer>;
  i: Integer;
begin
  // cap=8, get into a wrapped state (FTail > FHead), then shrink capacity
  // down toward Count. Exercises the Dif < 0 branch while wrapped, where
  // NewTail = FTail + Dif could go negative or otherwise miscompute.
  Q := Rapid.Generics.TQueue<Integer>.Create;
  try
    Q.Capacity := 8;
    for i := 1 to 6 do
      Q.Enqueue(i);        // fill 6 of 8
    for i := 1 to 4 do
      Q.Dequeue;           // drain 4 -> head moves to 4
    Q.Enqueue(7);           // wraps: tail area starts filling from 0
    Q.Enqueue(8);
    Q.Enqueue(9);
    Q.Enqueue(10);          // now FTail > FHead (wrapped), Count=6

    Q.Capacity := 6;        // shrink to exactly Count -> Dif = -2, wrapped

    SetLength(Actual, Q.Count);
    for i := 0 to Q.Count - 1 do
      Actual[i] := Q.Dequeue;

    Assert.AreEqual<TArray<Integer>>([5, 6, 7, 8, 9, 10], Actual,
      'Shrinking a wrapped queue corrupted order or lost items ' +
      '(check NewTail computation for negative values in Dif<0 branch)');
  finally
    Q.Free;
  end;
end;

procedure TQueueWrapGrowExtraTests_Rapid.Test_RepeatedGrowthCycles_MaintainsFIFOOrder;
var
  Q: Rapid.Generics.TQueue<Integer>;
  Produced, Consumed: TList<Integer>;
  i: Integer;
begin
  // Multiple consecutive grow operations, each triggered while wrapped,
  // to check for cumulative corruption across repeated SetCapacity calls
  // (as opposed to the single-grow scenarios tested elsewhere).
  Q := Rapid.Generics.TQueue<Integer>.Create;
  Produced := TList<Integer>.Create;
  Consumed := TList<Integer>.Create;
  try
    Q.Capacity := 2;
    for i := 1 to 100 do
    begin
      Q.Enqueue(i);
      Produced.Add(i);
      if (i mod 3) = 0 then
      begin
        Consumed.Add(Q.Dequeue);
        Q.Enqueue(i + 10000);
        Produced.Add(i + 10000);
      end;
    end;
    while Q.Count > 0 do
      Consumed.Add(Q.Dequeue);

    Assert.AreEqual(Produced.Count, Consumed.Count,
      'Item count mismatch after repeated grow cycles');
    for i := 0 to Produced.Count - 1 do
      Assert.AreEqual(Produced[i], Consumed[i],
        Format('FIFO order violated at position %d after repeated growth ' +
          '(expected %d, got %d)', [i, Produced[i], Consumed[i]]));
  finally
    Q.Free;
    Produced.Free;
    Consumed.Free;
  end;
end;

procedure TQueueWrapGrowExtraTests_Rapid.Test_GrowWhileFull_NotWrapped;
var
  Q: Rapid.Generics.TQueue<Integer>;
  Actual: TArray<Integer>;
  i: Integer;
begin
  // Full but contiguous: FTail=FHead=0, filled from a fresh queue with no
  // prior dequeues. Distinguishes "full+wrapped" (Defect A's case, tail=head<>0)
  // from "full+contiguous" (tail=head=0), which should NOT hit the wrapped
  // branch logic at all.
  Q := Rapid.Generics.TQueue<Integer>.Create;
  try
    Q.Capacity := 4;
    Q.Enqueue(1);
    Q.Enqueue(2);
    Q.Enqueue(3);
    Q.Enqueue(4); // full, tail=head=0

    Q.Capacity := 8;

    SetLength(Actual, Q.Count);
    for i := 0 to Q.Count - 1 do
      Actual[i] := Q.Dequeue;

    Assert.AreEqual<TArray<Integer>>([1, 2, 3, 4], Actual,
      'Full-but-contiguous growth (tail=head=0) was corrupted');
  finally
    Q.Free;
  end;
end;

{ ============ System.Generics.Collections control versions ============ }

procedure TQueueWrapGrowExtraTests_System.Test_ContiguousWrapped_GrowthCompactsCorrectly_System;
var
  Q: System.Generics.Collections.TQueue<Integer>;
  Actual: TArray<Integer>;
  i: Integer;
begin
  Q := System.Generics.Collections.TQueue<Integer>.Create;
  try
    Q.Capacity := 4;
    Q.Enqueue(1);
    Q.Enqueue(2);
    Q.Enqueue(3);
    Q.Enqueue(4);
    Q.Dequeue;

    Q.Capacity := 8;

    SetLength(Actual, Q.Count);
    for i := 0 to Q.Count - 1 do
      Actual[i] := Q.Dequeue;

    Assert.AreEqual<TArray<Integer>>([2, 3, 4], Actual,
      'Control (RTL) failed contiguous-wrapped compaction test');
  finally
    Q.Free;
  end;
end;

procedure TQueueWrapGrowExtraTests_System.Test_EmptyQueue_GrowthAfterFullDrain_System;
var
  Q: System.Generics.Collections.TQueue<Integer>;
begin
  Q := System.Generics.Collections.TQueue<Integer>.Create;
  try
    Q.Capacity := 4;
    Q.Enqueue(1);
    Q.Enqueue(2);
    Q.Enqueue(3);
    Q.Dequeue;
    Q.Dequeue;
    Q.Dequeue;

    Q.Capacity := 8;

    Q.Enqueue(100);
    Q.Enqueue(200);

    Assert.AreEqual(100, Q.Dequeue,
      'Control (RTL) failed empty-drain-then-grow test');
    Assert.AreEqual(200, Q.Dequeue);
  finally
    Q.Free;
  end;
end;

procedure TQueueWrapGrowExtraTests_System.Test_WrappedQueue_ShrinkCapacity_System;
var
  Q: System.Generics.Collections.TQueue<Integer>;
  Actual: TArray<Integer>;
  i: Integer;
begin
  Q := System.Generics.Collections.TQueue<Integer>.Create;
  try
    Q.Capacity := 8;
    for i := 1 to 6 do
      Q.Enqueue(i);
    for i := 1 to 4 do
      Q.Dequeue;
    Q.Enqueue(7);
    Q.Enqueue(8);
    Q.Enqueue(9);
    Q.Enqueue(10);

    Q.Capacity := 6;

    SetLength(Actual, Q.Count);
    for i := 0 to Q.Count - 1 do
      Actual[i] := Q.Dequeue;

    Assert.AreEqual<TArray<Integer>>([5, 6, 7, 8, 9, 10], Actual,
      'Control (RTL) failed wrapped-shrink test');
  finally
    Q.Free;
  end;
end;

procedure TQueueWrapGrowExtraTests_System.Test_RepeatedGrowthCycles_MaintainsFIFOOrder_System;
var
  Q: System.Generics.Collections.TQueue<Integer>;
  Produced, Consumed: TList<Integer>;
  i: Integer;
begin
  Q := System.Generics.Collections.TQueue<Integer>.Create;
  Produced := TList<Integer>.Create;
  Consumed := TList<Integer>.Create;
  try
    Q.Capacity := 2;
    for i := 1 to 100 do
    begin
      Q.Enqueue(i);
      Produced.Add(i);
      if (i mod 3) = 0 then
      begin
        Consumed.Add(Q.Dequeue);
        Q.Enqueue(i + 10000);
        Produced.Add(i + 10000);
      end;
    end;
    while Q.Count > 0 do
      Consumed.Add(Q.Dequeue);

    Assert.AreEqual(Produced.Count, Consumed.Count,
      'Control (RTL) item count mismatch after repeated grow cycles');
    for i := 0 to Produced.Count - 1 do
      Assert.AreEqual(Produced[i], Consumed[i],
        Format('Control (RTL) FIFO order violated at position %d ' +
          '(expected %d, got %d)', [i, Produced[i], Consumed[i]]));
  finally
    Q.Free;
    Produced.Free;
    Consumed.Free;
  end;
end;

procedure TQueueWrapGrowExtraTests_System.Test_GrowWhileFull_NotWrapped_System;
var
  Q: System.Generics.Collections.TQueue<Integer>;
  Actual: TArray<Integer>;
  i: Integer;
begin
  Q := System.Generics.Collections.TQueue<Integer>.Create;
  try
    Q.Capacity := 4;
    Q.Enqueue(1);
    Q.Enqueue(2);
    Q.Enqueue(3);
    Q.Enqueue(4);

    Q.Capacity := 8;

    SetLength(Actual, Q.Count);
    for i := 0 to Q.Count - 1 do
      Actual[i] := Q.Dequeue;

    Assert.AreEqual<TArray<Integer>>([1, 2, 3, 4], Actual,
      'Control (RTL) failed full-but-contiguous growth test');
  finally
    Q.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TQueueWrapGrowBugTests);
  TDUnitX.RegisterTestFixture(TQueueWrapGrowExtraTests_Rapid);
  TDUnitX.RegisterTestFixture(TQueueWrapGrowExtraTests_System);

end.

unit uDictionaries;

interface
uses
  Winapi.Windows, System.SysUtils, Generics.Defaults, Generics.Collections,
  Rapid.Generics, System.Diagnostics;


const
  ITEMS_COUNT = 1024 * (1024 div 4 * 3);
  ITERATIONS_COUNT = 10;

type
  TRunner<T> = class
  private
    sw: TStopwatch;
    procedure StartTest(const aClassName, aTestName: string; aStart: Boolean);
    procedure EndTest;
  public type
    TItems = array[0..ITEMS_COUNT - 1] of T;
    TRandomFunc = reference to function: T;

    TTest = class
      constructor Create(const Items: TItems; const Capacity: Integer); virtual; abstract;
      function ExecuteItems(const Items: TItems): Integer; virtual; abstract;
      function ExecuteTryGetValue(const Items: TItems): Integer; virtual; abstract;
      procedure ExecuteRemove(const Items: TItems); virtual; abstract;
    end;
    TTestClass = class of TTest;
  public
    Items: TItems;
    constructor Create(const RandomFunc: TRandomFunc);

    procedure Run(const TestClass: TTestClass);
    procedure RunEach;
  public type
    SystemSystem = class(TTest)
      Dictionary: Generics.Collections.TDictionary<T,Integer>;

      constructor Create(const Items: TItems; const Capacity: Integer); override;
      destructor Destroy; override;
      function ExecuteItems(const Items: TItems): Integer; override;
      function ExecuteTryGetValue(const Items: TItems): Integer; override;
      procedure ExecuteRemove(const Items: TItems); override;
    end;

    SystemRapid = class(SystemSystem)
      constructor Create(const Items: TItems; const Capacity: Integer); override;
    end;

    RapidRapid = class(TTest)
      Dictionary: Rapid.Generics.TDictionary<T,Integer>;

      constructor Create(const Items: TItems; const Capacity: Integer); override;
      destructor Destroy; override;
      function ExecuteItems(const Items: TItems): Integer; override;
      function ExecuteTryGetValue(const Items: TItems): Integer; override;
      procedure ExecuteRemove(const Items: TItems); override;
    end;

    RapidDictionary = class(TTest)
      Dictionary: TRapidDictionary<T,Integer>;

      constructor Create(const Items: TItems; const Capacity: Integer); override;
      destructor Destroy; override;
      function ExecuteItems(const Items: TItems): Integer; override;
      function ExecuteTryGetValue(const Items: TItems): Integer; override;
      procedure ExecuteRemove(const Items: TItems); override;
    end;
  end;


procedure Run;

implementation

procedure Run;
begin
  with TRunner<string>.Create(
    function: string
    var
      Len, i: Integer;
    begin
      Len := 5 + Random(8);
      SetLength(Result, Len);

      for i := 1 to Len do
        Result[i] := Char(Ord('A') + Random(Ord('Z') - Ord('A') + 1));
    end) do
  try
    RunEach;
  finally
    Free;
  end;

  with TRunner<Single>.Create(
    function: Single
    begin
      Result := Random * ITEMS_COUNT;
    end) do
  try
    RunEach;
  finally
    Free;
  end;

  with TRunner<Integer>.Create(
    function: Integer
    begin
      Result := Random(ITEMS_COUNT);
    end) do
  try
    RunEach;
  finally
    Free;
  end;

  with TRunner<Double>.Create(
    function: Double
    begin
      Result := Random(ITEMS_COUNT);
    end) do
  try
    RunEach;
  finally
    Free;
  end;
end;


{ TRunner<T>.SystemSystem }

constructor TRunner<T>.SystemSystem.Create(const Items: TItems; const Capacity: Integer);
var
  i: Integer;
begin
  Dictionary := Generics.Collections.TDictionary<T,Integer>.Create(Capacity);
  for i := Low(TItems) to High(TItems) do
    Dictionary.AddOrSetValue(Items[i], i);
end;

destructor TRunner<T>.SystemSystem.Destroy;
begin
  Dictionary.Free;
  inherited;
end;

function TRunner<T>.SystemSystem.ExecuteItems(const Items: TItems): Integer;
var
  i: Integer;
begin
  for i := Low(TItems) to High(TItems) do
    Result := Dictionary.Items[Items[i]];
end;

function TRunner<T>.SystemSystem.ExecuteTryGetValue(const Items: TItems): Integer;
var
  Value,
  i: Integer;
begin
  for i := Low(TItems) to High(TItems) do
  begin
    Dictionary.TryGetValue(Items[i], Value);
    Result := Value;
  end;
end;

procedure TRunner<T>.SystemSystem.ExecuteRemove(const Items: TItems);
var
  i: Integer;
begin
  for i := Low(TItems) to High(TItems) do
  begin
    Dictionary.Remove(Items[i]);
  end;
end;

{ TRunner<T>.SystemRapid }

constructor TRunner<T>.SystemRapid.Create(const Items: TItems; const Capacity: Integer);
var
  i: Integer;
  Comparer: Generics.Defaults.IEqualityComparer<T>;
begin
  IInterface(Comparer) := Rapid.Generics.TEqualityComparer<T>.Default;
  Dictionary := Generics.Collections.TDictionary<T,Integer>.Create(Capacity, Comparer);

  for i := Low(TItems) to High(TItems) do
    Dictionary.AddOrSetValue(Items[i], i);
end;

{ TRunner<T>.RapidRapid }

constructor TRunner<T>.RapidRapid.Create(const Items: TItems; const Capacity: Integer);
var
  i: Integer;
begin
  Dictionary := Rapid.Generics.TDictionary<T,Integer>.Create(Capacity);
  for i := Low(TItems) to High(TItems) do
    Dictionary.AddOrSetValue(Items[i], i);
end;

destructor TRunner<T>.RapidRapid.Destroy;
begin
  Dictionary.Free;
  inherited;
end;

function TRunner<T>.RapidRapid.ExecuteItems(const Items: TItems): Integer;
var
  i: Integer;
begin
  for i := Low(TItems) to High(TItems) do
    Result := Dictionary.Items[Items[i]];
end;

function TRunner<T>.RapidRapid.ExecuteTryGetValue(const Items: TItems): Integer;
var
  Value,
  i: Integer;
begin
  for i := Low(TItems) to High(TItems) do
  begin
    Dictionary.TryGetValue(Items[i], Value);
    Result := Value;
  end;
end;

procedure TRunner<T>.RapidRapid.ExecuteRemove(const Items: TItems);
var
  i: Integer;
begin
  for i := Low(TItems) to High(TItems) do
  begin
    Dictionary.Remove(Items[i]);
  end;
end;

{ TRunner<T>.RapidDictionary }

constructor TRunner<T>.RapidDictionary.Create(const Items: TItems; const Capacity: Integer);
var
  i: Integer;
begin
  Dictionary := TRapidDictionary<T,Integer>.Create(Capacity);
  for i := Low(TItems) to High(TItems) do
    Dictionary.AddOrSetValue(Items[i], i);
end;

destructor TRunner<T>.RapidDictionary.Destroy;
begin
  Dictionary.Free;
  inherited;
end;

function TRunner<T>.RapidDictionary.ExecuteItems(const Items: TItems): Integer;
var
  i: Integer;
begin
  for i := Low(TItems) to High(TItems) do
    Result := Dictionary.Items[Items[i]];
end;

function TRunner<T>.RapidDictionary.ExecuteTryGetValue(const Items: TItems): Integer;
var
  Value,
  i: Integer;
begin
  for i := Low(TItems) to High(TItems) do
  begin
    Dictionary.TryGetValue(Items[i], Value);
    Result := Value;
  end;
end;

procedure TRunner<T>.RapidDictionary.ExecuteRemove(const Items: TItems);
var
  i: Integer;
begin
  for i := Low(TItems) to High(TItems) do
  begin
    Dictionary.Remove(Items[i]);
  end;
end;

{ TRunner<T> }

constructor TRunner<T>.Create(const RandomFunc: TRandomFunc);
var
  i: Integer;
begin
  for i := Low(TItems) to High(TItems) do
    Items[i] := RandomFunc;
end;

procedure TRunner<T>.StartTest(const aClassName, aTestName: string; aStart: Boolean);
begin
  Write(aClassName, ' ', aTestName, '... ');
  if aStart then
    sw := TStopwatch.StartNew
  else
    sw := TStopwatch.Create;
end;

procedure TRunner<T>.EndTest;
begin
  sw.Stop;
  Writeln(sw.ElapsedMilliseconds, 'ms');
end;

procedure TRunner<T>.Run(const TestClass: TTestClass);
var
  i: Integer;
  Instance: TTest;
begin
    StartTest(TestClass.ClassName, 'Add', False);
    for i := 1 to ITERATIONS_COUNT do
    begin
      sw.Start;
      Instance := TestClass.Create(Items, 0);
      sw.Stop;
      Instance.Free;  // skip free time
    end;
    EndTest;

    StartTest(TestClass.ClassName, 'Add+Capacity', False);
    for i := 1 to ITERATIONS_COUNT do
    begin
      sw.Start;
      Instance := TestClass.Create(Items, ITEMS_COUNT);
      sw.Stop;
      Instance.Free;  // skip free time
    end;
    EndTest;

    StartTest(TestClass.ClassName, 'Items', False);
    Instance := TestClass.Create(Items, ITEMS_COUNT);
    sw.Start;
    for i := 1 to ITERATIONS_COUNT do
      Instance.ExecuteItems(Items);
    EndTest;

    StartTest(TestClass.ClassName, 'TryGetValue', True);
    for i := 1 to ITERATIONS_COUNT do
      Instance.ExecuteTryGetValue(Items);
    EndTest;

    StartTest(TestClass.ClassName, 'Remove', True);
    for i := 1 to ITERATIONS_COUNT do
      Instance.ExecuteRemove(Items);
    EndTest;

    Instance.Free;
end;

procedure TRunner<T>.RunEach;
begin
  Writeln;
  Writeln(PShortString(NativeUInt(TypeInfo(T)) + 1)^);

  Run(SystemSystem);
  Run(SystemRapid);
  Run(RapidRapid);
  Run(RapidDictionary);
end;

end.

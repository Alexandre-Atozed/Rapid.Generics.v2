unit uHashSet;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  Rapid.Generics,
  System.Generics.Collections,
  System.Diagnostics;

const
  ITEMS_COUNT = 1024 * (1024 div 4 * 3);
  ITERATIONS_COUNT = 10;

type
  TItems<T> = array[0..ITEMS_COUNT - 1] of T;
  TRandomFunc<T> = reference to function: T;

  { --- Enumerable wrappers for System.Generics.Collections --- }

  TSysArrayEnumerator<T> = class(System.Generics.Collections.TEnumerator<T>)
  private
    FValues: TArray<T>;
    FIndex: Integer;
    FCurrent: T;
  protected
    function DoGetCurrent: T; override;
    function DoMoveNext: Boolean; override;
  public
    constructor Create(const AValues: TArray<T>);
  end;

  TSysArrayEnumerable<T> = class(System.Generics.Collections.TEnumerable<T>)
  private
    FValues: TArray<T>;
  protected
    function DoGetEnumerator: System.Generics.Collections.TEnumerator<T>; override;
  public
    constructor Create(const AValues: TArray<T>);
  end;

  { --- Enumerable wrappers for Rapid.Generics --- }

  TRapidArrayEnumerator<T> = class(Rapid.Generics.TEnumerator<T>)
  private
    FValues: TArray<T>;
    FIndex: Integer;
    FCurrent: T;
  protected
    function DoGetCurrent: T; override;
    function DoMoveNext: Boolean; override;
  public
    constructor Create(const AValues: TArray<T>);
  end;

  TRapidArrayEnumerable<T> = class(Rapid.Generics.TEnumerable<T>)
  private
    FValues: TArray<T>;
  protected
    function DoGetEnumerator: Rapid.Generics.TEnumerator<T>; override;
  public
    constructor Create(const AValues: TArray<T>);
  end;

  { THashSetRunner<T> }

  THashSetRunner<T> = class
  private
    sw: TStopwatch;
    Items: TItems<T>;
    OtherItems: TItems<T>;
    procedure StartTest(const aLabel, aTestName: string; aStart: Boolean);
    procedure EndTest;

    procedure RunRapid;
    procedure RunSystem;
  public
    constructor Create(const RandomFunc: TRandomFunc<T>);
    procedure Run;
  end;

procedure Run;

implementation

{ TSysArrayEnumerator<T> }

constructor TSysArrayEnumerator<T>.Create(const AValues: TArray<T>);
begin
  inherited Create;
  FValues := AValues;
  FIndex := -1;
end;

function TSysArrayEnumerator<T>.DoGetCurrent: T;
begin
  Result := FCurrent;
end;

function TSysArrayEnumerator<T>.DoMoveNext: Boolean;
var
  LIndex: Integer;
begin
  LIndex := FIndex + 1;
  Result := LIndex < Length(FValues);
  if Result then
  begin
    FIndex := LIndex;
    FCurrent := FValues[LIndex];
  end;
end;

{ TSysArrayEnumerable<T> }

constructor TSysArrayEnumerable<T>.Create(const AValues: TArray<T>);
begin
  inherited Create;
  FValues := AValues;
end;

function TSysArrayEnumerable<T>.DoGetEnumerator: System.Generics.Collections.TEnumerator<T>;
begin
  Result := TSysArrayEnumerator<T>.Create(FValues);
end;

{ TRapidArrayEnumerator<T> }

constructor TRapidArrayEnumerator<T>.Create(const AValues: TArray<T>);
begin
  inherited Create;
  FValues := AValues;
  FIndex := -1;
end;

function TRapidArrayEnumerator<T>.DoGetCurrent: T;
begin
  Result := FCurrent;
end;

function TRapidArrayEnumerator<T>.DoMoveNext: Boolean;
var
  LIndex: Integer;
begin
  LIndex := FIndex + 1;
  Result := LIndex < Length(FValues);
  if Result then
  begin
    FIndex := LIndex;
    FCurrent := FValues[LIndex];
  end;
end;

{ TRapidArrayEnumerable<T> }

constructor TRapidArrayEnumerable<T>.Create(const AValues: TArray<T>);
begin
  inherited Create;
  FValues := AValues;
end;

function TRapidArrayEnumerable<T>.DoGetEnumerator: Rapid.Generics.TEnumerator<T>;
begin
  Result := TRapidArrayEnumerator<T>.Create(FValues);
end;

{ THashSetRunner<T> }

constructor THashSetRunner<T>.Create(const RandomFunc: TRandomFunc<T>);
var
  I: Integer;
begin
  for I := Low(Items) to High(Items) do
  begin
    Items[I] := RandomFunc;
    if (I and 1) = 0 then
      OtherItems[I] := Items[I]
    else
      OtherItems[I] := RandomFunc;
  end;
end;

procedure THashSetRunner<T>.StartTest(const aLabel, aTestName: string; aStart: Boolean);
begin
  Write(aLabel, ' ', aTestName, '... ');
  if aStart then
    sw := TStopwatch.StartNew
  else
    sw := TStopwatch.Create;
end;

procedure THashSetRunner<T>.EndTest;
begin
  sw.Stop;
  Writeln(sw.ElapsedMilliseconds, 'ms');
end;

{ ---- Rapid.Generics.THashSet<T> ---- }

{$HINTS OFF}

procedure THashSetRunner<T>.RunRapid;
var
  I, N: Integer;
  B: Boolean;
  SetInstance, Temp: Rapid.Generics.THashSet<T>;
  ItemsEnum, OtherEnum: TRapidArrayEnumerable<T>;
  ItemsArray, OtherArray: TArray<T>;
const
  LBL = 'Rapid';
begin
  StartTest(LBL, 'Add', False);
  for I := 1 to ITERATIONS_COUNT do
  begin
    SetInstance := Rapid.Generics.THashSet<T>.Create(0);
    sw.Start;
    for N := Low(Items) to High(Items) do
      SetInstance.Add(Items[N]);
    sw.Stop;
    SetInstance.Free;
  end;
  EndTest;

  StartTest(LBL, 'Add+Capacity', False);
  for I := 1 to ITERATIONS_COUNT do
  begin
    SetInstance := Rapid.Generics.THashSet<T>.Create(ITEMS_COUNT);
    sw.Start;
    for N := Low(Items) to High(Items) do
      SetInstance.Add(Items[N]);
    sw.Stop;
    SetInstance.Free;
  end;
  EndTest;

  SetLength(ItemsArray, Length(Items));
  SetLength(OtherArray, Length(OtherItems));
  for I := Low(Items) to High(Items) do
  begin
    ItemsArray[I] := Items[I];
    OtherArray[I] := OtherItems[I];
  end;
  ItemsEnum := TRapidArrayEnumerable<T>.Create(ItemsArray);
  OtherEnum := TRapidArrayEnumerable<T>.Create(OtherArray);

  SetInstance := Rapid.Generics.THashSet<T>.Create(ITEMS_COUNT);
  for I := Low(Items) to High(Items) do
    SetInstance.Add(Items[I]);
  try
    StartTest(LBL, 'Contains', True);
    for I := 1 to ITERATIONS_COUNT do
      for N := Low(Items) to High(Items) do
        SetInstance.Contains(Items[N]);
    EndTest;

    StartTest(LBL, 'Clear', False);
    for I := 1 to ITERATIONS_COUNT do
    begin
      SetInstance.Free;
      SetInstance := Rapid.Generics.THashSet<T>.Create(ITEMS_COUNT);
      for N := Low(Items) to High(Items) do
        SetInstance.Add(Items[N]);
      sw.Start;
      SetInstance.Clear;
      sw.Stop;
    end;
    EndTest;

    StartTest(LBL, 'Remove', False);
    for I := 1 to ITERATIONS_COUNT do
    begin
      Temp := Rapid.Generics.THashSet<T>.Create(ITEMS_COUNT);
      for N := Low(Items) to High(Items) do
        Temp.Add(Items[N]);
      sw.Start;
      for N := Low(Items) to High(Items) do
        Temp.Remove(Items[N]);
      sw.Stop;
      Temp.Free;
    end;
    EndTest;

    StartTest(LBL, 'UnionWith', False);
    for I := 1 to ITERATIONS_COUNT do
    begin
      Temp := Rapid.Generics.THashSet<T>.Create(ITEMS_COUNT);
      Temp.AddRange(Rapid.Generics.TEnumerable<T>(ItemsEnum));
      sw.Start;
      Temp.UnionWith(OtherEnum);
      sw.Stop;
      Temp.Free;
    end;
    EndTest;

    StartTest(LBL, 'IntersectWith', False);
    for I := 1 to ITERATIONS_COUNT do
    begin
      Temp := Rapid.Generics.THashSet<T>.Create(ITEMS_COUNT);
      Temp.AddRange(Rapid.Generics.TEnumerable<T>(ItemsEnum));
      sw.Start;
      Temp.IntersectWith(OtherEnum);
      sw.Stop;
      Temp.Free;
    end;
    EndTest;

    StartTest(LBL, 'ExceptWith', False);
    for I := 1 to ITERATIONS_COUNT do
    begin
      Temp := Rapid.Generics.THashSet<T>.Create(ITEMS_COUNT);
      Temp.AddRange(Rapid.Generics.TEnumerable<T>(ItemsEnum));
      sw.Start;
      Temp.ExceptWith(OtherEnum);
      sw.Stop;
      Temp.Free;
    end;
    EndTest;

    StartTest(LBL, 'SymmetricExceptWith', False);
    for I := 1 to ITERATIONS_COUNT do
    begin
      Temp := Rapid.Generics.THashSet<T>.Create(ITEMS_COUNT);
      Temp.AddRange(Rapid.Generics.TEnumerable<T>(ItemsEnum));
      sw.Start;
      Temp.SymmetricExceptWith(OtherEnum);
      sw.Stop;
      Temp.Free;
    end;
    EndTest;

    StartTest(LBL, 'IsSubsetOf', True);
    for I := 1 to ITERATIONS_COUNT do
      B := SetInstance.IsSubsetOf(OtherEnum);
    EndTest;

    StartTest(LBL, 'IsSupersetOf', True);
    for I := 1 to ITERATIONS_COUNT do
      B := SetInstance.IsSupersetOf(OtherEnum);
    EndTest;

    StartTest(LBL, 'Overlaps', True);
    for I := 1 to ITERATIONS_COUNT do
      B := SetInstance.Overlaps(OtherEnum);
    EndTest;
  finally
    SetInstance.Free;
    ItemsEnum.Free;
    OtherEnum.Free;
  end;
end;

{ ---- System.Generics.Collections.THashSet<T> ---- }

procedure THashSetRunner<T>.RunSystem;
var
  I, N: Integer;
  B: Boolean;
  SetInstance, Temp: System.Generics.Collections.THashSet<T>;
  ItemsEnum, OtherEnum: TSysArrayEnumerable<T>;
  ItemsArray, OtherArray: TArray<T>;
const
  LBL = 'System';
begin
  StartTest(LBL, 'Add', False);
  for I := 1 to ITERATIONS_COUNT do
  begin
    SetInstance := System.Generics.Collections.THashSet<T>.Create(0);
    sw.Start;
    for N := Low(Items) to High(Items) do
      SetInstance.Add(Items[N]);
    sw.Stop;
    SetInstance.Free;
  end;
  EndTest;

  StartTest(LBL, 'Add+Capacity', False);
  for I := 1 to ITERATIONS_COUNT do
  begin
    SetInstance := System.Generics.Collections.THashSet<T>.Create(ITEMS_COUNT);
    sw.Start;
    for N := Low(Items) to High(Items) do
      SetInstance.Add(Items[N]);
    sw.Stop;
    SetInstance.Free;
  end;
  EndTest;

  SetLength(ItemsArray, Length(Items));
  SetLength(OtherArray, Length(OtherItems));
  for I := Low(Items) to High(Items) do
  begin
    ItemsArray[I] := Items[I];
    OtherArray[I] := OtherItems[I];
  end;
  ItemsEnum := TSysArrayEnumerable<T>.Create(ItemsArray);
  OtherEnum := TSysArrayEnumerable<T>.Create(OtherArray);

  SetInstance := System.Generics.Collections.THashSet<T>.Create(ITEMS_COUNT);
  for I := Low(Items) to High(Items) do
    SetInstance.Add(Items[I]);
  try
    StartTest(LBL, 'Contains', True);
    for I := 1 to ITERATIONS_COUNT do
      for N := Low(Items) to High(Items) do
        SetInstance.Contains(Items[N]);
    EndTest;

    StartTest(LBL, 'Clear', False);
    for I := 1 to ITERATIONS_COUNT do
    begin
      SetInstance.Free;
      SetInstance := System.Generics.Collections.THashSet<T>.Create(ITEMS_COUNT);
      for N := Low(Items) to High(Items) do
        SetInstance.Add(Items[N]);
      sw.Start;
      SetInstance.Clear;
      sw.Stop;
    end;
    EndTest;

    StartTest(LBL, 'Remove', False);
    for I := 1 to ITERATIONS_COUNT do
    begin
      Temp := System.Generics.Collections.THashSet<T>.Create(ITEMS_COUNT);
      for N := Low(Items) to High(Items) do
        Temp.Add(Items[N]);
      sw.Start;
      for N := Low(Items) to High(Items) do
        Temp.Remove(Items[N]);
      sw.Stop;
      Temp.Free;
    end;
    EndTest;

    StartTest(LBL, 'UnionWith', False);
    for I := 1 to ITERATIONS_COUNT do
    begin
      Temp := System.Generics.Collections.THashSet<T>.Create(ITEMS_COUNT);
      Temp.AddRange(System.Generics.Collections.TEnumerable<T>(ItemsEnum));
      sw.Start;
      Temp.UnionWith(OtherEnum);
      sw.Stop;
      Temp.Free;
    end;
    EndTest;

    StartTest(LBL, 'IntersectWith', False);
    for I := 1 to ITERATIONS_COUNT do
    begin
      Temp := System.Generics.Collections.THashSet<T>.Create(ITEMS_COUNT);
      Temp.AddRange(System.Generics.Collections.TEnumerable<T>(ItemsEnum));
      sw.Start;
      Temp.IntersectWith(OtherEnum);
      sw.Stop;
      Temp.Free;
    end;
    EndTest;

    StartTest(LBL, 'ExceptWith', False);
    for I := 1 to ITERATIONS_COUNT do
    begin
      Temp := System.Generics.Collections.THashSet<T>.Create(ITEMS_COUNT);
      Temp.AddRange(System.Generics.Collections.TEnumerable<T>(ItemsEnum));
      sw.Start;
      Temp.ExceptWith(OtherEnum);
      sw.Stop;
      Temp.Free;
    end;
    EndTest;

    StartTest(LBL, 'SymmetricExceptWith -> Not available in System.Generics.Collections.THashSet', False);
    for I := 1 to ITERATIONS_COUNT do
    begin
      Temp := System.Generics.Collections.THashSet<T>.Create(ITEMS_COUNT);
      Temp.AddRange(System.Generics.Collections.TEnumerable<T>(ItemsEnum));
      sw.Start;
      //Temp.SymmetricExceptWith(OtherEnum);
      sw.Stop;
      Temp.Free;
    end;
    EndTest;

    StartTest(LBL, 'IsSubsetOf', True);
    for I := 1 to ITERATIONS_COUNT do
      B := SetInstance.IsSubsetOf(OtherEnum);
    EndTest;

    StartTest(LBL, 'IsSupersetOf', True);
    for I := 1 to ITERATIONS_COUNT do
      B := SetInstance.IsSupersetOf(OtherEnum);
    EndTest;

    StartTest(LBL, 'Overlaps', True);
    for I := 1 to ITERATIONS_COUNT do
      B := SetInstance.Overlaps(OtherEnum);
    EndTest;
  finally
    SetInstance.Free;
    ItemsEnum.Free;
    OtherEnum.Free;
  end;
end;

procedure THashSetRunner<T>.Run;
begin
  RunRapid;
  Writeln;
  RunSystem;
end;

procedure Run;
begin
  with THashSetRunner<string>.Create(
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
      Writeln;
      Writeln('string');
      Run;
    finally
      Free;
    end;

  with THashSetRunner<Integer>.Create(
    function: Integer
    begin
      Result := Random(ITEMS_COUNT);
    end) do
    try
      Writeln;
      Writeln('Integer');
      Run;
    finally
      Free;
    end;

  with THashSetRunner<Int64>.Create(
    function: Int64
    begin
      Result := Random(ITEMS_COUNT);
    end) do
    try
      Writeln;
      Writeln('Int64');
      Run;
    finally
      Free;
    end;
end;

end.

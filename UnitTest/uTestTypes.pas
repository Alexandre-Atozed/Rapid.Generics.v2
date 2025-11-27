unit uTestTypes;

interface

{$DEFINE TEST_RAPIDGENERICS}

uses
  Classes,
  {$IFDEF TEST_RAPIDGENERICS}
  Rapid.Generics,
  {$ELSE}
  System.Generics.Collections,
  System.Generics.Defaults,
  {$ENDIF}
  SysUtils;

type
  TTestObject = class
  private
    FId: Integer;
    FRefCounter: PInteger;
  public
    constructor Create(AId: Integer); overload;
    constructor Create(AId: Integer; var RefCounter: Integer); overload;
    destructor Destroy; override;
    property ID: Integer read FId;
  end;

  // Test record with strings (managed types)
  TTestRecordString = record
    x: Integer;
    y: string;
  end;

  TTestRecordStringComparer = class(TInterfacedObject, IComparer<TTestRecordString>)
  public
    function Compare(const Left, Right: TTestRecordString): Integer;
  end;

  // Define the interface
  ITestInterface = interface
    ['{DFB870C1-D271-44FA-9C5D-627FC2407B0A}']
    function GetValue: Integer;
    procedure SetValue(AValue: Integer);
    property Value: Integer read GetValue write SetValue;
  end;

  // Implementation class for the interface
  TTestInterfacedObject = class(TInterfacedObject, ITestInterface)
  private
    FValue: Integer;
    function GetValue: Integer;
    procedure SetValue(AValue: Integer);
  public
    constructor Create(AValue: Integer);
    procedure BeforeDestruction; override;
  end;

  TSortOrder = (soAscending, soDescending);

  TArrayBuilder = record
    class function Build<T>(Count: Integer; const Generator: TFunc<T>): TArray<T>; static;

    class function RandomInteger(Count: Integer; MaxValue: Integer = MaxInt): TArray<Integer>; static;
    class function RandomSmallInt(Count: Integer): TArray<SmallInt>; static;
    class function RandomCardinal(Count: Integer): TArray<Cardinal>; static;
    class function RandomInt64(Count: Integer): TArray<Int64>; static;
    class function RandomUInt64(Count: Integer): TArray<UInt64>; static;

    class function RandomSingle(Count: Integer): TArray<Single>; static;
    class function RandomDouble(Count: Integer): TArray<Double>; static;
    class function RandomExtended(Count: Integer): TArray<Extended>; static;
    class function IsArraySorted<T>(const Values: TArray<T>; const Order: TSortOrder; const Comparer: IComparer<T> = nil): Boolean; static;
  end;


implementation

{ TTestObject }

constructor TTestObject.Create(AId: Integer);
begin
  inherited Create;
  FId := AId;
end;

constructor TTestObject.Create(AId: Integer; var RefCounter: Integer);
begin
  Create(AId);
  FRefCounter := @RefCounter;
end;

destructor TTestObject.Destroy;
begin
  if Assigned(FRefCounter) then
    FRefCounter^ := FId;
  inherited;
end;

{ TTestInterfacedObject }

constructor TTestInterfacedObject.Create(AValue: Integer);
begin
  inherited Create;
  FValue := AValue;
end;

procedure TTestInterfacedObject.BeforeDestruction;
begin
  // For debugging
  inherited;
end;

function TTestInterfacedObject.GetValue: Integer;
begin
  Result := FValue;
end;

procedure TTestInterfacedObject.SetValue(AValue: Integer);
begin
  FValue := AValue;
end;

{ TTestRecordComparer }

function TTestRecordStringComparer.Compare(const Left, Right: TTestRecordString): Integer;
begin
  Result := Left.x - Right.x;
  if Result = 0 then
    Result := CompareText(Left.y, Right.y);
end;

{ TArrayBuilder }

class function TArrayBuilder.Build<T>(Count: Integer; const Generator: TFunc<T>): TArray<T>;
var
  I: Integer;
begin
  SetLength(Result, Count);
  for I := 0 to Count - 1 do
    Result[I] := Generator();
end;

class function TArrayBuilder.RandomInteger(Count: Integer; MaxValue: Integer): TArray<Integer>;
begin
  Result := Build<Integer>(
    Count,
    function: Integer
    begin
      Result := Random(MaxValue);
    end
  );
end;

class function TArrayBuilder.RandomSmallInt(Count: Integer): TArray<SmallInt>;
begin
  Result := Build<SmallInt>(
    Count,
    function: SmallInt
    begin
      Result := SmallInt(Random(High(SmallInt) + 1));
    end
  );
end;

class function TArrayBuilder.RandomCardinal(Count: Integer): TArray<Cardinal>;
begin
  Result := Build<Cardinal>(
    Count,
    function: Cardinal
    begin
      Result := Cardinal(Random(MaxInt));  // 31-bit randomness
    end
  );
end;

class function TArrayBuilder.RandomInt64(Count: Integer): TArray<Int64>;
begin
  Result := Build<Int64>(
    Count,
    function: Int64
    begin
      Result := (Int64(Random(MaxInt)) shl 32) or Random(MaxInt);
    end
  );
end;

class function TArrayBuilder.RandomUInt64(Count: Integer): TArray<UInt64>;
begin
  Result := Build<UInt64>(
    Count,
    function: UInt64
    begin
      Result := (UInt64(Random(MaxInt)) shl 32) or Random(MaxInt);
    end
  );
end;

class function TArrayBuilder.RandomSingle(Count: Integer): TArray<Single>;
begin
  Result := Build<Single>(
    Count,
    function: Single
    begin
      Result := Random; // 0.0 .. 1.0
    end
  );
end;

class function TArrayBuilder.RandomDouble(Count: Integer): TArray<Double>;
begin
  Result := Build<Double>(
    Count,
    function: Double
    begin
      Result := Random;
    end
  );
end;

class function TArrayBuilder.RandomExtended(Count: Integer): TArray<Extended>;
begin
  Result := Build<Extended>(
    Count,
    function: Extended
    begin
      Result := Random;
    end
  );
end;

class function TArrayBuilder.IsArraySorted<T>(const Values: TArray<T>; const Order: TSortOrder; const Comparer: IComparer<T> = nil): Boolean;
var
  I: Integer;
  Cmp: IComparer<T>;
  Res: Integer;
begin
  if Length(Values) <= 1 then
    Exit(True);

  if Comparer <> nil then
    Cmp := Comparer
  else
    Cmp := TComparer<T>.Default;

  for I := 0 to High(Values) - 1 do
  begin
    Res := Cmp.Compare(Values[I], Values[I+1]);

    case Order of
      soAscending:
        if Res > 0 then
          Exit(False);

      soDescending:
        if Res < 0 then
          Exit(False);
    end;
  end;

  Result := True;
end;

end.


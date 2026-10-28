unit uInitOrderLate;

interface

uses
  uInitOrderEarly;

function UseDefaultEqualityComparer: Boolean;
function UseDefaultSortAndSearch: Boolean;

implementation

uses
  Rapid.Generics;

type
  // Private record types so that each generic instance is first instantiated here.
  TEqKey = record
    A, B, C: Integer;
  end;

  TSortKey = record
    A, B, C: Integer;
  end;

function UseDefaultEqualityComparer: Boolean;
var
  K: TEqKey;
begin
  K := Default(TEqKey);
  Result := TEqualityComparer<TEqKey>.Default.Equals(K, K);
end;

function UseDefaultSortAndSearch: Boolean;
var
  Arr: array[0..2] of TSortKey;
  Item: TSortKey;
  Idx: Integer;
begin
  Arr[0] := Default(TSortKey);
  Arr[0].A := 3;
  Arr[1] := Default(TSortKey);
  Arr[1].A := 1;
  Arr[2] := Default(TSortKey);
  Arr[2].A := 2;

  TArray.Sort<TSortKey>(Arr);

  Item := Default(TSortKey);
  Item.A := 2;
  Result := TArray.BinarySearch<TSortKey>(Arr, Item, Idx) and (Idx = 1);
end;

end.

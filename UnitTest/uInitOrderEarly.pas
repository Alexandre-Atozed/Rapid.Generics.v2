unit uInitOrderEarly;

// Initialized BEFORE uInitOrderLate (Late names this unit in its interface uses),
// yet calls into Late during initialization. Late instantiates the generic default
// comparers, whose class constructors have therefore not run yet at that point.

interface

var
  EarlyEqualityResult: Boolean;
  EarlySortSearchResult: Boolean;
  EarlyInitError: string;

implementation

uses
  System.SysUtils,
  uInitOrderLate;

initialization
  try
    EarlyEqualityResult := UseDefaultEqualityComparer;
    EarlySortSearchResult := UseDefaultSortAndSearch;
  except
    on E: Exception do
      EarlyInitError := E.ClassName + ': ' + E.Message;
  end;

end.

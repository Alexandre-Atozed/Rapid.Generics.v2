unit uTestTypes;

interface

uses
  Classes,
  SysUtils;

type
  TTestObject = class
  private
    FId: Integer;
  public
    constructor Create(AId: Integer);
    property ID: Integer read FId;
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

implementation

{ TTestObject }

constructor TTestObject.Create(AId: Integer);
begin
  inherited Create;
  FId := AId;
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


end.

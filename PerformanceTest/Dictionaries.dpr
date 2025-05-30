program Dictionaries;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Rapid.Generics in '..\Source\Rapid.Generics.pas',
  uDictionaries in 'uDictionaries.pas';

begin
  try
    Run;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

  if (ParamStr(1) <> '-nowait') then
  begin
    Writeln;
    Write('Press Enter to quit');
    Readln;
  end;
end.

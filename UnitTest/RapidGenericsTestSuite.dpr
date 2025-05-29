program RapidGenericsTestSuite;

///// UI Selection - Pick only 1! //////////////////////////////
{$DEFINE UseVCL}
{.$DEFINE UseFMX}
{.$DEFINE UseWinConsole}
////////////////////////////////////////////////////////////////

{.$DEFINE CHECK_MEM_LEAKS}

{$IFDEF UseWinConsole}
  {$DEFINE UseConsole}
{$ENDIF}

{$IFDEF UseConsole}
  {$APPTYPE CONSOLE}
{$ENDIF}

uses
  {$IFDEF CHECK_MEM_LEAKS}
  FastMM4 in '..\3rdParty\FastMM4\FastMM4.pas',
  {$ENDIF}
  {$IFDEF UseVCL}
  VCL.Forms,
  // Uncomment the line below (and fix the if necessary) in case the compiler cannot find DUnitX.Loggers.GUI.VCL.pas or dfm files
  DUnitX.Loggers.GUI.VCL
    {in 'c:\program files (x86)\embarcadero\studio\23.0\source\DUnitX\DUnitX.Loggers.GUI.VCL.pas'},
  {$ENDIF }
  {$IFDEF UseFMX}
  FMX.Forms,
  {$ENDIF }
  {$IFDEF UseConsole}
  DUnitX.ConsoleWriter.Base,
  {$ENDIF }
  {$IFDEF UseWinConsole}
  DUnitX.Windows.Console,
  {$ENDIF }
  System.SysUtils,
  DUnitX.Generics,
  DUnitX.InternalInterfaces,
  DUnitX.WeakReference,
  DUnitX.FixtureResult,
  DUnitX.RunResults,
  DUnitX.Test,
  DUnitX.TestFixture,
  DUnitX.TestFramework,
  DUnitX.TestResult,
  DUnitX.TestRunner,
  DUnitX.Utils,
  DUnitX.IoC,
  DUnitX.MemoryLeakMonitor.Default,
  DUnitX.DUnitCompatibility,
  Rapid.Generics in '..\Source\Rapid.Generics.pas',
  uListTest in 'uListTest.pas',
  uDictionaryTest in 'uDictionaryTest.pas',
  uStackTest in 'uStackTest.pas',
  uQueueTest in 'uQueueTest.pas',
  uTestTypes in 'uTestTypes.pas';

{$R *.res}

/////////////////////////////////////////////////////////////////////////
{$IFDEF UseVCL}
begin
  Application.Initialize;
  Application.CreateForm(TGUIVCLTestRunner, GUIVCLTestRunner);
  GUIVCLTestRunner.Font.Name := 'IBM Plex Sans';
  GUIVCLTestRunner.Font.Size := 10;
  Application.Run;
  {$ENDIF}
/////////////////////////////////////////////////////////////////////////
  {$IFDEF UseFMX}
  begin
    Application.Initialize;
    Application.CreateForm(TGUIXTestRunner, GUIXTestRunner);
    Application.Run;
    {$ENDIF}
/////////////////////////////////////////////////////////////////////////
    {$IFDEF UseConsole}
    var
    runner: ITestRunner;
    results: IRunResults;
    logger: ITestLogger;
    nunitLogger: ITestLogger;

    begin
      try
      //Create the runner
        runner := TDUnitX.CreateRunner;
        runner.UseRTTI := True;
      //tell the runner how we will log things
        logger := TDUnitXConsoleLogger.Create(true);
        nunitLogger := TDUnitXXMLNUnitFileLogger.Create;
        runner.AddLogger(logger);
        runner.AddLogger(nunitLogger);

      //Run tests
        results := runner.Execute;

        System.Write('Done.. press <Enter> key to quit.');
        System.Readln;

      except
        on E: Exception do
          System.Writeln(E.ClassName, ': ', E.Message);
      end;
      {$ENDIF}
/////////////////////////////////////////////////////////////////////////

{$IFDEF CHECK_MEM_LEAKS}
TObject.Create;    // Force a mem leak so we know that FastMM is correctly configured to catch/report leaks
{$ENDIF}

end.


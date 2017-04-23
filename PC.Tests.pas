unit PC.Tests;

interface

uses
  TestFramework;

type
  TestNameAttribute = class(TCustomAttribute)
  strict private
    FName: string;
  public
    constructor Create(const AName: string);
    property Name: string read FName;
  end;

  TPCTestCase = class(TTestCase)
  private
    function MethodInfo(X: TMethod { TEventType } ): string;
  strict protected
    function FixMethodName: string;
  public
    constructor Create(MethodName: string); overload; override;
    constructor Create(MethodName: string; RunCount: Int64); overload; override;
    class function Suite: ITestSuite; override;
  end;

implementation

uses
  System.Rtti;

constructor TestNameAttribute.Create(const AName: string);
begin
  FName := AName;
end;

constructor TPCTestCase.Create(MethodName: string);
begin
  inherited Create(MethodName);
  FixMethodName;
end;

constructor TPCTestCase.Create(MethodName: string; RunCount: Int64);
begin
  inherited Create(MethodName, RunCount);
  FixMethodName;
end;

function TPCTestCase.FixMethodName: string;
var
  RTTIContext: TRTTIContext;
  t: TRttiType;
  m: TRttiMethod;
  p: TRttiParameter;
  a: TCustomAttribute;
begin
  FTestName := MethodInfo(TMethod(fMethod));

{$IFNDEF CLR}
  /// /  assert(assigned(FMethod));
  // RTTIContext := TRTTIContext.Create;
  // try
  // // fMethod.
  //
  // t := RTTIContext.GetType(TMyRESTfulService);
  // m := t.GetMethod('HandleRequest');
  // for p in fMethod.GetParameters do
  // for a in p.GetAttributes do
  // Writeln('Attribute "', a.ClassName, '" found on parameter "', p.Name, '"');
  // finally
  //
  // end;
  //
  // for LMethod in RTTIContext.GetType(testClass).GetMethods do
  // begin
  // if LMethod.Name = NameOfMethod then
  // for LAttr in LMethod.GetAttributes do
  // if LAttr is RunCountAttribute then
  // begin
  // RunCount := RunCountAttribute(LAttr).FCount;
  /// /              end
  /// /              else if LAttr is TestNameAttribute then
  /// /              begin
  /// /                TestName := TestNameAttribute(LAttr).Name;
  // end;
  // end;
  //
  // finally
  // RTTIContext.Free;
  // end;


  // {$IFNDEF CLR}
  /// /var
  /// /  RunMethod: TMethod;
  // {$ENDIF}
  // begin
  // {$IFNDEF CLR}
  // assert(assigned(MethodAddress(MethodName)));
  // {$ELSE}
  // assert(MethodName <> '');
  // {$ENDIF}
  //
  // inherited Create(MethodName);
  // {$IFDEF CLR}
  // FMethod := MethodName;
  // {$ELSE}
  // RunMethod.code := MethodAddress(MethodName);
  // RunMethod.Data := self;
  // FMethod := TTestMethod(RunMethod);
  //
  // assert(assigned(FMethod));
  //
  // FRunCount := RunCount;
  // {$ENDIF}
  //
  //
{$ENDIF !CLR}
end;

class function TPCTestCase.Suite: ITestSuite;
var
  SuiteName: string;
  RTTIContext: TRTTIContext;
  RttiType: TRttiType;
  Attribute: TCustomAttribute;
  Suite: TTestSuite;
begin
  SuiteName := Self.ClassName;

  RTTIContext := TRTTIContext.Create;
  try
    RttiType := RTTIContext.GetType(Self.ClassInfo);
    for Attribute in RttiType.GetAttributes do
      if Attribute is TestNameAttribute then
      begin
        SuiteName := TestNameAttribute(Attribute).Name;
        Break;
      end;
  finally
    RTTIContext.Free;
  end;

  Suite := TTestSuite.Create(SuiteName);
  Result := Suite;
  Suite.AddTests(Self);
end;

function TPCTestCase.MethodInfo(X: TMethod { TEventType } ): string;
var
  RTTIContext: TRTTIContext;
  RttiType: TRttiType;
  RttiMethod: TRttiMethod;
  Attribute: TCustomAttribute;
begin
  Result := '';
  RTTIContext := TRTTIContext.Create;
  try
    RttiType := RTTIContext.GetType(TObject(TMethod(X).Data).ClassType);
    for RttiMethod in RttiType.GetMethods do
      if RttiMethod.CodeAddress = TMethod(X).Code then
      begin
        Result := {RttiType.Name + '.' +} RttiMethod.Name;
        Break;
      end;

    for Attribute in RttiMethod.GetAttributes do
      if Attribute is TestNameAttribute then
      begin
        Result := TestNameAttribute(Attribute).Name;
        Break;
      end;
  finally
    RTTIContext.Free;
  end;
end;

end.

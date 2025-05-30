unit Rapid.Generics;

{******************************************************************************}
{ Copyright (c) 2017-2019 Dmitry Mozulyov                                      }
{                                                                              }
{ Permission is hereby granted, free of charge, to any person obtaining a copy }
{ of this software and associated documentation files (the "Software"), to deal}
{ in the Software without restriction, including without limitation the rights }
{ to use, copy, modify, merge, publish, distribute, sublicense, and/or sell    }
{ copies of the Software, and to permit persons to whom the Software is        }
{ furnished to do so, subject to the following conditions:                     }
{                                                                              }
{ The above copyright notice and this permission notice shall be included in   }
{ all copies or substantial portions of the Software.                          }
{                                                                              }
{ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR   }
{ IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,     }
{ FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE  }
{ AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER       }
{ LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,}
{ OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN    }
{ THE SOFTWARE.                                                                }
{                                                                              }
{ email: softforyou@inbox.ru                                                   }
{ skype: dimandevil                                                            }
{******************************************************************************}

(*******************************************************************************
 This is a modified version of Rapid.Generics (v2)
 by Alexandre Machado

 See Readme.md file for details about changes in this version

 This modified version is maintained separately and is not affiliated
 with the original author.
*******************************************************************************)

// compiler directives
{$IFDEF FPC}
  {$MESSAGE ERROR 'FreePascal not supported'}
{$ELSE}
  {$IF CompilerVersion >= 24}
    {$LEGACYIFEND ON}
  {$IFEND}
  {$IF CompilerVersion < 29}
    {$MESSAGE ERROR 'Only XE8+ compiler versions supported'}
  {$IFEND}
  {$WARN UNSAFE_CODE OFF}
  {$WARN UNSAFE_TYPE OFF}
  {$WARN UNSAFE_CAST OFF}
  {$WARN SYMBOL_DEPRECATED OFF}
  {$WEAKLINKRTTI ON}
  {$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
  {$IF (not Defined(NEXTGEN)) or ((CompilerVersion >= 31) and Defined(LINUX))}
    {$DEFINE ANSISTRSUPPORT}
  {$IFEND}
  {$IFNDEF NEXTGEN}
    {$DEFINE SHORTSTRSUPPORT}
  {$ENDIF}
  {$IF Defined(MSWINDOWS) or (Defined(MACOS) and not Defined(IOS))}
    {$DEFINE WIDESTRSUPPORT}
  {$IFEND}
  {$IF Defined(MSWINDOWS) or (Defined(WIDESTRSUPPORT) and (CompilerVersion <= 21))}
    {$DEFINE WIDESTRLENSHIFT}
  {$IFEND}
  {$IF Defined(ANSISTRSUPPORT) and (CompilerVersion >= 20)}
    {$DEFINE INTERNALCODEPAGE}
  {$IFEND}
{$ENDIF}
{$POINTERMATH ON}
{$U-}{$V+}{$B-}{$X+}{$T+}{$P+}{$H+}{$J-}{$Z1}{$A4}
{$O+}{$R-}{$I-}{$Q-}{$W-}
{$IFDEF CPUX86}
{$IF not Defined(NEXTGEN)}
{$DEFINE CPUX86ASM}
{$DEFINE CPUINTELASM}
{$IFEND}
{$DEFINE CPUINTEL}
{$ENDIF}
{$IFDEF CPUX64}
{$IF not Defined(POSIX)}
{$DEFINE CPUX64ASM}
{$DEFINE CPUINTELASM}
{$IFEND}
{$DEFINE CPUINTEL}
{$ENDIF}
{$IF Defined(CPUX64) or Defined(CPUARM64)}
{$DEFINE LARGEINT}
{$IFEND}
{$IF (not Defined(CPUX64)) and (not Defined(CPUARM64))}
{$DEFINE SMALLINT}
{$IFEND}

// Enable/disable inline methods
{$DEFINE HAS_INLINE}

(*$HPPEMIT '#pragma option -w-8022'*)

interface

uses
  {$IFDEF MSWINDOWS}
  Winapi.Windows,
  {$ELSE .POSIX}
  Posix.SysTypes,
  Posix.Time,
  Posix.Sched,
  {$ENDIF}
  {$IFDEF USE_LIBICU}
  System.Internal.ICU,
  {$ENDIF}
  {$IFDEF MACOS}
  Posix.Langinfo,
  Posix.Locale,
  Posix.String_,
  {$ENDIF}
  System.Types,
  System.SysUtils,
  System.TypInfo,
  System.Variants,
  System.SysConst,
  System.RTLConsts,
  System.Math,
  System.Classes;

type

{ TNothing record
  Dummy null size structure }

  TNothing = packed record
  end;

{ TRecord record
  Universal structure }

  TRecord<T1, T2, T3, T4> = packed record
    Field1: T1;
    Field2: T2;
    Field3: T3;
    Field4: T4;
  end;

  TRecord<T1, T2, T3> = packed record
    Field1: T1;
    Field2: T2;
    Field3: T3;
  end;

  TRecord<T1, T2> = packed record
    Field1: T1;
    Field2: T2;
  end;

{ TProcedure/TFunction
  Universal references }

  TProcedure = reference to procedure;
  TProcedure<T> = reference to procedure(const Arg1: T);
  TProcedure<T1, T2> = reference to procedure(const Arg1: T1; const Arg2: T2);
  TProcedure<T1, T2, T3> = reference to procedure(const Arg1: T1; const Arg2: T2; const Arg3: T3);
  TProcedure<T1, T2, T3, T4> = reference to procedure(const Arg1: T1; const Arg2: T2; const Arg3: T3; const Arg4: T4);
  TFunction<TResult> = reference to function: TResult;
  TFunction<T, TResult> = reference to function(const Arg1: T): TResult;
  TFunction<T1, T2, TResult> = reference to function(const Arg1: T1; const Arg2: T2): TResult;
  TFunction<T1, T2, T3, TResult> = reference to function(const Arg1: T1; const Arg2: T2; const Arg3: T3): TResult;
  TFunction<T1, T2, T3, T4, TResult> = reference to function(const Arg1: T1; const Arg2: T2; const Arg3: T3; const
    Arg4: T4): TResult;

{ TOSTime record
  Extremely fast UTC-based system timer (Windows FILETIME format)
  Contains 64-bit value representing the number of 100-nanosecond intervals since January 1, 1601 }

  TOSTime = record
  private
    class var
      FLOCAL_DELTA: Int64;
      {$IFDEF POSIX}
      FCLOCK_REALTIME_DELTA: Int64;
      FCLOCK_REALTIME_LOCAL_DELTA: Int64;
    const
      CLOCK_REALTIME_COARSE = 5;
      CLOCK_MONOTONIC_COARSE = 6;
    class function InternalClockGetTime(const ClockId: Integer): Int64; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    {$ENDIF}
  public
    const
      MICROSECOND = Int64(10);
      MILLISECOND = MICROSECOND * 1000;
      SECOND = MILLISECOND * 1000;
      MINUT = SECOND * 60;
      HOUR = MINUT * 60;
      DAY = HOUR * 24;
      DATETIME_DELTA = -109205;

    class property LOCAL_DELTA: Int64 read FLOCAL_DELTA;
  private
    class procedure Initialize; static;
    {$IF CompilerVersion >= 31}
    class constructor ClassConstructor;
    {$IFEND}
    class function GetNow: Int64; static;
    class function GetUTCNow: Int64; static;
    class function GetTickCount: Cardinal; static; {$IFDEF MSWINDOWS} inline; {$ENDIF}
  public
    class function ToDateTime(const ATimeStamp: Int64): TDateTime; static;
    class function ToString(const ATimeStamp: Int64): string; static;
    class property TickCount: Cardinal read GetTickCount;
    class property Now: Int64 read GetNow;
    class property UTCNow: Int64 read GetUTCNow;
  end;

{ TSyncYield record
  Improves the performance of spin loops by providing the processor with a hint
  displaying that the current code is in a spin loop }

  PSyncYield = ^TSyncYield;
  TSyncYield = packed record
  private
    FCount: Byte;
  public
    class function Create: TSyncYield; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure Reset; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure Execute;

    property Count: Byte read FCount write FCount;
  end;

{ TSyncSpinlock record
  The simplest and sufficiently fast synchronization primitive
  Accepts only two values: locked and unlocked }

  PSyncSpinlock = ^TSyncSpinlock;
  TSyncSpinlock = record
  private
    [Volatile]FValue: Byte;
    function GetLocked: Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure InternalEnter;
    procedure InternalWait;
  public
    class function Create: TSyncSpinlock; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}

    function TryEnter: Boolean; {$IFNDEF CPUINTELASM} inline; {$ENDIF}
    function Enter(const ATimeout: Cardinal): Boolean; overload;
    procedure Enter; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure Leave; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function Wait(const ATimeout: Cardinal): Boolean; overload;
    procedure Wait; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF}

    property Locked: Boolean read GetLocked;
  end;

{ TSyncLocker record
  Synchronization primitive, minimizes thread serialization to gain
  read access to a resource shared among threads while still providing complete
  exclusivity to callers needing write access to the shared resource }

  PSyncLocker = ^TSyncLocker;
  TSyncLocker = record
  private
    [Volatile]FValue: Integer;
    function GetLocked: Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function GetLockedRead: Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function GetLockedExclusive: Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure InternalEnterRead;
    procedure InternalEnterExclusive;
    procedure InternalWait;
  public
    class function Create: TSyncLocker; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}

    function TryEnterRead: Boolean;
    function TryEnterExclusive: Boolean;
    function EnterRead(const ATimeout: Cardinal): Boolean; overload;
    function EnterExclusive(const ATimeout: Cardinal): Boolean; overload;

    procedure EnterRead; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure EnterExclusive; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure LeaveRead; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure LeaveExclusive; {$IFDEF HAS_INLINE} inline; {$ENDIF}

    function Wait(const ATimeout: Cardinal): Boolean; overload;
    procedure Wait; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF}

    property Locked: Boolean read GetLocked;
    property LockedRead: Boolean read GetLockedRead;
    property LockedExclusive: Boolean read GetLockedExclusive;
  end;

{ TSyncSmallLocker record
  One-byte implementation of TSyncLocker }

  PSyncSmallLocker = ^TSyncSmallLocker;
  TSyncSmallLocker = record
  private
    [Volatile]FValue: Byte;
    function GetLocked: Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function GetLockedRead: Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function GetLockedExclusive: Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class function InternalCAS(var AValue: Byte; const NewValue, Comparand: Byte): Boolean; static;
      {$IFNDEF CPUINTELASM} inline; {$ENDIF}
    procedure InternalEnterRead;
    procedure InternalEnterExclusive;
    procedure InternalWait;
  public
    class function Create: TSyncSmallLocker; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}

    function TryEnterRead: Boolean;
    function TryEnterExclusive: Boolean;
    function EnterRead(const ATimeout: Cardinal): Boolean; overload;
    function EnterExclusive(const ATimeout: Cardinal): Boolean; overload;

    procedure EnterRead; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure EnterExclusive; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure LeaveRead; {$IFNDEF CPUINTELASM} inline; {$ENDIF}
    procedure LeaveExclusive; {$IFNDEF CPUINTELASM} inline; {$ENDIF}

    function Wait(const ATimeout: Cardinal): Boolean; overload;
    procedure Wait; overload; {$IFDEF HAS_INLINE} inline; {$ENDIF}

    property Locked: Boolean read GetLocked;
    property LockedRead: Boolean read GetLockedRead;
    property LockedExclusive: Boolean read GetLockedExclusive;
  end;

{ TaggedPointer record
  Atomic 8 bytes sized tagged pointer structure, auto incremented for x86/x64 CPUs
  May be useful for lock-free algorithms (should be 8 byte aligned)
  Supports 48 bit addresses for CPUX64
  Contains free list (stack) routine }

  PTaggedPointer = ^TaggedPointer;
  TaggedPointer = packed record
  private
    [Volatile]F: packed record
      case Integer of
        0: (Value: Pointer);
        1: (VLow, VHigh: Integer);
        2: (VInt64: Int64);
        3: (VNative: NativeUInt);
        4: (VDouble: Double);
    end;

    function GetIsEmpty: Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function GetIsInvalid: Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function GetIsEmptyOrInvalid: Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    {$IFDEF CPUX64}
    function GetValue: Pointer; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    {$ENDIF}
    {$IFDEF CPUINTEL}
    procedure SetValue(const AValue: Pointer);
    {$ENDIF}

    {$IFDEF CPUX64}
    const
      X64_TAGGEDPTR_MASK = (NativeUInt(1) shl 48) - 1;
      X64_TAGGEDPTR_CLEAR = not X64_TAGGEDPTR_MASK;
      {$ENDIF}
  public
    const
      INVALID_VALUE = Pointer(NativeInt(-1) {$IFDEF CPUX64} and NativeInt(X64_TAGGEDPTR_MASK){$ENDIF});
  public
    // initialization, copying, comparison
    class function Create(const AValue: Pointer): TaggedPointer; overload; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class function Create(const AValue: Int64): TaggedPointer; overload; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class function Create(const ALow, AHigh: Integer): TaggedPointer; overload; static; {$IFDEF HAS_INLINE} inline;
      {$ENDIF}
    class operator Equal(const a, b: TaggedPointer): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function Copy: TaggedPointer; {$IFNDEF CPUX86} inline; {$ENDIF}
    procedure Fill(const AValue: TaggedPointer); {$IFNDEF CPUX86} inline; {$ENDIF}

    // atomic helpers
    function AtomicCmpExchange(const NewValue: Pointer; const Comparand: TaggedPointer): Boolean; overload;
    function AtomicCmpExchange(const NewValue: TaggedPointer; const Comparand: TaggedPointer): Boolean; overload;
    function AtomicExchange(const NewValue: Pointer): Pointer; overload;
    function AtomicExchange(const NewValue: TaggedPointer): TaggedPointer; overload;

    // pointer value
    property IsEmpty: Boolean read GetIsEmpty;
    property IsInvalid: Boolean read GetIsInvalid;
    property IsEmptyOrInvalid: Boolean read GetIsEmptyOrInvalid;
    {$IF not Defined(CPUINTEL)}
    property Value: Pointer read F.Value write F.Value;
    {$ELSEIF Defined(CPUX64)}
    property Value: Pointer read GetValue write SetValue;
    {$ELSE .CPUX86}
    property Value: Pointer read F.Value write SetValue;
    {$IFEND}
  public
    // free list (stack) routine
    procedure Push(const Value: Pointer); {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function Pop: Pointer;
    procedure PushList(const First, Last: Pointer); overload;
    procedure PushList(const First: Pointer {Last calculated}); overload;
    function PopList: Pointer;
    function PopListReversed: Pointer;

    // invalid value case
    function TryPush(const Value: Pointer): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function TryPop: Pointer;
    function TryPushList(const First, Last: Pointer): Boolean; overload;
    function TryPushList(const First: Pointer {Last calculated}): Boolean; overload;
    function TryPopList: Pointer;
    function TryPopListReversed: Pointer;
  end;

{ TCustomObject/ICustomObject class
  TInterfacedObject alternative (inheritor) and own interface, the differences:
   - contains an original object instance
   - optimized initialize, cleanup and atomic operations
   - NEXTGEN-like rule of DisposeOf method, i.e. allows to call destructor before reference count set to zero
   - data in inherited classes is 8 byte aligned (this may be useful for lock-free algorithms)
   - allows to be placed not in memory heap
   - allows to make TMonitor operations faster
   - incompatible with TInterfacedObject.RefCount property }

  TMemoryScheme = (msHeap, msAllocator, msFreeList, msUnknownBuffer);
  PMemoryScheme = ^TMemoryScheme;

  TCustomObject = class;
  ICustomObject = interface
    function GetSelf: TCustomObject{$IFDEF AUTOREFCOUNT}unsafe{$ENDIF};
    function GetMemoryScheme: TMemoryScheme;
    function GetDisposed: Boolean;
    function GetRefCount: Integer;
    procedure DisposeOf;
    function TryEnter: Boolean;
    function Enter(const ATimeout: Cardinal): Boolean; overload;
    procedure Enter; overload;
    procedure Leave;
    function Wait(const ATimeout: Cardinal): Boolean; overload;
    procedure Wait; overload;
    property Self: TCustomObject read GetSelf;
    property MemoryScheme: TMemoryScheme read GetMemoryScheme;
    property Disposed: Boolean read GetDisposed;
    property RefCount: Integer read GetRefCount;
  end;

  TCustomObject = class(TInterfacedObject, ICustomObject)
  protected
    const
      DISPOSED_FLAG = Integer($40000000);
      MEMORY_SCHEME_SHIFT = 27;
      MEMORY_SCHEME_MASK = Integer(High(TMemoryScheme)) shl MEMORY_SCHEME_SHIFT;
      MEMORY_SCHEME_CLEAR = not MEMORY_SCHEME_MASK;
      DISPREFCOUNT_MASK = MEMORY_SCHEME_CLEAR;
      DISPREFCOUNT_CLEAR = not DISPREFCOUNT_MASK;
      REFCOUNT_MASK = DISPREFCOUNT_MASK and (not DISPOSED_FLAG);
      REFCOUNT_CLEAR = not REFCOUNT_MASK;
      DEFAULT_REFCOUNT = {$IFDEF AUTOREFCOUNT}1{$ELSE}0{$ENDIF};
      DUMMY_REFCOUNT = Integer($80000000);
      DEFAULT_DESTROY_FLAGS = DISPOSED_FLAG or DUMMY_REFCOUNT;
      {$IF CompilerVersion >= 32}
      monFlagsMask = NativeInt($01);
      monMonitorMask = not monFlagsMask;
      monWeakReferencedFlag = NativeInt($01);
      {$IFEND}
      {$IFNDEF AUTOREFCOUNT}
      vmtObjAddRef = SizeOf(Pointer);
      vmtObjRelease = vmtObjAddRef + SizeOf(Pointer);
      {$ENDIF}
    type
      IInterfaceTable = array[0..2] of Pointer;
      ICustomObjectTable = array[0..7] of Pointer;
    class var
      FInterfaceTable: IInterfaceTable;

    class procedure CreateIntfTables; static;
    {$IF CompilerVersion >= 31}
    class constructor ClassConstructor;
    {$IFEND}
    class function IntfQueryInterface(const Self: PByte; const IID: TGUID; out Obj): HResult; stdcall; static;
    class function IntfAddRef(const Self: PByte): Integer; stdcall; static;
    class function IntfRelease(const Self: PByte): Integer; stdcall; static;
  protected
    function GetSelf: TCustomObject{$IFDEF AUTOREFCOUNT}unsafe{$ENDIF};
    function GetRefCount: Integer; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function ICustomObject.QueryInterface = QueryInterface;
    function ICustomObject._AddRef = _AddRef;
    function ICustomObject._Release = _Release;

    class function CreateEObjectDisposed: EObjectDisposed; static;
    class function CreateEInvalidRefCount(const AObject: TObject; const ARefCount: Integer): EInvalidContainer; static;
    function GetMemoryScheme: TMemoryScheme; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function GetDisposed: Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure CheckDisposed; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function _AddRef: Integer; stdcall; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function _Release: Integer; stdcall; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function InternalMonitorOptimize(const ASpinCount: Integer): TCustomObject{$IFDEF AUTOREFCOUNT}unsafe{$ENDIF};
    function MonitorOptimize: TCustomObject{$IFDEF AUTOREFCOUNT}unsafe{$ENDIF}; {$IFDEF HAS_INLINE} inline; {$ENDIF}
  public
    class function NewInstance: TObject; override;
    class function PreallocatedInstance(const AMemory: Pointer; const AMemoryScheme: TMemoryScheme):
      TObject{$IFDEF AUTOREFCOUNT}unsafe{$ENDIF}; virtual;
    procedure FreeInstance; override;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    {$IFNDEF AUTOREFCOUNT}
    procedure Free; reintroduce; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    {$ENDIF}
    procedure DisposeOf; reintroduce;
    function __ObjAddRef: Integer; {$IFDEF AUTOREFCOUNT} override{$ELSE} virtual{$ENDIF};
    function __ObjRelease: Integer; {$IFDEF AUTOREFCOUNT} override{$ELSE} virtual{$ENDIF};
    function TryEnter: Boolean;
    function Enter(const ATimeout: Cardinal): Boolean; overload;
    procedure Enter; overload;
    procedure Leave;
    function Wait(const ATimeout: Cardinal): Boolean; overload;
    procedure Wait; overload;
    property MemoryScheme: TMemoryScheme read GetMemoryScheme;
    property Disposed: Boolean read GetDisposed;
    property RefCount: Integer read GetRefCount;
  end;

{ TLiteCustomObject class
  Single-thread and non-locking code optimized TCustomObject class }

  TLiteCustomObject = class(TCustomObject)
  protected
    class var
      FInterfaceTable: TCustomObject.IInterfaceTable;
      FCustomObjectTable: TCustomObject.ICustomObjectTable;

    class procedure CreateIntfTables; static;
    {$IF CompilerVersion >= 31}
    class constructor ClassConstructor;
    {$IFEND}
    class function IntfAddRef(const Self: PByte): Integer; stdcall; static;
    class function IntfRelease(const Self: PByte): Integer; stdcall; static;
    class function CustomObjectAddRef(const Self: PByte): Integer; stdcall; static;
    class function CustomObjectRelease(const Self: PByte): Integer; stdcall; static;
    function _AddRef: Integer; stdcall; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function _Release: Integer; stdcall; {$IFDEF HAS_INLINE} inline; {$ENDIF}
  public
    class function NewInstance: TObject; override;
    class function PreallocatedInstance(const AMemory: Pointer; const AMemoryScheme: TMemoryScheme): TObject; override;
    function __ObjAddRef: Integer; override;
    function __ObjRelease: Integer; override;
  end;

{ TRAIIHelper record
  Low level RTTI routine: initialization/finalization }

  TRAIIHelper = record
  public
    type
      TClearNativeProc = procedure(P, TypeInfo: Pointer);
      TClearNativeRec = record
        Offset: NativeInt;
        DynTypeInfo: PTypeInfo;
        ClearNativeProc: TClearNativeProc;
      end;
      TClearNatives = record
        Items: TArray<TClearNativeRec>;
        ItemSingle: TClearNativeRec;
        Count: NativeInt;
        procedure Clear; {$IFDEF HAS_INLINE} inline; {$ENDIF}
        procedure Add(AOffset: NativeInt; ADynTypeInfo: PTypeInfo; AClearNativeProc: TClearNativeProc);
      end;
      {$IFDEF WEAKINSTREF}
      TInitNativeRec = record
        Offset: NativeInt;
      end;
      TInitNatives = record
        Items: TArray<TInitNativeRec>;
        ItemSingle: TInitNativeRec;
        Count: NativeInt;
        procedure Clear; {$IFDEF HAS_INLINE} inline; {$ENDIF}
        procedure Add(AOffset: NativeInt);
      end;
      {$ELSE}
      TNativeRec = TClearNativeRec;
      TNatives = TClearNatives;
      {$ENDIF}
      TStaticArrayRec = record
        Offset: NativeInt;
        StaticTypeInfo: PTypeInfo;
        Count: NativeUInt;
      end;
      TStaticArrays = record
        Items: TArray<TStaticArrayRec>;
        Count: NativeInt;
        procedure Clear; {$IFDEF HAS_INLINE} inline; {$ENDIF}
        procedure Add(AOffset: NativeInt; AStaticTypeInfo: PTypeInfo; ACount: NativeUInt);
      end;
  public
    const
      varDeepData = $BFE8;
  private
    type
      PFieldInfo = ^TFieldInfo;
      TFieldInfo = packed record
        TypeInfo: PPTypeInfo;
        Offset: Cardinal;
        {$IFDEF LARGEINT}
        _Padding: Integer;
        {$ENDIF}
      end;
      PFieldTable = ^TFieldTable;
      TFieldTable = packed record
        X: Word;
        Size: Cardinal;
        Count: Cardinal;
        Fields: array[0..0] of TFieldInfo;
      end;
      TData16 = packed record
        case Integer of
          0: (Native: NativeInt);
          1: (Method: TMethod);
          2: (VarData: TVarData);
          3: (Bytes: array[0..15] of Byte);
          4: (Words: array[0..7] of Word);
          5: (Integers: array[0..3] of Integer);
          6: (Int64s: array[0..1] of Int64);
          7: (Natives: array[0.. {$IFDEF LARGEINT}1{$ELSE .SMALLINT}3{$ENDIF}] of NativeUInt);
      end;
      PData16 = ^TData16;
      TData16<TOffset> = packed record
        Offset: TOffset;
        case Integer of
          0: (Native: NativeInt);
          1: (Method: TMethod);
          2: (VarData: TVarData);
          3: (Bytes: array[0..15] of Byte);
          4: (Words: array[0..7] of Word);
          5: (Integers: array[0..3] of Integer);
          6: (Int64s: array[0..1] of Int64);
          7: (Natives: array[0.. {$IFDEF LARGEINT}1{$ELSE .SMALLINT}3{$ENDIF}] of NativeUInt);
      end;
      T1 = Byte;
      T2 = Word;
      T3 = array[1..3] of Byte;
      T4 = Cardinal;
      T5 = array[1..5] of Byte;
      T6 = array[1..6] of Byte;
      T7 = array[1..7] of Byte;
      T8 = Int64;
      T9 = array[1..9] of Byte;
      T10 = array[1..10] of Byte;
      T11 = array[1..11] of Byte;
      T12 = array[1..12] of Byte;
      T13 = array[1..13] of Byte;
      T14 = array[1..14] of Byte;
      T15 = array[1..15] of Byte;
      T16 = array[1..16] of Byte;
      T17 = array[1..17] of Byte;
      T18 = array[1..18] of Byte;
      T19 = array[1..19] of Byte;
      T20 = array[1..20] of Byte;
      T21 = array[1..21] of Byte;
      T22 = array[1..22] of Byte;
      T23 = array[1..23] of Byte;
      T24 = array[1..24] of Byte;
      T25 = array[1..25] of Byte;
      T26 = array[1..26] of Byte;
      T27 = array[1..27] of Byte;
      T28 = array[1..28] of Byte;
      T29 = array[1..29] of Byte;
      T30 = array[1..30] of Byte;
      T31 = array[1..31] of Byte;
      T32 = array[1..32] of Byte;
      T33 = array[1..33] of Byte;
      T34 = array[1..34] of Byte;
      T35 = array[1..35] of Byte;
      T36 = array[1..36] of Byte;
      T37 = array[1..37] of Byte;
      T38 = array[1..38] of Byte;
      T39 = array[1..39] of Byte;
      T40 = array[1..40] of Byte;
      TTemp40 = record
        case Integer of
          1: (V1: T1);
          2: (V2: T2);
          3: (V3: T3);
          4: (V4: T4);
          5: (V5: T5);
          6: (V6: T6);
          7: (V7: T7);
          8: (V8: T8);
          9: (V9: T9);
          10: (V10: T10);
          11: (V11: T11);
          12: (V12: T12);
          13: (V13: T13);
          14: (V14: T14);
          15: (V15: T15);
          16: (V16: T16);
          17: (V17: T17);
          18: (V18: T18);
          19: (V19: T19);
          20: (V20: T20);
          21: (V21: T21);
          22: (V22: T22);
          23: (V23: T23);
          24: (V24: T24);
          25: (V25: T25);
          26: (V26: T26);
          27: (V27: T27);
          28: (V28: T28);
          29: (V29: T29);
          30: (V30: T30);
          31: (V31: T31);
          32: (V32: T32);
          33: (V33: T33);
          34: (V34: T34);
          35: (V35: T35);
          36: (V36: T36);
          37: (V37: T37);
          38: (V38: T38);
          39: (V39: T39);
          40: (V40: T40);
      end;
      TNativeIntRec = packed record
        case Boolean of
          False: (Int: Integer);
          True: (Native: NativeInt);
      end;
  private
    FTypeInfo: PTypeInfo;
    FSize: NativeInt;
    FItemSize: NativeInt;
    FWeak: Boolean;

    // type var leak fix
    class procedure RegisterDynamicArray(const P: Pointer); static;
    class procedure UnregisterDynamicArray(const P: Pointer); static;

    // initialization/finalization
    procedure Include(AOffset: NativeInt; Value: PTypeInfo);
    procedure Initialize(Value: PTypeInfo);
    function GetTypeData: PTypeData; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class function IsManagedTypeInfo(Value: PTypeInfo): Boolean; static;
    class function InitsProcNativeOne(const Self: TRAIIHelper; P: Pointer): Pointer; static;
    class procedure InitsArrayProcNativeOne(const Self: TRAIIHelper; P, Overflow: Pointer; ItemSize: NativeUInt);
      static;
    class function InitsProcNativeTwo(const Self: TRAIIHelper; P: Pointer): Pointer; static;
    class procedure InitsArrayProcNativeTwo(const Self: TRAIIHelper; P, Overflow: Pointer; ItemSize: NativeUInt);
      static;
    class function InitsProcNativeThree(const Self: TRAIIHelper; P: Pointer): Pointer; static;
    class procedure InitsArrayProcNativeThree(const Self: TRAIIHelper; P, Overflow: Pointer; ItemSize: NativeUInt);
      static;
    class function InitsProcNatives(const Self: TRAIIHelper; P: Pointer): Pointer; static;
    class procedure InitsArrayProcNatives(const Self: TRAIIHelper; P, Overflow: Pointer; ItemSize: NativeUInt); static;
    class function InitsProc(const Self: TRAIIHelper; P: Pointer): Pointer; static;
    class procedure InitsArrayProc(const Self: TRAIIHelper; P, Overflow: Pointer; ItemSize: NativeUInt); static;
    class function ClearsProcNativeOne(const Self: TRAIIHelper; P: Pointer): Pointer; static;
    class procedure ClearsArrayProcNativeOne(const Self: TRAIIHelper; P, Overflow: Pointer; ItemSize: NativeUInt);
      static;
    class function ClearsProcNativeTwo(const Self: TRAIIHelper; P: Pointer): Pointer; static;
    class procedure ClearsArrayProcNativeTwo(const Self: TRAIIHelper; P, Overflow: Pointer; ItemSize: NativeUInt);
      static;
    class function ClearsProcNativeThree(const Self: TRAIIHelper; P: Pointer): Pointer; static;
    class procedure ClearsArrayProcNativeThree(const Self: TRAIIHelper; P, Overflow: Pointer; ItemSize: NativeUInt);
      static;
    class function ClearsProcNatives(const Self: TRAIIHelper; P: Pointer): Pointer; static;
    class procedure ClearsArrayProcNatives(const Self: TRAIIHelper; P, Overflow: Pointer; ItemSize: NativeUInt);
      static;
    class function ClearsProc(const Self: TRAIIHelper; P: Pointer): Pointer; static;
    class procedure ClearsArrayProc(const Self: TRAIIHelper; P, Overflow: Pointer; ItemSize: NativeUInt); static;

    // TClearNativeProc-anonyms
    class procedure ULStrClear(P: Pointer); static;
    {$IFDEF MSWINDOWS}
    class procedure WStrClear(P: Pointer); static;
    {$ENDIF}
    class procedure IntfClear(P: Pointer); static;
    class procedure VarClear(P: Pointer); static;
    class procedure DynArrayClear(P, TypeInfo: Pointer); static;
    {$IFDEF AUTOREFCOUNT}
    class procedure RefObjClear(P: Pointer); static;
    {$ENDIF}
    {$IFDEF WEAKINSTREF}
    class procedure WeakObjClear(P: Pointer); static;
    class procedure WeakMethodClear(P: Pointer); static;
    {$ENDIF}
    {$IFDEF WEAKINTFREF}
    class procedure WeakIntfClear(P: Pointer); static;
    {$ENDIF}
  public
    {$IFDEF WEAKINSTREF}
    InitNatives: TInitNatives;
    ClearNatives: TClearNatives;
    {$ELSE}
    Natives: TNatives;
    {$ENDIF}
    StaticArrays: TStaticArrays;
    InitProc: function(const Self: TRAIIHelper; P: Pointer): Pointer;
    ClearProc: function(const Self: TRAIIHelper; P: Pointer): Pointer;
    InitArrayProc: procedure(const Self: TRAIIHelper; P, Overflow: Pointer; ItemSize: NativeUInt);
    ClearArrayProc: procedure(const Self: TRAIIHelper; P, Overflow: Pointer; ItemSize: NativeUInt);

    property TypeInfo: PTypeInfo read FTypeInfo write Initialize;
    property TypeData: PTypeData read GetTypeData;
    property Size: NativeInt read FSize;
    property ItemSize: NativeInt read FItemSize;
    property Weak: Boolean read FWeak;
  end;
  PRAIIHelper = ^TRAIIHelper;

  TRAIIHelper<T> = record
  public
    type
      P = ^T;
      TArrayT = array[0..0] of T;
      PArrayT = ^TArrayT;
      TData = TRAIIHelper.TData16;
      PData = ^TData;
  private
    class var
      FOptions: TRAIIHelper;

    class constructor ClassCreate;
    class function GetManaged: Boolean; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class function GetWeak: Boolean; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
  public
    class function Init(Item: Pointer): Pointer; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class procedure Clear(Item: Pointer); static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    //class function ClearItem(Item: Pointer): Pointer; static; {$IFDEF HAS_INLINE}inline;{$ENDIF}
    class procedure InitArray(Item, OverflowItem: Pointer; ItemSize: NativeUInt); overload; static;
    class procedure InitArray(Item, OverflowItem: Pointer); overload; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class procedure InitArray(Item: Pointer; Count, ItemSize: NativeUInt); overload; static; {$IFDEF HAS_INLINE}
      inline; {$ENDIF}
    class procedure InitArray(Item: Pointer; Count: NativeUInt); overload; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class procedure ClearArray(Item, OverflowItem: Pointer; ItemSize: NativeUInt); overload; static;
    class procedure ClearArray(Item, OverflowItem: Pointer); overload; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class procedure ClearArray(Item: Pointer; Count, ItemSize: NativeUInt); overload; static; {$IFDEF HAS_INLINE}
      inline; {$ENDIF}
    class procedure ClearArray(Item: Pointer; Count: NativeUInt); overload; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}

    class property Managed: Boolean read GetManaged;
    class property Weak: Boolean read GetWeak;
    class property Options: TRAIIHelper read FOptions;
  end;

  TRAIIHelper<T1, T2, T3, T4> = record
  public
    type
      T = TRecord<T1, T2, T3, T4>;
      P = ^T;
      TArrayT = array[0..0] of T;
      PArrayT = ^TArrayT;
      TData1 = TRAIIHelper.TData16;
      TData2 = TRAIIHelper.TData16<T1>;
      TData3 = TRAIIHelper.TData16<TRecord<T1, T2>>;
      TData4 = TRAIIHelper.TData16<TRecord<T1, T2, T3>>;
      PData1 = ^TData1;
      PData2 = ^TData2;
      PData3 = ^TData3;
      PData4 = ^TData4;
  private
    class function GetManaged: Boolean; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class function GetWeak: Boolean; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class function GetOptions: PRAIIHelper; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
  public
    class function Init(Item: Pointer): Pointer; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class procedure Clear(Item: Pointer); static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class function ClearItem(Item: Pointer): Pointer; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class procedure InitArray(Item, OverflowItem: Pointer; ItemSize: NativeUInt); overload; static;
    class procedure InitArray(Item, OverflowItem: Pointer); overload; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class procedure InitArray(Item: Pointer; Count, ItemSize: NativeUInt); overload; static; {$IFDEF HAS_INLINE}
      inline; {$ENDIF}
    class procedure InitArray(Item: Pointer; Count: NativeUInt); overload; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class procedure ClearArray(Item, OverflowItem: Pointer; ItemSize: NativeUInt); overload; static;
    class procedure ClearArray(Item, OverflowItem: Pointer); overload; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class procedure ClearArray(Item: Pointer; Count, ItemSize: NativeUInt); overload; static; {$IFDEF HAS_INLINE}
      inline; {$ENDIF}
    class procedure ClearArray(Item: Pointer; Count: NativeUInt); overload; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}

    class property Managed: Boolean read GetManaged;
    class property Weak: Boolean read GetWeak;
    class property Options: PRAIIHelper read GetOptions;
  end;

{ InterfaceDefaults record
  Default functions/interfaces }

  InterfaceDefaults = record
  public
    type
      TMethodPtr = procedure of object;
      TTriple = packed record
        case Integer of
          0: (Low: Word; High: Byte);
          1: (Bytes: array[0..2] of Byte);
      end;
      IComparerInst = packed record
        Vtable: Pointer;
        Size: NativeInt;
        QueryInterface,
          AddRef,
          Release,
          Compare: Pointer;
      end;
      IEqualityComparerInst = packed record
        Vtable: Pointer;
        Size: NativeInt;
        QueryInterface,
          AddRef,
          Release,
          Equals,
          GetHashCode: Pointer;
      end;
      TDefaultComparer<T> = record
      public
        class var
          Instance: IComparerInst;
      private
        class constructor ClassCreate;
      end;
      TDefaultEqualityComparer<T> = record
      public
        class var
          Instance: IEqualityComparerInst;
      private
        class constructor ClassCreate;
      end;
  private
    class function Compare_Var_Difficult(Equal: Boolean; Left, Right: PVariant): Integer; static;
    class function GetHashCode_Var_Difficult(Value: PVariant): Integer; static;
  public
    // Nop Interface
    class function NopQueryInterface(Inst: Pointer; const IID: TGUID; out Obj): HResult; stdcall; static;
    class function NopAddRef(Inst: Pointer): Integer; stdcall; static;
    class function NopRelease(Inst: Pointer): Integer; stdcall; static;

    // IComparer<T>
    class function Compare_I1(Inst: Pointer; Left, Right: Shortint): Integer; static;
    class function Compare_U1(Inst: Pointer; Left, Right: Byte): Integer; static;
    class function Compare_I2(Inst: Pointer; Left, Right: Smallint): Integer; static;
    class function Compare_U2(Inst: Pointer; Left, Right: Word): Integer; static;
    class function Compare_I4(Inst: Pointer; Left, Right: Integer): Integer; static;
    class function Compare_U4(Inst: Pointer; Left, Right: Cardinal): Integer; static;
    class function Compare_I8(Inst: Pointer; Left, Right: Int64): Integer; static;
    class function Compare_U8(Inst: Pointer; Left, Right: UInt64): Integer; static;
    class function Compare_F4(Inst: Pointer; Left, Right: Single): Integer; static;
    class function Compare_F8(Inst: Pointer; Left, Right: Double): Integer; static;
    class function Compare_FE(Inst: Pointer; Left, Right: Extended): Integer; static;
    class function Compare_Var(Inst: Pointer; Left, Right: PVarData): Integer; static;
    class function Compare_OStr(Inst: Pointer; Left, Right: PByte): Integer; static;
    class function Compare_LStr(Inst: Pointer; Left, Right: PByte): Integer; static;
    class function Compare_UStr(Inst: Pointer; Left, Right: PByte): Integer; static;
    class function Compare_WStr(Inst: Pointer; Left, Right: PByte): Integer; static;
    class function Compare_Method(Inst: Pointer; const Left, Right: TMethodPtr): Integer; static;
    class function Compare_Dyn(const Inst: IComparerInst; Left, Right: PByte): Integer; static;
    class function Compare_Bin2(Inst: Pointer; Left, Right: Word): Integer; static;
    class function Compare_Bin3(Inst: Pointer; const Left, Right: TTriple): Integer; static;
    class function Compare_Bin4(Inst: Pointer; Left, Right: Cardinal): Integer; static;
    class function Compare_Bin8(Inst: Pointer; Left, Right: Int64): Integer; static;
    class function Compare_Bin(const Inst: IComparerInst; Left, Right: PByte): Integer; static;

    // IEqualityComparer<T>
    class function Equals_N1(Inst: Pointer; Left, Right: Byte): Boolean; static;
    class function GetHashCode_N1(Inst: Pointer; Value: Byte): Integer; static;
    class function Equals_N2(Inst: Pointer; Left, Right: Word): Boolean; static;
    class function GetHashCode_N2(Inst: Pointer; Value: Word): Integer; static;
    class function Equals_N4(Inst: Pointer; Left, Right: Integer): Boolean; static;
    class function GetHashCode_N4(Inst: Pointer; Value: Integer): Integer; static;
    class function Equals_N8(Inst: Pointer; Left, Right: Int64): Boolean; static;
    class function GetHashCode_N8(Inst: Pointer; Value: Int64): Integer; static;
    class function Equals_Class(Inst: Pointer; Left, Right: TObject): Boolean; static;
    class function GetHashCode_Class(Inst: Pointer; Value: TObject): Integer; static;
    class function GetHashCode_Ptr(Inst: Pointer; Value: NativeInt): Integer; static;
    class function Equals_F4(Inst: Pointer; Left, Right: Single): Boolean; static;
    class function GetHashCode_F4(Inst: Pointer; Value: Single): Integer; static;
    class function Equals_F8(Inst: Pointer; Left, Right: Double): Boolean; static;
    class function GetHashCode_F8(Inst: Pointer; Value: Double): Integer; static;
    class function Equals_FE(Inst: Pointer; Left, Right: Extended): Boolean; static;
    class function GetHashCode_FE(Inst: Pointer; Value: Extended): Integer; static;
    class function Equals_Var(Inst: Pointer; Left, Right: PVarData): Boolean; static;
    class function GetHashCode_Var(Inst: Pointer; Value: PVarData): Integer; static;
    class function Equals_OStr(Inst: Pointer; Left, Right: PByte): Boolean; static;
    class function GetHashCode_OStr(Inst: Pointer; Value: PByte): Integer; static;
    class function Equals_LStr(Inst: Pointer; Left, Right: PByte): Boolean; static;
    class function GetHashCode_LStr(Inst: Pointer; Value: PByte): Integer; static;
    class function Equals_UStr(Inst: Pointer; Left, Right: PByte): Boolean; static;
    class function GetHashCode_UStr(Inst: Pointer; Value: PByte): Integer; static;
    class function Equals_WStr(Inst: Pointer; Left, Right: PByte): Boolean; static;
    class function GetHashCode_WStr(Inst: Pointer; Value: PByte): Integer; static;
    class function Equals_Method(Inst: Pointer; const Left, Right: TMethodPtr): Boolean; static;
    class function GetHashCode_Method(Inst: Pointer; const Value: TMethodPtr): Integer; static;
    class function Equals_Dyn(const Inst: IEqualityComparerInst; Left, Right: PByte): Boolean; static;
    class function GetHashCode_Dyn(const Inst: IEqualityComparerInst; Value: PByte): Integer; static;
    class function Equals_Bin3(Inst: Pointer; const Left, Right: TTriple): Boolean; static;
    class function GetHashCode_Bin3(Inst: Pointer; const Value: TTriple): Integer; static;
    class function Equals_Bin(const Inst: IEqualityComparerInst; Left, Right: PByte): Boolean; static;
    class function GetHashCode_Bin(const Inst: IEqualityComparerInst; Value: PByte): Integer; static;
  end;

{ System.Generics.Defaults
  Equivalent types }

  IComparer<T> = interface
    function Compare(const Left, Right: T): Integer;
  end;

  IEqualityComparer<T> = interface
    function Equals(const Left, Right: T): Boolean;
    function GetHashCode(const Value: T): Integer;
  end;

  TComparison<T> = reference to function(const Left, Right: T): Integer;

  // Abstract base class for IComparer<T> implementations, and a provider
  // of default IComparer<T> implementations.
  TComparer<T> = class(TCustomObject, IComparer<T>)
  public
    class function Default: IComparer<T>;
    class function Construct(const Comparison: TComparison<T>): IComparer<T>; static; {$IFDEF HAS_INLINE} inline;
      {$ENDIF}
    function Compare(const Left, Right: T): Integer; virtual; abstract;
  end;

  TEqualityComparison<T> = reference to function(const Left, Right: T): Boolean;
  THasher<T> = reference to function(const Value: T): Integer;

  // Abstract base class for IEqualityComparer<T> implementations, and a provider
  // of default IEqualityComparer<T> implementations.
  TEqualityComparer<T> = class(TCustomObject, IEqualityComparer<T>)
  public
    class function Default: IEqualityComparer<T>; static;

    class function Construct(const EqualityComparison: TEqualityComparison<T>;
      const Hasher: THasher<T>): IEqualityComparer<T>;

    function Equals(const Left, Right: T): Boolean;
    reintroduce; overload; virtual; abstract;
    function GetHashCode(const Value: T): Integer;
    reintroduce; overload; virtual; abstract;
  end;

  // A non-reference-counted IInterface implementation.
  TSingletonImplementation = class(TObject, IInterface)
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

  TDelegatedComparer<T> = class(TComparer<T>)
  private
    FCompare: TComparison<T>;
  public
    constructor Create(const ACompare: TComparison<T>);
    function Compare(const Left, Right: T): Integer; override;
  end;

  TDelegatedEqualityComparer<T> = class(TEqualityComparer<T>)
  private
    FEquals: TEqualityComparison<T>;
    FGetHashCode: THasher<T>;
  public
    constructor Create(const AEquals: TEqualityComparison<T>;
      const AGetHashCode: THasher<T>);
    function Equals(const Left, Right: T): Boolean; overload; override;
    function GetHashCode(const Value: T): Integer; overload; override;
  end;

  TCustomComparer<T> = class(TSingletonImplementation, IComparer<T>, IEqualityComparer<T>)
  protected
    function Compare(const Left, Right: T): Integer; virtual; abstract;
    function Equals(const Left, Right: T): Boolean;
    reintroduce; overload; virtual; abstract;
    function GetHashCode(const Value: T): Integer;
    reintroduce; overload; virtual; abstract;
  end;

  TStringComparer = class(TCustomComparer<string>)
  private
    class var
      FOrdinal: TCustomComparer<string>;
  public
    class destructor Destroy;
    class function Ordinal: TStringComparer;
  end;

  TOrdinalIStringComparer = class(TStringComparer)
  private
    function CharsLower(Dest, Src: PWideChar; Count: Integer): Boolean;
    function GetHashCodeLower(const Value: string): Integer;
  public
    function Compare(const Left, Right: string): Integer; override;
    function Equals(const Left, Right: string): Boolean;
    reintroduce; overload; override;
    function GetHashCode(const Value: string): Integer;
    reintroduce; overload; override;
  end;

  TIStringComparer = class(TCustomComparer<string>)
  private
    class var
      FOrdinal: TCustomComparer<string>;
  public
    class destructor Destroy;
    class function Ordinal: TStringComparer;
  end;

{ System.Generics.Collections
  Basic types }

  TCollectionNotification = (cnAdded, cnRemoved, cnExtracted);
  TCollectionNotifyEvent<T> = procedure(Sender: TObject; const Item: T;
    Action: TCollectionNotification) of object;

  TEnumerator_ = class abstract(TCustomObject, IEnumerator)
  protected
    function IEnumerator.GetCurrent = DoGetCurrentObject;
    function IEnumerator.MoveNext = DoMoveNext;
    procedure IEnumerator.Reset = DoReset;
    function DoGetCurrentObject: TObject; virtual; abstract;
    function DoMoveNext: Boolean; virtual; abstract;
    procedure DoReset; virtual;
  public
    procedure Reset;
    function MoveNext: Boolean;
    property Current: TObject read DoGetCurrentObject;
  end;

  TEnumerator<T> = class abstract(TEnumerator_, IEnumerator<T>)
  protected
    function IEnumerator<T>.GetCurrent = DoGetCurrent;
    function IEnumerator<T>.MoveNext = DoMoveNext;
    function DoGetCurrentObject: TObject; override;
    function DoGetCurrent: T; virtual; abstract;
  public
    property Current: T read DoGetCurrent;
    property CurrentObject: TObject read DoGetCurrentObject;
  end;

  TEnumerable_ = class abstract(TCustomObject, IEnumerable)
  protected
    function IEnumerable.GetEnumerator = GetObjectEnumerator;
    function GetObjectEnumerator: IEnumerator;
    function DoGetObjectEnumerator: TEnumerator_; virtual; abstract;
  public
    function GetEnumerator: TEnumerator_;
  end;

  TEnumerable<T> = class abstract(TEnumerable_, IEnumerable<T>)
  protected
    function IEnumerable<T>.GetEnumerator = GetEnumerator_;
    function DoGetObjectEnumerator: TEnumerator_; override;
    function GetEnumerator_: IEnumerator<T>;
    function DoGetEnumerator: TEnumerator<T>; virtual; abstract;
  public
    destructor Destroy; override;
    function GetEnumerator: TEnumerator<T>; reintroduce;
    function ToArray: TArray<T>; virtual;
  end;

  TPair<TKey, TValue> = record
    Key: TKey;
    Value: TValue;
    constructor Create(const AKey: TKey; const AValue: TValue);
  end;

  PObject = ^TObject;

{ TArray class }

  TArray = class
  protected
    const
      HIGH_NATIVE = {$IFDEF LARGEINT}63{$ELSE}31{$ENDIF};
      HIGH_NATIVE_BIT = NativeInt(1) shl HIGH_NATIVE;
      BUFFER_SIZE = 1024;
  protected
    type
      TItemList<T> = array[0..15] of T;
      TSortStackItem<T> = record
        First: ^T;
        Last: ^T;
      end;
      TSortStack<T> = array[0..63] of TSortStackItem<T>;

      HugeByteArray = array[0..High(Integer) div SizeOf(Byte) - 1] of Byte;
      HugeWordArray = array[0..High(Integer) div SizeOf(Word) - 1] of Word;
      HugeCardinalArray = array[0..High(Integer) div SizeOf(Cardinal) - 1] of Cardinal;
      HugeUInt64Array = array[0..High(Integer) div SizeOf(UInt64) - 1] of UInt64;
      HugeNativeUIntArray = array[0..High(Integer) div SizeOf(NativeUInt) - 1] of NativeUInt;

      HugeShortIntArray = array[0..High(Integer) div SizeOf(ShortInt) - 1] of ShortInt;
      HugeSmallIntArray = array[0..High(Integer) div SizeOf(SmallInt) - 1] of SmallInt;
      HugeIntegerArray = array[0..High(Integer) div SizeOf(Integer) - 1] of Integer;
      HugeInt64Array = array[0..High(Integer) div SizeOf(Int64) - 1] of Int64;
      HugeNativeIntArray = array[0..High(Integer) div SizeOf(NativeInt) - 1] of NativeInt;

      HugeNativeArray = HugeNativeUIntArray;
      HugeTPointArray = array[0..High(Integer) div SizeOf(TPoint) - 1] of TPoint;
      HugeSingleArray = array[0..High(Integer) div SizeOf(Single) - 1] of Single;
      HugeDoubleArray = array[0..High(Integer) div SizeOf(Double) - 1] of Double;
      HugeExtendedArray = array[0..High(Integer) div SizeOf(Extended) - 1] of Extended;

      TLMemory = packed record
        case Integer of
          0: (LBytes: HugeByteArray);
          1: (LWords: HugeWordArray);
          2: (LCardinals: HugeCardinalArray);
          3: (LNatives: HugeNativeArray);
          4: (L1: array[1..1] of Byte;
            case Integer of
              0: (LWords1: HugeWordArray);
              1: (LCardinals1: HugeCardinalArray);
              2: (LNatives1: HugeNativeArray);
              );
          5: (L2: array[1..2] of Byte;
            case Integer of
              0: (LCardinals2: HugeCardinalArray);
              1: (LNatives2: HugeNativeArray);
              );
          6: (L3: array[1..3] of Byte;
            case Integer of
              0: (LCardinals3: HugeCardinalArray);
              1: (LNatives3: HugeNativeArray);
              );
          {$IFDEF LARGEINT}
          7: (L4: array[1..4] of Byte; LNatives4: HugeNativeArray);
          8: (L5: array[1..5] of Byte; LNatives5: HugeNativeArray);
          9: (L6: array[1..6] of Byte; LNatives6: HugeNativeArray);
          10: (L7: array[1..7] of Byte; LNatives7: HugeNativeArray);
          {$ENDIF}
      end;
      PLMemory = ^TLMemory;

      TRMemory = packed record
        case Integer of
          0: (RBytes: HugeByteArray);
          1: (RWords: HugeWordArray);
          2: (RCardinals: HugeCardinalArray);
          3: (RNatives: HugeNativeArray);
          4: (R1: array[1..1] of Byte;
            case Integer of
              0: (RWords1: HugeWordArray);
              1: (RCardinals1: HugeCardinalArray);
              2: (RNatives1: HugeNativeArray);
              );
          5: (R2: array[1..2] of Byte;
            case Integer of
              0: (RCardinals2: HugeCardinalArray);
              1: (RNatives2: HugeNativeArray);
              );
          6: (R3: array[1..3] of Byte;
            case Integer of
              0: (RCardinals3: HugeCardinalArray);
              1: (RNatives3: HugeNativeArray);
              );
          {$IFDEF LARGEINT}
          7: (R4: array[1..4] of Byte; RNatives4: HugeNativeArray);
          8: (R5: array[1..5] of Byte; RNatives5: HugeNativeArray);
          9: (R6: array[1..6] of Byte; RNatives6: HugeNativeArray);
          10: (R7: array[1..7] of Byte; RNatives7: HugeNativeArray);
          {$ENDIF}
      end;
      PRMemory = ^TRMemory;

      TSortHelper<T> = record
        Pivot: T;
        Temp: T;
        Inst: Pointer;
        Compare: function(Inst: Pointer; const Left, Right: T): Integer;

        procedure Init(const Comparer: IComparer<T>); overload;
        procedure Init(const Comparison: TComparison<T>); overload;
        procedure Init; overload;
        procedure FillZero;
      end;

      TFloat = packed record
        case Integer of
          0: (VSingle: Single);
          1: (VDouble: Double);
          2: (VExtended: Extended);
          3: (SSingle: Integer);
          4: (B1: array[1..SizeOf(Double) - SizeOf(Integer)] of Byte; SDouble: Integer);
          5: (B2: array[1..SizeOf(Extended) - SizeOf(Integer)] of Byte; SExtended: Integer);
      end;

      TSortPivot = packed record
        case Integer of
          0: (Ptr: Pointer);
          1: (Data: array[0..BUFFER_SIZE - 1] of Byte);
      end;

      TSearchHelper = record
        Count: NativeInt;
        Comparer: Pointer;
      end;

      TInternalSearchStored = record
        X: NativeUInt;
        ItemPtr: Pointer;
      end;

      TInternalSearchStored<T> = record
        Inst: Pointer;
        Compare: function(const Inst: Pointer; const Left, Right: T): Integer;
        Count: NativeInt;
      end;
  protected
    {$IFDEF WEAKREF}
    class procedure WeakExchange<T>(const Left, Right: Pointer); static;
    class procedure WeakReverse<T>(const Values: Pointer; const Count: NativeInt); static;
    {$ENDIF}
    class procedure CheckArrays(Source, Destination: Pointer; SourceIndex, SourceLength, DestIndex, DestLength, Count:
      NativeInt); static;
    class function MedianOfThree<T>(var A, B, C: T; Comparer: IComparer<T>): T; static; {$IFDEF HAS_INLINE} inline;
      {$ENDIF}
    class function SortItemPivot<T>(const I, J: Pointer): Pointer; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class function SortItemNext<T>(const StackItem, I, J: Pointer): Pointer; static; {$IFDEF HAS_INLINE} inline;
      {$ENDIF}
    class function SortItemCount<T>(const I, J: Pointer): NativeInt; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class function SortBinaryMarker<T>(const Binary: Pointer): NativeUInt; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}

    class procedure SortSigneds<T>(const Values: Pointer; const Count: NativeInt); static;
    class procedure SortDescendingSigneds<T>(const Values: Pointer; const Count: NativeInt); static;
    class procedure SortUnsigneds<T>(const Values: Pointer; const Count: NativeInt); static;
    class procedure SortDescendingUnsigneds<T>(const Values: Pointer; const Count: NativeInt); static;
    class procedure SortFloats<T>(const Values: Pointer; const Count: NativeInt); static;
    class procedure SortDescendingFloats<T>(const Values: Pointer; const Count: NativeInt); static;
    class procedure SortBinaries<T>(const Values: Pointer; const Count: NativeInt; var PivotBig: T); static;
    class procedure SortDescendingBinaries<T>(const Values: Pointer; const Count: NativeInt; var PivotBig: T); static;

    {$IFDEF WEAKREF}
    class procedure WeakSortUniversals<T>(const Values: Pointer; const Count: NativeInt; var aHelper: TSortHelper<T>);
      static;
    class procedure WeakSortDescendingUniversals<T>(const Values: Pointer; const Count: NativeInt; var aHelper:
      TSortHelper<T>); static;
    {$ENDIF}
    class procedure SortUniversals<T>(const Values: Pointer; const Count: NativeInt; var aHelper: TSortHelper<T>);
      static;
    class procedure SortDescendingUniversals<T>(const Values: Pointer; const Count: NativeInt; var aHelper:
      TSortHelper<T>); static;

    class function SearchSigneds<T>(Values: Pointer; Count: NativeInt; Item: Pointer): NativeInt; static;
    class function SearchUnsigneds<T>(Values: Pointer; Count: NativeInt; Item: Pointer): NativeInt; static;
    class function SearchFloats<T>(Values: Pointer; Count: NativeInt; Item: Pointer): NativeInt; static;
    class function SearchBinaries<T>(Values: Pointer; Count: NativeInt; const Item: T): NativeInt; static;

    class function SearchDescendingSigneds<T>(Values: Pointer; Count: NativeInt; Item: Pointer): NativeInt; static;
    class function SearchDescendingUnsigneds<T>(Values: Pointer; Count: NativeInt; Item: Pointer): NativeInt; static;
    class function SearchDescendingFloats<T>(Values: Pointer; Count: NativeInt; Item: Pointer): NativeInt; static;
    class function SearchDescendingBinaries<T>(Values: Pointer; Count: NativeInt; const Item: T): NativeInt; static;
    class function SearchUniversals<T>(Values: Pointer; const helper: TSearchHelper; const Item: T): NativeInt; static;
    class function SearchDescendingUniversals<T>(Values: Pointer; const helper: TSearchHelper; const Item: T):
      NativeInt; static;

    class function InternalSearch<T>(Values: Pointer; Index, Count: Integer; const Item: T;
      out FoundIndex: Integer): Boolean; overload; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class function InternalSearch<T>(Values: Pointer; Index, Count: Integer; const Item: T;
      out FoundIndex: Integer; Comparer: Pointer): Boolean; overload; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class function InternalSearchDescending<T>(Values: Pointer; Index, Count: Integer; const Item: T;
      out FoundIndex: Integer): Boolean; overload; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class function InternalSearchDescending<T>(Values: Pointer; Index, Count: Integer; const Item: T;
      out FoundIndex: Integer; Comparer: Pointer): Boolean; overload; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
  public
    class procedure Exchange<T>(const Left, Right: Pointer); static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class procedure Copy<T>(const Destination, Source: Pointer); overload; static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class procedure FillZero<T>(const Values: Pointer); static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class procedure Reverse<T>(const Values: Pointer; const Count: NativeInt); overload; static;
    class procedure Reverse<T>(var Values: array of T); overload; static;
    class procedure Copy<T>(const Source: array of T; var Destination: array of T; SourceIndex, DestIndex, Count:
      NativeInt); overload; static;
    class procedure Copy<T>(const Source: array of T; var Destination: array of T; Count: NativeInt); overload; static;
    class function Copy<T>(const Source: array of T; SourceIndex, Count: NativeInt): TArray<T>; overload; static;
    class function Copy<T>(const Source: array of T): TArray<T>; overload; static;

    class procedure Sort<T>(var Values: T; const Count: Integer); overload; static;
    class procedure Sort<T>(var Values: T; const Count: Integer; const Comparer: IComparer<T>); overload; static;
    class procedure Sort<T>(var Values: T; const Count: Integer; const Comparison: TComparison<T>); overload; static;
    class procedure Sort<T>(var Values: array of T); overload; static;
    class procedure Sort<T>(var Values: array of T; const Comparer: IComparer<T>); overload; static;
    class procedure Sort<T>(var Values: array of T; const Comparer: IComparer<T>; Index, Count: Integer); overload;
      static;
    class procedure Sort<T>(var Values: array of T; const Comparison: TComparison<T>); overload; static;
    class procedure Sort<T>(var Values: array of T; Index, Count: Integer; const Comparison: TComparison<T>); overload;
      static;

    class procedure SortDescending<T>(var Values: T; const Count: Integer); overload; static;
    class procedure SortDescending<T>(var Values: T; const Count: Integer; const Comparer: IComparer<T>); overload;
      static;
    class procedure SortDescending<T>(var Values: T; const Count: Integer; const Comparison: TComparison<T>); overload;
      static;
    class procedure SortDescending<T>(var Values: array of T); overload; static;
    class procedure SortDescending<T>(var Values: array of T; const Comparer: IComparer<T>); overload; static;
    class procedure SortDescending<T>(var Values: array of T; const Comparer: IComparer<T>; Index, Count: Integer);
      overload; static;
    class procedure SortDescending<T>(var Values: array of T; const Comparison: TComparison<T>); overload; static;
    class procedure SortDescending<T>(var Values: array of T; Index, Count: Integer; const Comparison: TComparison<T>);
      overload; static;

    class function BinarySearch<T>(var Values: T; const Item: T; out FoundIndex: Integer; Count: Integer): Boolean;
      overload; static;
    class function BinarySearch<T>(const Values: array of T; const Item: T; out FoundIndex: Integer): Boolean; overload;
      static;
    class function BinarySearch<T>(const Values: array of T; const Item: T; out FoundIndex: Integer;
      Index, Count: Integer): Boolean; overload; static;

    class function BinarySearch<T>(var Values: T; const Item: T; out FoundIndex: Integer; Count: Integer; const
      Comparer: IComparer<T>): Boolean; overload; static;
    class function BinarySearch<T>(const Values: array of T; const Item: T; out FoundIndex: Integer; const Comparer:
      IComparer<T>): Boolean; overload; static;
    class function BinarySearch<T>(const Values: array of T; const Item: T; out FoundIndex: Integer; const Comparer:
      IComparer<T>;
      Index, Count: Integer): Boolean; overload; static;
    class function BinarySearch<T>(var Values: T; const Item: T; out FoundIndex: Integer; Count: Integer; const
      Comparison: TComparison<T>): Boolean; overload; static;
    class function BinarySearch<T>(const Values: array of T; const Item: T; out FoundIndex: Integer; const Comparison:
      TComparison<T>): Boolean; overload; static;
    class function BinarySearch<T>(const Values: array of T; const Item: T; out FoundIndex: Integer;
      Index, Count: Integer; const Comparison: TComparison<T>): Boolean; overload; static;

    class function BinarySearchDescending<T>(var Values: T; const Item: T; out FoundIndex: Integer; Count: Integer):
      Boolean; overload; static;
    class function BinarySearchDescending<T>(const Values: array of T; const Item: T; out FoundIndex: Integer): Boolean;
      overload; static;
    class function BinarySearchDescending<T>(const Values: array of T; const Item: T; out FoundIndex: Integer;
      Index, Count: Integer): Boolean; overload; static;

    class function BinarySearchDescending<T>(var Values: T; const Item: T; out FoundIndex: Integer; Count: Integer;
      const Comparer: IComparer<T>): Boolean; overload; static;
    class function BinarySearchDescending<T>(const Values: array of T; const Item: T; out FoundIndex: Integer; const
      Comparer: IComparer<T>): Boolean; overload; static;
    class function BinarySearchDescending<T>(const Values: array of T; const Item: T; out FoundIndex: Integer; const
      Comparer: IComparer<T>;
      Index, Count: Integer): Boolean; overload; static;
    class function BinarySearchDescending<T>(var Values: T; const Item: T; out FoundIndex: Integer; Count: Integer;
      const Comparison: TComparison<T>): Boolean; overload; static;
    class function BinarySearchDescending<T>(const Values: array of T; const Item: T; out FoundIndex: Integer; const
      Comparison: TComparison<T>): Boolean; overload; static;
    class function BinarySearchDescending<T>(const Values: array of T; const Item: T; out FoundIndex: Integer;
      Index, Count: Integer; const Comparison: TComparison<T>): Boolean; overload; static;
    class function IndexOf<T>(const Values: array of T; const Item: T): Integer; static;
    class function Contains<T>(const Values: array of T; const Item: T): Boolean; static;
  end;

{ Collection and lightweight optimized enumerator routine }

  TCollectionEnumeratorData<T> = record
    {$IFDEF AUTOREFCOUNT} [Unsafe]{$ENDIF}Owner: TObject;
    Current: T;
    Tag: NativeInt;
    Reserved: NativeInt;
    procedure Init(const AOwner: TObject); {$IFDEF HAS_INLINE} inline; {$ENDIF}
  end;

  TCollectionEnumerator<T> = record
    Data: TCollectionEnumeratorData<T>;
    Intf: IInterface;
    DoMoveNext: function(var AData: TCollectionEnumeratorData<T>): Boolean;
    property Current: T read Data.Current;
    function MoveNext: Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
  end;

  ICollection<T> = interface(ICustomObject)
    function GetCount: Integer;
    function GetEnumerator: TCollectionEnumerator<T>;
    function ToArray: TArray<T>;
    property Count: Integer read GetCount;
  end;

  TCollection<T> = class(TCustomObject, ICollection<T>)
{ public
    type
      TEnumerator = record
        Data: TCollectionEnumeratorData<T>;
        property Current: T read Data.Current;
        function MoveNext: Boolean;
      end;

    function GetEnumerator: TEnumerator; }
  protected
    function ICollection<T>.GetCount = DoGetCount;
    function ICollection<T>.GetEnumerator = DoGetEnumerator;
    function DoGetCount: Integer; virtual; abstract;
    function DoGetEnumerator: TCollectionEnumerator<T>; virtual; abstract;
  public
    function ToArray: TArray<T>; virtual; abstract;
  end;

{ TCustomDictionary<TKey,TValue> class
  Basic class for TDictionary<TKey,TValue>, TRapidDictionary<TKey,TValue> }

  TCustomDictionary<TKey, TValue> = class(TCollection < TPair<TKey, TValue> > )
  public
    type
      PItem = ^TItem;
      TItem = packed record
      private
        FKey: TKey;
        FValue: TValue;
        FNext: PItem;
        FHashCode: Integer;
      public
        property Key: TKey read FKey;
        property Value: TValue read FValue write FValue;
        property HashCode: Integer read FHashCode;
      end;
      TItemList = array[0..0] of TItem;
      PItemList = ^TItemList;

      TPairEnumerator = record
        Data: TCollectionEnumeratorData < TPair<TKey, TValue> > ;
        property Current: TPair<TKey, TValue>read Data.Current;
        function MoveNext: Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
      end;

      TKeyEnumerator = record
        Data: TCollectionEnumeratorData<TKey>;
        property Current: TKey read Data.Current;
        function MoveNext: Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
      end;

      TValueEnumerator = record
        Data: TCollectionEnumeratorData<TValue>;
        property Current: TValue read Data.Current;
        function MoveNext: Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
      end;

      TKeyCollection = class(TCollection<TKey>)
      protected
        {$IFDEF AUTOREFCOUNT} [Unsafe]{$ENDIF}FDictionary: TCustomDictionary<TKey, TValue>;
        function DoGetCount: Integer; override;
        function GetCount: Integer; {$IFDEF HAS_INLINE} inline; {$ENDIF}
        function DoGetEnumerator: TCollectionEnumerator<TKey>; override;
      public
        constructor Create(const ADictionary: TCustomDictionary<TKey, TValue>);
        function GetEnumerator: TKeyEnumerator;
        function ToArray: TArray<TKey>; override; final;
        property Count: Integer read GetCount;
      end;

      TValueCollection = class(TCollection<TValue>)
      protected
        {$IFDEF AUTOREFCOUNT} [Unsafe]{$ENDIF}FDictionary: TCustomDictionary<TKey, TValue>;
        function DoGetCount: Integer; override;
        function GetCount: Integer; {$IFDEF HAS_INLINE} inline; {$ENDIF}
        function DoGetEnumerator: TCollectionEnumerator<TValue>; override;
      public
        constructor Create(const ADictionary: TCustomDictionary<TKey, TValue>);
        function GetEnumerator: TValueEnumerator;
        function ToArray: TArray<TValue>; override; final;
        property Count: Integer read GetCount;
      end;
  private
    type
      PKey = ^TKey;
      PValue = ^TValue;
      THashList = array[0..0] of PItem;
      PHashList = ^THashList;
      TData16 = TRAIIHelper.TData16;
      PData16 = ^TData16;
      TKeyRec = TRAIIHelper.TData16;
      PKeyRec = ^TKeyRec;
      TValueRec = TRAIIHelper.TData16<TKey>;
      PValueRec = ^TValueRec;
  protected
    FItems: PItemList;
    FCapacity: NativeInt;
    FHashTable: TArray<PItem>;
    FHashTableMask: NativeInt;
    FCount: TRAIIHelper.TNativeIntRec;
    FKeyCollection: TKeyCollection;
    FValueCollection: TValueCollection;

    // rehash
    procedure Rehash(NewTableCount: NativeInt);
    procedure SetCapacity(ACapacity: NativeInt);
    function Grow: TCustomDictionary<TKey, TValue>;

    // items
    function NewItem: Pointer {PItem};
    procedure DisposeItem(Item: Pointer {PItem});
    procedure DoCleanupItems(Item: PItem; Count: NativeInt); virtual;

    // enumerators
    function DoGetCount: Integer; override;
    function DoGetEnumerator: TCollectionEnumerator<TPair<TKey, TValue>>; override;
    function InitKeyCollection: TKeyCollection{$IFDEF AUTOREFCOUNT}unsafe{$ENDIF};
    function InitValueCollection: TValueCollection{$IFDEF AUTOREFCOUNT}unsafe{$ENDIF};
    function GetKeys: TKeyCollection{$IFDEF AUTOREFCOUNT}unsafe{$ENDIF}; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function GetValues: TValueCollection{$IFDEF AUTOREFCOUNT}unsafe{$ENDIF}; {$IFDEF HAS_INLINE} inline; {$ENDIF}

    // helpers
    class function IntfMethod(Intf: Pointer; MethodNum: NativeUInt = 3): TMethod; {$IFDEF HAS_INLINE} inline; {$ENDIF}
      static;
    class procedure ClearMethod(var Method); {$IFDEF HAS_INLINE} inline; {$ENDIF} static;
  protected
    FOnKeyNotify: TCollectionNotifyEvent<TKey>;
    FOnValueNotify: TCollectionNotifyEvent<TValue>;
    FInternalKeyNotify: TCollectionNotifyEvent<TKey>;
    FInternalValueNotify: TCollectionNotifyEvent<TValue>;
    FInternalItemNotify: procedure(const Item: TItem; Action: TCollectionNotification) of object;

    procedure SetKeyNotify(const Value: TCollectionNotifyEvent<TKey>);
    procedure SetValueNotify(const Value: TCollectionNotifyEvent<TValue>);
    procedure KeyNotify(const Key: TKey; Action: TCollectionNotification); virtual;
    procedure ValueNotify(const Value: TValue; Action: TCollectionNotification); virtual;
    procedure KeyNotifyCaller(Sender: TObject; const Item: TKey; Action: TCollectionNotification);
    procedure ValueNotifyCaller(Sender: TObject; const Item: TValue; Action: TCollectionNotification);
    procedure ItemNotifyCaller(const Item: TItem; Action: TCollectionNotification);
    procedure ItemNotifyEvents(const Item: TItem; Action: TCollectionNotification);
    procedure ItemNotifyKey(const Item: TItem; Action: TCollectionNotification);
    procedure ItemNotifyValue(const Item: TItem; Action: TCollectionNotification);
    procedure SetNotifyMethods; virtual;

    property List: PItemList read FItems;
  protected
    const
      FOUND_NONE = 0;
      FOUND_EXCEPTION = 1;
      FOUND_DELETE = 2;
      FOUND_REPLACE = 3;
      FOUND_MASK = 3;

      EMPTY_NONE = 0 shl 2;
      EMPTY_EXCEPTION = 1 shl 2;
      EMPTY_NEW = 2 shl 2;
      EMPTY_MASK = 3 shl 2;
  protected
    FInternalFindValue: ^TValue;
    FDefaultValue: TValue;
  public
    constructor Create(ACapacity: Integer = 0);
    destructor Destroy; override;
    procedure Clear;
    procedure TrimExcess;
    function ContainsValue(const Value: TValue): Boolean;

    function GetEnumerator: TPairEnumerator;
    function ToArray: TArray<TPair<TKey, TValue>>; override; final;

    property Keys: TKeyCollection read GetKeys;
    property Values: TValueCollection read GetValues;
  end;

{ TDictionary<TKey,TValue>
  System.Generics.Collections equivalent

  Included 3 members:
    function Find(const Key: TKey): PItem;
    function FindOrAdd(const Key: TKey): PItem;
    property List: PItemList read FItems; }

  TDictionary<TKey, TValue> = class(TCustomDictionary<TKey, TValue>)
  private
    type
      TInternalFindStored = record
        HashCode: Integer;
        Parent: Pointer;
      end;
  protected
    FComparer: IEqualityComparer<TKey>;
    FComparerEquals: function(const Left, Right: TKey): Boolean of object;
    FComparerGetHashCode: function(const Value: TKey): Integer of object;

    function InternalFindItem(const Key: TKey; const FindMode: Integer): Pointer {Pitem};
    function GetItem(const Key: TKey): TValue;
    procedure SetItem(const Key: TKey; const Value: TValue);
  public
    constructor Create(ACapacity: Integer = 0); overload;
    constructor Create(const AComparer: IEqualityComparer<TKey>); overload;
    constructor Create(ACapacity: Integer; const AComparer: IEqualityComparer<TKey>); overload;
    constructor Create(const Collection: TEnumerable < TPair<TKey, TValue> > ); overload;
    constructor Create(const Collection: TEnumerable < TPair<TKey, TValue> > ; const AComparer:
      IEqualityComparer<TKey>); overload;
    destructor Destroy; override;

    function Find(const Key: TKey): Pointer {PItem};
    function FindOrAdd(const Key: TKey): Pointer {PItem};
    procedure Add(const Key: TKey; const Value: TValue);
    function TryAdd(const Key: TKey; const Value: TValue): Boolean;
    procedure Remove(const Key: TKey);
    function ExtractPair(const Key: TKey): TPair<TKey, TValue>;
    function TryGetValue(const Key: TKey; out Value: TValue): Boolean;
    procedure AddOrSetValue(const Key: TKey; const Value: TValue);
    function ContainsKey(const Key: TKey): Boolean;

    property Items[const Key: TKey]: TValue read GetItem write SetItem; default;
    property List;
    property Count: Integer read FCount.Int;
    property OnKeyNotify: TCollectionNotifyEvent<TKey>read FOnKeyNotify write SetKeyNotify;
    property OnValueNotify: TCollectionNotifyEvent<TValue>read FOnValueNotify write SetValueNotify;
  end;

{ TRapidDictionary<TKey,TValue> class
  Rapid "inline" TDictionary equivalent with default hash code and comparer }

  TRapidDictionary<TKey, TValue> = class(TCustomDictionary<TKey, TValue>)
  private
    type
      TInternalFindStored = record
        HashCode: Integer;
        Parent: Pointer;
        Self: TRapidDictionary<TKey, TValue>;
        case Integer of
          0: (SingleRec: packed record
              Exponent: Integer;
              case Integer of
                0: (Mantissa: Single);
                1: (HighInt: Integer);
            end);
          1: (DoubleRec: packed record
              Exponent: Integer;
              case Integer of
                0: (Mantissa: Double);
                1: (LowInt: Integer; HighInt: Integer);
            end);
          2: (ExtendedRec: packed record
              Exponent: Integer;
              case Integer of
                0: (Mantissa: Extended);
                1: (LowInt: Integer; Middle: Word; HighInt: Integer);
            end);
      end;
  protected
    function InternalFindItem(const Key: TKey; const FindMode: Integer): TCustomDictionary<TKey, TValue>.Pitem;
    function GetItem(const Key: TKey): TValue; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure SetItem(const Key: TKey; const Value: TValue); {$IFDEF HAS_INLINE} inline; {$ENDIF}
  public
    constructor Create(ACapacity: Integer = 0); overload;
    constructor Create(const Collection: TEnumerable < TPair<TKey, TValue> > ); overload;
    destructor Destroy; override;

    function Find(const Key: TKey): Pointer {PItem}; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function FindOrAdd(const Key: TKey): Pointer {PItem}; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure Add(const Key: TKey; const Value: TValue); {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure Remove(const Key: TKey); {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function ExtractPair(const Key: TKey): TPair<TKey, TValue>;
    function TryGetValue(const Key: TKey; out Value: TValue): Boolean;
    procedure AddOrSetValue(const Key: TKey; const Value: TValue); {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function ContainsKey(const Key: TKey): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}

    property Items[const Key: TKey]: TValue read GetItem write SetItem; default;
    property List;
    property Count: Integer read FCount.Int;
    property OnKeyNotify: TCollectionNotifyEvent<TKey>read FOnKeyNotify write SetKeyNotify;
    property OnValueNotify: TCollectionNotifyEvent<TValue>read FOnValueNotify write SetValueNotify;
  end;

{ TCustomList<T> class
  Basic class for TList<T>, TQueue<T>, TStack<T> }

  TCustomList<T> = class(TCollection<T>)
  public
    type
      TItem = T;
      PItem = ^TItem;
      TItemList = array[0..0] of TItem;
      PItemList = ^TItemList;

      TEnumerator = record
        Data: TCollectionEnumeratorData<T>;
        property Current: T read Data.Current;
        function MoveNext: Boolean;
      end;
  protected
    FItems: PItemList;
    FCapacity: TRAIIHelper.TNativeIntRec;
    FCount: TRAIIHelper.TNativeIntRec;
    FTail: NativeInt;
    FHead: NativeInt;
    FOnNotify: TCollectionNotifyEvent<T>;
    FInternalNotify: TCollectionNotifyEvent<T>;

    class procedure ClearMethod(var Method); static; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    class function EmptyException: Exception; static;
    procedure SetCapacity(Value: Integer);
    procedure Grow;
    procedure GrowTo(Value: Integer);
    procedure SetOnNotify(const Value: TCollectionNotifyEvent<T>);
    procedure Notify(const Item: T; Action: TCollectionNotification); virtual;
    procedure NotifyCaller(Sender: TObject; const Item: T; Action: TCollectionNotification);
    procedure SetNotifyMethods; virtual;
    function DoGetCount: Integer; override;
    function DoGetEnumerator: TCollectionEnumerator<T>; override;

    property List: PItemList read FItems;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure TrimExcess; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function ToArray: TArray<T>; override; final;
    function GetEnumerator: TEnumerator;
    function IsEmpty: Boolean;

    property Count: Integer read FCount.Int;
    property Capacity: Integer read FCapacity.Int write SetCapacity;
    property OnNotify: TCollectionNotifyEvent<T>read FOnNotify write SetOnNotify;
  end;

{ TList<T>
  System.Generics.Collections equivalent }

  TList<T> = class(TCustomList<T>)
  private
    type
      TData16 = TRAIIHelper.TData16;
      PData16 = ^TData16;
      TCompare = function(Inst: Pointer; const Left, Right: T): Integer;
      TEquals = function(Inst: Pointer; const Left, Right: T): Boolean;
      TInternalStored = packed record
        Self: Pointer;
        InternalNotify: TMethod;
        Count: NativeInt;
        Item: TCustomList<T>.PItem;
        ACount: Integer;
      end;
      TComparerInst = packed record
        Vtable: Pointer;
        Method: TMethod;
        QueryInterface,
          AddRef,
          Release,
          Call: Pointer;
      end;
  public
    type
      TDirection = System.Types.TDirection;
    TEmptyFunc = reference to function(const L, R: T): Boolean;
    TListCompareFunc = reference to function(const L, R: T): Integer;
  protected
    FComparer: IComparer<T>;

    function GetItem(Index: Integer): T; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure ReplaceItemNotify(Index: Integer; const Value: T);
    procedure SetItem(Index: Integer; const Value: T); {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function ItemValue(const Item: T): NativeInt;
    {$IFDEF WEAKREF}
    class procedure InternalWeakInsert(const Item: Pointer; const ItemsCount, InsertCount: NativeUInt); static;
    {$ENDIF}
    function InternalInsert(Index: NativeInt; const Value: T): Integer;
    procedure InternalDelete(Index: NativeInt; Action: TCollectionNotification);
    procedure SetCount(Value: Integer);
    procedure InternalMove(CurIndex, NewIndex: Integer);
    procedure InternalMove40(CurIndex, NewIndex: Integer);
    function InternalIndexOf(const Value: T): NativeInt; overload;
    function InternalIndexOf(const Value: T; const Comparer: IComparer<T>): NativeInt; overload;
    function InternalIndexOfRev(const Value: T): NativeInt; overload;
    function InternalIndexOfRev(const Value: T; const Comparer: IComparer<T>): NativeInt; overload;
    {$IFDEF WEAKREF}
    procedure InternalWeakPack; overload;
    procedure InternalWeakPack(const IsEmpty: TEmptyFunc); overload;
    procedure InternalWeakPackComparer;
    {$ENDIF}
    procedure InternalPackDifficults;
    procedure InternalPackComparer;
  public
    constructor Create; overload;
    constructor Create(const AComparer: IComparer<T>); overload;
    constructor Create(const Collection: TEnumerable<T>); overload;

    class procedure Error(const Msg: string; Data: NativeInt); overload; virtual;
    {$IFNDEF NEXTGEN}
    class procedure Error(Msg: PResStringRec; Data: NativeInt); overload;
    {$ENDIF}

    function First: T; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function Last: T; {$IFDEF HAS_INLINE} inline; {$ENDIF}

    function Add(const Value: T): Integer; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure AddRange(const Values: array of T); overload;
    procedure AddRange(const Collection: IEnumerable<T>); overload;
    procedure AddRange(const Collection: TEnumerable<T>); overload;
    procedure AddRange(const AList: TList<T>); overload;
      // this provides a compatible way to copy a TList<T> as System.Generics.Collections is able to do

    procedure Insert(Index: Integer; const Value: T); {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure InsertRange(Index: Integer; const Values: array of T); overload;
    procedure InsertRange(Index: Integer; const Collection: IEnumerable<T>); overload;
    procedure InsertRange(Index: Integer; const Collection: TEnumerable<T>); overload;

    procedure Delete(Index: Integer); {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure DeleteRange(AIndex, ACount: Integer);

    function Expand: TList<T>; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure Exchange(Index1, Index2: Integer);
    procedure Move(CurIndex, NewIndex: Integer); {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure Reverse; {$IFDEF HAS_INLINE} inline; {$ENDIF}

    procedure Sort; overload;
    procedure Sort(const AComparer: IComparer<T>); overload;
    procedure Sort(const AComparison: TComparison<T>); overload;
    procedure Sort(Index, ACount: Integer); overload;
    procedure Sort(Index, ACount: Integer; const AComparer: IComparer<T>); overload;
    procedure Sort(Index, ACount: Integer; const AComparison: TComparison<T>); overload;
    procedure SortDescending; overload;
    procedure SortDescending(const AComparer: IComparer<T>); overload;
    procedure SortDescending(const AComparison: TComparison<T>); overload;
    procedure SortDescending(Index, ACount: Integer); overload;
    procedure SortDescending(Index, ACount: Integer; const AComparer: IComparer<T>); overload;
    procedure SortDescending(Index, ACount: Integer; const AComparison: TComparison<T>); overload;

    function BinarySearch(const Item: T; out FoundIndex: Integer): Boolean; overload;
    function BinarySearch(const Item: T; out FoundIndex: Integer; const AComparer: IComparer<T>): Boolean; overload;
    function BinarySearch(const Item: T; out FoundIndex: Integer; const AComparison: TComparison<T>): Boolean;
      overload;
    function BinarySearch(const Item: T; out FoundIndex: Integer; Index, ACount: Integer): Boolean; overload;
    function BinarySearch(const Item: T; out FoundIndex: Integer; const AComparer: IComparer<T>; Index, ACount:
      Integer): Boolean; overload;
    function BinarySearch(const Item: T; out FoundIndex: Integer; Index, ACount: Integer; const AComparison:
      TComparison<T>): Boolean; overload;
    function BinarySearchDescending(const Item: T; out FoundIndex: Integer): Boolean; overload;
    function BinarySearchDescending(const Item: T; out FoundIndex: Integer; const AComparer: IComparer<T>): Boolean;
      overload;
    function BinarySearchDescending(const Item: T; out FoundIndex: Integer; const AComparison: TComparison<T>): Boolean;
      overload;
    function BinarySearchDescending(const Item: T; out FoundIndex: Integer; Index, ACount: Integer): Boolean; overload;
    function BinarySearchDescending(const Item: T; out FoundIndex: Integer; const AComparer: IComparer<T>; Index,
      ACount: Integer): Boolean; overload;
    function BinarySearchDescending(const Item: T; out FoundIndex: Integer; Index, ACount: Integer; const AComparison:
      TComparison<T>): Boolean; overload;

    function Contains(const Value: T): Boolean; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function IndexOf(const Value: T): Integer; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function IndexOfItem(const Value: T; Direction: TDirection): Integer; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function LastIndexOf(const Value: T): Integer; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function Remove(const Value: T): Integer;
    function RemoveItem(const Value: T; Direction: TDirection): Integer;
    function Extract(const Value: T): T;
    function ExtractItem(const Value: T; Direction: TDirection): T;
    function ExtractAt(Index: Integer): T;

    procedure Pack; overload;
    procedure Pack(const IsEmpty: TEmptyFunc); overload;

    property Count: Integer read FCount.Int write SetCount;
    property Items[Index: Integer]: T read GetItem write SetItem; default;
    property List;
  end;

{ TStack<T>
  System.Generics.Collections equivalent }

  TStack<T> = class(TCustomList<T>)
  protected
    procedure InternalPush(const Value: T);
    function InternalPop(const Action: TCollectionNotification): T;
  public
    constructor Create; overload;
    constructor Create(const Collection: TEnumerable<T>); overload;

    procedure Push(const Value: T); {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function Pop: T; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function Extract: T; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function Peek: T; {$IFDEF HAS_INLINE} inline; {$ENDIF}
  end;

{ TQueue<T>
  System.Generics.Collections equivalent }

  TQueue<T> = class(TCustomList<T>)
  protected
    procedure InternalEnqueue(const Value: T);
    function InternalDequeue(const Action: TCollectionNotification): T;
  public
    constructor Create; overload;
    constructor Create(const Collection: TEnumerable<T>); overload;

    procedure Enqueue(const Value: T); {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function Dequeue: T; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function Extract: T; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    function Peek: T; {$IFDEF HAS_INLINE} inline; {$ENDIF}
  end;

{ TThreadList, TThreadedQueue classes
  Deprected synchronized routine }

  TThreadList<T> = class(TCustomObject)
  private
    FList: TList<T>;
    FLock: TObject;
    FDuplicates: TDuplicates;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Item: T);
    procedure Clear;
    function LockList: TList<T>;
    procedure Remove(const Item: T); {$IFDEF HAS_INLINE} inline; {$ENDIF}
    procedure RemoveItem(const Item: T; Direction: TDirection);
    procedure UnlockList; {$IFDEF HAS_INLINE} inline; {$ENDIF}
    property Duplicates: TDuplicates read FDuplicates write FDuplicates;
  end;

  TThreadedQueue<T> = class(TCustomObject)
  private
    FQueue: array of T;
    FQueueSize, FQueueOffset: Integer;
    FQueueNotEmpty,
      FQueueNotFull: TObject;
    FQueueLock: TObject;
    FShutDown: Boolean;
    FPushTimeout, FPopTimeout: LongWord;
    FTotalItemsPushed, FTotalItemsPopped: LongWord;
  public
    constructor Create(AQueueDepth: Integer = 10; PushTimeout: LongWord = INFINITE; PopTimeout: LongWord = INFINITE);
    destructor Destroy; override;

    procedure Grow(ADelta: Integer);
    function PushItem(const AItem: T): TWaitResult; overload;
    function PushItem(const AItem: T; var AQueueSize: Integer): TWaitResult; overload;
    function PopItem: T; overload;
    function PopItem(var AQueueSize: Integer): T; overload;
    function PopItem(var AQueueSize: Integer; var AItem: T): TWaitResult; overload;
    function PopItem(var AItem: T): TWaitResult; overload;
    procedure DoShutDown;

    property QueueSize: Integer read FQueueSize;
    property ShutDown: Boolean read FShutDown;
    property TotalItemsPushed: LongWord read FTotalItemsPushed;
    property TotalItemsPopped: LongWord read FTotalItemsPopped;
  end;

{  TObjectList, TObjectStack, TObjectDictionary, TRapidObjectDictionary
   Class-oriented containers }

  TObjectList<T: class> = class(TList<T>)
  protected
    FOwnsObjects: Boolean;
    procedure SetOwnsObjects(const Value: Boolean);
    procedure DisposeNotifyCaller(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
    procedure DisposeNotifyEvent(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
    procedure DisposeOnly(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
    procedure SetNotifyMethods; override;
  public
    constructor Create(AOwnsObjects: Boolean = True); overload;
    constructor Create(const AComparer: IComparer<T>; AOwnsObjects: Boolean = True); overload;
    constructor Create(const Collection: TEnumerable<T>; AOwnsObjects: Boolean = True); overload;
    property OwnsObjects: Boolean read FOwnsObjects write SetOwnsObjects;
  end;

  TObjectStack<T: class> = class(TStack<T>)
  protected
    FOwnsObjects: Boolean;
    procedure SetOwnsObjects(const Value: Boolean);
    procedure DisposeNotifyCaller(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
    procedure DisposeNotifyEvent(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
    procedure DisposeOnly(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
    procedure SetNotifyMethods; override;
  public
    constructor Create(AOwnsObjects: Boolean = True); overload;
    constructor Create(const Collection: TEnumerable<T>; AOwnsObjects: Boolean = True); overload;
    property OwnsObjects: Boolean read FOwnsObjects write SetOwnsObjects;
  end;

  TObjectQueue<T: class> = class(TQueue<T>)
  protected
    FOwnsObjects: Boolean;
    procedure SetOwnsObjects(const Value: Boolean);
    procedure DisposeNotifyCaller(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
    procedure DisposeNotifyEvent(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
    procedure DisposeOnly(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
    procedure SetNotifyMethods; override;
  public
    constructor Create(AOwnsObjects: Boolean = True); overload;
    constructor Create(const Collection: TEnumerable<T>; AOwnsObjects: Boolean = True); overload;
    procedure Dequeue;
    property OwnsObjects: Boolean read FOwnsObjects write SetOwnsObjects;
  end;

  TDictionaryOwnerships = set of (doOwnsKeys, doOwnsValues);

  TObjectDictionary<TKey, TValue> = class(TDictionary<TKey, TValue>)
  public
    type
      TItem = TCustomDictionary<TKey, TValue>.TItem;
  private
    type
      TOnKeyNotify = procedure(Data, Sender: TObject; const Key: TObject; Action: TCollectionNotification);
      TOnValueNotify = procedure(Data, Sender: TObject; const Value: TObject; Action: TCollectionNotification);
  protected
    FOwnerships: TDictionaryOwnerships;
    procedure DisposeKeyNotifyCaller(Sender: TObject; const Key: TKey; Action: TCollectionNotification);
    procedure DisposeKeyEvent(Sender: TObject; const Key: TObject; Action: TCollectionNotification);
    procedure DisposeKeyOnly(Sender: TObject; const Key: TObject; Action: TCollectionNotification);
    procedure DisposeValueNotifyCaller(Sender: TObject; const Value: TValue; Action: TCollectionNotification);
    procedure DisposeValueEvent(Sender: TObject; const Value: TObject; Action: TCollectionNotification);
    procedure DisposeValueOnly(Sender: TObject; const Value: TObject; Action: TCollectionNotification);
    procedure DisposeItemNotifyKeyCaller(const Item: TItem; Action: TCollectionNotification);
    procedure DisposeItemNotifyKeyEvent(const Item: TItem; Action: TCollectionNotification);
    procedure DisposeItemNotifyKeyOnly(const Item: TItem; Action: TCollectionNotification);
    procedure DisposeItemNotifyValueCaller(const Item: TItem; Action: TCollectionNotification);
    procedure DisposeItemNotifyValueEvent(const Item: TItem; Action: TCollectionNotification);
    procedure DisposeItemNotifyValueOnly(const Item: TItem; Action: TCollectionNotification);
    procedure SetNotifyMethods; override;
  public
    constructor Create(Ownerships: TDictionaryOwnerships; ACapacity: Integer = 0); overload;
    constructor Create(Ownerships: TDictionaryOwnerships;
      const AComparer: IEqualityComparer<TKey>); overload;
    constructor Create(Ownerships: TDictionaryOwnerships; ACapacity: Integer;
      const AComparer: IEqualityComparer<TKey>); overload;
  end;

  TRapidObjectDictionary<TKey, TValue> = class(TRapidDictionary<TKey, TValue>)
  public
    type
      TItem = TCustomDictionary<TKey, TValue>.TItem;
  private
    type
      TOnKeyNotify = procedure(Data, Sender: TObject; const Key: TObject; Action: TCollectionNotification);
      TOnValueNotify = procedure(Data, Sender: TObject; const Value: TObject; Action: TCollectionNotification);
  protected
    FOwnerships: TDictionaryOwnerships;
    procedure DisposeKeyEvent(Sender: TObject; const Key: TObject; Action: TCollectionNotification);
    procedure DisposeKeyOnly(Sender: TObject; const Key: TObject; Action: TCollectionNotification);
    procedure DisposeValueEvent(Sender: TObject; const Value: TObject; Action: TCollectionNotification);
    procedure DisposeValueOnly(Sender: TObject; const Value: TObject; Action: TCollectionNotification);
    procedure DisposeItemNotifyKeyCaller(const Item: TItem; Action: TCollectionNotification);
    procedure DisposeItemNotifyKeyEvent(const Item: TItem; Action: TCollectionNotification);
    procedure DisposeItemNotifyKeyOnly(const Item: TItem; Action: TCollectionNotification);
    procedure DisposeItemNotifyValueCaller(const Item: TItem; Action: TCollectionNotification);
    procedure DisposeItemNotifyValueEvent(const Item: TItem; Action: TCollectionNotification);
    procedure DisposeItemNotifyValueOnly(const Item: TItem; Action: TCollectionNotification);
    procedure SetNotifyMethods; override;
  public
    constructor Create(Ownerships: TDictionaryOwnerships; ACapacity: Integer = 0);
  end;

  // Declared externally so Delphi watches work
  PS1 = ^ShortInt;
  PS2 = ^SmallInt;
  PS4 = ^Integer;
  PS8 = ^Int64;

  PU1 = ^Byte;
  PU2 = ^Word;
  PU4 = ^Cardinal;
  PU8 = ^UInt64;

  PF4 = ^Single;
  PF8 = ^Double;
  PFE = ^Extended;

function ListIndexErrorMsg(AIndex, AMaxIndex: Integer; AListObjName: string = ''): string;
procedure ErrorArgumentOutOfRange; overload;
procedure ErrorArgumentOutOfRange(AIndex, AMaxIndex: NativeInt; AListObj: TObject = nil); overload;

implementation

resourcestring
  SInvalidPointerAlign = 'Invalid pointer %p align: should be %u';
  SInvalidRefCount = 'Invalid %s.RefCount value %d';
  SMethodNotSupported = 'Method %s not supported';
  SListIndexError = 'List index out of bounds (%d)';
  SListIndexErrorRangeReason = '.  %s range is 0..%d';
  SListIndexErrorEmptyReason = '.  %s is empty';
  SContainerName = 'Container';

type
  PDynArrayRec = ^TDynArrayRec;
  TDynArrayRec = packed record
    {$IFDEF LARGEINT}
    _Padding: Integer;
    {$ENDIF}
    RefCnt: Integer;
    Length: NativeInt;
  end;

function ListIndexErrorMsg(AIndex, AMaxIndex: Integer; AListObjName: string = ''): string;
begin
  Result := Format(SListIndexError, [AIndex]);
  if AListObjName = '' then
    AListObjName := SContainerName;

  if AMaxIndex < 0 then
    Result := Result + Format(SListIndexErrorEmptyReason, [AListObjName])
  else
    Result := Result + Format(SListIndexErrorRangeReason, [AListObjName, AMaxIndex]);
end;

procedure ErrorArgumentOutOfRange;
begin
  raise EArgumentOutOfRangeException.CreateRes(Pointer(@SArgumentOutOfRange))at ReturnAddress;
end;

procedure ErrorArgumentOutOfRange(AIndex, AMaxIndex: NativeInt; AListObj: TObject = nil);
var
  s: string;
begin
  s := '';
  if AListObj <> nil then
    s := AListObj.ClassName;
  s := ListIndexErrorMsg(AIndex, AMaxIndex, s);
  raise EArgumentOutOfRangeException.Create(s)at ReturnAddress;
end;

// x86 architecture compatibility (Word mode)
{$IFNDEF CPUX86}
function Swap(const X: NativeUInt): NativeUInt; {$IFDEF HAS_INLINE} inline; {$ENDIF}
begin
  Result := (Byte(X) shl 8) + Byte(X shr 8);
end;
{$ENDIF}

{ TOSTime }

{$IFDEF POSIX}
class function TOSTime.InternalClockGetTime(const ClockId: Integer): Int64;
var
  TimeSpec: Posix.Time.timespec;
begin
  clock_gettime(ClockId, @TimeSpec);
  Result := TimeSpec.tv_sec * SECOND + Trunc(TimeSpec.tv_nsec * (1 / 100));
end;
{$ENDIF}

class procedure TOSTime.Initialize;
{$IFDEF MSWINDOWS}
var
  UTCTime, LocalTime: TFileTime;
begin
  GetSystemTimeAsFileTime(UTCTime);
  FileTimeToLocalFileTime(UTCTime, LocalTime);
  FLOCAL_DELTA := Int64(LocalTime) - Int64(UTCTime);
end;
{$ELSE .POSIX}
var
  i: Integer;
  UTC_Time: Posix.SysTypes.time_t;
  LocalTime: Posix.Time.Ptm;
  Delta: Int64;
begin
  Posix.Time.time(@UTC_Time);
  LocalTime := Posix.Time.localtime(UTC_Time);
  if (Assigned(LocalTime)) then
  begin
    FLOCAL_DELTA := LocalTime.tm_gmtoff * SECOND;
  end;

  FCLOCK_REALTIME_DELTA := InternalClockGetTime(CLOCK_REALTIME_COARSE) - InternalClockGetTime(CLOCK_MONOTONIC_COARSE);
  for i := 1 to 10 do
  begin
    Delta := InternalClockGetTime(CLOCK_REALTIME_COARSE) - InternalClockGetTime(CLOCK_MONOTONIC_COARSE);
    if (Delta < FCLOCK_REALTIME_DELTA) then
      FCLOCK_REALTIME_DELTA := Delta;
  end;
  FCLOCK_REALTIME_DELTA := FCLOCK_REALTIME_DELTA + 134774 * DAY;
  FCLOCK_REALTIME_LOCAL_DELTA := FCLOCK_REALTIME_DELTA + FLOCAL_DELTA;
end;
{$ENDIF}

{$IF CompilerVersion >= 31}
class constructor TOSTime.ClassConstructor;
begin
  Initialize;
end;
{$IFEND}

class function TOSTime.GetTickCount: Cardinal;
{$IFDEF MSWINDOWS}
begin
  Result := Winapi.Windows.GetTickCount;
end;
{$ELSE .POSIX}
var
  TimeSpec: Posix.Time.timespec;
begin
  clock_gettime(CLOCK_MONOTONIC_COARSE, @TimeSpec);
  Result := Cardinal(TimeSpec.tv_sec * 1000 + Round(TimeSpec.tv_nsec * (1 / 1000000)));
end;
{$ENDIF}

class function TOSTime.GetNow: Int64;
{$IFDEF MSWINDOWS}
var
  FileTime: TFileTime;
begin
  GetSystemTimeAsFileTime(FileTime);
  Result := Int64(FileTime) + FLOCAL_DELTA;
end;
{$ELSE .POSIX}
begin
  Result := InternalClockGetTime(CLOCK_MONOTONIC_COARSE) + FCLOCK_REALTIME_LOCAL_DELTA;
end;
{$ENDIF}

class function TOSTime.GetUTCNow: Int64;
{$IFDEF MSWINDOWS}
var
  FileTime: TFileTime;
begin
  GetSystemTimeAsFileTime(FileTime);
  Result := Int64(FileTime);
end;
{$ELSE .POSIX}
begin
  Result := InternalClockGetTime(CLOCK_MONOTONIC_COARSE) + FCLOCK_REALTIME_DELTA;
end;
{$ENDIF}

class function TOSTime.ToDateTime(const ATimeStamp: Int64): TDateTime;
begin
  Result := ATimeStamp * (1 / TOSTime.DAY) + DATETIME_DELTA;
end;

class function TOSTime.ToString(const ATimeStamp: Int64): string;
var
  DateTime: TDateTime;
  Year, Month, Day, Hour, Minut, Second, MilliSecond: Word;
begin
  DateTime := ToDateTime(ATimeStamp);
  DecodeDate(DateTime, Year, Month, Day);
  DecodeTime(DateTime, Hour, Minut, Second, MilliSecond);
  Result := Format('%.4d-%.2u-%.2u %.2u:%.2u:%.2u.%.3u', [Year, Month, Day, Hour, Minut, Second, MilliSecond]);
end;

{ TSyncYield }

class function TSyncYield.Create: TSyncYield;
begin
  Result.FCount := 0;
end;

procedure TSyncYield.Reset;
begin
  Self.FCount := 0;
end;

procedure TSyncYield.Execute;
var
  LCount: Integer;
begin
  LCount := FCount;
  Inc(LCount);
  FCount := LCount;
  Dec(LCount);

  case (LCount and 7) of
    0..4: System.YieldProcessor;
    5, 6:
      begin
        {$IFDEF MSWINDOWS}
        SwitchToThread;
        {$ELSE .POSIX}
        sched_yield;
        {$ENDIF}
      end;
  else
    Sleep(1);
  end;
end;

{ TSyncSpinlock }

class function TSyncSpinlock.Create: TSyncSpinlock;
begin
  Result.FValue := 0;
end;

function TSyncSpinlock.GetLocked: Boolean;
begin
  Result := (FValue <> 0);
end;

function TSyncSpinlock.TryEnter: Boolean;
{$IFDEF CPUINTELASM}
asm
  {$IFDEF CPUX86}
  xchg eax, ecx
  {$ENDIF}
  mov edx, 1
  xor eax, eax

  {$IFDEF CPUX86}
    cmp byte ptr [ECX].TSyncSpinlock.FValue, 0
    jne @done
    lock xchg byte ptr [ECX].TSyncSpinlock.FValue, dl
  {$else .CPUX64}
    cmp byte ptr [RCX].TSyncSpinlock.FValue, 0
    jne @done
    lock xchg byte ptr [RCX].TSyncSpinlock.FValue, dl
  {$ENDIF}
@done:
  sete al
end;
{$ELSE .NEXTGEN}
begin
  Result := (FValue = 0) and
    (AtomicCmpExchange(FValue, 1, 0) = 0);
end;
{$ENDIF}

function TSyncSpinlock.Enter(const ATimeout: Cardinal): Boolean;
var
  Yield: TSyncYield;
  Timeout, TimeStart, TimeFinish, TimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
      begin
        Result := TryEnter;
      end;
    INFINITE:
      begin
        Enter;
        Result := True;
      end;
  else
    Timeout := ATimeout;
    Yield := TSyncYield.Create;
    TimeStart := TOSTime.TickCount;
    repeat
      Result := TryEnter;
      if (Result) then
        Exit;

      TimeFinish := TOSTime.TickCount;
      TimeDelta := TimeFinish - TimeStart;
      if (TimeDelta >= Timeout) then
        Break;
      Dec(Timeout, TimeDelta);
      TimeStart := TimeFinish;

      Yield.Execute;
    until (False);

    Result := False;
  end;
end;

procedure TSyncSpinlock.InternalEnter;
var
  Yield: TSyncYield;
begin
  Yield := TSyncYield.Create;
  repeat
    Yield.Execute;
  until (TryEnter);
end;

procedure TSyncSpinlock.Enter;
begin
  if (not TryEnter) then
    InternalEnter;
end;

procedure TSyncSpinlock.Leave;
begin
  FValue := 0;
end;

function TSyncSpinlock.Wait(const ATimeout: Cardinal): Boolean;
var
  Yield: TSyncYield;
  Timeout, TimeStart, TimeFinish, TimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
      begin
        Result := (FValue = 0);
      end;
    INFINITE:
      begin
        Wait;
        Result := True;
      end;
  else
    Timeout := ATimeout;
    Yield := TSyncYield.Create;
    TimeStart := TOSTime.TickCount;
    repeat
      Result := (FValue = 0);
      if (Result) then
        Exit;

      TimeFinish := TOSTime.TickCount;
      TimeDelta := TimeFinish - TimeStart;
      if (TimeDelta >= Timeout) then
        Break;
      Dec(Timeout, TimeDelta);
      TimeStart := TimeFinish;

      Yield.Execute;
    until (False);

    Result := False;
  end;
end;

procedure TSyncSpinlock.InternalWait;
var
  Yield: TSyncYield;
begin
  Yield := TSyncYield.Create;
  repeat
    Yield.Execute;
  until (FValue = 0);
end;

procedure TSyncSpinlock.Wait;
begin
  if (FValue <> 0) then
    InternalWait;
end;

{ TSyncLocker }

class function TSyncLocker.Create: TSyncLocker;
begin
  Result.FValue := 0;
end;

function TSyncLocker.GetLocked: Boolean;
begin
  Result := (FValue <> 0);
end;

function TSyncLocker.GetLockedRead: Boolean;
var
  LValue: Integer;
begin
  LValue := FValue;
  Result := (LValue <> 0) and (LValue and 1 = 0);
end;

function TSyncLocker.GetLockedExclusive: Boolean;
begin
  Result := (FValue and 1 <> 0);
end;

function TSyncLocker.TryEnterRead: Boolean;
var
  LValue: Integer;
begin
  LValue := FValue;
  if (LValue and 1 = 0) then
  begin
    LValue := AtomicIncrement(FValue, 2);
    if (LValue and 1 = 0) then
    begin
      Result := True;
      Exit;
    end
    else
    begin
      AtomicDecrement(FValue, 2)
    end;
  end;

  Result := False;
end;

function TSyncLocker.TryEnterExclusive: Boolean;
var
  LValue: Integer;
  Yield: TSyncYield;
begin
  repeat
    LValue := FValue;
    if (LValue and 1 <> 0) then
      Break;

    if (AtomicCmpExchange(FValue, LValue + 1, LValue) = LValue) then
    begin
      Yield := TSyncYield.Create;

      repeat
        if (FValue and -2 = 0) then
          Break;

        Yield.Execute;
      until (False);

      Result := True;
      Exit;
    end;
  until (False);

  Result := False;
end;

function TSyncLocker.EnterRead(const ATimeout: Cardinal): Boolean;
var
  Yield: TSyncYield;
  Timeout, TimeStart, TimeFinish, TimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
      begin
        Result := TryEnterRead;
      end;
    INFINITE:
      begin
        EnterRead;
        Result := True;
      end;
  else
    Timeout := ATimeout;
    Yield := TSyncYield.Create;
    TimeStart := TOSTime.TickCount;
    repeat
      Result := TryEnterRead;
      if (Result) then
        Exit;

      TimeFinish := TOSTime.TickCount;
      TimeDelta := TimeFinish - TimeStart;
      if (TimeDelta >= Timeout) then
        Break;
      Dec(Timeout, TimeDelta);
      TimeStart := TimeFinish;

      Yield.Execute;
    until (False);

    Result := False;
  end;
end;

function TSyncLocker.EnterExclusive(const ATimeout: Cardinal): Boolean;
var
  Yield: TSyncYield;
  Timeout, TimeStart, TimeFinish, TimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
      begin
        Result := TryEnterExclusive;
      end;
    INFINITE:
      begin
        EnterExclusive;
        Result := True;
      end;
  else
    Timeout := ATimeout;
    Yield := TSyncYield.Create;
    TimeStart := TOSTime.TickCount;
    repeat
      Result := TryEnterExclusive;
      if (Result) then
        Exit;

      TimeFinish := TOSTime.TickCount;
      TimeDelta := TimeFinish - TimeStart;
      if (TimeDelta >= Timeout) then
        Break;
      Dec(Timeout, TimeDelta);
      TimeStart := TimeFinish;

      Yield.Execute;
    until (False);

    Result := False;
  end;
end;

procedure TSyncLocker.InternalEnterRead;
var
  Yield: TSyncYield;
begin
  Yield := TSyncYield.Create;
  repeat
    Yield.Execute;
  until (TryEnterRead);
end;

procedure TSyncLocker.EnterRead;
var
  LValue: Integer;
begin
  // if (not inline TryEnterRead) then
  //   InternalEnterRead;

  LValue := FValue;
  if (LValue and 1 = 0) then
  begin
    LValue := AtomicIncrement(FValue, 2);
    if (LValue and 1 = 0) then
    begin
      Exit;
    end
    else
    begin
      AtomicDecrement(FValue, 2)
    end;
  end;

  InternalEnterRead;
end;

procedure TSyncLocker.InternalEnterExclusive;
var
  Yield: TSyncYield;
begin
  Yield := TSyncYield.Create;
  repeat
    Yield.Execute;
  until (TryEnterExclusive);
end;

procedure TSyncLocker.EnterExclusive;
begin
  if (not TryEnterExclusive) then
    InternalEnterExclusive;
end;

procedure TSyncLocker.LeaveRead;
begin
  AtomicDecrement(FValue, 2);
end;

procedure TSyncLocker.LeaveExclusive;
begin
  AtomicDecrement(FValue, 1);
end;

function TSyncLocker.Wait(const ATimeout: Cardinal): Boolean;
var
  Yield: TSyncYield;
  Timeout, TimeStart, TimeFinish, TimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
      begin
        Result := (FValue = 0);
      end;
    INFINITE:
      begin
        Wait;
        Result := True;
      end;
  else
    Timeout := ATimeout;
    Yield := TSyncYield.Create;
    TimeStart := TOSTime.TickCount;
    repeat
      Result := (FValue = 0);
      if (Result) then
        Exit;

      TimeFinish := TOSTime.TickCount;
      TimeDelta := TimeFinish - TimeStart;
      if (TimeDelta >= Timeout) then
        Break;
      Dec(Timeout, TimeDelta);
      TimeStart := TimeFinish;

      Yield.Execute;
    until (False);

    Result := False;
  end;
end;

procedure TSyncLocker.InternalWait;
var
  Yield: TSyncYield;
begin
  Yield := TSyncYield.Create;
  repeat
    Yield.Execute;
  until (FValue = 0);
end;

procedure TSyncLocker.Wait;
begin
  if (FValue <> 0) then
    InternalWait;
end;

{ TSyncSmallLocker }

class function TSyncSmallLocker.Create: TSyncSmallLocker;
begin
  Result.FValue := 0;
end;

function TSyncSmallLocker.GetLocked: Boolean;
begin
  Result := (FValue <> 0);
end;

function TSyncSmallLocker.GetLockedRead: Boolean;
var
  LValue: Integer;
begin
  LValue := FValue;
  Result := (LValue <> 0) and (LValue and 1 = 0);
end;

function TSyncSmallLocker.GetLockedExclusive: Boolean;
begin
  Result := (FValue and 1 <> 0);
end;

class function TSyncSmallLocker.InternalCAS(var AValue: Byte; const NewValue, Comparand: Byte): Boolean;
{$IFDEF CPUINTELASM}
asm
  {$IFDEF CPUX86}
    xchg eax, ecx
    cmp byte ptr [ECX].TSyncSpinlock.FValue, al
    jne @done
    lock xchg byte ptr [ECX].TSyncSpinlock.FValue, dl
  {$else .CPUX64}
    xchg rax, r8
    cmp byte ptr [RCX].TSyncSpinlock.FValue, al
    jne @done
    lock xchg byte ptr [RCX].TSyncSpinlock.FValue, dl
  {$ENDIF}
@done:
  sete al
end;
{$ELSE .NEXTGEN}
begin
  Result := (AValue = Comparand) and (AtomicCmpExchange(AValue, NewValue, Comparand) = Comparand);
end;
{$ENDIF}

function TSyncSmallLocker.TryEnterRead: Boolean;
var
  LValue: Integer;
begin
  repeat
    LValue := FValue;
    if (LValue and 1 <> 0) or (LValue = 254) then
      Break;

    if (InternalCAS(FValue, LValue + 2, LValue)) then
    begin
      Result := True;
      Exit;
    end;
  until (False);

  Result := False;
end;

function TSyncSmallLocker.TryEnterExclusive: Boolean;
var
  LValue: Integer;
  Yield: TSyncYield;
begin
  repeat
    LValue := FValue;
    if (LValue and 1 <> 0) then
      Break;

    if (InternalCAS(FValue, LValue + 1, LValue)) then
    begin
      Yield := TSyncYield.Create;

      repeat
        if (FValue and -2 = 0) then
          Break;

        Yield.Execute;
      until (False);

      Result := True;
      Exit;
    end;
  until (False);

  Result := False;
end;

function TSyncSmallLocker.EnterRead(const ATimeout: Cardinal): Boolean;
var
  Yield: TSyncYield;
  Timeout, TimeStart, TimeFinish, TimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
      begin
        Result := TryEnterRead;
      end;
    INFINITE:
      begin
        EnterRead;
        Result := True;
      end;
  else
    Timeout := ATimeout;
    Yield := TSyncYield.Create;
    TimeStart := TOSTime.TickCount;
    repeat
      Result := TryEnterRead;
      if (Result) then
        Exit;

      TimeFinish := TOSTime.TickCount;
      TimeDelta := TimeFinish - TimeStart;
      if (TimeDelta >= Timeout) then
        Break;
      Dec(Timeout, TimeDelta);
      TimeStart := TimeFinish;

      Yield.Execute;
    until (False);

    Result := False;
  end;
end;

function TSyncSmallLocker.EnterExclusive(const ATimeout: Cardinal): Boolean;
var
  Yield: TSyncYield;
  Timeout, TimeStart, TimeFinish, TimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
      begin
        Result := TryEnterExclusive;
      end;
    INFINITE:
      begin
        EnterExclusive;
        Result := True;
      end;
  else
    Timeout := ATimeout;
    Yield := TSyncYield.Create;
    TimeStart := TOSTime.TickCount;
    repeat
      Result := TryEnterExclusive;
      if (Result) then
        Exit;

      TimeFinish := TOSTime.TickCount;
      TimeDelta := TimeFinish - TimeStart;
      if (TimeDelta >= Timeout) then
        Break;
      Dec(Timeout, TimeDelta);
      TimeStart := TimeFinish;

      Yield.Execute;
    until (False);

    Result := False;
  end;
end;

procedure TSyncSmallLocker.InternalEnterRead;
var
  Yield: TSyncYield;
begin
  Yield := TSyncYield.Create;
  repeat
    Yield.Execute;
  until (TryEnterRead);
end;

procedure TSyncSmallLocker.EnterRead;
begin
  if (not TryEnterRead) then
    InternalEnterRead;
end;

procedure TSyncSmallLocker.InternalEnterExclusive;
var
  Yield: TSyncYield;
begin
  Yield := TSyncYield.Create;
  repeat
    Yield.Execute;
  until (TryEnterExclusive);
end;

procedure TSyncSmallLocker.EnterExclusive;
begin
  if (not TryEnterExclusive) then
    InternalEnterExclusive;
end;

procedure TSyncSmallLocker.LeaveRead;
{$IFDEF CPUINTELASM}
asm
  or edx, -2
  {$IFDEF CPUX86}
  lock xadd [EAX].FValue, dl
  {$else .CPUARM}
  lock xadd [RCX].FValue, dl
  {$ENDIF}
end;
{$ELSE .NEXTGEN}
begin
  AtomicDecrement(FValue, 2);
end;
{$ENDIF}

procedure TSyncSmallLocker.LeaveExclusive;
{$IFDEF CPUINTELASM}
asm
  or edx, -1
  {$IFDEF CPUX86}
  lock xadd [EAX].FValue, dl
  {$else .CPUARM}
  lock xadd [RCX].FValue, dl
  {$ENDIF}
end;
{$ELSE .NEXTGEN}
begin
  AtomicDecrement(FValue, 1);
end;
{$ENDIF}

function TSyncSmallLocker.Wait(const ATimeout: Cardinal): Boolean;
var
  Yield: TSyncYield;
  Timeout, TimeStart, TimeFinish, TimeDelta: Cardinal;
begin
  case (ATimeout) of
    0:
      begin
        Result := (FValue = 0);
      end;
    INFINITE:
      begin
        Wait;
        Result := True;
      end;
  else
    Timeout := ATimeout;
    Yield := TSyncYield.Create;
    TimeStart := TOSTime.TickCount;
    repeat
      Result := (FValue = 0);
      if (Result) then
        Exit;

      TimeFinish := TOSTime.TickCount;
      TimeDelta := TimeFinish - TimeStart;
      if (TimeDelta >= Timeout) then
        Break;
      Dec(Timeout, TimeDelta);
      TimeStart := TimeFinish;

      Yield.Execute;
    until (False);

    Result := False;
  end;
end;

procedure TSyncSmallLocker.InternalWait;
var
  Yield: TSyncYield;
begin
  Yield := TSyncYield.Create;
  repeat
    Yield.Execute;
  until (FValue = 0);
end;

procedure TSyncSmallLocker.Wait;
begin
  if (FValue <> 0) then
    InternalWait;
end;

{ TaggedPointer }

class function TaggedPointer.Create(const AValue: Pointer): TaggedPointer;
begin
  Result.F.Value := AValue;
  {$IFDEF SMALLINT}
  Result.F.VHigh := 0;
  {$ENDIF}
end;

class function TaggedPointer.Create(const AValue: Int64): TaggedPointer;
begin
  Result.F.VInt64 := AValue;
end;

class function TaggedPointer.Create(const ALow, AHigh: Integer): TaggedPointer;
begin
  Result.F.VLow := ALow;
  Result.F.VHigh := AHigh;
end;

class operator TaggedPointer.Equal(const a, b: TaggedPointer): Boolean;
begin
  Result := (Int64(a) = Int64(b));
end;

function TaggedPointer.Copy: TaggedPointer;
{$IF Defined(LARGEINT)}
begin
  Result.F.VInt64 := Self.F.VInt64;
end;
{$ELSEIF not Defined(CPUX86)}
var
  Temp: Double;
begin
  Temp := Self.F.VDouble;
  Result.F.VDouble := Temp;
end;
{$ELSE .CPUX86}
asm
  fild qword ptr [eax]
  fistp qword ptr [edx]
end;
{$IFEND}

procedure TaggedPointer.Fill(const AValue: TaggedPointer);
{$IF Defined(LARGEINT)}
begin
  F.VInt64 := AValue.F.VInt64;
end;
{$ELSEIF not Defined(CPUX86)}
var
  Temp: Double;
begin
  Temp := AValue.F.VDouble;
  Self.F.VDouble := Temp;
end;
{$ELSE .CPUX86}
asm
  fild qword ptr [edx]
  fistp qword ptr [eax]
end;
{$IFEND}

function TaggedPointer.GetIsEmpty: Boolean;
begin
  {$IFDEF CPUX64}
  Result := (Self.F.VNative and X64_TAGGEDPTR_MASK = 0);
  {$ELSE}
  Result := (Self.F.Value = nil);
  {$ENDIF}
end;

function TaggedPointer.GetIsInvalid: Boolean;
begin
  {$IFDEF CPUX64}
  Result := (Self.F.VNative and X64_TAGGEDPTR_MASK = NativeUInt(INVALID_VALUE));
  {$ELSE}
  Result := (Self.F.Value = INVALID_VALUE);
  {$ENDIF}
end;

function TaggedPointer.GetIsEmptyOrInvalid: Boolean;
var
  LNative: NativeUInt;
begin
  LNative := Self.F.VNative {$IFDEF CPUX64} and X64_TAGGEDPTR_MASK{$ENDIF};
  Result := (LNative = 0) or (LNative = NativeUInt(INVALID_VALUE));
end;

{$IFDEF CPUX64}
function TaggedPointer.GetValue: Pointer;
begin
  Result := Pointer(Self.F.VNative and X64_TAGGEDPTR_MASK);
end;
{$ENDIF}

{$IFDEF CPUX64}
procedure TaggedPointer.SetValue(const AValue: Pointer);
var
  Item, NewItem: NativeUInt;
begin
  repeat
    Item := F.VNative;
    NewItem := NativeUInt(AValue) + (((Item or X64_TAGGEDPTR_MASK) + 1) and X64_TAGGEDPTR_CLEAR);
  until (Item = F.VNative) and (Item = System.AtomicCmpExchange(F.VNative, NewItem, Item));
end;
{$ENDIF}

{$IFDEF CPUX86}
procedure TaggedPointer.SetValue(const AValue: Pointer);
asm
  push esi
  push ebx
  mov esi, eax // Self
  mov ebx, edx // AValue

  // Item := F.VInt64
  fild qword ptr [esi]
  fistp qword ptr [esp - 8]
  mov eax, [esp - 8]
  mov edx, [esp - 4]

  // lock-free loop
  @loop:
    // NewItem.Counter := Item.Counter + 1
    lea ecx, [edx + 1]

    // compare Item and F.VInt64
    cmp eax, [esi]
    jne @loop
    cmp edx, [esi + 4]
    jne @loop

    // Item := AtomicCmpExchangeInt64(F.VInt64, NewItem, Item)
    lock cmpxchg8b [esi]
  jnz @loop

@done:
  pop ebx
  pop esi
end;
{$ENDIF}

function TaggedPointer.AtomicCmpExchange(const NewValue: Pointer;
  const Comparand: TaggedPointer): Boolean;
{$IFNDEF CPUX86}
var
  _NewValue: TaggedPointer;
begin
  _NewValue.F.VNative := NativeUInt(NewValue)
    {$IFDEF CPUX64} + (((Comparand.F.VNative or X64_TAGGEDPTR_MASK) + 1) and X64_TAGGEDPTR_CLEAR){$ENDIF};
  {$IFDEF SMALLINT}
  _NewValue.F.VHigh := 0;
  {$ENDIF}

  Result := (Self.F.VInt64 = Comparand.F.VInt64) and
    (System.AtomicCmpExchange(Self.F.VInt64, _NewValue.F.VInt64, Comparand.F.VInt64) = Comparand.F.VInt64);
end;
{$ELSE .CPUX86}
asm
  push esi
  push ebx
  mov esi, eax // Self
  mov ebx, edx // AValue

  // Item := F.VInt64
  mov eax, [esi]
  mov edx, [esi + 4]

  // compare Item and Comparand
  cmp eax, [ecx]
  jne @done
  cmp edx, [ecx + 4]
  jne @done

  // NewItem.Counter := Item.Counter + 1
  lea ecx, [edx + 1]

  // Item := AtomicCmpExchangeInt64(F.VInt64, NewItem, Item)
  lock cmpxchg8b [esi]

@done:
  sete al
  pop ebx
  pop esi
end;
{$ENDIF}

function TaggedPointer.AtomicCmpExchange(const NewValue: TaggedPointer;
  const Comparand: TaggedPointer): Boolean;
{$IFNDEF CPUX86}
begin
  Result := (Self.F.VInt64 = Comparand.F.VInt64) and
    (System.AtomicCmpExchange(Self.F.VInt64, NewValue.F.VInt64, Comparand.F.VInt64) = Comparand.F.VInt64);
end;
{$ELSE .CPUX86}
asm
  push esi
  push ebx
  mov esi, eax // Self
  mov ebx, edx // NewValue

  // Item := F.VInt64
  mov eax, [esi]
  mov edx, [esi + 4]

  // compare Item and Comparand
  cmp eax, [ecx]
  jne @done
  cmp edx, [ecx + 4]
  jne @done

  // NewItem := NewValue
  mov ecx, [ebx + 4]
  mov ebx, [ebx]

  // Item := AtomicCmpExchangeInt64(F.VInt64, NewItem, Item)
  lock cmpxchg8b [esi]

@done:
  sete al
  pop ebx
  pop esi
end;
{$ENDIF}

function TaggedPointer.AtomicExchange(const NewValue: Pointer): Pointer;
{$IF not Defined(CPUINTEL)}
begin
  Result := System.AtomicExchange(Self.F.Value, NewValue);
end;
{$ELSEIF Defined(CPUX64)}
var
  Item, NewItem: NativeUInt;
begin
  repeat
    Item := F.VNative;
    NewItem := NativeUInt(NewValue) + (((Item or X64_TAGGEDPTR_MASK) + 1) and X64_TAGGEDPTR_CLEAR);
  until (Item = F.VNative) and (Item = System.AtomicCmpExchange(F.VNative, NewItem, Item));

  Result := Pointer(Item and X64_TAGGEDPTR_MASK);
end;
{$ELSE .CPUX86}
asm
  push esi
  push ebx
  mov esi, eax // Self
  mov ebx, edx // NewValue

  // Item := F.VInt64
  fild qword ptr [esi]
  fistp qword ptr [esp - 8]
  mov eax, [esp - 8]
  mov edx, [esp - 4]

  // lock-free loop
  @loop:
    // NewItem.Counter := Item.Counter + 1
    lea ecx, [edx + 1]

    // compare Item and F.VInt64
    cmp eax, [esi]
    jne @loop
    cmp edx, [esi + 4]
    jne @loop

    // Item := AtomicCmpExchangeInt64(F.VInt64, NewItem, Item)
    lock cmpxchg8b [esi]
  jnz @loop

@done:
  // mov eax, eax
  pop ebx
  pop esi
end;
{$IFEND}

function TaggedPointer.AtomicExchange(const NewValue: TaggedPointer): TaggedPointer;
begin
  Result.F.VInt64 := System.AtomicExchange(Self.F.VInt64, NewValue.F.VInt64);
end;

procedure TaggedPointer.PushList(const First, Last: Pointer);
{$IFNDEF CPUX86}
var
  Item, NewItem: NativeUInt;
begin
  repeat
    Item := F.VNative;
    PNativeUInt(Last)^ := Item {$IFDEF CPUX64} and X64_TAGGEDPTR_MASK{$ENDIF};
    NewItem := NativeUInt(First) {$IFDEF CPUX64} + (((Item or X64_TAGGEDPTR_MASK) + 1) and
      X64_TAGGEDPTR_CLEAR){$ENDIF};
  until (Item = System.AtomicCmpExchange(F.VNative, NewItem, Item));
end;
{$ELSE .CPUX86}
asm
  push esi
  push ebx
  push edi
  mov esi, eax // Self
  mov ebx, edx // NewItem = First
  mov edi, ecx // Last

  // Item := F.VInt64
  fild qword ptr [esi]
  fistp qword ptr [esp - 8]
  mov eax, [esp - 8]
  mov edx, [esp - 4]

  // lock-free loop
  @loop:
    // PItem(Last).Next := Item
    mov [edi], eax

    // NewItem.Counter := Item.Counter + 1
    lea ecx, [edx + 1]

    // Item := AtomicCmpExchangeInt64(F.VInt64, NewItem, Item)
    lock cmpxchg8b [esi]
  jnz @loop

@done:
  pop edi
  pop ebx
  pop esi
end;
{$ENDIF}

procedure TaggedPointer.PushList(const First: Pointer {Last calculated});
var
  Last, Next: Pointer;
begin
  Next := PPointer(First)^;
  Last := First;

  if (Assigned(Next)) then
    repeat
      Last := Next;
      Next := PPointer(Next)^;
    until (not Assigned(Next));

  Self.PushList(First, Last);
end;

procedure TaggedPointer.Push(const Value: Pointer);
begin
  Self.PushList(Value, Value);
end;

function TaggedPointer.Pop: Pointer;
{$IFNDEF CPUX86}
var
  Item, NewItem: NativeUInt;
begin
  repeat
    Item := F.VNative;
    Result := Pointer(Item {$IFDEF CPUX64} and X64_TAGGEDPTR_MASK{$ENDIF});
    if (not Assigned(Result)) then
      Exit;

    NewItem := PNativeUInt(Result)^ {$IFDEF CPUX64} + (Item and X64_TAGGEDPTR_CLEAR){$ENDIF};
  until (Item = System.AtomicCmpExchange(F.VNative, NewItem, Item));
end;
{$ELSE .CPUX86}
asm
  push esi
  push ebx
  mov esi, eax // Self

  // Item := F.VInt64
  fild qword ptr [esi]
  fistp qword ptr [esp - 8]
  mov eax, [esp - 8]
  mov edx, [esp - 4]

  // lock-free loop
  @loop:
    // Result := Item
    // if (not Assigned(Result)) then Exit;
    test eax, eax
    jz @done

    // NewItem := PItem(Item).Next, leave Counter
    mov ebx, [eax]
    mov ecx, edx

    // Item := AtomicCmpExchangeInt64(F.VInt64, NewItem, Item)
    lock cmpxchg8b [esi]
  jnz @loop

@done:
  pop ebx
  pop esi
end;
{$ENDIF}

function TaggedPointer.PopList: Pointer;
{$IFNDEF CPUX86}
var
  Item, NewItem: NativeUInt;
begin
  repeat
    Item := F.VNative;
    Result := Pointer(Item {$IFDEF CPUX64} and X64_TAGGEDPTR_MASK{$ENDIF});
    if (not Assigned(Result)) then
      Exit;

    NewItem := {nil}0 {$IFDEF CPUX64} + (Item and X64_TAGGEDPTR_CLEAR){$ENDIF};
  until (Item = System.AtomicCmpExchange(F.VNative, NewItem, Item));
end;
{$ELSE .CPUX86}
asm
  push esi
  push ebx
  mov esi, eax // Self

  // Item := F.VInt64
  fild qword ptr [esi]
  fistp qword ptr [esp - 8]
  mov eax, [esp - 8]
  mov edx, [esp - 4]

  // lock-free loop
  @loop:
    // Result := Item
    // if (not Assigned(Result)) then Exit;
    test eax, eax
    jz @done

    // NewItem := 0, leave Counter
    xor ebx, ebx
    mov ecx, edx

    // Item := AtomicCmpExchangeInt64(F.VInt64, NewItem, Item)
    lock cmpxchg8b [esi]
  jnz @loop

@done:
  pop ebx
  pop esi
end;
{$ENDIF}

function TaggedPointer.PopListReversed: Pointer;
var
  Current, Next: Pointer;
begin
  Result := Self.PopList;

  if (Assigned(Result)) then
  begin
    Current := PPointer(Result)^;
    PPointer(Result)^ := nil;

    if (Assigned(Current)) then
      repeat
        Next := PPointer(Current)^;
        PPointer(Current)^ := Result;
        Result := Current;

        Current := Next;
      until (not Assigned(Next));
  end;
end;

function TaggedPointer.TryPushList(const First, Last: Pointer): Boolean;
{$IFNDEF CPUX86}
var
  Item, NewItem: NativeUInt;
begin
  repeat
    Item := F.VNative;
    Result := False;
    if (Item = NativeUInt(INVALID_VALUE)) then
      Exit;

    PNativeUInt(Last)^ := Item {$IFDEF CPUX64} and X64_TAGGEDPTR_MASK{$ENDIF};
    NewItem := NativeUInt(First) {$IFDEF CPUX64} + (((Item or X64_TAGGEDPTR_MASK) + 1) and
      X64_TAGGEDPTR_CLEAR){$ENDIF};
  until (Item = System.AtomicCmpExchange(F.VNative, NewItem, Item));

  Result := True;
end;
{$ELSE .CPUX86}
asm
  push esi
  push ebx
  push edi
  mov esi, eax // Self
  mov ebx, edx // NewItem = First
  mov edi, ecx // Last

  // Item := F.VInt64
  fild qword ptr [esi]
  fistp qword ptr [esp - 8]
  mov eax, [esp - 8]
  mov edx, [esp - 4]

  // lock-free loop
  @loop:
    // if (Item = NativeUInt(INVALID_VALUE)) then Exit(False);
    cmp eax, -1
    je @invalid_value

    // PItem(Last).Next := Item
    mov [edi], eax

    // NewItem.Counter := Item.Counter + 1
    lea ecx, [edx + 1]

    // Item := AtomicCmpExchangeInt64(F.VInt64, NewItem, Item)
    lock cmpxchg8b [esi]
  jnz @loop

@done:
  mov eax, 1
  pop edi
  pop ebx
  pop esi
  ret
@invalid_value:
  xor eax, eax
  pop edi
  pop ebx
  pop esi
end;
{$ENDIF}

function TaggedPointer.TryPushList(const First: Pointer {Last calculated}): Boolean;
var
  Last, Next: Pointer;
begin
  Next := PPointer(First)^;
  Last := First;

  if (Assigned(Next)) then
    repeat
      Last := Next;
      Next := PPointer(Next)^;
    until (not Assigned(Next));

  Result := Self.TryPushList(First, Last);
end;

function TaggedPointer.TryPush(const Value: Pointer): Boolean;
begin
  Result := TryPushList(Value, Value);
end;

function TaggedPointer.TryPop: Pointer;
{$IFNDEF CPUX86}
var
  Item, NewItem: NativeUInt;
begin
  repeat
    Item := F.VNative;
    Result := Pointer(Item {$IFDEF CPUX64} and X64_TAGGEDPTR_MASK{$ENDIF});
    if (not Assigned(Result)) or (Result = INVALID_VALUE) then
      Exit;

    NewItem := PNativeUInt(Result)^ {$IFDEF CPUX64} + (Item and X64_TAGGEDPTR_CLEAR){$ENDIF};
  until (Item = System.AtomicCmpExchange(F.VNative, NewItem, Item));
end;
{$ELSE .CPUX86}
asm
  push esi
  push ebx
  mov esi, eax // Self

  // Item := F.VInt64
  fild qword ptr [esi]
  fistp qword ptr [esp - 8]
  mov eax, [esp - 8]
  mov edx, [esp - 4]

  // lock-free loop
  @loop:
    // Result := Item
    // if (not Assigned(Result)) or (Result = INVALID_VALUE) then Exit;
    test eax, eax
    jz @done
    cmp eax, -1
    je @done

    // NewItem := PItem(Item).Next, leave Counter
    mov ebx, [eax]
    mov ecx, edx

    // Item := AtomicCmpExchangeInt64(F.VInt64, NewItem, Item)
    lock cmpxchg8b [esi]
  jnz @loop

@done:
  pop ebx
  pop esi
end;
{$ENDIF}

function TaggedPointer.TryPopList: Pointer;
{$IFNDEF CPUX86}
var
  Item, NewItem: NativeUInt;
begin
  repeat
    Item := F.VNative;
    Result := Pointer(Item {$IFDEF CPUX64} and X64_TAGGEDPTR_MASK{$ENDIF});
    if (not Assigned(Result)) or (Result = INVALID_VALUE) then
      Exit;

    NewItem := {nil}0 {$IFDEF CPUX64} + (Item and X64_TAGGEDPTR_CLEAR){$ENDIF};
  until (Item = System.AtomicCmpExchange(F.VNative, NewItem, Item));
end;
{$ELSE .CPUX86}
asm
  push esi
  push ebx
  mov esi, eax // Self

  // Item := F.VInt64
  fild qword ptr [esi]
  fistp qword ptr [esp - 8]
  mov eax, [esp - 8]
  mov edx, [esp - 4]

  // lock-free loop
  @loop:
    // Result := Item
    // if (not Assigned(Result)) or (Result = INVALID_VALUE) then Exit;
    test eax, eax
    jz @done
    cmp eax, -1
    je @done

    // NewItem := 0, leave Counter
    xor ebx, ebx
    mov ecx, edx

    // Item := AtomicCmpExchangeInt64(F.VInt64, NewItem, Item)
    lock cmpxchg8b [esi]
  jnz @loop

@done:
  pop ebx
  pop esi
end;
{$ENDIF}

function TaggedPointer.TryPopListReversed: Pointer;
var
  Current, Next: Pointer;
begin
  Result := Self.TryPopList;

  if (Assigned(Result)) and (Result <> INVALID_VALUE) then
  begin
    Current := PPointer(Result)^;
    PPointer(Result)^ := nil;

    if (Assigned(Current)) then
      repeat
        Next := PPointer(Current)^;
        PPointer(Current)^ := Result;
        Result := Current;

        Current := Next;
      until (not Assigned(Next));
  end;
end;

{ TCustomObject }

class function TCustomObject.NewInstance: TObject;
label
  _0, _1, _2, _3, _4, _5, _6, _7, _8;
type
  HugeNativeIntArray = array[0..High(Integer) div SizeOf(NativeInt) - 1] of NativeInt;
var
  LSize: Integer;
  LPtr: ^HugeNativeIntArray;
  LNull: NativeInt;
  LClass: TClass;
  LTable: PInterfaceTable;
  LEntry, LTopEntry: PInterfaceEntry;
  LValue: Pointer;
begin
  // allocate
  LSize := (PInteger(PByte(Self) + vmtInstanceSize)^ + (SizeOf(NativeInt) - 1)) and (-SizeOf(NativeInt));
  GetMem(LPtr, LSize);

  // TCustomObject initialization
  LPtr[0] := NativeInt(Self);
  LPtr[1] {FRefCount} := (DUMMY_REFCOUNT or Ord(msHeap));
  LPtr[2] := NativeInt(@TCustomObject.FInterfaceTable);
  LPtr[3] := NativeInt(PInterfaceTable(PPointer(PByte(TCustomObject) + vmtIntfTable)^).Entries[0].VTable);

  // fill zero
  Dec(LSize, 4 * SizeOf(NativeInt));
  Inc(NativeInt(LPtr), 4 * SizeOf(NativeInt));
  LSize := LSize shr {$IFDEF LARGEINT}3{$ELSE .SMALLINT}2{$ENDIF};
  LNull := 0;
  case (LSize) of
    8: goto _8;
    7: goto _7;
    6: goto _6;
    5: goto _5;
    4: goto _4;
    3: goto _3;
    2: goto _2;
    1: goto _1;
    0: goto _0;
  else
    FillChar(LPtr^, LSize shl {$IFDEF LARGEINT}3{$ELSE .SMALLINT}2{$ENDIF}, #0);
    goto _0;
  end;
  _8: LPtr[7] := LNull;
  _7: LPtr[6] := LNull;
  _6: LPtr[5] := LNull;
  _5: LPtr[4] := LNull;
  _4: LPtr[3] := LNull;
  _3: LPtr[2] := LNull;
  _2: LPtr[1] := LNull;
  _1: LPtr[0] := LNull;
  _0: Dec(NativeInt(LPtr), 4 * SizeOf(NativeInt));

  // interfaces
  LClass := Self;
  if (LClass <> TCustomObject) then
    repeat
      LTable := PInterfaceTable(PPointer(PByte(LClass) + vmtIntfTable)^);
      if (Assigned(LTable)) then
      begin
        LTopEntry := @LTable.Entries[LTable.EntryCount];
        LEntry := @LTable.Entries[0];
        if (LEntry <> LTopEntry) then
          repeat
            LValue := LEntry.VTable;
            if (Assigned(LValue)) then
              PPointer(PByte(LPtr) + LEntry.IOffset)^ := LValue;

            Inc(LEntry);
          until (LEntry = LTopEntry);
      end;

      LClass := TClass(PPointer(PPointer(PByte(LClass) + vmtParent)^)^);
    until (LClass = TCustomObject);

  // result
  Result := Pointer(LPtr);
end;

class function TCustomObject.PreallocatedInstance(const AMemory: Pointer;
  const AMemoryScheme: TMemoryScheme): TObject;
label
  _0, _1, _2, _3, _4, _5, _6, _7, _8;
type
  HugeNativeIntArray = array[0..High(Integer) div SizeOf(NativeInt) - 1] of NativeInt;
var
  LInstanceSize, LSize: Integer;
  LPtr: ^HugeNativeIntArray;
  LNull: NativeInt;
  LClass: TClass;
  LTable: PInterfaceTable;
  LEntry, LTopEntry: PInterfaceEntry;
  LValue: Pointer;
begin
  // memory
  if (NativeUInt(AMemory) <= High(Word)) or (NativeInt(AMemory) and 7 <> 0) then
  begin
    if (NativeUInt(AMemory) <= High(Word)) then
    begin
      raise EInvalidPointer.CreateRes(Pointer(@SInvalidPointer));
    end
    else
    begin
      raise EInvalidPointer.CreateResFmt(Pointer(@SInvalidPointerAlign), [AMemory, 8]);
    end;
  end;

  // size
  LInstanceSize := PInteger(PByte(Self) + vmtInstanceSize)^;
  LSize := LInstanceSize and (-SizeOf(NativeInt));
  if (LInstanceSize and (SizeOf(NativeInt) - 1) <> 0) then
  begin
    PNativeInt(PByte(AMemory) + (LInstanceSize - SizeOf(NativeInt)))^ := 0;
  end;
  LPtr := AMemory;

  // TCustomObject initialization
  LPtr[0] := NativeInt(Self);
  LPtr[1] {FRefCount} := DUMMY_REFCOUNT + (Ord(AMemoryScheme) shl MEMORY_SCHEME_SHIFT);
  LPtr[2] := NativeInt(@TCustomObject.FInterfaceTable);
  LPtr[3] := NativeInt(PInterfaceTable(PPointer(PByte(TCustomObject) + vmtIntfTable)^).Entries[0].VTable);

  // fill zero
  Dec(LSize, 4 * SizeOf(NativeInt));
  Inc(NativeInt(LPtr), 4 * SizeOf(NativeInt));
  LSize := LSize shr {$IFDEF LARGEINT}3{$ELSE .SMALLINT}2{$ENDIF};
  LNull := 0;
  case (LSize) of
    8: goto _8;
    7: goto _7;
    6: goto _6;
    5: goto _5;
    4: goto _4;
    3: goto _3;
    2: goto _2;
    1: goto _1;
    0: goto _0;
  else
    FillChar(LPtr^, LSize shl {$IFDEF LARGEINT}3{$ELSE .SMALLINT}2{$ENDIF}, #0);
    goto _0;
  end;
  _8: LPtr[7] := LNull;
  _7: LPtr[6] := LNull;
  _6: LPtr[5] := LNull;
  _5: LPtr[4] := LNull;
  _4: LPtr[3] := LNull;
  _3: LPtr[2] := LNull;
  _2: LPtr[1] := LNull;
  _1: LPtr[0] := LNull;
  _0: Dec(NativeInt(LPtr), 4 * SizeOf(NativeInt));

  // interfaces
  LClass := Self;
  if (LClass <> TCustomObject) then
    repeat
      LTable := PInterfaceTable(PPointer(PByte(LClass) + vmtIntfTable)^);
      if (Assigned(LTable)) then
      begin
        LTopEntry := @LTable.Entries[LTable.EntryCount];
        LEntry := @LTable.Entries[0];
        if (LEntry <> LTopEntry) then
          repeat
            LValue := LEntry.VTable;
            if (Assigned(LValue)) then
              PPointer(PByte(LPtr) + LEntry.IOffset)^ := LValue;

            Inc(LEntry);
          until (LEntry = LTopEntry);
      end;

      LClass := TClass(PPointer(PPointer(PByte(LClass) + vmtParent)^)^);
    until (LClass = TCustomObject);

  // result
  Result := Pointer(LPtr);
end;

{$IF Defined(WEAKREF) and Defined(CPUINTELASM)}
procedure _CleanupInstance(Instance: Pointer);
asm
  jmp System.@CleanupInstance
end;
{$IFEND}

{$IF Defined(CPUINTELASM)}
procedure FinalizeRecord(P: Pointer; TypeInfo: Pointer);
asm
  jmp System.@FinalizeRecord
end;

{$ELSEIF CompilerVersion < 31}
procedure FinalizeRecord(P: Pointer; TypeInfo: Pointer); {$IFDEF HAS_INLINE} inline; {$ENDIF}
begin
  System.FinalizeArray(P, TypeInfo, 1);
end;
{$IFEND}

procedure TCustomObject.FreeInstance;
label
  next_class, free_memory;
var
  LRefCount: Integer;
  LSize: Integer;
  {$IF (not Defined(WEAKREF)) or Defined(CPUINTELASM) or (CompilerVersion >= 32)}
  LClass: TClass;
  LTypeInfo: PTypeInfo;
  LMonitor, LMonitorFlags: NativeInt;
  LLockEvent: Pointer;
  FieldTable: TRAIIHelper.PFieldTable;
  Field, TopField: TRAIIHelper.PFieldInfo;
  {$IFDEF WEAKREF}
  WeakMode: Boolean;
  {$ENDIF}
  LPtr: Pointer;
  VType: Integer;
  {$IFEND}
begin
  // check reference count
  LRefCount := FRefCount and (REFCOUNT_MASK and (not DUMMY_REFCOUNT));
  if (LRefCount <> 0) then
    raise CreateEInvalidRefCount(Self, LRefCount);

  {$IF (not Defined(WEAKREF)) or Defined(CPUINTELASM) or (CompilerVersion >= 32)}
    // monitor start, weak references
  LSize := PInteger(PNativeInt(Self)^ + vmtInstanceSize)^;
  LMonitorFlags := PNativeInt(PByte(Self) + LSize + (-hfFieldSize + hfMonitorOffset))^;
  {$IFDEF WEAKREF}
  {$IF CompilerVersion >= 32}
  if (LMonitorFlags and monWeakReferencedFlag <> 0) then
    {$IFEND}
  begin
    {$IFDEF CPUINTELASM}
    _CleanupInstance(Pointer(Self));
    {$ELSE .NEXTGEN}
    Self.CleanupInstance;
    goto free_memory;
    {$ENDIF}
  end;
  {$ENDIF}

    // monitor finish
  LMonitor := LMonitorFlags {$IF CompilerVersion >= 32} and monMonitorMask{$IFEND};
  if (LMonitor <> 0) then
  begin
    LLockEvent := PPointer(LMonitor + (SizeOf(Integer) + SizeOf(Integer) + SizeOf(System.TThreadID)))^;
    if Assigned(LLockEvent) then
    begin
      MonitorSupport.FreeSyncObject(LLockEvent);
    end;

    FreeMem(Pointer(LMonitor));
  end;

    // fields
  LClass := PPointer(Self)^;
  if (LClass <> TCustomObject) then
    repeat
      LTypeInfo := PPointer(PByte(LClass) + vmtInitTable)^;
      if (not Assigned(LTypeInfo)) then
        goto next_class;

      FieldTable := Pointer(PByte(LTypeInfo) + PByte(@LTypeInfo.Name)^);
      if (FieldTable.Count = 0) then
        goto next_class;

      TopField := @FieldTable.Fields[FieldTable.Count];
      Field := @FieldTable.Fields[0];
      repeat
        {$IFDEF WEAKREF}
        WeakMode := False;
        {$ENDIF}

        LPtr := PByte(Self) + NativeInt(Field.Offset);
        {$IFDEF WEAKREF}
        if (Field.TypeInfo = nil) then
        begin
          WeakMode := True;
        end;
        if (not WeakMode) then
        begin
          {$ENDIF}
          case (Field.TypeInfo^.Kind) of
            tkVariant:
              begin
                VType := Word(LPtr^);
                if (VType and TRAIIHelper.varDeepData <> 0) and (VType <> varBoolean) and
                  (Cardinal(VType - (varUnknown + 1)) > (varUInt64 - varUnknown - 1)) then
                  System.VarClear(Variant(LPtr^));
              end;
            {$IFDEF AUTOREFCOUNT}
            tkClass:
              begin
                if Assigned(PPointer(LPtr)^) then
                  TRAIIHelper.RefObjClear(LPtr);
              end;
            {$ENDIF}
            {$IFDEF WEAKINSTREF}
            tkMethod:
              begin
                Inc(NativeInt(LPtr), SizeOf(Pointer));
                if Assigned(PPointer(LPtr)^) then
                  TRAIIHelper.WeakMethodClear(LPtr);
              end;
            {$ENDIF}
            {$IFDEF MSWINDOWS}
            tkWString:
              begin
                if Assigned(PPointer(LPtr)^) then
                  TRAIIHelper.WStrClear(LPtr);
              end;
            {$ELSE}
            tkWString,
              {$ENDIF}
            tkLString, tkUString:
              begin
                if Assigned(PPointer(LPtr)^) then
                  TRAIIHelper.ULStrClear(LPtr);
              end;
            tkInterface:
              begin
                if Assigned(PPointer(LPtr)^) then
                  TRAIIHelper.IntfClear(LPtr);
              end;
            tkDynArray:
              begin
                if Assigned(PPointer(LPtr)^) then
                  TRAIIHelper.DynArrayClear(LPtr, Field.TypeInfo^);
              end;
            tkArray {static array}:
              begin
                System.FinalizeArray(LPtr, Field.TypeInfo^, FieldTable.Count);
              end;
            tkRecord:
              begin
                FinalizeRecord(LPtr, Field.TypeInfo^);
              end;
          end;
          {$IFDEF WEAKREF}
        end
        else
          case Field.TypeInfo^.Kind of
            {$IFDEF WEAKINTFREF}
            tkInterface:
              begin
                if Assigned(PPointer(LPtr)^) then
                  TRAIIHelper.WeakIntfClear(LPtr);
              end;
            {$ENDIF}
            {$IFDEF WEAKINSTREF}
            tkClass:
              begin
                if Assigned(PPointer(LPtr)^) then
                  TRAIIHelper.WeakObjClear(LPtr);
              end;
            tkMethod:
              begin
                Inc(NativeInt(LPtr), SizeOf(Pointer));
                if Assigned(PPointer(LPtr)^) then
                  TRAIIHelper.WeakMethodClear(LPtr);
              end;
            {$ENDIF}
          end;
        {$ENDIF .WEAKREF}

        Inc(Field);
      until (Field = TopField);

      next_class:
      LClass := TClass(PPointer(PPointer(PByte(LClass) + vmtParent)^)^);
    until (LClass = TCustomObject);
  {$ELSE}
  next_class {dummy}:
  Self.CleanupInstance;
  {$IFEND}

  // memory
  free_memory:
  case (FRefCount shr MEMORY_SCHEME_SHIFT) and Ord(High(TMemoryScheme)) of
    Ord(msHeap):
      begin
        FreeMem(Pointer(Self));
      end;
    Ord(msAllocator):
      begin
        raise EInvalidOpException.Create('msAllocator');
      end;
    Ord(msFreeList):
      begin
        raise EInvalidOpException.Create('msFreeList');
      end;
  else
    // msUnknownBuffer
    // Do nothing
  end;
end;

function TCustomObject.GetSelf: TCustomObject;
begin
  Result := Self;
end;

class function TCustomObject.CreateEObjectDisposed: EObjectDisposed;
begin
  Result := EObjectDisposed.CreateRes(Pointer(@SObjectDisposed));
end;

class function TCustomObject.CreateEInvalidRefCount(const AObject: TObject; const ARefCount: Integer):
  EInvalidContainer;
begin
  Result := EInvalidContainer.CreateResFmt(Pointer(@SInvalidRefCount), [AObject.ClassName, ARefCount]);
end;

function TCustomObject.GetMemoryScheme: TMemoryScheme;
begin
  Result := TMemoryScheme(Integer((FRefCount shr MEMORY_SCHEME_SHIFT) and Ord(High(TMemoryScheme))));
end;

function TCustomObject.GetDisposed: Boolean;
begin
  Result := (FRefCount and DISPOSED_FLAG <> 0);
end;

procedure TCustomObject.CheckDisposed;
begin
  if (FRefCount and DISPOSED_FLAG = 0) then
    raise CreateEObjectDisposed;
end;

function TCustomObject.GetRefCount: Integer;
begin
  Result := FRefCount and REFCOUNT_MASK;
end;

procedure TCustomObject.AfterConstruction;
const
  NEGATIVE_DECREMENT = Integer(-(Int64(DUMMY_REFCOUNT) - DEFAULT_REFCOUNT));
begin
  if (FRefCount and REFCOUNT_MASK <> DUMMY_REFCOUNT) then
  begin
    AtomicIncrement(FRefCount, NEGATIVE_DECREMENT);
  end
  else
  begin
    Inc(FRefCount, NEGATIVE_DECREMENT);
  end;
end;

procedure TCustomObject.BeforeDestruction;
begin
end;

{$IFNDEF AUTOREFCOUNT}
procedure TCustomObject.Free;
begin
  DisposeOf;
end;
{$ENDIF}

function TCustomObject.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

procedure TCustomObject.DisposeOf;
type
  TBeforeDestructionProc = procedure(Instance: Pointer);
  TDestructorProc = procedure(Instance: Pointer; OuterMost: ShortInt);
var
  LRef, LFlags: Integer;
  LProc: Pointer;
  LSelf: Pointer {TCustomObject};
begin
  if (Self = nil) then
    Exit;

  // check overloaded reference counter
  // no references optimization
  LFlags := DEFAULT_DESTROY_FLAGS;
  if (PPointer(PNativeInt(Self)^ + vmtObjAddRef)^ <> @TCustomObject.__ObjAddRef) or
    (PPointer(PNativeInt(Self)^ + vmtObjRelease)^ <> @TCustomObject.__ObjRelease) then
  begin
    LFlags := DISPOSED_FLAG;
  end
  else
  begin
    {$IFNDEF AUTOREFCOUNT}
    if (FRefCount and DISPREFCOUNT_MASK = 0) then
    begin
      FRefCount := FRefCount or DEFAULT_DESTROY_FLAGS;
      Destroy;
      Exit;
    end;
    {$ENDIF}
  end;

  // has references: the instance remains alive
  // mark disposed (exit if already disposed) and dummy reference count
  repeat
    LRef := FRefCount;
    if (LRef and DISPOSED_FLAG <> 0) then
      Exit;

    if (LFlags = DEFAULT_DESTROY_FLAGS) and (Cardinal(LRef and REFCOUNT_MASK) = 1) then
    begin
      FRefCount := LRef or LFlags;
      Break;
    end;

    if (AtomicCmpExchange(FRefCount, LRef or LFlags, LRef) = LRef) then
      Break;
  until (False);

  // call destructor, optional free instance
  LSelf := Self;
  if (LFlags = DEFAULT_DESTROY_FLAGS) then
  begin
    try
      LProc := PPointer(PNativeInt(Self)^ + vmtBeforeDestruction)^;
      if (LProc <> @TCustomObject.BeforeDestruction) then
        TBeforeDestructionProc(LProc)(Self);

      LProc := PPointer(PNativeInt(Self)^ + vmtDestroy)^;
      if (LProc <> @TCustomObject.Destroy) then
        TDestructorProc(LProc)(Self, 0);
    finally
      with TCustomObject(LSelf) do
      begin
        if ((FRefCount - DUMMY_REFCOUNT) and REFCOUNT_MASK = 0) or
          (AtomicIncrement(FRefCount, Integer(-Int64(DUMMY_REFCOUNT))) and REFCOUNT_MASK = 0) then
        begin
          FreeInstance;
        end;
      end;
    end;
  end
  else
  begin
    __ObjAddRef;
    try
      LProc := PPointer(PNativeInt(Self)^ + vmtBeforeDestruction)^;
      if (LProc <> @TCustomObject.BeforeDestruction) then
        TBeforeDestructionProc(LProc)(Self);

      LProc := PPointer(PNativeInt(Self)^ + vmtDestroy)^;
      if (LProc <> @TCustomObject.Destroy) then
        TDestructorProc(LProc)(Self, 0);
    finally
      TCustomObject(LSelf).__ObjRelease;
    end;
  end;
end;

function TCustomObject.__ObjAddRef: Integer;
begin
  Result := FRefCount;
  if (Cardinal(Result and REFCOUNT_MASK) <= DEFAULT_REFCOUNT) then
  begin
    Inc(Result);
    FRefCount := Result;
    Result := Result and REFCOUNT_MASK;
    Exit;
  end
  else
  begin
    Result := AtomicIncrement(FRefCount) and REFCOUNT_MASK;
  end;
end;

function TCustomObject._AddRef: Integer; stdcall;
begin
  if (PPointer(PNativeInt(Self)^ + vmtObjAddRef)^ = @TCustomObject.__ObjAddRef) then
  begin
    Result := FRefCount;
    if (Cardinal(Result and REFCOUNT_MASK) <= DEFAULT_REFCOUNT) then
    begin
      Inc(Result);
      FRefCount := Result;
      Result := Result and REFCOUNT_MASK;
      Exit;
    end
    else
    begin
      Result := AtomicIncrement(FRefCount) and REFCOUNT_MASK;
      Exit;
    end;
  end
  else
  begin
    Result := __ObjAddRef;
  end;
end;

function TCustomObject.__ObjRelease: Integer;
begin
  // release reference
  Result := FRefCount;
  if (Result and REFCOUNT_MASK <> 1) then
  begin
    Result := AtomicDecrement(FRefCount) and REFCOUNT_MASK;
    if (Result <> 0) then
      Exit;
  end
  else
  begin
    Dec(Result);
    FRefCount := Result;
    Result := Result and REFCOUNT_MASK;
  end;

  // no references: destroy/freeinstance
  if (FRefCount and DISPOSED_FLAG = 0) then
  begin
    FRefCount := FRefCount or DEFAULT_DESTROY_FLAGS;
    Destroy;
    Exit;
  end
  else
  begin
    FreeInstance;
  end;
end;

function TCustomObject._Release: Integer; stdcall;
begin
  if (PPointer(PNativeInt(Self)^ + vmtObjRelease)^ = @TCustomObject.__ObjRelease) then
  begin
    // release reference
    Result := FRefCount;
    if (Result and REFCOUNT_MASK = 1) then
    begin
      Dec(Result);
      FRefCount := Result;
      Result := Result and REFCOUNT_MASK;
    end
    else
    begin
      Result := AtomicDecrement(FRefCount) and REFCOUNT_MASK;
      if (Result <> 0) then
        Exit;
    end;

    // no references: destroy/freeinstance
    if (FRefCount and DISPOSED_FLAG = 0) then
    begin
      FRefCount := FRefCount or DEFAULT_DESTROY_FLAGS;
      Destroy;
      Exit;
    end
    else
    begin
      FreeInstance;
      Exit;
    end;
  end
  else
  begin
    Result := __ObjRelease;
  end;
end;

function TCustomObject.InternalMonitorOptimize(const ASpinCount: Integer): TCustomObject;
begin
  TMonitor.SetSpinCount(Self, ASpinCount);
  Result := Self;
end;

function TCustomObject.MonitorOptimize: TCustomObject;
const
  OPTIMIZED_SPIN_COUNT = 5;
var
  LSize: Integer;
  LMonitor: NativeInt;
  LField: PInteger;
begin
  Result := Self;
  LSize := PInteger(PNativeInt(Result)^ + vmtInstanceSize)^;
  LMonitor := PNativeInt(PByte(Result) + LSize + (-hfFieldSize + hfMonitorOffset))^;
  {$IF CompilerVersion >= 32}
  LMonitor := LMonitor and monMonitorMask;
  {$IFEND}
  if (LMonitor <> 0) then
  begin
    LField := PInteger(LMonitor + (SizeOf(Integer) + SizeOf(Integer) + SizeOf(System.TThreadID) + SizeOf(Pointer)));
    if (LField^ = OPTIMIZED_SPIN_COUNT) then
      Exit;

    if (CPUCount = 1) then
      Exit;
  end;

  Result := Result.InternalMonitorOptimize(OPTIMIZED_SPIN_COUNT);
end;

function TCustomObject.TryEnter: Boolean;
begin
  Result := TMonitor.TryEnter(MonitorOptimize);
end;

function TCustomObject.Enter(const ATimeout: Cardinal): Boolean;
begin
  Result := TMonitor.Enter(MonitorOptimize, ATimeout);
end;

procedure TCustomObject.Enter;
begin
  TMonitor.Enter(MonitorOptimize);
end;

procedure TCustomObject.Leave;
begin
  TMonitor.Exit(MonitorOptimize);
end;

function TCustomObject.Wait(const ATimeout: Cardinal): Boolean;
begin
  Result := TMonitor.Wait(MonitorOptimize, ATimeout);
end;

procedure TCustomObject.Wait;
begin
  TMonitor.Wait(MonitorOptimize, INFINITE);
end;

class procedure TCustomObject.CreateIntfTables;
begin
  TCustomObject.FInterfaceTable[0] := @TCustomObject.IntfQueryInterface;
  TCustomObject.FInterfaceTable[1] := @TCustomObject.IntfAddRef;
  TCustomObject.FInterfaceTable[2] := @TCustomObject.IntfRelease;
end;

{$IF CompilerVersion >= 31}
class constructor TCustomObject.ClassConstructor;
begin
  CreateIntfTables;
end;
{$IFEND}

class function TCustomObject.IntfQueryInterface(const Self: PByte;
  const IID: TGUID; out Obj): HResult; stdcall;
begin
  with TCustomObject(Self - 2 * SizeOf(Pointer)) do
    Result := QueryInterface(IID, Obj);
end;

class function TCustomObject.IntfAddRef(const Self: PByte): Integer; stdcall;
begin
  with TCustomObject(Self - 2 * SizeOf(Pointer)) do
    Result := _AddRef;
end;

class function TCustomObject.IntfRelease(const Self: PByte): Integer; stdcall;
begin
  with TCustomObject(Self - 2 * SizeOf(Pointer)) do
    Result := _Release;
end;

{ TLiteCustomObject }

class function TLiteCustomObject.NewInstance: TObject;
type
  HugePointerArray = array[0..High(Integer) div SizeOf(NativeInt) - 1] of Pointer;
  PHugePointerArray = ^HugePointerArray;
begin
  Result := inherited NewInstance;
  PHugePointerArray(Result)[2] := @TLiteCustomObject.FInterfaceTable;
  PHugePointerArray(Result)[3] := @TLiteCustomObject.FCustomObjectTable;
end;

class function TLiteCustomObject.PreallocatedInstance(const AMemory: Pointer;
  const AMemoryScheme: TMemoryScheme): TObject;
type
  HugePointerArray = array[0..High(Integer) div SizeOf(NativeInt) - 1] of Pointer;
  PHugePointerArray = ^HugePointerArray;
begin
  Result := inherited PreallocatedInstance(AMemory, AMemoryScheme);
  PHugePointerArray(Result)[2] := @TLiteCustomObject.FInterfaceTable;
  PHugePointerArray(Result)[3] := @TLiteCustomObject.FCustomObjectTable;
end;

function TLiteCustomObject.__ObjAddRef: Integer;
begin
  Result := FRefCount + 1;
  FRefCount := Result;
  Result := Result and REFCOUNT_MASK;
end;

function TLiteCustomObject._AddRef: Integer;
begin
  if (PPointer(PNativeInt(Self)^ + vmtObjAddRef)^ = @TLiteCustomObject.__ObjAddRef) then
  begin
    Result := FRefCount + 1;
    FRefCount := Result;
    Result := Result and REFCOUNT_MASK;
    Exit;
  end
  else
  begin
    Result := __ObjAddRef;
  end;
end;

function TLiteCustomObject.__ObjRelease: Integer;
begin
  Result := FRefCount - 1;
  FRefCount := Result;
  Result := Result and REFCOUNT_MASK;
  if (Result <> 0) then
    Exit;

  if (FRefCount and DISPOSED_FLAG = 0) then
  begin
    FRefCount := FRefCount or DEFAULT_DESTROY_FLAGS;
    Destroy;
    Exit;
  end
  else
  begin
    FreeInstance;
  end;
end;

function TLiteCustomObject._Release: Integer;
begin
  if (PPointer(PNativeInt(Self)^ + vmtObjRelease)^ = @TLiteCustomObject.__ObjRelease) then
  begin
    Result := FRefCount - 1;
    FRefCount := Result;
    Result := Result and REFCOUNT_MASK;
    if (Result <> 0) then
      Exit;

    if (FRefCount and DISPOSED_FLAG = 0) then
    begin
      FRefCount := FRefCount or DEFAULT_DESTROY_FLAGS;
      Destroy;
      Exit;
    end
    else
    begin
      FreeInstance;
      Exit;
    end;
  end
  else
  begin
    Result := __ObjRelease;
  end;
end;

class procedure TLiteCustomObject.CreateIntfTables;
var
  LTable: PInterfaceTable;
begin
  TLiteCustomObject.FInterfaceTable := TCustomObject.FInterfaceTable;
  TLiteCustomObject.FInterfaceTable[1] := @TLiteCustomObject.IntfAddRef;
  TLiteCustomObject.FInterfaceTable[2] := @TLiteCustomObject.IntfRelease;

  LTable := PInterfaceTable(PPointer(PByte(TCustomObject) + vmtIntfTable)^);
  System.Move(LTable.Entries[0].VTable^, TLiteCustomObject.FCustomObjectTable,
    SizeOf(TLiteCustomObject.FCustomObjectTable));
  TLiteCustomObject.FCustomObjectTable[1] := @TLiteCustomObject.CustomObjectAddRef;
  TLiteCustomObject.FCustomObjectTable[2] := @TLiteCustomObject.CustomObjectRelease;
end;

{$IF CompilerVersion >= 31}
class constructor TLiteCustomObject.ClassConstructor;
begin
  CreateIntfTables;
end;
{$IFEND}

class function TLiteCustomObject.IntfAddRef(const Self: PByte): Integer; stdcall;
begin
  with TLiteCustomObject(Self - 2 * SizeOf(Pointer)) do
    Result := _AddRef;
end;

class function TLiteCustomObject.IntfRelease(const Self: PByte): Integer; stdcall;
begin
  with TLiteCustomObject(Self - 2 * SizeOf(Pointer)) do
    Result := _Release;
end;

class function TLiteCustomObject.CustomObjectAddRef(const Self: PByte): Integer; stdcall;
begin
  with TLiteCustomObject(Self - 3 * SizeOf(Pointer)) do
    Result := _AddRef;
end;

class function TLiteCustomObject.CustomObjectRelease(const Self: PByte): Integer; stdcall;
begin
  with TLiteCustomObject(Self - 3 * SizeOf(Pointer)) do
    Result := _Release;
end;

{ TRAIIHelper.TClearNatives }

procedure TRAIIHelper.TClearNatives.Clear;
begin
  TRAIIHelper.UnregisterDynamicArray(Pointer(Items));
  Items := nil;
  Count := 0;
end;

procedure TRAIIHelper.TClearNatives.Add(AOffset: NativeInt; ADynTypeInfo: PTypeInfo;
  AClearNativeProc: TClearNativeProc);
begin
  if (Count = 0) then
  begin
    ItemSingle.ClearNativeProc := AClearNativeProc;
    ItemSingle.Offset := AOffset;
    ItemSingle.DynTypeInfo := ADynTypeInfo;
  end;

  Inc(Count);
  SetLength(Items, Count);
  with Items[Count - 1] do
  begin
    ClearNativeProc := AClearNativeProc;
    Offset := AOffset;
    DynTypeInfo := ADynTypeInfo;
  end;
end;

{$IFDEF WEAKINSTREF}
{ TRAIIHelper.TInitNatives }

procedure TRAIIHelper.TInitNatives.Clear;
begin
  TRAIIHelper.UnregisterDynamicArray(Pointer(Items));
  Items := nil;
  Count := 0;
end;

procedure TRAIIHelper.TInitNatives.Add(AOffset: NativeInt);
begin
  if (Count = 0) then
  begin
    ItemSingle.Offset := AOffset;
  end;

  Inc(Count);
  SetLength(Items, Count);
  Items[Count - 1].Offset := AOffset;
end;
{$ENDIF}

{ TRAIIHelper.TStaticArrays }

procedure TRAIIHelper.TStaticArrays.Clear;
begin
  TRAIIHelper.UnregisterDynamicArray(Pointer(Items));
  Items := nil;
  Count := 0;
end;

procedure TRAIIHelper.TStaticArrays.Add(AOffset: NativeInt; AStaticTypeInfo: PTypeInfo; ACount: NativeUInt);
begin
  Inc(Count);
  SetLength(Items, Count);
  with Items[Count - 1] do
  begin
    Offset := AOffset;
    StaticTypeInfo := AStaticTypeInfo;
    Count := ACount;
  end;
end;

{ TRAIIHelper }

{$WARNINGS OFF} // compiler can't correctly identify initialized variables

class procedure TRAIIHelper.RegisterDynamicArray(const P: Pointer);
begin
  {$IFDEF MSWINDOWS}
  if (Assigned(P)) then
    System.RegisterExpectedMemoryLeak(Pointer(NativeInt(P) - SizeOf(TDynArrayRec)));
  {$ENDIF}
end;

class procedure TRAIIHelper.UnregisterDynamicArray(const P: Pointer);
begin
  {$IFDEF MSWINDOWS}
  if (Assigned(P)) then
    System.UnregisterExpectedMemoryLeak(Pointer(NativeInt(P) - SizeOf(TDynArrayRec)));
  {$ENDIF}
end;
{$WARNINGS ON}

class procedure TRAIIHelper.ULStrClear(P: Pointer);
type
  PStrRec = ^StrRec;
  StrRec = packed record
    {$IFDEF LARGEINT}
    _Padding: Integer;
    {$ENDIF}
    codePage: Word;
    elemSize: Word;
    refCnt: Integer;
    length: Integer;
  end;
var
  Rec: PStrRec;
  RefCnt: Integer;
begin
  Rec := PPointer(P)^;
  Dec(Rec);
  RefCnt := Rec.refCnt;
  if (RefCnt > 0) then
  begin
    if (RefCnt = 1) or (AtomicDecrement(Rec.refCnt) = 0) then
      FreeMem(Rec);
  end;
end;

{$IFDEF MSWINDOWS}
procedure SysFreeString(P: Pointer); stdcall; external 'oleaut32.dll';

class procedure TRAIIHelper.WStrClear(P: Pointer);
begin
  SysFreeString(PPointer(P)^);
end;
{$ENDIF}

class procedure TRAIIHelper.IntfClear(P: Pointer);
begin
  IInterface(PPointer(P)^)._Release;
end;

class procedure TRAIIHelper.VarClear(P: Pointer);
var
  VType: Integer;
begin
  VType := PVarData(P).VType;
  if (VType and varDeepData <> 0) and (VType <> varBoolean) and
    (Cardinal(VType - (varUnknown + 1)) > (varUInt64 - varUnknown - 1)) then
    System.VarClear(PVariant(P)^);
end;

class procedure TRAIIHelper.DynArrayClear(P, TypeInfo: Pointer);
var
  Rec: PDynArrayRec;
  RefCnt: Integer;
begin
  Rec := PPointer(P)^;
  Dec(Rec);
  RefCnt := Rec.RefCnt;
  if (RefCnt > 0) then
  begin
    if (RefCnt = 1) or (AtomicDecrement(Rec.RefCnt) = 0) then
    begin
      Inc(PByte(TypeInfo), PByte(@PDynArrayTypeInfo(TypeInfo).name)^);
      TypeInfo := PDynArrayTypeInfo(TypeInfo).elType;
      if (TypeInfo <> nil) and (Rec.Length <> 0) then
      begin
        System.FinalizeArray(Pointer(NativeUInt(Rec) + SizeOf(TDynArrayRec)),
          PPointer(TypeInfo)^, Rec.Length);
      end;

      FreeMem(Rec);
    end;
  end;
end;

{$IFDEF AUTOREFCOUNT}
class procedure TRAIIHelper.RefObjClear(P: Pointer);
begin
  TObject(PPointer(P)^).__ObjRelease;
end;
{$ENDIF}

{$IFDEF WEAKINSTREF}
class procedure TRAIIHelper.WeakObjClear(P: Pointer);
{$IFDEF CPUINTELASM}
asm
  jmp System.@InstWeakClear
end;
{$ELSE}
type
  TInstance = record
    [Weak]Obj: TObject;
  end;
  PInstance = ^TInstance;
begin
  PInstance(P).Obj := nil;
end;
{$ENDIF}

class procedure TRAIIHelper.WeakMethodClear(P: Pointer);
{$IFDEF CPUINTELASM}
asm
  {$IFDEF CPUX86}
    sub eax, 4
  {$ELSE}
    sub rcx, 8
  {$ENDIF}
  jmp System.@ClosureRemoveWeakRef
end;
{$ELSE}
type
  TInstance = record
    Method: procedure of object;
  end;
  PInstance = ^TInstance;
begin
  PInstance(NativeInt(P) - SizeOf(Pointer)).Method := nil;
end;
{$ENDIF}
{$ENDIF}

{$IFDEF WEAKINTFREF}
class procedure TRAIIHelper.WeakIntfClear(P: Pointer);
{$IFDEF CPUINTELASM}
asm
  jmp System.@IntfWeakClear
end;
{$ELSE}
type
  TInstance = record
    [Weak]Intf: IInterface;
  end;
  PInstance = ^TInstance;
begin
  PInstance(P).Intf := nil;
end;
{$ENDIF}
{$ENDIF}

procedure TRAIIHelper.Include(AOffset: NativeInt; Value: PTypeInfo);
var
  i: Cardinal;
  {$IFDEF WEAKREF}
  WeakMode: Boolean;
  {$ENDIF}
  FieldTable: PFieldTable;
  ChildSize, ChildOffset: NativeInt;
begin
  case Value.Kind of
    tkVariant:
      begin
        {$IFDEF WEAKINSTREF}
        Self.InitNatives.Add(AOffset);
        Self.ClearNatives.Add(AOffset, nil, TClearNativeProc(@TRAIIHelper.VarClear));
        {$ELSE}
        Self.Natives.Add(AOffset, nil, TClearNativeProc(@TRAIIHelper.VarClear));
        {$ENDIF}
      end;
    {$IFDEF AUTOREFCOUNT}
    tkClass:
      begin
        {$IFDEF WEAKINSTREF}
        Self.InitNatives.Add(AOffset);
        Self.ClearNatives.Add(AOffset, nil, TClearNativeProc(@TRAIIHelper.RefObjClear));
        {$ELSE}
        Self.Natives.Add(AOffset, nil, TClearNativeProc(@TRAIIHelper.RefObjClear));
        {$ENDIF}
      end;
    {$ENDIF}
    {$IFDEF WEAKINSTREF}
    tkMethod:
      begin
        Self.FWeak := True;
        Self.InitNatives.Add(AOffset);
        Self.InitNatives.Add(AOffset + SizeOf(Pointer));
        Self.ClearNatives.Add(AOffset + SizeOf(Pointer), nil, TClearNativeProc(@TRAIIHelper.WeakMethodClear));
      end;
    {$ENDIF}
    {$IFDEF MSWINDOWS}
    tkWString:
      begin
        {$IFDEF WEAKINSTREF}
        Self.InitNatives.Add(AOffset);
        Self.ClearNatives.Add(AOffset, nil, TClearNativeProc(@TRAIIHelper.WStrClear));
        {$ELSE}
        Self.Natives.Add(AOffset, nil, TClearNativeProc(@TRAIIHelper.WStrClear));
        {$ENDIF}
      end;
    {$ELSE}
    tkWString,
      {$ENDIF}
    tkLString, tkUString:
      begin
        {$IFDEF WEAKINSTREF}
        Self.InitNatives.Add(AOffset);
        Self.ClearNatives.Add(AOffset, nil, TClearNativeProc(@TRAIIHelper.ULStrClear));
        {$ELSE}
        Self.Natives.Add(AOffset, nil, TClearNativeProc(@TRAIIHelper.ULStrClear));
        {$ENDIF}
      end;
    tkInterface:
      begin
        {$IFDEF WEAKINSTREF}
        Self.InitNatives.Add(AOffset);
        Self.ClearNatives.Add(AOffset, nil, TClearNativeProc(@TRAIIHelper.IntfClear));
        {$ELSE}
        Self.Natives.Add(AOffset, nil, TClearNativeProc(@TRAIIHelper.IntfClear));
        {$ENDIF}
      end;
    tkDynArray:
      begin
        {$IFDEF WEAKINSTREF}
        Self.InitNatives.Add(AOffset);
        Self.ClearNatives.Add(AOffset, Value, TClearNativeProc(@TRAIIHelper.DynArrayClear));
        {$ELSE}
        Self.Natives.Add(AOffset, Value, TClearNativeProc(@TRAIIHelper.DynArrayClear));
        {$ENDIF}
      end;
    tkArray {static array}:
      begin
        FieldTable := PFieldTable(NativeUInt(Value) + PByte(@Value.Name)^);
        if (FieldTable.Fields[0].TypeInfo <> nil) and IsManagedTypeInfo(FieldTable.Fields[0].TypeInfo^) then
        begin
          if (FieldTable.Count > 4) then
          begin
            Self.StaticArrays.Add(AOffset, FieldTable.Fields[0].TypeInfo^, FieldTable.Count);
          end
          else
          begin
            ChildSize := FieldTable.Size div FieldTable.Count;
            for i := 1 to FieldTable.Count do
            begin
              Self.Include(AOffset, FieldTable.Fields[0].TypeInfo^);
              Inc(AOffset, ChildSize);
            end;
          end;
        end;
      end;
    tkRecord:
      begin
        FieldTable := PFieldTable(NativeUInt(Value) + PByte(@Value.Name)^);
        if FieldTable.Count > 0 then
        begin
          {$IFDEF WEAKREF}
          WeakMode := False;
          {$ENDIF}
          for i := 0 to FieldTable.Count - 1 do
          begin
            ChildOffset := AOffset + NativeInt(FieldTable.Fields[i].Offset);
            {$IFDEF WEAKREF}
            if FieldTable.Fields[i].TypeInfo = nil then
            begin
              WeakMode := True;
              Self.FWeak := True;
              Continue;
            end;
            if (not WeakMode) then
            begin
              {$ENDIF}
              Self.Include(ChildOffset, FieldTable.Fields[i].TypeInfo^);
              {$IFDEF WEAKREF}
            end
            else
              case FieldTable.Fields[i].TypeInfo^.Kind of
                {$IFDEF WEAKINTFREF}
                tkInterface:
                  begin
                    {$IFDEF WEAKINSTREF}
                    Self.InitNatives.Add(ChildOffset);
                    Self.ClearNatives.Add(ChildOffset, nil, TClearNativeProc(@TRAIIHelper.WeakIntfClear));
                    {$ELSE}
                    Self.Natives.Add(ChildOffset, nil, TClearNativeProc(@TRAIIHelper.WeakIntfClear));
                    {$ENDIF}
                  end;
                {$ENDIF}
                {$IFDEF WEAKINSTREF}
                tkClass:
                  begin
                    Self.InitNatives.Add(ChildOffset);
                    Self.ClearNatives.Add(ChildOffset, nil, TClearNativeProc(@TRAIIHelper.WeakObjClear));
                  end;
                tkMethod:
                  begin
                    Self.InitNatives.Add(ChildOffset);
                    Self.InitNatives.Add(ChildOffset + SizeOf(Pointer));

                    Self.ClearNatives.Add(ChildOffset + SizeOf(Pointer), nil,
                      TClearNativeProc(@TRAIIHelper.WeakMethodClear));
                  end;
                {$ENDIF}
              end;
            {$ENDIF .WEAKREF}
          end;
        end;
      end;
  end;
end;

function TRAIIHelper.GetTypeData: PTypeData;
begin
  Result := Pointer(FTypeInfo);
  Inc(NativeUInt(Result), NativeUInt(PByte(@PTypeInfo(Result).Name)^) + 2);
end;

procedure TRAIIHelper.Initialize(Value: PTypeInfo);
var
  FieldTable: PFieldTable;
  TypeData: PTypeData;
begin
  // clear
  FTypeInfo := Value;
  FItemSize := 0;
  FWeak := False;
  {$IFDEF WEAKINSTREF}
  InitNatives.Clear;
  ClearNatives.Clear;
  {$ELSE}
  Natives.Clear;
  {$ENDIF}
  StaticArrays.Clear;
  InitProc := nil;
  ClearProc := nil;
  InitArrayProc := nil;
  ClearArrayProc := nil;

  // type data
  TypeData := Pointer(Value);
  Inc(NativeUInt(TypeData), NativeUInt(PByte(@PTypeInfo(TypeData).Name)^) + 2);

  // type kind
  case Value.Kind of
    tkInteger, tkChar, tkEnumeration, tkWChar:
      begin
        case (TypeData.OrdType) of
          otSByte, otUByte: FSize := SizeOf(Byte);
          otSWord, otUWord: FSize := SizeOf(Word);
          otSLong, otULong: FSize := SizeOf(Cardinal);
        end;
        Exit;
      end;
    tkSet:
      begin
        TypeData := Pointer(TypeData.CompType^);
        Inc(NativeUInt(TypeData), NativeUInt(PByte(@PTypeInfo(TypeData).Name)^) + 2);
        with TypeData^ do
        begin
          FSize := (((MaxValue + 7 + 1) and ($FF shl 3)) - (MinValue and ($FF shl 3))) shr 3;
          if (FSize = 3) then
            FSize := 4;
        end;
        Exit;
      end;
    tkFloat:
      begin
        case (TypeData.FloatType) of
          ftSingle: FSize := SizeOf(Single);
          ftDouble: FSize := SizeOf(Double);
          ftExtended: FSize := SizeOf(Extended);
        else
          FItemSize := -1;
          case (TypeData.FloatType) of
            ftComp: FSize := SizeOf(Comp);
            ftCurr: FSize := SizeOf(Currency);
          end;
        end;
        Exit;
      end;
    tkInt64:
      begin
        FSize := SizeOf(Int64);
        Exit;
      end;
    {$IFDEF SHORTSTRSUPPORT}
    tkString:
      begin
        FSize := TypeData.MaxLength + 1;
        Exit;
      end;
    {$ENDIF}
    tkClassRef, tkPointer, tkProcedure:
      begin
        FSize := SizeOf(Pointer);
        Exit;
      end;

    tkVariant:
      begin
        FSize := SizeOf(Variant);
        Self.Include(0, Value);
      end;
    tkMethod:
      begin
        FSize := SizeOf(TMethod);
        Self.Include(0, Value);
      end;
    tkClass, tkLString, tkWString, tkInterface, tkUString:
      begin
        FSize := SizeOf(Pointer);
        Self.Include(0, Value);
      end;
    tkDynArray:
      begin
        FSize := SizeOf(Pointer);
        FItemSize := TypeData.elSize;
        Self.Include(0, Value);
      end;
    tkArray:
      begin
        FieldTable := PFieldTable(NativeUInt(Value) + PByte(@Value.Name)^);
        FSize := FieldTable.Size;
        FItemSize := FieldTable.Size div FieldTable.Count;
        Self.Include(0, Value);
      end;
    tkRecord:
      begin
        FieldTable := PFieldTable(NativeUInt(Value) + PByte(@Value.Name)^);
        FSize := FieldTable.Size;
        Self.Include(0, Value);
      end;
  else
    System.Error(reInvalidPtr);
  end;

  // initialization
  if (StaticArrays.Count <> 0) then
  begin
    InitProc := Self.InitsProc;
    InitArrayProc := Self.InitsArrayProc;
  end
  else
    case ({$IFDEF WEAKINSTREF}InitNatives{$ELSE}Natives{$ENDIF}.Count) of
      0: ;
      1:
        begin
          InitProc := Self.InitsProcNativeOne;
          InitArrayProc := Self.InitsArrayProcNativeOne;
        end;
      2:
        begin
          InitProc := Self.InitsProcNativeTwo;
          InitArrayProc := Self.InitsArrayProcNativeTwo;
        end;
      3:
        begin
          InitProc := Self.InitsProcNativeThree;
          InitArrayProc := Self.InitsArrayProcNativeThree;
        end;
    else
      InitProc := Self.InitsProcNatives;
      InitArrayProc := Self.InitsArrayProcNatives;
    end;

  // finalization
  if (StaticArrays.Count <> 0) then
  begin
    ClearProc := Self.ClearsProc;
    ClearArrayProc := Self.ClearsArrayProc;
  end
  else
    case ({$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.Count) of
      0: ;
      1:
        begin
          ClearProc := Self.ClearsProcNativeOne;
          ClearArrayProc := Self.ClearsArrayProcNativeOne;
        end;
      2:
        begin
          ClearProc := Self.ClearsProcNativeTwo;
          ClearArrayProc := Self.ClearsArrayProcNativeTwo;
        end;
      3:
        begin
          ClearProc := Self.ClearsProcNativeThree;
          ClearArrayProc := Self.ClearsArrayProcNativeThree;
        end;
    else
      ClearProc := Self.ClearsProcNatives;
      ClearArrayProc := Self.ClearsArrayProcNatives;
    end;

  // dynamic arrays
  {$IFDEF WEAKINSTREF}
  TRAIIHelper.RegisterDynamicArray(Pointer(InitNatives.Items));
  TRAIIHelper.RegisterDynamicArray(Pointer(ClearNatives.Items));
  {$ELSE}
  TRAIIHelper.RegisterDynamicArray(Pointer(Natives.Items));
  {$ENDIF}
end;

class function TRAIIHelper.IsManagedTypeInfo(Value: PTypeInfo): Boolean;
var
  i: Cardinal;
  {$IFDEF WEAKREF}
  WeakMode: Boolean;
  {$ENDIF}
  FieldTable: PFieldTable;
begin
  Result := False;

  if Assigned(Value) then
    case Value.Kind of
      tkVariant:
        begin
          Exit(True);
        end;
      {$IFDEF AUTOREFCOUNT}
      tkClass:
        begin
          Exit(True);
        end;
      {$ENDIF}
      {$IFDEF WEAKINSTREF}
      tkMethod:
        begin
          Exit(True);
        end;
      {$ENDIF}
      tkWString, tkLString, tkUString, tkInterface, tkDynArray:
        begin
          Exit(True);
        end;
      tkArray {static array}:
        begin
          FieldTable := PFieldTable(NativeUInt(Value) + PByte(@Value.Name)^);
          if (FieldTable.Fields[0].TypeInfo <> nil) then
            Result := IsManagedTypeInfo(FieldTable.Fields[0].TypeInfo^);
        end;
      tkRecord:
        begin
          FieldTable := PFieldTable(NativeUInt(Value) + PByte(@Value.Name)^);
          if FieldTable.Count > 0 then
          begin
            {$IFDEF WEAKREF}
            WeakMode := False;
            {$ENDIF}
            for i := 0 to FieldTable.Count - 1 do
            begin
              {$IFDEF WEAKREF}
              if FieldTable.Fields[i].TypeInfo = nil then
              begin
                WeakMode := True;
                Continue;
              end;
              if (not WeakMode) then
              begin
                {$ENDIF}
                if (IsManagedTypeInfo(FieldTable.Fields[i].TypeInfo^)) then
                  Exit(True);
                {$IFDEF WEAKREF}
              end
              else
              begin
                Exit(True);
              end;
              {$ENDIF}
            end;
          end;
        end;
    end;
end;

class function TRAIIHelper.InitsProcNativeOne(const Self: TRAIIHelper; P: Pointer): Pointer;
begin
  Inc(NativeInt(P), Self. {$IFDEF WEAKINSTREF}InitNatives{$ELSE}Natives{$ENDIF}.ItemSingle.Offset);
  PNativeInt(P)^ := 0;
  Result := P;
end;

class procedure TRAIIHelper.InitsArrayProcNativeOne(const Self: TRAIIHelper;
  P, Overflow: Pointer; ItemSize: NativeUInt);
var
  Offset: NativeInt;
  Null: NativeInt;
  LItemSize: NativeInt;
begin
  Offset := Self. {$IFDEF WEAKINSTREF}InitNatives{$ELSE}Natives{$ENDIF}.ItemSingle.Offset;
  Inc(NativeInt(P), Offset);
  Inc(NativeInt(Overflow), Offset);

  LItemSize := ItemSize;
  Null := 0;
  if (P <> Overflow) then
    repeat
      PNativeInt(P)^ := Null;
      Inc(NativeUInt(P), LItemSize);
    until (P = Overflow);
end;

class function TRAIIHelper.InitsProcNativeTwo(const Self: TRAIIHelper; P: Pointer): Pointer;
var
  Null: NativeInt;
  Item: ^ {$IFDEF WEAKINSTREF}TInitNativeRec{$ELSE}TNativeRec{$ENDIF};
begin
  Item := Pointer(Self. {$IFDEF WEAKINSTREF}InitNatives{$ELSE}Natives{$ENDIF}.Items);
  Null := 0;

  PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
  Inc(Item);
  PNativeInt(NativeInt(P) + Item.Offset)^ := Null;

  Result := P;
end;

class procedure TRAIIHelper.InitsArrayProcNativeTwo(const Self: TRAIIHelper;
  P, Overflow: Pointer; ItemSize: NativeUInt);
var
  Ptr: PNativeInt;
  Item: ^ {$IFDEF WEAKINSTREF}TInitNativeRec{$ELSE}TNativeRec{$ENDIF};
  StoredItem: Pointer;
begin
  StoredItem := Pointer(Self. {$IFDEF WEAKINSTREF}InitNatives{$ELSE}Natives{$ENDIF}.Items);

  if (P <> Overflow) then
    repeat
      Item := StoredItem;

      Ptr := P;
      Inc(NativeInt(Ptr), Item.Offset);
      Ptr^ := 0;
      Inc(Item);
      Ptr := P;
      Inc(NativeInt(Ptr), Item.Offset);
      Ptr^ := 0;

      Inc(NativeUInt(P), ItemSize);
    until (P = Overflow);
end;

class function TRAIIHelper.InitsProcNativeThree(const Self: TRAIIHelper; P: Pointer): Pointer;
var
  Null: NativeInt;
  Item: ^ {$IFDEF WEAKINSTREF}TInitNativeRec{$ELSE}TNativeRec{$ENDIF};
begin
  Item := Pointer(Self. {$IFDEF WEAKINSTREF}InitNatives{$ELSE}Natives{$ENDIF}.Items);
  Null := 0;

  PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
  Inc(Item);
  PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
  Inc(Item);
  PNativeInt(NativeInt(P) + Item.Offset)^ := Null;

  Result := P;
end;

class procedure TRAIIHelper.InitsArrayProcNativeThree(const Self: TRAIIHelper;
  P, Overflow: Pointer; ItemSize: NativeUInt);
var
  Ptr: PNativeInt;
  Item: ^ {$IFDEF WEAKINSTREF}TInitNativeRec{$ELSE}TNativeRec{$ENDIF};
  StoredItem: Pointer;
begin
  StoredItem := Pointer(Self. {$IFDEF WEAKINSTREF}InitNatives{$ELSE}Natives{$ENDIF}.Items);

  if (P <> Overflow) then
    repeat
      Item := StoredItem;

      Ptr := P;
      Inc(NativeInt(Ptr), Item.Offset);
      Ptr^ := 0;
      Inc(Item);
      Ptr := P;
      Inc(NativeInt(Ptr), Item.Offset);
      Ptr^ := 0;
      Ptr := P;
      Inc(NativeInt(Ptr), Item.Offset);
      Ptr^ := 0;

      Inc(NativeUInt(P), ItemSize);
    until (P = Overflow);
end;

class function TRAIIHelper.InitsProcNatives(const Self: TRAIIHelper; P: Pointer): Pointer;
label
  _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11;
var
  Count, Null: NativeInt;
  Item: ^ {$IFDEF WEAKINSTREF}TInitNativeRec{$ELSE}TNativeRec{$ENDIF};
begin
  Item := Pointer(Self. {$IFDEF WEAKINSTREF}InitNatives{$ELSE}Natives{$ENDIF}.Items);
  Count := Self. {$IFDEF WEAKINSTREF}InitNatives{$ELSE}Natives{$ENDIF}.Count;
  Null := 0;

  case Count of
    11:
      begin
        _11:
        Dec(Count, 10);
        repeat
          PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
          Dec(Count);
          Inc(Item);
        until (Count = 0);
        goto _10;
      end;
    10:
      begin
        _10:
        PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
        Inc(Item);
        goto _9;
      end;
    9:
      begin
        _9:
        PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
        Inc(Item);
        goto _8;
      end;
    8:
      begin
        _8:
        PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
        Inc(Item);
        goto _7;
      end;
    7:
      begin
        _7:
        PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
        Inc(Item);
        goto _6;
      end;
    6:
      begin
        _6:
        PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
        Inc(Item);
        goto _5;
      end;
    5:
      begin
        _5:
        PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
        Inc(Item);
        goto _4;
      end;
    4:
      begin
        _4:
        PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
        Inc(Item);
        goto _3;
      end;
    3:
      begin
        _3:
        PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
        Inc(Item);
        goto _2;
      end;
    2:
      begin
        _2:
        PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
        Inc(Item);
        goto _1;
      end;
    1:
      begin
        _1:
        PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
      end;
    0: ;
  else
    goto _11;
  end;

  Result := P;
end;

class procedure TRAIIHelper.InitsArrayProcNatives(const Self: TRAIIHelper;
  P, Overflow: Pointer; ItemSize: NativeUInt);
label
  _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11;
var
  Count, Null: NativeInt;
  Item: ^ {$IFDEF WEAKINSTREF}TInitNativeRec{$ELSE}TNativeRec{$ENDIF};
  Stored: record
    Item: Pointer;
    Count: NativeInt;
  end;
begin
  Stored.Item := Pointer(Self. {$IFDEF WEAKINSTREF}InitNatives{$ELSE}Natives{$ENDIF}.Items);
  Stored.Count := Self. {$IFDEF WEAKINSTREF}InitNatives{$ELSE}Natives{$ENDIF}.Count;

  if (P <> Overflow) then
    repeat
      Item := Stored.Item;
      Count := Stored.Count;
      Null := 0;

      case Count of
        11:
          begin
            _11:
            Dec(Count, 10);
            repeat
              PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
              Dec(Count);
              Inc(Item);
            until (Count = 0);
            goto _10;
          end;
        10:
          begin
            _10:
            PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
            Inc(Item);
            goto _9;
          end;
        9:
          begin
            _9:
            PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
            Inc(Item);
            goto _8;
          end;
        8:
          begin
            _8:
            PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
            Inc(Item);
            goto _7;
          end;
        7:
          begin
            _7:
            PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
            Inc(Item);
            goto _6;
          end;
        6:
          begin
            _6:
            PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
            Inc(Item);
            goto _5;
          end;
        5:
          begin
            _5:
            PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
            Inc(Item);
            goto _4;
          end;
        4:
          begin
            _4:
            PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
            Inc(Item);
            goto _3;
          end;
        3:
          begin
            _3:
            PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
            Inc(Item);
            goto _2;
          end;
        2:
          begin
            _2:
            PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
            Inc(Item);
            goto _1;
          end;
        1:
          begin
            _1:
            PNativeInt(NativeInt(P) + Item.Offset)^ := Null;
          end;
        0: ;
      else
        goto _11;
      end;

      Inc(NativeUInt(P), ItemSize);
    until (P = Overflow);
end;

class function TRAIIHelper.InitsProc(const Self: TRAIIHelper; P: Pointer): Pointer;
var
  i: NativeInt;
  Item: ^ {$IFDEF WEAKINSTREF}TInitNativeRec{$ELSE}TNativeRec{$ENDIF};
  StaticArrayRec: ^TStaticArrayRec;
begin
  Item := Pointer(Self. {$IFDEF WEAKINSTREF}InitNatives{$ELSE}Natives{$ENDIF}.Items);
  for i := 1 to Self. {$IFDEF WEAKINSTREF}InitNatives{$ELSE}Natives{$ENDIF}.Count do
  begin
    PNativeInt(NativeInt(P) + Item.Offset)^ := 0;
    Inc(Item);
  end;

  StaticArrayRec := Pointer(Self.StaticArrays.Items);
  for i := 1 to Self.StaticArrays.Count do
  begin
    System.InitializeArray(Pointer(NativeInt(P) + StaticArrayRec.Offset),
      StaticArrayRec.StaticTypeInfo, StaticArrayRec.Count);
    Inc(StaticArrayRec);
  end;

  Result := P;
end;

class procedure TRAIIHelper.InitsArrayProc(const Self: TRAIIHelper;
  P, Overflow: Pointer; ItemSize: NativeUInt);
var
  Item, OverflowItem: ^TClearNativeRec;
  StaticArrayRec, OverflowStaticArrayRec: ^TStaticArrayRec;
begin
  if (P <> Overflow) then
    repeat
      Item := Pointer(Self. {$IFDEF WEAKINSTREF}InitNatives{$ELSE}Natives{$ENDIF}.Items);
      OverflowItem := Item + Self. {$IFDEF WEAKINSTREF}InitNatives{$ELSE}Natives{$ENDIF}.Count;
      if (Item <> OverflowItem) then
        repeat
          PNativeInt(NativeInt(P) + Item.Offset)^ := 0;
          Inc(Item);
        until (Item = OverflowItem);

      StaticArrayRec := Pointer(Self.StaticArrays.Items);
      OverflowStaticArrayRec := StaticArrayRec + Self.StaticArrays.Count;
      if (StaticArrayRec <> OverflowStaticArrayRec) then
        repeat
          System.InitializeArray(Pointer(NativeInt(P) + StaticArrayRec.Offset),
            StaticArrayRec.StaticTypeInfo, StaticArrayRec.Count);
          Inc(StaticArrayRec);
        until (StaticArrayRec = OverflowStaticArrayRec);

      Inc(NativeUInt(P), ItemSize);
    until (P = Overflow);
end;

class function TRAIIHelper.ClearsProcNativeOne(const Self: TRAIIHelper; P: Pointer): Pointer;
var
  Value: PNativeInt;
begin
  Value := Pointer(NativeInt(P) + Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.ItemSingle.Offset);
  if (Value^ <> 0) then
  begin
    Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.ItemSingle.ClearNativeProc(Value,
      Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.ItemSingle.DynTypeInfo);
  end;

  Result := P;
end;

class procedure TRAIIHelper.ClearsArrayProcNativeOne(const Self: TRAIIHelper;
  P, Overflow: Pointer; ItemSize: NativeUInt);
var
  Offset: NativeInt;
  ClearNativeProc: TClearNativeProc;
  DynTypeInfo: PTypeInfo;
  Value: PNativeInt;
begin
  Offset := Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.ItemSingle.Offset;
  ClearNativeProc := Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.ItemSingle.ClearNativeProc;
  DynTypeInfo := Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.ItemSingle.DynTypeInfo;
  if (P <> Overflow) then
    repeat
      Value := Pointer(NativeInt(P) + Offset);
      if (Value^ <> 0) then
        ClearNativeProc(Value, DynTypeInfo);

      Inc(NativeUInt(P), ItemSize);
    until (P = Overflow);
end;

class function TRAIIHelper.ClearsProcNativeTwo(const Self: TRAIIHelper; P: Pointer): Pointer;
var
  Value: PNativeInt;
  Item: ^ {$IFDEF WEAKINSTREF}TClearNativeRec{$ELSE}TNativeRec{$ENDIF};
begin
  Item := Pointer(Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.Items);

  Value := Pointer(NativeInt(P) + Item.Offset);
  if (Value^ <> 0) then
    Item.ClearNativeProc(Value, Item.DynTypeInfo);
  Inc(Item);
  Value := Pointer(NativeInt(P) + Item.Offset);
  if (Value^ <> 0) then
    Item.ClearNativeProc(Value, Item.DynTypeInfo);

  Result := P;
end;

class procedure TRAIIHelper.ClearsArrayProcNativeTwo(const Self: TRAIIHelper;
  P, Overflow: Pointer; ItemSize: NativeUInt);
var
  Value: PNativeInt;
  Item: ^ {$IFDEF WEAKINSTREF}TClearNativeRec{$ELSE}TNativeRec{$ENDIF};
  StoredItem: Pointer;
begin
  StoredItem := Pointer(Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.Items);

  if (P <> Overflow) then
    repeat
      Item := StoredItem;

      Value := Pointer(NativeInt(P) + Item.Offset);
      if (Value^ <> 0) then
        Item.ClearNativeProc(Value, Item.DynTypeInfo);
      Inc(Item);
      Value := Pointer(NativeInt(P) + Item.Offset);
      if (Value^ <> 0) then
        Item.ClearNativeProc(Value, Item.DynTypeInfo);

      Inc(NativeUInt(P), ItemSize);
    until (P = Overflow);
end;

class function TRAIIHelper.ClearsProcNativeThree(const Self: TRAIIHelper; P: Pointer): Pointer;
var
  Value: PNativeInt;
  Item: ^ {$IFDEF WEAKINSTREF}TClearNativeRec{$ELSE}TNativeRec{$ENDIF};
begin
  Item := Pointer(Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.Items);

  Value := Pointer(NativeInt(P) + Item.Offset);
  if (Value^ <> 0) then
    Item.ClearNativeProc(Value, Item.DynTypeInfo);
  Inc(Item);
  Value := Pointer(NativeInt(P) + Item.Offset);
  if (Value^ <> 0) then
    Item.ClearNativeProc(Value, Item.DynTypeInfo);
  Inc(Item);
  Value := Pointer(NativeInt(P) + Item.Offset);
  if (Value^ <> 0) then
    Item.ClearNativeProc(Value, Item.DynTypeInfo);

  Result := P;
end;

class procedure TRAIIHelper.ClearsArrayProcNativeThree(const Self: TRAIIHelper;
  P, Overflow: Pointer; ItemSize: NativeUInt);
var
  Value: PNativeInt;
  Item: ^ {$IFDEF WEAKINSTREF}TClearNativeRec{$ELSE}TNativeRec{$ENDIF};
  StoredItem: Pointer;
begin
  StoredItem := Pointer(Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.Items);

  if (P <> Overflow) then
    repeat
      Item := StoredItem;

      Value := Pointer(NativeInt(P) + Item.Offset);
      if (Value^ <> 0) then
        Item.ClearNativeProc(Value, Item.DynTypeInfo);
      Inc(Item);
      Value := Pointer(NativeInt(P) + Item.Offset);
      if (Value^ <> 0) then
        Item.ClearNativeProc(Value, Item.DynTypeInfo);
      Inc(Item);
      Value := Pointer(NativeInt(P) + Item.Offset);
      if (Value^ <> 0) then
        Item.ClearNativeProc(Value, Item.DynTypeInfo);

      Inc(NativeUInt(P), ItemSize);
    until (P = Overflow);
end;

class function TRAIIHelper.ClearsProcNatives(const Self: TRAIIHelper; P: Pointer): Pointer;
label
  _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11;
var
  Count: NativeInt;
  Value: PNativeInt;
  Item: ^ {$IFDEF WEAKINSTREF}TClearNativeRec{$ELSE}TNativeRec{$ENDIF};
begin
  Item := Pointer(Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.Items);
  Count := Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.Count;

  case Count of
    11:
      begin
        _11:
        Dec(Count, 10);
        repeat
          Value := Pointer(NativeInt(P) + Item.Offset);
          if (Value^ <> 0) then
            Item.ClearNativeProc(Value, Item.DynTypeInfo);
          Dec(Count);
          Inc(Item);
        until (Count = 0);
        goto _10;
      end;
    10:
      begin
        _10:
        Value := Pointer(NativeInt(P) + Item.Offset);
        if (Value^ <> 0) then
          Item.ClearNativeProc(Value, Item.DynTypeInfo);
        Inc(Item);
        goto _9;
      end;
    9:
      begin
        _9:
        Value := Pointer(NativeInt(P) + Item.Offset);
        if (Value^ <> 0) then
          Item.ClearNativeProc(Value, Item.DynTypeInfo);
        Inc(Item);
        goto _8;
      end;
    8:
      begin
        _8:
        Value := Pointer(NativeInt(P) + Item.Offset);
        if (Value^ <> 0) then
          Item.ClearNativeProc(Value, Item.DynTypeInfo);
        Inc(Item);
        goto _7;
      end;
    7:
      begin
        _7:
        Value := Pointer(NativeInt(P) + Item.Offset);
        if (Value^ <> 0) then
          Item.ClearNativeProc(Value, Item.DynTypeInfo);
        Inc(Item);
        goto _6;
      end;
    6:
      begin
        _6:
        Value := Pointer(NativeInt(P) + Item.Offset);
        if (Value^ <> 0) then
          Item.ClearNativeProc(Value, Item.DynTypeInfo);
        Inc(Item);
        goto _5;
      end;
    5:
      begin
        _5:
        Value := Pointer(NativeInt(P) + Item.Offset);
        if (Value^ <> 0) then
          Item.ClearNativeProc(Value, Item.DynTypeInfo);
        Inc(Item);
        goto _4;
      end;
    4:
      begin
        _4:
        Value := Pointer(NativeInt(P) + Item.Offset);
        if (Value^ <> 0) then
          Item.ClearNativeProc(Value, Item.DynTypeInfo);
        Inc(Item);
        goto _3;
      end;
    3:
      begin
        _3:
        Value := Pointer(NativeInt(P) + Item.Offset);
        if (Value^ <> 0) then
          Item.ClearNativeProc(Value, Item.DynTypeInfo);
        Inc(Item);
        goto _2;
      end;
    2:
      begin
        _2:
        Value := Pointer(NativeInt(P) + Item.Offset);
        if (Value^ <> 0) then
          Item.ClearNativeProc(Value, Item.DynTypeInfo);
        Inc(Item);
        goto _1;
      end;
    1:
      begin
        _1:
        Value := Pointer(NativeInt(P) + Item.Offset);
        if (Value^ <> 0) then
          Item.ClearNativeProc(Value, Item.DynTypeInfo);
      end;
    0: ;
  else
    goto _11;
  end;

  Result := P;
end;

class procedure TRAIIHelper.ClearsArrayProcNatives(const Self: TRAIIHelper;
  P, Overflow: Pointer; ItemSize: NativeUInt);
label
  _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11;
var
  Count: NativeInt;
  Value: PNativeInt;
  Item, OverflowItem: ^ {$IFDEF WEAKINSTREF}TClearNativeRec{$ELSE}TNativeRec{$ENDIF};
  Stored: record
    Item: Pointer;
    Count: NativeInt;
  end;
begin
  Stored.Item := Pointer(Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.Items);
  Stored.Count := Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.Count;

  if (P <> Overflow) then
    repeat
      Item := Stored.Item;
      Count := Stored.Count;

      case Count of
        11:
          begin
            _11:
            OverflowItem := Item + (Count - 10);
            repeat
              Value := Pointer(NativeInt(P) + Item.Offset);
              if (Value^ <> 0) then
                Item.ClearNativeProc(Value, Item.DynTypeInfo);
              Inc(Item);
            until (Item = OverflowItem);
            goto _10;
          end;
        10:
          begin
            _10:
            Value := Pointer(NativeInt(P) + Item.Offset);
            if (Value^ <> 0) then
              Item.ClearNativeProc(Value, Item.DynTypeInfo);
            Inc(Item);
            goto _9;
          end;
        9:
          begin
            _9:
            Value := Pointer(NativeInt(P) + Item.Offset);
            if (Value^ <> 0) then
              Item.ClearNativeProc(Value, Item.DynTypeInfo);
            Inc(Item);
            goto _8;
          end;
        8:
          begin
            _8:
            Value := Pointer(NativeInt(P) + Item.Offset);
            if (Value^ <> 0) then
              Item.ClearNativeProc(Value, Item.DynTypeInfo);
            Inc(Item);
            goto _7;
          end;
        7:
          begin
            _7:
            Value := Pointer(NativeInt(P) + Item.Offset);
            if (Value^ <> 0) then
              Item.ClearNativeProc(Value, Item.DynTypeInfo);
            Inc(Item);
            goto _6;
          end;
        6:
          begin
            _6:
            Value := Pointer(NativeInt(P) + Item.Offset);
            if (Value^ <> 0) then
              Item.ClearNativeProc(Value, Item.DynTypeInfo);
            Inc(Item);
            goto _5;
          end;
        5:
          begin
            _5:
            Value := Pointer(NativeInt(P) + Item.Offset);
            if (Value^ <> 0) then
              Item.ClearNativeProc(Value, Item.DynTypeInfo);
            Inc(Item);
            goto _4;
          end;
        4:
          begin
            _4:
            Value := Pointer(NativeInt(P) + Item.Offset);
            if (Value^ <> 0) then
              Item.ClearNativeProc(Value, Item.DynTypeInfo);
            Inc(Item);
            goto _3;
          end;
        3:
          begin
            _3:
            Value := Pointer(NativeInt(P) + Item.Offset);
            if (Value^ <> 0) then
              Item.ClearNativeProc(Value, Item.DynTypeInfo);
            Inc(Item);
            goto _2;
          end;
        2:
          begin
            _2:
            Value := Pointer(NativeInt(P) + Item.Offset);
            if (Value^ <> 0) then
              Item.ClearNativeProc(Value, Item.DynTypeInfo);
            Inc(Item);
            goto _1;
          end;
        1:
          begin
            _1:
            Value := Pointer(NativeInt(P) + Item.Offset);
            if (Value^ <> 0) then
              Item.ClearNativeProc(Value, Item.DynTypeInfo);
          end;
        0: ;
      else
        goto _11;
      end;

      Inc(NativeUInt(P), ItemSize);
    until (P = Overflow);
end;

class function TRAIIHelper.ClearsProc(const Self: TRAIIHelper; P: Pointer): Pointer;
var
  i: NativeInt;
  Value: PNativeInt;
  Item: ^TClearNativeRec;
  StaticArrayRec: ^TStaticArrayRec;
begin
  Item := Pointer(Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.Items);
  for i := 1 to Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.Count do
  begin
    Value := Pointer(NativeInt(P) + Item.Offset);
    if (Value^ <> 0) then
    begin
      Item.ClearNativeProc(Value, Item.DynTypeInfo);
    end;
    Inc(Item);
  end;

  StaticArrayRec := Pointer(Self.StaticArrays.Items);
  for i := 1 to Self.StaticArrays.Count do
  begin
    System.FinalizeArray(Pointer(NativeInt(P) + StaticArrayRec.Offset),
      StaticArrayRec.StaticTypeInfo, StaticArrayRec.Count);
    Inc(StaticArrayRec);
  end;

  Result := P;
end;

class procedure TRAIIHelper.ClearsArrayProc(const Self: TRAIIHelper;
  P, Overflow: Pointer; ItemSize: NativeUInt);
var
  Value: PNativeInt;
  Item, OverflowItem: ^TClearNativeRec;
  StaticArrayRec, OverflowStaticArrayRec: ^TStaticArrayRec;
begin
  if (P <> Overflow) then
    repeat
      Item := Pointer(Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.Items);
      OverflowItem := Item + Self. {$IFDEF WEAKINSTREF}ClearNatives{$ELSE}Natives{$ENDIF}.Count;
      if (Item <> OverflowItem) then
        repeat
          Value := Pointer(NativeInt(P) + Item.Offset);
          if (Value^ <> 0) then
          begin
            Item.ClearNativeProc(Value, Item.DynTypeInfo);
          end;
          Inc(Item);
        until (Item = OverflowItem);

      StaticArrayRec := Pointer(Self.StaticArrays.Items);
      OverflowStaticArrayRec := StaticArrayRec + Self.StaticArrays.Count;
      if (StaticArrayRec <> OverflowStaticArrayRec) then
        repeat
          System.FinalizeArray(Pointer(NativeInt(P) + StaticArrayRec.Offset),
            StaticArrayRec.StaticTypeInfo, StaticArrayRec.Count);
          Inc(StaticArrayRec);
        until (StaticArrayRec = OverflowStaticArrayRec);

      Inc(NativeUInt(P), ItemSize);
    until (P = Overflow);
end;

{ TRAIIHelper<T> }

class constructor TRAIIHelper<T>.ClassCreate;
begin
  FOptions.TypeInfo := TypeInfo(T);
end;

class function TRAIIHelper<T>.GetManaged: Boolean;
begin
  Result := System.IsManagedType(T);
end;

class function TRAIIHelper<T>.GetWeak: Boolean;
begin
  {$IFDEF WEAKREF}
  Result := System.HasWeakRef(T) {$IFNDEF WEAKINSTREF} and (GetTypeKind(T) <> tkMethod){$ENDIF};
  {$ELSE}
  Result := False;
  {$ENDIF}
end;

class function TRAIIHelper<T>.Init(Item: Pointer): Pointer;
var
  LNull: NativeInt;
begin
  Result := Item;

  if (System.IsManagedType(T)) then
  begin
    if (GetTypeKind(T) = tkVariant) or (SizeOf(T) <= 16) then
    begin
      LNull := 0;

      if (GetTypeKind(T) = tkVariant) then
      begin
        TData(Result^).Integers[0] := LNull;
      end
      else
      begin
        {$IFDEF SMALLINT}
        if (SizeOf(T) >= SizeOf(Integer) * 1) then
          TData(Result^).Integers[0] := LNull;
        if (SizeOf(T) >= SizeOf(Integer) * 2) then
          TData(Result^).Integers[1] := LNull;
        if (SizeOf(T) >= SizeOf(Integer) * 3) then
          TData(Result^).Integers[2] := LNull;
        if (SizeOf(T) = SizeOf(Integer) * 4) then
          TData(Result^).Integers[3] := LNull;
        {$ELSE .LARGEINT}
        if (SizeOf(T) >= SizeOf(Int64) * 1) then
          TData(Result^).Int64s[0] := LNull;
        if (SizeOf(T) = SizeOf(Int64) * 2) then
          TData(Result^).Int64s[1] := LNull;
        case SizeOf(T) of
          4..7: TData(Result^).Integers[0] := LNull;
          12..15: TData(Result^).Integers[2] := LNull;
        end;
        {$ENDIF}
        case SizeOf(T) of
          2, 3: TData(Result^).Words[0] := 0;
          6, 7: TData(Result^).Words[2] := 0;
          10, 11: TData(Result^).Words[4] := 0;
          14, 15: TData(Result^).Words[6] := 0;
        end;
        case SizeOf(T) of
          1: TData(Result^).Bytes[1 - 1] := 0;
          3: TData(Result^).Bytes[3 - 1] := 0;
          5: TData(Result^).Bytes[5 - 1] := 0;
          7: TData(Result^).Bytes[7 - 1] := 0;
          9: TData(Result^).Bytes[9 - 1] := 0;
          11: TData(Result^).Bytes[11 - 1] := 0;
          13: TData(Result^).Bytes[13 - 1] := 0;
          15: TData(Result^).Bytes[15 - 1] := 0;
        end;
      end;
    end
    else
    begin
      Result := FOptions.InitProc(FOptions, Result);
    end;
  end;
end;

class procedure TRAIIHelper<T>.Clear(Item: Pointer);
var
  VType: Integer;
begin
  if (System.IsManagedType(T)) then
  begin
    if (not (GetTypeKind(T) in [tkArray, tkRecord])) then
    begin
      case GetTypeKind(T) of
        {$IFDEF AUTOREFCOUNT}
        tkClass,
          {$ENDIF}
        tkWString, tkLString, tkUString, tkInterface, tkDynArray:
          begin
            if (TData(Item^).Native <> 0) then
              case GetTypeKind(T) of
                {$IFDEF AUTOREFCOUNT}
                tkClass: TRAIIHelper.RefObjClear(@TData(Item^).Native);
                {$ENDIF}
                {$IFDEF MSWINDOWS}
                tkWString: TRAIIHelper.WStrClear(@TData(Item^).Native);
                {$ELSE}
                tkWString,
                  {$ENDIF}
                tkLString, tkUString: TRAIIHelper.ULStrClear(@TData(Item^).Native);
            // AM: Fix for IInterface cleanup.
            // We could also make it  IInterface(PInterface(Item)^)._Release;
                tkInterface: IInterface(Pointer(TData(Item^).Native))._Release;
                tkDynArray: TRAIIHelper.DynArrayClear(@TData(Item^).Native, TypeInfo(T));
              end;
          end;
        {$IFDEF WEAKINSTREF}
        tkMethod:
          begin
            if (TData(Item^).Natives[1] <> 0) then
              TRAIIHelper.WeakMethodClear(@TData(Item^).Natives[1]);
          end;
        {$ENDIF}
        tkVariant:
          begin
            VType := Word(Item^);
            if (VType and TRAIIHelper.varDeepData <> 0) and (VType <> varBoolean) and
              (Cardinal(VType - (varUnknown + 1)) > (varUInt64 - varUnknown - 1)) then
              System.VarClear(Variant(Item^));
          end;
      end;
    end
    else
    begin
      // Original code calls InitProc here, but it doesn't look correct and causes
      // Memory leaks if record or array contains a managed type.
      // It should actually call ClearProc() as below:
      //FOptions.InitProc(FOptions, Item);
      FOptions.ClearProc(FOptions, Item);
    end;
  end;
end;

(* AM: This method is  not used internally and seems to have the same original problem
   of method Clear() above
class function TRAIIHelper<T>.ClearItem(Item: Pointer): Pointer;
var
  VType: Integer;
begin
  if (System.IsManagedType(T)) then
  begin
    if (not (GetTypeKind(T) in [tkArray, tkRecord])) then
    begin
      case GetTypeKind(T) of
        {$IFDEF AUTOREFCOUNT}
        tkClass,
        {$ENDIF}
        tkWString, tkLString, tkUString, tkInterface, tkDynArray:
        begin
          if (TData(Item^).Native <> 0) then
          case GetTypeKind(T) of
            {$IFDEF AUTOREFCOUNT}
            tkClass: TRAIIHelper.RefObjClear(@TData(Item^).Native);
            {$ENDIF}
            {$IFDEF MSWINDOWS}
            tkWString: TRAIIHelper.WStrClear(@TData(Item^).Native);
            {$ELSE}
            tkWString,
            {$ENDIF}
            tkLString, tkUString: TRAIIHelper.ULStrClear(@TData(Item^).Native);
            tkInterface: IInterface(Pointer(@TData(Item^).Native))._Release;
            tkDynArray: TRAIIHelper.DynArrayClear(@TData(Item^).Native, TypeInfo(T));
          end;
        end;
        {$IFDEF WEAKINSTREF}
        tkMethod:
        begin
          if (TData(Item^).Natives[1] <> 0) then
            TRAIIHelper.WeakMethodClear(@TData(Item^).Natives[1]);
        end;
        {$ENDIF}
        tkVariant:
        begin
          VType := Word(Item^);
          if (VType and TRAIIHelper.varDeepData <> 0) and (VType <> varBoolean) and
            (Cardinal(VType - (varUnknown + 1)) > (varUInt64 - varUnknown - 1)) then
            System.VarClear(Variant(Item^));
        end;
      end;

      Result := Item;
    end else
    begin
      Result := FOptions.InitProc(FOptions, Item);
    end;
  end
  else
  begin
    Result := Item;
  end;
end;
*)

class procedure TRAIIHelper<T>.InitArray(Item, OverflowItem: Pointer; ItemSize: NativeUInt);
const
  FILLZERO_ITEM_SIZE = 3 * SizeOf(Pointer) - 1;
var
  LItemSize: NativeUInt;
begin
  if (System.IsManagedType(T)) and (Item <> OverflowItem) then
  begin
    if (SizeOf(T) <= FILLZERO_ITEM_SIZE) and (ItemSize <= FILLZERO_ITEM_SIZE) then
    begin
      FillChar(Item^, NativeInt(OverflowItem) - NativeInt(Item), #0);
    end
    else if (GetTypeKind(T) = tkVariant) or (SizeOf(T) <= 16) then
    begin
      LItemSize := ItemSize;
      repeat
        Item := TRAIIHelper<T>.Init(Item);
        Inc(NativeUInt(Item), LItemSize);
      until (Item = OverflowItem);
    end
    else
    begin
      FOptions.InitArrayProc(FOptions, Item, OverflowItem, ItemSize);
    end;
  end;
end;

class procedure TRAIIHelper<T>.InitArray(Item, OverflowItem: Pointer);
begin
  if (System.IsManagedType(T)) then
    InitArray(Item, OverflowItem, SizeOf(T));
end;

class procedure TRAIIHelper<T>.InitArray(Item: Pointer; Count, ItemSize: NativeUInt);
begin
  if (System.IsManagedType(T)) then
    InitArray(Item, PByte(Item) + Count * ItemSize, ItemSize);
end;

class procedure TRAIIHelper<T>.InitArray(Item: Pointer; Count: NativeUInt);
begin
  if (System.IsManagedType(T)) then
    InitArray(Item, P(Item) + Count, SizeOf(T));
end;

class procedure TRAIIHelper<T>.ClearArray(Item, OverflowItem: Pointer; ItemSize: NativeUInt);
var
  LItemSize: NativeUInt;
begin
  if (System.IsManagedType(T)) and (Item <> OverflowItem) then
  begin
    if (not (GetTypeKind(T) in [tkArray, tkRecord])) then
    begin
      LItemSize := ItemSize;
      repeat
        TRAIIHelper<T>.Clear(Item);
        Inc(NativeUInt(Item), LItemSize);
      until (Item = OverflowItem);
    end
    else
    begin
      FOptions.ClearArrayProc(FOptions, Item, OverflowItem, ItemSize);
    end;
  end;
end;

class procedure TRAIIHelper<T>.ClearArray(Item, OverflowItem: Pointer);
begin
  if (System.IsManagedType(T)) then
    ClearArray(Item, OverflowItem, SizeOf(T));
end;

class procedure TRAIIHelper<T>.ClearArray(Item: Pointer; Count, ItemSize: NativeUInt);
begin
  if (System.IsManagedType(T)) then
    ClearArray(Item, PByte(Item) + Count * ItemSize, ItemSize);
end;

class procedure TRAIIHelper<T>.ClearArray(Item: Pointer; Count: NativeUInt);
begin
  if (System.IsManagedType(T)) then
    ClearArray(Item, P(Item) + Count, SizeOf(T));
end;

{ TRAIIHelper<T1,T2,T3,T4> }

class function TRAIIHelper<T1, T2, T3, T4>.GetManaged: Boolean;
begin
  Result := System.IsManagedType(TRecord<T1, T2, T3, T4>);
end;

class function TRAIIHelper<T1, T2, T3, T4>.GetWeak: Boolean;
begin
  {$IFDEF WEAKREF}
  {$IFDEF WEAKINSTREF}
  Result := System.HasWeakRef(TRecord<T1, T2, T3, T4>);
  {$ELSE}
  Result := (System.HasWeakRef(T1) and (GetTypeKind(T1) <> tkMethod)) or
    (System.HasWeakRef(T2) and (GetTypeKind(T2) <> tkMethod)) or
    (System.HasWeakRef(T3) and (GetTypeKind(T3) <> tkMethod)) or
    (System.HasWeakRef(T4) and (GetTypeKind(T4) <> tkMethod));
  {$ENDIF}
  {$ELSE}
  Result := False;
  {$ENDIF}
end;

class function TRAIIHelper<T1, T2, T3, T4>.GetOptions: PRAIIHelper;
begin
  Result := @TRAIIHelper < TRecord<T1, T2, T3, T4> > .FOptions;
end;

class function TRAIIHelper<T1, T2, T3, T4>.Init(Item: Pointer): Pointer;
var
  LNull: NativeInt;
begin
  Result := Item;

  if (System.IsManagedType(TRecord<T1, T2, T3, T4>)) then
  begin
    if (not System.IsManagedType(T1) or (GetTypeKind(T1) = tkVariant) or (SizeOf(T1) <= 16)) and
      (not System.IsManagedType(T2) or (GetTypeKind(T2) = tkVariant) or (SizeOf(T2) <= 16)) and
      (not System.IsManagedType(T3) or (GetTypeKind(T3) = tkVariant) or (SizeOf(T3) <= 16)) and
      (not System.IsManagedType(T4) or (GetTypeKind(T4) = tkVariant) or (SizeOf(T4) <= 16)) then
    begin
      LNull := 0;

      if (System.IsManagedType(T1)) then
      begin
        if (GetTypeKind(T1) = tkVariant) then
        begin
          TData1(Result^).Integers[0] := LNull;
        end
        else
        begin
          {$IFDEF SMALLINT}
          if (SizeOf(T1) >= SizeOf(Integer) * 1) then
            TData1(Result^).Integers[0] := LNull;
          if (SizeOf(T1) >= SizeOf(Integer) * 2) then
            TData1(Result^).Integers[1] := LNull;
          if (SizeOf(T1) >= SizeOf(Integer) * 3) then
            TData1(Result^).Integers[2] := LNull;
          if (SizeOf(T1) = SizeOf(Integer) * 4) then
            TData1(Result^).Integers[3] := LNull;
          {$ELSE .LARGEINT}
          if (SizeOf(T1) >= SizeOf(Int64) * 1) then
            TData1(Result^).Int64s[0] := LNull;
          if (SizeOf(T1) = SizeOf(Int64) * 2) then
            TData1(Result^).Int64s[1] := LNull;
          case SizeOf(T1) of
            4..7: TData1(Result^).Integers[0] := LNull;
            12..15: TData1(Result^).Integers[2] := LNull;
          end;
          {$ENDIF}
          case SizeOf(T1) of
            2, 3: TData1(Result^).Words[0] := 0;
            6, 7: TData1(Result^).Words[2] := 0;
            10, 11: TData1(Result^).Words[4] := 0;
            14, 15: TData1(Result^).Words[6] := 0;
          end;
          case SizeOf(T1) of
            1: TData1(Result^).Bytes[1 - 1] := 0;
            3: TData1(Result^).Bytes[3 - 1] := 0;
            5: TData1(Result^).Bytes[5 - 1] := 0;
            7: TData1(Result^).Bytes[7 - 1] := 0;
            9: TData1(Result^).Bytes[9 - 1] := 0;
            11: TData1(Result^).Bytes[11 - 1] := 0;
            13: TData1(Result^).Bytes[13 - 1] := 0;
            15: TData1(Result^).Bytes[15 - 1] := 0;
          end;
        end;
      end;

      if (System.IsManagedType(T2)) then
      begin
        if (GetTypeKind(T2) = tkVariant) then
        begin
          TData2(Result^).Integers[0] := LNull;
        end
        else
        begin
          {$IFDEF SMALLINT}
          if (SizeOf(T2) >= SizeOf(Integer) * 1) then
            TData2(Result^).Integers[0] := LNull;
          if (SizeOf(T2) >= SizeOf(Integer) * 2) then
            TData2(Result^).Integers[1] := LNull;
          if (SizeOf(T2) >= SizeOf(Integer) * 3) then
            TData2(Result^).Integers[2] := LNull;
          if (SizeOf(T2) = SizeOf(Integer) * 4) then
            TData2(Result^).Integers[3] := LNull;
          {$ELSE .LARGEINT}
          if (SizeOf(T2) >= SizeOf(Int64) * 1) then
            TData2(Result^).Int64s[0] := LNull;
          if (SizeOf(T2) = SizeOf(Int64) * 2) then
            TData2(Result^).Int64s[1] := LNull;
          case SizeOf(T2) of
            4..7: TData2(Result^).Integers[0] := LNull;
            12..15: TData2(Result^).Integers[2] := LNull;
          end;
          {$ENDIF}
          case SizeOf(T2) of
            2, 3: TData2(Result^).Words[0] := 0;
            6, 7: TData2(Result^).Words[2] := 0;
            10, 11: TData2(Result^).Words[4] := 0;
            14, 15: TData2(Result^).Words[6] := 0;
          end;
          case SizeOf(T2) of
            1: TData2(Result^).Bytes[1 - 1] := 0;
            3: TData2(Result^).Bytes[3 - 1] := 0;
            5: TData2(Result^).Bytes[5 - 1] := 0;
            7: TData2(Result^).Bytes[7 - 1] := 0;
            9: TData2(Result^).Bytes[9 - 1] := 0;
            11: TData2(Result^).Bytes[11 - 1] := 0;
            13: TData2(Result^).Bytes[13 - 1] := 0;
            15: TData2(Result^).Bytes[15 - 1] := 0;
          end;
        end;
      end;

      if (System.IsManagedType(T3)) then
      begin
        if (GetTypeKind(T3) = tkVariant) then
        begin
          TData3(Result^).Integers[0] := LNull;
        end
        else
        begin
          {$IFDEF SMALLINT}
          if (SizeOf(T3) >= SizeOf(Integer) * 1) then
            TData3(Result^).Integers[0] := LNull;
          if (SizeOf(T3) >= SizeOf(Integer) * 2) then
            TData3(Result^).Integers[1] := LNull;
          if (SizeOf(T3) >= SizeOf(Integer) * 3) then
            TData3(Result^).Integers[2] := LNull;
          if (SizeOf(T3) = SizeOf(Integer) * 4) then
            TData3(Result^).Integers[3] := LNull;
          {$ELSE .LARGEINT}
          if (SizeOf(T3) >= SizeOf(Int64) * 1) then
            TData3(Result^).Int64s[0] := LNull;
          if (SizeOf(T3) = SizeOf(Int64) * 2) then
            TData3(Result^).Int64s[1] := LNull;
          case SizeOf(T3) of
            4..7: TData3(Result^).Integers[0] := LNull;
            12..15: TData3(Result^).Integers[2] := LNull;
          end;
          {$ENDIF}
          case SizeOf(T3) of
            2, 3: TData3(Result^).Words[0] := 0;
            6, 7: TData3(Result^).Words[2] := 0;
            10, 11: TData3(Result^).Words[4] := 0;
            14, 15: TData3(Result^).Words[6] := 0;
          end;
          case SizeOf(T3) of
            1: TData3(Result^).Bytes[1 - 1] := 0;
            3: TData3(Result^).Bytes[3 - 1] := 0;
            5: TData3(Result^).Bytes[5 - 1] := 0;
            7: TData3(Result^).Bytes[7 - 1] := 0;
            9: TData3(Result^).Bytes[9 - 1] := 0;
            11: TData3(Result^).Bytes[11 - 1] := 0;
            13: TData3(Result^).Bytes[13 - 1] := 0;
            15: TData3(Result^).Bytes[15 - 1] := 0;
          end;
        end;
      end;

      if (System.IsManagedType(T4)) then
      begin
        if (GetTypeKind(T4) = tkVariant) then
        begin
          TData4(Result^).Integers[0] := LNull;
        end
        else
        begin
          {$IFDEF SMALLINT}
          if (SizeOf(T4) >= SizeOf(Integer) * 1) then
            TData4(Result^).Integers[0] := LNull;
          if (SizeOf(T4) >= SizeOf(Integer) * 2) then
            TData4(Result^).Integers[1] := LNull;
          if (SizeOf(T4) >= SizeOf(Integer) * 3) then
            TData4(Result^).Integers[2] := LNull;
          if (SizeOf(T4) = SizeOf(Integer) * 4) then
            TData4(Result^).Integers[3] := LNull;
          {$ELSE .LARGEINT}
          if (SizeOf(T4) >= SizeOf(Int64) * 1) then
            TData4(Result^).Int64s[0] := LNull;
          if (SizeOf(T4) = SizeOf(Int64) * 2) then
            TData4(Result^).Int64s[1] := LNull;
          case SizeOf(T4) of
            4..7: TData4(Result^).Integers[0] := LNull;
            12..15: TData4(Result^).Integers[2] := LNull;
          end;
          {$ENDIF}
          case SizeOf(T4) of
            2, 3: TData4(Result^).Words[0] := 0;
            6, 7: TData4(Result^).Words[2] := 0;
            10, 11: TData4(Result^).Words[4] := 0;
            14, 15: TData4(Result^).Words[6] := 0;
          end;
          case SizeOf(T4) of
            1: TData4(Result^).Bytes[1 - 1] := 0;
            3: TData4(Result^).Bytes[3 - 1] := 0;
            5: TData4(Result^).Bytes[5 - 1] := 0;
            7: TData4(Result^).Bytes[7 - 1] := 0;
            9: TData4(Result^).Bytes[9 - 1] := 0;
            11: TData4(Result^).Bytes[11 - 1] := 0;
            13: TData4(Result^).Bytes[13 - 1] := 0;
            15: TData4(Result^).Bytes[15 - 1] := 0;
          end;
        end;
      end;
    end
    else
    begin
      Result := TRAIIHelper < TRecord<T1, T2, T3, T4> > .FOptions.InitProc(TRAIIHelper < TRecord<T1, T2, T3, T4> >
        .FOptions, Result);
    end;
  end;
end;

class procedure TRAIIHelper<T1, T2, T3, T4>.Clear(Item: Pointer);
var
  LData: PNativeUInt;
  VType: Integer;
begin
  if (System.IsManagedType(TRecord<T1, T2, T3, T4>)) then
  begin
    if (not System.IsManagedType(T1) or not (GetTypeKind(T1) in [tkArray, tkRecord])) and
      (not System.IsManagedType(T2) or not (GetTypeKind(T2) in [tkArray, tkRecord])) and
      (not System.IsManagedType(T3) or not (GetTypeKind(T3) in [tkArray, tkRecord])) and
      (not System.IsManagedType(T4) or not (GetTypeKind(T4) in [tkArray, tkRecord])) then
    begin
      if (System.IsManagedType(T1)) then
      begin
        {$IFDEF WEAKINSTREF}
        if (GetTypeKind(T1) = tkMethod) then
          LData := @TData1(Item^).Natives[1]
        else
          {$ENDIF}
          LData := @TData1(Item^).Natives[0];

        case GetTypeKind(T1) of
          {$IFDEF AUTOREFCOUNT}
          tkClass,
            {$ENDIF}
          {$IFDEF WEAKINSTREF}
          tkMethod,
            {$ENDIF}
          tkWString, tkLString, tkUString, tkInterface, tkDynArray:
            begin
              if (LData^ <> 0) then
                case GetTypeKind(T1) of
                  {$IFDEF AUTOREFCOUNT}
                  tkClass: TRAIIHelper.RefObjClear(LData);
                  {$ENDIF}
                  {$IFDEF MSWINDOWS}
                  tkWString: TRAIIHelper.WStrClear(LData);
                  {$ELSE}
                  tkWString,
                    {$ENDIF}
                  tkLString, tkUString: TRAIIHelper.ULStrClear(LData);
                  tkInterface: IInterface(Pointer(LData))._Release;
                  tkDynArray: TRAIIHelper.DynArrayClear(LData, TypeInfo(T1));
                  {$IFDEF WEAKINSTREF}
                  tkMethod: TRAIIHelper.WeakMethodClear(LData);
                  {$ENDIF}
                end;
            end;
          tkVariant:
            begin
              VType := Word(LData^);
              if (VType and TRAIIHelper.varDeepData <> 0) and (VType <> varBoolean) and
                (Cardinal(VType - (varUnknown + 1)) > (varUInt64 - varUnknown - 1)) then
                System.VarClear(Variant(Pointer(LData)^));
            end;
        end;
      end;

      if (System.IsManagedType(T2)) then
      begin
        {$IFDEF WEAKINSTREF}
        if (GetTypeKind(T2) = tkMethod) then
          LData := @TData2(Item^).Natives[1]
        else
          {$ENDIF}
          LData := @TData2(Item^).Natives[0];

        case GetTypeKind(T2) of
          {$IFDEF AUTOREFCOUNT}
          tkClass,
            {$ENDIF}
          {$IFDEF WEAKINSTREF}
          tkMethod,
            {$ENDIF}
          tkWString, tkLString, tkUString, tkInterface, tkDynArray:
            begin
              if (LData^ <> 0) then
                case GetTypeKind(T2) of
                  {$IFDEF AUTOREFCOUNT}
                  tkClass: TRAIIHelper.RefObjClear(LData);
                  {$ENDIF}
                  {$IFDEF MSWINDOWS}
                  tkWString: TRAIIHelper.WStrClear(LData);
                  {$ELSE}
                  tkWString,
                    {$ENDIF}
                  tkLString, tkUString: TRAIIHelper.ULStrClear(LData);
                  tkInterface: IInterface(Pointer(LData))._Release;
                  tkDynArray: TRAIIHelper.DynArrayClear(LData, TypeInfo(T2));
                  {$IFDEF WEAKINSTREF}
                  tkMethod: TRAIIHelper.WeakMethodClear(LData);
                  {$ENDIF}
                end;
            end;
          tkVariant:
            begin
              VType := Word(LData^);
              if (VType and TRAIIHelper.varDeepData <> 0) and (VType <> varBoolean) and
                (Cardinal(VType - (varUnknown + 1)) > (varUInt64 - varUnknown - 1)) then
                System.VarClear(Variant(Pointer(LData)^));
            end;
        end;
      end;

      if (System.IsManagedType(T3)) then
      begin
        {$IFDEF WEAKINSTREF}
        if (GetTypeKind(T3) = tkMethod) then
          LData := @TData3(Item^).Natives[1]
        else
          {$ENDIF}
          LData := @TData3(Item^).Natives[0];

        case GetTypeKind(T3) of
          {$IFDEF AUTOREFCOUNT}
          tkClass,
            {$ENDIF}
          {$IFDEF WEAKINSTREF}
          tkMethod,
            {$ENDIF}
          tkWString, tkLString, tkUString, tkInterface, tkDynArray:
            begin
              if (LData^ <> 0) then
                case GetTypeKind(T3) of
                  {$IFDEF AUTOREFCOUNT}
                  tkClass: TRAIIHelper.RefObjClear(LData);
                  {$ENDIF}
                  {$IFDEF MSWINDOWS}
                  tkWString: TRAIIHelper.WStrClear(LData);
                  {$ELSE}
                  tkWString,
                    {$ENDIF}
                  tkLString, tkUString: TRAIIHelper.ULStrClear(LData);
                  tkInterface: IInterface(Pointer(LData))._Release;
                  tkDynArray: TRAIIHelper.DynArrayClear(LData, TypeInfo(T3));
                  {$IFDEF WEAKINSTREF}
                  tkMethod: TRAIIHelper.WeakMethodClear(LData);
                  {$ENDIF}
                end;
            end;
          tkVariant:
            begin
              VType := Word(LData^);
              if (VType and TRAIIHelper.varDeepData <> 0) and (VType <> varBoolean) and
                (Cardinal(VType - (varUnknown + 1)) > (varUInt64 - varUnknown - 1)) then
                System.VarClear(Variant(Pointer(LData)^));
            end;
        end;
      end;

      if (System.IsManagedType(T4)) then
      begin
        {$IFDEF WEAKINSTREF}
        if (GetTypeKind(T4) = tkMethod) then
          LData := @TData4(Item^).Natives[1]
        else
          {$ENDIF}
          LData := @TData4(Item^).Natives[0];

        case GetTypeKind(T4) of
          {$IFDEF AUTOREFCOUNT}
          tkClass,
            {$ENDIF}
          {$IFDEF WEAKINSTREF}
          tkMethod,
            {$ENDIF}
          tkWString, tkLString, tkUString, tkInterface, tkDynArray:
            begin
              if (LData^ <> 0) then
                case GetTypeKind(T4) of
                  {$IFDEF AUTOREFCOUNT}
                  tkClass: TRAIIHelper.RefObjClear(LData);
                  {$ENDIF}
                  {$IFDEF MSWINDOWS}
                  tkWString: TRAIIHelper.WStrClear(LData);
                  {$ELSE}
                  tkWString,
                    {$ENDIF}
                  tkLString, tkUString: TRAIIHelper.ULStrClear(LData);
                  tkInterface: IInterface(Pointer(LData))._Release;
                  tkDynArray: TRAIIHelper.DynArrayClear(LData, TypeInfo(T4));
                  {$IFDEF WEAKINSTREF}
                  tkMethod: TRAIIHelper.WeakMethodClear(LData);
                  {$ENDIF}
                end;
            end;
          tkVariant:
            begin
              VType := Word(LData^);
              if (VType and TRAIIHelper.varDeepData <> 0) and (VType <> varBoolean) and
                (Cardinal(VType - (varUnknown + 1)) > (varUInt64 - varUnknown - 1)) then
                System.VarClear(Variant(Pointer(LData)^));
            end;
        end;
      end;
    end
    else
    begin
      TRAIIHelper < TRecord<T1, T2, T3, T4> > .FOptions.InitProc(TRAIIHelper < TRecord<T1, T2, T3, T4> > .FOptions,
        Item);
    end;
  end;
end;

class function TRAIIHelper<T1, T2, T3, T4>.ClearItem(Item: Pointer): Pointer;
var
  LData: PNativeUInt;
  VType: Integer;
begin
  if (System.IsManagedType(TRecord<T1, T2, T3, T4>)) then
  begin
    if (not System.IsManagedType(T1) or not (GetTypeKind(T1) in [tkArray, tkRecord])) and
      (not System.IsManagedType(T2) or not (GetTypeKind(T2) in [tkArray, tkRecord])) and
      (not System.IsManagedType(T3) or not (GetTypeKind(T3) in [tkArray, tkRecord])) and
      (not System.IsManagedType(T4) or not (GetTypeKind(T4) in [tkArray, tkRecord])) then
    begin
      if (System.IsManagedType(T1)) then
      begin
        {$IFDEF WEAKINSTREF}
        if (GetTypeKind(T1) = tkMethod) then
          LData := @TData1(Item^).Natives[1]
        else
          {$ENDIF}
          LData := @TData1(Item^).Natives[0];

        case GetTypeKind(T1) of
          {$IFDEF AUTOREFCOUNT}
          tkClass,
            {$ENDIF}
          {$IFDEF WEAKINSTREF}
          tkMethod,
            {$ENDIF}
          tkWString, tkLString, tkUString, tkInterface, tkDynArray:
            begin
              if (LData^ <> 0) then
                case GetTypeKind(T1) of
                  {$IFDEF AUTOREFCOUNT}
                  tkClass: TRAIIHelper.RefObjClear(LData);
                  {$ENDIF}
                  {$IFDEF MSWINDOWS}
                  tkWString: TRAIIHelper.WStrClear(LData);
                  {$ELSE}
                  tkWString,
                    {$ENDIF}
                  tkLString, tkUString: TRAIIHelper.ULStrClear(LData);
                  tkInterface: IInterface(Pointer(LData))._Release;
                  tkDynArray: TRAIIHelper.DynArrayClear(LData, TypeInfo(T1));
                  {$IFDEF WEAKINSTREF}
                  tkMethod: TRAIIHelper.WeakMethodClear(LData);
                  {$ENDIF}
                end;
            end;
          tkVariant:
            begin
              VType := Word(LData^);
              if (VType and TRAIIHelper.varDeepData <> 0) and (VType <> varBoolean) and
                (Cardinal(VType - (varUnknown + 1)) > (varUInt64 - varUnknown - 1)) then
                System.VarClear(Variant(Pointer(LData)^));
            end;
        end;
      end;

      if (System.IsManagedType(T2)) then
      begin
        {$IFDEF WEAKINSTREF}
        if (GetTypeKind(T2) = tkMethod) then
          LData := @TData2(Item^).Natives[1]
        else
          {$ENDIF}
          LData := @TData2(Item^).Natives[0];

        case GetTypeKind(T2) of
          {$IFDEF AUTOREFCOUNT}
          tkClass,
            {$ENDIF}
          {$IFDEF WEAKINSTREF}
          tkMethod,
            {$ENDIF}
          tkWString, tkLString, tkUString, tkInterface, tkDynArray:
            begin
              if (LData^ <> 0) then
                case GetTypeKind(T2) of
                  {$IFDEF AUTOREFCOUNT}
                  tkClass: TRAIIHelper.RefObjClear(LData);
                  {$ENDIF}
                  {$IFDEF MSWINDOWS}
                  tkWString: TRAIIHelper.WStrClear(LData);
                  {$ELSE}
                  tkWString,
                    {$ENDIF}
                  tkLString, tkUString: TRAIIHelper.ULStrClear(LData);
                  tkInterface: IInterface(Pointer(LData))._Release;
                  tkDynArray: TRAIIHelper.DynArrayClear(LData, TypeInfo(T2));
                  {$IFDEF WEAKINSTREF}
                  tkMethod: TRAIIHelper.WeakMethodClear(LData);
                  {$ENDIF}
                end;
            end;
          tkVariant:
            begin
              VType := Word(LData^);
              if (VType and TRAIIHelper.varDeepData <> 0) and (VType <> varBoolean) and
                (Cardinal(VType - (varUnknown + 1)) > (varUInt64 - varUnknown - 1)) then
                System.VarClear(Variant(Pointer(LData)^));
            end;
        end;
      end;

      if (System.IsManagedType(T3)) then
      begin
        {$IFDEF WEAKINSTREF}
        if (GetTypeKind(T3) = tkMethod) then
          LData := @TData3(Item^).Natives[1]
        else
          {$ENDIF}
          LData := @TData3(Item^).Natives[0];

        case GetTypeKind(T3) of
          {$IFDEF AUTOREFCOUNT}
          tkClass,
            {$ENDIF}
          {$IFDEF WEAKINSTREF}
          tkMethod,
            {$ENDIF}
          tkWString, tkLString, tkUString, tkInterface, tkDynArray:
            begin
              if (LData^ <> 0) then
                case GetTypeKind(T3) of
                  {$IFDEF AUTOREFCOUNT}
                  tkClass: TRAIIHelper.RefObjClear(LData);
                  {$ENDIF}
                  {$IFDEF MSWINDOWS}
                  tkWString: TRAIIHelper.WStrClear(LData);
                  {$ELSE}
                  tkWString,
                    {$ENDIF}
                  tkLString, tkUString: TRAIIHelper.ULStrClear(LData);
                  tkInterface: IInterface(Pointer(LData))._Release;
                  tkDynArray: TRAIIHelper.DynArrayClear(LData, TypeInfo(T3));
                  {$IFDEF WEAKINSTREF}
                  tkMethod: TRAIIHelper.WeakMethodClear(LData);
                  {$ENDIF}
                end;
            end;
          tkVariant:
            begin
              VType := Word(LData^);
              if (VType and TRAIIHelper.varDeepData <> 0) and (VType <> varBoolean) and
                (Cardinal(VType - (varUnknown + 1)) > (varUInt64 - varUnknown - 1)) then
                System.VarClear(Variant(Pointer(LData)^));
            end;
        end;
      end;

      if (System.IsManagedType(T4)) then
      begin
        {$IFDEF WEAKINSTREF}
        if (GetTypeKind(T4) = tkMethod) then
          LData := @TData4(Item^).Natives[1]
        else
          {$ENDIF}
          LData := @TData4(Item^).Natives[0];

        case GetTypeKind(T4) of
          {$IFDEF AUTOREFCOUNT}
          tkClass,
            {$ENDIF}
          {$IFDEF WEAKINSTREF}
          tkMethod,
            {$ENDIF}
          tkWString, tkLString, tkUString, tkInterface, tkDynArray:
            begin
              if (LData^ <> 0) then
                case GetTypeKind(T4) of
                  {$IFDEF AUTOREFCOUNT}
                  tkClass: TRAIIHelper.RefObjClear(LData);
                  {$ENDIF}
                  {$IFDEF MSWINDOWS}
                  tkWString: TRAIIHelper.WStrClear(LData);
                  {$ELSE}
                  tkWString,
                    {$ENDIF}
                  tkLString, tkUString: TRAIIHelper.ULStrClear(LData);
                  tkInterface: IInterface(Pointer(LData))._Release;
                  tkDynArray: TRAIIHelper.DynArrayClear(LData, TypeInfo(T4));
                  {$IFDEF WEAKINSTREF}
                  tkMethod: TRAIIHelper.WeakMethodClear(LData);
                  {$ENDIF}
                end;
            end;
          tkVariant:
            begin
              VType := Word(LData^);
              if (VType and TRAIIHelper.varDeepData <> 0) and (VType <> varBoolean) and
                (Cardinal(VType - (varUnknown + 1)) > (varUInt64 - varUnknown - 1)) then
                System.VarClear(Variant(Pointer(LData)^));
            end;
        end;
      end;

      Result := Item;
    end
    else
    begin
      Result := TRAIIHelper < TRecord<T1, T2, T3, T4> > .FOptions.InitProc(TRAIIHelper < TRecord<T1, T2, T3, T4> >
        .FOptions, Item);
    end;
  end
  else
  begin
    Result := Item;
  end;
end;

class procedure TRAIIHelper<T1, T2, T3, T4>.InitArray(Item, OverflowItem: Pointer; ItemSize: NativeUInt);
const
  FILLZERO_ITEM_SIZE = 3 * SizeOf(Pointer) - 1;
var
  LItemSize: NativeUInt;
begin
  if (System.IsManagedType(TRecord<T1, T2, T3, T4>)) and (Item <> OverflowItem) then
  begin
    if (SizeOf(TRecord<T1, T2, T3, T4>) <= FILLZERO_ITEM_SIZE) and (ItemSize <= FILLZERO_ITEM_SIZE) then
    begin
      FillChar(Item^, NativeInt(OverflowItem) - NativeInt(Item), #0);
    end
    else if (not System.IsManagedType(T1) or (GetTypeKind(T1) = tkVariant) or (SizeOf(T1) <= 16)) and
      (not System.IsManagedType(T2) or (GetTypeKind(T2) = tkVariant) or (SizeOf(T2) <= 16)) and
      (not System.IsManagedType(T3) or (GetTypeKind(T3) = tkVariant) or (SizeOf(T3) <= 16)) and
      (not System.IsManagedType(T4) or (GetTypeKind(T4) = tkVariant) or (SizeOf(T4) <= 16)) then
    begin
      LItemSize := ItemSize;
      repeat
        Item := TRAIIHelper<T1, T2, T3, T4>.Init(Item);
        Inc(NativeUInt(Item), LItemSize);
      until (Item = OverflowItem);
    end
    else
    begin
      TRAIIHelper < TRecord<T1, T2, T3, T4> > .FOptions.InitArrayProc(
        TRAIIHelper < TRecord<T1, T2, T3, T4> > .FOptions, Item, OverflowItem, ItemSize);
    end;
  end;
end;

class procedure TRAIIHelper<T1, T2, T3, T4>.InitArray(Item, OverflowItem: Pointer);
begin
  if (System.IsManagedType(TRecord<T1, T2, T3, T4>)) then
    InitArray(Item, OverflowItem, SizeOf(TRecord<T1, T2, T3, T4>));
end;

class procedure TRAIIHelper<T1, T2, T3, T4>.InitArray(Item: Pointer; Count, ItemSize: NativeUInt);
begin
  if (System.IsManagedType(TRecord<T1, T2, T3, T4>)) then
    InitArray(Item, PByte(Item) + Count * ItemSize, ItemSize);
end;

class procedure TRAIIHelper<T1, T2, T3, T4>.InitArray(Item: Pointer; Count: NativeUInt);
begin
  if (System.IsManagedType(TRecord<T1, T2, T3, T4>)) then
    InitArray(Item, P(Item) + Count, SizeOf(TRecord<T1, T2, T3, T4>));
end;

class procedure TRAIIHelper<T1, T2, T3, T4>.ClearArray(Item, OverflowItem: Pointer; ItemSize: NativeUInt);
var
  LItemSize: NativeUInt;
begin
  if (System.IsManagedType(TRecord<T1, T2, T3, T4>)) and (Item <> OverflowItem) then
  begin
    if (not System.IsManagedType(T1) or not (GetTypeKind(T1) in [tkArray, tkRecord])) and
      (not System.IsManagedType(T2) or not (GetTypeKind(T2) in [tkArray, tkRecord])) and
      (not System.IsManagedType(T3) or not (GetTypeKind(T3) in [tkArray, tkRecord])) and
      (not System.IsManagedType(T4) or not (GetTypeKind(T4) in [tkArray, tkRecord])) then
    begin
      LItemSize := ItemSize;
      repeat
        TRAIIHelper<T1, T2, T3, T4>.Clear(Item);
        Inc(NativeUInt(Item), LItemSize);
      until (Item = OverflowItem);
    end
    else
    begin
      TRAIIHelper < TRecord<T1, T2, T3, T4> > .FOptions.ClearArrayProc(
        TRAIIHelper < TRecord<T1, T2, T3, T4> > .FOptions, Item, OverflowItem, ItemSize);
    end;
  end;
end;

class procedure TRAIIHelper<T1, T2, T3, T4>.ClearArray(Item, OverflowItem: Pointer);
begin
  if (System.IsManagedType(TRecord<T1, T2, T3, T4>)) then
    ClearArray(Item, OverflowItem, SizeOf(TRecord<T1, T2, T3, T4>));
end;

class procedure TRAIIHelper<T1, T2, T3, T4>.ClearArray(Item: Pointer; Count, ItemSize: NativeUInt);
begin
  if (System.IsManagedType(TRecord<T1, T2, T3, T4>)) then
    ClearArray(Item, PByte(Item) + Count * ItemSize, ItemSize);
end;

class procedure TRAIIHelper<T1, T2, T3, T4>.ClearArray(Item: Pointer; Count: NativeUInt);
begin
  if (System.IsManagedType(TRecord<T1, T2, T3, T4>)) then
    ClearArray(Item, P(Item) + Count, SizeOf(TRecord<T1, T2, T3, T4>));
end;

{ InterfaceDefaults }

class constructor InterfaceDefaults.TDefaultComparer<T>.ClassCreate;
var
  TypeData: PTypeData;
begin
  Instance.Vtable := @Instance.QueryInterface;
  Instance.Size := SizeOf(T);
  Instance.QueryInterface := @InterfaceDefaults.NopQueryInterface;
  Instance.AddRef := @InterfaceDefaults.NopAddRef;
  Instance.Release := @InterfaceDefaults.NopRelease;

  // Compare
  TypeData := Pointer(TypeInfo(T));
  Inc(NativeUInt(TypeData), NativeUInt(PByte(@PTypeInfo(TypeData).Name)^) + 2);
  case GetTypeKind(T) of
    tkInteger, tkEnumeration, tkChar, tkWChar:
      case TypeData.OrdType of
        otSByte: Instance.Compare := @InterfaceDefaults.Compare_I1;
        otUByte: Instance.Compare := @InterfaceDefaults.Compare_U1;
        otSWord: Instance.Compare := @InterfaceDefaults.Compare_I2;
        otUWord: Instance.Compare := @InterfaceDefaults.Compare_U2;
        otSLong: Instance.Compare := @InterfaceDefaults.Compare_I4;
        otULong: Instance.Compare := @InterfaceDefaults.Compare_U4;
      end;
    tkInt64:
      begin
        if (TypeData.MaxInt64Value > TypeData.MinInt64Value) then
        begin
          Instance.Compare := @InterfaceDefaults.Compare_I8
        end
        else
        begin
          Instance.Compare := @InterfaceDefaults.Compare_U8;
        end;
      end;
    tkClass, tkInterface, tkClassRef, tkPointer, tkProcedure:
      begin
        {$IFDEF LARGEINT}
        Instance.Compare := @InterfaceDefaults.Compare_U8;
        {$ELSE .SMALLINT}
        Instance.Compare := @InterfaceDefaults.Compare_U4;
        {$ENDIF}
      end;
    tkFloat:
      case TypeData.FloatType of
        ftSingle: Instance.Compare := @InterfaceDefaults.Compare_F4;
        ftDouble: Instance.Compare := @InterfaceDefaults.Compare_F8;
        ftExtended: Instance.Compare := @InterfaceDefaults.Compare_FE;
      else
        Instance.Compare := @InterfaceDefaults.Compare_U8;
      end;
    tkMethod:
      begin
        Instance.Compare := @InterfaceDefaults.Compare_Method;
      end;
    tkVariant:
      begin
        Instance.Compare := @InterfaceDefaults.Compare_Var;
      end;
    tkString:
      begin
        Instance.Compare := @InterfaceDefaults.Compare_OStr;
      end;
    tkLString:
      begin
        Instance.Compare := @InterfaceDefaults.Compare_LStr;
      end;
    {$IFDEF MSWINDOWS}
    tkWString:
      begin
        Instance.Compare := @InterfaceDefaults.Compare_WStr;
      end;
    {$ELSE}
    tkWString,
      {$ENDIF}
    tkUString:
      begin
        Instance.Compare := @InterfaceDefaults.Compare_UStr;
      end;
    tkDynArray:
      begin
        Instance.Size := TypeData.elSize;
        Instance.Compare := @InterfaceDefaults.Compare_Dyn;
      end;
  else
    // binary
    case SizeOf(T) of
      1: Instance.Compare := @InterfaceDefaults.Compare_U1;
      2: Instance.Compare := @InterfaceDefaults.Compare_Bin2;
      3: Instance.Compare := @InterfaceDefaults.Compare_Bin3;
      4: Instance.Compare := @InterfaceDefaults.Compare_Bin4;
      {$IFDEF LARGEINT}
      8: Instance.Compare := @InterfaceDefaults.Compare_Bin8;
      {$ENDIF}
    else
      Instance.Compare := @InterfaceDefaults.Compare_Bin;
    end;
  end;
end;

class constructor InterfaceDefaults.TDefaultEqualityComparer<T>.ClassCreate;
var
  TypeData: PTypeData;
begin
  Instance.Vtable := @Instance.QueryInterface;
  Instance.Size := SizeOf(T);
  Instance.QueryInterface := @InterfaceDefaults.NopQueryInterface;
  Instance.AddRef := @InterfaceDefaults.NopAddRef;
  Instance.Release := @InterfaceDefaults.NopRelease;

  // Equals/GetHashCode
  TypeData := Pointer(TypeInfo(T));
  Inc(NativeUInt(TypeData), NativeUInt(PByte(@PTypeInfo(TypeData).Name)^) + 2);
  case GetTypeKind(T) of
    tkClass:
      begin
        Instance.Equals := @InterfaceDefaults.Equals_Class;
        Instance.GetHashCode := @InterfaceDefaults.GetHashCode_Class;
      end;
    tkInterface, tkClassRef, tkPointer, tkProcedure:
      begin
        {$IFDEF LARGEINT}
        Instance.Equals := @InterfaceDefaults.Equals_N8;
        {$ELSE .SMALLINT}
        Instance.Equals := @InterfaceDefaults.Equals_N4;
        {$ENDIF}
        Instance.GetHashCode := @InterfaceDefaults.GetHashCode_Ptr;
      end;
    tkInt64:
      begin
        Instance.Equals := @InterfaceDefaults.Equals_N8;
        Instance.GetHashCode := @InterfaceDefaults.GetHashCode_N8;
      end;
    tkFloat:
      case TypeData.FloatType of
        ftSingle:
          begin
            Instance.Equals := @InterfaceDefaults.Equals_F4;
            Instance.GetHashCode := @InterfaceDefaults.GetHashCode_F4;
          end;
        ftDouble:
          begin
            Instance.Equals := @InterfaceDefaults.Equals_F8;
            Instance.GetHashCode := @InterfaceDefaults.GetHashCode_F8;
          end;
        ftExtended:
          begin
            Instance.Equals := @InterfaceDefaults.Equals_FE;
            Instance.GetHashCode := @InterfaceDefaults.GetHashCode_FE;
          end;
      else
        Instance.Equals := @InterfaceDefaults.Equals_N8;
        Instance.GetHashCode := @InterfaceDefaults.GetHashCode_N8;
      end;
    tkMethod:
      begin
        Instance.Equals := @InterfaceDefaults.Equals_Method;
        Instance.GetHashCode := @InterfaceDefaults.GetHashCode_Method;
      end;
    tkVariant:
      begin
        Instance.Equals := @InterfaceDefaults.Equals_Var;
        Instance.GetHashCode := @InterfaceDefaults.GetHashCode_Var;
      end;
    tkString:
      begin
        Instance.Equals := @InterfaceDefaults.Equals_OStr;
        Instance.GetHashCode := @InterfaceDefaults.GetHashCode_OStr;
      end;
    tkLString:
      begin
        Instance.Equals := @InterfaceDefaults.Equals_LStr;
        Instance.GetHashCode := @InterfaceDefaults.GetHashCode_LStr;
      end;
    {$IFDEF MSWINDOWS}
    tkWString:
      begin
        Instance.Equals := @InterfaceDefaults.Equals_WStr;
        Instance.GetHashCode := @InterfaceDefaults.GetHashCode_WStr;
      end;
    {$ELSE}
    tkWString,
      {$ENDIF}
    tkUString:
      begin
        Instance.Equals := @InterfaceDefaults.Equals_UStr;
        Instance.GetHashCode := @InterfaceDefaults.GetHashCode_UStr;
      end;
    tkDynArray:
      begin
        Instance.Size := TypeData.elSize;
        Instance.Equals := @InterfaceDefaults.Equals_Dyn;
        Instance.GetHashCode := @InterfaceDefaults.GetHashCode_Dyn;
      end;
  else
    // binary
    case SizeOf(T) of
      1:
        begin
          Instance.Equals := @InterfaceDefaults.Equals_N1;
          Instance.GetHashCode := @InterfaceDefaults.GetHashCode_N1;
        end;
      2:
        begin
          Instance.Equals := @InterfaceDefaults.Equals_N2;
          Instance.GetHashCode := @InterfaceDefaults.GetHashCode_N2;
        end;
      3:
        begin
          Instance.Equals := @InterfaceDefaults.Equals_Bin3;
          Instance.GetHashCode := @InterfaceDefaults.GetHashCode_Bin3;
        end;
      4:
        begin
          Instance.Equals := @InterfaceDefaults.Equals_N4;
          Instance.GetHashCode := @InterfaceDefaults.GetHashCode_N4;
        end;
      {$IFDEF LARGEINT}
      8:
        begin
          Instance.Equals := @InterfaceDefaults.Equals_N8;
          Instance.GetHashCode := @InterfaceDefaults.GetHashCode_N8;
        end;
      {$ENDIF}
    else
      Instance.Equals := @InterfaceDefaults.Equals_Bin;
      Instance.GetHashCode := @InterfaceDefaults.GetHashCode_Bin;
    end;
  end;
end;

class function InterfaceDefaults.NopQueryInterface(Inst: Pointer; const IID: TGUID; out Obj): HResult; stdcall;
begin
  Result := E_NOINTERFACE;
end;

class function InterfaceDefaults.NopAddRef(Inst: Pointer): Integer; stdcall;
begin
  Result := -1;
end;

class function InterfaceDefaults.NopRelease(Inst: Pointer): Integer; stdcall;
begin
  Result := -1;
end;

class function InterfaceDefaults.Compare_I1(Inst: Pointer; Left, Right: Shortint): Integer;
begin
  Result := Integer(Left) - Integer(Right);
end;

class function InterfaceDefaults.Compare_U1(Inst: Pointer; Left, Right: Byte): Integer;
begin
  Result := Integer(Left) - Integer(Right);
end;

class function InterfaceDefaults.Equals_N1(Inst: Pointer; Left, Right: Byte): Boolean;
begin
  Result := (Left = Right);
end;

class function InterfaceDefaults.GetHashCode_N1(Inst: Pointer; Value: Byte): Integer;
begin
  Result := Value;
  Inc(Result, +(Result shr 4) * 63689);
end;

class function InterfaceDefaults.Compare_I2(Inst: Pointer; Left, Right: Smallint): Integer;
begin
  Result := Integer(Left) - Integer(Right);
end;

class function InterfaceDefaults.Compare_U2(Inst: Pointer; Left, Right: Word): Integer;
begin
  Result := Integer(Left) - Integer(Right);
end;

class function InterfaceDefaults.Equals_N2(Inst: Pointer; Left, Right: Word): Boolean;
begin
  Result := (Left = Right);
end;

class function InterfaceDefaults.GetHashCode_N2(Inst: Pointer; Value: Word): Integer;
begin
  Result := Byte(Value);
  Inc(Result, (Result shr 4) * 63689);
  Inc(Result, (Integer(Value) shr 8) * -1660269137);
end;

class function InterfaceDefaults.Compare_I4(Inst: Pointer; Left, Right: Integer): Integer;
{$IFNDEF CPUINTELASM}
begin
  Result := Shortint(Byte(Left >= Right) - Byte(Left <= Right));
end;
{$ELSE}
asm
  xor eax, eax
  {$IFDEF CPUX86}
    cmp edx, ecx
  {$else .CPUX64}
    cmp edx, r8d
  {$ENDIF}
  mov edx, 1
  mov ecx, -1
  cmovg eax, edx
  cmovl eax, ecx
end;
{$ENDIF}

class function InterfaceDefaults.Compare_U4(Inst: Pointer; Left, Right: Cardinal): Integer;
{$IFNDEF CPUINTELASM}
begin
  Result := Shortint(Byte(Left >= Right) - Byte(Left <= Right));
end;
{$ELSE}
asm
  xor eax, eax
  {$IFDEF CPUX86}
    cmp edx, ecx
  {$else .CPUX64}
    cmp edx, r8d
  {$ENDIF}
  mov edx, 1
  mov ecx, -1
  cmova eax, edx
  cmovb eax, ecx
end;
{$ENDIF}

class function InterfaceDefaults.Equals_N4(Inst: Pointer; Left, Right: Integer): Boolean;
begin
  Result := (Left = Right);
end;

class function InterfaceDefaults.GetHashCode_N4(Inst: Pointer; Value: Integer): Integer;
begin
  Result := Value + ((Value shr 8) * 63689) + ((Value shr 16) * -1660269137) +
    ((Value shr 24) * -1092754919);
end;

class function InterfaceDefaults.Compare_I8(Inst: Pointer; Left, Right: Int64): Integer;
{$IF Defined(CPUX64ASM)}
asm
  xor eax, eax
  cmp rdx, r8
  mov edx, 1
  mov ecx, -1
  cmovg eax, edx
  cmovl eax, ecx
end;
{$ELSEIF Defined(LARGEINT)}
begin
  Result := Shortint(Byte(Left >= Right) - Byte(Left <= Right));
end;
{$ELSE .SMALLINT}
var
  IL, IR: Integer;
  UL, UR: Cardinal;
begin
  IL := TPoint(Left).Y;
  IR := TPoint(Right).Y;
  if (IL <> IR) then
  begin
    Result := Shortint(Byte(IL >= IR) - Byte(IL <= IR));
  end
  else
  begin
    UL := TPoint(Left).X;
    UR := TPoint(Right).X;
    Result := Shortint(Byte(UL >= UR) - Byte(UL <= UR));
  end;
end;
{$IFEND}

class function InterfaceDefaults.Compare_U8(Inst: Pointer; Left, Right: UInt64): Integer;
{$IF Defined(CPUX64ASM)}
asm
  xor eax, eax
  cmp rdx, r8
  mov edx, 1
  mov ecx, -1
  cmova eax, edx
  cmovb eax, ecx
end;
{$ELSEIF Defined(LARGEINT)}
begin
  Result := Shortint(Byte(Left >= Right) - Byte(Left <= Right));
end;
{$ELSE .SMALLINT}
type
  UInt64Rec = array[0..1] of Cardinal;
var
  Index: NativeUInt;
  L, R: ^UInt64Rec;
  UL, UR: Cardinal;
begin
  Index := Byte(TPoint(Left).Y <> TPoint(Right).Y);
  L := @UInt64Rec(Left);
  R := @UInt64Rec(Right);
  UL := L[Index];
  UR := R[Index];
  Result := Shortint(Byte(UL >= UR) - Byte(UL <= UR));
end;
{$IFEND}

class function InterfaceDefaults.Equals_N8(Inst: Pointer; Left, Right: Int64): Boolean;
begin
  {$IFDEF LARGEINT}
  Result := (Left = Right);
  {$ELSE .SMALLINT}
  Result := ((TPoint(Left).X - TPoint(Right).X) or (TPoint(Left).Y - TPoint(Right).Y) = 0);
  {$ENDIF}
end;

class function InterfaceDefaults.GetHashCode_N8(Inst: Pointer; Value: Int64): Integer;
begin
  {$IFDEF LARGEINT}
  Result := Integer(Value) + Integer(Value shr 32) * 63689;
  {$ELSE .SMALLINT}
  Result := TPoint(Value).X + TPoint(Value).Y * 63689;
  {$ENDIF}

  Inc(Result, ((Result shr 8) * 63689) + ((Result shr 16) * -1660269137) +
    ((Result shr 24) * -1092754919));
end;

class function InterfaceDefaults.Equals_Class(Inst: Pointer; Left, Right: TObject): Boolean;
begin
  if (Left <> nil) then
  begin
    if (PPointer(Pointer(Left)^)[vmtEquals div SizeOf(Pointer)] = @TObject.Equals) then
    begin
      Result := (Left = Right);
      Exit;
    end
    else
    begin
      Result := Left.Equals(Right);
      Exit;
    end;
  end
  else
  begin
    Result := (Right = nil);
  end;
end;

class function InterfaceDefaults.GetHashCode_Class(Inst: Pointer; Value: TObject): Integer;
begin
  if (Assigned(Value)) then
  begin
    if (PPointer(Pointer(Value)^)[vmtGetHashCode div SizeOf(Pointer)] = @TObject.GetHashCode) then
    begin
      {$IFDEF LARGEINT}
      Result := Integer(NativeInt(Value) xor (NativeInt(Value) shr 32));
      {$ELSE .SMALLINT}
      Result := Integer(Value);
      {$ENDIF}
      Inc(Result, ((Result shr 8) * 63689) + ((Result shr 16) * -1660269137) +
        ((Result shr 24) * -1092754919));
      Exit;
    end
    else
    begin
      Result := Value.GetHashCode;
      Exit;
    end;
  end
  else
  begin
    Result := 0;
  end;
end;

class function InterfaceDefaults.GetHashCode_Ptr(Inst: Pointer; Value: NativeInt): Integer;
begin
  {$IFDEF LARGEINT}
  Value := Value xor (Value shr 32);
  {$ENDIF}
  Result := Integer(Value);
  Inc(Result, ((Result shr 8) * 63689) + ((Result shr 16) * -1660269137) +
    ((Result shr 24) * -1092754919));
end;

class function InterfaceDefaults.Compare_F4(Inst: Pointer; Left, Right: Single): Integer;
{$IF Defined(CPUX86ASM)}
asm
  fld Left
  fcomp Right
  fstsw ax
  xor ecx, ecx
  or ebp, -1
  lea edx, [ecx + 1]
  test ax, 256
  cmovnz edx, ebp
  test ax, 16384
  cmovnz edx, ecx
  xchg eax, edx
end;
{$ELSEIF Defined(CPUX64ASM)}
asm
  or eax, -1
  xor edx, edx
  mov ecx, 1
  comiss xmm1,xmm2
  cmovz eax, edx
  cmova eax, ecx
end;
{$ELSE}
begin
  Result := Shortint(Byte(Left >= Right) - Byte(Left <= Right));
end;
{$IFEND}

class function InterfaceDefaults.Equals_F4(Inst: Pointer; Left, Right: Single): Boolean;
begin
  Result := (Left = Right);
end;

class function InterfaceDefaults.GetHashCode_F4(Inst: Pointer; Value: Single): Integer;
type
  TSingleRec = packed record
    Exponent: Integer;
    case Integer of
      0: (Mantissa: Single);
      1: (HighInt: Integer);
  end;
var
  SingleRec: TSingleRec;
begin
  Result := 0;
  if (Value <> 0) then
  begin
    Frexp(Value, SingleRec.Mantissa, SingleRec.Exponent);
    Result := SingleRec.Exponent + SingleRec.HighInt * 63689;
    Inc(Result, ((Result shr 8) * 63689) + ((Result shr 16) * -1660269137) +
      ((Result shr 24) * -1092754919));
  end;
end;

class function InterfaceDefaults.Compare_F8(Inst: Pointer; Left, Right: Double): Integer;
{$IF Defined(CPUX86ASM)}
asm
  fld Left
  fcomp Right
  fstsw ax
  xor ecx, ecx
  or ebp, -1
  lea edx, [ecx + 1]
  test ax, 256
  cmovnz edx, ebp
  test ax, 16384
  cmovnz edx, ecx
  xchg eax, edx
end;
{$ELSEIF Defined(CPUX64ASM)}
asm
  or eax, -1
  xor edx, edx
  mov ecx, 1
  comisd xmm1,xmm2
  cmovz eax, edx
  cmova eax, ecx
end;
{$ELSE}
begin
  Result := Shortint(Byte(Left >= Right) - Byte(Left <= Right));
end;
{$IFEND}

class function InterfaceDefaults.Equals_F8(Inst: Pointer; Left, Right: Double): Boolean;
begin
  Result := (Left = Right);
end;

class function InterfaceDefaults.GetHashCode_F8(Inst: Pointer; Value: Double): Integer;
type
  TDoubleRec = packed record
    Exponent: Integer;
    case Integer of
      0: (Mantissa: Double);
      1: (LowInt: Integer; HighInt: Integer);
  end;
var
  DoubleRec: TDoubleRec;
begin
  Result := 0;
  if (Value <> 0) then
  begin
    Frexp(Value, DoubleRec.Mantissa, DoubleRec.Exponent);
    Result := DoubleRec.Exponent + DoubleRec.LowInt * 63689 + DoubleRec.HighInt * -1660269137;
    Inc(Result, ((Result shr 8) * 63689) + ((Result shr 16) * -1660269137) +
      ((Result shr 24) * -1092754919));
  end;
end;

class function InterfaceDefaults.Compare_FE(Inst: Pointer; Left, Right: Extended): Integer;
{$IF Defined(CPUX86ASM)}
asm
  fld Right
  fld Left
  fcompp
  fstsw ax
  xor ecx, ecx
  or ebp, -1
  lea edx, [ecx + 1]
  test ax, 256
  cmovnz edx, ebp
  test ax, 16384
  cmovnz edx, ecx
  xchg eax, edx
end;
{$ELSEIF Defined(CPUX64ASM)}
asm
  or eax, -1
  xor edx, edx
  mov ecx, 1
  comisd xmm1,xmm2
  cmovz eax, edx
  cmova eax, ecx
end;
{$ELSE}
begin
  Result := Shortint(Byte(Left >= Right) - Byte(Left <= Right));
end;
{$IFEND}

class function InterfaceDefaults.Equals_FE(Inst: Pointer; Left, Right: Extended): Boolean;
begin
  Result := (Left = Right);
end;

class function InterfaceDefaults.GetHashCode_FE(Inst: Pointer; Value: Extended): Integer;
type
  TExtendedRec = packed record
    Exponent: Integer;
    case Integer of
      0: (Mantissa: Extended);
      1: (LowInt: Integer; {$IF SizeOf(Extended) = 10}Middle: Word; {$IFEND}HighInt: Integer);
  end;
var
  ExtendedRec: TExtendedRec;
begin
  Result := 0;
  if (Value <> 0) then
  begin
    Frexp(Value, ExtendedRec.Mantissa, ExtendedRec.Exponent);
    Result := ExtendedRec.Exponent + ExtendedRec.LowInt * 63689 + ExtendedRec.HighInt * -1660269137
      {$IF SizeOf(Extended) = 10} + Integer(ExtendedRec.Middle) * -1092754919{$IFEND};
    Inc(Result, ((Result shr 8) * 63689) + ((Result shr 16) * -1660269137) +
      ((Result shr 24) * -1092754919));
  end;
end;

class function InterfaceDefaults.Compare_Var_Difficult(Equal: Boolean; Left, Right: PVariant): Integer;
var
  S1, S2: string;
  Inst: IComparerInst;
begin
  try
    if (Left^ = Right^) then
    begin
      Result := 0;
    end
    else if (not Equal) then
    begin
      Result := 2 * Ord(Left^ > Right^) - 1;
    end
    else
    begin
      Result := 1;
    end;
  except // if comparison failed with exception, compare as string.
    try
      S1 := Left^;
      S2 := Right^;
      if (Equal) and (Length(S1) <> Length(S2)) then
        Exit(1);
      Result := InterfaceDefaults.Compare_UStr(nil, Pointer(S1), Pointer(S2));
    except // if comparison fails again, compare bytes.
      Inst.Size := SizeOf(Variant);
      Result := InterfaceDefaults.Compare_Bin(Inst, Pointer(Left), Pointer(Right));
    end;
  end;
end;

class function InterfaceDefaults.Compare_Var(Inst: Pointer; Left, Right: PVarData): Integer;
label
  has_left, has_right, difficult;
var
  VLeft, VRight: Integer;
begin
  VLeft := Left.VType;
  if (VLeft <> varByRef or varVariant) then
  begin
    has_left:
    VRight := Right.VType;
    if (VRight <> varByRef or varVariant) then
    begin
      has_right:
      if (VLeft > varNull) and (VRight > varNull) then
      begin
        if (VLeft <> VRight) then
          goto difficult;

        case (VLeft) of
          varShortInt:
            begin
              Result := Integer(Left.VShortInt) - Integer(Right.VShortInt);
            end;
          varBoolean, varByte:
            begin
              Result := Integer(Left.VByte) - Integer(Right.VByte);
            end;
          varSmallint:
            begin
              Result := Integer(Left.VSmallInt) - Integer(Right.VSmallInt);
            end;
          varWord:
            begin
              Result := Integer(Left.VWord) - Integer(Right.VWord);
            end;
          varInteger:
            begin
              Result := Shortint(Byte(Left.VInteger >= Right.VInteger) - Byte(Left.VInteger <= Right.VInteger));
            end;
          varLongWord:
            begin
              Result := Shortint(Byte(Left.VLongWord >= Right.VLongWord) - Byte(Left.VLongWord <= Right.VLongWord));
            end;
          varInt64, varCurrency:
            begin
              {$IFDEF LARGEINT}
              Result := Shortint(Byte(Left.VInt64 >= Right.VInt64) - Byte(Left.VInt64 <= Right.VInt64));
              {$ELSE .SMALLINT}
              VLeft := Left.VLongs[2];
              VRight := Right.VLongs[2];
              if (VLeft <> VRight) then
              begin
                Result := Shortint(Byte(VLeft >= VRight) - Byte(VLeft <= VRight));
              end
              else
              begin
                VLeft := Left.VInteger;
                VRight := Right.VInteger;
                Result := Shortint(Byte(Cardinal(VLeft) >= Cardinal(VRight)) - Byte(Cardinal(VLeft) <=
                  Cardinal(VRight)));
              end;
              {$ENDIF}
            end;
          varUInt64:
            begin
              {$IFDEF LARGEINT}
              Result := Shortint(Byte(Left.VUInt64 >= Right.VUInt64) - Byte(Left.VUInt64 <= Right.VUInt64));
              {$ELSE .SMALLINT}
              VLeft := Left.VLongs[2];
              VRight := Right.VLongs[2];
              if (VLeft = VRight) then
              begin
                VLeft := Left.VInteger;
                VRight := Right.VInteger;
              end;
              Result := Shortint(Byte(Cardinal(VLeft) >= Cardinal(VRight)) - Byte(Cardinal(VLeft) <=
                Cardinal(VRight)));
              {$ENDIF}
            end;
          varSingle:
            begin
              Result := Shortint(Byte(Left.VSingle >= Right.VSingle) - Byte(Left.VSingle <= Right.VSingle));
            end;
          varDouble, varDate:
            begin
              Result := Shortint(Byte(Left.VDouble >= Right.VDouble) - Byte(Left.VDouble <= Right.VDouble));
            end;
          varString:
            begin
              Result := InterfaceDefaults.Compare_LStr(nil, Left.VPointer, Right.VPointer);
            end;
          varUString:
            begin
              Result := InterfaceDefaults.Compare_UStr(nil, Left.VPointer, Right.VPointer);
            end;
          varOleStr:
            begin
              Result := InterfaceDefaults.Compare_WStr(nil, Left.VPointer, Right.VPointer);
            end;
        else
          difficult:
          Result := InterfaceDefaults.Compare_Var_Difficult(False, PVariant(Left), PVariant(Right));
        end;
      end
      else
      begin
        Result := 0;
      end;
    end
    else
    begin
      repeat
        Right := Right.VPointer;
        VRight := Right.VType;
      until (VRight <> varByRef or varVariant);
      goto has_right;
    end;
  end
  else
  begin
    repeat
      Left := Left.VPointer;
      VLeft := Left.VType;
    until (VLeft <> varByRef or varVariant);
    goto has_left;
  end;
end;

class function InterfaceDefaults.Equals_Var(Inst: Pointer; Left, Right: PVarData): Boolean;
var
  VLeft, VRight: Integer;
begin
  VLeft := Left.VType;
  if (VLeft = varByRef or varVariant) then
    repeat
      Left := Left.VPointer;
      VLeft := Left.VType;
    until (VLeft <> varByRef or varVariant);

  VRight := Right.VType;
  if (VRight = varByRef or varVariant) then
    repeat
      Right := Right.VPointer;
      VRight := Right.VType;
    until (VRight <> varByRef or varVariant);

  if (VLeft > varNull) and (VRight > varNull) then
  begin
    if (VLeft = VRight) then
      case (VLeft) of
        varShortInt, varBoolean, varByte:
          begin
            Result := (Left.VByte = Right.VByte);
            Exit;
          end;
        varSmallint, varWord:
          begin
            Result := (Left.VWord = Right.VWord);
            Exit;
          end;
        varInteger, varLongWord:
          begin
            Result := (Left.VInteger = Right.VInteger);
            Exit;
          end;
        varInt64, varCurrency, varUInt64:
          begin
            {$IFDEF LARGEINT}
            Result := (Left.VInt64 = Right.VInt64);
            {$ELSE .SMALLINT}
            Result := ((Left.VLongs[1] - Right.VLongs[1]) or (Left.VLongs[2] - Right.VLongs[2]) = 0);
            {$ENDIF}
            Exit;
          end;
        varSingle:
          begin
            Result := (Left.VSingle >= Right.VSingle) = (Left.VSingle <= Right.VSingle);
            Exit;
          end;
        varDouble, varDate:
          begin
            Result := (Left.VDouble >= Right.VDouble) = (Left.VDouble <= Right.VDouble);
            Exit;
          end;
        varString:
          begin
            Result := InterfaceDefaults.Equals_LStr(nil, Left.VPointer, Right.VPointer);
            Exit;
          end;
        varUString:
          begin
            Result := InterfaceDefaults.Equals_UStr(nil, Left.VPointer, Right.VPointer);
            Exit;
          end;
        varOleStr:
          begin
            Result := InterfaceDefaults.Equals_WStr(nil, Left.VPointer, Right.VPointer);
            Exit;
          end;
      end;

    Result := (InterfaceDefaults.Compare_Var_Difficult(True, PVariant(Left), PVariant(Right)) = 0);
  end
  else
  begin
    Result := True;
  end;
end;

class function InterfaceDefaults.GetHashCode_Var_Difficult(Value: PVariant): Integer;
var
  S: string;
  Instance: IEqualityComparerInst;
begin
  try
    S := Value^;
    Result := GetHashCode_UStr(nil, Pointer(S));
  except
    Instance.Size := SizeOf(Variant);
    Result := GetHashCode_Bin(Instance, Pointer(Value));
  end;
end;

class function InterfaceDefaults.GetHashCode_Var(Inst: Pointer; Value: PVarData): Integer;
label
  hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7, hash8, hash9, hash10,
    null, write_uint64, init_write_cardinal, write_cardinal,
    write_ordinal_string, write_terminated_string, write_string;
const
  DIGITS: array[0..99] of array[1..2] of Char = (
    '00', '01', '02', '03', '04', '05', '06', '07', '08', '09',
    '10', '11', '12', '13', '14', '15', '16', '17', '18', '19',
    '20', '21', '22', '23', '24', '25', '26', '27', '28', '29',
    '30', '31', '32', '33', '34', '35', '36', '37', '38', '39',
    '40', '41', '42', '43', '44', '45', '46', '47', '48', '49',
    '50', '51', '52', '53', '54', '55', '56', '57', '58', '59',
    '60', '61', '62', '63', '64', '65', '66', '67', '68', '69',
    '70', '71', '72', '73', '74', '75', '76', '77', '78', '79',
    '80', '81', '82', '83', '84', '85', '86', '87', '88', '89',
    '90', '91', '92', '93', '94', '95', '96', '97', '98', '99');
var
  V32: Cardinal;
  V64, V64Buffer: UInt64;
  VFloat: Extended;
  VSign: Boolean;
  S, Top: PChar;
  Count: NativeUInt;
  M, N: Integer;
  Buffer: array[0..31] of Char;
begin
  VSign := False;

  case Integer(Value.VType) of
    varEmpty, varNull:
      begin
        null:
        Result := 0;
        Exit;
      end;
    varBoolean:
      begin
        if (Value.VBoolean) then
        begin
          Result := -34292652;
          Exit;
        end
        else
        begin
          Result := 1454490910;
          Exit;
        end;
      end;
    varShortInt:
      begin
        V32 := Cardinal(Integer(Value.VShortInt));
        if (Integer(V32) < 0) then
        begin
          VSign := True;
          V32 := Cardinal(-Integer(V32));
        end;
        goto init_write_cardinal;
      end;
    varByte:
      begin
        V32 := Value.VByte;
        goto init_write_cardinal;
      end;
    varSmallint:
      begin
        V32 := Cardinal(Integer(Value.VSmallInt));
        if (Integer(V32) < 0) then
        begin
          VSign := True;
          V32 := Cardinal(-Integer(V32));
        end;
        goto init_write_cardinal;
      end;
    varWord:
      begin
        V32 := Value.VWord;
        goto init_write_cardinal;
      end;
    varInteger:
      begin
        V32 := Cardinal(Integer(Value.VInteger));
        if (Integer(V32) < 0) then
        begin
          VSign := True;
          V32 := Cardinal(-Integer(V32));
        end;
        goto init_write_cardinal;
      end;
    varLongWord:
      begin
        V32 := Value.VLongWord;
        goto init_write_cardinal;
      end;
    varInt64:
      begin
        V64 := Value.VUInt64;
        if ({$IFDEF LARGEINT}Int64(V64){$ELSE}TPoint(V64).Y{$ENDIF} < 0) then
        begin
          VSign := True;
          Int64(V64) := -Int64(V64);
        end;
        goto write_uint64;
      end;
    varUInt64:
      begin
        V64 := Value.VUInt64;
        write_uint64:
        S := @Buffer[High(Buffer)];
        V32 := V64;
        if ({$IFDEF LARGEINT}V64 <> V32{$ELSE}TPoint(V64).Y <> 0{$ENDIF}) then
          repeat
            V64Buffer := V64;
            V64 := V64 div 100;
            V64Buffer := V64Buffer - V64 * 100;
            Dec(S, 2);
            PCardinal(S)^ := PCardinal(@DIGITS[NativeUInt(V64Buffer)])^;
            V32 := V64;
          until ({$IFDEF LARGEINT}V64 = V32{$ELSE}TPoint(V64).Y = 0{$ENDIF});
        goto write_cardinal;
      end;
    varSingle:
      begin
        VFloat := Value.VSingle;
        Top := @Buffer[FloatToText(Buffer, VFloat, fvExtended, ffGeneral, 15, 0, FormatSettings)];
        S := @Buffer[0];
        goto write_terminated_string;
      end;
    varDouble:
      begin
        VFloat := Value.VDouble;
        Top := @Buffer[FloatToText(Buffer, VFloat, fvExtended, ffGeneral, 15, 0, FormatSettings)];
        S := @Buffer[0];
        goto write_terminated_string;
      end;
    varCurrency:
      begin
        Top := @Buffer[FloatToText(Buffer, Value.VCurrency, fvCurrency, ffGeneral, 0, 0, FormatSettings)];
        S := @Buffer[0];
        goto write_terminated_string;
      end;
    varUString:
      begin
        S := Value.VPointer;
        if (S = nil) then
          goto null;
        Top := Pointer(@S[PInteger(PByte(S) - SizeOf(Integer))^]);
        goto write_string;
      end;
    varOleStr:
      begin
        S := Value.VPointer;
        if (S = nil) then
          goto null;
        Top := Pointer(@S[PInteger(PByte(S) - SizeOf(Integer))^ {$IFDEF MSWINDOWS} shr 1{$ENDIF}]);
        {$IFDEF MSWINDOWS}if (S = Top) then
          goto null; {$ENDIF}
        goto write_string;
      end;
  else
    Result := GetHashCode_Var_Difficult(Pointer(Value));
    Exit;
  end;

  init_write_cardinal:
  S := @Buffer[High(Buffer)];
  write_cardinal:
  if (V32 >= 10000) then
  begin
    if (V32 >= 100000000) then
    begin
      M := V32;
      V32 := V32 div 100;
      Dec(M, Integer(V32) * 100);
      Dec(S, 2);
      PCardinal(S)^ := PCardinal(@DIGITS[M])^;
    end;
    M := V32;
    V32 := V32 div 10000;
    Dec(M, Integer(V32) * 10000);
    N := (M * $147B) shr 19; // N := M div 100;
    M := M - (N * 100); // M := M mod 100;
    Dec(S, 2);
    PCardinal(S)^ := PCardinal(@DIGITS[M])^;
    Dec(S, 2);
    PCardinal(S)^ := PCardinal(@DIGITS[N])^;
  end;
  N := (Integer(V32) * $147B) shr 19; // N := M div 100;
  M := Integer(V32) - (N * 100); // M := M mod 100;
  Dec(S, 2);
  PCardinal(S)^ := PCardinal(@DIGITS[M])^;
  Dec(S, 2);
  PCardinal(S)^ := PCardinal(@DIGITS[N])^;
  Inc(S, 3);
  Dec(S, Byte(Byte(V32 > 9) + Byte(V32 > 99) + Byte(V32 > 999)));

  write_ordinal_string:
  Top := @Buffer[High(Buffer)];
  if (VSign) then
  begin
    Dec(S);
    S^ := '-';
  end;

  // InterfaceDefaults.GetHashCode_UStr(S..Top)
  write_terminated_string:
  Top^ := #0;
  write_string:
  Inc(Top);
  Count := NativeInt(Top) - NativeInt(S);
  Count := Count and -4;
  Result := Integer(Count) + PInteger(@PByte(S)[Count - SizeOf(Integer)])^ * 63689;
  case (Count - 1) shr 2 of
    10: goto hash10;
    9: goto hash9;
    8: goto hash8;
    7: goto hash7;
    6: goto hash6;
    5: goto hash5;
    4: goto hash4;
    3: goto hash3;
    2: goto hash2;
    1: goto hash1;
    0: goto hash0;
  else
    Dec(Count);
    M := -1660269137;
    repeat
      Result := Result * M + PInteger(S)^;
      Dec(Count, SizeOf(Integer));
      Inc(PByte(S), SizeOf(Integer));
      M := M * 378551;
    until (Count <= 43);

    hash10:
    Result := Result * 631547855 + PInteger(S)^;
    Inc(PByte(S), SizeOf(Integer));
    hash9:
    Result := Result * -1987506439 + PInteger(S)^;
    Inc(PByte(S), SizeOf(Integer));
    hash8:
    Result := Result * -1653913089 + PInteger(S)^;
    Inc(PByte(S), SizeOf(Integer));
    hash7:
    Result := Result * -186114231 + PInteger(S)^;
    Inc(PByte(S), SizeOf(Integer));
    hash6:
    Result := Result * 915264303 + PInteger(S)^;
    Inc(PByte(S), SizeOf(Integer));
    hash5:
    Result := Result * -794603367 + PInteger(S)^;
    Inc(PByte(S), SizeOf(Integer));
    hash4:
    Result := Result * 135394143 + PInteger(S)^;
    Inc(PByte(S), SizeOf(Integer));
    hash3:
    Result := Result * 2012804575 + PInteger(S)^;
    Inc(PByte(S), SizeOf(Integer));
    hash2:
    Result := Result * -1092754919 + PInteger(S)^;
    Inc(PByte(S), SizeOf(Integer));
    hash1:
    Result := Result * -1660269137 + PInteger(S)^;
    hash0:
  end;

  Inc(Result, ((Result shr 8) * 63689) + ((Result shr 16) * -1660269137) +
    ((Result shr 24) * -1092754919));
end;

class function InterfaceDefaults.Compare_OStr(Inst: Pointer; Left, Right: PByte): Integer;
label
  make_result, make_result_swaped;
var
  X, Y, Count: NativeUInt;
  Modify: Integer;
begin
  X := Left^;
  Y := Right^;
  if (Left <> Right) and (X <> 0) and (Y <> 0) then
  begin
    if (Left[1] = Right[1]) then
    begin
      if (X < Y) then
      begin
        Modify := -1;
        Count := X;
      end
      else
      begin
        Modify := NativeInt(Y - X) shr {$IFDEF SMALLINT}31{$ELSE}63{$ENDIF};
        Count := Y;
      end;
      Inc(Left);
      Inc(Right);

      repeat
        if (Count < SizeOf(NativeUInt)) then
          Break;
        X := PNativeUInt(Left)^;
        Dec(Count, SizeOf(NativeUInt));
        Y := PNativeUInt(Right)^;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));

        if (X <> Y) then
        begin
          {$IFDEF LARGEINT}
          if (Integer(X) = Integer(Y)) then
          begin
            X := X shr 32;
            Y := Y shr 32;
          end
          else
          begin
            X := Cardinal(X);
            Y := Cardinal(Y);
          end;
          {$ENDIF}

          goto make_result;
        end;
      until (False);

      {$IFDEF LARGEINT}
      if (Count and 4 <> 0) then
      begin
        X := PCardinal(Left)^;
        Y := PCardinal(Right)^;
        Inc(Left, SizeOf(Cardinal));
        Inc(Right, SizeOf(Cardinal));

        if (X <> Y) then
          goto make_result;
      end;
      {$ENDIF}

      case Count of
        1:
          begin
            X := PByte(Left)^;
            Y := PByte(Right)^;
            if (X <> Y) then
              goto make_result_swaped;
          end;
        2:
          begin
            X := Swap(PWord(Left)^);
            Y := Swap(PWord(Right)^);
            if (X <> Y) then
              goto make_result_swaped;
          end;
        3:
          begin
            X := Swap(PWord(Left)^);
            Y := Swap(PWord(Right)^);
            Inc(Left, SizeOf(Word));
            Inc(Right, SizeOf(Word));
            X := (X shl 8) or PByte(Left)^;
            Y := (Y shl 8) or PByte(Right)^;
            if (X <> Y) then
              goto make_result_swaped;
          end;
      end;

      Result := Modify;
      Exit;
      make_result:
      X := (Swap(X) shl 16) + Swap(X shr 16);
      Y := (Swap(Y) shl 16) + Swap(Y shr 16);

      make_result_swaped:
      Result := Shortint(Byte(X >= Y) - Byte(X <= Y));
      Exit;
    end
    else
    begin
      Inc(Left);
      Inc(Right);
      X := Left^;
      Y := Right^;
    end;
  end;

  Result := Integer(X) - Integer(Y);
end;

class function InterfaceDefaults.Equals_OStr(Inst: Pointer; Left, Right: PByte): Boolean;
label
  cmp0, cmp1, cmp2, cmp3, cmp4, cmp5, {$IFDEF SMALLINT}cmp6, cmp7, cmp8, cmp9, cmp10, {$ENDIF}
  done;
var
  Count: NativeUInt;
begin
  if (Left = Right) then
    goto done;
  Count := Left^;
  if (Count <> Right^) then
    goto done;

  // natives (40 bytes static) compare
  case Count shr {$IFDEF LARGEINT}3{$ELSE}2{$ENDIF} of
    {$IFDEF SMALLINT}
    10: goto cmp10;
    9: goto cmp9;
    8: goto cmp8;
    7: goto cmp7;
    6: goto cmp6;
    {$ENDIF}
    5: goto cmp5;
    4: goto cmp4;
    3: goto cmp3;
    2: goto cmp2;
    1: goto cmp1;
    0: goto cmp0;
  else
    repeat
      if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
        goto done;
      Dec(Count, SizeOf(NativeUInt));
      Inc(Left, SizeOf(NativeUInt));
      Inc(Right, SizeOf(NativeUInt));
    until (Count < (40 + SizeOf(NativeUInt) - 1));

    {$IFDEF SMALLINT}
    cmp10:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp9:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp8:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp7:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp6:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    {$ENDIF}
    cmp5:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp4:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp3:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp2:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp1:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp0:
  end;

  {$IFDEF LARGEINT}
  if (Count and 4 <> 0) then
  begin
    if (PCardinal(Left)^ <> PCardinal(Right)^) then
      goto done;
    Inc(Left, SizeOf(Cardinal));
    Inc(Right, SizeOf(Cardinal));
  end;
  {$ENDIF}

  if (Count and 3 <> 0) then
  begin
    if (Count and 2 <> 0) then
    begin
      if (PWord(Left)^ <> PWord(Right)^) then
        goto done;
    end;
    Dec(Left);
    Dec(Right);
    if (Left[Count] <> Right[Count]) then
      goto done;
  end;

// Result := True
  Left := nil;
  Right := nil;
  done:
  Result := (Left = Right);
end;

class function InterfaceDefaults.GetHashCode_OStr(Inst: Pointer; Value: PByte): Integer;
label
  hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7, hash8, hash9, hash10;
var
  Count: NativeUInt;
  M: Integer;
begin
  Count := Value^;
  Inc(Count);

  if (Count >= SizeOf(Integer)) then
  begin
    Result := Integer(Count) + PInteger(@Value[Count - SizeOf(Integer)])^ * 63689;

    case (Count - 1) shr 2 of
      10: goto hash10;
      9: goto hash9;
      8: goto hash8;
      7: goto hash7;
      6: goto hash6;
      5: goto hash5;
      4: goto hash4;
      3: goto hash3;
      2: goto hash2;
      1: goto hash1;
      0: goto hash0;
    else
      Dec(Count);
      M := -1660269137;
      repeat
        Result := Result * M + PInteger(Value)^;
        Dec(Count, SizeOf(Integer));
        Inc(Value, SizeOf(Integer));
        M := M * 378551;
      until (Count <= 43);

      hash10:
      Result := Result * 631547855 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash9:
      Result := Result * -1987506439 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash8:
      Result := Result * -1653913089 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash7:
      Result := Result * -186114231 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash6:
      Result := Result * 915264303 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash5:
      Result := Result * -794603367 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash4:
      Result := Result * 135394143 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash3:
      Result := Result * 2012804575 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash2:
      Result := Result * -1092754919 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash1:
      Result := Result * -1660269137 + PInteger(Value)^;
      hash0:
    end;

    Inc(Result, ((Result shr 8) * 63689) + ((Result shr 16) * -1660269137) +
      ((Result shr 24) * -1092754919));
    Exit;
  end
  else
  begin
    Result := Integer(Value[0]);
    Result := Result + (Result shr 4) * 63689;
    if (Count > 1) then
    begin
      Result := Result + Integer(Value[1]) * -1660269137;
      if (Count > 2) then
      begin
        Result := Result + Integer(Value[2]) * -1092754919;
      end;
    end;
  end;
end;

class function InterfaceDefaults.Compare_LStr(Inst: Pointer; Left, Right: PByte): Integer;
label
  make_result, make_result_swaped;
var
  X, Y, Count: NativeUInt;
  Modify: Integer;
begin
  X := NativeUInt(Left);
  Y := NativeUInt(Right);
  if (Left = nil) or (Right = nil) or (Left = Right) then
    goto make_result_swaped;

  X := Left^;
  Y := Right^;
  if (X <> Y) then
    goto make_result_swaped;

  Dec(Left, SizeOf(Integer));
  Dec(Right, SizeOf(Integer));
  X := PInteger(Left)^;
  Y := PInteger(Right)^;
  Inc(Left, SizeOf(Integer));
  Inc(Right, SizeOf(Integer));
  if (X < Y) then
  begin
    Modify := -1;
    Count := X + 1;
  end
  else
  begin
    Modify := NativeInt(Y - X) shr {$IFDEF SMALLINT}31{$ELSE}63{$ENDIF};
    Count := Y + 1;
  end;

  repeat
    if (Count < SizeOf(NativeUInt)) then
      Break;
    X := PNativeUInt(Left)^;
    Dec(Count, SizeOf(NativeUInt));
    Y := PNativeUInt(Right)^;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));

    if (X <> Y) then
    begin
      {$IFDEF LARGEINT}
      if (Integer(X) = Integer(Y)) then
      begin
        X := X shr 32;
        Y := Y shr 32;
      end
      else
      begin
        X := Cardinal(X);
        Y := Cardinal(Y);
      end;
      {$ENDIF}

      goto make_result;
    end;
  until (False);

  {$IFDEF LARGEINT}
  if (Count and 4 <> 0) then
  begin
    X := PCardinal(Left)^;
    Y := PCardinal(Right)^;
    Inc(Left, SizeOf(Cardinal));
    Inc(Right, SizeOf(Cardinal));

    if (X <> Y) then
      goto make_result;
  end;
  {$ENDIF}

  if (Count and 2 <> 0) then
  begin
    X := Swap(PWord(Left)^);
    Y := Swap(PWord(Right)^);
    if (X <> Y) then
      goto make_result_swaped;
  end;

  Result := Modify;
  Exit;
  make_result:
  X := (Swap(X) shl 16) + Swap(X shr 16);
  Y := (Swap(Y) shl 16) + Swap(Y shr 16);

  make_result_swaped:
  Result := Shortint(Byte(X >= Y) - Byte(X <= Y));
end;

class function InterfaceDefaults.Equals_LStr(Inst: Pointer; Left, Right: PByte): Boolean;
label
  cmp0, cmp1, cmp2, cmp3, cmp4, cmp5, {$IFDEF SMALLINT}cmp6, cmp7, cmp8, cmp9, cmp10, {$ENDIF}
  done;
var
  Count: NativeUInt;
begin
  if (Left = nil) or (Right = nil) or (Left = Right) then
    goto done;
  Dec(Left, SizeOf(Integer));
  Dec(Right, SizeOf(Integer));
  Count := PInteger(Left)^;
  if (Integer(Count) <> PInteger(Right)^) then
    goto done;
  Inc(Count);
  Inc(Left, SizeOf(Integer));
  Inc(Right, SizeOf(Integer));

  // natives (40 bytes static) compare
  case Count shr {$IFDEF LARGEINT}3{$ELSE}2{$ENDIF} of
    {$IFDEF SMALLINT}
    10: goto cmp10;
    9: goto cmp9;
    8: goto cmp8;
    7: goto cmp7;
    6: goto cmp6;
    {$ENDIF}
    5: goto cmp5;
    4: goto cmp4;
    3: goto cmp3;
    2: goto cmp2;
    1: goto cmp1;
    0: goto cmp0;
  else
    repeat
      if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
        goto done;
      Dec(Count, SizeOf(NativeUInt));
      Inc(Left, SizeOf(NativeUInt));
      Inc(Right, SizeOf(NativeUInt));
    until (Count < (40 + SizeOf(NativeUInt) - 1));

    {$IFDEF SMALLINT}
    cmp10:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp9:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp8:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp7:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp6:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    {$ENDIF}
    cmp5:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp4:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp3:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp2:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp1:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp0:
  end;

  {$IFDEF LARGEINT}
  if (Count and 4 <> 0) then
  begin
    if (PCardinal(Left)^ <> PCardinal(Right)^) then
      goto done;
    Inc(Left, SizeOf(Cardinal));
    Inc(Right, SizeOf(Cardinal));
  end;
  {$ENDIF}

  if (Count and 2 <> 0) then
  begin
    if (PWord(Left)^ <> PWord(Right)^) then
      goto done;
  end;

// Result := True
  Left := nil;
  Right := nil;
  done:
  Result := (Left = Right);
end;

class function InterfaceDefaults.GetHashCode_LStr(Inst: Pointer; Value: PByte): Integer;
label
  hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7, hash8, hash9, hash10;
var
  Count: NativeUInt;
  M: Integer;
begin
  if (Value <> nil) then
  begin
    Count := PInteger(@Value[-SizeOf(Integer)])^;

    if (Count >= SizeOf(Integer)) then
    begin
      Result := Integer(Count) + PInteger(@Value[Count - SizeOf(Integer)])^ * 63689;

      case (Count - 1) shr 2 of
        10: goto hash10;
        9: goto hash9;
        8: goto hash8;
        7: goto hash7;
        6: goto hash6;
        5: goto hash5;
        4: goto hash4;
        3: goto hash3;
        2: goto hash2;
        1: goto hash1;
        0: goto hash0;
      else
        Dec(Count);
        M := -1660269137;
        repeat
          Result := Result * M + PInteger(Value)^;
          Dec(Count, SizeOf(Integer));
          Inc(Value, SizeOf(Integer));
          M := M * 378551;
        until (Count <= 43);

        hash10:
        Result := Result * 631547855 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash9:
        Result := Result * -1987506439 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash8:
        Result := Result * -1653913089 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash7:
        Result := Result * -186114231 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash6:
        Result := Result * 915264303 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash5:
        Result := Result * -794603367 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash4:
        Result := Result * 135394143 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash3:
        Result := Result * 2012804575 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash2:
        Result := Result * -1092754919 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash1:
        Result := Result * -1660269137 + PInteger(Value)^;
        hash0:
      end;

      Inc(Result, ((Result shr 8) * 63689) + ((Result shr 16) * -1660269137) +
        ((Result shr 24) * -1092754919));
      Exit;
    end
    else
    begin
      Result := Integer(Value[0]);
      Result := Result + (Result shr 4) * 63689;
      if (Count > 1) then
      begin
        Result := Result + Integer(Value[1]) * -1660269137;
        if (Count > 2) then
        begin
          Result := Result + Integer(Value[2]) * -1092754919;
        end;
      end;
    end;
  end
  else
  begin
    Result := 0;
  end;
end;

class function InterfaceDefaults.Compare_UStr(Inst: Pointer; Left, Right: PByte): Integer;
label
  make_result, make_result_swaped;
var
  X, Y, Count: NativeUInt;
  Modify: Integer;
begin
  X := NativeUInt(Left);
  Y := NativeUInt(Right);
  if (Left = nil) or (Right = nil) or (Left = Right) then
    goto make_result_swaped;

  X := PWord(Left)^;
  Y := PWord(Right)^;
  if (X <> Y) then
    goto make_result_swaped;

  Dec(Left, SizeOf(Integer));
  Dec(Right, SizeOf(Integer));
  X := PInteger(Left)^;
  Y := PInteger(Right)^;
  Inc(Left, SizeOf(Integer));
  Inc(Right, SizeOf(Integer));
  if (X < Y) then
  begin
    Modify := -1;
    Count := X * 2 + 2;
  end
  else
  begin
    Modify := NativeInt(Y - X) shr {$IFDEF SMALLINT}31{$ELSE}63{$ENDIF};
    Count := Y * 2 + 2;
  end;

  repeat
    if (Count < SizeOf(NativeUInt)) then
      Break;
    X := PNativeUInt(Left)^;
    Dec(Count, SizeOf(NativeUInt));
    Y := PNativeUInt(Right)^;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));

    if (X <> Y) then
    begin
      {$IFDEF LARGEINT}
      if (Integer(X) = Integer(Y)) then
      begin
        X := X shr 32;
        Y := Y shr 32;
      end
      else
      begin
        X := Cardinal(X);
        Y := Cardinal(Y);
      end;
      {$ENDIF}

      goto make_result;
    end;
  until (False);

  {$IFDEF LARGEINT}
  if (Count and 4 <> 0) then
  begin
    X := PCardinal(Left)^;
    Y := PCardinal(Right)^;
    if (X <> Y) then
      goto make_result;
  end;
  {$ENDIF}

  Result := Modify;
  Exit;
  make_result:
  X := {$IFDEF LARGEINT}Cardinal{$ENDIF}(X shl 16) + (X shr 16);
  Y := {$IFDEF LARGEINT}Cardinal{$ENDIF}(Y shl 16) + (Y shr 16);
  make_result_swaped:
  Result := Shortint(Byte(X >= Y) - Byte(X <= Y));
end;

class function InterfaceDefaults.Equals_UStr(Inst: Pointer; Left, Right: PByte): Boolean;
label
  cmp0, cmp1, cmp2, cmp3, cmp4, cmp5, {$IFDEF SMALLINT}cmp6, cmp7, cmp8, cmp9, cmp10, {$ENDIF}
  done;
var
  Count: NativeUInt;
begin
  if (Left = nil) or (Right = nil) or (Left = Right) then
    goto done;
  Dec(Left, SizeOf(Integer));
  Dec(Right, SizeOf(Integer));
  Count := PInteger(Left)^;
  if (Integer(Count) <> PInteger(Right)^) then
    goto done;
  Count := Count * 2 + 2;
  Inc(Left, SizeOf(Integer));
  Inc(Right, SizeOf(Integer));

  // natives (40 bytes static) compare
  case Count shr {$IFDEF LARGEINT}3{$ELSE}2{$ENDIF} of
    {$IFDEF SMALLINT}
    10: goto cmp10;
    9: goto cmp9;
    8: goto cmp8;
    7: goto cmp7;
    6: goto cmp6;
    {$ENDIF}
    5: goto cmp5;
    4: goto cmp4;
    3: goto cmp3;
    2: goto cmp2;
    1: goto cmp1;
    0: goto cmp0;
  else
    repeat
      if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
        goto done;
      Dec(Count, SizeOf(NativeUInt));
      Inc(Left, SizeOf(NativeUInt));
      Inc(Right, SizeOf(NativeUInt));
    until (Count < (40 + SizeOf(NativeUInt) - 1));

    {$IFDEF SMALLINT}
    cmp10:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp9:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp8:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp7:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp6:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    {$ENDIF}
    cmp5:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp4:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp3:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp2:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp1:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    {$IFDEF LARGEINT}
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    {$ENDIF}
    cmp0:
  end;

  {$IFDEF LARGEINT}
  if (Count and 4 <> 0) then
  begin
    if (PCardinal(Left)^ <> PCardinal(Right)^) then
      goto done;
  end;
  {$ENDIF}

// Result := True
  Left := nil;
  Right := nil;
  done:
  Result := (Left = Right);
end;

class function InterfaceDefaults.GetHashCode_UStr(Inst: Pointer; Value: PByte): Integer;
label
  hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7, hash8, hash9, hash10;
var
  Count: NativeUInt;
  M: Integer;
begin
  if (Value <> nil) then
  begin
    Count := PInteger(@Value[-SizeOf(Integer)])^;
    Count := Count * 2 + 2;
    Count := Count and -4;

    Result := Integer(Count) + PInteger(@Value[Count - SizeOf(Integer)])^ * 63689;
    case (Count - 1) shr 2 of
      10: goto hash10;
      9: goto hash9;
      8: goto hash8;
      7: goto hash7;
      6: goto hash6;
      5: goto hash5;
      4: goto hash4;
      3: goto hash3;
      2: goto hash2;
      1: goto hash1;
      0: goto hash0;
    else
      Dec(Count);
      M := -1660269137;
      repeat
        Result := Result * M + PInteger(Value)^;
        Dec(Count, SizeOf(Integer));
        Inc(Value, SizeOf(Integer));
        M := M * 378551;
      until (Count <= 43);

      hash10:
      Result := Result * 631547855 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash9:
      Result := Result * -1987506439 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash8:
      Result := Result * -1653913089 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash7:
      Result := Result * -186114231 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash6:
      Result := Result * 915264303 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash5:
      Result := Result * -794603367 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash4:
      Result := Result * 135394143 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash3:
      Result := Result * 2012804575 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash2:
      Result := Result * -1092754919 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash1:
      Result := Result * -1660269137 + PInteger(Value)^;
      hash0:
    end;

    Inc(Result, ((Result shr 8) * 63689) + ((Result shr 16) * -1660269137) +
      ((Result shr 24) * -1092754919));
    Exit;
  end
  else
  begin
    Result := 0;
  end;
end;

class function InterfaceDefaults.Compare_WStr(Inst: Pointer; Left, Right: PByte): Integer;
label
  {$IFDEF MSWINDOWS}left_nil, right_nil, {$ENDIF}
  make_result, make_result_swaped;
var
  X, Y, Count: NativeUInt;
  Modify: Integer;
begin
  X := NativeUInt(Left);
  Y := NativeUInt(Right);
  if (Left = Right) then
    goto make_result_swaped;
  if (Left = nil) then
    goto {$IFDEF MSWINDOWS}left_nil{$ELSE}make_result_swaped{$ENDIF};
  if (Right = nil) then
    goto {$IFDEF MSWINDOWS}right_nil{$ELSE}make_result_swaped{$ENDIF};

  X := PWord(Left)^;
  Y := PWord(Right)^;
  if (X <> Y) then
    goto make_result_swaped;

  Dec(Left, SizeOf(Integer));
  Dec(Right, SizeOf(Integer));
  X := PInteger(Left)^;
  Y := PInteger(Right)^;
  Inc(Left, SizeOf(Integer));
  Inc(Right, SizeOf(Integer));
  if (X < Y) then
  begin
    Modify := -1;
    Count := X {$IFNDEF MSWINDOWS} * 2{$ENDIF} + 2;
  end
  else
  begin
    Modify := NativeInt(Y - X) shr {$IFDEF SMALLINT}31{$ELSE}63{$ENDIF};
    Count := Y {$IFNDEF MSWINDOWS} * 2{$ENDIF} + 2;
  end;

  repeat
    if (Count < SizeOf(NativeUInt)) then
      Break;
    X := PNativeUInt(Left)^;
    Dec(Count, SizeOf(NativeUInt));
    Y := PNativeUInt(Right)^;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));

    if (X <> Y) then
    begin
      {$IFDEF LARGEINT}
      if (Integer(X) = Integer(Y)) then
      begin
        X := X shr 32;
        Y := Y shr 32;
      end
      else
      begin
        X := Cardinal(X);
        Y := Cardinal(Y);
      end;
      {$ENDIF}

      goto make_result;
    end;
  until (False);

  {$IFDEF LARGEINT}
  if (Count and 4 <> 0) then
  begin
    X := PCardinal(Left)^;
    Y := PCardinal(Right)^;
    if (X <> Y) then
      goto make_result;
  end;
  {$ENDIF}

  Result := Modify;
  Exit;
  make_result:
  X := {$IFDEF LARGEINT}Cardinal{$ENDIF}(X shl 16) + (X shr 16);
  Y := {$IFDEF LARGEINT}Cardinal{$ENDIF}(Y shl 16) + (Y shr 16);
  make_result_swaped:
  Result := Shortint(Byte(X >= Y) - Byte(X <= Y));
  {$IFDEF MSWINDOWS}
  Exit;
  left_nil:
  Dec(Right, SizeOf(Integer));
  Result := -Ord(PInteger(Right)^ <> 0);
  Exit;
  right_nil:
  Dec(Left, SizeOf(Integer));
  Result := Ord(PInteger(Left)^ <> 0);
  {$ENDIF}
end;

class function InterfaceDefaults.Equals_WStr(Inst: Pointer; Left, Right: PByte): Boolean;
label
  cmp0, cmp1, cmp2, cmp3, cmp4, cmp5, {$IFDEF SMALLINT}cmp6, cmp7, cmp8, cmp9, cmp10, {$ENDIF}
  {$IFDEF MSWINDOWS}left_nil, right_nil, {$ENDIF}
  done;
var
  Count: NativeUInt;
begin
  if (Left = Right) then
    goto done;
  if (Left = nil) then
    goto {$IFDEF MSWINDOWS}left_nil{$ELSE}done{$ENDIF};
  if (Right = nil) then
    goto {$IFDEF MSWINDOWS}right_nil{$ELSE}done{$ENDIF};
  Dec(Left, SizeOf(Integer));
  Dec(Right, SizeOf(Integer));
  Count := PInteger(Left)^;
  if (Integer(Count) <> PInteger(Right)^) then
    goto done;
  Count := Count {$IFNDEF MSWINDOWS} * 2{$ENDIF} + 2;
  Inc(Left, SizeOf(Integer));
  Inc(Right, SizeOf(Integer));

  // natives (40 bytes static) compare
  case Count shr {$IFDEF LARGEINT}3{$ELSE}2{$ENDIF} of
    {$IFDEF SMALLINT}
    10: goto cmp10;
    9: goto cmp9;
    8: goto cmp8;
    7: goto cmp7;
    6: goto cmp6;
    {$ENDIF}
    5: goto cmp5;
    4: goto cmp4;
    3: goto cmp3;
    2: goto cmp2;
    1: goto cmp1;
    0: goto cmp0;
  else
    repeat
      if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
        goto done;
      Dec(Count, SizeOf(NativeUInt));
      Inc(Left, SizeOf(NativeUInt));
      Inc(Right, SizeOf(NativeUInt));
    until (Count < (40 + SizeOf(NativeUInt) - 1));

    {$IFDEF SMALLINT}
    cmp10:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp9:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp8:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp7:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp6:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    {$ENDIF}
    cmp5:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp4:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp3:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp2:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp1:
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    {$IFDEF LARGEINT}
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    {$ENDIF}
    cmp0:
  end;

  {$IFDEF LARGEINT}
  if (Count and 4 <> 0) then
  begin
    if (PCardinal(Left)^ <> PCardinal(Right)^) then
      goto done;
  end;
  {$ENDIF}

// Result := True
  Left := nil;
  Right := nil;
  done:
  Result := (Left = Right);
  {$IFDEF MSWINDOWS}
  Exit;
  left_nil:
  Dec(Right, SizeOf(Integer));
  Result := (PInteger(Right)^ = 0);
  Exit;
  right_nil:
  Dec(Left, SizeOf(Integer));
  Result := (PInteger(Left)^ = 0);
  {$ENDIF}
end;

class function InterfaceDefaults.GetHashCode_WStr(Inst: Pointer; Value: PByte): Integer;
label
  {$IFDEF MSWINDOWS}null, {$ENDIF}
  hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7, hash8, hash9, hash10;
var
  Count: NativeUInt;
  M: Integer;
begin
  if (Value <> nil) then
  begin
    Count := PInteger(@Value[-SizeOf(Integer)])^;
    {$IFDEF MSWINDOWS}if (Count = 0) then
      goto null; {$ENDIF}
    Count := Count {$IFNDEF MSWINDOWS} * 2{$ENDIF} + 2;
    Count := Count and -4;

    Result := Integer(Count) + PInteger(@Value[Count - SizeOf(Integer)])^ * 63689;
    case (Count - 1) shr 2 of
      10: goto hash10;
      9: goto hash9;
      8: goto hash8;
      7: goto hash7;
      6: goto hash6;
      5: goto hash5;
      4: goto hash4;
      3: goto hash3;
      2: goto hash2;
      1: goto hash1;
      0: goto hash0;
    else
      Dec(Count);
      M := -1660269137;
      repeat
        Result := Result * M + PInteger(Value)^;
        Dec(Count, SizeOf(Integer));
        Inc(Value, SizeOf(Integer));
        M := M * 378551;
      until (Count <= 43);

      hash10:
      Result := Result * 631547855 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash9:
      Result := Result * -1987506439 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash8:
      Result := Result * -1653913089 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash7:
      Result := Result * -186114231 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash6:
      Result := Result * 915264303 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash5:
      Result := Result * -794603367 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash4:
      Result := Result * 135394143 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash3:
      Result := Result * 2012804575 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash2:
      Result := Result * -1092754919 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash1:
      Result := Result * -1660269137 + PInteger(Value)^;
      hash0:
    end;

    Inc(Result, ((Result shr 8) * 63689) + ((Result shr 16) * -1660269137) +
      ((Result shr 24) * -1092754919));
    Exit;
  end
  else
  begin
    {$IFDEF MSWINDOWS}null: {$ENDIF}
    Result := 0;
  end;
end;

class function InterfaceDefaults.Compare_Method(Inst: Pointer; const Left, Right: TMethodPtr): Integer;
var
  X, Y: NativeUInt;
begin
  X := NativeUInt(TMethod(Left).Data);
  Y := NativeUInt(TMethod(Right).Data);
  if (X = Y) then
  begin
    X := NativeUInt(TMethod(Left).Code);
    Y := NativeUInt(TMethod(Right).Code);
  end;

  Result := Shortint(Byte(X >= Y) - Byte(X <= Y));
end;

class function InterfaceDefaults.Equals_Method(Inst: Pointer; const Left, Right: TMethodPtr): Boolean;
begin
  Result := ((NativeInt(TMethod(Left).Data) - NativeInt(TMethod(Right).Data)) or
    (NativeInt(TMethod(Left).Code) - NativeInt(TMethod(Right).Code)) = 0);
end;

class function InterfaceDefaults.GetHashCode_Method(Inst: Pointer; const Value: TMethodPtr): Integer;
{$IFDEF LARGEINT}
var
  Data: PByte;
  {$ENDIF}
begin
  {$IFDEF SMALLINT}
  Result := PPoint(@Value).X + PPoint(@Value).Y * 63689;
  {$ELSE .LARGEINT}
  Data := Pointer(@Value);
  Result := Integer(SizeOf(TMethodPtr)) + PInteger(Data)[3] * 63689;
  Result := Result * 2012804575 + PInteger(Data)[0];
  Result := Result * -1092754919 + PInteger(Data)[1];
  Result := Result * -1660269137 + PInteger(Data)[2];
  {$ENDIF}

  Inc(Result, ((Result shr 8) * 63689) + ((Result shr 16) * -1660269137) +
    ((Result shr 24) * -1092754919));
end;

class function InterfaceDefaults.Compare_Dyn(const Inst: IComparerInst; Left, Right: PByte): Integer;
label
  make_result, make_result_swaped;
var
  X, Y, Count: NativeUInt;
  Modify: Integer;
begin
  Count := Inst.Size;
  X := NativeUInt(Left);
  Y := NativeUInt(Right);
  if (Left = nil) or (Right = nil) or (Left = Right) then
    goto make_result_swaped;

  X := Left^;
  Y := Right^;
  if (X <> Y) then
    goto make_result_swaped;

  Dec(Left, SizeOf(NativeUInt));
  Dec(Right, SizeOf(NativeUInt));
  X := PNativeUInt(Left)^;
  Y := PNativeUInt(Right)^;
  Inc(Left, SizeOf(NativeUInt));
  Inc(Right, SizeOf(NativeUInt));
  if (X < Y) then
  begin
    Modify := -1;
    NativeInt(Count) := NativeInt(Count) * NativeInt(X);
  end
  else
  begin
    Modify := NativeInt(Y - X) shr {$IFDEF SMALLINT}31{$ELSE}63{$ENDIF};
    NativeInt(Count) := NativeInt(Count) * NativeInt(Y);
  end;

  repeat
    if (Count < SizeOf(NativeUInt)) then
      Break;
    X := PNativeUInt(Left)^;
    Dec(Count, SizeOf(NativeUInt));
    Y := PNativeUInt(Right)^;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));

    if (X <> Y) then
    begin
      {$IFDEF LARGEINT}
      if (Integer(X) = Integer(Y)) then
      begin
        X := X shr 32;
        Y := Y shr 32;
      end
      else
      begin
        X := Cardinal(X);
        Y := Cardinal(Y);
      end;
      {$ENDIF}

      goto make_result;
    end;
  until (False);

  {$IFDEF LARGEINT}
  if (Count and 4 <> 0) then
  begin
    X := PCardinal(Left)^;
    Y := PCardinal(Right)^;
    Inc(Left, SizeOf(Cardinal));
    Inc(Right, SizeOf(Cardinal));

    if (X <> Y) then
      goto make_result;
  end;
  {$ENDIF}

  case Count of
    1:
      begin
        X := PByte(Left)^;
        Y := PByte(Right)^;
        if (X <> Y) then
          goto make_result_swaped;
      end;
    2:
      begin
        X := Swap(PWord(Left)^);
        Y := Swap(PWord(Right)^);
        if (X <> Y) then
          goto make_result_swaped;
      end;
    3:
      begin
        X := Swap(PWord(Left)^);
        Y := Swap(PWord(Right)^);
        Inc(Left, SizeOf(Word));
        Inc(Right, SizeOf(Word));
        X := (X shl 8) or PByte(Left)^;
        Y := (Y shl 8) or PByte(Right)^;
        if (X <> Y) then
          goto make_result_swaped;
      end;
  end;

  Result := Modify;
  Exit;
  make_result:
  X := (Swap(X) shl 16) + Swap(X shr 16);
  Y := (Swap(Y) shl 16) + Swap(Y shr 16);

  make_result_swaped:
  Result := Shortint(Byte(X >= Y) - Byte(X <= Y));
end;

class function InterfaceDefaults.Equals_Dyn(const Inst: IEqualityComparerInst; Left, Right: PByte): Boolean;
label
  cmp0, cmp1, cmp2, cmp3, cmp4, cmp5, {$IFDEF SMALLINT}cmp6, cmp7, cmp8, cmp9, cmp10, {$ENDIF}
  done;
var
  Count: NativeUInt;
begin
  if (Left = nil) or (Right = nil) or (Left = Right) then
    goto done;
  Dec(Left, SizeOf(Integer));
  Dec(Right, SizeOf(Integer));
  Count := PInteger(Left)^;
  if (Integer(Count) <> PInteger(Right)^) then
    goto done;
  NativeInt(Count) := NativeInt(Count) * Inst.Size;
  Inc(Left, SizeOf(Integer));
  Inc(Right, SizeOf(Integer));

  // natives (40 bytes static) compare
  case Count shr {$IFDEF LARGEINT}3{$ELSE}2{$ENDIF} of
    {$IFDEF SMALLINT}
    10: goto cmp10;
    9: goto cmp9;
    8: goto cmp8;
    7: goto cmp7;
    6: goto cmp6;
    {$ENDIF}
    5: goto cmp5;
    4: goto cmp4;
    3: goto cmp3;
    2: goto cmp2;
    1: goto cmp1;
    0: goto cmp0;
  else
    repeat
      if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
        goto done;
      Dec(Count, SizeOf(NativeUInt));
      Inc(Left, SizeOf(NativeUInt));
      Inc(Right, SizeOf(NativeUInt));
    until (Count < (40 + SizeOf(NativeUInt) - 1));

    {$IFDEF SMALLINT}
    cmp10:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp9:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp8:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp7:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp6:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    {$ENDIF}
    cmp5:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp4:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp3:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp2:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp1:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp0:
  end;

  {$IFDEF LARGEINT}
  if (Count and 4 <> 0) then
  begin
    if (PCardinal(Left)^ <> PCardinal(Right)^) then
      goto done;
    Inc(Left, SizeOf(Cardinal));
    Inc(Right, SizeOf(Cardinal));
  end;
  {$ENDIF}

  if (Count and 3 <> 0) then
  begin
    if (Count and 2 <> 0) then
    begin
      if (PWord(Left)^ <> PWord(Right)^) then
        goto done;
    end;
    Dec(Left);
    Dec(Right);
    if (Left[Count] <> Right[Count]) then
      goto done;
  end;

// Result := True
  Left := nil;
  Right := nil;
  done:
  Result := (Left = Right);
end;

class function InterfaceDefaults.GetHashCode_Dyn(const Inst: IEqualityComparerInst; Value: PByte): Integer;
label
  hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7, hash8, hash9, hash10;
var
  Count: NativeUInt;
  M: Integer;
begin
  if (Value <> nil) then
  begin
    Count := NativeUInt(PNativeInt(@Value[-SizeOf(NativeInt)])^ * Inst.Size);

    if (Count >= SizeOf(Integer)) then
    begin
      Result := Integer(Count) + PInteger(@Value[Count - SizeOf(Integer)])^ * 63689;

      case (Count - 1) shr 2 of
        10: goto hash10;
        9: goto hash9;
        8: goto hash8;
        7: goto hash7;
        6: goto hash6;
        5: goto hash5;
        4: goto hash4;
        3: goto hash3;
        2: goto hash2;
        1: goto hash1;
        0: goto hash0;
      else
        Dec(Count);
        M := -1660269137;
        repeat
          Result := Result * M + PInteger(Value)^;
          Dec(Count, SizeOf(Integer));
          Inc(Value, SizeOf(Integer));
          M := M * 378551;
        until (Count <= 43);

        hash10:
        Result := Result * 631547855 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash9:
        Result := Result * -1987506439 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash8:
        Result := Result * -1653913089 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash7:
        Result := Result * -186114231 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash6:
        Result := Result * 915264303 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash5:
        Result := Result * -794603367 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash4:
        Result := Result * 135394143 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash3:
        Result := Result * 2012804575 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash2:
        Result := Result * -1092754919 + PInteger(Value)^;
        Inc(Value, SizeOf(Integer));
        hash1:
        Result := Result * -1660269137 + PInteger(Value)^;
        hash0:
      end;

      Inc(Result, ((Result shr 8) * 63689) + ((Result shr 16) * -1660269137) +
        ((Result shr 24) * -1092754919));
      Exit;
    end
    else
    begin
      Result := Integer(Value[0]);
      Result := Result + (Result shr 4) * 63689;
      if (Count > 1) then
      begin
        Result := Result + Integer(Value[1]) * -1660269137;
        if (Count > 2) then
        begin
          Result := Result + Integer(Value[2]) * -1092754919;
        end;
      end;
    end;
  end
  else
  begin
    Result := 0;
  end;
end;

//class function InterfaceDefaults.Compare_Bin(const Inst: IComparerInst; Left, Right: PByte): Integer;
//label
//  make_result, make_result_swaped;
//var
//  X, Y, Count: NativeUInt;
//begin
//  Count := Inst.Size;
//  repeat
//    if (Count < SizeOf(NativeUInt)) then Break;
//    X := PNativeUInt(Left)^;
//    Dec(Count, SizeOf(NativeUInt));
//    Y := PNativeUInt(Right)^;
//    Inc(Left, SizeOf(NativeUInt));
//    Inc(Right, SizeOf(NativeUInt));
//
//    if (X <> Y) then
//    begin
//      {$IFDEF LARGEINT}
//        if (Integer(X) = Integer(Y)) then
//        begin
//          X := X shr 32;
//          Y := Y shr 32;
//        end else
//        begin
//          X := Cardinal(X);
//          Y := Cardinal(Y);
//        end;
//      {$ENDIF}
//
//      goto make_result;
//    end;
//  until (False);
//
//  // read last
//  {$IFDEF LARGEINT}
//  if (Count >= SizeOf(Cardinal)) then
//  begin
//    X := PCardinal(Left)^;
//    Dec(Count, SizeOf(Cardinal));
//    Y := PCardinal(Right)^;
//    Inc(Left, SizeOf(Cardinal));
//    Inc(Right, SizeOf(Cardinal));
//
//    if (X <> Y) then goto make_result;
//  end;
//  {$ENDIF}
//
//  case Count of
//    1: begin
//         X := PByte(Left)^;
//         Y := PByte(Right)^;
//         Result := Integer(X) - Integer(Y);
//         Exit;
//       end;
//    2: begin
//         X := Swap(PWord(Left)^);
//         Y := Swap(PWord(Right)^);
//         Result := Integer(X) - Integer(Y);
//         Exit;
//       end;
//    3: begin
//         X := Swap(PWord(Left)^);
//         Y := Swap(PWord(Right)^);
//         Inc(Left, SizeOf(Word));
//         Inc(Right, SizeOf(Word));
//         X := (X shl 8) or PByte(Left)^;
//         Y := (Y shl 8) or PByte(Right)^;
//         Result := Integer(X) - Integer(Y);
//         Exit;
//       end;
//  else
//    // 0
//    Result := 0;
//    Exit;
//  end;
//
//make_result:
//  X := (Swap(X) shl 16) + Swap(X shr 16);
//  Y := (Swap(Y) shl 16) + Swap(Y shr 16);
//
//make_result_swaped:
//  Result := Shortint(Byte(X >= Y) - Byte(X <= Y));
//end;

class function InterfaceDefaults.Compare_Bin2(Inst: Pointer; Left, Right: Word): Integer;
var
  L, R: NativeUInt;
begin
  L := Left;
  R := Right;
  L := Swap(L);
  R := Swap(R);
  Result := Integer(L) - Integer(R);
end;

class function InterfaceDefaults.Compare_Bin3(Inst: Pointer; const Left, Right: TTriple): Integer;
var
  L, R: NativeUInt;
begin
  L := Left.Low;
  R := Right.Low;
  L := (Swap(L) shl 8) + Left.High;
  R := (Swap(R) shl 8) + Right.High;
  Result := Integer(L) - Integer(R);
end;

class function InterfaceDefaults.Equals_Bin3(Inst: Pointer; const Left, Right: TTriple): Boolean;
begin
  Result := ((Integer(Left.High) shl 16) + Left.Low) = ((Integer(Right.High) shl 16) + Right.Low);
end;

class function InterfaceDefaults.GetHashCode_Bin3(Inst: Pointer; const Value: TTriple): Integer;
begin
  Result := Integer(Value.Bytes[0]);
  Result := Result + (Result shr 4) * 63689 + Integer(Value.Bytes[1]) * -1660269137 +
    Integer(Value.Bytes[2]) * -1092754919;
end;

class function InterfaceDefaults.Compare_Bin4(Inst: Pointer; Left, Right: Cardinal): Integer;
var
  X, Y: NativeUInt;
begin
  {$IFDEF LARGEINT}
  X := Left;
  Y := Right;
  X := (Swap(X) shl 16) + Swap(X shr 16);
  Y := (Swap(Y) shl 16) + Swap(Y shr 16);
  {$ELSE .SMALLINT}
  X := (Swap(Left) shl 16) + Swap(Left shr 16);
  Y := (Swap(Right) shl 16) + Swap(Right shr 16);
  {$ENDIF}

  Result := Shortint(Byte(X >= Y) - Byte(X <= Y));
end;

class function InterfaceDefaults.Compare_Bin8(Inst: Pointer; Left, Right: Int64): Integer;
var
  X, Y: NativeUInt;
begin
  {$IFDEF LARGEINT}
  if (Integer(Left) = Integer(Right)) then
  begin
    Left := Left shr 32;
    Right := Right shr 32;
  end
  else
  begin
    Left := Cardinal(Left);
    Right := Cardinal(Right);
  end;
  X := (Swap(Left) shl 16) + Swap(Left shr 16);
  Y := (Swap(Right) shl 16) + Swap(Right shr 16);
  {$ELSE .SMALLINT}
  X := TPoint(Left).X;
  Y := TPoint(Right).X;
  if (X = Y) then
  begin
    X := TPoint(Left).Y;
    Y := TPoint(Right).Y;
  end;
  X := (Swap(X) shl 16) + Swap(X shr 16);
  Y := (Swap(Y) shl 16) + Swap(Y shr 16);
  {$ENDIF}

  Result := Shortint(Byte(X >= Y) - Byte(X <= Y));
end;

class function InterfaceDefaults.Compare_Bin(const Inst: IComparerInst; Left, Right: PByte): Integer;
label
  make_result, make_result_swaped;
var
  X, Y, Count: NativeUInt;
begin
  // Handle nil cases
  if (Left = nil) and (Right = nil) then
  begin
    Result := 0; // Equal if both are nil
    Exit;
  end;
  if (Left = nil) then
  begin
    Result := -1; // nil is less than non-nil
    Exit;
  end;
  if (Right = nil) then
  begin
    Result := 1; // non-nil is greater than nil
    Exit;
  end;

  Count := Inst.Size;
  repeat
    if (Count < SizeOf(NativeUInt)) then
      Break;
    X := PNativeUInt(Left)^;
    Dec(Count, SizeOf(NativeUInt));
    Y := PNativeUInt(Right)^;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));

    if (X <> Y) then
    begin
      {$IFDEF LARGEINT}
      if (Integer(X) = Integer(Y)) then
      begin
        X := X shr 32;
        Y := Y shr 32;
      end
      else
      begin
        X := Cardinal(X);
        Y := Cardinal(Y);
      end;
      {$ENDIF}

      goto make_result;
    end;
  until (False);

  // read last
  {$IFDEF LARGEINT}
  if (Count >= SizeOf(Cardinal)) then
  begin
    X := PCardinal(Left)^;
    Dec(Count, SizeOf(Cardinal));
    Y := PCardinal(Right)^;
    Inc(Left, SizeOf(Cardinal));
    Inc(Right, SizeOf(Cardinal));

    if (X <> Y) then
      goto make_result;
  end;
  {$ENDIF}

  case Count of
    1:
      begin
        X := PByte(Left)^;
        Y := PByte(Right)^;
        Result := Integer(X) - Integer(Y);
        Exit;
      end;
    2:
      begin
        X := Swap(PWord(Left)^);
        Y := Swap(PWord(Right)^);
        Result := Integer(X) - Integer(Y);
        Exit;
      end;
    3:
      begin
        X := Swap(PWord(Left)^);
        Y := Swap(PWord(Right)^);
        Inc(Left, SizeOf(Word));
        Inc(Right, SizeOf(Word));
        X := (X shl 8) or PByte(Left)^;
        Y := (Y shl 8) or PByte(Right)^;
        Result := Integer(X) - Integer(Y);
        Exit;
      end;
  else
    // 0
    Result := 0;
    Exit;
  end;

  make_result:
  X := (Swap(X) shl 16) + Swap(X shr 16);
  Y := (Swap(Y) shl 16) + Swap(Y shr 16);

  make_result_swaped:
  Result := Shortint(Byte(X >= Y) - Byte(X <= Y));
end;

class function InterfaceDefaults.Equals_Bin(const Inst: IEqualityComparerInst; Left, Right: PByte): Boolean;
label
  cmp0, cmp1, cmp2, cmp3, cmp4, cmp5, {$IFDEF SMALLINT}cmp6, cmp7, cmp8, cmp9, cmp10, {$ENDIF}
  done;
var
  Count: NativeUInt;
begin
  if (Left = Right) then
    goto done;
  Count := Inst.Size;

  // natives (40 bytes static) compare
  case Count shr {$IFDEF LARGEINT}3{$ELSE}2{$ENDIF} of
    {$IFDEF SMALLINT}
    10: goto cmp10;
    9: goto cmp9;
    8: goto cmp8;
    7: goto cmp7;
    6: goto cmp6;
    {$ENDIF}
    5: goto cmp5;
    4: goto cmp4;
    3: goto cmp3;
    2: goto cmp2;
    1: goto cmp1;
    0: goto cmp0;
  else
    repeat
      if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
        goto done;
      Dec(Count, SizeOf(NativeUInt));
      Inc(Left, SizeOf(NativeUInt));
      Inc(Right, SizeOf(NativeUInt));
    until (Count < (40 + SizeOf(NativeUInt) - 1));

    {$IFDEF SMALLINT}
    cmp10:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp9:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp8:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp7:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp6:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    {$ENDIF}
    cmp5:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp4:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp3:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp2:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp1:
    Dec(Count, SizeOf(NativeUInt));
    if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
      goto done;
    Inc(Left, SizeOf(NativeUInt));
    Inc(Right, SizeOf(NativeUInt));
    cmp0:
  end;

  {$IFDEF LARGEINT}
  if (Count and 4 <> 0) then
  begin
    if (PCardinal(Left)^ <> PCardinal(Right)^) then
      goto done;
    Inc(Left, SizeOf(Cardinal));
    Inc(Right, SizeOf(Cardinal));
  end;
  {$ENDIF}

  if (Count and 3 <> 0) then
  begin
    if (Count and 2 <> 0) then
    begin
      if (PWord(Left)^ <> PWord(Right)^) then
        goto done;
    end;
    Dec(Left);
    Dec(Right);
    if (Left[Count] <> Right[Count]) then
      goto done;
  end;

// Result := True
  Left := nil;
  Right := nil;
  done:
  Result := (Left = Right);
end;

class function InterfaceDefaults.GetHashCode_Bin(const Inst: IEqualityComparerInst; Value: PByte): Integer;
label
  hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7, hash8, hash9, hash10;
var
  Count: NativeUInt;
  M: Integer;
begin
  Count := Inst.Size;

  if (Count >= SizeOf(Integer)) then
  begin
    Result := Integer(Count) + PInteger(@Value[Count - SizeOf(Integer)])^ * 63689;

    case (Count - 1) shr 2 of
      10: goto hash10;
      9: goto hash9;
      8: goto hash8;
      7: goto hash7;
      6: goto hash6;
      5: goto hash5;
      4: goto hash4;
      3: goto hash3;
      2: goto hash2;
      1: goto hash1;
      0: goto hash0;
    else
      Dec(Count);
      M := -1660269137;
      repeat
        Result := Result * M + PInteger(Value)^;
        Dec(Count, SizeOf(Integer));
        Inc(Value, SizeOf(Integer));
        M := M * 378551;
      until (Count <= 43);

      hash10:
      Result := Result * 631547855 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash9:
      Result := Result * -1987506439 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash8:
      Result := Result * -1653913089 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash7:
      Result := Result * -186114231 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash6:
      Result := Result * 915264303 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash5:
      Result := Result * -794603367 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash4:
      Result := Result * 135394143 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash3:
      Result := Result * 2012804575 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash2:
      Result := Result * -1092754919 + PInteger(Value)^;
      Inc(Value, SizeOf(Integer));
      hash1:
      Result := Result * -1660269137 + PInteger(Value)^;
      hash0:
    end;

    Inc(Result, ((Result shr 8) * 63689) + ((Result shr 16) * -1660269137) +
      ((Result shr 24) * -1092754919));
    Exit;
  end
  else if (Count <> 0) then
  begin
    Result := Integer(Value[0]);
    Result := Result + (Result shr 4) * 63689;
    if (Count > 1) then
    begin
      Result := Result + Integer(Value[1]) * -1660269137;
      if (Count > 2) then
      begin
        Result := Result + Integer(Value[2]) * -1092754919;
      end;
    end;
  end
  else
  begin
    Result := 0;
  end;
end;

{ TComparer<T> }

class function TComparer<T>.Default: IComparer<T>;
begin
  Result := IComparer<T>(Pointer(@InterfaceDefaults.TDefaultComparer<T>.Instance));
end;

class function TComparer<T>.Construct(const Comparison: TComparison<T>): IComparer<T>;
begin
  { Much faster way to have IComparer<T> interface, than
    TDelegatedComparer<T> instance }
  //IInterface(Result) := IInterface(PPointer(@Comparison)^);
  Result := IComparer<T>(PPointer(@Comparison)^);
end;

{ TEqualityComparer<T> }

class function TEqualityComparer<T>.Default: IEqualityComparer<T>;
begin
  Result := IEqualityComparer<T>(Pointer(@InterfaceDefaults.TDefaultEqualityComparer<T>.Instance));
end;

class function TEqualityComparer<T>.Construct(
  const EqualityComparison: TEqualityComparison<T>;
  const Hasher: THasher<T>): IEqualityComparer<T>;
begin
  Result := TDelegatedEqualityComparer<T>.Create(EqualityComparison, Hasher);
end;

{ TSingletonImplementation }

function TSingletonImplementation.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TSingletonImplementation._AddRef: Integer;
begin
  Result := -1;
end;

function TSingletonImplementation._Release: Integer;
begin
  Result := -1;
end;

{ Delegated Comparers }

constructor TDelegatedComparer<T>.Create(const ACompare: TComparison<T>);
begin
  FCompare := ACompare;
end;

function TDelegatedComparer<T>.Compare(const Left, Right: T): Integer;
begin
  Result := FCompare(Left, Right);
end;

constructor TDelegatedEqualityComparer<T>.Create(const AEquals: TEqualityComparison<T>; const AGetHashCode:
  THasher<T>);
begin
  FEquals := AEquals;
  FGetHashCode := AGetHashCode;
end;

function TDelegatedEqualityComparer<T>.Equals(const Left, Right: T): Boolean;
begin
  Result := FEquals(Left, Right);
end;

function TDelegatedEqualityComparer<T>.GetHashCode(const Value: T): Integer;
begin
  Result := FGetHashCode(Value);
end;

{ TOrdinalStringComparer }

type
  TOrdinalStringComparer = class(TStringComparer)
  public
    function Compare(const Left, Right: string): Integer; override;
    function Equals(const Left, Right: string): Boolean;
    reintroduce; overload; override;
    function GetHashCode(const Value: string): Integer;
    reintroduce; overload; override;
  end;

function TOrdinalStringComparer.Compare(const Left, Right: string): Integer;
{$IFNDEF CPUINTELASM}
begin
  Result := InterfaceDefaults.Compare_UStr(nil, Pointer(Left), Pointer(Right));
end;
{$ELSE}
asm
  jmp InterfaceDefaults.Compare_UStr
end;
{$ENDIF}

function TOrdinalStringComparer.Equals(const Left, Right: string): Boolean;
{$IFNDEF CPUINTELASM}
begin
  Result := InterfaceDefaults.Equals_UStr(nil, Pointer(Left), Pointer(Right));
end;
{$ELSE}
asm
  jmp InterfaceDefaults.Equals_UStr
end;
{$ENDIF}

function TOrdinalStringComparer.GetHashCode(const Value: string): Integer;
{$IFNDEF CPUINTELASM}
begin
  Result := InterfaceDefaults.GetHashCode_UStr(nil, Pointer(Value));
end;
{$ELSE}
asm
  jmp InterfaceDefaults.GetHashCode_UStr
end;
{$ENDIF}

{ TStringComparer }

class destructor TStringComparer.Destroy;
begin
  FreeAndNil(FOrdinal);
end;

class function TStringComparer.Ordinal: TStringComparer;
begin
  if FOrdinal = nil then
    FOrdinal := TOrdinalStringComparer.Create;
  Result := TStringComparer(FOrdinal);
end;

{ TOrdinalIStringComparer }

function TOrdinalIStringComparer.Compare(const Left, Right: string): Integer;
begin
  Result := AnsiCompareText(Left, Right);
end;

function TOrdinalIStringComparer.Equals(const Left, Right: string): Boolean;
var
  Count: Integer;
begin
  if (NativeInt(Left) <> NativeInt(Right)) and (Pointer(Left) <> nil) and (Pointer(Right) <> nil) then
  begin
    Count := PInteger(NativeUInt(Left) - SizeOf(Integer))^;
    Result := (Count = PInteger(NativeUInt(Right) - SizeOf(Integer))^) and
      (0 = AnsiCompareText(Left, Right));
  end
  else
  begin
    Result := (NativeUInt(Left) = NativeUInt(Right));
  end;
end;

function TOrdinalIStringComparer.CharsLower(Dest, Src: PWideChar; Count: Integer): Boolean;
{$IF defined(MSWINDOWS)}
begin
  Move(Src^, Dest^, Count * SizeOf(WideChar));
  CharLowerBuff(Dest, Count);
  Result := True;
end;
{$ELSEIF defined(USE_LIBICU)}
var
  ErrorCode: UErrorCode;
begin
  ErrorCode := U_ZERO_ERROR;
  Result := (Count = u_strToLower(Dest, Count, Src, Count, UTF8CompareLocale, ErrorCode)) and
    (ErrorCode <= U_ZERO_ERROR);
end;
{$ELSEIF defined(MACOS)}
var
  MutableStringRef: CFMutableStringRef;
begin
  Move(Src^, Dest^, Count * SizeOf(WideChar));

  MutableStringRef := CFStringCreateMutableWithExternalCharactersNoCopy(kCFAllocatorDefault,
    Dest, Count, Count, kCFAllocatorNull);
  if (MutableStringRef <> nil) then
  begin
    try
      CFStringLowercase(MutableStringRef, UTF8CompareLocale);
      Result := (Count = CFStringGetLength(CFStringRef(MutableStringRef)));
    finally
      CFRelease(MutableStringRef);
    end;
  end
  else
  begin
    Result := False;
  end;
end;
{$ELSEIF Defined(POSIX)}
begin
  Result := False;
end;
{$IFEND POSIX}

function TOrdinalIStringComparer.GetHashCodeLower(const Value: string): Integer;
var
  S: string;
begin
  S := AnsiLowerCase(Value);
  Result := InterfaceDefaults.GetHashCode_UStr(nil, Pointer(S));
end;

function TOrdinalIStringComparer.GetHashCode(const Value: string): Integer;
var
  Count: Integer;
  Buffer: packed record
    _Padding: array[1..12] of Byte;
    Count: Integer;
    Chars: array[0..1024] of WideChar;
  end;
begin
  if (NativeInt(Value) <> 0) then
  begin
    Count := PInteger(NativeUInt(Value) - SizeOf(Integer))^;
    if (Count <= 1024) and (CharsLower(@Buffer.Chars[0], Pointer(Value), Count)) then
    begin
      Buffer.Count := Count;
      Buffer.Chars[Count] := #0;
      Result := InterfaceDefaults.GetHashCode_UStr(nil, Pointer(@Buffer.Chars[0]));
    end
    else
    begin
      Result := GetHashCodeLower(Value);
    end;
  end
  else
  begin
    Result := 0;
  end;
end;

{ TIStringComparer }

class destructor TIStringComparer.Destroy;
begin
  FreeAndNil(FOrdinal);
end;

class function TIStringComparer.Ordinal: TStringComparer;
begin
  if FOrdinal = nil then
    FOrdinal := TOrdinalIStringComparer.Create;
  Result := TStringComparer(FOrdinal);
end;

{ TEnumerator_ }

procedure TEnumerator_.Reset;
begin
  DoReset;
end;

procedure TEnumerator_.DoReset;
begin
  raise ENotSupportedException.CreateResFmt(Pointer(@SMethodNotSupported), ['Reset']);
end;

function TEnumerator_.MoveNext: Boolean;
begin
  Result := DoMoveNext;
end;

{ TEnumerator<T> }

function TEnumerator<T>.DoGetCurrentObject: TObject;
begin
  if (GetTypeKind(T) = tkClass) then
  begin
    T(Pointer(@Result)^) := DoGetCurrent;
  end
  else
  begin
    Result := nil;
  end;
end;

{ TEnumerable_ }

function TEnumerable_.GetObjectEnumerator: IEnumerator;
begin
  Result := DoGetObjectEnumerator;
end;

function TEnumerable_.GetEnumerator: TEnumerator_;
begin
  Result := DoGetObjectEnumerator;
end;

{ TEnumerable<T> }

// The overridden destructor that simply invokes 'inherited' is
// required to instantiate the destructor for C++ code
destructor TEnumerable<T>.Destroy;
begin
  inherited;
end;

function TEnumerable<T>.DoGetObjectEnumerator: TEnumerator_;
begin
  if (GetTypeKind(T) = tkClass) then
  begin
    Result := DoGetEnumerator;
  end
  else
  begin
    Result := nil;
  end;
end;

function TEnumerable<T>.GetEnumerator_: IEnumerator<T>;
begin
  Result := DoGetEnumerator;
end;

function TEnumerable<T>.GetEnumerator: TEnumerator<T>;
begin
  Result := DoGetEnumerator;
end;

function TEnumerable<T>.ToArray: TArray<T>;
var
  Count, Buffered: NativeUInt;
  Value: T;
begin
  Count := 0;
  Buffered := 16;
  Result := nil;
  SetLength(Result, Buffered);

  for Value in Self do
  begin
    if (Count = Buffered) then
    begin
      Buffered := Buffered * 2;
      SetLength(Result, Buffered);
    end;

    Result[Count] := Value;
    Inc(Count);
  end;

  SetLength(Result, Count);
end;

{ TPair<TKey,TValue> }

constructor TPair<TKey, TValue>.Create(const AKey: TKey; const AValue: TValue);
begin
  Key := AKey;
  Value := AValue;
end;

{ TArray }

{$IFDEF WEAKREF}
class procedure TArray.WeakExchange<T>(const Left, Right: Pointer);
var
  Buffer: T;
begin
  Buffer := T(Left^);
  T(Left^) := T(Right^);
  T(Right^) := Buffer;
end;
{$ENDIF}

class procedure TArray.Exchange<T>(const Left, Right: Pointer);
var
  Index: NativeInt;
  Temp1: Byte;
  Temp2: Word;
  Temp4: Cardinal;
  TempNative: NativeUInt;
begin
  {$IFDEF WEAKREF}
  if (TRAIIHelper<T>.Weak) then
  begin
    TArray.WeakExchange<T>(Left, Right);
  end
  else
    {$ENDIF}
    with TLMemory(Left^), TRMemory(Right^) do
      case SizeOf(T) of
        0: ;
        1:
          begin
            Temp1 := LBytes[0];
            LBytes[0] := RBytes[0];
            RBytes[0] := Temp1;
          end;
        2:
          begin
            Temp2 := LWords[0];
            LWords[0] := RWords[0];
            RWords[0] := Temp2;
          end;
        3:
          begin
            Temp2 := LWords[0];
            LWords[0] := RWords[0];
            RWords[0] := Temp2;

            Temp1 := LBytes[2];
            LBytes[2] := RBytes[2];
            RBytes[2] := Temp1;
          end;
        4..7:
          begin
            Temp4 := LCardinals[0];
            LCardinals[0] := RCardinals[0];
            RCardinals[0] := Temp4;

            case SizeOf(T) of
              5:
                begin
                  Temp1 := LBytes[4];
                  LBytes[4] := RBytes[4];
                  RBytes[4] := Temp1;
                end;
              6:
                begin
                  Temp2 := LWords[2];
                  LWords[2] := RWords[2];
                  RWords[2] := Temp2;
                end;
              7:
                begin
                  Temp2 := LWords[2];
                  LWords[2] := RWords[2];
                  RWords[2] := Temp2;
                  Temp1 := LBytes[6];
                  LBytes[6] := RBytes[6];
                  RBytes[6] := Temp1;
                end;
            end;
          end;
        8..16:
          begin
            TempNative := LNatives[0];
            LNatives[0] := RNatives[0];
            RNatives[0] := TempNative;

            if (SizeOf(T) >= SizeOf(NativeUInt) * 2) then
            begin
              TempNative := LNatives[1];
              LNatives[1] := RNatives[1];
              RNatives[1] := TempNative;
            end;

            if (SizeOf(T) >= SizeOf(NativeUInt) * 3) then
            begin
              TempNative := LNatives[2];
              LNatives[2] := RNatives[2];
              RNatives[2] := TempNative;
            end;

            if (SizeOf(T) = SizeOf(NativeUInt) * 4) then
            begin
              TempNative := LNatives[3];
              LNatives[3] := RNatives[3];
              RNatives[3] := TempNative;
            end;

            {$IFDEF LARGEINT}
            case SizeOf(T) of
              12, 13, 14, 15:
                begin
                  Temp4 := LCardinals[2];
                  LCardinals[2] := RCardinals[2];
                  RCardinals[2] := Temp4;
                end;
            end;
            {$ENDIF}

            case SizeOf(T) of
              9:
                begin
                  Temp1 := LBytes[8];
                  LBytes[8] := RBytes[8];
                  RBytes[8] := Temp1;
                end;
              10:
                begin
                  Temp2 := LWords[4];
                  LWords[4] := RWords[4];
                  RWords[4] := Temp2;
                end;
              11:
                begin
                  Temp2 := LWords[4];
                  LWords[4] := RWords[4];
                  RWords[4] := Temp2;
                  Temp1 := LBytes[10];
                  LBytes[10] := RBytes[10];
                  RBytes[10] := Temp1;
                end;
              13:
                begin
                  Temp2 := LWords[5];
                  LWords[5] := RWords[5];
                  RWords[5] := Temp2;
                  Temp1 := LBytes[12];
                  LBytes[12] := RBytes[12];
                  RBytes[12] := Temp1;
                end;
              14:
                begin
                  Temp2 := LWords[6];
                  LWords[6] := RWords[6];
                  RWords[6] := Temp2;
                end;
              15:
                begin
                  Temp2 := LWords[6];
                  LWords[6] := RWords[6];
                  RWords[6] := Temp2;
                  Temp1 := LBytes[14];
                  LBytes[14] := RBytes[14];
                  RBytes[14] := Temp1;
                end;
            end;
          end;
      else
        Index := 0;
        repeat
          TempNative := LNatives[Index];
          LNatives[Index] := RNatives[Index];
          RNatives[Index] := TempNative;
          Inc(Index);
        until (Index = SizeOf(T) div SizeOf(NativeUInt));

        if (SizeOf(T) and (SizeOf(NativeUInt) - 1) <> 0) then
        begin
          {$IFDEF LARGEINT}
          if (SizeOf(T) and 4 <> 0) then
          begin
            Index := SizeOf(T) div SizeOf(Cardinal) - 1;
            Temp4 := LCardinals[Index];
            LCardinals[Index] := RCardinals[Index];
            RCardinals[Index] := Temp4;
          end;
          {$ENDIF}

          if (SizeOf(T) and 2 <> 0) then
          begin
            Index := SizeOf(T) div SizeOf(Word) - 1;
            Temp2 := LWords[Index];
            LWords[Index] := RWords[Index];
            RWords[Index] := Temp2;
          end;

          if (SizeOf(T) and 1 <> 0) then
          begin
            Index := SizeOf(T) div SizeOf(Byte) - 1;
            Temp1 := LBytes[Index];
            LBytes[Index] := RBytes[Index];
            RBytes[Index] := Temp1;
          end;
        end;
      end;
end;

class procedure TArray.Copy<T>(const Destination, Source: Pointer);
var
  Index: NativeInt;
begin
  {$IFDEF WEAKREF}
  if (TRAIIHelper<T>.Weak) then
  begin
    T(Destination^) := T(Source^);
  end
  else
    {$ENDIF}
    with TLMemory(Destination^), TRMemory(Source^) do
      case SizeOf(T) of
        0: ;
        1: LBytes[0] := RBytes[0];
        2: LWords[0] := RWords[0];
        3:
          begin
            LWords[0] := RWords[0];
            LBytes[2] := RBytes[2];
          end;
        4..7:
          begin
            LCardinals[0] := RCardinals[0];

            case SizeOf(T) of
              5: LCardinals1[0] := RCardinals1[0];
              6: LCardinals2[0] := RCardinals2[0];
              7: LCardinals3[0] := RCardinals3[0];
            end;
          end;
        8..16:
          begin
            LNatives[0] := RNatives[0];

            if (SizeOf(T) >= SizeOf(NativeUInt) * 2) then
              LNatives[1] := RNatives[1];

            if (SizeOf(T) >= SizeOf(NativeUInt) * 3) then
              LNatives[2] := RNatives[2];

            if (SizeOf(T) = SizeOf(NativeUInt) * 4) then
              LNatives[3] := RNatives[3];

            {$IFDEF SMALLINT}
            case SizeOf(T) of
              9: LNatives1[1] := RNatives1[1];
              10: LNatives2[1] := RNatives2[1];
              11: LNatives3[1] := RNatives3[1];
              13: LNatives1[2] := RNatives1[2];
              14: LNatives2[2] := RNatives2[2];
              15: LNatives3[2] := RNatives3[2];
            end;
            {$ELSE .LARGEINT}
            case SizeOf(T) of
              9: LNatives1[1] := RNatives1[1];
              10: LNatives2[1] := RNatives2[1];
              11: LNatives3[1] := RNatives3[1];
              12: LNatives4[1] := RNatives4[1];
              13: LNatives5[1] := RNatives5[1];
              14: LNatives6[1] := RNatives6[1];
              15: LNatives7[1] := RNatives7[1];
            end;
            {$ENDIF}
          end;
      else
        Index := 0;
        repeat
          LNatives[Index] := RNatives[Index];
          Inc(Index);
        until (Index = SizeOf(T) div SizeOf(NativeUInt) - 1);

        if (SizeOf(T) and (SizeOf(NativeUInt) - 1) <> 0) then
        begin
          Index := SizeOf(T) div SizeOf(NativeUInt) - 1;
          case SizeOf(T) and (SizeOf(NativeUInt) - 1) of
            1: LNatives1[Index] := RNatives1[Index];
            2: LNatives2[Index] := RNatives2[Index];
            3: LNatives3[Index] := RNatives3[Index];
            {$IFDEF LARGEINT}
            4: LNatives4[Index] := RNatives4[Index];
            5: LNatives5[Index] := RNatives5[Index];
            6: LNatives6[Index] := RNatives6[Index];
            7: LNatives7[Index] := RNatives7[Index];
            {$ENDIF}
          end;
        end;
      end;
end;

class procedure TArray.FillZero<T>(const Values: Pointer);
var
  Null4: Cardinal;
  NullNative: NativeUInt;
  Index: NativeInt;
begin
  NullNative := 0;
  with TLMemory(Values^) do
    case SizeOf(T) of
      0: ;
      1: LBytes[0] := 0;
      2: LWords[0] := 0;
      3:
        begin
          LWords[0] := 0;
          LBytes[2] := 0;
        end;
      4..7:
        begin
          Null4 := 0;
          LCardinals[0] := Null4;

          case SizeOf(T) of
            5: LCardinals1[0] := Null4;
            6: LCardinals2[0] := Null4;
            7: LCardinals3[0] := Null4;
          end;
        end;
      8..16:
        begin
          LNatives[0] := NullNative;

          if (SizeOf(T) >= SizeOf(NativeUInt) * 2) then
            LNatives[1] := NullNative;

          if (SizeOf(T) >= SizeOf(NativeUInt) * 3) then
            LNatives[2] := NullNative;

          if (SizeOf(T) = SizeOf(NativeUInt) * 4) then
            LNatives[3] := NullNative;

          {$IFDEF SMALLINT}
          case SizeOf(T) of
            9: LNatives1[1] := NullNative;
            10: LNatives2[1] := NullNative;
            11: LNatives3[1] := NullNative;
            13: LNatives1[2] := NullNative;
            14: LNatives2[2] := NullNative;
            15: LNatives3[2] := NullNative;
          end;
          {$ELSE .LARGEINT}
          case SizeOf(T) of
            9: LNatives1[1] := NullNative;
            10: LNatives2[1] := NullNative;
            11: LNatives3[1] := NullNative;
            12: LNatives4[1] := NullNative;
            13: LNatives5[1] := NullNative;
            14: LNatives6[1] := NullNative;
            15: LNatives7[1] := NullNative;
          end;
          {$ENDIF}
        end;
    else
      Index := 0;
      repeat
        LNatives[Index] := NullNative;
        Inc(Index);
      until (Index = SizeOf(T) div SizeOf(NativeUInt) - 1);

      if (SizeOf(T) and (SizeOf(NativeUInt) - 1) <> 0) then
      begin
        Index := SizeOf(T) div SizeOf(NativeUInt) - 1;
        case SizeOf(T) and (SizeOf(NativeUInt) - 1) of
          1: LNatives1[Index] := NullNative;
          2: LNatives2[Index] := NullNative;
          3: LNatives3[Index] := NullNative;
          {$IFDEF LARGEINT}
          4: LNatives4[Index] := NullNative;
          5: LNatives5[Index] := NullNative;
          6: LNatives6[Index] := NullNative;
          7: LNatives7[Index] := NullNative;
          {$ENDIF}
        end;
      end;
    end;
end;

{$IFDEF WEAKREF}
class procedure TArray.WeakReverse<T>(const Values: Pointer; const Count: NativeInt);
var
  X, Y: ^T;
  Buffer: T;
begin
  if (Count > 1) then
  begin
    X := Values;
    Y := TRAIIHelper<T>.P(Values) + Count - 1;

    repeat
      Buffer := X^;
      X^ := Y^;
      Y^ := Buffer;

      Inc(X);
      Dec(Y);
    until (NativeUInt(X) >= NativeUInt(Y));
  end;
end;
{$ENDIF}

class procedure TArray.Reverse<T>(const Values: Pointer; const Count: NativeInt);
var
  X, Y: Pointer;
  Index: NativeInt;
  Temp1: Byte;
  Temp2: Word;
  TempNative: NativeUInt;
  {$IFDEF LARGEINT}
  Temp4: Cardinal;
  {$ENDIF}
begin
  {$IFDEF WEAKREF}
  if (TRAIIHelper<T>.Weak) then
  begin
    TArray.WeakReverse<T>(Values, Count);
  end
  else
    {$ENDIF}if (Count > 1) then
    begin
      X := Values;
      Y := TRAIIHelper<T>.P(Values) + Count - 1;

      repeat
        if (SizeOf(T) <= 16) then
        begin
          TArray.Exchange<T>(X, Y);
          Inc(NativeUInt(X), SizeOf(T));
          Dec(NativeUInt(Y), SizeOf(T));
        end
        else
        begin
          Index := 0;
          repeat
            Inc(Index);
            TempNative := PNativeUInt(X)^;
            PNativeUInt(X)^ := PNativeUInt(Y)^;
            PNativeUInt(Y)^ := TempNative;
            Inc(NativeUInt(X), SizeOf(NativeUInt));
            Inc(NativeUInt(Y), SizeOf(NativeUInt));
          until (Index = SizeOf(T) div SizeOf(NativeUInt));

          {$IFDEF LARGEINT}
          if (SizeOf(T) and 4 <> 0) then
          begin
            Temp4 := PCardinal(X)^;
            PCardinal(X)^ := PCardinal(Y)^;
            PCardinal(Y)^ := Temp4;
            Inc(NativeUInt(X), SizeOf(Cardinal));
            Inc(NativeUInt(Y), SizeOf(Cardinal));
          end;
          {$ENDIF}

          if (SizeOf(T) and 2 <> 0) then
          begin
            Temp2 := PWord(X)^;
            PWord(X)^ := PWord(Y)^;
            PWord(Y)^ := Temp2;
            Inc(NativeUInt(X), SizeOf(Word));
            Inc(NativeUInt(Y), SizeOf(Word));
          end;

          if (SizeOf(T) and 1 <> 0) then
          begin
            Temp1 := PByte(X)^;
            PByte(X)^ := PByte(Y)^;
            PByte(Y)^ := Temp1;
            Inc(NativeUInt(X), SizeOf(Byte));
            Inc(NativeUInt(Y), SizeOf(Byte));
          end;

          Dec(NativeUInt(Y), 2 * SizeOf(T));
        end;
      until (NativeUInt(X) >= NativeUInt(Y));
    end;
end;

class procedure TArray.Reverse<T>(var Values: array of T);
begin
  if (High(Values) > 0) then
    TArray.Reverse<T>(@Values[0], Length(Values));
end;

procedure TArray.TSortHelper<T>.Init(const Comparer: IComparer<T>);
begin
  Self.Inst := Pointer(Comparer);
  Self.Compare := PPointer(PNativeUInt(Self.Inst)^ + 3 * SizeOf(Pointer))^;
end;

procedure TArray.TSortHelper<T>.Init(const Comparison: TComparison<T>);
begin
  Self.Inst := PPointer(@Comparison)^;
  Self.Compare := PPointer(PNativeUInt(Self.Inst)^ + 3 * SizeOf(Pointer))^;
end;

procedure TArray.TSortHelper<T>.Init;
begin
  Self.Inst := Pointer(@InterfaceDefaults.TDefaultComparer<T>.Instance);
  Self.Compare := InterfaceDefaults.TDefaultComparer<T>.Instance.Compare;
end;

procedure TArray.TSortHelper<T>.FillZero;
begin
  FillChar(Self, SizeOf(T), #0);
end;

class procedure TArray.CheckArrays(Source, Destination: Pointer; SourceIndex, SourceLength, DestIndex, DestLength,
  Count: NativeInt);
begin
  if (NativeUInt(SourceIndex) >= NativeUInt(SourceLength)) then
    ErrorArgumentOutOfRange(SourceIndex, SourceLength);
  if (NativeUInt(DestIndex) >= NativeUInt(DestLength)) then
    ErrorArgumentOutOfRange(DestIndex, DestLength);
  if (SourceIndex + Count > SourceLength) then
    ErrorArgumentOutOfRange(SourceIndex + Count, SourceLength);
  if (DestIndex + Count > DestLength) then
    ErrorArgumentOutOfRange(DestIndex + Count, DestLength);
  if Source = Destination then
    raise EArgumentException.CreateRes(Pointer(@sSameArrays));
end;

class procedure TArray.Copy<T>(const Source: array of T; var Destination: array of T; SourceIndex, DestIndex, Count:
  NativeInt);
begin
  CheckArrays(Pointer(@Source[0]), Pointer(@Destination[0]), SourceIndex, Length(Source), DestIndex,
    Length(Destination), Count);
  if (Count <> 0) then
  begin
    if TRAIIHelper<T>.Managed then
      System.CopyArray(Pointer(@Destination[DestIndex]), Pointer(@Source[SourceIndex]), TypeInfo(T), Count)
    else
      System.Move(Pointer(@Source[SourceIndex])^, Pointer(@Destination[DestIndex])^, Count * SizeOf(T));
  end;
end;

class procedure TArray.Copy<T>(const Source: array of T; var Destination: array of T; Count: NativeInt);
begin
  Copy<T>(Source, Destination, 0, 0, Count);
end;

class function TArray.Copy<T>(const Source: array of T; SourceIndex, Count: NativeInt): TArray<T>;
begin
  if (Count < 0) or (SourceIndex + Count > Length(Source)) then
    ErrorArgumentOutOfRange;

  if (Count <> 0) then
  begin
    if TRAIIHelper<T>.Managed then
      System.CopyArray(Pointer(Result), Pointer(@Source[SourceIndex]), TypeInfo(T), Count)
    else
      System.Move(Pointer(@Source[SourceIndex])^, Pointer(@Result)^, Count * SizeOf(T));
  end;
end;

class function TArray.Copy<T>(const Source: array of T): TArray<T>;
var
  Count: NativeInt;
begin
  Count := Length(Source);
  SetLength(Result, Count);
  if (Count <> 0) then
  begin
    if TRAIIHelper<T>.Managed then
      System.CopyArray(Pointer(Result), Pointer(@Source[0]), TypeInfo(T), Count)
    else
      System.Move(Pointer(@Source[0])^, Pointer(@Result)^, Count * SizeOf(T));
  end;
end;

// AM TODO: Use a median of three in order to obtain the pivot
class function TArray.SortItemPivot<T>(const I, J: Pointer): Pointer;
var
  Index: NativeInt;
begin
  if (SizeOf(T) and (SizeOf(T) - 1) = 0) and (SizeOf(T) <= 256) then
  begin
    Index := NativeInt(J) - NativeInt(I);
    case SizeOf(T) of
      0, 1: Index := Index shr 1;
      2: Index := Index shr 2;
      4: Index := Index shr 3;
      8: Index := Index shr 4;
      16: Index := Index shr 5;
      32: Index := Index shr 6;
      64: Index := Index shr 7;
      128: Index := Index shr 8;
    else
    // 256:
      Index := Index shr 9;
    end;
  end
  else
  begin
    Index := NativeInt(Round((NativeInt(J) - NativeInt(I)) * (1 / SizeOf(T)))) shr 1;
  end;

  Result := TRAIIHelper<T>.P(I) + Index;
end;

class function TArray.MedianOfThree<T>(var A, B, C: T; Comparer: IComparer<T>): T;
begin
  if Comparer.Compare(A, B) < 0 then
  begin
    if Comparer.Compare(B, C) < 0 then
      Exit(B) // A < B < C
    else if Comparer.Compare(A, C) < 0 then
      Exit(C) // A < C < B
    else
      Exit(A);
  end
  else
  begin
    if Comparer.Compare(A, C) < 0 then
      Exit(A) // B < A < C
    else if Comparer.Compare(B, C) < 0 then
      Exit(C) // B < C < A
    else
      Exit(B);
  end;
end;

class function TArray.SortItemNext<T>(const StackItem, I, J: Pointer): Pointer;
var
  Item: ^TSortStackItem<T>;
  DiffI, DiffJ: NativeInt;
  Buf: Pointer;
begin
  Item := StackItem;

  // next "recursion" iteration
  // if (i < last) qs(s_arr, i, last);
  // if (first < j) qs(s_arr, first, j);
  DiffI := NativeInt(Item^.Last) - NativeInt(I);
  DiffJ := NativeInt(J) - NativeInt(Item^.First);
  if (DiffI > 0) then
  begin
    if (DiffJ <= 0) then
    begin
      Item^.First := I;
      // Item.Last := Item.Last;
    end
    else if (DiffI >= DiffJ) then
    begin
      // i..last, first..j
      Buf := Item^.First;
      Item^.First := I;
      Inc(Item);
      Item^.First := Buf;
      Item^.Last := J;
    end
    else
    begin
      // first..j, i..last
      Buf := Item^.Last;
      Item^.Last := J;
      Inc(Item);
      Item^.First := I;
      Item^.Last := Buf;
    end;
  end
  else if (DiffJ > 0) then
  begin
    // Item.First := Item.First;
    Item^.Last := J;
  end
  else
  begin
    Inc(NativeInt(Item), HIGH_NATIVE_BIT);
  end;

  Result := Item;
end;

class function TArray.SortItemCount<T>(const I, J: Pointer): NativeInt;
begin
  if (SizeOf(T) and (SizeOf(T) - 1) = 0) and (SizeOf(T) <= 256) then
  begin
    Result := NativeInt(J) + SizeOf(T) - NativeInt(I);
    case SizeOf(T) of
      2: Result := Result shr 1;
      4: Result := Result shr 2;
      8: Result := Result shr 3;
      16: Result := Result shr 4;
      32: Result := Result shr 5;
      64: Result := Result shr 6;
      128: Result := Result shr 7;
      256: Result := Result shr 8;
    end;
  end
  else
  begin
    Result := Round((NativeInt(J) + SizeOf(T) - NativeInt(I)) * (1 / SizeOf(T)));
  end;
end;

class function TArray.SortBinaryMarker<T>(const Binary: Pointer): NativeUInt;
begin
  case GetTypeKind(T) of
    tkMethod: Result := NativeUInt(TMethod(Binary^).Data);
    tkLString, tkWString, tkUString, tkDynArray:
      begin
        Result := PNativeUInt(Binary)^;
        if (Result <> 0) then
          case GetTypeKind(T) of
            tkLString:
              begin
                Result := PWord(Result)^;
                Result := Swap(Result);
              end;
            {$IFDEF MSWINDOWS}
            tkWString:
              begin
                Dec(Result, SizeOf(Integer));
                if (PInteger(Result)^ = 0) then
                begin
                  Result := 0;
                  Exit;
                end
                else
                begin
                  Inc(Result, SizeOf(Integer));
                  Result := PCardinal(Result)^;
                  Result := Cardinal((Result shl 16) + (Result shr 16));
                end;
              end;
            {$ELSE}
            tkWString,
              {$ENDIF}
            tkUString:
              begin
                Result := PCardinal(Result)^;
                Result := Cardinal((Result shl 16) + (Result shr 16));
              end;
            tkDynArray:
              begin
                Result := PByte(Result)^;
              end;
          end;
      end;
    tkString:
      begin
        Result := PWord(Binary)^;
        if (Result and $FF = 0) then
        begin
          Result := 0;
        end
        else
        begin
          Result := Result shr 8;
        end;
      end;
  else
    with TLMemory(Binary^) do
      case SizeOf(T) of
        1: Result := LBytes[0];
        2:
          begin
            Result := LWords[0];
            Result := Swap(Result);
          end;
        3:
          begin
            Result := LWords[0];
            Result := Swap(Result);
            Result := Result shl 8;
            Inc(Result, LBytes[2]);
          end;
      else
        Result := LCardinals[0];
        Result := (Swap(Result) shl 16) + Swap(Result shr 16);
      end;
  end;
end;

{$WARNINGS OFF} // compiler can't identify variable initialization in case statement

class procedure TArray.SortSigneds<T>(const Values: Pointer; const Count: NativeInt);
label
  proc_loop, proc_loop_current, swap_loop;
var
  Pivot4: Integer;
  {$IFDEF LARGEINT}
  Pivot8: Int64;
  {$ELSE .SMALLINT}
  Pivot8Low: Cardinal;
  Pivot8High, Buffer8High: Integer;
  Temp4: Cardinal;
  {$ENDIF}
  Temp: T;

  I, J: ^T;
  StackItem: ^TSortStackItem<T>;
  Stack: TSortStack<T>;
begin
  Stack[0].First := Values;
  Stack[0].Last := TRAIIHelper<T>.P(Values) + Count - 1;
  StackItem := Pointer(@Stack[1]);

  proc_loop:
  Dec(StackItem);
  proc_loop_current:
  I := StackItem^.First;
  J := StackItem^.Last;

  // pivot
  case SizeOf(T) of
    1: Pivot4 := PS1(SortItemPivot<T>(I, J))^;
    2: Pivot4 := PS2(SortItemPivot<T>(I, J))^;
    4: Pivot4 := PS4(SortItemPivot<T>(I, J))^;
  else
    {$IFDEF LARGEINT}
    Pivot8 := PS8(SortItemPivot<T>(I, J))^;
    {$ELSE .SMALLINT}
    with PPoint(I + ((NativeInt(J) - NativeInt(I)) shr 4))^ do
    begin
      Pivot8Low := X;
      Pivot8High := Y;
    end;
    {$ENDIF}
  end;

  // quick sort
  Dec(J);
  Dec(I);
  swap_loop:
  begin
    Inc(J, 2);

    repeat
      if I = StackItem^.Last then
        Break; // do not let it go beyond the end of the stack
      Inc(I);
      case SizeOf(T) of
        1: if (Pivot4 <= PS1(I)^) then
            Break;
        2: if (Pivot4 <= PS2(I)^) then
            Break;
        4: if (Pivot4 <= PS4(I)^) then
            Break;
      else
        {$IFDEF LARGEINT}
        if (Pivot8 <= PS8(I)^) then
          Break;
        {$ELSE .SMALLINT}
        Buffer8High := PPoint(I).Y;
        if (Pivot8High < Buffer8High) or
          ((Pivot8High = Buffer8High) and (Pivot8Low <= PCardinal(I)^)) then
          Break;
        {$ENDIF}
      end;
    until (False);

    repeat
      if J = StackItem^.First then
        Break; // do not let it go beyond the begin of the stack
      Dec(J);
      case SizeOf(T) of
        1: if (PS1(J)^ <= Pivot4) then
            Break;
        2: if (PS2(J)^ <= Pivot4) then
            Break;
        4: if (PS4(J)^ <= Pivot4) then
            Break;
      else
        {$IFDEF LARGEINT}
        if (PS8(J)^ <= Pivot8) then
          Break;
        {$ELSE .SMALLINT}
        Buffer8High := PPoint(J).Y;
        if (Buffer8High < Pivot8High) or
          ((Buffer8High = Pivot8High) and (PCardinal(J)^ <= Pivot8Low)) then
          Break;
        {$ENDIF}
      end;
    until (False);

    if (I <= J) then
    begin
      {$IFDEF SMALLINT}
      if (SizeOf(T) = 8) then
      begin
        Temp4 := TLMemory(Pointer(I)^).LCardinals[0];
        TLMemory(Pointer(I)^).LCardinals[0] := TLMemory(Pointer(J)^).LCardinals[0];
        TLMemory(Pointer(J)^).LCardinals[0] := Temp4;
        Temp4 := TLMemory(Pointer(I)^).LCardinals[1];
        TLMemory(Pointer(I)^).LCardinals[1] := TLMemory(Pointer(J)^).LCardinals[1];
        TLMemory(Pointer(J)^).LCardinals[1] := Temp4;
      end
      else
        {$ENDIF}
      begin
        Temp := I^;
        I^ := J^;
        J^ := Temp;
      end;

      Dec(J, 2);
      if (I <= J) then
        goto swap_loop;
      Inc(I);
      Inc(J);
    end;
  end;

  // next iteration
  StackItem := SortItemNext<T>(StackItem, I, J);
  if (NativeInt(StackItem) >= 0) then
    goto proc_loop_current;
  Dec(NativeInt(StackItem), HIGH_NATIVE_BIT);
  if (StackItem <> Pointer(@Stack[0])) then
    goto proc_loop;
end;
{$WARNINGS ON}

{$WARNINGS OFF} // compiler can't identify variable initialization in case statement

class procedure TArray.SortDescendingSigneds<T>(const Values: Pointer; const Count: NativeInt);
label
  proc_loop, proc_loop_current, swap_loop;
var
  Pivot4: Integer;
  {$IFDEF LARGEINT}
  Pivot8: Int64;
  {$ELSE .SMALLINT}
  Pivot8Low: Cardinal;
  Pivot8High, Buffer8High: Integer;
  Temp4: Cardinal;
  {$ENDIF}
  Temp: T;

  I, J: ^T;
  StackItem: ^TSortStackItem<T>;
  Stack: TSortStack<T>;
begin
  Stack[0].First := Values;
  Stack[0].Last := TRAIIHelper<T>.P(Values) + Count - 1;
  StackItem := Pointer(@Stack[1]);

  proc_loop:
  Dec(StackItem);
  proc_loop_current:
  I := StackItem^.First;
  J := StackItem^.Last;

  // pivot
  case SizeOf(T) of
    1: Pivot4 := PS1(SortItemPivot<T>(I, J))^;
    2: Pivot4 := PS2(SortItemPivot<T>(I, J))^;
    4: Pivot4 := PS4(SortItemPivot<T>(I, J))^;
  else
    {$IFDEF LARGEINT}
    Pivot8 := PS8(SortItemPivot<T>(I, J))^;
    {$ELSE .SMALLINT}
    with PPoint(I + ((NativeInt(J) - NativeInt(I)) shr 4))^ do
    begin
      Pivot8Low := X;
      Pivot8High := Y;
    end;
    {$ENDIF}
  end;

  // quick sort
  Dec(J);
  Dec(I);
  swap_loop:
  begin
    Inc(J, 2);

    repeat
      if I = StackItem^.Last then
        Break; // do not let it go beyond the end of the stack
      Inc(I);
      case SizeOf(T) of
        1: if (Pivot4 >= PS1(I)^) then
            Break;
        2: if (Pivot4 >= PS2(I)^) then
            Break;
        4: if (Pivot4 >= PS4(I)^) then
            Break;
      else
        {$IFDEF LARGEINT}
        if (Pivot8 >= PS8(I)^) then
          Break;
        {$ELSE .SMALLINT}
        Buffer8High := PPoint(I).Y;
        if (Pivot8High > Buffer8High) or
          ((Pivot8High = Buffer8High) and (Pivot8Low >= PCardinal(I)^)) then
          Break;
        {$ENDIF}
      end;
    until (False);

    repeat
      if J = StackItem^.First then
        Break; // do not let it go beyond the end of the stack
      Dec(J);
      case SizeOf(T) of
        1: if (PS1(J)^ >= Pivot4) then
            Break;
        2: if (PS2(J)^ >= Pivot4) then
            Break;
        4: if (PS4(J)^ >= Pivot4) then
            Break;
      else
        {$IFDEF LARGEINT}
        if (PS8(J)^ >= Pivot8) then
          Break;
        {$ELSE .SMALLINT}
        Buffer8High := PPoint(J).Y;
        if (Buffer8High > Pivot8High) or
          ((Buffer8High = Pivot8High) and (PCardinal(J)^ >= Pivot8Low)) then
          Break;
        {$ENDIF}
      end;
    until (False);

    if (I <= J) then
    begin
      {$IFDEF SMALLINT}
      if (SizeOf(T) = 8) then
      begin
        Temp4 := TLMemory(Pointer(I)^).LCardinals[0];
        TLMemory(Pointer(I)^).LCardinals[0] := TLMemory(Pointer(J)^).LCardinals[0];
        TLMemory(Pointer(J)^).LCardinals[0] := Temp4;
        Temp4 := TLMemory(Pointer(I)^).LCardinals[1];
        TLMemory(Pointer(I)^).LCardinals[1] := TLMemory(Pointer(J)^).LCardinals[1];
        TLMemory(Pointer(J)^).LCardinals[1] := Temp4;
      end
      else
        {$ENDIF}
      begin
        Temp := I^;
        I^ := J^;
        J^ := Temp;
      end;

      Dec(J, 2);
      if (I <= J) then
        goto swap_loop;
      Inc(I);
      Inc(J);
    end;
  end;

  // next iteration
  StackItem := SortItemNext<T>(StackItem, I, J);
  if (NativeInt(StackItem) >= 0) then
    goto proc_loop_current;
  Dec(NativeInt(StackItem), HIGH_NATIVE_BIT);
  if (StackItem <> Pointer(@Stack[0])) then
    goto proc_loop;
end;
{$WARNINGS ON}

{$WARNINGS OFF} // compiler can't identify variable initialization in case statement

class procedure TArray.SortUnsigneds<T>(const Values: Pointer; const Count: NativeInt);
label
  proc_loop, proc_loop_current, swap_loop;
var
  Pivot4: Cardinal;
  {$IFDEF LARGEINT}
  Pivot8: UInt64;
  {$ELSE .SMALLINT}
  Pivot8Low: Cardinal;
  Pivot8High, Buffer8High: Cardinal;
  Temp4: Cardinal;
  {$ENDIF}
  Temp: T;

  I, J: ^T;
  StackItem: ^TSortStackItem<T>;
  Stack: TSortStack<T>;
begin
  Stack[0].First := Values;
  Stack[0].Last := TRAIIHelper<T>.P(Values) + Count - 1;
  StackItem := Pointer(@Stack[1]);

  proc_loop:
  Dec(StackItem);
  proc_loop_current:
  I := StackItem^.First;
  J := StackItem^.Last;

  // pivot
  case SizeOf(T) of
    1: Pivot4 := PU1(SortItemPivot<T>(I, J))^;
    2: Pivot4 := PU2(SortItemPivot<T>(I, J))^;
    4: Pivot4 := PU4(SortItemPivot<T>(I, J))^;
  else
    {$IFDEF LARGEINT}
    Pivot8 := PU8(SortItemPivot<T>(I, J))^;
    {$ELSE .SMALLINT}
    with PPoint(I + ((NativeInt(J) - NativeInt(I)) shr 4))^ do
    begin
      Pivot8Low := X;
      Pivot8High := Y;
    end;
    {$ENDIF}
  end;

  // quick sort
  Dec(J);
  Dec(I);
  swap_loop:
  begin
    Inc(J, 2);

    repeat
      if I = StackItem^.Last then
        Break; // do not let it go beyond the end of the stack
      Inc(I);
      case SizeOf(T) of
        1: if (Pivot4 <= PU1(I)^) then
            Break;
        2: if (Pivot4 <= PU2(I)^) then
            Break;
        4: if (Pivot4 <= PU4(I)^) then
            Break;
      else
        {$IFDEF LARGEINT}
        if (Pivot8 <= PU8(I)^) then
          Break;
        {$ELSE .SMALLINT}
        Buffer8High := PPoint(I).Y;
        if (Pivot8High < Buffer8High) or
          ((Pivot8High = Buffer8High) and (Pivot8Low <= PCardinal(I)^)) then
          Break;
        {$ENDIF}
      end;
    until (False);

    repeat
      if J = StackItem^.First then
        Break; // do not let it go beyond the begin of the stack
      Dec(J);
      case SizeOf(T) of
        1: if (PU1(J)^ <= Pivot4) then
            Break;
        2: if (PU2(J)^ <= Pivot4) then
            Break;
        4: if (PU4(J)^ <= Pivot4) then
            Break;
      else
        {$IFDEF LARGEINT}
        if (PU8(J)^ <= Pivot8) then
          Break;
        {$ELSE .SMALLINT}
        Buffer8High := PPoint(J).Y;
        if (Buffer8High < Pivot8High) or
          ((Buffer8High = Pivot8High) and (PCardinal(J)^ <= Pivot8Low)) then
          Break;
        {$ENDIF}
      end;
    until (False);

    if (I <= J) then
    begin
      {$IFDEF SMALLINT}
      if (SizeOf(T) = 8) then
      begin
        Temp4 := TLMemory(Pointer(I)^).LCardinals[0];
        TLMemory(Pointer(I)^).LCardinals[0] := TLMemory(Pointer(J)^).LCardinals[0];
        TLMemory(Pointer(J)^).LCardinals[0] := Temp4;
        Temp4 := TLMemory(Pointer(I)^).LCardinals[1];
        TLMemory(Pointer(I)^).LCardinals[1] := TLMemory(Pointer(J)^).LCardinals[1];
        TLMemory(Pointer(J)^).LCardinals[1] := Temp4;
      end
      else
        {$ENDIF}
      begin
        Temp := I^;
        I^ := J^;
        J^ := Temp;
      end;

      Dec(J, 2);
      if (I <= J) then
        goto swap_loop;
      Inc(I);
      Inc(J);
    end;
  end;

  // next iteration
  StackItem := SortItemNext<T>(StackItem, I, J);
  if (NativeInt(StackItem) >= 0) then
    goto proc_loop_current;
  Dec(NativeInt(StackItem), HIGH_NATIVE_BIT);
  if (StackItem <> Pointer(@Stack[0])) then
    goto proc_loop;
end;
{$WARNINGS ON}

{$WARNINGS OFF} // compiler can't identify variable initialization in case statement

class procedure TArray.SortDescendingUnsigneds<T>(const Values: Pointer; const Count: NativeInt);
label
  proc_loop, proc_loop_current, swap_loop;
var
  Pivot4: Cardinal;
  {$IFDEF LARGEINT}
  Pivot8: UInt64;
  {$ELSE .SMALLINT}
  Pivot8Low: Cardinal;
  Pivot8High, Buffer8High: Cardinal;
  Temp4: Cardinal;
  {$ENDIF}
  Temp: T;

  I, J: ^T;
  StackItem: ^TSortStackItem<T>;
  Stack: TSortStack<T>;
begin
  Stack[0].First := Values;
  Stack[0].Last := TRAIIHelper<T>.P(Values) + Count - 1;
  StackItem := Pointer(@Stack[1]);

  proc_loop:
  Dec(StackItem);
  proc_loop_current:
  I := StackItem^.First;
  J := StackItem^.Last;

  // pivot
  case SizeOf(T) of
    1: Pivot4 := PU1(SortItemPivot<T>(I, J))^;
    2: Pivot4 := PU2(SortItemPivot<T>(I, J))^;
    4: Pivot4 := PU4(SortItemPivot<T>(I, J))^;
  else
    {$IFDEF LARGEINT}
    Pivot8 := PU8(SortItemPivot<T>(I, J))^;
    {$ELSE .SMALLINT}
    with PPoint(I + ((NativeInt(J) - NativeInt(I)) shr 4))^ do
    begin
      Pivot8Low := X;
      Pivot8High := Y;
    end;
    {$ENDIF}
  end;

  // quick sort
  Dec(J);
  Dec(I);
  swap_loop:
  begin
    Inc(J, 2);

    repeat
      if I = StackItem^.Last then
        Break; // do not let it go beyond the end of the stack
      Inc(I);
      case SizeOf(T) of
        1: if (Pivot4 >= PU1(I)^) then
            Break;
        2: if (Pivot4 >= PU2(I)^) then
            Break;
        4: if (Pivot4 >= PU4(I)^) then
            Break;
      else
        {$IFDEF LARGEINT}
        if (Pivot8 >= PU8(I)^) then
          Break;
        {$ELSE .SMALLINT}
        Buffer8High := PPoint(I).Y;
        if (Pivot8High > Buffer8High) or
          ((Pivot8High = Buffer8High) and (Pivot8Low >= PCardinal(I)^)) then
          Break;
        {$ENDIF}
      end;
    until (False);

    repeat
      if J = StackItem^.First then
        Break; // do not let it go beyond the begin of the stack
      Dec(J);
      case SizeOf(T) of
        1: if (PU1(J)^ >= Pivot4) then
            Break;
        2: if (PU2(J)^ >= Pivot4) then
            Break;
        4: if (PU4(J)^ >= Pivot4) then
            Break;
      else
        {$IFDEF LARGEINT}
        if (PU8(J)^ >= Pivot8) then
          Break;
        {$ELSE .SMALLINT}
        Buffer8High := PPoint(J).Y;
        if (Buffer8High > Pivot8High) or
          ((Buffer8High = Pivot8High) and (PCardinal(J)^ >= Pivot8Low)) then
          Break;
        {$ENDIF}
      end;
    until (False);

    if (I <= J) then
    begin
      {$IFDEF SMALLINT}
      if (SizeOf(T) = 8) then
      begin
        Temp4 := TLMemory(Pointer(I)^).LCardinals[0];
        TLMemory(Pointer(I)^).LCardinals[0] := TLMemory(Pointer(J)^).LCardinals[0];
        TLMemory(Pointer(J)^).LCardinals[0] := Temp4;
        Temp4 := TLMemory(Pointer(I)^).LCardinals[1];
        TLMemory(Pointer(I)^).LCardinals[1] := TLMemory(Pointer(J)^).LCardinals[1];
        TLMemory(Pointer(J)^).LCardinals[1] := Temp4;
      end
      else
        {$ENDIF}
      begin
        Temp := I^;
        I^ := J^;
        J^ := Temp;
      end;

      Dec(J, 2);
      if (I <= J) then
        goto swap_loop;
      Inc(I);
      Inc(J);
    end;
  end;

  // next iteration
  StackItem := SortItemNext<T>(StackItem, I, J);
  if (NativeInt(StackItem) >= 0) then
    goto proc_loop_current;
  Dec(NativeInt(StackItem), HIGH_NATIVE_BIT);
  if (StackItem <> Pointer(@Stack[0])) then
    goto proc_loop;
end;
{$WARNINGS ON}

{$WARNINGS OFF} // compiler can't identify variable initialization in case statement

class procedure TArray.SortFloats<T>(const Values: Pointer; const Count: NativeInt);
label
  proc_loop, proc_loop_current, swap_loop;
var
  Pivot4: Single;
  Pivot8: Double;
  PivotE: Extended;
  TempNative: NativeUInt;

  I, J: ^T;
  StackItem: ^TSortStackItem<T>;
  Stack: TSortStack<T>;
begin
  Stack[0].First := Values;
  Stack[0].Last := TRAIIHelper<T>.P(Values) + Count - 1;
  StackItem := Pointer(@Stack[1]);

  proc_loop:
  Dec(StackItem);
  proc_loop_current:
  I := StackItem^.First;
  J := StackItem^.Last;

  // pivot
  case SizeOf(T) of
    4: Pivot4 := PF4(SortItemPivot<T>(I, J))^;
    8: Pivot8 := PF8(SortItemPivot<T>(I, J))^;
  else
    PivotE := PFE(SortItemPivot<T>(I, J))^;
  end;

  // quick sort
  Dec(J);
  Dec(I);
  swap_loop:
  begin
    Inc(J, 2);

    repeat
      if I = StackItem^.Last then
        Break; // do not let it go beyond the end of the stack
      Inc(I);
      case SizeOf(T) of
        4: if (Pivot4 <= PF4(I)^) then
            Break;
        8: if (Pivot8 <= PF8(I)^) then
            Break;
      else
        if (PivotE <= PFE(I)^) then
          Break;
      end;
    until (False);

    repeat
      if J = StackItem^.First then
        Break; // do not let it go beyond the begin of the stack
      Dec(J);
      case SizeOf(T) of
        4: if (PF4(J)^ <= Pivot4) then
            Break;
        8: if (PF8(J)^ <= Pivot8) then
            Break;
      else
        if (PFE(J)^ <= PivotE) then
          Break;
      end;
    until (False);

    if (I <= J) then
    begin
      if (SizeOf(T) = 4) then
      begin
        TempNative := TLMemory(Pointer(I)^).LCardinals[0];
        TLMemory(Pointer(I)^).LCardinals[0] := TLMemory(Pointer(J)^).LCardinals[0];
        TLMemory(Pointer(J)^).LCardinals[0] := TempNative;
      end
      else
      begin
        TempNative := TLMemory(Pointer(I)^).LNatives[0];
        TLMemory(Pointer(I)^).LNatives[0] := TLMemory(Pointer(J)^).LNatives[0];
        TLMemory(Pointer(J)^).LNatives[0] := TempNative;

        if (SizeOf(T) >= 2 * SizeOf(NativeUInt)) then
        begin
          TempNative := TLMemory(Pointer(I)^).LNatives[1];
          TLMemory(Pointer(I)^).LNatives[1] := TLMemory(Pointer(J)^).LNatives[1];
          TLMemory(Pointer(J)^).LNatives[1] := TempNative;
        end;

        if (SizeOf(T) = 10) then
        begin
          TempNative := TLMemory(Pointer(I)^).LWords[4];
          TLMemory(Pointer(I)^).LWords[4] := TLMemory(Pointer(J)^).LWords[4];
          TLMemory(Pointer(J)^).LWords[4] := TempNative;
        end;
      end;

      Dec(J, 2);
      if (I <= J) then
        goto swap_loop;
      Inc(I);
      Inc(J);
    end;
  end;

  // next iteration
  StackItem := SortItemNext<T>(StackItem, I, J);
  if (NativeInt(StackItem) >= 0) then
    goto proc_loop_current;
  Dec(NativeInt(StackItem), HIGH_NATIVE_BIT);
  if (StackItem <> Pointer(@Stack[0])) then
    goto proc_loop;
end;
{$WARNINGS ON}

{$WARNINGS OFF} // compiler can't identify variable initialization in case statement

class procedure TArray.SortDescendingFloats<T>(const Values: Pointer; const Count: NativeInt);
label
  proc_loop, proc_loop_current, swap_loop;
var
  Pivot4: Single;
  Pivot8: Double;
  PivotE: Extended;
  TempNative: NativeUInt;

  I, J: ^T;
  StackItem: ^TSortStackItem<T>;
  Stack: TSortStack<T>;
begin
  Stack[0].First := Values;
  Stack[0].Last := TRAIIHelper<T>.P(Values) + Count - 1;
  StackItem := Pointer(@Stack[1]);

  proc_loop:
  Dec(StackItem);
  proc_loop_current:
  I := StackItem^.First;
  J := StackItem^.Last;

  // pivot
  case SizeOf(T) of
    4: Pivot4 := PF4(SortItemPivot<T>(I, J))^;
    8: Pivot8 := PF8(SortItemPivot<T>(I, J))^;
  else
    PivotE := PFE(SortItemPivot<T>(I, J))^;
  end;

  // quick sort
  Dec(J);
  Dec(I);
  swap_loop:
  begin
    Inc(J, 2);

    repeat
      if I = StackItem^.Last then
        Break; // do not let it go beyond the end of the stack
      Inc(I);
      case SizeOf(T) of
        4: if (Pivot4 >= PF4(I)^) then
            Break;
        8: if (Pivot8 >= PF8(I)^) then
            Break;
      else
        if (PivotE >= PFE(I)^) then
          Break;
      end;
    until (False);

    repeat
      if J = StackItem^.First then
        Break; // do not let it go beyond the begin of the stack
      Dec(J);
      case SizeOf(T) of
        4: if (PF4(J)^ >= Pivot4) then
            Break;
        8: if (PF8(J)^ >= Pivot8) then
            Break;
      else
        if (PFE(J)^ >= PivotE) then
          Break;
      end;
    until (False);

    if (I <= J) then
    begin
      if (SizeOf(T) = 4) then
      begin
        TempNative := TLMemory(Pointer(I)^).LCardinals[0];
        TLMemory(Pointer(I)^).LCardinals[0] := TLMemory(Pointer(J)^).LCardinals[0];
        TLMemory(Pointer(J)^).LCardinals[0] := TempNative;
      end
      else
      begin
        TempNative := TLMemory(Pointer(I)^).LNatives[0];
        TLMemory(Pointer(I)^).LNatives[0] := TLMemory(Pointer(J)^).LNatives[0];
        TLMemory(Pointer(J)^).LNatives[0] := TempNative;

        if (SizeOf(T) >= 2 * SizeOf(NativeUInt)) then
        begin
          TempNative := TLMemory(Pointer(I)^).LNatives[1];
          TLMemory(Pointer(I)^).LNatives[1] := TLMemory(Pointer(J)^).LNatives[1];
          TLMemory(Pointer(J)^).LNatives[1] := TempNative;
        end;

        if (SizeOf(T) = 10) then
        begin
          TempNative := TLMemory(Pointer(I)^).LWords[4];
          TLMemory(Pointer(I)^).LWords[4] := TLMemory(Pointer(J)^).LWords[4];
          TLMemory(Pointer(J)^).LWords[4] := TempNative;
        end;
      end;

      Dec(J, 2);
      if (I <= J) then
        goto swap_loop;
      Inc(I);
      Inc(J);
    end;
  end;

  // next iteration
  StackItem := SortItemNext<T>(StackItem, I, J);
  if (NativeInt(StackItem) >= 0) then
    goto proc_loop_current;
  Dec(NativeInt(StackItem), HIGH_NATIVE_BIT);
  if (StackItem <> Pointer(@Stack[0])) then
    goto proc_loop;
end;
{$WARNINGS ON}

class procedure TArray.SortBinaries<T>(const Values: Pointer; const Count: NativeInt; var PivotBig: T);
label
  proc_loop, proc_loop_current, swap_loop;
var
  Index: NativeInt;
  Temp1: Byte;
  Temp2: Word;
  Temp4: Cardinal;
  TempNative: NativeUInt;

  I, J: ^T;
  Pivot: TSortPivot;
  X, Y: NativeUInt;
  Buffer: Pointer;
  StackItem: ^TSortStackItem<T>;
  Stack: TSortStack<T>;
begin
  Stack[0].First := Values;
  Stack[0].Last := TRAIIHelper<T>.P(Values) + Count - 1;
  StackItem := Pointer(@Stack[1]);

  proc_loop:
  Dec(StackItem);
  proc_loop_current:
  I := StackItem^.First;
  J := StackItem^.Last;

  // pivot
  if (SizeOf(T) <= SizeOf(Pivot)) then
  begin
    if (SizeOf(T) = SizeOf(Pointer)) then
    begin
      Pivot.Ptr := Pointer(SortItemPivot<T>(I, J)^);
    end
    else
    begin
      TArray.Copy<T>(@Pivot, SortItemPivot<T>(I, J));
    end;
    X := TArray.SortBinaryMarker<T>(@Pivot);
  end
  else
  begin
    TArray.Copy<T>(@PivotBig, SortItemPivot<T>(I, J));
    X := TArray.SortBinaryMarker<T>(@PivotBig);
  end;

  // quick sort
  Dec(J);
  Dec(I);
  swap_loop:
  begin
    Inc(J, 2);

    repeat
      if I = StackItem^.Last then
        Break; // do not let it go beyond the end of the stack
      Inc(I);

      Y := TArray.SortBinaryMarker<T>(I);
      if (X < Y) then
        Break;
      if (X = Y) then
      begin
        if (SizeOf(T) <= SizeOf(Pivot)) then
        begin
          // compare pivot/I
          if (GetTypeKind(T) = tkMethod) then
          begin
            if (NativeUInt(Pivot.Ptr) <= NativeUInt(Pointer(I)^)) then
              Break;
          end
          else if (GetTypeKind(T) = tkString) then
          begin
            if (InterfaceDefaults.Compare_OStr(nil, Pointer(@Pivot), Pointer(I)) <= 0) then
              Break;
          end
          else if (GetTypeKind(T) in [tkLString, tkWString, tkUString, tkDynArray]) then
          begin
            Buffer := Pointer(Pointer(I)^);
            if (Pivot.Ptr = Buffer) then
              Break;
            case GetTypeKind(T) of
              tkLString: if (InterfaceDefaults.Compare_LStr(nil, Pivot.Ptr, Buffer) <= 0) then
                  Break;
              {$IFDEF MSWINDOWS}
              tkWString: if (InterfaceDefaults.Compare_WStr(nil, Pivot.Ptr, Buffer) <= 0) then
                  Break;
              {$ELSE}
              tkWString,
                {$ENDIF}
              tkUString: if (InterfaceDefaults.Compare_UStr(nil, Pivot.Ptr, Buffer) <= 0) then
                  Break;
              tkDynArray: if (InterfaceDefaults.Compare_Dyn(InterfaceDefaults.TDefaultComparer<T>.Instance, Pivot.Ptr,
                Buffer) <= 0) then
                  Break;
            end;
          end
          else
            case SizeOf(T) of
              0..SizeOf(Cardinal): Break;
              {$IFDEF LARGEINT}
              SizeOf(Int64): if (InterfaceDefaults.Compare_Bin8(nil, PInt64(@Pivot)^, PInt64(I)^) <= 0) then
                  Break;
              {$ENDIF}
            else
              if (InterfaceDefaults.Compare_Bin(InterfaceDefaults.TDefaultComparer<T>.Instance,
                Pointer(@Pivot), Pointer(I)) <= 0) then
                Break;
            end;
        end
        else
        begin
          if (InterfaceDefaults.Compare_Bin(InterfaceDefaults.TDefaultComparer<T>.Instance,
            Pointer(@PivotBig), Pointer(I)) <= 0) then
            Break;
        end;
      end;
    until (False);

    repeat
      if J = StackItem^.First then
        Break; // do not let it go beyond the begin of the stack
      Dec(J);

      Y := TArray.SortBinaryMarker<T>(J);
      if (Y < X) then
        Break;
      if (Y = X) then
      begin
        if (SizeOf(T) <= SizeOf(Pivot)) then
        begin
          // compare J/pivot
          if (GetTypeKind(T) = tkMethod) then
          begin
            if (NativeUInt(Pointer(J)^) <= NativeUInt(Pivot.Ptr)) then
              Break;
          end
          else if (GetTypeKind(T) = tkString) then
          begin
            if (InterfaceDefaults.Compare_OStr(nil, Pointer(J), Pointer(@Pivot)) <= 0) then
              Break;
          end
          else if (GetTypeKind(T) in [tkLString, tkWString, tkUString, tkDynArray]) then
          begin
            Buffer := Pointer(Pointer(J)^);
            if (Buffer = Pivot.Ptr) then
              Break;
            case GetTypeKind(T) of
              tkLString: if (InterfaceDefaults.Compare_LStr(nil, Buffer, Pivot.Ptr) <= 0) then
                  Break;
              {$IFDEF MSWINDOWS}
              tkWString: if (InterfaceDefaults.Compare_WStr(nil, Buffer, Pivot.Ptr) <= 0) then
                  Break;
              {$ELSE}
              tkWString,
                {$ENDIF}
              tkUString: if (InterfaceDefaults.Compare_UStr(nil, Buffer, Pivot.Ptr) <= 0) then
                  Break;
              tkDynArray: if (InterfaceDefaults.Compare_Dyn(InterfaceDefaults.TDefaultComparer<T>.Instance, Buffer,
                Pivot.Ptr) <= 0) then
                  Break;
            end;
          end
          else
            case SizeOf(T) of
              0..SizeOf(Cardinal): Break;
              {$IFDEF LARGEINT}
              SizeOf(Int64): if (InterfaceDefaults.Compare_Bin8(nil, PInt64(J)^, PInt64(@Pivot)^) <= 0) then
                  Break;
              {$ENDIF}
            else
              if (InterfaceDefaults.Compare_Bin(InterfaceDefaults.TDefaultComparer<T>.Instance,
                Pointer(J), Pointer(@Pivot)) <= 0) then
                Break;
            end;
        end
        else
        begin
          if (InterfaceDefaults.Compare_Bin(InterfaceDefaults.TDefaultComparer<T>.Instance,
            Pointer(J), Pointer(@PivotBig)) <= 0) then
            Break;
        end;
      end;
    until (False);

    if (I <= J) then
    begin
      // TArray.Exchange<T>(I, J);
      case SizeOf(T) of
        0: ;
        1:
          begin
            Temp1 := PLMemory(I).LBytes[0];
            PLMemory(I).LBytes[0] := PRMemory(J).RBytes[0];
            PRMemory(J).RBytes[0] := Temp1;
          end;
        2:
          begin
            Temp2 := PLMemory(I).LWords[0];
            PLMemory(I).LWords[0] := PRMemory(J).RWords[0];
            PRMemory(J).RWords[0] := Temp2;
          end;
        3:
          begin
            Temp2 := PLMemory(I).LWords[0];
            PLMemory(I).LWords[0] := PRMemory(J).RWords[0];
            PRMemory(J).RWords[0] := Temp2;

            Temp1 := PLMemory(I).LBytes[2];
            PLMemory(I).LBytes[2] := PRMemory(J).RBytes[2];
            PRMemory(J).RBytes[2] := Temp1;
          end;
        4..7:
          begin
            Temp4 := PLMemory(I).LCardinals[0];
            PLMemory(I).LCardinals[0] := PRMemory(J).RCardinals[0];
            PRMemory(J).RCardinals[0] := Temp4;

            case SizeOf(T) of
              5:
                begin
                  Temp1 := PLMemory(I).LBytes[4];
                  PLMemory(I).LBytes[4] := PRMemory(J).RBytes[4];
                  PRMemory(J).RBytes[4] := Temp1;
                end;
              6:
                begin
                  Temp2 := PLMemory(I).LWords[2];
                  PLMemory(I).LWords[2] := PRMemory(J).RWords[2];
                  PRMemory(J).RWords[2] := Temp2;
                end;
              7:
                begin
                  Temp2 := PLMemory(I).LWords[2];
                  PLMemory(I).LWords[2] := PRMemory(J).RWords[2];
                  PRMemory(J).RWords[2] := Temp2;
                  Temp1 := PLMemory(I).LBytes[6];
                  PLMemory(I).LBytes[6] := PRMemory(J).RBytes[6];
                  PRMemory(J).RBytes[6] := Temp1;
                end;
            end;
          end;
        8..16:
          begin
            TempNative := PLMemory(I).LNatives[0];
            PLMemory(I).LNatives[0] := PRMemory(J).RNatives[0];
            PRMemory(J).RNatives[0] := TempNative;

            if (SizeOf(T) >= SizeOf(NativeUInt) * 2) then
            begin
              TempNative := PLMemory(I).LNatives[1];
              PLMemory(I).LNatives[1] := PRMemory(J).RNatives[1];
              PRMemory(J).RNatives[1] := TempNative;
            end;

            if (SizeOf(T) >= SizeOf(NativeUInt) * 3) then
            begin
              TempNative := PLMemory(I).LNatives[2];
              PLMemory(I).LNatives[2] := PRMemory(J).RNatives[2];
              PRMemory(J).RNatives[2] := TempNative;
            end;

            if (SizeOf(T) = SizeOf(NativeUInt) * 4) then
            begin
              TempNative := PLMemory(I).LNatives[3];
              PLMemory(I).LNatives[3] := PRMemory(J).RNatives[3];
              PRMemory(J).RNatives[3] := TempNative;
            end;

            {$IFDEF LARGEINT}
            case SizeOf(T) of
              12, 13, 14, 15:
                begin
                  Temp4 := PLMemory(I).LCardinals[2];
                  PLMemory(I).LCardinals[2] := PRMemory(J).RCardinals[2];
                  PRMemory(J).RCardinals[2] := Temp4;
                end;
            end;
            {$ENDIF}

            case SizeOf(T) of
              9:
                begin
                  Temp1 := PLMemory(I).LBytes[8];
                  PLMemory(I).LBytes[8] := PRMemory(J).RBytes[8];
                  PRMemory(J).RBytes[8] := Temp1;
                end;
              10:
                begin
                  Temp2 := PLMemory(I).LWords[4];
                  PLMemory(I).LWords[4] := PRMemory(J).RWords[4];
                  PRMemory(J).RWords[4] := Temp2;
                end;
              11:
                begin
                  Temp2 := PLMemory(I).LWords[4];
                  PLMemory(I).LWords[4] := PRMemory(J).RWords[4];
                  PRMemory(J).RWords[4] := Temp2;
                  Temp1 := PLMemory(I).LBytes[10];
                  PLMemory(I).LBytes[10] := PRMemory(J).RBytes[10];
                  PRMemory(J).RBytes[10] := Temp1;
                end;
              13:
                begin
                  Temp2 := PLMemory(I).LWords[5];
                  PLMemory(I).LWords[5] := PRMemory(J).RWords[5];
                  PRMemory(J).RWords[5] := Temp2;
                  Temp1 := PLMemory(I).LBytes[12];
                  PLMemory(I).LBytes[12] := PRMemory(J).RBytes[12];
                  PRMemory(J).RBytes[12] := Temp1;
                end;
              14:
                begin
                  Temp2 := PLMemory(I).LWords[6];
                  PLMemory(I).LWords[6] := PRMemory(J).RWords[6];
                  PRMemory(J).RWords[6] := Temp2;
                end;
              15:
                begin
                  Temp2 := PLMemory(I).LWords[6];
                  PLMemory(I).LWords[6] := PRMemory(J).RWords[6];
                  PRMemory(J).RWords[6] := Temp2;
                  Temp1 := PLMemory(I).LBytes[14];
                  PLMemory(I).LBytes[14] := PRMemory(J).RBytes[14];
                  PRMemory(J).RBytes[14] := Temp1;
                end;
            end;
          end;
      else
        Index := 0;
        repeat
          TempNative := PLMemory(I).LNatives[Index];
          PLMemory(I).LNatives[Index] := PRMemory(J).RNatives[Index];
          PRMemory(J).RNatives[Index] := TempNative;
          Inc(Index);
        until (Index = SizeOf(T) div SizeOf(NativeUInt));

        if (SizeOf(T) and (SizeOf(NativeUInt) - 1) <> 0) then
        begin
          {$IFDEF LARGEINT}
          if (SizeOf(T) and 4 <> 0) then
          begin
            Index := SizeOf(T) div SizeOf(Cardinal) - 1;
            Temp4 := PLMemory(I).LCardinals[Index];
            PLMemory(I).LCardinals[Index] := PRMemory(J).RCardinals[Index];
            PRMemory(J).RCardinals[Index] := Temp4;
          end;
          {$ENDIF}

          if (SizeOf(T) and 2 <> 0) then
          begin
            Index := SizeOf(T) div SizeOf(Word) - 1;
            Temp2 := PLMemory(I).LWords[Index];
            PLMemory(I).LWords[Index] := PRMemory(J).RWords[Index];
            PRMemory(J).RWords[Index] := Temp2;
          end;

          if (SizeOf(T) and 1 <> 0) then
          begin
            Index := SizeOf(T) div SizeOf(Byte) - 1;
            Temp1 := PLMemory(I).LBytes[Index];
            PLMemory(I).LBytes[Index] := PRMemory(J).RBytes[Index];
            PRMemory(J).RBytes[Index] := Temp1;
          end;
        end;
      end;

      Dec(J, 2);
      if (I <= J) then
        goto swap_loop;
      Inc(I);
      Inc(J);
    end;
  end;

  // next iteration
  StackItem := SortItemNext<T>(StackItem, I, J);
  if (NativeInt(StackItem) >= 0) then
    goto proc_loop_current;
  Dec(NativeInt(StackItem), HIGH_NATIVE_BIT);
  if (StackItem <> Pointer(@Stack[0])) then
    goto proc_loop;
end;

class procedure TArray.SortDescendingBinaries<T>(const Values: Pointer; const Count: NativeInt; var PivotBig: T);
label
  proc_loop, proc_loop_current, swap_loop;
var
  Index: NativeInt;
  Temp1: Byte;
  Temp2: Word;
  Temp4: Cardinal;
  TempNative: NativeUInt;

  I, J: ^T;
  Pivot: TSortPivot;
  X, Y: NativeUInt;
  Buffer: Pointer;
  StackItem: ^TSortStackItem<T>;
  Stack: TSortStack<T>;
begin
  Stack[0].First := Values;
  Stack[0].Last := TRAIIHelper<T>.P(Values) + Count - 1;
  StackItem := Pointer(@Stack[1]);

  proc_loop:
  Dec(StackItem);
  proc_loop_current:
  I := StackItem^.First;
  J := StackItem^.Last;

  // pivot
  if (SizeOf(T) <= SizeOf(Pivot)) then
  begin
    if (SizeOf(T) = SizeOf(Pointer)) then
    begin
      Pivot.Ptr := Pointer(SortItemPivot<T>(I, J)^);
    end
    else
    begin
      TArray.Copy<T>(@Pivot, SortItemPivot<T>(I, J));
    end;
    X := TArray.SortBinaryMarker<T>(@Pivot);
  end
  else
  begin
    TArray.Copy<T>(@PivotBig, SortItemPivot<T>(I, J));
    X := TArray.SortBinaryMarker<T>(@PivotBig);
  end;

  // quick sort
  Dec(J);
  Dec(I);
  swap_loop:
  begin
    Inc(J, 2);

    repeat
      if I = StackItem^.Last then
        Break; // do not let it go beyond the end of the stack
      Inc(I);

      Y := TArray.SortBinaryMarker<T>(I);
      if (X > Y) then
        Break; // Changed from < to > for descending order
      if (X = Y) then
      begin
        if (SizeOf(T) <= SizeOf(Pivot)) then
        begin
          // compare pivot/I
          if (GetTypeKind(T) = tkMethod) then
          begin
            if (NativeUInt(Pivot.Ptr) >= NativeUInt(Pointer(I)^)) then
              Break; // Changed <= to >=
          end
          else if (GetTypeKind(T) = tkString) then
          begin
            if (InterfaceDefaults.Compare_OStr(nil, Pointer(@Pivot), Pointer(I)) >= 0) then
              Break; // Changed <= to >=
          end
          else if (GetTypeKind(T) in [tkLString, tkWString, tkUString, tkDynArray]) then
          begin
            Buffer := Pointer(Pointer(I)^);
            if (Pivot.Ptr = Buffer) then
              Break;
            case GetTypeKind(T) of
              tkLString: if (InterfaceDefaults.Compare_LStr(nil, Pivot.Ptr, Buffer) >= 0) then
                  Break; // Changed <= to >=
              {$IFDEF MSWINDOWS}
              tkWString: if (InterfaceDefaults.Compare_WStr(nil, Pivot.Ptr, Buffer) >= 0) then
                  Break; // Changed <= to >=
              {$ELSE}
              tkWString,
                {$ENDIF}
              tkUString: if (InterfaceDefaults.Compare_UStr(nil, Pivot.Ptr, Buffer) >= 0) then
                  Break; // Changed <= to >=
              tkDynArray: if (InterfaceDefaults.Compare_Dyn(InterfaceDefaults.TDefaultComparer<T>.Instance, Pivot.Ptr,
                Buffer) >= 0) then
                  Break; // Changed <= to >=
            end;
          end
          else
            case SizeOf(T) of
              0..SizeOf(Cardinal): Break;
              {$IFDEF LARGEINT}
              SizeOf(Int64): if (InterfaceDefaults.Compare_Bin8(nil, PInt64(@Pivot)^, PInt64(I)^) >= 0) then
                  Break; // Changed <= to >=
              {$ENDIF}
            else
              if (InterfaceDefaults.Compare_Bin(InterfaceDefaults.TDefaultComparer<T>.Instance,
                Pointer(@Pivot), Pointer(I)) >= 0) then
                Break; // Changed <= to >=
            end;
        end
        else
        begin
          if (InterfaceDefaults.Compare_Bin(InterfaceDefaults.TDefaultComparer<T>.Instance,
            Pointer(@PivotBig), Pointer(I)) >= 0) then
            Break; // Changed <= to >=
        end;
      end;
    until (False);

    repeat
      if J = StackItem^.First then
        Break; // do not let it go beyond the begin of the stack
      Dec(J);

      Y := TArray.SortBinaryMarker<T>(J);
      if (Y > X) then
        Break; // Changed from < to > for descending order
      if (Y = X) then
      begin
        if (SizeOf(T) <= SizeOf(Pivot)) then
        begin
          // compare J/pivot
          if (GetTypeKind(T) = tkMethod) then
          begin
            if (NativeUInt(Pointer(J)^) >= NativeUInt(Pivot.Ptr)) then
              Break; // Changed <= to >=
          end
          else if (GetTypeKind(T) = tkString) then
          begin
            if (InterfaceDefaults.Compare_OStr(nil, Pointer(J), Pointer(@Pivot)) >= 0) then
              Break; // Changed <= to >=
          end
          else if (GetTypeKind(T) in [tkLString, tkWString, tkUString, tkDynArray]) then
          begin
            Buffer := Pointer(Pointer(J)^);
            if (Buffer = Pivot.Ptr) then
              Break;
            case GetTypeKind(T) of
              tkLString: if (InterfaceDefaults.Compare_LStr(nil, Buffer, Pivot.Ptr) >= 0) then
                  Break; // Changed <= to >=
              {$IFDEF MSWINDOWS}
              tkWString: if (InterfaceDefaults.Compare_WStr(nil, Buffer, Pivot.Ptr) >= 0) then
                  Break; // Changed <= to >=
              {$ELSE}
              tkWString,
                {$ENDIF}
              tkUString: if (InterfaceDefaults.Compare_UStr(nil, Buffer, Pivot.Ptr) >= 0) then
                  Break; // Changed <= to >=
              tkDynArray: if (InterfaceDefaults.Compare_Dyn(InterfaceDefaults.TDefaultComparer<T>.Instance, Buffer,
                Pivot.Ptr) >= 0) then
                  Break; // Changed <= to >=
            end;
          end
          else
            case SizeOf(T) of
              0..SizeOf(Cardinal): Break;
              {$IFDEF LARGEINT}
              SizeOf(Int64): if (InterfaceDefaults.Compare_Bin8(nil, PInt64(J)^, PInt64(@Pivot)^) >= 0) then
                  Break; // Changed <= to >=
              {$ENDIF}
            else
              if (InterfaceDefaults.Compare_Bin(InterfaceDefaults.TDefaultComparer<T>.Instance,
                Pointer(J), Pointer(@Pivot)) >= 0) then
                Break; // Changed <= to >=
            end;
        end
        else
        begin
          if (InterfaceDefaults.Compare_Bin(InterfaceDefaults.TDefaultComparer<T>.Instance,
            Pointer(J), Pointer(@PivotBig)) >= 0) then
            Break; // Changed <= to >=
        end;
      end;
    until (False);

    if (I <= J) then
    begin
      // TArray.Exchange<T>(I, J);
      case SizeOf(T) of
        0: ;
        1:
          begin
            Temp1 := PLMemory(I).LBytes[0];
            PLMemory(I).LBytes[0] := PRMemory(J).RBytes[0];
            PRMemory(J).RBytes[0] := Temp1;
          end;
        2:
          begin
            Temp2 := PLMemory(I).LWords[0];
            PLMemory(I).LWords[0] := PRMemory(J).RWords[0];
            PRMemory(J).RWords[0] := Temp2;
          end;
        3:
          begin
            Temp2 := PLMemory(I).LWords[0];
            PLMemory(I).LWords[0] := PRMemory(J).RWords[0];
            PRMemory(J).RWords[0] := Temp2;

            Temp1 := PLMemory(I).LBytes[2];
            PLMemory(I).LBytes[2] := PRMemory(J).RBytes[2];
            PRMemory(J).RBytes[2] := Temp1;
          end;
        4..7:
          begin
            Temp4 := PLMemory(I).LCardinals[0];
            PLMemory(I).LCardinals[0] := PRMemory(J).RCardinals[0];
            PRMemory(J).RCardinals[0] := Temp4;

            case SizeOf(T) of
              5:
                begin
                  Temp1 := PLMemory(I).LBytes[4];
                  PLMemory(I).LBytes[4] := PRMemory(J).RBytes[4];
                  PRMemory(J).RBytes[4] := Temp1;
                end;
              6:
                begin
                  Temp2 := PLMemory(I).LWords[2];
                  PLMemory(I).LWords[2] := PRMemory(J).RWords[2];
                  PRMemory(J).RWords[2] := Temp2;
                end;
              7:
                begin
                  Temp2 := PLMemory(I).LWords[2];
                  PLMemory(I).LWords[2] := PRMemory(J).RWords[2];
                  PRMemory(J).RWords[2] := Temp2;
                  Temp1 := PLMemory(I).LBytes[6];
                  PLMemory(I).LBytes[6] := PRMemory(J).RBytes[6];
                  PRMemory(J).RBytes[6] := Temp1;
                end;
            end;
          end;
        8..16:
          begin
            TempNative := PLMemory(I).LNatives[0];
            PLMemory(I).LNatives[0] := PRMemory(J).RNatives[0];
            PRMemory(J).RNatives[0] := TempNative;

            if (SizeOf(T) >= SizeOf(NativeUInt) * 2) then
            begin
              TempNative := PLMemory(I).LNatives[1];
              PLMemory(I).LNatives[1] := PRMemory(J).RNatives[1];
              PRMemory(J).RNatives[1] := TempNative;
            end;

            if (SizeOf(T) >= SizeOf(NativeUInt) * 3) then
            begin
              TempNative := PLMemory(I).LNatives[2];
              PLMemory(I).LNatives[2] := PRMemory(J).RNatives[2];
              PRMemory(J).RNatives[2] := TempNative;
            end;

            if (SizeOf(T) = SizeOf(NativeUInt) * 4) then
            begin
              TempNative := PLMemory(I).LNatives[3];
              PLMemory(I).LNatives[3] := PRMemory(J).RNatives[3];
              PRMemory(J).RNatives[3] := TempNative;
            end;

            {$IFDEF LARGEINT}
            case SizeOf(T) of
              12, 13, 14, 15:
                begin
                  Temp4 := PLMemory(I).LCardinals[2];
                  PLMemory(I).LCardinals[2] := PRMemory(J).RCardinals[2];
                  PRMemory(J).RCardinals[2] := Temp4;
                end;
            end;
            {$ENDIF}

            case SizeOf(T) of
              9:
                begin
                  Temp1 := PLMemory(I).LBytes[8];
                  PLMemory(I).LBytes[8] := PRMemory(J).RBytes[8];
                  PRMemory(J).RBytes[8] := Temp1;
                end;
              10:
                begin
                  Temp2 := PLMemory(I).LWords[4];
                  PLMemory(I).LWords[4] := PRMemory(J).RWords[4];
                  PRMemory(J).RWords[4] := Temp2;
                end;
              11:
                begin
                  Temp2 := PLMemory(I).LWords[4];
                  PLMemory(I).LWords[4] := PRMemory(J).RWords[4];
                  PRMemory(J).RWords[4] := Temp2;
                  Temp1 := PLMemory(I).LBytes[10];
                  PLMemory(I).LBytes[10] := PRMemory(J).RBytes[10];
                  PRMemory(J).RBytes[10] := Temp1;
                end;
              13:
                begin
                  Temp2 := PLMemory(I).LWords[5];
                  PLMemory(I).LWords[5] := PRMemory(J).RWords[5];
                  PRMemory(J).RWords[5] := Temp2;
                  Temp1 := PLMemory(I).LBytes[12];
                  PLMemory(I).LBytes[12] := PRMemory(J).RBytes[12];
                  PRMemory(J).RBytes[12] := Temp1;
                end;
              14:
                begin
                  Temp2 := PLMemory(I).LWords[6];
                  PLMemory(I).LWords[6] := PRMemory(J).RWords[6];
                  PRMemory(J).RWords[6] := Temp2;
                end;
              15:
                begin
                  Temp2 := PLMemory(I).LWords[6];
                  PLMemory(I).LWords[6] := PRMemory(J).RWords[6];
                  PRMemory(J).RWords[6] := Temp2;
                  Temp1 := PLMemory(I).LBytes[14];
                  PLMemory(I).LBytes[14] := PRMemory(J).RBytes[14];
                  PRMemory(J).RBytes[14] := Temp1;
                end;
            end;
          end;
      else
        Index := 0;
        repeat
          TempNative := PLMemory(I).LNatives[Index];
          PLMemory(I).LNatives[Index] := PRMemory(J).RNatives[Index];
          PRMemory(J).RNatives[Index] := TempNative;
          Inc(Index);
        until (Index = SizeOf(T) div SizeOf(NativeUInt));

        if (SizeOf(T) and (SizeOf(NativeUInt) - 1) <> 0) then
        begin
          {$IFDEF LARGEINT}
          if (SizeOf(T) and 4 <> 0) then
          begin
            Index := SizeOf(T) div SizeOf(Cardinal) - 1;
            Temp4 := PLMemory(I).LCardinals[Index];
            PLMemory(I).LCardinals[Index] := PRMemory(J).RCardinals[Index];
            PRMemory(J).RCardinals[Index] := Temp4;
          end;
          {$ENDIF}

          if (SizeOf(T) and 2 <> 0) then
          begin
            Index := SizeOf(T) div SizeOf(Word) - 1;
            Temp2 := PLMemory(I).LWords[Index];
            PLMemory(I).LWords[Index] := PRMemory(J).RWords[Index];
            PRMemory(J).RWords[Index] := Temp2;
          end;

          if (SizeOf(T) and 1 <> 0) then
          begin
            Index := SizeOf(T) div SizeOf(Byte) - 1;
            Temp1 := PLMemory(I).LBytes[Index];
            PLMemory(I).LBytes[Index] := PRMemory(J).RBytes[Index];
            PRMemory(J).RBytes[Index] := Temp1;
          end;
        end;
      end;

      Dec(J, 2);
      if (I <= J) then
        goto swap_loop;
      Inc(I);
      Inc(J);
    end;
  end;

  // next iteration
  StackItem := SortItemNext<T>(StackItem, I, J);
  if (NativeInt(StackItem) >= 0) then
    goto proc_loop_current;
  Dec(NativeInt(StackItem), HIGH_NATIVE_BIT);
  if (StackItem <> Pointer(@Stack[0])) then
    goto proc_loop;
end;

{$IFDEF WEAKREF}
class procedure TArray.WeakSortUniversals<T>(const Values: Pointer; const Count: NativeInt; var aHelper:
  TSortHelper<T>);
label
  proc_loop, proc_loop_current, swap_loop;
var
  I, J: ^T;
  StackItem: ^TSortStackItem<T>;
  Stack: TSortStack<T>;
begin
  Stack[0].First := Values;
  Stack[0].Last := TRAIIHelper<T>.P(Values) + Count - 1;
  StackItem := Pointer(@Stack[1]);

  proc_loop:
  Dec(StackItem);
  proc_loop_current:
  I := StackItem^.First;
  J := StackItem^.Last;

  // pivot
  System.Move(SortItemPivot<T>(I, J)^, aHelper.Pivot, SizeOf(T));

  // quick sort
  Dec(J);
  Dec(I);
  swap_loop:
  begin
    Inc(J, 2);

    repeat
      if I = StackItem^.Last then
        Break; // do not let it go beyond the end of the stack
      Inc(I);
      if (aHelper.Compare(aHelper.Inst, aHelper.Pivot, I^) <= 0) then
        Break;
    until (False);

    repeat
      if J = StackItem^.First then
        Break; // do not let it go beyond the begin of the stack
      Dec(J);
      if (aHelper.Compare(aHelper.Inst, J^, aHelper.Pivot) <= 0) then
        Break;
    until (False);

    if (I <= J) then
    begin
      aHelper.Temp := I^;
      I^ := J^;
      J^ := aHelper.Temp;

      Dec(J, 2);
      if (I <= J) then
        goto swap_loop;
      Inc(I);
      Inc(J);
    end;
  end;

  // next iteration
  StackItem := SortItemNext<T>(StackItem, I, J);
  if (NativeInt(StackItem) >= 0) then
    goto proc_loop_current;
  Dec(NativeInt(StackItem), HIGH_NATIVE_BIT);
  if (StackItem <> Pointer(@Stack[0])) then
    goto proc_loop;
end;
{$ENDIF}

class procedure TArray.SortUniversals<T>(const Values: Pointer; const Count: NativeInt; var aHelper: TSortHelper<T>);
label
  proc_loop, proc_loop_current, swap_loop;
var
  Index: NativeInt;
  Temp1: Byte;
  Temp2: Word;
  Temp4: Cardinal;
  TempNative: NativeUInt;

  I, J: ^T;
  StackItem: ^TSortStackItem<T>;
  Stack: TSortStack<T>;
begin
  Stack[0].First := Values;
  Stack[0].Last := TRAIIHelper<T>.P(Values) + Count - 1;
  StackItem := Pointer(@Stack[1]);

  proc_loop:
  Dec(StackItem);
  proc_loop_current:
  I := StackItem^.First;
  J := StackItem^.Last;

  // pivot
  TArray.Copy<T>(@aHelper.Pivot, SortItemPivot<T>(I, J));

  // quick sort
  Dec(J);
  Dec(I);
  swap_loop:
  begin
    Inc(J, 2);

    repeat
      if I = StackItem^.Last then
        Break; // do not let it go beyond the end of the stack
      Inc(I);
      if (aHelper.Compare(aHelper.Inst, aHelper.Pivot, I^) <= 0) then
        Break;
    until (False);

    repeat
      if J = StackItem^.First then
        Break; // do not let it go beyond the begin of the stack
      Dec(J);
      if (aHelper.Compare(aHelper.Inst, J^, aHelper.Pivot) <= 0) then
        Break;
    until (False);

    if (I <= J) then
    begin
      // TArray.Exchange<T>(I, J);
      case SizeOf(T) of
        0: ;
        1:
          begin
            Temp1 := PLMemory(I).LBytes[0];
            PLMemory(I).LBytes[0] := PRMemory(J).RBytes[0];
            PRMemory(J).RBytes[0] := Temp1;
          end;
        2:
          begin
            Temp2 := PLMemory(I).LWords[0];
            PLMemory(I).LWords[0] := PRMemory(J).RWords[0];
            PRMemory(J).RWords[0] := Temp2;
          end;
        3:
          begin
            Temp2 := PLMemory(I).LWords[0];
            PLMemory(I).LWords[0] := PRMemory(J).RWords[0];
            PRMemory(J).RWords[0] := Temp2;

            Temp1 := PLMemory(I).LBytes[2];
            PLMemory(I).LBytes[2] := PRMemory(J).RBytes[2];
            PRMemory(J).RBytes[2] := Temp1;
          end;
        4..7:
          begin
            Temp4 := PLMemory(I).LCardinals[0];
            PLMemory(I).LCardinals[0] := PRMemory(J).RCardinals[0];
            PRMemory(J).RCardinals[0] := Temp4;

            case SizeOf(T) of
              5:
                begin
                  Temp1 := PLMemory(I).LBytes[4];
                  PLMemory(I).LBytes[4] := PRMemory(J).RBytes[4];
                  PRMemory(J).RBytes[4] := Temp1;
                end;
              6:
                begin
                  Temp2 := PLMemory(I).LWords[2];
                  PLMemory(I).LWords[2] := PRMemory(J).RWords[2];
                  PRMemory(J).RWords[2] := Temp2;
                end;
              7:
                begin
                  Temp2 := PLMemory(I).LWords[2];
                  PLMemory(I).LWords[2] := PRMemory(J).RWords[2];
                  PRMemory(J).RWords[2] := Temp2;
                  Temp1 := PLMemory(I).LBytes[6];
                  PLMemory(I).LBytes[6] := PRMemory(J).RBytes[6];
                  PRMemory(J).RBytes[6] := Temp1;
                end;
            end;
          end;
        8..16:
          begin
            TempNative := PLMemory(I).LNatives[0];
            PLMemory(I).LNatives[0] := PRMemory(J).RNatives[0];
            PRMemory(J).RNatives[0] := TempNative;

            if (SizeOf(T) >= SizeOf(NativeUInt) * 2) then
            begin
              TempNative := PLMemory(I).LNatives[1];
              PLMemory(I).LNatives[1] := PRMemory(J).RNatives[1];
              PRMemory(J).RNatives[1] := TempNative;
            end;

            if (SizeOf(T) >= SizeOf(NativeUInt) * 3) then
            begin
              TempNative := PLMemory(I).LNatives[2];
              PLMemory(I).LNatives[2] := PRMemory(J).RNatives[2];
              PRMemory(J).RNatives[2] := TempNative;
            end;

            if (SizeOf(T) = SizeOf(NativeUInt) * 4) then
            begin
              TempNative := PLMemory(I).LNatives[3];
              PLMemory(I).LNatives[3] := PRMemory(J).RNatives[3];
              PRMemory(J).RNatives[3] := TempNative;
            end;

            {$IFDEF LARGEINT}
            case SizeOf(T) of
              12, 13, 14, 15:
                begin
                  Temp4 := PLMemory(I).LCardinals[2];
                  PLMemory(I).LCardinals[2] := PRMemory(J).RCardinals[2];
                  PRMemory(J).RCardinals[2] := Temp4;
                end;
            end;
            {$ENDIF}

            case SizeOf(T) of
              9:
                begin
                  Temp1 := PLMemory(I).LBytes[8];
                  PLMemory(I).LBytes[8] := PRMemory(J).RBytes[8];
                  PRMemory(J).RBytes[8] := Temp1;
                end;
              10:
                begin
                  Temp2 := PLMemory(I).LWords[4];
                  PLMemory(I).LWords[4] := PRMemory(J).RWords[4];
                  PRMemory(J).RWords[4] := Temp2;
                end;
              11:
                begin
                  Temp2 := PLMemory(I).LWords[4];
                  PLMemory(I).LWords[4] := PRMemory(J).RWords[4];
                  PRMemory(J).RWords[4] := Temp2;
                  Temp1 := PLMemory(I).LBytes[10];
                  PLMemory(I).LBytes[10] := PRMemory(J).RBytes[10];
                  PRMemory(J).RBytes[10] := Temp1;
                end;
              13:
                begin
                  Temp2 := PLMemory(I).LWords[5];
                  PLMemory(I).LWords[5] := PRMemory(J).RWords[5];
                  PRMemory(J).RWords[5] := Temp2;
                  Temp1 := PLMemory(I).LBytes[12];
                  PLMemory(I).LBytes[12] := PRMemory(J).RBytes[12];
                  PRMemory(J).RBytes[12] := Temp1;
                end;
              14:
                begin
                  Temp2 := PLMemory(I).LWords[6];
                  PLMemory(I).LWords[6] := PRMemory(J).RWords[6];
                  PRMemory(J).RWords[6] := Temp2;
                end;
              15:
                begin
                  Temp2 := PLMemory(I).LWords[6];
                  PLMemory(I).LWords[6] := PRMemory(J).RWords[6];
                  PRMemory(J).RWords[6] := Temp2;
                  Temp1 := PLMemory(I).LBytes[14];
                  PLMemory(I).LBytes[14] := PRMemory(J).RBytes[14];
                  PRMemory(J).RBytes[14] := Temp1;
                end;
            end;
          end;
      else
        Index := 0;
        repeat
          TempNative := PLMemory(I).LNatives[Index];
          PLMemory(I).LNatives[Index] := PRMemory(J).RNatives[Index];
          PRMemory(J).RNatives[Index] := TempNative;
          Inc(Index);
        until (Index = SizeOf(T) div SizeOf(NativeUInt));

        if (SizeOf(T) and (SizeOf(NativeUInt) - 1) <> 0) then
        begin
          {$IFDEF LARGEINT}
          if (SizeOf(T) and 4 <> 0) then
          begin
            Index := SizeOf(T) div SizeOf(Cardinal) - 1;
            Temp4 := PLMemory(I).LCardinals[Index];
            PLMemory(I).LCardinals[Index] := PRMemory(J).RCardinals[Index];
            PRMemory(J).RCardinals[Index] := Temp4;
          end;
          {$ENDIF}

          if (SizeOf(T) and 2 <> 0) then
          begin
            Index := SizeOf(T) div SizeOf(Word) - 1;
            Temp2 := PLMemory(I).LWords[Index];
            PLMemory(I).LWords[Index] := PRMemory(J).RWords[Index];
            PRMemory(J).RWords[Index] := Temp2;
          end;

          if (SizeOf(T) and 1 <> 0) then
          begin
            Index := SizeOf(T) div SizeOf(Byte) - 1;
            Temp1 := PLMemory(I).LBytes[Index];
            PLMemory(I).LBytes[Index] := PRMemory(J).RBytes[Index];
            PRMemory(J).RBytes[Index] := Temp1;
          end;
        end;
      end;

      Dec(J, 2);
      if (I <= J) then
        goto swap_loop;
      Inc(I);
      Inc(J);
    end;
  end;

  // next iteration
  StackItem := SortItemNext<T>(StackItem, I, J);
  if (NativeInt(StackItem) >= 0) then
    goto proc_loop_current;
  Dec(NativeInt(StackItem), HIGH_NATIVE_BIT);
  if (StackItem <> Pointer(@Stack[0])) then
    goto proc_loop;
end;

{$IFDEF WEAKREF}
class procedure TArray.WeakSortDescendingUniversals<T>(const Values: Pointer; const Count: NativeInt; var aHelper:
  TSortHelper<T>);
label
  proc_loop, proc_loop_current, swap_loop;
var
  I, J: ^T;
  StackItem: ^TSortStackItem<T>;
  Stack: TSortStack<T>;
begin
  Stack[0].First := Values;
  Stack[0].Last := TRAIIHelper<T>.P(Values) + Count - 1;
  StackItem := Pointer(@Stack[1]);

  proc_loop:
  Dec(StackItem);
  proc_loop_current:
  I := StackItem^.First;
  J := StackItem^.Last;

  // pivot
  System.Move(SortItemPivot<T>(I, J)^, aHelper.Pivot, SizeOf(T));

  // quick sort
  Dec(J);
  Dec(I);
  swap_loop:
  begin
    Inc(J, 2);

    repeat
      if I = StackItem^.Last then
        Break; // do not let it go beyond the end of the stack
      Inc(I);
      if (aHelper.Compare(aHelper.Inst, aHelper.Pivot, I^) >= 0) then
        Break;
    until (False);

    repeat
      if J = StackItem^.First then
        Break; // do not let it go beyond the begin of the stack
      Dec(J);
      if (aHelper.Compare(aHelper.Inst, J^, aHelper.Pivot) >= 0) then
        Break;
    until (False);

    if (I <= J) then
    begin
      aHelper.Temp := I^;
      I^ := J^;
      J^ := aHelper.Temp;

      Dec(J, 2);
      if (I <= J) then
        goto swap_loop;
      Inc(I);
      Inc(J);
    end;
  end;

  // next iteration
  StackItem := SortItemNext<T>(StackItem, I, J);
  if (NativeInt(StackItem) >= 0) then
    goto proc_loop_current;
  Dec(NativeInt(StackItem), HIGH_NATIVE_BIT);
  if (StackItem <> Pointer(@Stack[0])) then
    goto proc_loop;
end;
{$ENDIF}

class procedure TArray.SortDescendingUniversals<T>(const Values: Pointer; const Count: NativeInt; var aHelper:
  TSortHelper<T>);
label
  proc_loop, proc_loop_current, swap_loop;
var
  Index: NativeInt;
  Temp1: Byte;
  Temp2: Word;
  Temp4: Cardinal;
  TempNative: NativeUInt;

  I, J: ^T;
  StackItem: ^TSortStackItem<T>;
  Stack: TSortStack<T>;
begin
  Stack[0].First := Values;
  Stack[0].Last := TRAIIHelper<T>.P(Values) + Count - 1;
  StackItem := Pointer(@Stack[1]);

  proc_loop:
  Dec(StackItem);
  proc_loop_current:
  I := StackItem^.First;
  J := StackItem^.Last;

  // pivot
  TArray.Copy<T>(@aHelper.Pivot, SortItemPivot<T>(I, J));

  // quick sort
  Dec(J);
  Dec(I);
  swap_loop:
  begin
    Inc(J, 2);

    repeat
      if I = StackItem^.Last then
        Break; // do not let it go beyond the end of the stack
      Inc(I);
      if (aHelper.Compare(aHelper.Inst, aHelper.Pivot, I^) >= 0) then
        Break;
    until (False);

    repeat
      if J = StackItem^.First then
        Break; // do not let it go beyond the begin of the stack
      Dec(J);
      if (aHelper.Compare(aHelper.Inst, J^, aHelper.Pivot) >= 0) then
        Break;
    until (False);

    if (I <= J) then
    begin
      // TArray.Exchange<T>(I, J);
      case SizeOf(T) of
        0: ;
        1:
          begin
            Temp1 := PLMemory(I).LBytes[0];
            PLMemory(I).LBytes[0] := PRMemory(J).RBytes[0];
            PRMemory(J).RBytes[0] := Temp1;
          end;
        2:
          begin
            Temp2 := PLMemory(I).LWords[0];
            PLMemory(I).LWords[0] := PRMemory(J).RWords[0];
            PRMemory(J).RWords[0] := Temp2;
          end;
        3:
          begin
            Temp2 := PLMemory(I).LWords[0];
            PLMemory(I).LWords[0] := PRMemory(J).RWords[0];
            PRMemory(J).RWords[0] := Temp2;

            Temp1 := PLMemory(I).LBytes[2];
            PLMemory(I).LBytes[2] := PRMemory(J).RBytes[2];
            PRMemory(J).RBytes[2] := Temp1;
          end;
        4..7:
          begin
            Temp4 := PLMemory(I).LCardinals[0];
            PLMemory(I).LCardinals[0] := PRMemory(J).RCardinals[0];
            PRMemory(J).RCardinals[0] := Temp4;

            case SizeOf(T) of
              5:
                begin
                  Temp1 := PLMemory(I).LBytes[4];
                  PLMemory(I).LBytes[4] := PRMemory(J).RBytes[4];
                  PRMemory(J).RBytes[4] := Temp1;
                end;
              6:
                begin
                  Temp2 := PLMemory(I).LWords[2];
                  PLMemory(I).LWords[2] := PRMemory(J).RWords[2];
                  PRMemory(J).RWords[2] := Temp2;
                end;
              7:
                begin
                  Temp2 := PLMemory(I).LWords[2];
                  PLMemory(I).LWords[2] := PRMemory(J).RWords[2];
                  PRMemory(J).RWords[2] := Temp2;
                  Temp1 := PLMemory(I).LBytes[6];
                  PLMemory(I).LBytes[6] := PRMemory(J).RBytes[6];
                  PRMemory(J).RBytes[6] := Temp1;
                end;
            end;
          end;
        8..16:
          begin
            TempNative := PLMemory(I).LNatives[0];
            PLMemory(I).LNatives[0] := PRMemory(J).RNatives[0];
            PRMemory(J).RNatives[0] := TempNative;

            if (SizeOf(T) >= SizeOf(NativeUInt) * 2) then
            begin
              TempNative := PLMemory(I).LNatives[1];
              PLMemory(I).LNatives[1] := PRMemory(J).RNatives[1];
              PRMemory(J).RNatives[1] := TempNative;
            end;

            if (SizeOf(T) >= SizeOf(NativeUInt) * 3) then
            begin
              TempNative := PLMemory(I).LNatives[2];
              PLMemory(I).LNatives[2] := PRMemory(J).RNatives[2];
              PRMemory(J).RNatives[2] := TempNative;
            end;

            if (SizeOf(T) = SizeOf(NativeUInt) * 4) then
            begin
              TempNative := PLMemory(I).LNatives[3];
              PLMemory(I).LNatives[3] := PRMemory(J).RNatives[3];
              PRMemory(J).RNatives[3] := TempNative;
            end;

            {$IFDEF LARGEINT}
            case SizeOf(T) of
              12, 13, 14, 15:
                begin
                  Temp4 := PLMemory(I).LCardinals[2];
                  PLMemory(I).LCardinals[2] := PRMemory(J).RCardinals[2];
                  PRMemory(J).RCardinals[2] := Temp4;
                end;
            end;
            {$ENDIF}

            case SizeOf(T) of
              9:
                begin
                  Temp1 := PLMemory(I).LBytes[8];
                  PLMemory(I).LBytes[8] := PRMemory(J).RBytes[8];
                  PRMemory(J).RBytes[8] := Temp1;
                end;
              10:
                begin
                  Temp2 := PLMemory(I).LWords[4];
                  PLMemory(I).LWords[4] := PRMemory(J).RWords[4];
                  PRMemory(J).RWords[4] := Temp2;
              //AM: Check this
              //PRMemory(J).RBytes[4] := Temp2;
                end;
              11:
                begin
                  Temp2 := PLMemory(I).LWords[4];
                  PLMemory(I).LWords[4] := PRMemory(J).RWords[4];
                  PRMemory(J).RWords[4] := Temp2;
                  Temp1 := PLMemory(I).LBytes[10];
                  PLMemory(I).LBytes[10] := PRMemory(J).RBytes[10];
                  PRMemory(J).RBytes[10] := Temp1;
                end;
              13:
                begin
                  Temp2 := PLMemory(I).LWords[5];
                  PLMemory(I).LWords[5] := PRMemory(J).RWords[5];
                  PRMemory(J).RWords[5] := Temp2;
                  Temp1 := PLMemory(I).LBytes[12];
                  PLMemory(I).LBytes[12] := PRMemory(J).RBytes[12];
                  PRMemory(J).RBytes[12] := Temp1;
                end;
              14:
                begin
                  Temp2 := PLMemory(I).LWords[6];
                  PLMemory(I).LWords[6] := PRMemory(J).RWords[6];
                  PRMemory(J).RWords[6] := Temp2;
                end;
              15:
                begin
                  Temp2 := PLMemory(I).LWords[6];
                  PLMemory(I).LWords[6] := PRMemory(J).RWords[6];
                  PRMemory(J).RWords[6] := Temp2;
                  Temp1 := PLMemory(I).LBytes[14];
                  PLMemory(I).LBytes[14] := PRMemory(J).RBytes[14];
                  PRMemory(J).RBytes[14] := Temp1;
                end;
            end;
          end;
      else
        Index := 0;
        repeat
          TempNative := PLMemory(I).LNatives[Index];
          PLMemory(I).LNatives[Index] := PRMemory(J).RNatives[Index];
          PRMemory(J).RNatives[Index] := TempNative;
          Inc(Index);
        until (Index = SizeOf(T) div SizeOf(NativeUInt));

        if (SizeOf(T) and (SizeOf(NativeUInt) - 1) <> 0) then
        begin
          {$IFDEF LARGEINT}
          if (SizeOf(T) and 4 <> 0) then
          begin
            Index := SizeOf(T) div SizeOf(Cardinal) - 1;
            Temp4 := PLMemory(I).LCardinals[Index];
            PLMemory(I).LCardinals[Index] := PRMemory(J).RCardinals[Index];
            PRMemory(J).RCardinals[Index] := Temp4;
          end;
          {$ENDIF}

          if (SizeOf(T) and 2 <> 0) then
          begin
            Index := SizeOf(T) div SizeOf(Word) - 1;
            Temp2 := PLMemory(I).LWords[Index];
            PLMemory(I).LWords[Index] := PRMemory(J).RWords[Index];
            PRMemory(J).RWords[Index] := Temp2;
          end;

          if (SizeOf(T) and 1 <> 0) then
          begin
            Index := SizeOf(T) div SizeOf(Byte) - 1;
            Temp1 := PLMemory(I).LBytes[Index];
            PLMemory(I).LBytes[Index] := PRMemory(J).RBytes[Index];
            PRMemory(J).RBytes[Index] := Temp1;
          end;
        end;
      end;

      Dec(J, 2);
      if (I <= J) then
        goto swap_loop;
      Inc(I);
      Inc(J);
    end;
  end;

  // next iteration
  StackItem := SortItemNext<T>(StackItem, I, J);
  if (NativeInt(StackItem) >= 0) then
    goto proc_loop_current;
  Dec(NativeInt(StackItem), HIGH_NATIVE_BIT);
  if (StackItem <> Pointer(@Stack[0])) then
    goto proc_loop;
end;

class procedure TArray.Sort<T>(var Values: T; const Count: Integer);
var
  TypeData: PTypeData;
  PivotBig: ^T;
begin
  if (Count <= 1) then
    Exit;

  if (GetTypeKind(T) in [tkInteger, tkEnumeration, tkChar, tkWChar, tkInt64]) or
    ((GetTypeKind(T) = tkFloat) and (SizeOf(T) = 8)) then
  begin
    TypeData := Pointer(TypeInfo(T));
    Inc(NativeUInt(TypeData), NativeUInt(PByte(@PTypeInfo(TypeData).Name)^) + 2);
  end
  else
    TypeData := nil; // satisfy compiler

  {$IFDEF WEAKREF}
  if (TRAIIHelper<T>.Weak) then
  begin
    TArray.Sort<T>(Values, Count, IComparer<T>(Pointer(@InterfaceDefaults.TDefaultComparer<T>.Instance)));
  end
  else
    {$ENDIF}
    case GetTypeKind(T) of
      tkInteger, tkEnumeration, tkChar, tkWChar:
        case SizeOf(T) of
          1:
            begin
              case TypeData.OrdType of
                otSByte: SortSigneds<ShortInt>(@Values, Count);
                otUByte: SortUnsigneds<Byte>(@Values, Count);
              end;
            end;
          2:
            begin
              case TypeData.OrdType of
                otSWord: SortSigneds<SmallInt>(@Values, Count);
                otUWord: SortUnsigneds<Word>(@Values, Count);
              end;
            end;
          4:
            begin
              case TypeData.OrdType of
                otSLong: SortSigneds<Integer>(@Values, Count);
                otULong: SortUnsigneds<Cardinal>(@Values, Count);
              end;
            end;
        end;
      tkInt64:
        begin
          if (TypeData.MaxInt64Value > TypeData.MinInt64Value) then
          begin
            SortSigneds<Int64>(@Values, Count);
          end
          else
          begin
            SortUnsigneds<UInt64>(@Values, Count);
          end;
        end;
      tkClass, tkInterface, tkClassRef, tkPointer, tkProcedure:
        begin
          {$IFDEF LARGEINT}
          SortUnsigneds<UInt64>(@Values, Count);
          {$ELSE .SMALLINT}
          SortUnsigneds<Cardinal>(@Values, Count);
          {$ENDIF}
        end;
      tkFloat:
        case SizeOf(T) of
          4: SortFloats<Single>(@Values, Count);
          10: SortFloats<Extended>(@Values, Count);
        else
          if (TypeData.FloatType = ftDouble) then
          begin
            SortFloats<Double>(@Values, Count);
          end
          else
          begin
            SortSigneds<Int64>(@Values, Count);
          end;
        end;
      tkVariant:
        begin
          TArray.Sort<Variant>(PVariant(@Values)^, Count,
            IComparer<Variant>(Pointer(@InterfaceDefaults.TDefaultComparer<Variant>.Instance)));
        end;
      tkMethod:
        begin
          SortBinaries < InterfaceDefaults.TMethodPtr > (@Values, Count, InterfaceDefaults.TMethodPtr(nil^));
        end;
      tkString:
        begin
          SortBinaries<T>(@Values, Count, T(nil^));
        end;
      tkLString:
        begin
          {$IFDEF ANSISTRSUPPORT}
          SortBinaries<AnsiString>(@Values, Count, AnsiString(nil^));
          {$ELSE}
          SortBinaries<T>(@Values, Count, T(nil^));
          {$ENDIF}
        end;
      {$IFDEF MSWINDOWS}
      tkWString:
        begin
          SortBinaries<WideString>(@Values, Count, WideString(nil^));
        end;
      {$ELSE}
      tkWString,
        {$ENDIF}
      tkUString:
        begin
          SortBinaries<UnicodeString>(@Values, Count, UnicodeString(nil^));
        end;
      tkDynArray:
        begin
          SortBinaries<T>(@Values, Count, T(nil^));
        end;
    else
    // binary
      case SizeOf(T) of
        0: ;
        1: SortUnsigneds<Byte>(@Values, Count);
        2..BUFFER_SIZE: SortBinaries<T>(@Values, Count, T(nil^));
      else
        GetMem(PivotBig, SizeOf(T));
        try
          SortBinaries<T>(@Values, Count, PivotBig^);
        finally
          FreeMem(PivotBig);
        end;
      end;
    end;
end;

class procedure TArray.Sort<T>(var Values: T; const Count: Integer; const Comparer: IComparer<T>);
var
  HelperBuffer: array[0..BUFFER_SIZE - 1] of Byte;
  LHelper: ^TSortHelper<T>;
begin
  if (Count <= 1) then
    Exit;

  LHelper := Pointer(@HelperBuffer);
  if (SizeOf(TSortHelper<T>) > SizeOf(HelperBuffer)) then
    GetMem(LHelper, SizeOf(TSortHelper<T>));
  try
    LHelper^.Init(Comparer);

    {$IFDEF WEAKREF}
    if (TRAIIHelper<T>.Weak) then
    begin
      System.Initialize(LHelper.Temp);
      try
        TArray.WeakSortUniversals<T>(@Values, Count, LHelper^);
      finally
        System.Finalize(LHelper.Temp);
      end;
    end
    else
      {$ENDIF}
    begin
      TArray.SortUniversals<T>(@Values, Count, LHelper^);
    end;
  finally
    if (LHelper <> Pointer(@HelperBuffer)) then
      FreeMem(LHelper);
  end;
end;

class procedure TArray.Sort<T>(var Values: T; const Count: Integer; const Comparison: TComparison<T>);
var
  HelperBuffer: array[0..BUFFER_SIZE - 1] of Byte;
  LHelper: ^TSortHelper<T>;
begin
  if (Count <= 1) then
    Exit;

  LHelper := Pointer(@HelperBuffer);
  if (SizeOf(TSortHelper<T>) > SizeOf(HelperBuffer)) then
    GetMem(LHelper, SizeOf(TSortHelper<T>));
  try
    LHelper^.Init(Comparison);

    {$IFDEF WEAKREF}
    if (TRAIIHelper<T>.Weak) then
    begin
      System.Initialize(LHelper.Temp);
      try
        TArray.WeakSortUniversals<T>(@Values, Count, LHelper^);
      finally
        System.Finalize(LHelper.Temp);
      end;
    end
    else
      {$ENDIF}
    begin
      TArray.SortUniversals<T>(@Values, Count, LHelper^);
    end;
  finally
    if (LHelper <> Pointer(@HelperBuffer)) then
      FreeMem(LHelper);
  end;
end;

class procedure TArray.Sort<T>(var Values: array of T);
begin
  if (High(Values) > 0) then
    Sort<T>(Values[0], Length(Values));
end;

class procedure TArray.Sort<T>(var Values: array of T; const Comparer: IComparer<T>);
begin
  if (High(Values) > 0) then
    Sort<T>(Values[0], Length(Values), Comparer);
end;

class procedure TArray.Sort<T>(var Values: array of T; const Comparer: IComparer<T>; Index, Count: Integer);
begin
  if (Index < Low(Values)) or ((Index > High(Values)) and (Count > 0))
    or (Index + Count - 1 > High(Values)) or (Count < 0)
    or (Index + Count < 0) then
    ErrorArgumentOutOfRange;
  if Count <= 1 then
    Exit;

  Sort<T>(Values[Index], Count, Comparer);
end;

class procedure TArray.Sort<T>(var Values: array of T; const Comparison: TComparison<T>);
begin
  if (High(Values) > 0) then
    Sort<T>(Values[0], Length(Values), Comparison);
end;

class procedure TArray.Sort<T>(var Values: array of T; Index, Count: Integer; const Comparison: TComparison<T>);
begin
  if (Index < Low(Values)) or ((Index > High(Values)) and (Count > 0))
    or (Index + Count - 1 > High(Values)) or (Count < 0)
    or (Index + Count < 0) then
    ErrorArgumentOutOfRange;
  if Count <= 1 then
    Exit;

  Sort<T>(Values[Index], Count, Comparison);
end;

class procedure TArray.SortDescending<T>(var Values: T; const Count: Integer);
var
  TypeData: PTypeData;
  PivotBig: ^T;
begin
  if (Count <= 1) then
    Exit;

  if (GetTypeKind(T) in [tkInteger, tkEnumeration, tkChar, tkWChar, tkInt64]) or
    ((GetTypeKind(T) = tkFloat) and (SizeOf(T) = 8)) then
  begin
    TypeData := Pointer(TypeInfo(T));
    Inc(NativeUInt(TypeData), NativeUInt(PByte(@PTypeInfo(TypeData).Name)^) + 2);
  end
  else
    TypeData := nil; // satisfy compiler

  {$IFDEF WEAKREF}
  if (TRAIIHelper<T>.Weak) then
  begin
    TArray.SortDescending<T>(Values, Count, IComparer<T>(Pointer(@InterfaceDefaults.TDefaultComparer<T>.Instance)));
  end
  else
    {$ENDIF}
    case GetTypeKind(T) of
      tkInteger, tkEnumeration, tkChar, tkWChar:
        case SizeOf(T) of
          1:
            begin
              case TypeData.OrdType of
                otSByte: SortDescendingSigneds<ShortInt>(@Values, Count);
                otUByte: SortDescendingUnsigneds<Byte>(@Values, Count);
              end;
            end;
          2:
            begin
              case TypeData.OrdType of
                otSWord: SortDescendingSigneds<SmallInt>(@Values, Count);
                otUWord: SortDescendingUnsigneds<Word>(@Values, Count);
              end;
            end;
          4:
            begin
              case TypeData.OrdType of
                otSLong: SortDescendingSigneds<Integer>(@Values, Count);
                otULong: SortDescendingUnsigneds<Cardinal>(@Values, Count);
              end;
            end;
        end;
      tkInt64:
        begin
          if (TypeData.MaxInt64Value > TypeData.MinInt64Value) then
          begin
            SortDescendingSigneds<Int64>(@Values, Count);
          end
          else
          begin
            SortDescendingUnsigneds<UInt64>(@Values, Count);
          end;
        end;
      tkClass, tkInterface, tkClassRef, tkPointer, tkProcedure:
        begin
          {$IFDEF LARGEINT}
          SortDescendingUnsigneds<UInt64>(@Values, Count);
          {$ELSE .SMALLINT}
          SortDescendingUnsigneds<Cardinal>(@Values, Count);
          {$ENDIF}
        end;
      tkFloat:
        case SizeOf(T) of
          4: SortDescendingFloats<Single>(@Values, Count);
          10: SortDescendingFloats<Extended>(@Values, Count);
        else
          if (TypeData.FloatType = ftDouble) then
          begin
            SortDescendingFloats<Double>(@Values, Count);
          end
          else
          begin
            SortDescendingSigneds<Int64>(@Values, Count);
          end;
        end;
      tkVariant:
        begin
          TArray.SortDescending<Variant>(PVariant(@Values)^, Count,
            IComparer<Variant>(Pointer(@InterfaceDefaults.TDefaultComparer<Variant>.Instance)));
        end;
      tkMethod:
        begin
          SortDescendingBinaries < InterfaceDefaults.TMethodPtr > (@Values, Count, InterfaceDefaults.TMethodPtr(nil^));
        end;
      tkString:
        begin
          SortDescendingBinaries<T>(@Values, Count, T(nil^));
        end;
      tkLString:
        begin
          {$IFDEF ANSISTRSUPPORT}
          SortDescendingBinaries<AnsiString>(@Values, Count, AnsiString(nil^));
          {$ELSE}
          SortDescendingBinaries<T>(@Values, Count, T(nil^));
          {$ENDIF}
        end;
      {$IFDEF MSWINDOWS}
      tkWString:
        begin
          SortDescendingBinaries<WideString>(@Values, Count, WideString(nil^));
        end;
      {$ELSE}
      tkWString,
        {$ENDIF}
      tkUString:
        begin
          SortDescendingBinaries<UnicodeString>(@Values, Count, UnicodeString(nil^));
        end;
      tkDynArray:
        begin
          SortDescendingBinaries<T>(@Values, Count, T(nil^));
        end;
    else
    // binary
      case SizeOf(T) of
        0: ;
        1: SortDescendingUnsigneds<Byte>(@Values, Count);
        2..BUFFER_SIZE: SortDescendingBinaries<T>(@Values, Count, T(nil^));
      else
        GetMem(PivotBig, SizeOf(T));
        try
          SortDescendingBinaries<T>(@Values, Count, PivotBig^);
        finally
          FreeMem(PivotBig);
        end;
      end;
    end;
end;

class procedure TArray.SortDescending<T>(var Values: T; const Count: Integer; const Comparer: IComparer<T>);
var
  HelperBuffer: array[0..BUFFER_SIZE - 1] of Byte;
  helper: ^TSortHelper<T>;
begin
  if (Count <= 1) then
    Exit;

  helper := Pointer(@HelperBuffer);
  if (SizeOf(TSortHelper<T>) > SizeOf(HelperBuffer)) then
    GetMem(helper, SizeOf(TSortHelper<T>));
  try
    helper^.Init(Comparer);

    {$IFDEF WEAKREF}
    if (TRAIIHelper<T>.Weak) then
    begin
      System.Initialize(helper.Temp);
      try
        TArray.WeakSortDescendingUniversals<T>(@Values, Count, helper^);
      finally
        System.Finalize(helper.Temp);
      end;
    end
    else
      {$ENDIF}
    begin
      TArray.SortDescendingUniversals<T>(@Values, Count, helper^);
    end;
  finally
    if (helper <> Pointer(@HelperBuffer)) then
      FreeMem(helper);
  end;
end;

class procedure TArray.SortDescending<T>(var Values: T; const Count: Integer; const Comparison: TComparison<T>);
var
  HelperBuffer: array[0..BUFFER_SIZE - 1] of Byte;
  helper: ^TSortHelper<T>;
begin
  if (Count <= 1) then
    Exit;

  helper := Pointer(@HelperBuffer);
  if (SizeOf(TSortHelper<T>) > SizeOf(HelperBuffer)) then
    GetMem(helper, SizeOf(TSortHelper<T>));
  try
    helper^.Init(Comparison);

    {$IFDEF WEAKREF}
    if (TRAIIHelper<T>.Weak) then
    begin
      System.Initialize(helper.Temp);
      try
        TArray.WeakSortDescendingUniversals<T>(@Values, Count, helper^);
      finally
        System.Finalize(helper.Temp);
      end;
    end
    else
      {$ENDIF}
    begin
      TArray.SortDescendingUniversals<T>(@Values, Count, helper^);
    end;
  finally
    if (helper <> Pointer(@HelperBuffer)) then
      FreeMem(helper);
  end;
end;

class procedure TArray.SortDescending<T>(var Values: array of T);
begin
  if (High(Values) > 0) then
    SortDescending<T>(Values[0], Length(Values));
end;

class procedure TArray.SortDescending<T>(var Values: array of T; const Comparer: IComparer<T>);
begin
  if (High(Values) > 0) then
    SortDescending<T>(Values[0], Length(Values), Comparer);
end;

class procedure TArray.SortDescending<T>(var Values: array of T; const Comparer: IComparer<T>; Index, Count: Integer);
begin
  if (Index < Low(Values)) or ((Index > High(Values)) and (Count > 0))
    or (Index + Count - 1 > High(Values)) or (Count < 0)
    or (Index + Count < 0) then
    ErrorArgumentOutOfRange;
  if Count <= 1 then
    Exit;

  SortDescending<T>(Values[Index], Count, Comparer);
end;

class procedure TArray.SortDescending<T>(var Values: array of T; const Comparison: TComparison<T>);
begin
  if (High(Values) > 0) then
    SortDescending<T>(Values[0], Length(Values), Comparison);
end;

class procedure TArray.SortDescending<T>(var Values: array of T; Index, Count: Integer; const Comparison:
  TComparison<T>);
begin
  if (Index < Low(Values)) or ((Index > High(Values)) and (Count > 0))
    or (Index + Count - 1 > High(Values)) or (Count < 0)
    or (Index + Count < 0) then
    ErrorArgumentOutOfRange;
  if Count <= 1 then
    Exit;

  SortDescending<T>(Values[Index], Count, Comparison);
end;

{$WARNINGS OFF} // compiler can't identify variable initialization in case statement

class function TArray.SearchSigneds<T>(Values: Pointer; Count: NativeInt; Item: Pointer): NativeInt;
label
  middle_init, not_found;
type
  PArray1 = ^HugeShortIntArray;
  PArray2 = ^HugeSmallIntArray;
  PArray4 = ^HugeIntegerArray;
  PArray8 = ^ {$IFDEF LARGEINT}HugeInt64Array{$ELSE .SMALLINT}HugeTPointArray{$ENDIF};
var
  Item1: ShortInt;
  Item2: SmallInt;
  Item4: Integer;
  {$IFDEF LARGEINT}
  Item8: Int64;
  {$ELSE .SMALLINT}
  Item8Low: Cardinal;
  Item8High, Buffer8High: Integer;
  {$ENDIF}
  Left, Right, Middle: NativeInt;
begin
  case SizeOf(T) of
    1: Byte(Item1) := PByte(Item)^;
    2: Word(Item2) := PWord(Item)^;
    4: Integer(Item4) := PInteger(Item)^;
  else
    {$IFDEF LARGEINT}
    Int64(Item8) := PInt64(Item)^;
    {$ELSE .SMALLINT}
    Item8Low := PPoint(Item).X;
    Item8High := PPoint(Item).Y;
    {$ENDIF}
  end;

  Middle := -1;
  Right := Count + (-1);
  repeat
    Left := Middle + 1;
    if (Middle >= Right) then
      Break;

    middle_init:
    Middle := Right;
    Dec(Middle, Left);
    Middle := Left + (Middle shr 1);

    case SizeOf(T) of
      1: if (PArray1(Values)[Middle] < Item1) then
          Continue;
      2: if (PArray2(Values)[Middle] < Item2) then
          Continue;
      4: if (PArray4(Values)[Middle] < Item4) then
          Continue;
    else
      {$IFDEF LARGEINT}
      if (PArray8(Values)[Middle] < Item8) then
        Continue;
      {$ELSE .SMALLINT}
      Inc(NativeUInt(Values), SizeOf(Integer));
      Buffer8High := PArray8(Values)[Middle].X;
      Dec(NativeUInt(Values), SizeOf(Integer));
      if (Buffer8High < Item8High) then
        Continue;
      if (Buffer8High = Item8High) then
      begin
        if (Cardinal(PArray8(Values)[Middle].X) < Item8Low) then
          Continue;
      end;
      {$ENDIF}
    end;

    Right := Middle + (-1);
    if (not (Left > Right)) then
      goto middle_init;
    Break;
  until (False);

  if (Left < Count) then
  begin
    case SizeOf(T) of
      1: if (PArray1(Values)[Left] <> Item1) then
          goto not_found;
      2: if (PArray2(Values)[Left] <> Item2) then
          goto not_found;
      4: if (PArray4(Values)[Left] <> Item4) then
          goto not_found;
    else
      {$IFDEF LARGEINT}
      if (PArray8(Values)[Left] <> Item8) then
        goto not_found;
      {$ELSE .SMALLINT}
      Inc(NativeUInt(Values), SizeOf(Integer));
      Dec(Item8High, PArray8(Values)[Left].X);
      Dec(NativeUInt(Values), SizeOf(Integer));
      Buffer8High := PArray8(Values)[Left].X;
      Dec(Buffer8High, Item8Low);
      if (Buffer8High or Item8High <> 0) then
        goto not_found;
      {$ENDIF}
    end;
  end
  else
  begin
    not_found:
    Left := not Left;
  end;

  Result := Left;
end;
{$WARNINGS ON}

{$WARNINGS OFF} // compiler can't identify variable initialization in case statement

class function TArray.SearchDescendingSigneds<T>(Values: Pointer; Count: NativeInt; Item: Pointer): NativeInt;
label
  middle_init, not_found;
type
  PArray1 = ^HugeShortIntArray;
  PArray2 = ^HugeSmallIntArray;
  PArray4 = ^HugeIntegerArray;
  PArray8 = ^ {$IFDEF LARGEINT}HugeInt64Array{$ELSE .SMALLINT}HugeTPointArray{$ENDIF};
var
  Item1: ShortInt;
  Item2: SmallInt;
  Item4: Integer;
  {$IFDEF LARGEINT}
  Item8: Int64;
  {$ELSE .SMALLINT}
  Item8Low: Cardinal;
  Item8High, Buffer8High: Integer;
  {$ENDIF}
  Left, Right, Middle: NativeInt;
begin
  case SizeOf(T) of
    1: Byte(Item1) := PByte(Item)^;
    2: Word(Item2) := PWord(Item)^;
    4: Integer(Item4) := PInteger(Item)^;
  else
    {$IFDEF LARGEINT}
    Int64(Item8) := PInt64(Item)^;
    {$ELSE .SMALLINT}
    Item8Low := PPoint(Item).X;
    Item8High := PPoint(Item).Y;
    {$ENDIF}
  end;

  Middle := -1;
  Right := Count + (-1);
  repeat
    Left := Middle + 1;
    if (Middle >= Right) then
      Break;

    middle_init:
    Middle := Right;
    Dec(Middle, Left);
    Middle := Left + (Middle shr 1);

    case SizeOf(T) of
      1: if (PArray1(Values)[Middle] > Item1) then
          Continue;
      2: if (PArray2(Values)[Middle] > Item2) then
          Continue;
      4: if (PArray4(Values)[Middle] > Item4) then
          Continue;
    else
      {$IFDEF LARGEINT}
      if (PArray8(Values)[Middle] > Item8) then
        Continue;
      {$ELSE .SMALLINT}
      Inc(NativeUInt(Values), SizeOf(Integer));
      Buffer8High := PArray8(Values)[Middle].X;
      Dec(NativeUInt(Values), SizeOf(Integer));
      if (Buffer8High > Item8High) then
        Continue;
      if (Buffer8High = Item8High) then
      begin
        if (Cardinal(PArray8(Values)[Middle].X) > Item8Low) then
          Continue;
      end;
      {$ENDIF}
    end;

    Right := Middle + (-1);
    if (not (Left > Right)) then
      goto middle_init;
    Break;
  until (False);

  if (Left < Count) then
  begin
    case SizeOf(T) of
      1: if (PArray1(Values)[Left] <> Item1) then
          goto not_found;
      2: if (PArray2(Values)[Left] <> Item2) then
          goto not_found;
      4: if (PArray4(Values)[Left] <> Item4) then
          goto not_found;
    else
      {$IFDEF LARGEINT}
      if (PArray8(Values)[Left] <> Item8) then
        goto not_found;
      {$ELSE .SMALLINT}
      Inc(NativeUInt(Values), SizeOf(Integer));
      Dec(Item8High, PArray8(Values)[Left].X);
      Dec(NativeUInt(Values), SizeOf(Integer));
      Buffer8High := PArray8(Values)[Left].X;
      Dec(Buffer8High, Item8Low);
      if (Buffer8High or Item8High <> 0) then
        goto not_found;
      {$ENDIF}
    end;
  end
  else
  begin
    not_found:
    Left := not Left;
  end;

  Result := Left;
end;
{$WARNINGS ON}

{$WARNINGS OFF} // compiler can't identify variable initialization in case statement

class function TArray.SearchUnsigneds<T>(Values: Pointer; Count: NativeInt; Item: Pointer): NativeInt;
label
  middle_init, not_found;
type
  PArray1 = ^HugeByteArray;
  PArray2 = ^HugeWordArray;
  PArray4 = ^HugeCardinalArray;
  PArray8 = ^ {$IFDEF LARGEINT}HugeUInt64Array{$ELSE .SMALLINT}HugeTPointArray{$ENDIF};
var
  Item1: Byte;
  Item2: Word;
  Item4: Cardinal;
  {$IFDEF LARGEINT}
  Item8: UInt64;
  {$ELSE .SMALLINT}
  Item8Low: Cardinal;
  Item8High, Buffer8High: Cardinal;
  {$ENDIF}
  Left, Right, Middle: NativeInt;
begin
  case SizeOf(T) of
    1: Byte(Item1) := PByte(Item)^;
    2: Word(Item2) := PWord(Item)^;
    4: Integer(Item4) := PInteger(Item)^;
  else
    {$IFDEF LARGEINT}
    Int64(Item8) := PInt64(Item)^;
    {$ELSE .SMALLINT}
    Item8Low := PPoint(Item).X;
    Item8High := PPoint(Item).Y;
    {$ENDIF}
  end;

  Middle := -1;
  Right := Count + (-1);
  repeat
    Left := Middle + 1;
    if (Middle >= Right) then
      Break;

    middle_init:
    Middle := Right;
    Dec(Middle, Left);
    Middle := Left + (Middle shr 1);

    case SizeOf(T) of
      1: if (PArray1(Values)[Middle] < Item1) then
          Continue;
      2: if (PArray2(Values)[Middle] < Item2) then
          Continue;
      4: if (PArray4(Values)[Middle] < Item4) then
          Continue;
    else
      {$IFDEF LARGEINT}
      if (PArray8(Values)[Middle] < Item8) then
        Continue;
      {$ELSE .SMALLINT}
      Inc(NativeUInt(Values), SizeOf(Integer));
      Buffer8High := PArray8(Values)[Middle].X;
      Dec(NativeUInt(Values), SizeOf(Integer));
      if (Buffer8High < Item8High) then
        Continue;
      if (Buffer8High = Item8High) then
      begin
        if (Cardinal(PArray8(Values)[Middle].X) < Item8Low) then
          Continue;
      end;
      {$ENDIF}
    end;

    Right := Middle + (-1);
    if (not (Left > Right)) then
      goto middle_init;
    Break;
  until (False);

  if (Left < Count) then
  begin
    case SizeOf(T) of
      1: if (PArray1(Values)[Left] <> Item1) then
          goto not_found;
      2: if (PArray2(Values)[Left] <> Item2) then
          goto not_found;
      4: if (PArray4(Values)[Left] <> Item4) then
          goto not_found;
    else
      {$IFDEF LARGEINT}
      if (PArray8(Values)[Left] <> Item8) then
        goto not_found;
      {$ELSE .SMALLINT}
      Inc(NativeUInt(Values), SizeOf(Integer));
      Dec(Item8High, PArray8(Values)[Left].X);
      Dec(NativeUInt(Values), SizeOf(Integer));
      Buffer8High := PArray8(Values)[Left].X;
      Dec(Buffer8High, Item8Low);
      if (Buffer8High or Item8High <> 0) then
        goto not_found;
      {$ENDIF}
    end;
  end
  else
  begin
    not_found:
    Left := not Left;
  end;

  Result := Left;
end;
{$WARNINGS ON}

{$WARNINGS OFF} // compiler can't identify variable initialization in case statement

class function TArray.SearchDescendingUnsigneds<T>(Values: Pointer; Count: NativeInt; Item: Pointer): NativeInt;
label
  middle_init, not_found;
type
  PArray1 = ^HugeByteArray;
  PArray2 = ^HugeWordArray;
  PArray4 = ^HugeCardinalArray;
  PArray8 = ^ {$IFDEF LARGEINT}HugeUInt64Array{$ELSE .SMALLINT}HugeTPointArray{$ENDIF};
var
  Item1: Byte;
  Item2: Word;
  Item4: Cardinal;
  {$IFDEF LARGEINT}
  Item8: UInt64;
  {$ELSE .SMALLINT}
  Item8Low: Cardinal;
  Item8High, Buffer8High: Cardinal;
  {$ENDIF}
  Left, Right, Middle: NativeInt;
begin
  case SizeOf(T) of
    1: Byte(Item1) := PByte(Item)^;
    2: Word(Item2) := PWord(Item)^;
    4: Integer(Item4) := PInteger(Item)^;
  else
    {$IFDEF LARGEINT}
    Int64(Item8) := PInt64(Item)^;
    {$ELSE .SMALLINT}
    Item8Low := PPoint(Item).X;
    Item8High := PPoint(Item).Y;
    {$ENDIF}
  end;

  Middle := -1;
  Right := Count + (-1);
  repeat
    Left := Middle + 1;
    if (Middle >= Right) then
      Break;

    middle_init:
    Middle := Right;
    Dec(Middle, Left);
    Middle := Left + (Middle shr 1);

    case SizeOf(T) of
      1: if (PArray1(Values)[Middle] > Item1) then
          Continue;
      2: if (PArray2(Values)[Middle] > Item2) then
          Continue;
      4: if (PArray4(Values)[Middle] > Item4) then
          Continue;
    else
      {$IFDEF LARGEINT}
      if (PArray8(Values)[Middle] > Item8) then
        Continue;
      {$ELSE .SMALLINT}
      Inc(NativeUInt(Values), SizeOf(Integer));
      Buffer8High := PArray8(Values)[Middle].X;
      Dec(NativeUInt(Values), SizeOf(Integer));
      if (Buffer8High > Item8High) then
        Continue;
      if (Buffer8High = Item8High) then
      begin
        if (Cardinal(PArray8(Values)[Middle].X) > Item8Low) then
          Continue;
      end;
      {$ENDIF}
    end;

    Right := Middle + (-1);
    if (not (Left > Right)) then
      goto middle_init;
    Break;
  until (False);

  if (Left < Count) then
  begin
    case SizeOf(T) of
      1: if (PArray1(Values)[Left] <> Item1) then
          goto not_found;
      2: if (PArray2(Values)[Left] <> Item2) then
          goto not_found;
      4: if (PArray4(Values)[Left] <> Item4) then
          goto not_found;
    else
      {$IFDEF LARGEINT}
      if (PArray8(Values)[Left] <> Item8) then
        goto not_found;
      {$ELSE .SMALLINT}
      Inc(NativeUInt(Values), SizeOf(Integer));
      Dec(Item8High, PArray8(Values)[Left].X);
      Dec(NativeUInt(Values), SizeOf(Integer));
      Buffer8High := PArray8(Values)[Left].X;
      Dec(Buffer8High, Item8Low);
      if (Buffer8High or Item8High <> 0) then
        goto not_found;
      {$ENDIF}
    end;
  end
  else
  begin
    not_found:
    Left := not Left;
  end;

  Result := Left;
end;
{$WARNINGS ON}

{$WARNINGS OFF} // compiler can't identify variable initialization in case statement

class function TArray.SearchFloats<T>(Values: Pointer; Count: NativeInt; Item: Pointer): NativeInt;
label
  middle_init, not_found;
type
  PArray4 = ^HugeSingleArray;
  PArray8 = ^HugeDoubleArray;
  PArrayE = ^HugeExtendedArray;
var
  Item4: {$IFDEF CPUX86}Extended{$ELSE}Single{$ENDIF};
  Item8: {$IFDEF CPUX86}Extended{$ELSE}Double{$ENDIF};
  ItemE: Extended;
  Left, Right, Middle: NativeInt;
begin
  case SizeOf(T) of
    4: Item4 := PSingle(Item)^;
    8: Item8 := PDouble(Item)^;
  else
    ItemE := PExtended(Item)^;
  end;

  Middle := -1;
  Right := Count + (-1);
  repeat
    Inc(Middle);
    Left := Middle;
    if (Middle > Right) then
      Break;

    middle_init:
    Middle := Right;
    Dec(Middle, Left);
    Middle := Left + (Middle shr 1);

    case SizeOf(T) of
      4: if (PArray4(Values)[Middle] < Item4) then
          Continue;
      8: if (PArray8(Values)[Middle] < Item8) then
          Continue;
    else
      if (PArrayE(Values)[Middle] < ItemE) then
        Continue;
    end;

    Right := Middle + (-1);
    if (not (Left > Right)) then
      goto middle_init;
    Break;
  until (False);

  if (Left < Count) then
  begin
    case SizeOf(T) of
      4: if (PArray4(Values)[Left] <> Item4) then
          goto not_found;
      8: if (PArray8(Values)[Left] <> Item8) then
          goto not_found;
    else
      if (PArrayE(Values)[Left] <> ItemE) then
        goto not_found;
    end;
  end
  else if (Left >= Count) then
  begin
    not_found:
    Left := not Left;
  end;

  Result := Left;
end;
{$WARNINGS ON}

{$WARNINGS OFF} // compiler can't identify variable initialization in case statement

class function TArray.SearchDescendingFloats<T>(Values: Pointer; Count: NativeInt; Item: Pointer): NativeInt;
label
  middle_init, not_found;
type
  PArray4 = ^HugeSingleArray;
  PArray8 = ^HugeDoubleArray;
  PArrayE = ^HugeExtendedArray;
var
  Item4: {$IFDEF CPUX86}Extended{$ELSE}Single{$ENDIF};
  Item8: {$IFDEF CPUX86}Extended{$ELSE}Double{$ENDIF};
  ItemE: Extended;
  Left, Right, Middle: NativeInt;
begin
  case SizeOf(T) of
    4: Item4 := PSingle(Item)^;
    8: Item8 := PDouble(Item)^;
  else
    ItemE := PExtended(Item)^;
  end;

  Middle := -1;
  Right := Count + (-1);
  repeat
    Inc(Middle);
    Left := Middle;
    if (Middle > Right) then
      Break;

    middle_init:
    Middle := Right;
    Dec(Middle, Left);
    Middle := Left + (Middle shr 1);

    case SizeOf(T) of
      4: if (PArray4(Values)[Middle] > Item4) then
          Continue;
      8: if (PArray8(Values)[Middle] > Item8) then
          Continue;
    else
      if (PArrayE(Values)[Middle] > ItemE) then
        Continue;
    end;

    Right := Middle + (-1);
    if (not (Left > Right)) then
      goto middle_init;
    Break;
  until (False);

  if (Left < Count) then
  begin
    case SizeOf(T) of
      4: if (PArray4(Values)[Left] <> Item4) then
          goto not_found;
      8: if (PArray8(Values)[Left] <> Item8) then
          goto not_found;
    else
      if (PArrayE(Values)[Left] <> ItemE) then
        goto not_found;
    end;
  end
  else if (Left >= Count) then
  begin
    not_found:
    Left := not Left;
  end;

  Result := Left;
end;
{$WARNINGS ON}

class function TArray.SearchBinaries<T>(Values: Pointer; Count: NativeInt; const Item: T): NativeInt;
label
  middle_init, not_found;
var
  Left, Right, Middle: NativeInt;
  X, Y: NativeUInt;
  BufferMiddle, BufferLeft: Pointer;
  Cmp: Integer;
  Stored: TInternalSearchStored;
begin
  Middle := -1;
  Right := Count + (-1);
  X := TArray.SortBinaryMarker<T>(@Item);
  Stored.X := X;
  if (GetTypeKind(T) in [tkMethod, tkLString, tkWString, tkUString, tkDynArray]) then
  begin
    Stored.ItemPtr := PPointer(@Item)^;
  end;
  repeat
    Left := Middle + 1;
    if (Middle >= Right) then
      Break;

    middle_init:
    Middle := Right;
    Dec(Middle, Left);
    Middle := Left + (Middle shr 1);

    case GetTypeKind(T) of
      tkMethod:
        begin
          Y := Middle;
          Y := Y shl {$IFDEF LARGEINT}4{$ELSE .SMALLINT}3{$ENDIF};
          Inc(Y, NativeUInt(Values));
          Y := NativeUInt(PMethod(Y).Data);
        end;
      tkLString, tkWString, tkUString, tkDynArray:
        begin
          Y := PNativeUInt(TRAIIHelper<T>.P(Values) + Middle)^;
          if (Y <> 0) then
            case GetTypeKind(T) of
              tkLString:
                begin
                  Y := PWord(Y)^;
                  Y := Swap(Y);
                end;
              {$IFDEF MSWINDOWS}
              tkWString:
                begin
                  Dec(Y, SizeOf(Integer));
                  if (PInteger(Y)^ = 0) then
                  begin
                    Y := 0;
                  end
                  else
                  begin
                    Inc(Y, SizeOf(Integer));
                    Y := PCardinal(Y)^;
                    Y := Cardinal((Y shl 16) + (Y shr 16));
                  end;
                end;
              {$ELSE}
              tkWString,
                {$ENDIF}
              tkUString:
                begin
                  Y := PCardinal(Y)^;
                  Y := Cardinal((Y shl 16) + (Y shr 16));
                end;
              tkDynArray:
                begin
                  Y := PByte(Y)^;
                end;
            end;
        end;
    else
      Y := TArray.SortBinaryMarker<T>(TRAIIHelper<T>.P(Values) + Middle);
    end;

    if (Y < X) then
      Continue;
    if (Y = X) then
    begin
      if (GetTypeKind(T) = tkMethod) then
      begin
        Y := Middle;
        Y := Y shl {$IFDEF LARGEINT}4{$ELSE .SMALLINT}3{$ENDIF};
        Inc(Y, NativeInt(Values));
        Y := NativeUInt(PMethod(Y).Data);
        if (Y < NativeUInt(Stored.ItemPtr)) then
          Continue;
      end
      else
      begin
        if (GetTypeKind(T) = tkString) then
        begin
          Cmp := InterfaceDefaults.Compare_OStr(nil, Pointer(TRAIIHelper<T>.P(Values) + Middle), Pointer(@Item));
        end
        else if (GetTypeKind(T) in [tkLString, tkWString, tkUString, tkDynArray]) then
        begin
          BufferMiddle := PPointer(TRAIIHelper<T>.P(Values) + Middle)^;
          Cmp := 0;
          if (BufferMiddle <> Stored.ItemPtr) then
          begin
            case GetTypeKind(T) of
              tkLString: Cmp := InterfaceDefaults.Compare_LStr(nil, BufferMiddle, Stored.ItemPtr);
              {$IFDEF MSWINDOWS}
              tkWString: Cmp := InterfaceDefaults.Compare_WStr(nil, BufferMiddle, Stored.ItemPtr);
              {$ELSE}
              tkWString,
                {$ENDIF}
              tkUString: Cmp := InterfaceDefaults.Compare_UStr(nil, BufferMiddle, Stored.ItemPtr);
              tkDynArray: Cmp := InterfaceDefaults.Compare_Dyn(InterfaceDefaults.TDefaultComparer<T>.Instance,
                BufferMiddle, Stored.ItemPtr);
            end;
          end;
        end
        else
          case SizeOf(T) of
            0..SizeOf(Cardinal): Cmp := 0;
            {$IFDEF LARGEINT}
            SizeOf(Int64): Cmp := InterfaceDefaults.Compare_Bin8(nil, PInt64(TRAIIHelper<T>.P(Values) + Middle)^,
              PInt64(@Item)^);
            {$ENDIF}
          else
            Cmp := InterfaceDefaults.Compare_Bin(InterfaceDefaults.TDefaultComparer<T>.Instance,
              Pointer(TRAIIHelper<T>.P(Values) + Middle), Pointer(@Item));
          end;

        X := Stored.X;
        if (Cmp < 0) then
          Continue;
      end;
    end;

    Right := Middle + (-1);
    if (not (Left > Right)) then
      goto middle_init;
    Break;
  until (False);

  if (Left < Count) then
  begin
    BufferLeft := TRAIIHelper<T>.P(Values) + Left;
    Y := TArray.SortBinaryMarker<T>(BufferLeft);
    if (Y <> X) then
      goto not_found;
    if (GetTypeKind(T) = tkMethod) then
    begin
      if (PNativeUInt(BufferLeft)^ <> NativeUInt(Stored.ItemPtr)) then
        goto not_found;
    end
    else
    begin
      if (GetTypeKind(T) = tkString) then
      begin
        Cmp := InterfaceDefaults.Compare_OStr(nil, BufferLeft, Pointer(@Item));
      end
      else if (GetTypeKind(T) in [tkLString, tkWString, tkUString, tkDynArray]) then
      begin
        BufferLeft := PPointer(BufferLeft)^;
        Cmp := 0;
        if (BufferLeft <> Stored.ItemPtr) then
        begin
          case GetTypeKind(T) of
            tkLString: Cmp := InterfaceDefaults.Compare_LStr(nil, BufferLeft, Stored.ItemPtr);
            {$IFDEF MSWINDOWS}
            tkWString: Cmp := InterfaceDefaults.Compare_WStr(nil, BufferLeft, Stored.ItemPtr);
            {$ELSE}
            tkWString,
              {$ENDIF}
            tkUString: Cmp := InterfaceDefaults.Compare_UStr(nil, BufferLeft, Stored.ItemPtr);
            tkDynArray: Cmp := InterfaceDefaults.Compare_Dyn(InterfaceDefaults.TDefaultComparer<T>.Instance,
              BufferLeft, Stored.ItemPtr);
          end;
        end;
      end
      else
        case SizeOf(T) of
          0..SizeOf(Cardinal): Cmp := 0;
          {$IFDEF LARGEINT}
          SizeOf(Int64): Cmp := InterfaceDefaults.Compare_Bin8(nil, PInt64(BufferLeft)^, PInt64(@Item)^);
          {$ENDIF}
        else
          Cmp := InterfaceDefaults.Compare_Bin(InterfaceDefaults.TDefaultComparer<T>.Instance, BufferLeft,
            Pointer(@Item));
        end;

      if (Cmp <> 0) then
        goto not_found;
    end;
  end
  else
  begin
    not_found:
    Left := not Left;
  end;

  Result := Left;
end;

class function TArray.SearchDescendingBinaries<T>(Values: Pointer; Count: NativeInt; const Item: T): NativeInt;
label
  middle_init, not_found;
var
  Left, Right, Middle: NativeInt;
  X, Y: NativeUInt;
  BufferMiddle, BufferLeft: Pointer;
  Cmp: Integer;
  Stored: TInternalSearchStored;
begin
  Middle := -1;
  Right := Count + (-1);
  X := TArray.SortBinaryMarker<T>(@Item);
  Stored.X := X;
  if (GetTypeKind(T) in [tkMethod, tkLString, tkWString, tkUString, tkDynArray]) then
  begin
    Stored.ItemPtr := PPointer(@Item)^;
  end;
  repeat
    Left := Middle + 1;
    if (Middle >= Right) then
      Break;

    middle_init:
    Middle := Right;
    Dec(Middle, Left);
    Middle := Left + (Middle shr 1);

    case GetTypeKind(T) of
      tkMethod:
        begin
          Y := Middle;
          Y := Y shl {$IFDEF LARGEINT}4{$ELSE .SMALLINT}3{$ENDIF};
          Inc(Y, NativeUInt(Values));
          Y := NativeUInt(PMethod(Y).Data);
        end;
      tkLString, tkWString, tkUString, tkDynArray:
        begin
          Y := PNativeUInt(TRAIIHelper<T>.P(Values) + Middle)^;
          if (Y <> 0) then
            case GetTypeKind(T) of
              tkLString:
                begin
                  Y := PWord(Y)^;
                  Y := Swap(Y);
                end;
              {$IFDEF MSWINDOWS}
              tkWString:
                begin
                  Dec(Y, SizeOf(Integer));
                  if (PInteger(Y)^ = 0) then
                  begin
                    Y := 0;
                  end
                  else
                  begin
                    Inc(Y, SizeOf(Integer));
                    Y := PCardinal(Y)^;
                    Y := Cardinal((Y shl 16) + (Y shr 16));
                  end;
                end;
              {$ELSE}
              tkWString,
                {$ENDIF}
              tkUString:
                begin
                  Y := PCardinal(Y)^;
                  Y := Cardinal((Y shl 16) + (Y shr 16));
                end;
              tkDynArray:
                begin
                  Y := PByte(Y)^;
                end;
            end;
        end;
    else
      Y := TArray.SortBinaryMarker<T>(TRAIIHelper<T>.P(Values) + Middle);
    end;

    if (Y > X) then
      Continue;
    if (Y = X) then
    begin
      if (GetTypeKind(T) = tkMethod) then
      begin
        Y := Middle;
        Y := Y shl {$IFDEF LARGEINT}4{$ELSE .SMALLINT}3{$ENDIF};
        Inc(Y, NativeInt(Values));
        Y := NativeUInt(PMethod(Y).Data);
        if (Y > NativeUInt(Stored.ItemPtr)) then
          Continue;
      end
      else
      begin
        if (GetTypeKind(T) = tkString) then
        begin
          Cmp := InterfaceDefaults.Compare_OStr(nil, Pointer(TRAIIHelper<T>.P(Values) + Middle), Pointer(@Item));
        end
        else if (GetTypeKind(T) in [tkLString, tkWString, tkUString, tkDynArray]) then
        begin
          BufferMiddle := PPointer(TRAIIHelper<T>.P(Values) + Middle)^;
          Cmp := 0;
          if (BufferMiddle <> Stored.ItemPtr) then
          begin
            case GetTypeKind(T) of
              tkLString: Cmp := InterfaceDefaults.Compare_LStr(nil, BufferMiddle, Stored.ItemPtr);
              {$IFDEF MSWINDOWS}
              tkWString: Cmp := InterfaceDefaults.Compare_WStr(nil, BufferMiddle, Stored.ItemPtr);
              {$ELSE}
              tkWString,
                {$ENDIF}
              tkUString: Cmp := InterfaceDefaults.Compare_UStr(nil, BufferMiddle, Stored.ItemPtr);
              tkDynArray: Cmp := InterfaceDefaults.Compare_Dyn(InterfaceDefaults.TDefaultComparer<T>.Instance,
                BufferMiddle, Stored.ItemPtr);
            end;
          end;
        end
        else
          case SizeOf(T) of
            0..SizeOf(Cardinal): Cmp := 0;
            {$IFDEF LARGEINT}
            SizeOf(Int64): Cmp := InterfaceDefaults.Compare_Bin8(nil, PInt64(TRAIIHelper<T>.P(Values) + Middle)^,
              PInt64(@Item)^);
            {$ENDIF}
          else
            Cmp := InterfaceDefaults.Compare_Bin(InterfaceDefaults.TDefaultComparer<T>.Instance,
              Pointer(TRAIIHelper<T>.P(Values) + Middle), Pointer(@Item));
          end;

        X := Stored.X;
        if (Cmp > 0) then
          Continue;
      end;
    end;

    Right := Middle + (-1);
    if (not (Left > Right)) then
      goto middle_init;
    Break;
  until (False);

  if (Left < Count) then
  begin
    BufferLeft := TRAIIHelper<T>.P(Values) + Left;
    Y := TArray.SortBinaryMarker<T>(BufferLeft);
    if (Y <> X) then
      goto not_found;
    if (GetTypeKind(T) = tkMethod) then
    begin
      if (PNativeUInt(BufferLeft)^ <> NativeUInt(Stored.ItemPtr)) then
        goto not_found;
    end
    else
    begin
      if (GetTypeKind(T) = tkString) then
      begin
        Cmp := InterfaceDefaults.Compare_OStr(nil, BufferLeft, Pointer(@Item));
      end
      else if (GetTypeKind(T) in [tkLString, tkWString, tkUString, tkDynArray]) then
      begin
        BufferLeft := PPointer(BufferLeft)^;
        Cmp := 0;
        if (BufferLeft <> Stored.ItemPtr) then
        begin
          case GetTypeKind(T) of
            tkLString: Cmp := InterfaceDefaults.Compare_LStr(nil, BufferLeft, Stored.ItemPtr);
            {$IFDEF MSWINDOWS}
            tkWString: Cmp := InterfaceDefaults.Compare_WStr(nil, BufferLeft, Stored.ItemPtr);
            {$ELSE}
            tkWString,
              {$ENDIF}
            tkUString: Cmp := InterfaceDefaults.Compare_UStr(nil, BufferLeft, Stored.ItemPtr);
            tkDynArray: Cmp := InterfaceDefaults.Compare_Dyn(InterfaceDefaults.TDefaultComparer<T>.Instance,
              BufferLeft, Stored.ItemPtr);
          end;
        end;
      end
      else
        case SizeOf(T) of
          0..SizeOf(Cardinal): Cmp := 0;
          {$IFDEF LARGEINT}
          SizeOf(Int64): Cmp := InterfaceDefaults.Compare_Bin8(nil, PInt64(BufferLeft)^, PInt64(@Item)^);
          {$ENDIF}
        else
          Cmp := InterfaceDefaults.Compare_Bin(InterfaceDefaults.TDefaultComparer<T>.Instance, BufferLeft,
            Pointer(@Item));
        end;

      if (Cmp <> 0) then
        goto not_found;
    end;
  end
  else
  begin
    not_found:
    Left := not Left;
  end;

  Result := Left;
end;

class function TArray.SearchUniversals<T>(Values: Pointer; const helper: TSearchHelper; const Item: T): NativeInt;
label
  middle_init;
var
  Left, Right, Middle: NativeInt;
  Stored: TInternalSearchStored<T>;
begin
  Stored.Inst := helper.Comparer;
  Stored.Compare := PPointer(PNativeUInt(Stored.Inst)^ + 3 * SizeOf(Pointer))^;
  Stored.Count := helper.Count;

  Middle := -1;
  Right := Stored.Count + (-1);
  repeat
    Left := Middle + 1;
    if (Middle >= Right) then
      Break;

    middle_init:
    Middle := Right;
    Dec(Middle, Left);
    Middle := Left + (Middle shr 1);

    if (Stored.Compare(Stored.Inst, TRAIIHelper<T>.PArrayT(Values)[Middle], Item) < 0) then
      Continue;

    Right := Middle + (-1);
    if (not (Left > Right)) then
    begin
      goto middle_init;
    end
    else
    begin
      Break;
    end;
  until (False);

  if (Left >= Stored.Count) or
    (Stored.Compare(Stored.Inst, TRAIIHelper<T>.PArrayT(Values)[Left], Item) <> 0) then
  begin
    Left := not Left;
  end;

  Result := Left;
end;

class function TArray.SearchDescendingUniversals<T>(Values: Pointer; const helper: TSearchHelper; const Item: T):
  NativeInt;
label
  middle_init;
var
  Left, Right, Middle: NativeInt;
  Stored: TInternalSearchStored<T>;
begin
  Stored.Inst := helper.Comparer;
  Stored.Compare := PPointer(PNativeUInt(Stored.Inst)^ + 3 * SizeOf(Pointer))^;
  Stored.Count := helper.Count;

  Middle := -1;
  Right := Stored.Count + (-1);
  repeat
    Left := Middle + 1;
    if (Middle >= Right) then
      Break;

    middle_init:
    Middle := Right;
    Dec(Middle, Left);
    Middle := Left + (Middle shr 1);

    if (Stored.Compare(Stored.Inst, TRAIIHelper<T>.PArrayT(Values)[Middle], Item) > 0) then
      Continue;

    Right := Middle + (-1);
    if (not (Left > Right)) then
    begin
      goto middle_init;
    end
    else
    begin
      Break;
    end;
  until (False);

  if (Left >= Stored.Count) or
    (Stored.Compare(Stored.Inst, TRAIIHelper<T>.PArrayT(Values)[Left], Item) <> 0) then
  begin
    Left := not Left;
  end;

  Result := Left;
end;

class function TArray.InternalSearch<T>(Values: Pointer; Index, Count: Integer; const Item: T;
  out FoundIndex: Integer): Boolean;
var
  I: Integer;
  helper: TSearchHelper;
  TypeData: PTypeData;
begin
  if (Count <= 0) then
  begin
    if (Count = 0) then
    begin
      FoundIndex := Index;
      Result := False;
      Exit;
    end
    else
    begin
      ErrorArgumentOutOfRange;
    end;
  end;

  if (GetTypeKind(T) in [tkInteger, tkEnumeration, tkChar, tkWChar, tkInt64]) or
    ((GetTypeKind(T) = tkFloat) and (SizeOf(T) = 8)) then
  begin
    TypeData := Pointer(TypeInfo(T));
    Inc(NativeUInt(TypeData), NativeUInt(PByte(@PTypeInfo(TypeData).Name)^) + 2);
  end
  else
    TypeData := nil; // satisfy compiler

  I := -1; // satisfy compiler
  case GetTypeKind(T) of
    tkInteger, tkEnumeration, tkChar, tkWChar:
      case SizeOf(T) of
        1:
          begin
            case TypeData.OrdType of
              otSByte: I := SearchSigneds<ShortInt>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
              otUByte: I := SearchUnsigneds<Byte>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
            end;
          end;
        2:
          begin
            case TypeData.OrdType of
              otSWord: I := SearchSigneds<SmallInt>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
              otUWord: I := SearchUnsigneds<Word>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
            end;
          end;
        4:
          begin
            case TypeData.OrdType of
              otSLong: I := SearchSigneds<Integer>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
              otULong: I := SearchUnsigneds<Cardinal>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
            end;
          end;
      end;
    tkInt64:
      begin
        if (TypeData.MaxInt64Value > TypeData.MinInt64Value) then
        begin
          I := SearchSigneds<Int64>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
        end
        else
        begin
          I := SearchUnsigneds<UInt64>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
        end;
      end;
    tkClass, tkInterface, tkClassRef, tkPointer, tkProcedure:
      begin
        {$IFDEF LARGEINT}
        I := SearchUnsigneds<UInt64>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
        {$ELSE .SMALLINT}
        I := SearchUnsigneds<Cardinal>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
        {$ENDIF}
      end;
    tkFloat:
      case SizeOf(T) of
        4: I := SearchFloats<Single>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
        10: I := SearchFloats<Extended>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
      else
        if (TypeData.FloatType = ftDouble) then
        begin
          I := SearchFloats<Double>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
        end
        else
        begin
          I := SearchSigneds<Int64>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
        end;
      end;
    tkVariant:
      begin
        helper.Count := Count;
        helper.Comparer := Pointer(@InterfaceDefaults.TDefaultComparer<Variant>.Instance);
        I := SearchUniversals<T>(TRAIIHelper<T>.P(Values) + Index, helper, Item);
      end;
    tkMethod:
      begin
        I := SearchBinaries < InterfaceDefaults.TMethodPtr > (TRAIIHelper<T>.P(Values) + Index, Count,
          InterfaceDefaults.TMethodPtr(Pointer(@Item)^));
      end;
    tkString:
      begin
        I := SearchBinaries<T>(TRAIIHelper<T>.P(Values) + Index, Count, Item);
      end;
    tkLString:
      begin
        {$IFDEF ANSISTRSUPPORT}
        I := SearchBinaries<AnsiString>(TRAIIHelper<T>.P(Values) + Index, Count, AnsiString(Pointer(@Item)^));
        {$ELSE}
        I := SearchBinaries<T>(TRAIIHelper<T>.P(Values) + Index, Count, Item);
        {$ENDIF}
      end;
    {$IFDEF MSWINDOWS}
    tkWString:
      begin
        I := SearchBinaries<WideString>(TRAIIHelper<T>.P(Values) + Index, Count, WideString(Pointer(@Item)^));
      end;
    {$ELSE}
    tkWString,
      {$ENDIF}
    tkUString:
      begin
        I := SearchBinaries<UnicodeString>(TRAIIHelper<T>.P(Values) + Index, Count, UnicodeString(Pointer(@Item)^));
      end;
    tkDynArray:
      begin
        I := SearchBinaries<T>(TRAIIHelper<T>.P(Values) + Index, Count, Item);
      end;
  else
    // binary
    I := SearchBinaries<T>(TRAIIHelper<T>.P(Values) + Index, Count, Item);
  end;

  if (I < 0) then
  begin
    FoundIndex := Index + (not I);
    Result := False;
  end
  else
  begin
    FoundIndex := Index + I;
    Result := True;
  end;
end;

class function TArray.InternalSearch<T>(Values: Pointer; Index, Count: Integer; const Item: T;
  out FoundIndex: Integer; Comparer: Pointer): Boolean;
var
  I: Integer;
  helper: TSearchHelper;
begin
  if (Count <= 0) then
  begin
    if (Count = 0) then
    begin
      FoundIndex := Index;
      Result := False;
      Exit;
    end
    else
    begin
      ErrorArgumentOutOfRange;
    end;
  end;

  helper.Count := Count;
  helper.Comparer := Comparer;
  I := TArray.SearchUniversals<T>(TRAIIHelper<T>.P(Values) + Index, helper, Item);
  if (I < 0) then
  begin
    FoundIndex := Index + (not I);
    Result := False;
  end
  else
  begin
    FoundIndex := Index + I;
    Result := True;
  end;
end;

class function TArray.BinarySearch<T>(var Values: T; const Item: T;
  out FoundIndex: Integer; Count: Integer): Boolean;
begin
  Result := TArray.InternalSearch<T>(@Values, 0, Count, Item, FoundIndex);
end;

class function TArray.BinarySearch<T>(const Values: array of T; const Item: T;
  out FoundIndex: Integer): Boolean;
begin
  Result := TArray.InternalSearch<T>(@Values[0], 0, Length(Values), Item, FoundIndex);
end;

class function TArray.BinarySearch<T>(const Values: array of T; const Item: T;
  out FoundIndex: Integer; Index, Count: Integer): Boolean;
begin
  if (Index < Low(Values)) or ((Index > High(Values)) and (Count > 0))
    or (Index + Count - 1 > High(Values)) {or (Count < 0)}
    or (Index + Count < 0) then
    ErrorArgumentOutOfRange;

  Result := TArray.InternalSearch<T>(@Values[0], Index, Count, Item, FoundIndex);
end;

class function TArray.BinarySearch<T>(var Values: T; const Item: T;
  out FoundIndex: Integer; Count: Integer; const Comparer: IComparer<T>): Boolean;
begin
  Result := TArray.InternalSearch<T>(@Values, 0, Count, Item, FoundIndex, Pointer(Comparer));
end;

class function TArray.BinarySearch<T>(const Values: array of T; const Item: T;
  out FoundIndex: Integer; const Comparer: IComparer<T>): Boolean;
begin
  Result := TArray.InternalSearch<T>(@Values[0], 0, Length(Values), Item, FoundIndex, Pointer(Comparer));
end;

class function TArray.BinarySearch<T>(const Values: array of T; const Item: T;
  out FoundIndex: Integer; const Comparer: IComparer<T>; Index, Count: Integer): Boolean;
begin
  if (Index < Low(Values)) or ((Index > High(Values)) and (Count > 0))
    or (Index + Count - 1 > High(Values)) {or (Count < 0)}
    or (Index + Count < 0) then
    ErrorArgumentOutOfRange;

  Result := TArray.InternalSearch<T>(@Values[0], Index, Count, Item, FoundIndex, Pointer(Comparer));
end;

class function TArray.BinarySearch<T>(var Values: T; const Item: T;
  out FoundIndex: Integer; Count: Integer; const Comparison: TComparison<T>): Boolean;
begin
  Result := TArray.InternalSearch<T>(@Values, 0, Count, Item, FoundIndex, PPointer(@Comparison)^);
end;

class function TArray.BinarySearch<T>(const Values: array of T; const Item: T;
  out FoundIndex: Integer; const Comparison: TComparison<T>): Boolean;
begin
  Result := TArray.InternalSearch<T>(@Values[0], 0, Length(Values), Item, FoundIndex, PPointer(@Comparison)^);
end;

class function TArray.BinarySearch<T>(const Values: array of T; const Item: T;
  out FoundIndex: Integer; Index, Count: Integer; const Comparison: TComparison<T>): Boolean;
begin
  if (Index < Low(Values)) or ((Index > High(Values)) and (Count > 0))
    or (Index + Count - 1 > High(Values)) {or (Count < 0)}
    or (Index + Count < 0) then
    ErrorArgumentOutOfRange;

  Result := TArray.InternalSearch<T>(@Values[0], Index, Count, Item, FoundIndex, PPointer(@Comparison)^);
end;

class function TArray.InternalSearchDescending<T>(Values: Pointer; Index, Count: Integer; const Item: T;
  out FoundIndex: Integer): Boolean;
var
  I: Integer;
  helper: TSearchHelper;
  TypeData: PTypeData;
begin
  if (Count <= 0) then
  begin
    if (Count = 0) then
    begin
      FoundIndex := Index;
      Result := False;
      Exit;
    end
    else
    begin
      ErrorArgumentOutOfRange;
    end;
  end;

  if (GetTypeKind(T) in [tkInteger, tkEnumeration, tkChar, tkWChar, tkInt64]) or
    ((GetTypeKind(T) = tkFloat) and (SizeOf(T) = 8)) then
  begin
    TypeData := Pointer(TypeInfo(T));
    Inc(NativeUInt(TypeData), NativeUInt(PByte(@PTypeInfo(TypeData).Name)^) + 2);
  end
  else
    TypeData := nil; // satisfy compiler

  I := 01;
  case GetTypeKind(T) of
    tkInteger, tkEnumeration, tkChar, tkWChar:
      case SizeOf(T) of
        1:
          begin
            case TypeData.OrdType of
              otSByte: I := SearchDescendingSigneds<ShortInt>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
              otUByte: I := SearchDescendingUnsigneds<Byte>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
            end;
          end;
        2:
          begin
            case TypeData.OrdType of
              otSWord: I := SearchDescendingSigneds<SmallInt>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
              otUWord: I := SearchDescendingUnsigneds<Word>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
            end;
          end;
        4:
          begin
            case TypeData.OrdType of
              otSLong: I := SearchDescendingSigneds<Integer>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
              otULong: I := SearchDescendingUnsigneds<Cardinal>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
            end;
          end;
      end;
    tkInt64:
      begin
        if (TypeData.MaxInt64Value > TypeData.MinInt64Value) then
        begin
          I := SearchDescendingSigneds<Int64>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
        end
        else
        begin
          I := SearchDescendingUnsigneds<UInt64>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
        end;
      end;
    tkClass, tkInterface, tkClassRef, tkPointer, tkProcedure:
      begin
        {$IFDEF LARGEINT}
        I := SearchDescendingUnsigneds<UInt64>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
        {$ELSE .SMALLINT}
        I := SearchDescendingUnsigneds<Cardinal>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
        {$ENDIF}
      end;
    tkFloat:
      case SizeOf(T) of
        4: I := SearchDescendingFloats<Single>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
        10: I := SearchDescendingFloats<Extended>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
      else
        if (TypeData.FloatType = ftDouble) then
        begin
          I := SearchDescendingFloats<Double>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
        end
        else
        begin
          I := SearchDescendingSigneds<Int64>(TRAIIHelper<T>.P(Values) + Index, Count, @Item);
        end;
      end;
    tkVariant:
      begin
        helper.Count := Count;
        helper.Comparer := Pointer(@InterfaceDefaults.TDefaultComparer<Variant>.Instance);
        I := SearchDescendingUniversals<T>(TRAIIHelper<T>.P(Values) + Index, helper, Item);
      end;
    tkMethod:
      begin
        I := SearchDescendingBinaries < InterfaceDefaults.TMethodPtr > (TRAIIHelper<T>.P(Values) + Index, Count,
          InterfaceDefaults.TMethodPtr(Pointer(@Item)^));
      end;
    tkString:
      begin
        I := SearchDescendingBinaries<T>(TRAIIHelper<T>.P(Values) + Index, Count, Item);
      end;
    tkLString:
      begin
        {$IFDEF ANSISTRSUPPORT}
        I := SearchDescendingBinaries<AnsiString>(TRAIIHelper<T>.P(Values) + Index, Count,
          AnsiString(Pointer(@Item)^));
        {$ELSE}
        I := SearchDescendingBinaries<T>(TRAIIHelper<T>.P(Values) + Index, Count, Item);
        {$ENDIF}
      end;
    {$IFDEF MSWINDOWS}
    tkWString:
      begin
        I := SearchDescendingBinaries<WideString>(TRAIIHelper<T>.P(Values) + Index, Count,
          WideString(Pointer(@Item)^));
      end;
    {$ELSE}
    tkWString,
      {$ENDIF}
    tkUString:
      begin
        I := SearchDescendingBinaries<UnicodeString>(TRAIIHelper<T>.P(Values) + Index, Count,
          UnicodeString(Pointer(@Item)^));
      end;
    tkDynArray:
      begin
        I := SearchDescendingBinaries<T>(TRAIIHelper<T>.P(Values) + Index, Count, Item);
      end;
  else
    // binary
    I := SearchDescendingBinaries<T>(TRAIIHelper<T>.P(Values) + Index, Count, Item);
  end;

  if (I < 0) then
  begin
    FoundIndex := Index + (not I);
    Result := False;
  end
  else
  begin
    FoundIndex := Index + I;
    Result := True;
  end;
end;

class function TArray.InternalSearchDescending<T>(Values: Pointer; Index, Count: Integer; const Item: T;
  out FoundIndex: Integer; Comparer: Pointer): Boolean;
var
  I: Integer;
  helper: TSearchHelper;
begin
  if (Count <= 0) then
  begin
    if (Count = 0) then
    begin
      FoundIndex := Index;
      Result := False;
      Exit;
    end
    else
    begin
      ErrorArgumentOutOfRange;
    end;
  end;

  helper.Count := Count;
  helper.Comparer := Comparer;
  I := TArray.SearchDescendingUniversals<T>(TRAIIHelper<T>.P(Values) + Index, helper, Item);
  if (I < 0) then
  begin
    FoundIndex := Index + (not I);
    Result := False;
  end
  else
  begin
    FoundIndex := Index + I;
    Result := True;
  end;
end;

class function TArray.BinarySearchDescending<T>(var Values: T; const Item: T;
  out FoundIndex: Integer; Count: Integer): Boolean;
begin
  Result := TArray.InternalSearchDescending<T>(@Values, 0, Count, Item, FoundIndex);
end;

class function TArray.BinarySearchDescending<T>(const Values: array of T; const Item: T;
  out FoundIndex: Integer): Boolean;
begin
  Result := TArray.InternalSearchDescending<T>(@Values[0], 0, Length(Values), Item, FoundIndex);
end;

class function TArray.BinarySearchDescending<T>(const Values: array of T; const Item: T;
  out FoundIndex: Integer; Index, Count: Integer): Boolean;
begin
  if (Index < Low(Values)) or ((Index > High(Values)) and (Count > 0))
    or (Index + Count - 1 > High(Values)) {or (Count < 0)}
    or (Index + Count < 0) then
    ErrorArgumentOutOfRange;

  Result := TArray.InternalSearchDescending<T>(@Values[0], Index, Count, Item, FoundIndex);
end;

class function TArray.BinarySearchDescending<T>(var Values: T; const Item: T;
  out FoundIndex: Integer; Count: Integer; const Comparer: IComparer<T>): Boolean;
begin
  Result := TArray.InternalSearchDescending<T>(@Values, 0, Count, Item, FoundIndex, Pointer(Comparer));
end;

class function TArray.BinarySearchDescending<T>(const Values: array of T; const Item: T;
  out FoundIndex: Integer; const Comparer: IComparer<T>): Boolean;
begin
  Result := TArray.InternalSearchDescending<T>(@Values[0], 0, Length(Values), Item, FoundIndex, Pointer(Comparer));
end;

class function TArray.BinarySearchDescending<T>(const Values: array of T; const Item: T;
  out FoundIndex: Integer; const Comparer: IComparer<T>; Index, Count: Integer): Boolean;
begin
  if (Index < Low(Values)) or ((Index > High(Values)) and (Count > 0))
    or (Index + Count - 1 > High(Values)) {or (Count < 0)}
    or (Index + Count < 0) then
    ErrorArgumentOutOfRange;

  Result := TArray.InternalSearchDescending<T>(@Values[0], Index, Count, Item, FoundIndex, Pointer(Comparer));
end;

class function TArray.BinarySearchDescending<T>(var Values: T; const Item: T;
  out FoundIndex: Integer; Count: Integer; const Comparison: TComparison<T>): Boolean;
begin
  Result := TArray.InternalSearchDescending<T>(@Values, 0, Count, Item, FoundIndex, PPointer(@Comparison)^);
end;

class function TArray.BinarySearchDescending<T>(const Values: array of T; const Item: T;
  out FoundIndex: Integer; const Comparison: TComparison<T>): Boolean;
begin
  Result := TArray.InternalSearchDescending<T>(@Values[0], 0, Length(Values), Item, FoundIndex,
    PPointer(@Comparison)^);
end;

class function TArray.BinarySearchDescending<T>(const Values: array of T; const Item: T;
  out FoundIndex: Integer; Index, Count: Integer; const Comparison: TComparison<T>): Boolean;
begin
  if (Index < Low(Values)) or ((Index > High(Values)) and (Count > 0))
    or (Index + Count - 1 > High(Values)) {or (Count < 0)}
    or (Index + Count < 0) then
    ErrorArgumentOutOfRange;

  Result := TArray.InternalSearchDescending<T>(@Values[0], Index, Count, Item, FoundIndex, PPointer(@Comparison)^);
end;

class function TArray.IndexOf<T>(const Values: array of T; const Item: T): Integer;
var
  idx: Integer;
begin
  if TArray.InternalSearch<T>(@Values[0], 0, Length(Values), Item, idx) then
    Result := idx
  else
    Result := -1;
end;

class function TArray.Contains<T>(const Values: array of T; const Item: T): Boolean;
var
  dummy: Integer;
begin
  Result := TArray.InternalSearch<T>(@Values[0], 0, Length(Values), Item, dummy);
end;

{ TCollectionEnumeratorData<T> }

procedure TCollectionEnumeratorData<T>.Init(const AOwner: TObject);
begin
  Owner := AOwner;
  Tag := -1;
  Reserved := -1;
end;

{ TCollectionEnumerator<T> }

function TCollectionEnumerator<T>.MoveNext: Boolean;
begin
  Result := DoMoveNext(Data);
end;

{ TCustomDictionary<TKey,TValue>.TPairEnumerator }

function TCustomDictionary<TKey, TValue>.TPairEnumerator.MoveNext: Boolean;
var
  N: NativeInt;
  Item: PItem;
begin
  N := Data.Tag + 1;

  with TCustomDictionary<TKey, TValue>(Data.Owner) do
  begin
    if (N < FCount.Native) then
    begin
      Data.Tag := N;

      Item := @FItems[N];
      Data.Current.Key := Item.Key;
      Data.Current.Value := Item.Value;

      Exit(True);
    end;
  end;

  Result := False;
end;

{ TCustomDictionary<TKey,TValue>.TKeyEnumerator }

function TCustomDictionary<TKey, TValue>.TKeyEnumerator.MoveNext: Boolean;
var
  N: NativeInt;
begin
  N := Data.Tag + 1;

  with TCustomDictionary<TKey, TValue>(Data.Owner) do
  begin
    if (N < FCount.Native) then
    begin
      Data.Tag := N;
      Data.Current := FItems[N].Key;
      Exit(True);
    end;
  end;

  Result := False;
end;

{ TCustomDictionary<TKey,TValue>.TValueEnumerator }

function TCustomDictionary<TKey, TValue>.TValueEnumerator.MoveNext: Boolean;
var
  N: NativeInt;
begin
  N := Data.Tag + 1;

  with TCustomDictionary<TKey, TValue>(Data.Owner) do
  begin
    if (N < FCount.Native) then
    begin
      Data.Tag := N;
      Data.Current := FItems[N].Value;
      Exit(True);
    end;
  end;

  Result := False;
end;

{ TCustomDictionary<TKey,TValue>.TKeyCollection }

constructor TCustomDictionary<TKey, TValue>.TKeyCollection.Create(const ADictionary: TCustomDictionary<TKey, TValue>);
begin
  inherited Create;
  FDictionary := ADictionary;
end;

function TCustomDictionary<TKey, TValue>.TKeyCollection.DoGetCount: Integer;
begin
  Result := FDictionary.FCount.Int;
end;

function TCustomDictionary<TKey, TValue>.TKeyCollection.GetCount: Integer;
begin
  Result := FDictionary.FCount.Int;
end;

function TCustomDictionary<TKey, TValue>.TKeyCollection.DoGetEnumerator: TCollectionEnumerator<TKey>;
begin
  Result.Data.Init(Self.FDictionary);
  Pointer(@Result.DoMoveNext) := @TKeyEnumerator.MoveNext;
end;

function TCustomDictionary<TKey, TValue>.TKeyCollection.GetEnumerator: TKeyEnumerator;
begin
  Result.Data.Init(Self.FDictionary);
end;

function TCustomDictionary<TKey, TValue>.TKeyCollection.ToArray: TArray<TKey>;
var
  i, Count: NativeInt;
  Src: TCustomDictionary<TKey, TValue>.PItem;
  Dest: ^TKey;
begin
  Count := Self.FDictionary.FCount.Native;

  SetLength(Result, Count);
  Src := Pointer(FDictionary.FItems);
  Dest := Pointer(Result);
  for i := 0 to Count - 1 do
  begin
    Dest^ := Src.Key;
    Inc(Src);
    Inc(Dest);
  end;
end;

{ TCustomDictionary<TKey,TValue>.TValueCollection }

constructor TCustomDictionary<TKey, TValue>.TValueCollection.Create(const ADictionary: TCustomDictionary<TKey,
  TValue>);
begin
  inherited Create;
  FDictionary := ADictionary;
end;

function TCustomDictionary<TKey, TValue>.TValueCollection.DoGetCount: Integer;
begin
  Result := FDictionary.FCount.Int;
end;

function TCustomDictionary<TKey, TValue>.TValueCollection.GetCount: Integer;
begin
  Result := FDictionary.FCount.Int;
end;

function TCustomDictionary<TKey, TValue>.TValueCollection.DoGetEnumerator: TCollectionEnumerator<TValue>;
begin
  Result.Data.Init(Self.FDictionary);
  Pointer(@Result.DoMoveNext) := @TValueEnumerator.MoveNext;
end;

function TCustomDictionary<TKey, TValue>.TValueCollection.GetEnumerator: TValueEnumerator;
begin
  Result.Data.Init(Self.FDictionary);
end;

function TCustomDictionary<TKey, TValue>.TValueCollection.ToArray: TArray<TValue>;
var
  i, Count: NativeInt;
  Src: TCustomDictionary<TKey, TValue>.PItem;
  Dest: ^TValue;
begin
  Count := Self.FDictionary.FCount.Native;

  SetLength(Result, Count);
  Src := Pointer(FDictionary.FItems);
  Dest := Pointer(Result);
  for i := 0 to Count - 1 do
  begin
    Dest^ := Src.Value;
    Inc(Src);
    Inc(Dest);
  end;
end;

{ TCustomDictionary<TKey,TValue> }

function TCustomDictionary<TKey, TValue>.DoGetCount: Integer;
begin
  Result := FCount.Int;
end;

function TCustomDictionary<TKey, TValue>.DoGetEnumerator: TCollectionEnumerator<TPair<TKey, TValue>>;
begin
  Result.Data.Init(Self);
  Pointer(@Result.DoMoveNext) := @TPairEnumerator.MoveNext;
end;

function TCustomDictionary<TKey, TValue>.GetEnumerator: TPairEnumerator;
begin
  Result.Data.Init(Self);
end;

function TCustomDictionary<TKey, TValue>.InitKeyCollection: TKeyCollection;
begin
  FKeyCollection := TKeyCollection.Create(Self);
  {$IFNDEF AUTOREFCOUNT}
  FKeyCollection._AddRef;
  {$ENDIF}
  Result := FKeyCollection;
end;

function TCustomDictionary<TKey, TValue>.InitValueCollection: TValueCollection;
begin
  FValueCollection := TValueCollection.Create(Self);
  {$IFNDEF AUTOREFCOUNT}
  FValueCollection._AddRef;
  {$ENDIF}
  Result := FValueCollection;
end;

function TCustomDictionary<TKey, TValue>.GetKeys: TKeyCollection;
begin
  if (not Assigned(FKeyCollection)) then
  begin
    Result := InitKeyCollection;
  end
  else
  begin
    Result := FKeyCollection;
  end;
end;

function TCustomDictionary<TKey, TValue>.GetValues: TValueCollection;
begin
  if (not Assigned(FValueCollection)) then
  begin
    Result := InitValueCollection;
  end
  else
  begin
    Result := FValueCollection;
  end;
end;

function TCustomDictionary<TKey, TValue>.ToArray: TArray<TPair<TKey, TValue>>;
var
  i, Count: NativeInt;
  Src: PItem;
  Dest: ^TPair<TKey, TValue>;
begin
  Count := Self.FCount.Native;

  SetLength(Result, Count);
  Src := Pointer(FItems);
  Dest := Pointer(Result);
  for i := 0 to Count - 1 do
  begin
    Dest^.Key := Src.Key;
    Dest^.Value := Src.Value;

    Inc(Src);
    Inc(Dest);
  end;
end;

constructor TCustomDictionary<TKey, TValue>.Create(ACapacity: Integer);
begin
  inherited Create;

  FDefaultValue := Default(TValue);
  FHashTableMask := -1;
  SetNotifyMethods;

  if (ACapacity > 3) then
  begin
    SetCapacity(ACapacity);
  end
  else
  begin
    Rehash(4);
  end;
end;

class procedure TCustomDictionary<TKey, TValue>.ClearMethod(var Method);
begin
  {$IFDEF WEAKINSTREF}
  TMethod(Method).Data := nil;
  {$ENDIF}
end;

destructor TCustomDictionary<TKey, TValue>.Destroy;
begin
  Clear;
  ReallocMem(FItems, 0);
  {$IFDEF AUTOREFCOUNT}
  FKeyCollection.Free;
  FValueCollection.Free;
  {$ELSE}
  if (Assigned(FKeyCollection)) then
    FKeyCollection._Release;
  if (Assigned(FValueCollection)) then
    FValueCollection._Release;
  {$ENDIF}
  ClearMethod(FInternalKeyNotify);
  ClearMethod(FInternalValueNotify);
  ClearMethod(FInternalItemNotify);
  inherited;
end;

procedure TCustomDictionary<TKey, TValue>.Rehash(NewTableCount {power of 2}: NativeInt);
var
  NewCapacity: NativeInt;
  NewHashTable: TArray<PItem>;
  {$IFDEF WEAKREF}
  WeakItems: PItemList;
  {$ENDIF}

  i, HashTableMask, Index: NativeInt;
  Item: PItem;
  HashList: ^THashList;
begin
  // grow threshold
  NewCapacity := NewTableCount shr 1 + NewTableCount shr 2; // 75%
  if (NewCapacity < Self.FCount.Native) then
    ErrorArgumentOutOfRange;

  // reallocations
  if (NewTableCount < FHashTableMask + 1 {Length(FHashTable)}) then
  begin
    ReallocMem(FItems, NewCapacity * SizeOf(TItem));
    SetLength(FHashTable, NewTableCount);
    NewHashTable := FHashTable;
  end
  else
  begin
    SetLength(NewHashTable, NewTableCount);

    {$IFDEF WEAKREF}
    if (TRAIIHelper<TKey>.Weak) or (TRAIIHelper<TValue>.Weak) then
    begin
      GetMem(WeakItems, NewCapacity * SizeOf(TItem));

      if (FCount.Native <> 0) then
      begin
        FillChar(WeakItems^, FCount.Native * SizeOf(TItem), #0);
        System.CopyArray(WeakItems, FItems, TypeInfo(TItem), FCount.Native);
        System.FinalizeArray(FItems, TypeInfo(TItem), FCount.Native);
      end;

      FreeMem(FItems);
      FItems := WeakItems;
    end
    else
      {$ENDIF}
    begin
      ReallocMem(FItems, NewCapacity * SizeOf(TItem));
    end;
  end;

  // apply new
  FillChar(Pointer(NewHashTable)^, NewTableCount * SizeOf(Pointer), #0);
  FHashTable := NewHashTable;
  FCapacity := NewCapacity;
  FHashTableMask := NewTableCount - 1;

  // regroup items
  Item := Pointer(FItems);
  HashList := Pointer(FHashTable);
  HashTableMask := FHashTableMask;
  for i := 1 to Self.FCount.Native do
  begin
    Index := NativeInt(Cardinal(Item.HashCode)) and HashTableMask;
    Item.FNext := HashList[Index];
    HashList[Index] := Item;
    Inc(Item);
  end;
end;

procedure TCustomDictionary<TKey, TValue>.SetCapacity(ACapacity: NativeInt);
var
  Cap, NewTableCount: NativeInt;
begin
  // 75% threshold
  Cap := 3;
  if (Cap < ACapacity) then
    repeat
      Cap := Cap shl 1;
    until (Cap < 0) or (Cap >= ACapacity);

  // power of 2
  NewTableCount := (Cap and (Cap - 1)) shl 1;
  if (NewTableCount = FHashTableMask + 1 {Length(FHashTable)}) then
    Exit;
  if (NativeUInt(NewTableCount) > NativeUInt(High(Integer)) {Integer(NewTableCount) < 0}) then
    OutOfMemoryError;

  // rehash
  Rehash(NewTableCount);
end;

function TCustomDictionary<TKey, TValue>.Grow: TCustomDictionary<TKey, TValue>;
begin
  Rehash((FHashTableMask + 1) {Length(FHashTable)} * 2);
  Result := Self;
end;

procedure TCustomDictionary<TKey, TValue>.TrimExcess;
var
  Capacity: Integer;
begin
  Capacity := FCount.Int;
  SetCapacity(Capacity);
end;

procedure TCustomDictionary<TKey, TValue>.Clear;
begin
  if (FCount.Native <> 0) then
  begin
    Self.DoCleanupItems(Pointer(FItems), FCount.Native);
  end;

  FCount.Native := 0;
  if (FHashTableMask + 1 = 4) then
  begin
    FillChar(Pointer(FHashTable)^, 4 * SizeOf(Pointer), #0);
  end
  else
  begin
    Rehash(4);
  end;
end;

procedure TCustomDictionary<TKey, TValue>.DoCleanupItems(Item: PItem; Count: NativeInt);
var
  i: NativeInt;
  VType: Integer;
  StoredItem: PItem;
begin
  // Key/Value notifies (cnRemoved)
  StoredItem := Item;
  if Assigned(FInternalKeyNotify) then
  begin
    if Assigned(FInternalValueNotify) then
    begin
      // Both KeyNotify() and ValueNotify() are overriden
      if (TMethod(FInternalItemNotify).Code = @TCustomDictionary<TKey, TValue>.ItemNotifyCaller) then
      begin
        for i := 1 to Count do
        begin
          Self.KeyNotify(Item.Key, cnRemoved);
          Self.ValueNotify(Item.Value, cnRemoved);
          Inc(Item);
        end;
      end
      else
      begin
        for i := 1 to Count do
        begin
          FInternalKeyNotify(Self, Item.Key, cnRemoved);
          FInternalValueNotify(Self, Item.Value, cnRemoved);
          Inc(Item);
        end;
      end;
    end
    else
    begin
      // Key
      if (TMethod(FInternalKeyNotify).Code = @TCustomDictionary<TKey, TKey>.KeyNotifyCaller) then
      begin
        for i := 1 to Count do
        begin
          Self.KeyNotify(Item.Key, cnRemoved);
          Inc(Item);
        end;
      end
      else
      begin
        for i := 1 to Count do
        begin
          FInternalKeyNotify(Self, Item.Key, cnRemoved);
          Inc(Item);
        end;
      end;
    end;
  end
  else if Assigned(FInternalValueNotify) then
  begin
    // Value
    if (TMethod(FInternalValueNotify).Code = @TCustomDictionary<TKey, TValue>.ValueNotifyCaller) then
    begin
      for i := 1 to Count do
      begin
        Self.ValueNotify(Item.Value, cnRemoved);
        Inc(Item);
      end;
    end
    else
    begin
      for i := 1 to Count do
      begin
        FInternalValueNotify(Self, Item.Value, cnRemoved);
        Inc(Item);
      end;
    end;
  end;

  // finalize array
  Item := StoredItem;
  if (System.IsManagedType(TKey)) then
  begin
    if (System.IsManagedType(TValue)) then
    begin
      // Keys + Values
      for i := 1 to Count do
      begin
        case GetTypeKind(TKey) of
          {$IFDEF AUTOREFCOUNT}
          tkClass,
            {$ENDIF}
          tkWString, tkLString, tkUString, tkInterface, tkDynArray:
            begin
              if (PKeyRec(Item).Native <> 0) then
                case GetTypeKind(TKey) of
                  {$IFDEF AUTOREFCOUNT}
                  tkClass:
                    begin
                      TRAIIHelper.RefObjClear(@PKeyRec(Item).Native);
                    end;
                  {$ENDIF}
                  {$IFDEF MSWINDOWS}
                  tkWString:
                    begin
                      TRAIIHelper.WStrClear(@PKeyRec(Item).Native);
                    end;
                  {$ELSE}
                  tkWString,
                    {$ENDIF}
                  tkLString, tkUString:
                    begin
                      TRAIIHelper.ULStrClear(@PKeyRec(Item).Native);
                    end;
                  tkInterface:
                    begin
                      IInterface(PKeyRec(Item).Native)._Release;
                    end;
                  tkDynArray:
                    begin
                      TRAIIHelper.DynArrayClear(@PKeyRec(Item).Native, TypeInfo(TKey));
                    end;
                end;
            end;
          {$IFDEF WEAKINSTREF}
          tkMethod:
            begin
              if (PKeyRec(Item).Method.Data <> nil) then
                TRAIIHelper.WeakMethodClear(@PKeyRec(Item).Method.Data);
            end;
          {$ENDIF}
          tkVariant:
            begin
              VType := PKeyRec(Item).VarData.VType;
              if (VType and TRAIIHelper.varDeepData <> 0) then
                case VType of
                  varBoolean, varUnknown + 1..varUInt64: ;
                else
                  System.VarClear(Variant(PKeyRec(Item).VarData));
                end;
            end;
        else
          TRAIIHelper<TKey>.FOptions.ClearProc(TRAIIHelper<TKey>.FOptions, @Item.FKey);
        end;

        case GetTypeKind(TValue) of
          {$IFDEF AUTOREFCOUNT}
          tkClass,
            {$ENDIF}
          tkWString, tkLString, tkUString, tkInterface, tkDynArray:
            begin
              if (PValueRec(Item).Native <> 0) then
                case GetTypeKind(TValue) of
                  {$IFDEF AUTOREFCOUNT}
                  tkClass:
                    begin
                      TRAIIHelper.RefObjClear(@PValueRec(Item).Native);
                    end;
                  {$ENDIF}
                  {$IFDEF MSWINDOWS}
                  tkWString:
                    begin
                      TRAIIHelper.WStrClear(@PValueRec(Item).Native);
                    end;
                  {$ELSE}
                  tkWString,
                    {$ENDIF}
                  tkLString, tkUString:
                    begin
                      TRAIIHelper.ULStrClear(@PValueRec(Item).Native);
                    end;
                  tkInterface:
                    begin
                      IInterface(PValueRec(Item).Native)._Release;
                    end;
                  tkDynArray:
                    begin
                      TRAIIHelper.DynArrayClear(@PValueRec(Item).Native, TypeInfo(TValue));
                    end;
                end;
            end;
          {$IFDEF WEAKINSTREF}
          tkMethod:
            begin
              if (PValueRec(Item).Method.Data <> nil) then
                TRAIIHelper.WeakMethodClear(@PValueRec(Item).Method.Data);
            end;
          {$ENDIF}
          tkVariant:
            begin
              VType := PValueRec(Item).VarData.VType;
              if (VType and TRAIIHelper.varDeepData <> 0) then
                case VType of
                  varBoolean, varUnknown + 1..varUInt64: ;
                else
                  System.VarClear(Variant(PValueRec(Item).VarData));
                end;
            end;
        else
          TRAIIHelper<TValue>.FOptions.ClearProc(TRAIIHelper<TValue>.FOptions, @Item.FValue);
        end;

        Inc(Item);
      end;
    end
    else
    begin
      // Keys only
      TRAIIHelper<TKey>.ClearArray(@Item.Key, Count, SizeOf(TItem));
    end;
  end
  else if (System.IsManagedType(TValue)) then
  begin
    // Values only
    TRAIIHelper<TValue>.ClearArray(@Item.Value, Count, SizeOf(TItem));
  end;
end;

function TCustomDictionary<TKey, TValue>.NewItem: Pointer {PItem};
var
  Instance: TCustomDictionary<TKey, TValue>;
  Count: NativeInt;
  LNull: NativeUInt;
begin
  Instance := Self;
  LNull := 0;
  repeat
    Count := Instance.FCount.Native;
    if (Count <> Instance.FCapacity) then
    begin
      Instance.FCount.Native := Count + 1;
      Result := Pointer(Instance.FItems);
      Inc(PItem(Result), Count);

      // AM: LNull := 0 is the only possible value, so why test it?
      //if ((SizeOf(TKey) >= SizeOf(NativeInt)) and (SizeOf(TKey) <= 16)) or
      //  ((SizeOf(TValue) >= SizeOf(NativeInt)) and (SizeOf(TValue) <= 16)) then
      //begin
      //  if (System.IsManagedType(TItem)) then
      //    LNull := 0;
      //end;

      if (System.IsManagedType(TKey)) then
      begin
        if (SizeOf(TKey) = SizeOf(NativeInt)) or (GetTypeKind(TKey) = tkVariant) then
        begin
          PKeyRec(Result).Natives[0] := LNull;
        end
        else if ((SizeOf(TKey) >= SizeOf(NativeInt)) and (SizeOf(TKey) <= 16)) then
        begin
          PKeyRec(Result).Natives[0] := LNull;
          if (SizeOf(TKey) >= 2 * SizeOf(NativeInt)) then
            PKeyRec(Result).Natives[1] := LNull;
          {$IFDEF SMALLINT}
          if (SizeOf(TKey) >= 3 * SizeOf(NativeInt)) then
            PKeyRec(Result).Natives[2] := LNull;
          if (SizeOf(TKey) = 4 * SizeOf(NativeInt)) then
            PKeyRec(Result).Natives[3] := LNull;
          {$ENDIF}
        end
        else
          TRAIIHelper<TKey>.Init(@PItem(Result).FKey);
      end;

      if (System.IsManagedType(TValue)) then
      begin
        if (SizeOf(TValue) = SizeOf(NativeInt)) or (GetTypeKind(TValue) = tkVariant) then
        begin
          PValueRec(Result)^.Natives[0] := LNull;
        end
        else if ((SizeOf(TValue) >= SizeOf(NativeInt)) and (SizeOf(TValue) <= 16)) then
        begin
          PValueRec(Result)^.Natives[0] := LNull;
          if (SizeOf(TValue) >= 2 * SizeOf(NativeInt)) then
            PValueRec(Result)^.Natives[1] := LNull;
          {$IFDEF SMALLINT}
          if (SizeOf(TValue) >= 3 * SizeOf(NativeInt)) then
            PValueRec(Result)^.Natives[2] := LNull;
          if (SizeOf(TValue) = 4 * SizeOf(NativeInt)) then
            PValueRec(Result)^.Natives[3] := LNull;
          {$ENDIF}
        end
        else
          TRAIIHelper<TValue>.Init(@PItem(Result).FValue);
      end;

      Exit;
    end
    else
    begin
      Instance := Instance.Grow;
    end;
  until (False);
end;

procedure TCustomDictionary<TKey, TValue>.DisposeItem(Item: Pointer {Item});
var
  VType: Integer;
  Count: NativeInt;
  Parent: Pointer;
  TopItem, Current: PItem;
begin
  // top item, count
  Count := Self.FCount.Native;
  Dec(Count);
  Self.FCount.Native := Count;
  TopItem := Pointer(FItems);
  Inc(TopItem, Count);
  if (Item <> TopItem) then
  begin
    // change TopItem.Parent.Next --> Item
    Parent := Pointer(@FHashTable[NativeInt(Cardinal(TopItem.HashCode)) and FHashTableMask]);
    repeat
      Current := PItem(Parent^);
      if (Current = TopItem) then
      begin
        PItem(Parent^) := Item;
        Break;
      end;
      Parent := Pointer(@Current.FNext);
    until (False);
  end;

  {$IFDEF WEAKREF}
  if (TRAIIHelper<TKey>.Weak) or (TRAIIHelper<TValue>.Weak) then
  begin
    // weak case: Copy(TopItem --> Item), Finalize(TopItem)
    PItem(Item)^ := TopItem^;
    System.Finalize(TopItem^);
  end
  else
    {$ENDIF}
  begin
    // standard case: Finalize(Item) + Move(DestItem, Item)
    // finalize Item.Key
    case GetTypeKind(TKey) of
      {$IFDEF AUTOREFCOUNT}
      tkClass,
        {$ENDIF}
      tkWString, tkLString, tkUString, tkInterface, tkDynArray:
        begin
          if (PKeyRec(Item).Native <> 0) then
            case GetTypeKind(TKey) of
              {$IFDEF AUTOREFCOUNT}
              tkClass:
                begin
                  TRAIIHelper.RefObjClear(@PKeyRec(Item).Native);
                end;
              {$ENDIF}
              {$IFDEF MSWINDOWS}
              tkWString:
                begin
                  TRAIIHelper.WStrClear(@PKeyRec(Item).Native);
                end;
              {$ELSE}
              tkWString,
                {$ENDIF}
              tkLString, tkUString:
                begin
                  TRAIIHelper.ULStrClear(@PKeyRec(Item).Native);
                end;
              tkInterface:
                begin
                  IInterface(PKeyRec(Item).Native)._Release;
                end;
              tkDynArray:
                begin
                  TRAIIHelper.DynArrayClear(@PKeyRec(Item).Native, TypeInfo(TKey));
                end;
            end;
        end;
      {$IFDEF WEAKINSTREF}
      tkMethod:
        begin
          if (PKeyRec(Item).Method.Data <> nil) then
            TRAIIHelper.WeakMethodClear(@PKeyRec(Item).Method.Data);
        end;
      {$ENDIF}
      tkVariant:
        begin
          VType := PKeyRec(Item).VarData.VType;
          if (VType and TRAIIHelper.varDeepData <> 0) then
            case VType of
              varBoolean, varUnknown + 1..varUInt64: ;
            else
              System.VarClear(Variant(PKeyRec(Item).VarData));
            end;
        end
    else
      TRAIIHelper<TKey>.Clear(@PItem(Item).FKey);
    end;

    // finalize Item.Value
    case GetTypeKind(TValue) of
      {$IFDEF AUTOREFCOUNT}
      tkClass,
        {$ENDIF}
      tkWString, tkLString, tkUString, tkInterface, tkDynArray:
        begin
          if (PValueRec(Item).Native <> 0) then
            case GetTypeKind(TValue) of
              {$IFDEF AUTOREFCOUNT}
              tkClass:
                begin
                  TRAIIHelper.RefObjClear(@PValueRec(Item).Native);
                end;
              {$ENDIF}
              {$IFDEF MSWINDOWS}
              tkWString:
                begin
                  TRAIIHelper.WStrClear(@PValueRec(Item).Native);
                end;
              {$ELSE}
              tkWString,
                {$ENDIF}
              tkLString, tkUString:
                begin
                  TRAIIHelper.ULStrClear(@PValueRec(Item).Native);
                end;
              tkInterface:
                begin
                  IInterface(PValueRec(Item).Native)._Release;
                end;
              tkDynArray:
                begin
                  TRAIIHelper.DynArrayClear(@PValueRec(Item).Native, TypeInfo(TValue));
                end;
            end;
        end;
      {$IFDEF WEAKINSTREF}
      tkMethod:
        begin
          if (PValueRec(Item).Method.Data <> nil) then
            TRAIIHelper.WeakMethodClear(@PValueRec(Item).Method.Data);
        end;
      {$ENDIF}
      tkVariant:
        begin
          VType := PValueRec(Item).VarData.VType;
          if (VType and TRAIIHelper.varDeepData <> 0) then
            case VType of
              varBoolean, varUnknown + 1..varUInt64: ;
            else
              System.VarClear(Variant(PValueRec(Item).VarData));
            end;
        end
    else
      TRAIIHelper<TValue>.Clear(@PItem(Item).FValue);
    end;

    // move TopItem --> Item
    if (Item <> TopItem) then
    begin
      case SizeOf(TItem) of
        1: TRAIIHelper.T1(Pointer(Item)^) := TRAIIHelper.T1(Pointer(TopItem)^);
        2: TRAIIHelper.T2(Pointer(Item)^) := TRAIIHelper.T2(Pointer(TopItem)^);
        3: TRAIIHelper.T3(Pointer(Item)^) := TRAIIHelper.T3(Pointer(TopItem)^);
        4: TRAIIHelper.T4(Pointer(Item)^) := TRAIIHelper.T4(Pointer(TopItem)^);
        5: TRAIIHelper.T5(Pointer(Item)^) := TRAIIHelper.T5(Pointer(TopItem)^);
        6: TRAIIHelper.T6(Pointer(Item)^) := TRAIIHelper.T6(Pointer(TopItem)^);
        7: TRAIIHelper.T7(Pointer(Item)^) := TRAIIHelper.T7(Pointer(TopItem)^);
        8: TRAIIHelper.T8(Pointer(Item)^) := TRAIIHelper.T8(Pointer(TopItem)^);
        9: TRAIIHelper.T9(Pointer(Item)^) := TRAIIHelper.T9(Pointer(TopItem)^);
        10: TRAIIHelper.T10(Pointer(Item)^) := TRAIIHelper.T10(Pointer(TopItem)^);
        11: TRAIIHelper.T11(Pointer(Item)^) := TRAIIHelper.T11(Pointer(TopItem)^);
        12: TRAIIHelper.T12(Pointer(Item)^) := TRAIIHelper.T12(Pointer(TopItem)^);
        13: TRAIIHelper.T13(Pointer(Item)^) := TRAIIHelper.T13(Pointer(TopItem)^);
        14: TRAIIHelper.T14(Pointer(Item)^) := TRAIIHelper.T14(Pointer(TopItem)^);
        15: TRAIIHelper.T15(Pointer(Item)^) := TRAIIHelper.T15(Pointer(TopItem)^);
        16: TRAIIHelper.T16(Pointer(Item)^) := TRAIIHelper.T16(Pointer(TopItem)^);
        17: TRAIIHelper.T17(Pointer(Item)^) := TRAIIHelper.T17(Pointer(TopItem)^);
        18: TRAIIHelper.T18(Pointer(Item)^) := TRAIIHelper.T18(Pointer(TopItem)^);
        19: TRAIIHelper.T19(Pointer(Item)^) := TRAIIHelper.T19(Pointer(TopItem)^);
        20: TRAIIHelper.T20(Pointer(Item)^) := TRAIIHelper.T20(Pointer(TopItem)^);
        21: TRAIIHelper.T21(Pointer(Item)^) := TRAIIHelper.T21(Pointer(TopItem)^);
        22: TRAIIHelper.T22(Pointer(Item)^) := TRAIIHelper.T22(Pointer(TopItem)^);
        23: TRAIIHelper.T23(Pointer(Item)^) := TRAIIHelper.T23(Pointer(TopItem)^);
        24: TRAIIHelper.T24(Pointer(Item)^) := TRAIIHelper.T24(Pointer(TopItem)^);
        25: TRAIIHelper.T25(Pointer(Item)^) := TRAIIHelper.T25(Pointer(TopItem)^);
        26: TRAIIHelper.T26(Pointer(Item)^) := TRAIIHelper.T26(Pointer(TopItem)^);
        27: TRAIIHelper.T27(Pointer(Item)^) := TRAIIHelper.T27(Pointer(TopItem)^);
        28: TRAIIHelper.T28(Pointer(Item)^) := TRAIIHelper.T28(Pointer(TopItem)^);
        29: TRAIIHelper.T29(Pointer(Item)^) := TRAIIHelper.T29(Pointer(TopItem)^);
        30: TRAIIHelper.T30(Pointer(Item)^) := TRAIIHelper.T30(Pointer(TopItem)^);
        31: TRAIIHelper.T31(Pointer(Item)^) := TRAIIHelper.T31(Pointer(TopItem)^);
        32: TRAIIHelper.T32(Pointer(Item)^) := TRAIIHelper.T32(Pointer(TopItem)^);
        33: TRAIIHelper.T33(Pointer(Item)^) := TRAIIHelper.T33(Pointer(TopItem)^);
        34: TRAIIHelper.T34(Pointer(Item)^) := TRAIIHelper.T34(Pointer(TopItem)^);
        35: TRAIIHelper.T35(Pointer(Item)^) := TRAIIHelper.T35(Pointer(TopItem)^);
        36: TRAIIHelper.T36(Pointer(Item)^) := TRAIIHelper.T36(Pointer(TopItem)^);
        37: TRAIIHelper.T37(Pointer(Item)^) := TRAIIHelper.T37(Pointer(TopItem)^);
        38: TRAIIHelper.T38(Pointer(Item)^) := TRAIIHelper.T38(Pointer(TopItem)^);
        39: TRAIIHelper.T39(Pointer(Item)^) := TRAIIHelper.T39(Pointer(TopItem)^);
        40: TRAIIHelper.T40(Pointer(Item)^) := TRAIIHelper.T40(Pointer(TopItem)^);
      else
        System.Move(TopItem^, Item^, SizeOf(TItem));
      end;
    end;
  end;
end;

function TCustomDictionary<TKey, TValue>.ContainsValue(const Value: TValue): Boolean;
label
  cmp0, cmp1, cmp2, cmp3, cmp4, cmp5, {$IFDEF SMALLINT}cmp6, cmp7, cmp8, cmp9, cmp10, {$ENDIF}
  next_item, done;
var
  i: NativeInt;
  Item: PValue;
  Left, Right: PByte;
  Count, Offset: NativeUInt;
begin
  Result := False; // satisfy compiler
  Item := @Self.FItems[0].FValue;

  for i := 1 to Self.FCount.Native do
  begin
    if (GetTypeKind(TValue) = tkVariant) then
    begin
      if (not InterfaceDefaults.Equals_Var(nil, PVarData(@Value), PVarData(Item))) then
        goto next_item;
    end
    else if (GetTypeKind(TValue) = tkClass) then
    begin
      Left := PPointer(@Value)^;
      Right := PPointer(Item)^;

      if (Assigned(Left)) then
      begin
        if (PPointer(Pointer(Left)^)[vmtEquals div SizeOf(Pointer)] = @TObject.Equals) then
        begin
          if (Left <> Right) then
            goto next_item;
        end
        else
        begin
          if (not TObject(Left).Equals(TObject(Right))) then
            goto next_item;
        end;
      end
      else
      begin
        if (Right <> nil) then
          goto next_item;
      end;
    end
    else if (GetTypeKind(TValue) = tkFloat) then
    begin
      case SizeOf(TValue) of
        4:
          begin
            if (PSingle(@Value)^ <> PSingle(Result)^) then
              goto next_item;
          end;
        10:
          begin
            if (PExtended(@Value)^ <> PExtended(Result)^) then
              goto next_item;
          end;
      else
        {$IFDEF LARGEINT}
        if (PInt64(@Value)^ <> PInt64(Result)^) then
          {$ELSE .SMALLINT}
        if ((PPoint(@Value).X - PPoint(Result).X) or (PPoint(@Value).Y - PPoint(Result).Y) <> 0) then
          {$ENDIF}
        begin
          if (TRAIIHelper<TValue>.Options.ItemSize < 0) then
            goto next_item;
          if (PDouble(@Value)^ <> PDouble(Result)^) then
            goto next_item;
        end;
      end;
    end
    else if (not (GetTypeKind(TValue) in [tkDynArray, tkString, tkLString, tkWString, tkUString])) and
      (SizeOf(TValue) <= 16) then
    begin
      // small binary
      if (SizeOf(TValue) <> 0) then
        with PData16(@Value)^ do
        begin
          if (SizeOf(TValue) >= SizeOf(Integer)) then
          begin
            if (SizeOf(TValue) >= SizeOf(Int64)) then
            begin
              {$IFDEF LARGEINT}
              if (Int64s[0] <> PData16(Item).Int64s[0]) then
                goto next_item;
              {$ELSE}
              if (Integers[0] <> PData16(Item).Integers[0]) then
                goto next_item;
              if (Integers[1] <> PData16(Item).Integers[1]) then
                goto next_item;
              {$ENDIF}

              if (SizeOf(TValue) = 16) then
              begin
                {$IFDEF LARGEINT}
                if (Int64s[1] <> PData16(Item).Int64s[1]) then
                  goto next_item;
                {$ELSE}
                if (Integers[2] <> PData16(Item).Integers[2]) then
                  goto next_item;
                if (Integers[3] <> PData16(Item).Integers[3]) then
                  goto next_item;
                {$ENDIF}
              end
              else if (SizeOf(TValue) >= 12) then
              begin
                if (Integers[2] <> PData16(Item).Integers[2]) then
                  goto next_item;
              end;
            end
            else
            begin
              if (Integers[0] <> PData16(Item).Integers[0]) then
                goto next_item;
            end;
          end;

          if (SizeOf(TValue) and 2 <> 0) then
          begin
            if (Words[(SizeOf(TValue) and -4) shr 1] <> PData16(Item).Words[(SizeOf(TValue) and -4) shr 1]) then
              goto next_item;
          end;
          if (SizeOf(TValue) and 1 <> 0) then
          begin
            if (Bytes[SizeOf(TValue) and -2] <> PData16(Item).Bytes[SizeOf(TValue) and -2]) then
              goto next_item;
          end;
        end;
    end
    else
    begin
      if (GetTypeKind(TValue) in [tkDynArray, tkString, tkLString, tkWString, tkUString]) then
      begin
        // dynamic size
        if (GetTypeKind(TValue) = tkString) then
        begin
          Left := Pointer(@Value);
          Right := Pointer(Item);
          if (PValue(Left) = {Right}Item) then
            goto cmp0;
          Count := Left^;
          if (Count <> Right^) then
            goto next_item;
          if (Count = 0) then
            goto cmp0;
          // compare last bytes
          if (Left[Count] <> Right[Count]) then
            goto next_item;
        end
        else
        // if (GetTypeKind(TValue) in [tkDynArray, tkLString, tkWString, tkUString]) then
        begin
          Left := PPointer(@Value)^;
          Right := PPointer(Item)^;
          if (Left = Right) then
            goto cmp0;
          if (Left = nil) then
          begin
            {$IFDEF MSWINDOWS}
            if (GetTypeKind(TValue) = tkWString) then
            begin
              Dec(Right, SizeOf(Cardinal));
              if (PCardinal(Right)^ = 0) then
                goto cmp0;
            end;
            {$ENDIF}
            goto next_item;
          end;
          if (Right = nil) then
          begin
            {$IFDEF MSWINDOWS}
            if (GetTypeKind(TValue) = tkWString) then
            begin
              Dec(Left, SizeOf(Cardinal));
              if (PCardinal(Left)^ = 0) then
                goto cmp0;
            end;
            {$ENDIF}
            goto next_item;
          end;

          if (GetTypeKind(TValue) = tkDynArray) then
          begin
            Dec(Left, SizeOf(NativeUInt));
            Dec(Right, SizeOf(NativeUInt));
            Count := PNativeUInt(Left)^;
            if (Count <> PNativeUInt(Right)^) then
              goto next_item;
            NativeInt(Count) := NativeInt(Count) * TRAIIHelper<TValue>.Options.ItemSize;
            Inc(Left, SizeOf(NativeUInt));
            Inc(Right, SizeOf(NativeUInt));
          end
          else
          // if (GetTypeKind(TValue) in [tkLString, tkWString, tkUString]) then
          begin
            Dec(Left, SizeOf(Cardinal));
            Dec(Right, SizeOf(Cardinal));
            Count := PCardinal(Left)^;
            if (Cardinal(Count) <> PCardinal(Right)^) then
              goto next_item;
            Inc(Left, SizeOf(Cardinal));
            Inc(Right, SizeOf(Cardinal));
          end;
        end;

        // compare last (after cardinal) words
        if (GetTypeKind(TValue) in [tkDynArray, tkString, tkLString]) then
        begin
          if (GetTypeKind(TValue) in [tkString, tkLString]) {ByteStrings + 2} then
          begin
            Inc(Count);
          end;
          if (Count and 2 <> 0) then
          begin
            Offset := Count and -4;
            Inc(Left, Offset);
            Inc(Right, Offset);
            if (PWord(Left)^ <> PWord(Right)^) then
              goto next_item;
            Offset := Count;
            Offset := Offset and -4;
            Dec(Left, Offset);
            Dec(Right, Offset);
          end;
        end
        else
        // modify Count to have only cardinals to compare
        // if (GetTypeKind(TValue) in [tkWString, tkUString]) {UnicodeStrings + 2} then
        begin
          {$IFDEF MSWINDOWS}
          if (GetTypeKind(TValue) = tkWString) then
          begin
            if (Count = 0) then
              goto cmp0;
          end
          else
            {$ENDIF}
          begin
            Inc(Count, Count);
          end;
          Inc(Count, 2);
        end;

        {$IFDEF LARGEINT}
        if (Count and 4 <> 0) then
        begin
          Offset := Count and -8;
          Inc(Left, Offset);
          Inc(Right, Offset);
          if (PCardinal(Left)^ <> PCardinal(Right)^) then
            goto next_item;
          Dec(Left, Offset);
          Dec(Right, Offset);
        end;
        {$ENDIF}
      end
      else
      begin
        // non-dynamic (constant) size binary > 16
        if (SizeOf(TValue) and {$IFDEF LARGEINT}7{$ELSE}3{$ENDIF} <> 0) then
          with PData16(@Value)^ do
          begin
            {$IFDEF LARGEINT}
            if (SizeOf(TValue) and 4 <> 0) then
            begin
              if (Integers[(SizeOf(TValue) and -8) shr 2] <> PData16(Item).Integers[(SizeOf(TValue) and -8) shr 2])
                then
                goto next_item;
            end;
            {$ENDIF}
            if (SizeOf(TValue) and 2 <> 0) then
            begin
              if (Words[(SizeOf(TValue) and -4) shr 1] <> PData16(Item).Words[(SizeOf(TValue) and -4) shr 1]) then
                goto next_item;
            end;
            if (SizeOf(TValue) and 1 <> 0) then
            begin
              if (Bytes[SizeOf(TValue) and -2] <> PData16(Item).Bytes[SizeOf(TValue) and -2]) then
                goto next_item;
            end;
          end;
        Left := Pointer(@Value);
        Right := Pointer(Item);
        Count := SizeOf(TValue);
      end;

      // natives (40 bytes static) compare
      Count := Count shr {$IFDEF LARGEINT}3{$ELSE}2{$ENDIF};
      case Count of
        {$IFDEF SMALLINT}
        10: goto cmp10;
        9: goto cmp9;
        8: goto cmp8;
        7: goto cmp7;
        6: goto cmp6;
        {$ENDIF}
        5: goto cmp5;
        4: goto cmp4;
        3: goto cmp3;
        2: goto cmp2;
        1: goto cmp1;
        0: goto cmp0;
      else
        repeat
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            goto next_item;
          Dec(Count);
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
        until (Count = {$IFDEF LARGEINT}5{$ELSE}10{$ENDIF});

        {$IFDEF SMALLINT}
        cmp10:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp9:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp8:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp7:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp6:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        {$ENDIF}
        cmp5:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp4:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp3:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp2:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp1:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        cmp0:
      end;
    end;
    goto done;

    next_item:
    Inc(NativeUInt(Item), SizeOf(TItem));
  end;

  Result := False;
  Exit;
  done:
  Result := True;
  Exit;
end;

class function TCustomDictionary<TKey, TValue>.IntfMethod(Intf: Pointer; MethodNum: NativeUInt): TMethod;
begin
  Result.Data := Intf;
  Result.Code := PPointer(PNativeUInt(Intf)^ + MethodNum * SizeOf(Pointer))^;
end;

procedure TCustomDictionary<TKey, TValue>.SetKeyNotify(const Value: TCollectionNotifyEvent<TKey>);
begin
  if (TMethod(FOnKeyNotify).Code <> TMethod(Value).Code) or
    (TMethod(FOnKeyNotify).Data <> TMethod(Value).Data) then
  begin
    FOnKeyNotify := Value;
    SetNotifyMethods;
  end;
end;

procedure TCustomDictionary<TKey, TValue>.SetValueNotify(const Value: TCollectionNotifyEvent<TValue>);
begin
  if (TMethod(FOnValueNotify).Code <> TMethod(Value).Code) or
    (TMethod(FOnValueNotify).Data <> TMethod(Value).Data) then
  begin
    FOnValueNotify := Value;
    SetNotifyMethods;
  end;
end;

procedure TCustomDictionary<TKey, TValue>.KeyNotify(const Key: TKey; Action: TCollectionNotification);
begin
  if Assigned(FOnKeyNotify) then
    FOnKeyNotify(Self, Key, Action);
end;

procedure TCustomDictionary<TKey, TValue>.ValueNotify(const Value: TValue; Action: TCollectionNotification);
begin
  if Assigned(FOnValueNotify) then
    FOnValueNotify(Self, Value, Action);
end;

procedure TCustomDictionary<TKey, TValue>.KeyNotifyCaller(Sender: TObject; const Item: TKey; Action:
  TCollectionNotification);
begin
  Self.KeyNotify(Item, Action);
end;

procedure TCustomDictionary<TKey, TValue>.ValueNotifyCaller(Sender: TObject; const Item: TValue; Action:
  TCollectionNotification);
begin
  Self.ValueNotify(Item, Action);
end;

procedure TCustomDictionary<TKey, TValue>.ItemNotifyCaller(const Item: TItem; Action: TCollectionNotification);
begin
  Self.KeyNotify(Item.Key, Action);
  Self.ValueNotify(Item.Value, Action);
end;

procedure TCustomDictionary<TKey, TValue>.ItemNotifyEvents(const Item: TItem; Action: TCollectionNotification);
begin
  Self.FInternalKeyNotify(Self, Item.Key, Action);
  Self.FInternalValueNotify(Self, Item.Value, Action);
end;

procedure TCustomDictionary<TKey, TValue>.ItemNotifyKey(const Item: TItem; Action: TCollectionNotification);
begin
  Self.FInternalKeyNotify(Self, Item.Key, Action);
end;

procedure TCustomDictionary<TKey, TValue>.ItemNotifyValue(const Item: TItem; Action: TCollectionNotification);
begin
  Self.FInternalValueNotify(Self, Item.Value, Action);
end;

procedure TCustomDictionary<TKey, TValue>.SetNotifyMethods;
var
  VMTKeyNotify: procedure(const Key: TKey; Action: TCollectionNotification) of object;
  VMTValueNotify: procedure(const Value: TValue; Action: TCollectionNotification) of object;
begin
  // FInternalKeyNotify, FInternalValueNotify
  VMTKeyNotify := Self.KeyNotify;
  VMTValueNotify := Self.ValueNotify;
  if (TMethod(VMTKeyNotify).Code <> @TCustomDictionary<TKey, TValue>.KeyNotify) then
  begin
    // FInternalKeyNotify := Self.KeyNotifyCaller;
    TMethod(FInternalKeyNotify).Data := Pointer(Self);
    TMethod(FInternalKeyNotify).Code := @TCustomDictionary<TKey, TValue>.KeyNotifyCaller;
  end
  else
  begin
    TMethod(FInternalKeyNotify) := TMethod(Self.FOnKeyNotify);
  end;
  if (TMethod(VMTValueNotify).Code <> @TCustomDictionary<TKey, TValue>.ValueNotify) then
  begin
    // FInternalValueNotify := Self.ValueNotifyCaller;
    TMethod(FInternalValueNotify).Data := Pointer(Self);
    TMethod(FInternalValueNotify).Code := @TCustomDictionary<TKey, TValue>.ValueNotifyCaller;
  end
  else
  begin
    TMethod(FInternalValueNotify) := TMethod(Self.FOnValueNotify);
  end;

  // FInternalItemNotify
  if Assigned(FInternalKeyNotify) then
  begin
    // FInternalItemNotify := Self.ItemNotifyKey;
    TMethod(FInternalItemNotify).Data := Pointer(Self);
    TMethod(FInternalItemNotify).Code := @TCustomDictionary<TKey, TValue>.ItemNotifyKey;

    if Assigned(FInternalValueNotify) then
    begin
      // FInternalItemNotify := Self.ItemNotifyEvents;
      TMethod(FInternalItemNotify).Code := @TCustomDictionary<TKey, TValue>.ItemNotifyEvents;

      if (TMethod(VMTKeyNotify).Code <> @TCustomDictionary<TKey, TValue>.KeyNotify) or
        (TMethod(VMTValueNotify).Code <> @TCustomDictionary<TKey, TValue>.ValueNotify) then
      begin
        // FInternalItemNotify := Self.ItemNotifyCaller;
        TMethod(FInternalItemNotify).Code := @TCustomDictionary<TKey, TValue>.ItemNotifyCaller;
      end;
    end;
  end
  else if Assigned(FInternalValueNotify) then
  begin
    // FInternalItemNotify := Self.ItemNotifyValue;
    TMethod(FInternalItemNotify).Data := Pointer(Self);
    TMethod(FInternalItemNotify).Code := @TCustomDictionary<TKey, TValue>.ItemNotifyValue;
  end
  else
  begin
    // FInternalItemNotify := nil;
    TMethod(FInternalItemNotify).Data := nil;
    TMethod(FInternalItemNotify).Code := nil;
  end;
end;

{ TDictionary }

constructor TDictionary<TKey, TValue>.Create(ACapacity: Integer);
begin
  Create(ACapacity, nil);
end;

constructor TDictionary<TKey, TValue>.Create(const AComparer: IEqualityComparer<TKey>);
begin
  Create(0, AComparer);
end;

constructor TDictionary<TKey, TValue>.Create(ACapacity: Integer; const AComparer: IEqualityComparer<TKey>);
begin
  if ACapacity < 0 then
    ErrorArgumentOutOfRange;

  // comparer
  FComparer := AComparer;
  if (FComparer = nil) then
    Pointer(FComparer) := Pointer(@InterfaceDefaults.TDefaultEqualityComparer<TKey>.Instance);

  // comparer methods
  TMethod(FComparerEquals) := IntfMethod(Pointer(FComparer), 3);
  TMethod(FComparerGetHashCode) := IntfMethod(Pointer(FComparer), 4);

  // initialization
  inherited Create(ACapacity);
end;

constructor TDictionary<TKey, TValue>.Create(const Collection: TEnumerable < TPair<TKey, TValue> > );
begin
  Create(Collection, nil);
end;

constructor TDictionary<TKey, TValue>.Create(const Collection: TEnumerable < TPair<TKey, TValue> > ;
  const AComparer: IEqualityComparer<TKey>);
var
  Item: TPair<TKey, TValue>;
begin
  Create(0, AComparer);
  for Item in Collection do
    AddOrSetValue(Item.Key, Item.Value);
end;

destructor TDictionary<TKey, TValue>.Destroy;
begin
  inherited;

  ClearMethod(FComparerEquals);
  ClearMethod(FComparerGetHashCode);
end;

function TDictionary<TKey, TValue>.InternalFindItem(const Key: TKey; const FindMode: Integer): Pointer {PItem};
var
  Parent: Pointer;
  Item: TCustomDictionary<TKey, TValue>.PItem;
  HashCode, Mode: Integer;
  Stored: TInternalFindStored;
begin
  // hash code
  HashCode := Self.FComparerGetHashCode(Key);

  // parent
  Pointer(Item {Parent}) := @FHashTable[NativeInt(Cardinal(HashCode)) and FHashTableMask];
  Dec(NativeUInt(Item {Parent}), SizeOf(TKey) + SizeOf(TValue));

  // find
  Stored.HashCode := HashCode;
  repeat
    // hash code item
    repeat
      Parent := Pointer(@Item.FNext);
      Item := Item.FNext;
    until (Item = nil) or (Stored.HashCode = Item.HashCode);

    if (Item <> nil) then
    begin
      // hash code item found
      Stored.Parent := Parent;

      // keys comparison
      if (not Self.FComparerEquals(Key, Item.Key)) then
        Continue;

      // found
      Mode := FindMode;
      if (Mode and FOUND_MASK = 0) then
        Break;
      Cardinal(Mode) := Cardinal(Mode) and FOUND_MASK;
      if (Mode <> FOUND_EXCEPTION) then
      begin
        if (Mode = FOUND_DELETE) then
        begin
          Pointer(Stored.Parent^) := Item.FNext;
          if (not Assigned(Self.FInternalItemNotify)) then
          begin
            Self.DisposeItem(Item);
          end
          else
          begin
            Self.FInternalItemNotify(Item^, cnRemoved);
            Self.DisposeItem(Item);
          end;
        end
        else
        // if (Mode = FOUND_REPLACE) then
        begin
          if (not Assigned(Self.FInternalValueNotify)) then
          begin
            Item.FValue := FInternalFindValue^;
          end
          else
          begin
            Self.FInternalValueNotify(Self, Item.Value, cnRemoved);
            Item.FValue := FInternalFindValue^;
            Self.FInternalValueNotify(Self, Item.Value, cnAdded);
          end;
        end;
      end
      else
      begin
        raise EListError.CreateRes(Pointer(@SGenericDuplicateItem));
      end;
      Break;
    end;

    // not found (Item = nil)
    Mode := FindMode;
    if (Mode and EMPTY_MASK = 0) then
      Break;
    if (Mode and EMPTY_EXCEPTION = 0) then
    begin
      // EMPTY_NEW
      Item := Self.NewItem;
      Item.FKey := Key;
      Item.FHashCode := Stored.HashCode;
      Parent := Pointer(@Self.FHashTable[NativeInt(Cardinal(Stored.HashCode)) and Self.FHashTableMask]);
      Item.FNext := Pointer(Parent^);
      Pointer(Parent^) := Item;
      Item.FValue := FInternalFindValue^;
      if (Assigned(Self.FInternalItemNotify)) then
      begin
        Self.FInternalItemNotify(Item^, cnAdded);
      end;
      Break;
    end
    else
    begin
      raise EListError.CreateRes(Pointer(@SGenericItemNotFound));
    end;
  until (False);

  Result := Item;
end;

function TDictionary<TKey, TValue>.GetItem(const Key: TKey): TValue;
begin
  Result := TCustomDictionary<TKey, TValue>.PItem(Self.InternalFindItem(Key, FOUND_NONE + EMPTY_EXCEPTION)).Value;
end;

procedure TDictionary<TKey, TValue>.SetItem(const Key: TKey; const Value: TValue);
begin
  Self.FInternalFindValue := @Value;
  Self.InternalFindItem(Key, FOUND_REPLACE + EMPTY_EXCEPTION);
end;

function TDictionary<TKey, TValue>.Find(const Key: TKey): Pointer {PItem};
begin
  Result := Self.InternalFindItem(Key, FOUND_NONE + EMPTY_NONE);
end;

function TDictionary<TKey, TValue>.FindOrAdd(const Key: TKey): Pointer {PItem};
begin
  Self.FInternalFindValue := @Self.FDefaultValue;
  Result := Self.InternalFindItem(Key, FOUND_NONE + EMPTY_NEW);
end;

procedure TDictionary<TKey, TValue>.Add(const Key: TKey; const Value: TValue);
begin
  Self.FInternalFindValue := @Value;
  Self.InternalFindItem(Key, FOUND_EXCEPTION + EMPTY_NEW);
end;

function TDictionary<TKey, TValue>.TryAdd(const Key: TKey; const Value: TValue): Boolean;
begin
  if ContainsKey(Key) then
    Exit(False);

  Add(Key, Value);
  Result := True;
end;

procedure TDictionary<TKey, TValue>.Remove(const Key: TKey);
begin
  Self.InternalFindItem(Key, FOUND_DELETE + EMPTY_NONE)
end;

function TDictionary<TKey, TValue>.ExtractPair(const Key: TKey): TPair<TKey, TValue>;
var
  Parent: Pointer;
  Item, Current: TCustomDictionary<TKey, TValue>.PItem;
begin
  Result.Key := Key;
  Item := Self.InternalFindItem(Key, FOUND_NONE + EMPTY_NONE);
  if (Item = nil) then
  begin
    Result.Value := Default(TValue);
    Exit;
  end;

  Result.Value := Item.Value;
  Parent := Pointer(@Self.FHashTable[NativeInt(Cardinal(Item.HashCode)) and Self.FHashTableMask]);
  repeat
    Current := TCustomDictionary<TKey, TValue>.PItem(Parent^);

    if (Item = Current) then
    begin
      TCustomDictionary<TKey, TValue>.PItem(Parent^) := Item.FNext;

      if (not Assigned(Self.FInternalItemNotify)) then
      begin
        Self.DisposeItem(Item);
      end
      else
      begin
        Self.FInternalItemNotify(Item^, cnExtracted);
        Self.DisposeItem(Item);
      end;

      Exit;
    end;

    Parent := Pointer(@Current.FNext);
  until (False);
end;

function TDictionary<TKey, TValue>.TryGetValue(const Key: TKey; out Value: TValue): Boolean;
var
  Item: PItem;
begin
  Item := Self.InternalFindItem(Key, FOUND_NONE + EMPTY_NONE);
  if Assigned(Item) then
  begin
    Value := Item.Value;
    Result := True;
  end
  else
  begin
    Value := Default(TValue);
    Result := False;
  end;
end;

procedure TDictionary<TKey, TValue>.AddOrSetValue(const Key: TKey; const Value: TValue);
begin
  Self.FInternalFindValue := @Value;
  Self.InternalFindItem(Key, FOUND_REPLACE + EMPTY_NEW);
end;

function TDictionary<TKey, TValue>.ContainsKey(const Key: TKey): Boolean;
begin
  Result := (Self.InternalFindItem(Key, FOUND_NONE + EMPTY_NONE) <> nil);
end;

{ TRapidDictionary<TKey,TValue> }

constructor TRapidDictionary<TKey, TValue>.Create(ACapacity: Integer);
begin
  inherited;
end;

procedure TRapidDictionary<TKey, TValue>.AddOrSetValue(const Key: TKey; const Value: TValue);
begin
  Self.FInternalFindValue := @Value;
  Self.InternalFindItem(Key, FOUND_REPLACE + EMPTY_NEW);
end;

constructor TRapidDictionary<TKey, TValue>.Create(const Collection: TEnumerable < TPair<TKey, TValue> > );
var
  Item: TPair<TKey, TValue>;
begin
  inherited Create;
  for Item in Collection do
    AddOrSetValue(Item.Key, Item.Value);
end;

destructor TRapidDictionary<TKey, TValue>.Destroy;
begin
  inherited;
end;

function TRapidDictionary<TKey, TValue>.InternalFindItem(const Key: TKey; const FindMode: Integer):
  TCustomDictionary<TKey, TValue>.PItem;
label
  hash0, hash1, hash2, hash3, hash4, hash5, hash6, hash7, hash8, hash9, hash10,
    cmp0, cmp1, cmp2, cmp3, cmp4, cmp5, {$IFDEF SMALLINT}cmp6, cmp7, cmp8, cmp9, cmp10, {$ENDIF}
  hash_calculated, next_item, not_found;
var
  Parent: ^PItem;
  HashCode, Mode, M: Integer;
  Stored: TInternalFindStored;
  Left, Right: PByte;
  Count, Offset: NativeUInt;
  _Self1, _Self2: TRapidDictionary<TKey, TValue>;
begin
  // stores, hash code
  Stored.Self := Self;
  if (GetTypeKind(TKey) = tkVariant) then
  begin
    HashCode := InterfaceDefaults.GetHashCode_Var(nil, PVarData(@Key));
  end
  else if (GetTypeKind(TKey) = tkClass) then
  begin
    Left := PPointer(@Key)^;
    if (Assigned(Left)) then
    begin
      if (PPointer(Pointer(Left)^)[vmtGetHashCode div SizeOf(Pointer)] = @TObject.GetHashCode) then
      begin
        {$IFDEF LARGEINT}
        HashCode := Integer(NativeInt(Left) xor (NativeInt(Left) shr 32));
        {$ELSE .SMALLINT}
        HashCode := Integer(Left);
        {$ENDIF}
        Inc(HashCode, ((HashCode shr 8) * 63689) + ((HashCode shr 16) * -1660269137) +
          ((HashCode shr 24) * -1092754919));
      end
      else
      begin
        HashCode := TObject(Left).GetHashCode;
      end;
    end
    else
    begin
      HashCode := 0;
    end;
  end
  else if (GetTypeKind(TKey) in [tkInterface, tkClassRef, tkPointer, tkProcedure]) then
  begin
    {$IFDEF LARGEINT}
    HashCode := Integer(PNativeInt(@Key)^ xor (PNativeInt(@Key)^ shr 32));
    {$ELSE .SMALLINT}
    HashCode := PInteger(@Key)^;
    {$ENDIF}
    Inc(HashCode, ((HashCode shr 8) * 63689) + ((HashCode shr 16) * -1660269137) +
      ((HashCode shr 24) * -1092754919));
  end
  else if (GetTypeKind(TKey) = tkFloat) then
  begin
    HashCode := 0;
    case SizeOf(TKey) of
      4:
        begin
          if (PSingle(@Key)^ = 0) then
            goto hash_calculated;
          Frexp(PSingle(@Key)^, Stored.SingleRec.Mantissa, Stored.SingleRec.Exponent);
          HashCode := Stored.SingleRec.Exponent + Stored.SingleRec.HighInt * 63689;
        end;
      10:
        begin
          if (PExtended(@Key)^ = 0) then
            goto hash_calculated;
          Frexp(PExtended(@Key)^, Stored.ExtendedRec.Mantissa, Stored.ExtendedRec.Exponent);
          HashCode := Stored.ExtendedRec.Exponent + Stored.ExtendedRec.LowInt * 63689 +
            Stored.ExtendedRec.HighInt * -1660269137 + Integer(Stored.ExtendedRec.Middle) * -1092754919;
        end;
    else
      if (TRAIIHelper<TKey>.Options.ItemSize < 0) then
      begin
        HashCode := PPoint(@Key).X + PPoint(@Key).Y * 63689;
      end
      else
      begin
        if (PDouble(@Key)^ = 0) then
          goto hash_calculated;
        Frexp(PDouble(@Key)^, Stored.DoubleRec.Mantissa, Stored.DoubleRec.Exponent);
        HashCode := Stored.DoubleRec.Exponent + Stored.DoubleRec.LowInt * 63689 +
          Stored.DoubleRec.HighInt * -1660269137;
      end;
    end;

    Inc(HashCode, ((HashCode shr 8) * 63689) + ((HashCode shr 16) * -1660269137) +
      ((HashCode shr 24) * -1092754919));
  end
  else if (not (GetTypeKind(TKey) in [tkDynArray, tkString, tkLString, tkWString, tkUString])) and
    (SizeOf(TKey) <= 16) then
  begin
    // small binary
    if (SizeOf(TKey) >= SizeOf(Integer)) then
    begin
      if (SizeOf(TKey) = SizeOf(Integer)) then
      begin
        HashCode := PInteger(@Key)^;
      end
      else if (SizeOf(TKey) = SizeOf(Int64)) then
      begin
        HashCode := PPoint(@Key).X + PPoint(@Key).Y * 63689;
      end
      else
      begin
        Left := Pointer(@Key);
        HashCode := Integer(SizeOf(TKey)) + PInteger(Left + (SizeOf(TKey) - SizeOf(Integer)))^ * 63689;
        HashCode := HashCode * 2012804575 + PInteger(Left)[0];
        if (SizeOf(TKey) > SizeOf(Integer) * 2) then
        begin
          HashCode := HashCode * -1092754919 + PInteger(Left)[1];
          if (SizeOf(TKey) > SizeOf(Integer) * 3) then
          begin
            HashCode := HashCode * -1660269137 + PInteger(Left)[2];
          end;
        end;
      end;

      Inc(HashCode, ((HashCode shr 8) * 63689) + ((HashCode shr 16) * -1660269137) +
        ((HashCode shr 24) * -1092754919));
    end
    else if (SizeOf(TKey) <> 0) then
    begin
      Left := Pointer(@Key);
      HashCode := Integer(Left[0]);
      HashCode := HashCode + (HashCode shr 4) * 63689;
      if (SizeOf(TKey) > 1) then
      begin
        HashCode := HashCode + Integer(Left[1]) * -1660269137;
        if (SizeOf(TKey) > 2) then
        begin
          HashCode := HashCode + Integer(Left[2]) * -1092754919;
        end;
      end;
    end
    else
    begin
      HashCode := 0;
    end;
  end
  else
  begin
    if (GetTypeKind(TKey) in [tkDynArray, tkString, tkLString, tkWString, tkUString]) then
    begin
      // dynamic size
      if (GetTypeKind(TKey) = tkString) then
      begin
        Left := Pointer(@Key);
        Count := Left^;
        Inc(Count);
      end
      else
      // if (GetTypeKind(TKey) in [tkDynArray, tkLString, tkWString, tkUString]) then
      begin
        Left := PPointer(@Key)^;
        HashCode := 0;
        if (Left = nil) then
          goto hash_calculated;

        case GetTypeKind(TKey) of
          tkLString:
            begin
              Dec(Left, SizeOf(Integer));
              Count := PInteger(Left)^;
              Inc(Left, SizeOf(Integer));
            end;
          {$IFDEF MSWINDOWS}
          tkWString:
            begin
              Dec(Left, SizeOf(Integer));
              Count := PInteger(Left)^;
              Inc(Left, SizeOf(Integer));
              if (Count = 0) then
                goto hash_calculated;
              Count := Count + 2;
              Count := Count and -4;
            end;
          {$ELSE}
          tkWString,
            {$ENDIF}
          tkUString:
            begin
              Dec(Left, SizeOf(Integer));
              Count := PInteger(Left)^;
              Inc(Left, SizeOf(Integer));
              Count := Count * 2 + 2;
              Count := Count and -4;
            end;
        else
        // tkDynArray
          Dec(Left, SizeOf(NativeUInt));
          Count := PNativeInt(Left)^ * TRAIIHelper<TKey>.Options.ItemSize;
          Inc(Left, SizeOf(NativeUInt));
        end;
      end;
    end
    else
    begin
      // non-dynamic (constant) size binary > 16
      Left := Pointer(@Key);
      Count := SizeOf(TKey);
    end;

    if (not (GetTypeKind(TKey) in [tkWString, tkUString])) then
    begin
      if (Count < SizeOf(Integer)) then
      begin
        if (Count <> 0) then
        begin
          HashCode := Integer(Left[0]);
          HashCode := HashCode + (HashCode shr 4) * 63689;
          if (Count > 1) then
          begin
            HashCode := HashCode + Integer(Left[1]) * -1660269137;
            if (Count > 2) then
            begin
              HashCode := HashCode + Integer(Left[2]) * -1092754919;
            end;
          end;
        end
        else
        begin
          HashCode := 0;
        end;
        goto hash_calculated;
      end;
    end;

    HashCode := Integer(Count);
    Dec(Count, SizeOf(Integer));
    Inc(Left, Count);
    Inc(HashCode, PInteger(Left)^ * 63689);
    Dec(Left, Count);
    case (Count + (SizeOf(Integer) - 1)) shr 2 of
      10: goto hash10;
      9: goto hash9;
      8: goto hash8;
      7: goto hash7;
      6: goto hash6;
      5: goto hash5;
      4: goto hash4;
      3: goto hash3;
      2: goto hash2;
      1: goto hash1;
      0: goto hash0;
    else
      Inc(Count, SizeOf(Integer) - 1);
      M := -1660269137;
      repeat
        HashCode := HashCode * M + PInteger(Left)^;
        Dec(Count, SizeOf(Integer));
        Inc(Left, SizeOf(Integer));
        M := M * 378551;
        if (NativeInt(Count) <= 43) then
          Break;
      until (False);

      hash10:
      HashCode := HashCode * 631547855 + PInteger(Left)^;
      Inc(Left, SizeOf(Integer));
      hash9:
      HashCode := HashCode * -1987506439 + PInteger(Left)^;
      Inc(Left, SizeOf(Integer));
      hash8:
      HashCode := HashCode * -1653913089 + PInteger(Left)^;
      Inc(Left, SizeOf(Integer));
      hash7:
      HashCode := HashCode * -186114231 + PInteger(Left)^;
      Inc(Left, SizeOf(Integer));
      hash6:
      HashCode := HashCode * 915264303 + PInteger(Left)^;
      Inc(Left, SizeOf(Integer));
      hash5:
      HashCode := HashCode * -794603367 + PInteger(Left)^;
      Inc(Left, SizeOf(Integer));
      hash4:
      HashCode := HashCode * 135394143 + PInteger(Left)^;
      Inc(Left, SizeOf(Integer));
      hash3:
      HashCode := HashCode * 2012804575 + PInteger(Left)^;
      Inc(Left, SizeOf(Integer));
      hash2:
      HashCode := HashCode * -1092754919 + PInteger(Left)^;
      Inc(Left, SizeOf(Integer));
      hash1:
      HashCode := HashCode * -1660269137 + PInteger(Left)^;
      hash0:
    end;

    Inc(HashCode, ((HashCode shr 8) * 63689) + ((HashCode shr 16) * -1660269137) +
      ((HashCode shr 24) * -1092754919));
  end;
  hash_calculated:

  // parent
  Pointer(Result {Parent}) := @FHashTable[NativeInt(Cardinal(HashCode)) and FHashTableMask];
  Dec(NativeUInt(Result {Parent}), SizeOf(TKey) + SizeOf(TValue));

  // find
  Stored.HashCode := HashCode;
  repeat
    next_item:
    // hash code item
    repeat
      Parent := Pointer(@Result.FNext);
      Result := Result.FNext;
      if (not Assigned(Result)) then
        goto not_found;
    until (Stored.HashCode = Result.HashCode);
    NativeUInt(Stored.Parent) := NativeUInt(Parent);

    // default keys comparison
    if (GetTypeKind(TKey) = tkVariant) then
    begin
      if (not InterfaceDefaults.Equals_Var(nil, PVarData(@Key), PVarData(Result))) then
        goto next_item;
    end
    else if (GetTypeKind(TKey) = tkClass) then
    begin
      Left := PPointer(@Key)^;
      Right := PPointer(Result)^;
      if (Assigned(Left)) then
      begin
        if (PPointer(Pointer(Left)^)[vmtEquals div SizeOf(Pointer)] = @TObject.Equals) then
        begin
          if (Left <> Right) then
            goto next_item;
        end
        else
        begin
          if (not TObject(PNativeUInt(@Key)^).Equals(TObject(PNativeUInt(Result)^))) then
            goto next_item;
        end;
      end
      else
      begin
        if (Right <> nil) then
          goto next_item;
      end;
    end
    else if (GetTypeKind(TKey) = tkFloat) then
    begin
      case SizeOf(TKey) of
        4:
          begin
            if (PSingle(@Key)^ <> PSingle(Result)^) then
              goto next_item;
          end;
        10:
          begin
            if (PExtended(@Key)^ <> PExtended(Result)^) then
              goto next_item;
          end;
      else
        {$IFDEF LARGEINT}
        if (PInt64(@Key)^ <> PInt64(Result)^) then
          {$ELSE .SMALLINT}
        if ((PPoint(@Key).X - PPoint(Result).X) or (PPoint(@Key).Y - PPoint(Result).Y) <> 0) then
          {$ENDIF}
        begin
          if (TRAIIHelper<TKey>.Options.ItemSize < 0) then
            goto next_item;
          if (PDouble(@Key)^ <> PDouble(Result)^) then
            goto next_item;
        end;
      end;
    end
    else if (not (GetTypeKind(TKey) in [tkDynArray, tkString, tkLString, tkWString, tkUString])) and
      (SizeOf(TKey) <= 16) then
    begin
      // small binary
      if (SizeOf(TKey) <> 0) then
        with PData16(@Key)^ do
        begin
          if (SizeOf(TKey) >= SizeOf(Integer)) then
          begin
            if (SizeOf(TKey) >= SizeOf(Int64)) then
            begin
              {$IFDEF LARGEINT}
              if (Int64s[0] <> PData16(Result).Int64s[0]) then
                goto next_item;
              {$ELSE}
              if (Integers[0] <> PData16(Result).Integers[0]) then
                goto next_item;
              if (Integers[1] <> PData16(Result).Integers[1]) then
                goto next_item;
              {$ENDIF}

              if (SizeOf(TKey) = 16) then
              begin
                {$IFDEF LARGEINT}
                if (Int64s[1] <> PData16(Result).Int64s[1]) then
                  goto next_item;
                {$ELSE}
                if (Integers[2] <> PData16(Result).Integers[2]) then
                  goto next_item;
                if (Integers[3] <> PData16(Result).Integers[3]) then
                  goto next_item;
                {$ENDIF}
              end
              else if (SizeOf(TKey) >= 12) then
              begin
                if (Integers[2] <> PData16(Result).Integers[2]) then
                  goto next_item;
              end;
            end
            else
            begin
              if (Integers[0] <> PData16(Result).Integers[0]) then
                goto next_item;
            end;
          end;

          if (SizeOf(TKey) and 2 <> 0) then
          begin
            if (Words[(SizeOf(TKey) and -4) shr 1] <> PData16(Result).Words[(SizeOf(TKey) and -4) shr 1]) then
              goto next_item;
          end;
          if (SizeOf(TKey) and 1 <> 0) then
          begin
            if (Bytes[SizeOf(TKey) and -2] <> PData16(Result).Bytes[SizeOf(TKey) and -2]) then
              goto next_item;
          end;
        end;
    end
    else
    begin
      if (GetTypeKind(TKey) in [tkDynArray, tkString, tkLString, tkWString, tkUString]) then
      begin
        // dynamic size
        if (GetTypeKind(TKey) = tkString) then
        begin
          Left := Pointer(@Key);
          Right := Pointer(Result);
          if (PItem(Left) = {Right}Result) then
            goto cmp0;
          Count := Left^;
          if (Count <> Right^) then
            goto next_item;
          if (Count = 0) then
            goto cmp0;
          // compare last bytes
          if (Left[Count] <> Right[Count]) then
            goto next_item;
        end
        else
        // if (GetTypeKind(TKey) in [tkDynArray, tkLString, tkWString, tkUString]) then
        begin
          Left := PPointer(@Key)^;
          Right := PPointer(Result)^;
          if (Left = Right) then
            goto cmp0;
          if (Left = nil) then
          begin
            {$IFDEF MSWINDOWS}
            if (GetTypeKind(TKey) = tkWString) then
            begin
              Dec(Right, SizeOf(Cardinal));
              if (PCardinal(Right)^ = 0) then
                goto cmp0;
            end;
            {$ENDIF}
            goto next_item;
          end;
          if (Right = nil) then
          begin
            {$IFDEF MSWINDOWS}
            if (GetTypeKind(TKey) = tkWString) then
            begin
              Dec(Left, SizeOf(Cardinal));
              if (PCardinal(Left)^ = 0) then
                goto cmp0;
            end;
            {$ENDIF}
            goto next_item;
          end;

          if (GetTypeKind(TKey) = tkDynArray) then
          begin
            Dec(Left, SizeOf(NativeUInt));
            Dec(Right, SizeOf(NativeUInt));
            Count := PNativeUInt(Left)^;
            if (Count <> PNativeUInt(Right)^) then
              goto next_item;
            NativeInt(Count) := NativeInt(Count) * TRAIIHelper<TKey>.Options.ItemSize;
            Inc(Left, SizeOf(NativeUInt));
            Inc(Right, SizeOf(NativeUInt));
          end
          else
          // if (GetTypeKind(TKey) in [tkLString, tkWString, tkUString]) then
          begin
            Dec(Left, SizeOf(Cardinal));
            Dec(Right, SizeOf(Cardinal));
            Count := PCardinal(Left)^;
            if (Cardinal(Count) <> PCardinal(Right)^) then
              goto next_item;
            Inc(Left, SizeOf(Cardinal));
            Inc(Right, SizeOf(Cardinal));
          end;
        end;

        // compare last (after cardinal) words
        if (GetTypeKind(TKey) in [tkDynArray, tkString, tkLString]) then
        begin
          if (GetTypeKind(TKey) in [tkString, tkLString]) {ByteStrings + 2} then
          begin
            Inc(Count);
          end;
          if (Count and 2 <> 0) then
          begin
            Offset := Count and -4;
            Inc(Left, Offset);
            Inc(Right, Offset);
            if (PWord(Left)^ <> PWord(Right)^) then
              goto next_item;
            Offset := Count;
            Offset := Offset and -4;
            Dec(Left, Offset);
            Dec(Right, Offset);
          end;
        end
        else
        // modify Count to have only cardinals to compare
        // if (GetTypeKind(TKey) in [tkWString, tkUString]) {UnicodeStrings + 2} then
        begin
          {$IFDEF MSWINDOWS}
          if (GetTypeKind(TKey) = tkWString) then
          begin
            if (Count = 0) then
              goto cmp0;
          end
          else
            {$ENDIF}
          begin
            Inc(Count, Count);
          end;
          Inc(Count, 2);
        end;

        {$IFDEF LARGEINT}
        if (Count and 4 <> 0) then
        begin
          Offset := Count and -8;
          Inc(Left, Offset);
          Inc(Right, Offset);
          if (PCardinal(Left)^ <> PCardinal(Right)^) then
            goto next_item;
          Dec(Left, Offset);
          Dec(Right, Offset);
        end;
        {$ENDIF}
      end
      else
      begin
        // non-dynamic (constant) size binary > 16
        if (SizeOf(TKey) and {$IFDEF LARGEINT}7{$ELSE}3{$ENDIF} <> 0) then
          with PData16(@Key)^ do
          begin
            {$IFDEF LARGEINT}
            if (SizeOf(TKey) and 4 <> 0) then
            begin
              if (Integers[(SizeOf(TKey) and -8) shr 2] <> PData16(Result).Integers[(SizeOf(TKey) and -8) shr 2]) then
                goto next_item;
            end;
            {$ENDIF}
            if (SizeOf(TKey) and 2 <> 0) then
            begin
              if (Words[(SizeOf(TKey) and -4) shr 1] <> PData16(Result).Words[(SizeOf(TKey) and -4) shr 1]) then
                goto next_item;
            end;
            if (SizeOf(TKey) and 1 <> 0) then
            begin
              if (Bytes[SizeOf(TKey) and -2] <> PData16(Result).Bytes[SizeOf(TKey) and -2]) then
                goto next_item;
            end;
          end;
        Left := Pointer(@Key);
        Right := Pointer(Result);
        Count := SizeOf(TKey);
      end;

      // natives (40 bytes static) compare
      Count := Count shr {$IFDEF LARGEINT}3{$ELSE}2{$ENDIF};
      case Count of
        {$IFDEF SMALLINT}
        10: goto cmp10;
        9: goto cmp9;
        8: goto cmp8;
        7: goto cmp7;
        6: goto cmp6;
        {$ENDIF}
        5: goto cmp5;
        4: goto cmp4;
        3: goto cmp3;
        2: goto cmp2;
        1: goto cmp1;
        0: goto cmp0;
      else
        repeat
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            goto next_item;
          Dec(Count);
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
        until (Count = {$IFDEF LARGEINT}5{$ELSE}10{$ENDIF});

        {$IFDEF SMALLINT}
        cmp10:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp9:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp8:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp7:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp6:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        {$ENDIF}
        cmp5:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp4:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp3:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp2:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        Inc(Left, SizeOf(NativeUInt));
        Inc(Right, SizeOf(NativeUInt));
        cmp1:
        if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
          goto next_item;
        cmp0:
      end;
    end;

    // found
    Mode := FindMode;
    if (Mode and FOUND_MASK = 0) then
      Exit;
    Cardinal(Mode) := Cardinal(Mode) and FOUND_MASK;
    if (Mode <> FOUND_EXCEPTION) then
    begin
      if (Mode = FOUND_DELETE) then
      begin
        Pointer(Stored.Parent^) := Result.FNext;

        _Self1 := Stored.Self;
        with _Self1 do
          if (not Assigned(FInternalItemNotify)) then
          begin
            DisposeItem(Result);
          end
          else
          begin
            FInternalItemNotify(Result^, cnRemoved);
            DisposeItem(Result);
          end;
      end
      else
      // if (Mode = FOUND_REPLACE) then
      begin
        _Self1 := Stored.Self;
        with _Self1 do
          if (not Assigned(FInternalValueNotify)) then
          begin
            Result.FValue := FInternalFindValue^;
          end
          else
          begin
            FInternalValueNotify(_Self1, Result.Value, cnRemoved);
            Result.FValue := FInternalFindValue^;
            FInternalValueNotify(_Self1, Result.Value, cnAdded);
          end;
      end;
    end
    else
    begin
      raise EListError.CreateRes(Pointer(@SGenericDuplicateItem));
    end;
    Exit;

    // not found (Result = nil)
    not_found:
    Mode := FindMode;
    if (Mode and EMPTY_MASK = 0) then
      Exit;
    if (Mode and EMPTY_EXCEPTION = 0) then
    begin
      // EMPTY_NEW
      _Self2 := Stored.Self;
      with _Self2 do
      begin
        Result := NewItem;
        Result.FKey := Key;
        Result.FHashCode := Stored.HashCode;
        Parent := Pointer(@FHashTable[NativeInt(Cardinal(Stored.HashCode)) and FHashTableMask]);
        Result.FNext := Parent^;
        Parent^ := Result;
        Result.FValue := FInternalFindValue^;
        if (Assigned(FInternalItemNotify)) then
        begin
          FInternalItemNotify(Result^, cnAdded);
        end;
      end;
    end
    else
    begin
      raise EListError.CreateRes(Pointer(@SGenericItemNotFound));
    end;
    Exit;
  until (False);
end;

function TRapidDictionary<TKey, TValue>.GetItem(const Key: TKey): TValue;
begin
  Result := TCustomDictionary<TKey, TValue>.PItem(Self.InternalFindItem(Key, FOUND_NONE + EMPTY_EXCEPTION)).Value;
end;

procedure TRapidDictionary<TKey, TValue>.SetItem(const Key: TKey; const Value: TValue);
begin
  Self.FInternalFindValue := @Value;
  Self.InternalFindItem(Key, FOUND_REPLACE + EMPTY_EXCEPTION);
end;

function TRapidDictionary<TKey, TValue>.Find(const Key: TKey): Pointer {PItem};
begin
  Result := Self.InternalFindItem(Key, FOUND_NONE + EMPTY_NONE);
end;

function TRapidDictionary<TKey, TValue>.FindOrAdd(const Key: TKey): Pointer {PItem};
begin
  Self.FInternalFindValue := @Self.FDefaultValue;
  Result := Self.InternalFindItem(Key, FOUND_NONE + EMPTY_NEW);
end;

procedure TRapidDictionary<TKey, TValue>.Add(const Key: TKey; const Value: TValue);
begin
  Self.FInternalFindValue := @Value;
  Self.InternalFindItem(Key, FOUND_EXCEPTION + EMPTY_NEW);
end;

procedure TRapidDictionary<TKey, TValue>.Remove(const Key: TKey);
begin
  Self.InternalFindItem(Key, FOUND_DELETE + EMPTY_NONE)
end;

function TRapidDictionary<TKey, TValue>.ExtractPair(const Key: TKey): TPair<TKey, TValue>;
var
  Parent: Pointer;
  Item, Current: TCustomDictionary<TKey, TValue>.PItem;
begin
  Result.Key := Key;
  Item := Self.InternalFindItem(Key, FOUND_NONE + EMPTY_NONE);
  if (Item = nil) then
  begin
    Result.Value := Default(TValue);
    Exit;
  end;

  Result.Value := Item.Value;
  Parent := Pointer(@Self.FHashTable[NativeInt(Cardinal(Item.HashCode)) and Self.FHashTableMask]);
  repeat
    Current := TCustomDictionary<TKey, TValue>.PItem(Parent^);

    if (Item = Current) then
    begin
      TCustomDictionary<TKey, TValue>.PItem(Parent^) := Item.FNext;

      if (not Assigned(Self.FInternalItemNotify)) then
      begin
        Self.DisposeItem(Item);
      end
      else
      begin
        Self.FInternalItemNotify(Item^, cnExtracted);
        Self.DisposeItem(Item);
      end;

      Exit;
    end;

    Parent := Pointer(@Current.FNext);
  until (False);
end;

function TRapidDictionary<TKey, TValue>.TryGetValue(const Key: TKey; out Value: TValue): Boolean;
var
  Item: PItem;
begin
  Item := Self.InternalFindItem(Key, FOUND_NONE + EMPTY_NONE);
  if Assigned(Item) then
  begin
    Value := Item.Value;
    Result := True;
  end
  else
  begin
    Value := Default(TValue);
    Result := False;
  end;
end;

function TRapidDictionary<TKey, TValue>.ContainsKey(const Key: TKey): Boolean;
begin
  Result := (Self.InternalFindItem(Key, FOUND_NONE + EMPTY_NONE) <> nil);
end;

{ TCustomList<T>.TEnumerator }

function TCustomList<T>.TEnumerator.MoveNext: Boolean;
var
  N, Cap: NativeInt;
begin
  N := Data.Tag + 1;
  with TCustomList<T>(Data.Owner) do
  begin
    if (N < FCount.Native) then
    begin
      Data.Tag := N;

      Inc(N, FTail);
      Cap := FCapacity.Native;
      if (N > Cap) then
        Dec(N, Cap);
      Data.Current := FItems[N];

      Exit(True);
    end;
  end;
  Result := False;
end;

{ TCustomList<T> }

constructor TCustomList<T>.Create;
begin
  inherited Create;
  SetNotifyMethods;
end;

class procedure TCustomList<T>.ClearMethod(var Method);
begin
  {$IFDEF WEAKINSTREF}
  TMethod(Method).Data := nil;
  {$ENDIF}
end;

destructor TCustomList<T>.Destroy;
begin
  Clear;
  ClearMethod(FInternalNotify);
  inherited;
end;

class function TCustomList<T>.EmptyException: Exception;
begin
  Result := EListError.CreateRes(Pointer(@SUnbalancedOperation));
end;

procedure TCustomList<T>.SetCapacity(Value: Integer);
var
  Dif, NewTail: NativeInt;
  OldCapacity: NativeInt;
  {$IFDEF WEAKREF}
  WeakItems: PItemList;
  {$ENDIF}
begin
  if (Value = FCapacity.Int) then
    Exit;
  if Value < Count then
    ErrorArgumentOutOfRange;

  {$IFDEF WEAKREF}
  if (TRAIIHelper<T>.Weak) then
  begin
    GetMem(WeakItems, Value * SizeOf(T));

    if (FCount.Native <> 0) then
    begin
      FillChar(Pointer(WeakItems)^, FCount.Native * SizeOf(T), #0);

      if (FTail <= FHead) then
      begin
        System.CopyArray(@WeakItems[0], @FItems[FTail], TypeInfo(T), FCount.Native);
        System.FinalizeArray(@FItems[FTail], TypeInfo(T), FCount.Native);
      end
      else
      begin
        System.CopyArray(@WeakItems[0], @FItems[FTail], TypeInfo(T), FCapacity.Native - FTail);
        System.FinalizeArray(@FItems[FTail], TypeInfo(T), FCapacity.Native - FTail);
        System.CopyArray(@WeakItems[FCapacity.Native - FTail], @FItems[0], TypeInfo(T), FHead);
        System.FinalizeArray(@FItems[0], TypeInfo(T), FHead);
      end;
    end;

    FreeMem(FItems);
    FItems := WeakItems;
    FTail := 0;
    FHead := FCount.Native;
    FCapacity.Native := Value;
  end
  else
    {$ENDIF}
    if (FCount.Native = 0) then
    begin
      FTail := 0;
      FHead := 0;
      OldCapacity := FCapacity.Native;
      FCapacity.Native := Value;
      ReallocMem(FItems, Value * SizeOf(T));
      if Value > OldCapacity then
        FillChar(FItems[OldCapacity], (Value - OldCapacity) * SizeOf(T), 0);
    end
  else
  if (FTail <= FHead) then
    begin
      if (FTail <> 0) then
      begin
        System.Move(FItems[FTail], FItems[0], FCount.Native * SizeOf(T));
        Dec(FHead, FTail);
        FTail := 0;
      end;
      OldCapacity := FCapacity.Native;
      FCapacity.Native := Value;
      ReallocMem(FItems, Value * SizeOf(T));
      if Value > OldCapacity then
        FillChar(FItems[OldCapacity], (Value - OldCapacity) * SizeOf(T), 0);
    end
    else
    begin
      Dif := NativeInt(Value) - FCapacity.Native;
      NewTail := FTail + Dif;

      OldCapacity := FCapacity.Native;

      if (Dif > 0) then
      begin
        ReallocMem(FItems, Value * SizeOf(T));
        System.Move(FItems[FTail], FItems[NewTail], (OldCapacity - FTail) * SizeOf(T));
        FillChar(FItems[OldCapacity], (Value - OldCapacity) * SizeOf(T), 0);
      end
      else
    //if (Dif < 0) then
      begin
        System.Move(FItems[FTail], FItems[NewTail], (OldCapacity - FTail) * SizeOf(T));
        ReallocMem(FItems, Value * SizeOf(T));
      end;

      FCapacity.Native := Value;
      FTail := NewTail;
    end;
end;

procedure TCustomList<T>.Grow;
var
  OldCapacity, NewCapacity: Integer;
begin
  OldCapacity := FCapacity.Int;
  NewCapacity := OldCapacity * 2;
  if (NewCapacity < 0) then
    OutOfMemoryError;
  if (NewCapacity < 4) then
    NewCapacity := 4;

  SetCapacity(NewCapacity);
end;

procedure TCustomList<T>.GrowTo(Value: Integer);
var
  OldCapacity, NewCapacity: Integer;
begin
  OldCapacity := FCapacity.Int;
  NewCapacity := OldCapacity * 2;
  if (NewCapacity < 0) then
    OutOfMemoryError;
  if (NewCapacity < 4) then
    NewCapacity := 4;

  while (NewCapacity < Value) do
  begin
    NewCapacity := NewCapacity * 2;
    if (NewCapacity < 0) then
      OutOfMemoryError;
  end;

  SetCapacity(NewCapacity)
end;

procedure TCustomList<T>.Clear;
var
  i: NativeInt;
  Item: PItem;
begin
  if (FItems = nil) then
    Exit;

  if (Assigned(FInternalNotify)) then
  begin
    Item := @FItems[FTail];

    if (FTail <= FHead) then
    begin
      if (TMethod(FInternalNotify).Code = @TCustomList<T>.NotifyCaller) then
      begin
        for i := 1 to FCount.Native do
        begin
          Self.Notify(Item^, cnRemoved);
          Inc(Item);
        end;
      end
      else
      begin
        for i := 1 to FCount.Native do
        begin
          FInternalNotify(Self, Item^, cnRemoved);
          Inc(Item);
        end;
      end;
    end
    else if (TMethod(FInternalNotify).Code = @TCustomList<T>.NotifyCaller) then
    begin
      for i := FTail to FCapacity.Native - 1 do
      begin
        Self.Notify(Item^, cnRemoved);
        Inc(Item);
      end;
      Item := @FItems[0];
      for i := 0 to FHead - 1 do
      begin
        Self.Notify(Item^, cnRemoved);
        Inc(Item);
      end;
    end
    else
    begin
      for i := FTail to FCapacity.Native - 1 do
      begin
        FInternalNotify(Self, Item^, cnRemoved);
        Inc(Item);
      end;
      Item := @FItems[0];
      for i := 0 to FHead - 1 do
      begin
        FInternalNotify(Self, Item^, cnRemoved);
        Inc(Item);
      end;
    end;
  end;

  if (System.IsManagedType(T)) then
  begin
    if (FTail <= FHead) then
    begin
      TRAIIHelper<T>.ClearArray(@FItems[FTail], FCount.Native);
    end
    else
    begin
      TRAIIHelper<T>.ClearArray(@FItems[FTail], FCapacity.Native - FTail - 1);
      TRAIIHelper<T>.ClearArray(@FItems[0], FHead);
    end;
  end;

  FCapacity.Native := 0;
  FTail := 0;
  FHead := 0;
  FCount.Native := 0;
  ReallocMem(FItems, 0);
end;

procedure TCustomList<T>.TrimExcess;
begin
  SetCapacity(Count);
end;

procedure TCustomList<T>.SetOnNotify(const Value: TCollectionNotifyEvent<T>);
begin
  if (TMethod(FOnNotify).Code <> TMethod(Value).Code) or
    (TMethod(FOnNotify).Data <> TMethod(Value).Data) then
  begin
    FOnNotify := Value;
    SetNotifyMethods;
  end;
end;

procedure TCustomList<T>.Notify(const Item: T; Action: TCollectionNotification);
begin
  if Assigned(FOnNotify) then
    FOnNotify(Self, Item, Action);
end;

procedure TCustomList<T>.NotifyCaller(Sender: TObject; const Item: T; Action: TCollectionNotification);
begin
  Self.Notify(Item, Action);
end;

procedure TCustomList<T>.SetNotifyMethods;
var
  VMTNotify: procedure(const Item: T; Action: TCollectionNotification) of object;
begin
  VMTNotify := Self.Notify;
  if (TMethod(VMTNotify).Code <> @TCustomList<T>.Notify) then
  begin
    TMethod(FInternalNotify).Data := Pointer(Self);
    TMethod(FInternalNotify).Code := @TCustomList<T>.NotifyCaller;
  end
  else
  begin
    TMethod(FInternalNotify) := TMethod(Self.FOnNotify);
  end;
end;

function TCustomList<T>.DoGetCount: Integer;
begin
  Result := FCount.Int;
end;

function TCustomList<T>.DoGetEnumerator: TCollectionEnumerator<T>;
begin
  Result.Data.Init(Self);
  Pointer(@Result.DoMoveNext) := @TEnumerator.MoveNext;
end;

function TCustomList<T>.GetEnumerator: TEnumerator;
begin
  Result.Data.Init(Self);
end;

function TCustomList<T>.IsEmpty: Boolean;
begin
  Result := FCount.Int = 0;
end;

function TCustomList<T>.ToArray: TArray<T>;
var
  Count, TailCount: NativeInt;
begin
  Count := FCount.Native;
  if (Count <> 0) then
  begin
    if (Pointer(Result) <> nil) then
      Result := nil;
    SetLength(Result, Count);

    if (FTail <= FHead) then
    begin
      if (System.IsManagedType(T)) then
      begin
        System.CopyArray(Pointer(Result), @FItems[FTail], TypeInfo(T), Count);
      end
      else
      begin
        System.Move(FItems[FTail], Pointer(Result)^, Count * SizeOf(T));
      end;
    end
    else
    begin
      TailCount := FCapacity.Native - FTail - 1;

      if (System.IsManagedType(T)) then
      begin
        System.CopyArray(Pointer(Result), @FItems[FTail], TypeInfo(T), TailCount);
        System.CopyArray(@Result[TailCount], @FItems[0], TypeInfo(T), FHead);
      end
      else
      begin
        System.Move(FItems[FTail], Pointer(Result)^, TailCount * SizeOf(T));
        System.Move(FItems[0], Result[TailCount], FHead * SizeOf(T));
      end;
    end;
  end
  else
  begin
    if (Pointer(Result) <> nil) then
      Result := nil;
  end;
end;

{ TList<T> }

constructor TList<T>.Create;
begin
  inherited Create;
end;

constructor TList<T>.Create(const AComparer: IComparer<T>);
begin
  Create;
  if (Pointer(AComparer) <> @InterfaceDefaults.TDefaultComparer<T>.Instance) then
    FComparer := AComparer;
end;

constructor TList<T>.Create(const Collection: TEnumerable<T>);
begin
  Create;
  InsertRange(0, Collection);
end;

class procedure TList<T>.Error(const Msg: string; Data: NativeInt);
begin
  raise EListError.CreateFmt(Msg, [Data])at ReturnAddress;
end;

{$IFNDEF NEXTGEN}
class procedure TList<T>.Error(Msg: PResStringRec; Data: NativeInt);
begin
  raise EListError.CreateFmt(LoadResString(Msg), [Data])at ReturnAddress;
end;
{$ENDIF}

procedure TList<T>.SetCount(Value: Integer);
var
  Count: Integer;
begin
  Count := FCount.Int;
  if (Value < 0) then
  begin
    ErrorArgumentOutOfRange;
  end
  else if (Value < Count) then
  begin
    DeleteRange(Value, Count - Value);
  end
  else if (Value > Count) then
  begin
    if (Value > FCapacity.Int) then
      GrowTo(Value);

    if (System.IsManagedType(T)) then
    begin
      TRAIIHelper<T>.InitArray(@FItems[FCount.Native], Value - FCount.Int);
    end;

    FCount.Int := Value;
  end;
end;

function TList<T>.GetItem(Index: Integer): T;
begin
  if (Cardinal(Index) > Cardinal(FCount.Int)) then
    ErrorArgumentOutOfRange(Index, FCount.Int, Self);
  Result := FItems[Index];
end;

procedure TList<T>.ReplaceItemNotify(Index: Integer; const Value: T);
var
  Item: ^T;
begin
  Item := @FItems[Index];

  if (TMethod(FInternalNotify).Code = @TCustomList<T>.NotifyCaller) then
  begin
    Self.Notify(Item^, cnRemoved);
    Item^ := Value;
    Self.Notify(Value, cnAdded);
  end
  else
  begin
    FInternalNotify(Self, Item^, cnRemoved);
    Item^ := Value;
    FInternalNotify(Self, Value, cnAdded);
  end;
end;

procedure TList<T>.SetItem(Index: Integer; const Value: T);
begin
  if (Cardinal(Index) < Cardinal(FCount.Int)) then
  begin
    if (not Assigned(FInternalNotify)) then
    begin
      FItems[Index] := Value;
    end
    else
    begin
      ReplaceItemNotify(Index, Value);
    end;
  end
  else
  begin
    ErrorArgumentOutOfRange(Index, FCount.Int, Self);
  end;
end;

{$WARNINGS OFF} // compiler doesn't identify exception

function TList<T>.First: T;
begin
  if (FCount.Native <> 0) then
  begin
    Result := FItems[0];
  end
  else
  begin
    ErrorArgumentOutOfRange(0, FCount.Int, Self);
  end;
end;

function TList<T>.Last: T;
var
  LCount: NativeInt;
begin
  LCount := FCount.Native;
  if (LCount <> 0) then
  begin
    Dec(LCount);
    Result := FItems[LCount];
  end
  else
  begin
    ErrorArgumentOutOfRange(LCount - 1, FCount.Int, Self);
  end;
end;
{$WARNINGS ON}

function TList<T>.ItemValue(const Item: T): NativeInt;
begin
  case SizeOf(T) of
    1: Result := PByte(@Item)^;
    2: Result := PWord(@Item)^;
    3: Result := PWord(@Item)^ + PByte(@Item)[2] shl 16;
    {$IFDEF LARGEINT}
    4: Result := PCardinal(@Item)^;
    5: Result := NativeInt(PCardinal(@Item)^) +
      NativeInt(PByte(@Item)[4]) shl 32;
    6: Result := NativeInt(PCardinal(@Item)^) +
      NativeInt(PWord(PByte(@Item) + SizeOf(Cardinal))^) shl 32;
    7: Result := NativeInt(PCardinal(@Item)^) +
      NativeInt(PWord(PByte(@Item) + SizeOf(Cardinal))^) shl 32 + NativeInt(PByte(@Item)[6]) shl 48;
    {$ENDIF}
  else
    Result := PNativeInt(@Item)^;
  end;
end;

{$IFDEF WEAKREF}
class procedure TList<T>.InternalWeakInsert(const Item: Pointer; const ItemsCount, InsertCount: NativeUInt);
var
  Source, Destination: ^T;
begin
  // init appended items
  Source := Item;
  Inc(Source, ItemsCount);
  TRAIIHelper<T>.InitArray(Source, InsertCount);

  // move items
  Destination := Source + InsertCount;
  repeat
    Dec(Source);
    Dec(Destination);
    Destination^ := Source^;
  until (Source = Item);

  // clear + init (Finalization)
  TRAIIHelper<T>.ClearArray(Item, InsertCount);
  TRAIIHelper<T>.InitArray(Item, InsertCount);
end;
{$ENDIF}

function TList<T>.InternalInsert(Index: NativeInt; const Value: T): Integer;
var
  Count, Null: NativeInt;
  Item: ^TRAIIHelper.TData16;
begin
  Result := Index;
  Count := FCount.Native;
  Item := nil; //satisfy compiler
  if (NativeUInt(Index) <= NativeUInt(Count)) then
  begin
    repeat
      if (Count <> FCapacity.Native) then
      begin
        Inc(Count);
        FCount.Native := Count;
        Dec(Count);
        if (Index <> Count) then
        begin
          {$IFDEF WEAKREF}
          if (TRAIIHelper<T>.Weak) then
          begin
            InternalWeakInsert(Item, Count - Index, 1);
          end
          else
            {$ENDIF}
          begin
            Count := (Count - Index) * SizeOf(T);
            Item := Pointer(@FItems[Index]);
            System.Move(Item^, PByte(PByte(Item) + SizeOf(T))^, Count);
          end;

          Index := Result;
        end;
        Item := Pointer(@FItems[Index]);

        if (System.IsManagedType(T)) then
        begin
          if (GetTypeKind(T) = tkVariant) then
          begin
            Item.Integers[0] := 0;
          end
          else if (SizeOf(T) <= 16) then
          begin
            Null := 0;
            {$IFDEF SMALLINT}
            if (SizeOf(T) >= SizeOf(Integer) * 1) then
              Item.Integers[0] := Null;
            if (SizeOf(T) >= SizeOf(Integer) * 2) then
              Item.Integers[1] := Null;
            if (SizeOf(T) >= SizeOf(Integer) * 3) then
              Item.Integers[2] := Null;
            if (SizeOf(T) = SizeOf(Integer) * 4) then
              Item.Integers[3] := Null;
            {$ELSE .LARGEINT}
            if (SizeOf(T) >= SizeOf(Int64) * 1) then
              Item.Int64s[0] := Null;
            if (SizeOf(T) = SizeOf(Int64) * 2) then
              Item.Int64s[1] := Null;
            case SizeOf(T) of
              4..7: Item.Integers[0] := Null;
              12..15: Item.Integers[2] := Null;
            end;
            {$ENDIF}
            case SizeOf(T) of
              2, 3: Item.Words[0] := 0;
              6, 7: Item.Words[2] := 0;
              10, 11: Item.Words[4] := 0;
              14, 15: Item.Words[6] := 0;
            end;
            case SizeOf(T) of
              1: Item.Bytes[1 - 1] := 0;
              3: Item.Bytes[3 - 1] := 0;
              5: Item.Bytes[5 - 1] := 0;
              7: Item.Bytes[7 - 1] := 0;
              9: Item.Bytes[9 - 1] := 0;
              11: Item.Bytes[11 - 1] := 0;
              13: Item.Bytes[13 - 1] := 0;
              15: Item.Bytes[15 - 1] := 0;
            end;
          end
          else
          begin
            TRAIIHelper<T>.Init(Pointer(Item));
          end;
        end;

        PItem(Item)^ := Value;
        if Assigned(FInternalNotify) then
          FInternalNotify(Self, Value, cnAdded);
        Exit;
      end
      else
      begin
        Self.Grow;
        Count := FCount.Native;
        Index := Result;
      end;
    until (False);
  end
  else
  begin
    ErrorArgumentOutOfRange;
  end;
end;

function TList<T>.Add(const Value: T): Integer;
var
  Count, Null: NativeInt;
  Item: TRAIIHelper.PData16;
begin
  Count := FCount.Native;
  if (Count <> FCapacity.Native) and (not Assigned(FInternalNotify)) then
  begin
    Inc(Count);
    FCount.Native := Count;
    Dec(Count);
    Item := Pointer(@FItems[Count]);

    if (System.IsManagedType(T)) then
    begin
      if (GetTypeKind(T) = tkVariant) then
      begin
        Item.Integers[0] := 0;
      end
      else if (SizeOf(T) <= 16) then
      begin
        Null := 0;
        {$IFDEF SMALLINT}
        if (SizeOf(T) >= SizeOf(Integer) * 1) then
          Item.Integers[0] := Null;
        if (SizeOf(T) >= SizeOf(Integer) * 2) then
          Item.Integers[1] := Null;
        if (SizeOf(T) >= SizeOf(Integer) * 3) then
          Item.Integers[2] := Null;
        if (SizeOf(T) = SizeOf(Integer) * 4) then
          Item.Integers[3] := Null;
        {$ELSE .LARGEINT}
        if (SizeOf(T) >= SizeOf(Int64) * 1) then
          Item.Int64s[0] := Null;
        if (SizeOf(T) = SizeOf(Int64) * 2) then
          Item.Int64s[1] := Null;
        case SizeOf(T) of
          4..7: Item.Integers[0] := Null;
          12..15: Item.Integers[2] := Null;
        end;
        {$ENDIF}
        case SizeOf(T) of
          2, 3: Item.Words[0] := 0;
          6, 7: Item.Words[2] := 0;
          10, 11: Item.Words[4] := 0;
          14, 15: Item.Words[6] := 0;
        end;
        case SizeOf(T) of
          1: Item.Bytes[1 - 1] := 0;
          3: Item.Bytes[3 - 1] := 0;
          5: Item.Bytes[5 - 1] := 0;
          7: Item.Bytes[7 - 1] := 0;
          9: Item.Bytes[9 - 1] := 0;
          11: Item.Bytes[11 - 1] := 0;
          13: Item.Bytes[13 - 1] := 0;
          15: Item.Bytes[15 - 1] := 0;
        end;
      end
      else
      begin
        TRAIIHelper<T>.Init(Pointer(Item));
      end;
    end;

    PItem(Item)^ := Value;
    Result := Count;
    Exit;
  end
  else
  begin
    Result := InternalInsert(Count, Value);
  end;
end;

procedure TList<T>.Insert(Index: Integer; const Value: T);
begin
  InternalInsert(Index, Value);
end;

procedure TList<T>.AddRange(const Values: array of T);
var
  Count, ValuesCount: NativeInt;
  Item, Source, Buffer: PItem;
  Stored: TInternalStored;
begin
  ValuesCount := High(Values);
  if (ValuesCount < 0) then
    Exit;
  Inc(ValuesCount);

  Stored.Self := Self;
  Stored.InternalNotify := TMethod(FInternalNotify);

  Count := FCount.Native;
  Inc(Count, ValuesCount);
  if (NativeUInt(Count) <= NativeUInt(High(Integer))) then
  begin
    repeat
      if (Count <= FCapacity.Native) then
      begin
        FCount.Native := Count;
        Dec(Count, ValuesCount);
        Buffer {Item} := @FItems[Count];

        if (System.IsManagedType(T)) then
        begin
          TRAIIHelper<T>.InitArray(Buffer {Item}, ValuesCount);
        end
        else if (not Assigned(Stored.InternalNotify.Code)) then
        begin
          System.Move(Values[0], Buffer {Item}^, ValuesCount * SizeOf(T));
          Exit;
        end;

        Source := @Values[0];
        Item := Buffer {Item};
        if (not Assigned(Stored.InternalNotify.Code)) then
        begin
          for ValuesCount := ValuesCount downto 1 do
          begin
            Item^ := Source^;
            Inc(Source);
            Inc(Item);
          end;
        end
        else
        begin
          for ValuesCount := ValuesCount downto 1 do
          begin
            Item^ := Source^;
            TCollectionNotifyEvent<T>(Stored.InternalNotify)(Stored.Self, Source^, cnAdded);
            Inc(Source);
            Inc(Item);
          end;
        end;
        Exit;
      end
      else
      begin
        Self.GrowTo(Count);
        Count := FCount.Native;
        Inc(Count, ValuesCount);
      end;
    until (False);
  end
  else
  begin
    OutOfMemoryError;
  end;
end;

procedure TList<T>.InsertRange(Index: Integer; const Values: array of T);
var
  Count, ValuesCount, AIndex: NativeInt;
  Item, Source, Buffer: PItem;
  Stored: TInternalStored;
begin
  ValuesCount := High(Values);
  if (ValuesCount < 0) then
    Exit;
  Inc(ValuesCount);

  Stored.Self := Self;
  Stored.InternalNotify := TMethod(FInternalNotify);
  Stored.Count := ValuesCount;
  AIndex := Index;

  Count := FCount.Native;
  if (NativeUInt(AIndex) <= NativeUInt(Count)) then
  begin
    Inc(Count, ValuesCount);
    if (NativeUInt(Count) <= NativeUInt(High(Integer))) then
    begin
      repeat
        if (Count <= FCapacity.Native) then
        begin
          FCount.Native := Count;
          Dec(Count, AIndex);
          Dec(Count, ValuesCount);
          Buffer {Item} := @FItems[AIndex];

          if (System.IsManagedType(T)) then
          begin
            {$IFDEF WEAKREF}
            if (TRAIIHelper<T>.Weak) then
            begin
              if (Count <> 0) then
              begin
                InternalWeakInsert(Buffer {Item}, Count, Stored.Count);
              end
              else
              begin
                TRAIIHelper<T>.InitArray(Buffer {Item}, Stored.Count);
              end;
            end
            else
              {$ENDIF}
            begin
              if (Count <> 0) then
              begin
                Count := Count * SizeOf(T);
                Source := Buffer {Item} + Stored.Count;
                System.Move(Buffer {Item}^, Source^, Count);
              end;

              TRAIIHelper<T>.InitArray(Buffer {Item}, Stored.Count);
            end;
          end
          else
          begin
            if (Count <> 0) then
            begin
              Count := Count * SizeOf(T);
              Source := Buffer {Item} + Stored.Count;
              System.Move(Buffer {Item}^, Source^, Count);
            end;

            if (not Assigned(Stored.InternalNotify.Code)) then
            begin
              System.Move(Values[0], Buffer {Item}^, Stored.Count * SizeOf(T));
              Exit;
            end;
          end;

          // insertion
          Source := @Values[0];
          Stored.Item := Source + Stored.Count;
          Item := Buffer {Item};
          if (not Assigned(Stored.InternalNotify.Code)) then
          begin
            repeat
              Item^ := Source^;
              Inc(Source);
              Inc(Item);
            until (Source = Stored.Item);
          end
          else
          begin
            repeat
              Item^ := Source^;
              TCollectionNotifyEvent<T>(Stored.InternalNotify)(Stored.Self, Source^, cnAdded);
              Inc(Source);
              Inc(Item);
            until (Source = Stored.Item);
          end;
          Exit;
        end
        else
        begin
          Self.GrowTo(Count);
          AIndex := Index;
          ValuesCount := Stored.Count;
          Count := FCount.Native;
          Inc(Count, ValuesCount);
        end;
      until (False);
    end
    else
    begin
      OutOfMemoryError;
    end;
  end
  else
  begin
    ErrorArgumentOutOfRange;
  end;
end;

procedure TList<T>.AddRange(const Collection: IEnumerable<T>);
var
  Item: T;
  Index: NativeInt;
begin
  if (not Assigned(FInternalNotify)) then
  begin
    for Item in Collection do
    begin
      Add(Item);
    end;
  end
  else
  begin
    Index := FCount.Native;
    for Item in Collection do
    begin
      InternalInsert(Index, Item);
      Inc(Index);
    end;
  end;
end;

procedure TList<T>.AddRange(const Collection: TEnumerable<T>);
var
  Item: T;
  Index: NativeInt;
begin
  if (not Assigned(FInternalNotify)) then
  begin
    for Item in Collection do
    begin
      Add(Item);
    end;
  end
  else
  begin
    Index := FCount.Native;
    for Item in Collection do
    begin
      InternalInsert(Index, Item);
      Inc(Index);
    end;
  end;
end;

procedure TList<T>.AddRange(const AList: TList<T>);
var
  I: Integer;
begin
  if Assigned(AList) then
  begin
    Capacity := AList.Count + AList.Count;
    for I := 0 to AList.Count - 1 do
      Add(AList.Items[I]);
  end;
end;

procedure TList<T>.InsertRange(Index: Integer; const Collection: IEnumerable<T>);
var
  Item: T;
begin
  if (Index = FCount.Int) and (not Assigned(FInternalNotify)) then
  begin
    AddRange(Collection);
    Exit;
  end;

  for Item in Collection do
  begin
    Insert(Index, Item);
    Inc(Index);
  end;
end;

procedure TList<T>.InsertRange(Index: Integer; const Collection: TEnumerable<T>);
var
  Item: T;
begin
  if (Index = FCount.Int) and (not Assigned(FInternalNotify)) then
  begin
    AddRange(Collection);
    Exit;
  end;

  for Item in Collection do
  begin
    Insert(Index, Item);
    Inc(Index);
  end;
end;

procedure TList<T>.InternalDelete(Index: NativeInt; Action: TCollectionNotification);
var
  LCount: NativeInt;
  Item: PItem;
  VType: Integer;
  Stored: TInternalStored;
begin
  LCount := FCount.Native;
  if (NativeUInt(Index) < NativeUInt(LCount)) then
  begin
    Dec(LCount);
    FCount.Native := LCount;
    Dec(LCount, Index);
    Item := @FItems[Index];

    if (Assigned(FInternalNotify)) then
    begin
      Stored.Item := Item;
      Stored.Count := LCount;
      FInternalNotify(Self, Stored.Item^, Action);
      Item := Stored.Item;
      LCount := Stored.Count;
    end;

    case GetTypeKind(T) of
      {$IFDEF AUTOREFCOUNT}
      tkClass,
        {$ENDIF}
      tkWString, tkLString, tkUString, tkInterface, tkDynArray:
        begin
          if (PNativeInt(Item)^ <> 0) then
            case GetTypeKind(T) of
              {$IFDEF AUTOREFCOUNT}
              tkClass:
                begin
                  TRAIIHelper.RefObjClear(Item);
                end;
              {$ENDIF}
              {$IFDEF MSWINDOWS}
              tkWString:
                begin
                  TRAIIHelper.WStrClear(Item);
                end;
              {$ELSE}
              tkWString,
                {$ENDIF}
              tkLString, tkUString:
                begin
                  TRAIIHelper.ULStrClear(Item);
                end;
              tkInterface:
                begin
                  IInterface(PPointer(Item)^)._Release;
                end;
              tkDynArray:
                begin
                  TRAIIHelper.DynArrayClear(Item, TypeInfo(T));
                end;
            end;
        end;
      {$IFDEF WEAKINSTREF}
      tkMethod:
        begin
          if (PMethod(Item).Data <> nil) then
            TRAIIHelper.WeakMethodClear(@PMethod(Item).Data);
        end;
      {$ENDIF}
      tkVariant:
        begin
          VType := PVarData(Item).VType;
          if (VType and TRAIIHelper.varDeepData <> 0) then
            case VType of
              varBoolean, varUnknown + 1..varUInt64: ;
            else
              System.VarClear(PVariant(Item)^);
            end;
        end;
    else
      begin
        TRAIIHelper<T>.Clear(Item);
      end;
    end;

    if (LCount <> 0) then
    begin
      {$IFDEF WEAKREF}
      if (TRAIIHelper<T>.Weak) then
      begin
        System.CopyArray(Item, Item + 1, TypeInfo(T), LCount);
        System.Finalize((Item + LCount)^);
      end
      else
        {$ENDIF}
      begin
        System.Move(Pointer(Item + 1)^, Item^, LCount * SizeOf(T));
      end;
    end;

    Exit;
  end
  else
  begin
    ErrorArgumentOutOfRange;
  end;
end;

procedure TList<T>.Delete(Index: Integer);
begin
  InternalDelete(Index, cnRemoved);
end;

procedure TList<T>.DeleteRange(AIndex, ACount: Integer);
var
  LCount, Index: NativeInt;
  Item: PItem;
  VType: Integer;
  Stored: TInternalStored;
begin
  if (AIndex >= 0) and (ACount >= 0) then
  begin
    Index := NativeInt(AIndex) + NativeInt(ACount);
    LCount := FCount.Native;
    if (Index >= 0) and (Index <= LCount) then
    begin
      if (ACount = 0) then
        Exit;
      Dec(LCount, ACount);
      Dec(Index, ACount);
      FCount.Native := LCount;
      Dec(LCount, Index);
      Item := @FItems[Index];

      if (Assigned(FInternalNotify)) then
      begin
        Stored.Self := Self;
        Stored.InternalNotify := TMethod(FInternalNotify);
        Stored.Count := LCount;
        Stored.ACount := ACount;
        for ACount := ACount downto 1 do
        begin
          TCollectionNotifyEvent<T>(Stored.InternalNotify)(Stored.Self, Item^, cnRemoved);
          Inc(Item);
        end;
        // Not used
        //LCount := Stored.Count;
        ACount := Stored.ACount;
        Dec(Item, ACount);
      end;

      if (System.IsManagedType(T)) then
      begin
        Stored.ACount := ACount;
        for ACount := ACount downto 1 do
        begin
          case GetTypeKind(T) of
            {$IFDEF AUTOREFCOUNT}
            tkClass,
              {$ENDIF}
            tkWString, tkLString, tkUString, tkInterface, tkDynArray:
              begin
                if (PNativeInt(Item)^ <> 0) then
                  case GetTypeKind(T) of
                    {$IFDEF AUTOREFCOUNT}
                    tkClass:
                      begin
                        TRAIIHelper.RefObjClear(Item);
                      end;
                    {$ENDIF}
                    {$IFDEF MSWINDOWS}
                    tkWString:
                      begin
                        TRAIIHelper.WStrClear(Item);
                      end;
                    {$ELSE}
                    tkWString,
                      {$ENDIF}
                    tkLString, tkUString:
                      begin
                        TRAIIHelper.ULStrClear(Item);
                      end;
                    tkInterface:
                      begin
                        IInterface(PPointer(Item)^)._Release;
                      end;
                    tkDynArray:
                      begin
                        TRAIIHelper.DynArrayClear(Item, TypeInfo(T));
                      end;
                  end;
              end;
            {$IFDEF WEAKINSTREF}
            tkMethod:
              begin
                if (PMethod(Item).Data <> nil) then
                  TRAIIHelper.WeakMethodClear(@PMethod(Item).Data);
              end;
            {$ENDIF}
            tkVariant:
              begin
                VType := PVarData(Item).VType;
                if (VType and TRAIIHelper.varDeepData <> 0) then
                  case VType of
                    varBoolean, varUnknown + 1..varUInt64: ;
                  else
                    System.VarClear(PVariant(Item)^);
                  end;
              end;
          else
            TRAIIHelper<T>.Options.ClearProc(TRAIIHelper<T>.Options, Item);
          end;

          Inc(Item);
        end;
        ACount := Stored.ACount;
        Dec(Item, ACount);
      end;

      if (Count <> 0) then
      begin
        {$IFDEF WEAKREF}
        if (TRAIIHelper<T>.Weak) then
        begin
          System.CopyArray(Item, Item + ACount, TypeInfo(T), Count);
          System.FinalizeArray(Item + Count, TypeInfo(T), ACount);
        end
        else
          {$ENDIF}
        begin
          System.Move(Pointer(Item + ACount)^, Item^, Count * SizeOf(T));
        end;
      end;

      Exit;
    end;
  end;

  ErrorArgumentOutOfRange;
end;

function TList<T>.Expand: TList<T>;
begin
  if (FCount.Native = FCapacity.Native) then
    Grow;

  Result := Self;
end;

procedure TList<T>.Exchange(Index1, Index2: Integer);
var
  Count: Cardinal;
  X, Y: Pointer;
begin
  Count := FCount.Int;
  if (Cardinal(Index1) < Count) and (Cardinal(Index2) < Count) then
  begin
    if (Index1 <> Index2) then
    begin
      X := Pointer(FItems);
      Y := Pointer(TCustomList<T>.PItem(X) + Index2);
      X := Pointer(TCustomList<T>.PItem(X) + Index1);

      TArray.Exchange<T>(X, Y);
    end;
  end
  else
  begin
    ErrorArgumentOutOfRange;
  end;
end;

procedure TList<T>.InternalMove(CurIndex, NewIndex: Integer);
var
  Count: Cardinal;
  X, Y: PItem;
  Temp: T;
begin
  Count := FCount.Int;
  if (Cardinal(CurIndex) < Count) and (Cardinal(NewIndex) < Count) then
  begin
    if (CurIndex <> NewIndex) then
    begin
      X := Pointer(FItems);
      Y := X + NewIndex;
      X := X + CurIndex;

      Temp := X^;
      if (X < Y) then
      begin
        System.Move(Pointer(X + 1)^, X^, NativeUInt(Y) - NativeUInt(X));
      end
      else
      begin
        System.Move(Y^, Pointer(Y + 1)^, NativeUInt(X) - NativeUInt(Y));
      end;
      Y^ := Temp;
    end;
  end
  else
  begin
    ErrorArgumentOutOfRange;
  end;
end;

{$WARNINGS OFF} // compiler can't identify variable initialization in case statement

procedure TList<T>.InternalMove40(CurIndex, NewIndex: Integer);
var
  Count: Cardinal;
  X, Y: PItem;

  Temp1: TRAIIHelper.T1;
  Temp2: TRAIIHelper.T2;
  Temp4: TRAIIHelper.T4;
  Temp8: TRAIIHelper.T8;
  Temp40: TRAIIHelper.TTemp40;
begin
  Count := FCount.Int;
  if (Cardinal(CurIndex) < Count) and (Cardinal(NewIndex) < Count) then
  begin
    if (CurIndex <> NewIndex) then
    begin
      X := Pointer(FItems);
      Y := X + NewIndex;
      X := X + CurIndex;

      case SizeOf(T) of
        1: Temp1 := TRAIIHelper.T1(Pointer(X)^);
        2: Temp2 := TRAIIHelper.T2(Pointer(X)^);
        3: Temp40.V3 := TRAIIHelper.T3(Pointer(X)^);
        4: Temp4 := TRAIIHelper.T4(Pointer(X)^);
        5: Temp40.V5 := TRAIIHelper.T5(Pointer(X)^);
        6: Temp40.V6 := TRAIIHelper.T6(Pointer(X)^);
        7: Temp40.V7 := TRAIIHelper.T7(Pointer(X)^);
        8: Temp8 := TRAIIHelper.T8(Pointer(X)^);
        9: Temp40.V9 := TRAIIHelper.T9(Pointer(X)^);
        10: Temp40.V10 := TRAIIHelper.T10(Pointer(X)^);
        11: Temp40.V11 := TRAIIHelper.T11(Pointer(X)^);
        12: Temp40.V12 := TRAIIHelper.T12(Pointer(X)^);
        13: Temp40.V13 := TRAIIHelper.T13(Pointer(X)^);
        14: Temp40.V14 := TRAIIHelper.T14(Pointer(X)^);
        15: Temp40.V15 := TRAIIHelper.T15(Pointer(X)^);
        16: Temp40.V16 := TRAIIHelper.T16(Pointer(X)^);
        17: Temp40.V17 := TRAIIHelper.T17(Pointer(X)^);
        18: Temp40.V18 := TRAIIHelper.T18(Pointer(X)^);
        19: Temp40.V19 := TRAIIHelper.T19(Pointer(X)^);
        20: Temp40.V20 := TRAIIHelper.T20(Pointer(X)^);
        21: Temp40.V21 := TRAIIHelper.T21(Pointer(X)^);
        22: Temp40.V22 := TRAIIHelper.T22(Pointer(X)^);
        23: Temp40.V23 := TRAIIHelper.T23(Pointer(X)^);
        24: Temp40.V24 := TRAIIHelper.T24(Pointer(X)^);
        25: Temp40.V25 := TRAIIHelper.T25(Pointer(X)^);
        26: Temp40.V26 := TRAIIHelper.T26(Pointer(X)^);
        27: Temp40.V27 := TRAIIHelper.T27(Pointer(X)^);
        28: Temp40.V28 := TRAIIHelper.T28(Pointer(X)^);
        29: Temp40.V29 := TRAIIHelper.T29(Pointer(X)^);
        30: Temp40.V30 := TRAIIHelper.T30(Pointer(X)^);
        31: Temp40.V31 := TRAIIHelper.T31(Pointer(X)^);
        32: Temp40.V32 := TRAIIHelper.T32(Pointer(X)^);
        33: Temp40.V33 := TRAIIHelper.T33(Pointer(X)^);
        34: Temp40.V34 := TRAIIHelper.T34(Pointer(X)^);
        35: Temp40.V35 := TRAIIHelper.T35(Pointer(X)^);
        36: Temp40.V36 := TRAIIHelper.T36(Pointer(X)^);
        37: Temp40.V37 := TRAIIHelper.T37(Pointer(X)^);
        38: Temp40.V38 := TRAIIHelper.T38(Pointer(X)^);
        39: Temp40.V39 := TRAIIHelper.T39(Pointer(X)^);
        40: Temp40.V40 := TRAIIHelper.T40(Pointer(X)^);
      end;

      if (X < Y) then
      begin
        System.Move(Pointer(X + 1)^, X^, NativeUInt(Y) - NativeUInt(X));
      end
      else
      begin
        System.Move(Y^, Pointer(Y + 1)^, NativeUInt(X) - NativeUInt(Y));
      end;

      case SizeOf(T) of
        1: TRAIIHelper.T1(Pointer(Y)^) := Temp1;
        2: TRAIIHelper.T2(Pointer(Y)^) := Temp2;
        3: TRAIIHelper.T3(Pointer(Y)^) := Temp40.V3;
        4: TRAIIHelper.T4(Pointer(Y)^) := Temp4;
        5: TRAIIHelper.T5(Pointer(Y)^) := Temp40.V5;
        6: TRAIIHelper.T6(Pointer(Y)^) := Temp40.V6;
        7: TRAIIHelper.T7(Pointer(Y)^) := Temp40.V7;
        8: TRAIIHelper.T8(Pointer(Y)^) := Temp8;
        9: TRAIIHelper.T9(Pointer(Y)^) := Temp40.V9;
        10: TRAIIHelper.T10(Pointer(Y)^) := Temp40.V10;
        11: TRAIIHelper.T11(Pointer(Y)^) := Temp40.V11;
        12: TRAIIHelper.T12(Pointer(Y)^) := Temp40.V12;
        13: TRAIIHelper.T13(Pointer(Y)^) := Temp40.V13;
        14: TRAIIHelper.T14(Pointer(Y)^) := Temp40.V14;
        15: TRAIIHelper.T15(Pointer(Y)^) := Temp40.V15;
        16: TRAIIHelper.T16(Pointer(Y)^) := Temp40.V16;
        17: TRAIIHelper.T17(Pointer(Y)^) := Temp40.V17;
        18: TRAIIHelper.T18(Pointer(Y)^) := Temp40.V18;
        19: TRAIIHelper.T19(Pointer(Y)^) := Temp40.V19;
        20: TRAIIHelper.T20(Pointer(Y)^) := Temp40.V20;
        21: TRAIIHelper.T21(Pointer(Y)^) := Temp40.V21;
        22: TRAIIHelper.T22(Pointer(Y)^) := Temp40.V22;
        23: TRAIIHelper.T23(Pointer(Y)^) := Temp40.V23;
        24: TRAIIHelper.T24(Pointer(Y)^) := Temp40.V24;
        25: TRAIIHelper.T25(Pointer(Y)^) := Temp40.V25;
        26: TRAIIHelper.T26(Pointer(Y)^) := Temp40.V26;
        27: TRAIIHelper.T27(Pointer(Y)^) := Temp40.V27;
        28: TRAIIHelper.T28(Pointer(Y)^) := Temp40.V28;
        29: TRAIIHelper.T29(Pointer(Y)^) := Temp40.V29;
        30: TRAIIHelper.T30(Pointer(Y)^) := Temp40.V30;
        31: TRAIIHelper.T31(Pointer(Y)^) := Temp40.V31;
        32: TRAIIHelper.T32(Pointer(Y)^) := Temp40.V32;
        33: TRAIIHelper.T33(Pointer(Y)^) := Temp40.V33;
        34: TRAIIHelper.T34(Pointer(Y)^) := Temp40.V34;
        35: TRAIIHelper.T35(Pointer(Y)^) := Temp40.V35;
        36: TRAIIHelper.T36(Pointer(Y)^) := Temp40.V36;
        37: TRAIIHelper.T37(Pointer(Y)^) := Temp40.V37;
        38: TRAIIHelper.T38(Pointer(Y)^) := Temp40.V38;
        39: TRAIIHelper.T39(Pointer(Y)^) := Temp40.V39;
        40: TRAIIHelper.T40(Pointer(Y)^) := Temp40.V40;
      end;
    end;
  end
  else
  begin
    ErrorArgumentOutOfRange;
  end;
end;
{$WARNINGS ON}

procedure TList<T>.Move(CurIndex, NewIndex: Integer);
begin
  if (SizeOf(T) > 40) then
  begin
    InternalMove(CurIndex, NewIndex);
  end
  else
  begin
    InternalMove40(CurIndex, NewIndex);
  end;
end;

procedure TList<T>.Reverse;
begin
  TArray.Reverse<T>(Pointer(FItems), FCount.Native);
end;

procedure TList<T>.Sort;
var
  LCount: NativeInt;
begin
  LCount := FCount.Native;
  if (LCount > 1) then
  begin
    if (Assigned(FComparer)) then
    begin
      TArray.Sort<T>(FItems[0], LCount, FComparer);
    end
    else
    begin
      TArray.Sort<T>(FItems[0], LCount);
    end;
  end;
end;

procedure TList<T>.Sort(Index, ACount: Integer);
begin
  if (Index < 0) or ((Index >= FCount.Int) and (ACount > 0))
    or (Index + ACount - 1 >= FCount.Int) or (ACount < 0)
    or (Index + ACount < 0) then
    ErrorArgumentOutOfRange;
  if ACount <= 1 then
    Exit;

  if (Assigned(FComparer)) then
  begin
    TArray.Sort<T>(FItems[Index], ACount, FComparer);
  end
  else
  begin
    TArray.Sort<T>(FItems[Index], ACount);
  end;
end;

procedure TList<T>.Sort(const AComparer: IComparer<T>);
var
  Count: NativeInt;
begin
  Count := FCount.Native;
  if (Count > 1) then
  begin
    TArray.Sort<T>(FItems[0], Count, AComparer);
  end;
end;

procedure TList<T>.Sort(const AComparison: TComparison<T>);
var
  Count: NativeInt;
begin
  Count := FCount.Native;
  if (Count > 1) then
  begin
    TArray.Sort<T>(FItems[0], Count, AComparison);
  end;
end;

procedure TList<T>.Sort(Index, ACount: Integer; const AComparer: IComparer<T>);
begin
  if (Index < 0) or ((Index >= FCount.Int) and (ACount > 0))
    or (Index + ACount - 1 >= FCount.Int) or (ACount < 0)
    or (Index + ACount < 0) then
    ErrorArgumentOutOfRange;
  if ACount <= 1 then
    Exit;

  TArray.Sort<T>(FItems[Index], ACount, AComparer);
end;

procedure TList<T>.Sort(Index, ACount: Integer; const AComparison: TComparison<T>);
begin
  if (Index < 0) or ((Index >= FCount.Int) and (ACount > 0))
    or (Index + ACount - 1 >= FCount.Int) or (ACount < 0)
    or (Index + ACount < 0) then
    ErrorArgumentOutOfRange;
  if ACount <= 1 then
    Exit;

  TArray.Sort<T>(FItems[Index], ACount, AComparison);
end;

procedure TList<T>.SortDescending;
var
  LCount: NativeInt;
begin
  LCount := FCount.Native;
  if (LCount > 1) then
  begin
    if (Assigned(FComparer)) then
    begin
      TArray.SortDescending<T>(FItems[0], LCount, FComparer);
    end
    else
    begin
      TArray.SortDescending<T>(FItems[0], LCount);
    end;
  end;
end;

procedure TList<T>.SortDescending(Index, ACount: Integer);
begin
  if (Index < 0) or ((Index >= FCount.Int) and (ACount > 0))
    or (Index + ACount - 1 >= FCount.Int) or (ACount < 0)
    or (Index + ACount < 0) then
    ErrorArgumentOutOfRange;
  if ACount <= 1 then
    Exit;

  if (Assigned(FComparer)) then
  begin
    TArray.SortDescending<T>(FItems[Index], ACount, FComparer);
  end
  else
  begin
    TArray.SortDescending<T>(FItems[Index], ACount);
  end;
end;

procedure TList<T>.SortDescending(const AComparer: IComparer<T>);
var
  Count: NativeInt;
begin
  Count := FCount.Native;
  if (Count > 1) then
  begin
    TArray.SortDescending<T>(FItems[0], Count, AComparer);
  end;
end;

procedure TList<T>.SortDescending(const AComparison: TComparison<T>);
var
  Count: NativeInt;
begin
  Count := FCount.Native;
  if (Count > 1) then
  begin
    TArray.SortDescending<T>(FItems[0], Count, AComparison);
  end;
end;

procedure TList<T>.SortDescending(Index, ACount: Integer; const AComparer: IComparer<T>);
begin
  if (Index < 0) or ((Index >= FCount.Int) and (ACount > 0))
    or (Index + ACount - 1 >= FCount.Int) or (ACount < 0)
    or (Index + ACount < 0) then
    ErrorArgumentOutOfRange;
  if ACount <= 1 then
    Exit;

  TArray.SortDescending<T>(FItems[Index], ACount, AComparer);
end;

procedure TList<T>.SortDescending(Index, ACount: Integer; const AComparison: TComparison<T>);
begin
  if (Index < 0) or ((Index >= FCount.Int) and (ACount > 0))
    or (Index + ACount - 1 >= FCount.Int) or (ACount < 0)
    or (Index + ACount < 0) then
    ErrorArgumentOutOfRange;
  if ACount <= 1 then
    Exit;

  TArray.SortDescending<T>(FItems[Index], ACount, AComparison);
end;

function TList<T>.BinarySearch(const Item: T; out FoundIndex: Integer): Boolean;
begin
  if (Assigned(FComparer)) then
  begin
    Result := TArray.InternalSearch<T>(Pointer(FItems), 0, FCount.Int, Item, FoundIndex, Pointer(FComparer));
  end
  else
  begin
    Result := TArray.InternalSearch<T>(Pointer(FItems), 0, FCount.Int, Item, FoundIndex);
  end;
end;

function TList<T>.BinarySearch(const Item: T; out FoundIndex: Integer; const AComparer: IComparer<T>): Boolean;
begin
  Result := TArray.InternalSearch<T>(Pointer(FItems), 0, FCount.Int, Item, FoundIndex, Pointer(AComparer));
end;

function TList<T>.BinarySearch(const Item: T; out FoundIndex: Integer; const AComparison: TComparison<T>): Boolean;
begin
  Result := TArray.InternalSearch<T>(Pointer(FItems), 0, FCount.Int, Item, FoundIndex, PPointer(@AComparison)^);
end;

function TList<T>.BinarySearch(const Item: T; out FoundIndex: Integer; Index, ACount: Integer): Boolean;
begin
  if (Index < 0) or ((Index >= FCount.Int) and (ACount > 0))
    or (Index + ACount - 1 >= FCount.Int) {or (ACount < 0)}
    or (Index + ACount < 0) then
    ErrorArgumentOutOfRange;

  if (Assigned(FComparer)) then
  begin
    Result := TArray.InternalSearch<T>(Pointer(FItems), Index, ACount, Item, FoundIndex, Pointer(FComparer));
  end
  else
  begin
    Result := TArray.InternalSearch<T>(Pointer(FItems), Index, ACount, Item, FoundIndex);
  end;
end;

function TList<T>.BinarySearch(const Item: T; out FoundIndex: Integer; const AComparer: IComparer<T>;
  Index, ACount: Integer): Boolean;
begin
  if (Index < 0) or ((Index >= FCount.Int) and (ACount > 0))
    or (Index + ACount - 1 >= FCount.Int) {or (ACount < 0)}
    or (Index + ACount < 0) then
    ErrorArgumentOutOfRange;

  Result := TArray.InternalSearch<T>(Pointer(FItems), Index, ACount, Item, FoundIndex, Pointer(AComparer));
end;

function TList<T>.BinarySearch(const Item: T; out FoundIndex: Integer; Index, ACount: Integer;
  const AComparison: TComparison<T>): Boolean;
begin
  if (Index < 0) or ((Index >= FCount.Int) and (ACount > 0))
    or (Index + ACount - 1 >= FCount.Int) {or (ACount < 0)}
    or (Index + ACount < 0) then
    ErrorArgumentOutOfRange;

  Result := TArray.InternalSearch<T>(Pointer(FItems), Index, ACount, Item, FoundIndex, PPointer(@AComparison)^);
end;

function TList<T>.BinarySearchDescending(const Item: T; out FoundIndex: Integer): Boolean;
begin
  if (Assigned(FComparer)) then
  begin
    Result := TArray.InternalSearchDescending<T>(Pointer(FItems), 0, FCount.Int, Item, FoundIndex, Pointer(FComparer));
  end
  else
  begin
    Result := TArray.InternalSearchDescending<T>(Pointer(FItems), 0, FCount.Int, Item, FoundIndex);
  end;
end;

function TList<T>.BinarySearchDescending(const Item: T; out FoundIndex: Integer; const AComparer: IComparer<T>):
  Boolean;
begin
  Result := TArray.InternalSearchDescending<T>(Pointer(FItems), 0, FCount.Int, Item, FoundIndex, Pointer(AComparer));
end;

function TList<T>.BinarySearchDescending(const Item: T; out FoundIndex: Integer; const AComparison: TComparison<T>):
  Boolean;
begin
  Result := TArray.InternalSearchDescending<T>(Pointer(FItems), 0, FCount.Int, Item, FoundIndex,
    PPointer(@AComparison)^);
end;

function TList<T>.BinarySearchDescending(const Item: T; out FoundIndex: Integer; Index, ACount: Integer): Boolean;
begin
  if (Index < 0) or ((Index >= FCount.Int) and (ACount > 0))
    or (Index + ACount - 1 >= FCount.Int) {or (ACount < 0)}
    or (Index + ACount < 0) then
    ErrorArgumentOutOfRange;

  if (Assigned(FComparer)) then
  begin
    Result := TArray.InternalSearchDescending<T>(Pointer(FItems), Index, ACount, Item, FoundIndex, Pointer(FComparer));
  end
  else
  begin
    Result := TArray.InternalSearchDescending<T>(Pointer(FItems), Index, ACount, Item, FoundIndex);
  end;
end;

function TList<T>.BinarySearchDescending(const Item: T; out FoundIndex: Integer; const AComparer: IComparer<T>;
  Index, ACount: Integer): Boolean;
begin
  if (Index < 0) or ((Index >= FCount.Int) and (ACount > 0))
    or (Index + ACount - 1 >= FCount.Int) {or (ACount < 0)}
    or (Index + ACount < 0) then
    ErrorArgumentOutOfRange;

  Result := TArray.InternalSearchDescending<T>(Pointer(FItems), Index, ACount, Item, FoundIndex, Pointer(AComparer));
end;

function TList<T>.BinarySearchDescending(const Item: T; out FoundIndex: Integer; Index, ACount: Integer;
  const AComparison: TComparison<T>): Boolean;
begin
  if (Index < 0) or ((Index >= FCount.Int) and (ACount > 0))
    or (Index + ACount - 1 >= FCount.Int) {or (ACount < 0)}
    or (Index + ACount < 0) then
    ErrorArgumentOutOfRange;

  Result := TArray.InternalSearchDescending<T>(Pointer(FItems), Index, Count, Item, FoundIndex,
    PPointer(@AComparison)^);
end;

function TList<T>.InternalIndexOf(const Value: T): NativeInt;
label
  cmp0, cmp1, cmp2, cmp3, cmp4, cmp5 {$IFDEF SMALLINT}, cmp6, cmp7, cmp8, cmp9, cmp10{$ENDIF};
var
  R: NativeInt;
  Item, TopItem: PItem;
  LCount: NativeUInt;
  Left, Right: PByte;
  Offset: NativeUInt;
  Stored: TInternalStored;
begin
  if Count = 0 then
    Exit(-1);

  if (not Assigned(FComparer)) then
  begin
    Item := Pointer(FItems);
    Stored.Item := Item;
    Dec(Item);
    TopItem := Item + FCount.Native;

    repeat
      if (Item = TopItem) then
        Break;
      Inc(Item);

      if (GetTypeKind(T) = tkVariant) then
      begin
        if (not InterfaceDefaults.Equals_Var(nil, PVarData(@Value), PVarData(Item))) then
          Continue;
      end
      else if (GetTypeKind(T) = tkClass) then
      begin
        Left := PPointer(@Value)^;
        Right := PPointer(Item)^;
        if (Assigned(Left)) then
        begin
          if (PPointer(Pointer(Left)^)[vmtEquals div SizeOf(Pointer)] = @TObject.Equals) then
          begin
            if (Left <> Right) then
              Continue;
          end
          else
          begin
            if (not TObject(PNativeUInt(@Value)^).Equals(TObject(PNativeUInt(Item)^))) then
              Continue;
          end;
        end
        else
        begin
          if (Right <> nil) then
            Continue;
        end;
      end
      else if (GetTypeKind(T) = tkFloat) then
      begin
        case SizeOf(T) of
          4:
            begin
              if (PSingle(@Value)^ <> PSingle(Item)^) then
                Continue;
            end;
          10:
            begin
              if (PExtended(@Value)^ <> PExtended(Item)^) then
                Continue;
            end;
        else
          {$IFDEF LARGEINT}
          if (PInt64(@Value)^ <> PInt64(Item)^) then
            {$ELSE .SMALLINT}
          if ((PPoint(@Value).X - PPoint(Item).X) or (PPoint(@Value).Y - PPoint(Item).Y) <> 0) then
            {$ENDIF}
          begin
            if (TRAIIHelper<T>.Options.ItemSize < 0) then
              Continue;
            if (PDouble(@Value)^ <> PDouble(Item)^) then
              Continue;
          end;
        end;
      end
      else if (not (GetTypeKind(T) in [tkDynArray, tkString, tkLString, tkWString, tkUString])) and
        (SizeOf(T) <= 16) then
      begin
        // small binary
        if (SizeOf(T) <> 0) then
          with PData16(@Value)^ do
          begin
            if (SizeOf(T) >= SizeOf(Integer)) then
            begin
              if (SizeOf(T) >= SizeOf(Int64)) then
              begin
                {$IFDEF LARGEINT}
                if (Int64s[0] <> PData16(Item).Int64s[0]) then
                  Continue;
                {$ELSE}
                if (Integers[0] <> PData16(Item).Integers[0]) then
                  Continue;
                if (Integers[1] <> PData16(Item).Integers[1]) then
                  Continue;
                {$ENDIF}

                if (SizeOf(T) = 16) then
                begin
                  {$IFDEF LARGEINT}
                  if (Int64s[1] <> PData16(Item).Int64s[1]) then
                    Continue;
                  {$ELSE}
                  if (Integers[2] <> PData16(Item).Integers[2]) then
                    Continue;
                  if (Integers[3] <> PData16(Item).Integers[3]) then
                    Continue;
                  {$ENDIF}
                end
                else if (SizeOf(T) >= 12) then
                begin
                  if (Integers[2] <> PData16(Item).Integers[2]) then
                    Continue;
                end;
              end
              else
              begin
                if (Integers[0] <> PData16(Item).Integers[0]) then
                  Continue;
              end;
            end;

            if (SizeOf(T) and 2 <> 0) then
            begin
              if (Words[(SizeOf(T) and -4) shr 1] <> PData16(Item).Words[(SizeOf(T) and -4) shr 1]) then
                Continue;
            end;
            if (SizeOf(T) and 1 <> 0) then
            begin
              if (Bytes[SizeOf(T) and -2] <> PData16(Item).Bytes[SizeOf(T) and -2]) then
                Continue;
            end;
          end;
      end
      else
      begin
        if (GetTypeKind(T) in [tkDynArray, tkString, tkLString, tkWString, tkUString]) then
        begin
          // dynamic size
          if (GetTypeKind(T) = tkString) then
          begin
            Left := Pointer(@Value);
            Right := Pointer(Item);
            if (PItem(Left) = {Right}Item) then
              goto cmp0;
            LCount := Left^;
            if (LCount <> Right^) then
              Continue;
            if (LCount = 0) then
              goto cmp0;
            // compare last bytes
            if (Left[LCount] <> Right[LCount]) then
              Continue;
          end
          else
          // if (GetTypeKind(T) in [tkDynArray, tkLString, tkWString, tkUString]) then
          begin
            Left := PPointer(@Value)^;
            Right := PPointer(Item)^;
            if (Left = Right) then
              goto cmp0;
            if (Left = nil) then
            begin
              {$IFDEF MSWINDOWS}
              if (GetTypeKind(T) = tkWString) then
              begin
                Dec(Right, SizeOf(Cardinal));
                if (PCardinal(Right)^ = 0) then
                  goto cmp0;
              end;
              {$ENDIF}
              Continue;
            end;
            if (Right = nil) then
            begin
              {$IFDEF MSWINDOWS}
              if (GetTypeKind(T) = tkWString) then
              begin
                Dec(Left, SizeOf(Cardinal));
                if (PCardinal(Left)^ = 0) then
                  goto cmp0;
              end;
              {$ENDIF}
              Continue;
            end;

            if (GetTypeKind(T) = tkDynArray) then
            begin
              Dec(Left, SizeOf(NativeUInt));
              Dec(Right, SizeOf(NativeUInt));
              LCount := PNativeUInt(Left)^;
              if (LCount <> PNativeUInt(Right)^) then
                Continue;
              NativeInt(LCount) := NativeInt(LCount) * TRAIIHelper<T>.Options.ItemSize;
              Inc(Left, SizeOf(NativeUInt));
              Inc(Right, SizeOf(NativeUInt));
            end
            else
            // if (GetTypeKind(T) in [tkLString, tkWString, tkUString]) then
            begin
              Dec(Left, SizeOf(Cardinal));
              Dec(Right, SizeOf(Cardinal));
              LCount := PCardinal(Left)^;
              if (Cardinal(LCount) <> PCardinal(Right)^) then
                Continue;
              Inc(Left, SizeOf(Cardinal));
              Inc(Right, SizeOf(Cardinal));
            end;
          end;

          // compare last (after cardinal) words
          if (GetTypeKind(T) in [tkDynArray, tkString, tkLString]) then
          begin
            if (GetTypeKind(T) in [tkString, tkLString]) {ByteStrings + 2} then
            begin
              Inc(LCount);
            end;
            if (LCount and 2 <> 0) then
            begin
              Offset := LCount and -4;
              Inc(Left, Offset);
              Inc(Right, Offset);
              if (PWord(Left)^ <> PWord(Right)^) then
                Continue;
              Offset := LCount;
              Offset := Offset and -4;
              Dec(Left, Offset);
              Dec(Right, Offset);
            end;
          end
          else
          // modify Count to have only cardinals to compare
          // if (GetTypeKind(T) in [tkWString, tkUString]) {UnicodeStrings + 2} then
          begin
            {$IFDEF MSWINDOWS}
            if (GetTypeKind(T) = tkWString) then
            begin
              if (LCount = 0) then
                goto cmp0;
            end
            else
              {$ENDIF}
            begin
              Inc(LCount, LCount);
            end;
            Inc(LCount, 2);
          end;

          {$IFDEF LARGEINT}
          if (LCount and 4 <> 0) then
          begin
            Offset := LCount and -8;
            Inc(Left, Offset);
            Inc(Right, Offset);
            if (PCardinal(Left)^ <> PCardinal(Right)^) then
              Continue;
            Dec(Left, Offset);
            Dec(Right, Offset);
          end;
          {$ENDIF}
        end
        else
        begin
          // non-dynamic (constant) size binary > 16
          if (SizeOf(T) and {$IFDEF LARGEINT}7{$ELSE}3{$ENDIF} <> 0) then
            with PData16(@Value)^ do
            begin
              {$IFDEF LARGEINT}
              if (SizeOf(T) and 4 <> 0) then
              begin
                if (Integers[(SizeOf(T) and -8) shr 2] <> PData16(Item).Integers[(SizeOf(T) and -8) shr 2]) then
                  Continue;
              end;
              {$ENDIF}
              if (SizeOf(T) and 2 <> 0) then
              begin
                if (Words[(SizeOf(T) and -4) shr 1] <> PData16(Item).Words[(SizeOf(T) and -4) shr 1]) then
                  Continue;
              end;
              if (SizeOf(T) and 1 <> 0) then
              begin
                if (Bytes[SizeOf(T) and -2] <> PData16(Item).Bytes[SizeOf(T) and -2]) then
                  Continue;
              end;
            end;
          Left := Pointer(@Value);
          Right := Pointer(Item);
          LCount := SizeOf(T);
        end;

        // natives (40 bytes static) compare
        LCount := LCount shr {$IFDEF LARGEINT}3{$ELSE}2{$ENDIF};
        case LCount of
          {$IFDEF SMALLINT}
          10: goto cmp10;
          9: goto cmp9;
          8: goto cmp8;
          7: goto cmp7;
          6: goto cmp6;
          {$ENDIF}
          5: goto cmp5;
          4: goto cmp4;
          3: goto cmp3;
          2: goto cmp2;
          1: goto cmp1;
          0: goto cmp0;
        else
          repeat
            if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
              Continue;
            Dec(LCount);
            Inc(Left, SizeOf(NativeUInt));
            Inc(Right, SizeOf(NativeUInt));
          until (LCount = {$IFDEF LARGEINT}5{$ELSE}10{$ENDIF});

          {$IFDEF SMALLINT}
          cmp10:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp9:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp8:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp7:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp6:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          {$ENDIF}
          cmp5:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp4:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp3:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp2:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp1:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          cmp0:
        end;
      end;

      R := NativeInt(Item) - NativeInt(Stored.Item);
      case SizeOf(T) of
        0, 1: Exit(R);
        2: Exit(R shr 1);
        4: Exit(R shr 2);
        8: Exit(R shr 3);
        16: Exit(R shr 4);
        32: Exit(R shr 5);
        64: Exit(R shr 6);
        128: Exit(R shr 7);
        256: Exit(R shr 8);
      else
        Exit(Round(R * (1 / SizeOf(T))));
      end;
    until (False);

    Exit(-1);
  end
  else
  begin
    Exit(InternalIndexOf(Value, FComparer));
  end;
end;

function TList<T>.InternalIndexOf(const Value: T; const Comparer: IComparer<T>): NativeInt;
var
  LCount: NativeInt;
  Item: PItem;
  Compare: TMethod;
begin
  LCount := FCount.Native;
  if LCount = 0 then
    Exit(-1);

  Item := Pointer(FItems);
  Compare.Data := Pointer(Comparer);
  Compare.Code := PPointer(PNativeUInt(Comparer)^ + 3 * SizeOf(Pointer))^;
  for Result := 0 to LCount - 1 do
  begin
    if (TCompare(Compare.Code)(Compare.Data, Item^, Value) = 0) then
      Exit;
    Inc(Item);
  end;

  Result := -1;
end;

function TList<T>.InternalIndexOfRev(const Value: T): NativeInt;
label
  cmp0, cmp1, cmp2, cmp3, cmp4, cmp5 {$IFDEF SMALLINT}, cmp6, cmp7, cmp8, cmp9, cmp10{$ENDIF};
var
  R: NativeInt;
  Item, LowItem: PItem;
  LCount: NativeUInt;
  Left, Right: PByte;
  Offset: NativeUInt;
  Stored: TInternalStored;
begin
  if Count = 0 then
    Exit(-1);

  if (not Assigned(FComparer)) then
  begin
    LowItem := Pointer(FItems);
    Stored.Item := LowItem;
    Item := LowItem + FCount.Native;

    repeat
      if (Item = LowItem) then
        Break;
      Dec(Item);

      if (GetTypeKind(T) = tkVariant) then
      begin
        if (not InterfaceDefaults.Equals_Var(nil, PVarData(@Value), PVarData(Item))) then
          Continue;
      end
      else if (GetTypeKind(T) = tkClass) then
      begin
        Left := PPointer(@Value)^;
        Right := PPointer(Item)^;
        if (Assigned(Left)) then
        begin
          if (PPointer(Pointer(Left)^)[vmtEquals div SizeOf(Pointer)] = @TObject.Equals) then
          begin
            if (Left <> Right) then
              Continue;
          end
          else
          begin
            if (not TObject(PNativeUInt(@Value)^).Equals(TObject(PNativeUInt(Item)^))) then
              Continue;
          end;
        end
        else
        begin
          if (Right <> nil) then
            Continue;
        end;
      end
      else if (GetTypeKind(T) = tkFloat) then
      begin
        case SizeOf(T) of
          4:
            begin
              if (PSingle(@Value)^ <> PSingle(Item)^) then
                Continue;
            end;
          10:
            begin
              if (PExtended(@Value)^ <> PExtended(Item)^) then
                Continue;
            end;
        else
          {$IFDEF LARGEINT}
          if (PInt64(@Value)^ <> PInt64(Item)^) then
            {$ELSE .SMALLINT}
          if ((PPoint(@Value).X - PPoint(Item).X) or (PPoint(@Value).Y - PPoint(Item).Y) <> 0) then
            {$ENDIF}
          begin
            if (TRAIIHelper<T>.Options.ItemSize < 0) then
              Continue;
            if (PDouble(@Value)^ <> PDouble(Item)^) then
              Continue;
          end;
        end;
      end
      else if (not (GetTypeKind(T) in [tkDynArray, tkString, tkLString, tkWString, tkUString])) and
        (SizeOf(T) <= 16) then
      begin
        // small binary
        if (SizeOf(T) <> 0) then
          with PData16(@Value)^ do
          begin
            if (SizeOf(T) >= SizeOf(Integer)) then
            begin
              if (SizeOf(T) >= SizeOf(Int64)) then
              begin
                {$IFDEF LARGEINT}
                if (Int64s[0] <> PData16(Item).Int64s[0]) then
                  Continue;
                {$ELSE}
                if (Integers[0] <> PData16(Item).Integers[0]) then
                  Continue;
                if (Integers[1] <> PData16(Item).Integers[1]) then
                  Continue;
                {$ENDIF}

                if (SizeOf(T) = 16) then
                begin
                  {$IFDEF LARGEINT}
                  if (Int64s[1] <> PData16(Item).Int64s[1]) then
                    Continue;
                  {$ELSE}
                  if (Integers[2] <> PData16(Item).Integers[2]) then
                    Continue;
                  if (Integers[3] <> PData16(Item).Integers[3]) then
                    Continue;
                  {$ENDIF}
                end
                else if (SizeOf(T) >= 12) then
                begin
                  if (Integers[2] <> PData16(Item).Integers[2]) then
                    Continue;
                end;
              end
              else
              begin
                if (Integers[0] <> PData16(Item).Integers[0]) then
                  Continue;
              end;
            end;

            if (SizeOf(T) and 2 <> 0) then
            begin
              if (Words[(SizeOf(T) and -4) shr 1] <> PData16(Item).Words[(SizeOf(T) and -4) shr 1]) then
                Continue;
            end;
            if (SizeOf(T) and 1 <> 0) then
            begin
              if (Bytes[SizeOf(T) and -2] <> PData16(Item).Bytes[SizeOf(T) and -2]) then
                Continue;
            end;
          end;
      end
      else
      begin
        if (GetTypeKind(T) in [tkDynArray, tkString, tkLString, tkWString, tkUString]) then
        begin
          // dynamic size
          if (GetTypeKind(T) = tkString) then
          begin
            Left := Pointer(@Value);
            Right := Pointer(Item);
            if (PItem(Left) = {Right}Item) then
              goto cmp0;
            LCount := Left^;
            if (LCount <> Right^) then
              Continue;
            if (LCount = 0) then
              goto cmp0;
            // compare last bytes
            if (Left[LCount] <> Right[LCount]) then
              Continue;
          end
          else
          // if (GetTypeKind(T) in [tkDynArray, tkLString, tkWString, tkUString]) then
          begin
            Left := PPointer(@Value)^;
            Right := PPointer(Item)^;
            if (Left = Right) then
              goto cmp0;
            if (Left = nil) then
            begin
              {$IFDEF MSWINDOWS}
              if (GetTypeKind(T) = tkWString) then
              begin
                Dec(Right, SizeOf(Cardinal));
                if (PCardinal(Right)^ = 0) then
                  goto cmp0;
              end;
              {$ENDIF}
              Continue;
            end;
            if (Right = nil) then
            begin
              {$IFDEF MSWINDOWS}
              if (GetTypeKind(T) = tkWString) then
              begin
                Dec(Left, SizeOf(Cardinal));
                if (PCardinal(Left)^ = 0) then
                  goto cmp0;
              end;
              {$ENDIF}
              Continue;
            end;

            if (GetTypeKind(T) = tkDynArray) then
            begin
              Dec(Left, SizeOf(NativeUInt));
              Dec(Right, SizeOf(NativeUInt));
              LCount := PNativeUInt(Left)^;
              if (LCount <> PNativeUInt(Right)^) then
                Continue;
              NativeInt(LCount) := NativeInt(LCount) * TRAIIHelper<T>.Options.ItemSize;
              Inc(Left, SizeOf(NativeUInt));
              Inc(Right, SizeOf(NativeUInt));
            end
            else
            // if (GetTypeKind(T) in [tkLString, tkWString, tkUString]) then
            begin
              Dec(Left, SizeOf(Cardinal));
              Dec(Right, SizeOf(Cardinal));
              LCount := PCardinal(Left)^;
              if (Cardinal(LCount) <> PCardinal(Right)^) then
                Continue;
              Inc(Left, SizeOf(Cardinal));
              Inc(Right, SizeOf(Cardinal));
            end;
          end;

          // compare last (after cardinal) words
          if (GetTypeKind(T) in [tkDynArray, tkString, tkLString]) then
          begin
            if (GetTypeKind(T) in [tkString, tkLString]) {ByteStrings + 2} then
            begin
              Inc(LCount);
            end;
            if (LCount and 2 <> 0) then
            begin
              Offset := LCount and -4;
              Inc(Left, Offset);
              Inc(Right, Offset);
              if (PWord(Left)^ <> PWord(Right)^) then
                Continue;
              Offset := LCount;
              Offset := Offset and -4;
              Dec(Left, Offset);
              Dec(Right, Offset);
            end;
          end
          else
          // modify Count to have only cardinals to compare
          // if (GetTypeKind(T) in [tkWString, tkUString]) {UnicodeStrings + 2} then
          begin
            {$IFDEF MSWINDOWS}
            if (GetTypeKind(T) = tkWString) then
            begin
              if (LCount = 0) then
                goto cmp0;
            end
            else
              {$ENDIF}
            begin
              Inc(LCount, LCount);
            end;
            Inc(LCount, 2);
          end;

          {$IFDEF LARGEINT}
          if (LCount and 4 <> 0) then
          begin
            Offset := LCount and -8;
            Inc(Left, Offset);
            Inc(Right, Offset);
            if (PCardinal(Left)^ <> PCardinal(Right)^) then
              Continue;
            Dec(Left, Offset);
            Dec(Right, Offset);
          end;
          {$ENDIF}
        end
        else
        begin
          // non-dynamic (constant) size binary > 16
          if (SizeOf(T) and {$IFDEF LARGEINT}7{$ELSE}3{$ENDIF} <> 0) then
            with PData16(@Value)^ do
            begin
              {$IFDEF LARGEINT}
              if (SizeOf(T) and 4 <> 0) then
              begin
                if (Integers[(SizeOf(T) and -8) shr 2] <> PData16(Item).Integers[(SizeOf(T) and -8) shr 2]) then
                  Continue;
              end;
              {$ENDIF}
              if (SizeOf(T) and 2 <> 0) then
              begin
                if (Words[(SizeOf(T) and -4) shr 1] <> PData16(Item).Words[(SizeOf(T) and -4) shr 1]) then
                  Continue;
              end;
              if (SizeOf(T) and 1 <> 0) then
              begin
                if (Bytes[SizeOf(T) and -2] <> PData16(Item).Bytes[SizeOf(T) and -2]) then
                  Continue;
              end;
            end;
          Left := Pointer(@Value);
          Right := Pointer(Item);
          LCount := SizeOf(T);
        end;

        // natives (40 bytes static) compare
        LCount := LCount shr {$IFDEF LARGEINT}3{$ELSE}2{$ENDIF};
        case LCount of
          {$IFDEF SMALLINT}
          10: goto cmp10;
          9: goto cmp9;
          8: goto cmp8;
          7: goto cmp7;
          6: goto cmp6;
          {$ENDIF}
          5: goto cmp5;
          4: goto cmp4;
          3: goto cmp3;
          2: goto cmp2;
          1: goto cmp1;
          0: goto cmp0;
        else
          repeat
            if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
              Continue;
            Dec(LCount);
            Inc(Left, SizeOf(NativeUInt));
            Inc(Right, SizeOf(NativeUInt));
          until (LCount = {$IFDEF LARGEINT}5{$ELSE}10{$ENDIF});

          {$IFDEF SMALLINT}
          cmp10:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp9:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp8:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp7:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp6:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          {$ENDIF}
          cmp5:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp4:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp3:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp2:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          Inc(Left, SizeOf(NativeUInt));
          Inc(Right, SizeOf(NativeUInt));
          cmp1:
          if (PNativeUInt(Left)^ <> PNativeUInt(Right)^) then
            Continue;
          cmp0:
        end;
      end;

      R := NativeInt(Item) - NativeInt(Stored.Item);
      case SizeOf(T) of
        0, 1: Exit(R);
        2: Exit(R shr 1);
        4: Exit(R shr 2);
        8: Exit(R shr 3);
        16: Exit(R shr 4);
        32: Exit(R shr 5);
        64: Exit(R shr 6);
        128: Exit(R shr 7);
        256: Exit(R shr 8);
      else
        Exit(Round(R * (1 / SizeOf(T))));
      end;
    until (False);

    Exit(-1);
  end
  else
  begin
    Exit(InternalIndexOfRev(Value, FComparer));
  end;
end;

function TList<T>.InternalIndexOfRev(const Value: T; const Comparer: IComparer<T>): NativeInt;
var
  LCount: NativeInt;
  Item: PItem;
  Compare: TMethod;
begin
  LCount := FCount.Native;
  if LCount = 0 then
    Exit(-1);

  Dec(LCount);
  Item := @FItems[LCount];
  Compare.Data := Pointer(Comparer);
  Compare.Code := PPointer(PNativeUInt(Comparer)^ + 3 * SizeOf(Pointer))^;
  for Result := LCount downto 0 do
  begin
    if (TCompare(Compare.Code)(Compare.Data, Item^, Value) = 0) then
      Exit;
    Dec(Item);
  end;

  Result := -1;
end;

function TList<T>.Contains(const Value: T): Boolean;
begin
  Result := (InternalIndexOf(Value) >= 0);
end;

function TList<T>.IndexOf(const Value: T): Integer;
begin
  Result := InternalIndexOf(Value);
end;

function TList<T>.IndexOfItem(const Value: T; Direction: TDirection): Integer;
begin
  if (Direction = FromBeginning) then
  begin
    Result := InternalIndexOf(Value);
  end
  else
  begin
    Result := InternalIndexOfRev(Value);
  end;
end;

function TList<T>.LastIndexOf(const Value: T): Integer;
begin
  Result := InternalIndexOfRev(Value);
end;

function TList<T>.Remove(const Value: T): Integer;
var
  Index: NativeInt;
begin
  Index := IndexOf(Value);
  if (Index >= 0) then
    InternalDelete(Index, cnRemoved);

  Result := Index;
end;

function TList<T>.RemoveItem(const Value: T; Direction: TDirection): Integer;
var
  Index: NativeInt;
begin
  Index := IndexOfItem(Value, Direction);
  if (Index >= 0) then
    InternalDelete(Index, cnRemoved);

  Result := Index;
end;

function TList<T>.Extract(const Value: T): T;
var
  Index: NativeInt;
begin
  Index := IndexOf(Value);
  if (Index < 0) then
  begin
    Result := Default(T);
  end
  else
  begin
    Result := FItems[Index];
    InternalDelete(Index, cnExtracted);
  end;
end;

function TList<T>.ExtractItem(const Value: T; Direction: TDirection): T;
var
  Index: NativeInt;
begin
  Index := IndexOfItem(Value, Direction);
  if (Index < 0) then
  begin
    Result := Default(T);
  end
  else
  begin
    Result := FItems[Index];
    InternalDelete(Index, cnExtracted);
  end;
end;

function TList<T>.ExtractAt(Index: Integer): T;
begin
  if Cardinal(Index) >= Cardinal(Count) then
    ErrorArgumentOutOfRange(Index, Count - 1, Self);
  Result := List[Index];
  InternalDelete(Index, cnExtracted);
end;

{$IFDEF WEAKREF}
procedure TList<T>.InternalWeakPack;
label
  next_find, next_item, comparer_recall;
var
  R, Index, LastCount: NativeInt;
  Item, TopItem, DestItem: ^TRAIIHelper.TData16;
  VByte: Byte;
  VWord: Word;
  VInteger: Integer;
  VNative, Flags: NativeUInt;
begin
  Item := Pointer(FItems);
  Dec(NativeUInt(Item), SizeOf(T));
  TopItem := Pointer(TCustomList<T>.PItem(Item) + FCount.Native);
  Flags := 0; // satisfy compiler

  // find first empty
  repeat
    next_find:
    if (Item = TopItem) then
      Exit;
    Inc(NativeUInt(Item), SizeOf(T));

    if (SizeOf(T) <= 16) then
    begin
      {$IFDEF SMALLINT}
      if (SizeOf(T) >= SizeOf(Int64) * 1) then
      begin
        if (Item.Integers[0] or Item.Integers[1] <> 0) then
          Continue;
      end;
      if (SizeOf(T) = SizeOf(Int64) * 2) then
      begin
        if (Item.Integers[2] or Item.Integers[3] <> 0) then
          Continue;
      end;
      {$ELSE .LARGEINT}
      if (SizeOf(T) >= SizeOf(Int64) * 1) then
      begin
        if (Item.Int64s[0] <> 0) then
          Continue;
      end;
      if (SizeOf(T) = SizeOf(Int64) * 2) then
      begin
        if (Item.Int64s[1] <> 0) then
          Continue;
      end;
      {$ENDIF}
      case SizeOf(T) of
        4..7: if (Item.Integers[0] <> 0) then
            Continue;
        12..15: if (Item.Integers[2] <> 0) then
            Continue;
      end;
      case SizeOf(T) of
        2, 3: if (Item.Words[0] <> 0) then
            Continue;
        6, 7: if (Item.Words[2] <> 0) then
            Continue;
        10, 11: if (Item.Words[4] <> 0) then
            Continue;
        14, 15: if (Item.Words[6] <> 0) then
            Continue;
      end;
      case SizeOf(T) of
        1: if (Item.Bytes[1 - 1] <> 0) then
            Continue;
        3: if (Item.Bytes[3 - 1] <> 0) then
            Continue;
        5: if (Item.Bytes[5 - 1] <> 0) then
            Continue;
        7: if (Item.Bytes[7 - 1] <> 0) then
            Continue;
        9: if (Item.Bytes[9 - 1] <> 0) then
            Continue;
        11: if (Item.Bytes[11 - 1] <> 0) then
            Continue;
        13: if (Item.Bytes[13 - 1] <> 0) then
            Continue;
        15: if (Item.Bytes[15 - 1] <> 0) then
            Continue;
      end;
    end
    else
    begin
      DestItem := Item;
      Index := 0;
      repeat
        Inc(Index);
        if (PNativeUInt(DestItem)^ <> 0) then
          goto next_find;
        Inc(NativeUInt(DestItem), SizeOf(NativeUInt));
      until (Index = SizeOf(T) div SizeOf(NativeUInt));

      if (SizeOf(T) and (SizeOf(NativeUInt) - 1) <> 0) then
      begin
        Dec(NativeUInt(DestItem), SizeOf(T) - (SizeOf(NativeUInt) - 1));
        if (PNativeUInt(DestItem)^ <> 0) then
          goto next_find;
      end;
    end;
    Break;
  until (False);

  // compare empty and move
  DestItem := Item;
  goto next_item;
  repeat
    DestItem^ := Item^;
    Inc(NativeUInt(DestItem), SizeOf(T));
    next_item:
    if (Item = TopItem) then
      Break;
    Inc(NativeUInt(Item), SizeOf(T));

    case SizeOf(T) of
      1:
        begin
          VByte := Item.Bytes[0];
          if (VByte <> 0) then
            Continue;
        end;
      2:
        begin
          VWord := Item.Words[0];
          if (VWord <> 0) then
            Continue;
        end;
      4:
        begin
          VInteger := Item.Integers[0];
          if (VInteger <> 0) then
            Continue;
        end;
      8:
        begin
          {$IFDEF LARGEINT}
          VNative := Item.Int64s[0];
          if (VNative <> 0) then
            Continue;
          {$ELSE .SMALLINT}
          VInteger := Item.Integers[0];
          VNative := Item.Integers[1];
          if (VInteger or Integer(VNative) <> 0) then
            Continue;
          {$ENDIF}
        end;
    else
      if (SizeOf(T) < SizeOf(NativeUInt)) then
      begin
        case SizeOf(T) of
          3:
            begin
              Flags := Item.Words[0];
              DestItem.Words[0] := Flags;
              VByte := Item.Bytes[2];
              DestItem.Bytes[2] := VByte;
              Flags := Flags or VByte;
            end;
          5:
            begin
              Flags := Item.Integers[0];
              DestItem.Integers[0] := Flags;
              VByte := Item.Bytes[4];
              DestItem.Bytes[4] := VByte;
              Flags := Flags or VByte;
            end;
          6:
            begin
              Flags := Item.Integers[0];
              DestItem.Integers[0] := Flags;
              VWord := Item.Words[2];
              DestItem.Words[2] := VWord;
              Flags := Flags or VWord;
            end;
          7:
            begin
              Flags := Item.Integers[0];
              DestItem.Integers[0] := Flags;
              VWord := Item.Words[2];
              DestItem.Words[2] := VWord;
              Flags := Flags or VWord;
              VByte := Item.Bytes[6];
              DestItem.Bytes[6] := VByte;
              Flags := Flags or VByte;
            end;
        end;
      end
      else if (SizeOf(T) <= 16) then
      begin
        {$IFDEF LARGEINT}
        Flags := Item.Int64s[0];
        DestItem.Int64s[0] := Flags;
        {$ELSE .SMALLINT}
        Flags := Item.Integers[0];
        DestItem.Integers[0] := Flags;
        {$ENDIF}

        {$IFDEF SMALLINT}
        if (SizeOf(T) >= SizeOf(Integer) * 2) then
        begin
          VInteger := Item.Integers[1];
          Item.Integers[1] := VInteger;
          Flags := Flags or Cardinal(VInteger);
        end;
        if (SizeOf(T) >= SizeOf(Integer) * 3) then
        begin
          VInteger := Item.Integers[2];
          Item.Integers[2] := VInteger;
          Flags := Flags or Cardinal(VInteger);
        end;
        if (SizeOf(T) = SizeOf(Integer) * 4) then
        begin
          VInteger := Item.Integers[3];
          Item.Integers[3] := VInteger;
          Flags := Flags or Cardinal(VInteger);
        end;
        {$ELSE .LARGEINT}
        if (SizeOf(T) = SizeOf(Int64) * 2) then
        begin
          VNative := Item.Int64s[1];
          Item.Int64s[1] := VNative;
          Flags := Flags or VNative;
        end;
        {$ENDIF}

        if (SizeOf(T) and (SizeOf(NativeUInt) - 1) <> 0) then
        begin
          VNative := PNativeUInt(@Item.Bytes[SizeOf(T) - SizeOf(NativeUInt)])^;
          PNativeUInt(@DestItem.Bytes[SizeOf(T) - SizeOf(NativeUInt)])^ := VNative;
          Flags := Flags or VNative;
        end;
      end
      else
      begin
        Flags := 0;

        Index := 0;
        repeat
          Inc(Index);
          VNative := PNativeUInt(Item)^;
          PNativeUInt(DestItem)^ := VNative;
          Inc(NativeUInt(Item), SizeOf(NativeUInt));
          Inc(NativeUInt(DestItem), SizeOf(NativeUInt));
          Flags := Flags or VNative;
        until (Index = SizeOf(T) div SizeOf(NativeUInt));

        if (SizeOf(T) and (SizeOf(NativeUInt) - 1) <> 0) then
        begin
          Dec(NativeUInt(Item), SizeOf(T) - (SizeOf(NativeUInt) - 1));
          Dec(NativeUInt(DestItem), SizeOf(T) - (SizeOf(NativeUInt) - 1));
          VNative := PNativeUInt(Item)^;
          PNativeUInt(DestItem)^ := VNative;
          Flags := Flags or VNative;
        end;

        Dec(NativeUInt(Item), (SizeOf(T) div SizeOf(NativeUInt)) * SizeOf(NativeUInt));
        Dec(NativeUInt(DestItem), (SizeOf(T) div SizeOf(NativeUInt)) * SizeOf(NativeUInt));
      end;

      if (Flags <> 0) then
        Continue;
    end;

    goto next_item;
  until (False);

  LastCount := FCount.Native;
  R := NativeInt(DestItem) - NativeInt(FItems);
  case SizeOf(T) of
    0, 1: FCount.Native := R;
    2: FCount.Native := R shr 1;
    4: FCount.Native := R shr 2;
    8: FCount.Native := R shr 3;
    16: FCount.Native := R shr 4;
    32: FCount.Native := R shr 5;
    64: FCount.Native := R shr 6;
    128: FCount.Native := R shr 7;
    256: FCount.Native := R shr 8;
  else
    FCount.Native := Round(R * (1 / SizeOf(T)));
  end;
  System.FinalizeArray(@FItems[FCount.Native], TypeInfo(T), LastCount - FCount.Native);
end;
{$ENDIF}

{$WARNINGS OFF} // compiler can't correctly identify initialized variables in case statements

procedure TList<T>.InternalPackDifficults;
label
  next_item;
var
  R: NativeInt;
  Item, TopItem, DestItem: PItem;
  VarData: PVarData;
  {$IFNDEF CPUX86}
  VSingle, VSingleNull: Single;
  VDouble, VDoubleNull: Double;
  VExtended, VExtendedNull: Extended;
  {$ENDIF}
begin
  Item := Pointer(FItems);
  Dec(Item);
  TopItem := Item + FCount.Native;

  {$IFNDEF CPUX86}
  case SizeOf(T) of
    4:
      begin
        VSingleNull := 0;
      end;
    10:
      begin
        VExtendedNull := 0;
      end;
  else
    VDoubleNull := 0;
  end;
  {$ENDIF}

  repeat
    if (Item = TopItem) then
      Exit;
    Inc(Item);

    if (GetTypeKind(T) = tkVariant) then
    begin
      VarData := Pointer(Item);
      while (VarData.VType = varByRef or varVariant) do
        VarData := PVarData(VarData.VPointer);

      if (VarData.VType > varNull) then
        Continue;
    end
    else if (GetTypeKind(T) = tkFloat) then
    begin
      case SizeOf(T) of
        4:
          begin
            if (PSingle(Item)^ <> {$IFNDEF CPUX86}VSingleNull{$ELSE}0{$ENDIF}) then
              Continue;
          end;
        10:
          begin
            if (PExtended(Item)^ <> {$IFNDEF CPUX86}VExtendedNull{$ELSE}0{$ENDIF}) then
              Continue;
          end;
      else
        if (PDouble(Item)^ <> {$IFNDEF CPUX86}VDoubleNull{$ELSE}0{$ENDIF}) then
          Continue;
      end;
    end
    else
    //if (GetTypeKind(T) = tkString) then
    begin
      if (PByte(Item)^ <> 0) then
        Continue;
    end;
    Break;
  until (False);

  DestItem := Item;
  goto next_item;
  repeat
    // DestItem^ := Item^;
    if (GetTypeKind(T) = tkVariant) then
    begin
      PRect(DestItem)^ := PRect(Item)^;
    end
    else if (GetTypeKind(T) = tkFloat) then
    begin
      {$IFDEF CPUX86}
      DestItem^ := Item^;
      {$ELSE !CPUX86}
      case SizeOf(T) of
        4: PSingle(DestItem)^ := VSingle;
        10: PExtended(DestItem)^ := VExtended;
      else
        PDouble(DestItem)^ := VDouble;
      end;
      {$ENDIF}
    end
    else
    begin
      DestItem^ := Item^;
    end;

    Inc(DestItem);
    next_item:
    if (Item = TopItem) then
      Break;
    Inc(Item);

    if (GetTypeKind(T) = tkVariant) then
    begin
      VarData := Pointer(Item);
      while (VarData.VType = varByRef or varVariant) do
        VarData := PVarData(VarData.VPointer);

      if (VarData.VType > varNull) then
        Continue;
    end
    else if (GetTypeKind(T) = tkFloat) then
    begin
      case SizeOf(T) of
        4:
          begin
            {$IFDEF CPUX86}
            if (PSingle(Item)^ <> 0) then
              Continue;
            {$ELSE}
            VSingle := PSingle(Item)^;
            if (VSingle <> VSingleNull) then
              Continue;
            {$ENDIF}
          end;
        10:
          begin
            {$IFDEF CPUX86}
            if (PExtended(Item)^ <> 0) then
              Continue;
            {$ELSE}
            VExtended := PExtended(Item)^;
            if (VExtended <> VExtendedNull) then
              Continue;
            {$ENDIF}
          end;
      else
        {$IFDEF CPUX86}
        if (PDouble(Item)^ <> 0) then
          Continue;
        {$ELSE}
        VDouble := PDouble(Item)^;
        if (VDouble <> VDoubleNull) then
          Continue;
        {$ENDIF}
      end;
    end
    else
    //if (GetTypeKind(T) = tkString) then
    begin
      if (PByte(Item)^ <> 0) then
        Continue;
    end;

    goto next_item;
  until (False);

  R := NativeInt(DestItem) - NativeInt(FItems);
  case SizeOf(T) of
    0, 1: FCount.Native := R;
    2: FCount.Native := R shr 1;
    4: FCount.Native := R shr 2;
    8: FCount.Native := R shr 3;
    16: FCount.Native := R shr 4;
    32: FCount.Native := R shr 5;
    64: FCount.Native := R shr 6;
    128: FCount.Native := R shr 7;
    256: FCount.Native := R shr 8;
  else
    FCount.Native := Round(R * (1 / SizeOf(T)));
  end;
end;
{$WARNINGS ON}

{$WARNINGS OFF}

procedure TList<T>.Pack;
label
  next_find, next_item, comparer_recall;
var
  R, Index: NativeInt;
  Item, TopItem, DestItem: ^TRAIIHelper.TData16;
  // AM: Compiler reports these variables as being not initialized, but
  // they are assigned values from Item in the next_item loop before being checked.
  VByte: Byte;
  VWord: Word;
  VInteger: Integer;
  VNative, Flags: NativeUInt;
begin
  if (Assigned(FComparer)) then
    goto comparer_recall;

  {$IFDEF WEAKREF}
  if (TRAIIHelper<T>.Weak) then
  begin
    Self.InternalWeakPack;
  end
  else
    {$ENDIF}
  begin
    if (GetTypeKind(T) = tkVariant) or (GetTypeKind(T) = tkString) or
      (GetTypeKind(T) = tkFloat) and
      (
      (SizeOf(T) <> SizeOf(Double)) or (TRAIIHelper<T>.Options.ItemSize >= 0)
      ) then
    begin
      Self.InternalPackDifficults;
      Exit;
    end;

    Item := Pointer(FItems);
    Dec(NativeUInt(Item), SizeOf(T));
    TopItem := Pointer(TCustomList<T>.PItem(Item) + FCount.Native);
    Flags := 0; // satisfy compiler

    // find first empty
    repeat
      next_find:
      if (Item = TopItem) then
        Exit;
      Inc(NativeUInt(Item), SizeOf(T));

      if (SizeOf(T) <= 16) then
      begin
        {$IFDEF SMALLINT}
        if (SizeOf(T) >= SizeOf(Int64) * 1) then
        begin
          if (Item.Integers[0] or Item.Integers[1] <> 0) then
            Continue;
        end;
        if (SizeOf(T) = SizeOf(Int64) * 2) then
        begin
          if (Item.Integers[2] or Item.Integers[3] <> 0) then
            Continue;
        end;
        {$ELSE .LARGEINT}
        if (SizeOf(T) >= SizeOf(Int64) * 1) then
        begin
          if (Item.Int64s[0] <> 0) then
            Continue;
        end;
        if (SizeOf(T) = SizeOf(Int64) * 2) then
        begin
          if (Item.Int64s[1] <> 0) then
            Continue;
        end;
        {$ENDIF}
        case SizeOf(T) of
          4..7: if (Item.Integers[0] <> 0) then
              Continue;
          12..15: if (Item.Integers[2] <> 0) then
              Continue;
        end;
        case SizeOf(T) of
          2, 3: if (Item.Words[0] <> 0) then
              Continue;
          6, 7: if (Item.Words[2] <> 0) then
              Continue;
          10, 11: if (Item.Words[4] <> 0) then
              Continue;
          14, 15: if (Item.Words[6] <> 0) then
              Continue;
        end;
        case SizeOf(T) of
          1: if (Item.Bytes[1 - 1] <> 0) then
              Continue;
          3: if (Item.Bytes[3 - 1] <> 0) then
              Continue;
          5: if (Item.Bytes[5 - 1] <> 0) then
              Continue;
          7: if (Item.Bytes[7 - 1] <> 0) then
              Continue;
          9: if (Item.Bytes[9 - 1] <> 0) then
              Continue;
          11: if (Item.Bytes[11 - 1] <> 0) then
              Continue;
          13: if (Item.Bytes[13 - 1] <> 0) then
              Continue;
          15: if (Item.Bytes[15 - 1] <> 0) then
              Continue;
        end;
      end
      else
      begin
        DestItem := Item;
        Index := 0;
        repeat
          Inc(Index);
          if (PNativeUInt(DestItem)^ <> 0) then
            goto next_find;
          Inc(NativeUInt(DestItem), SizeOf(NativeUInt));
        until (Index = SizeOf(T) div SizeOf(NativeUInt));

        if (SizeOf(T) and (SizeOf(NativeUInt) - 1) <> 0) then
        begin
          Dec(NativeUInt(DestItem), SizeOf(T) - (SizeOf(NativeUInt) - 1));
          if (PNativeUInt(DestItem)^ <> 0) then
            goto next_find;
        end;
      end;
      Break;
    until (False);

    // compare empty and move
    DestItem := Item;
    goto next_item;
    repeat
      // DestItem^ := Item^;
      case SizeOf(T) of
        1: DestItem.Bytes[0] := VByte;
        2: DestItem.Words[0] := VWord;
        4: DestItem.Integers[0] := VInteger;
        8:
          begin
            {$IFDEF LARGEINT}
            DestItem.Int64s[0] := VNative;
            {$ELSE .SMALLINT}
            DestItem.Integers[0] := VInteger;
            DestItem.Integers[1] := VNative;
            {$ENDIF}
          end;
        3: TRAIIHelper.T3(Pointer(DestItem)^) := TRAIIHelper.T3(Pointer(Item)^);
        5: TRAIIHelper.T5(Pointer(DestItem)^) := TRAIIHelper.T5(Pointer(Item)^);
        6: TRAIIHelper.T6(Pointer(DestItem)^) := TRAIIHelper.T6(Pointer(Item)^);
        7: TRAIIHelper.T7(Pointer(DestItem)^) := TRAIIHelper.T7(Pointer(Item)^);
        9: TRAIIHelper.T9(Pointer(DestItem)^) := TRAIIHelper.T9(Pointer(Item)^);
        10: TRAIIHelper.T10(Pointer(DestItem)^) := TRAIIHelper.T10(Pointer(Item)^);
        11: TRAIIHelper.T11(Pointer(DestItem)^) := TRAIIHelper.T11(Pointer(Item)^);
        12: TRAIIHelper.T12(Pointer(DestItem)^) := TRAIIHelper.T12(Pointer(Item)^);
        13: TRAIIHelper.T13(Pointer(DestItem)^) := TRAIIHelper.T13(Pointer(Item)^);
        14: TRAIIHelper.T14(Pointer(DestItem)^) := TRAIIHelper.T14(Pointer(Item)^);
        15: TRAIIHelper.T15(Pointer(DestItem)^) := TRAIIHelper.T15(Pointer(Item)^);
        16: TRAIIHelper.T16(Pointer(DestItem)^) := TRAIIHelper.T16(Pointer(Item)^);
        17: TRAIIHelper.T17(Pointer(DestItem)^) := TRAIIHelper.T17(Pointer(Item)^);
        18: TRAIIHelper.T18(Pointer(DestItem)^) := TRAIIHelper.T18(Pointer(Item)^);
        19: TRAIIHelper.T19(Pointer(DestItem)^) := TRAIIHelper.T19(Pointer(Item)^);
        20: TRAIIHelper.T20(Pointer(DestItem)^) := TRAIIHelper.T20(Pointer(Item)^);
        21: TRAIIHelper.T21(Pointer(DestItem)^) := TRAIIHelper.T21(Pointer(Item)^);
        22: TRAIIHelper.T22(Pointer(DestItem)^) := TRAIIHelper.T22(Pointer(Item)^);
        23: TRAIIHelper.T23(Pointer(DestItem)^) := TRAIIHelper.T23(Pointer(Item)^);
        24: TRAIIHelper.T24(Pointer(DestItem)^) := TRAIIHelper.T24(Pointer(Item)^);
        25: TRAIIHelper.T25(Pointer(DestItem)^) := TRAIIHelper.T25(Pointer(Item)^);
        26: TRAIIHelper.T26(Pointer(DestItem)^) := TRAIIHelper.T26(Pointer(Item)^);
        27: TRAIIHelper.T27(Pointer(DestItem)^) := TRAIIHelper.T27(Pointer(Item)^);
        28: TRAIIHelper.T28(Pointer(DestItem)^) := TRAIIHelper.T28(Pointer(Item)^);
        29: TRAIIHelper.T29(Pointer(DestItem)^) := TRAIIHelper.T29(Pointer(Item)^);
        30: TRAIIHelper.T30(Pointer(DestItem)^) := TRAIIHelper.T30(Pointer(Item)^);
        31: TRAIIHelper.T31(Pointer(DestItem)^) := TRAIIHelper.T31(Pointer(Item)^);
        32: TRAIIHelper.T32(Pointer(DestItem)^) := TRAIIHelper.T32(Pointer(Item)^);
        33: TRAIIHelper.T33(Pointer(DestItem)^) := TRAIIHelper.T33(Pointer(Item)^);
        34: TRAIIHelper.T34(Pointer(DestItem)^) := TRAIIHelper.T34(Pointer(Item)^);
        35: TRAIIHelper.T35(Pointer(DestItem)^) := TRAIIHelper.T35(Pointer(Item)^);
        36: TRAIIHelper.T36(Pointer(DestItem)^) := TRAIIHelper.T36(Pointer(Item)^);
        37: TRAIIHelper.T37(Pointer(DestItem)^) := TRAIIHelper.T37(Pointer(Item)^);
        38: TRAIIHelper.T38(Pointer(DestItem)^) := TRAIIHelper.T38(Pointer(Item)^);
        39: TRAIIHelper.T39(Pointer(DestItem)^) := TRAIIHelper.T39(Pointer(Item)^);
        40: TRAIIHelper.T40(Pointer(DestItem)^) := TRAIIHelper.T40(Pointer(Item)^);
      else
        System.Move(Item^, DestItem^, SizeOf(T));
      end;
      Inc(NativeUInt(DestItem), SizeOf(T));
      next_item:
      if (Item = TopItem) then
        Break;
      Inc(NativeUInt(Item), SizeOf(T));

      case SizeOf(T) of
        1:
          begin
            VByte := Item.Bytes[0];
            if (VByte <> 0) then
              Continue;
          end;
        2:
          begin
            VWord := Item.Words[0];
            if (VWord <> 0) then
              Continue;
          end;
        4:
          begin
            VInteger := Item.Integers[0];
            if (VInteger <> 0) then
              Continue;
          end;
        8:
          begin
            {$IFDEF LARGEINT}
            VNative := Item.Int64s[0];
            if (VNative <> 0) then
              Continue;
            {$ELSE .SMALLINT}
            VInteger := Item.Integers[0];
            VNative := Item.Integers[1];
            if (VInteger or Integer(VNative) <> 0) then
              Continue;
            {$ENDIF}
          end;
      else
        if (SizeOf(T) < SizeOf(NativeUInt)) then
        begin
          case SizeOf(T) of
            3:
              begin
                Flags := Item.Words[0];
                DestItem.Words[0] := Flags;
                VByte := Item.Bytes[2];
                DestItem.Bytes[2] := VByte;
                Flags := Flags or VByte;
              end;
            5:
              begin
                Flags := Item.Integers[0];
                DestItem.Integers[0] := Flags;
                VByte := Item.Bytes[4];
                DestItem.Bytes[4] := VByte;
                Flags := Flags or VByte;
              end;
            6:
              begin
                Flags := Item.Integers[0];
                DestItem.Integers[0] := Flags;
                VWord := Item.Words[2];
                DestItem.Words[2] := VWord;
                Flags := Flags or VWord;
              end;
            7:
              begin
                Flags := Item.Integers[0];
                DestItem.Integers[0] := Flags;
                VWord := Item.Words[2];
                DestItem.Words[2] := VWord;
                Flags := Flags or VWord;
                VByte := Item.Bytes[6];
                DestItem.Bytes[6] := VByte;
                Flags := Flags or VByte;
              end;
          end;
        end
        else if (SizeOf(T) <= 16) then
        begin
          {$IFDEF LARGEINT}
          Flags := Item.Int64s[0];
          DestItem.Int64s[0] := Flags;
          {$ELSE .SMALLINT}
          Flags := Item.Integers[0];
          DestItem.Integers[0] := Flags;
          {$ENDIF}

          {$IFDEF SMALLINT}
          if (SizeOf(T) >= SizeOf(Integer) * 2) then
          begin
            VInteger := Item.Integers[1];
            Item.Integers[1] := VInteger;
            Flags := Flags or Cardinal(VInteger);
          end;
          if (SizeOf(T) >= SizeOf(Integer) * 3) then
          begin
            VInteger := Item.Integers[2];
            Item.Integers[2] := VInteger;
            Flags := Flags or Cardinal(VInteger);
          end;
          if (SizeOf(T) = SizeOf(Integer) * 4) then
          begin
            VInteger := Item.Integers[3];
            Item.Integers[3] := VInteger;
            Flags := Flags or Cardinal(VInteger);
          end;
          {$ELSE .LARGEINT}
          if (SizeOf(T) = SizeOf(Int64) * 2) then
          begin
            VNative := Item.Int64s[1];
            Item.Int64s[1] := VNative;
            Flags := Flags or VNative;
          end;
          {$ENDIF}

          if (SizeOf(T) and (SizeOf(NativeUInt) - 1) <> 0) then
          begin
            VNative := PNativeUInt(@Item.Bytes[SizeOf(T) - SizeOf(NativeUInt)])^;
            PNativeUInt(@DestItem.Bytes[SizeOf(T) - SizeOf(NativeUInt)])^ := VNative;
            Flags := Flags or VNative;
          end;
        end
        else
        begin
          Flags := 0;

          Index := 0;
          repeat
            Inc(Index);
            VNative := PNativeUInt(Item)^;
            PNativeUInt(DestItem)^ := VNative;
            Inc(NativeUInt(Item), SizeOf(NativeUInt));
            Inc(NativeUInt(DestItem), SizeOf(NativeUInt));
            Flags := Flags or VNative;
          until (Index = SizeOf(T) div SizeOf(NativeUInt));

          if (SizeOf(T) and (SizeOf(NativeUInt) - 1) <> 0) then
          begin
            Dec(NativeUInt(Item), SizeOf(T) - (SizeOf(NativeUInt) - 1));
            Dec(NativeUInt(DestItem), SizeOf(T) - (SizeOf(NativeUInt) - 1));
            VNative := PNativeUInt(Item)^;
            PNativeUInt(DestItem)^ := VNative;
            Flags := Flags or VNative;
          end;

          Dec(NativeUInt(Item), (SizeOf(T) div SizeOf(NativeUInt)) * SizeOf(NativeUInt));
          Dec(NativeUInt(DestItem), (SizeOf(T) div SizeOf(NativeUInt)) * SizeOf(NativeUInt));
        end;

        if (Flags <> 0) then
          Continue;
      end;

      goto next_item;
    until (False);

    R := NativeInt(DestItem) - NativeInt(FItems);
    case SizeOf(T) of
      0, 1: FCount.Native := R;
      2: FCount.Native := R shr 1;
      4: FCount.Native := R shr 2;
      8: FCount.Native := R shr 3;
      16: FCount.Native := R shr 4;
      32: FCount.Native := R shr 5;
      64: FCount.Native := R shr 6;
      128: FCount.Native := R shr 7;
      256: FCount.Native := R shr 8;
    else
      FCount.Native := Round(R * (1 / SizeOf(T)));
    end;
  end;
  Exit;

  comparer_recall:
  {$IFDEF WEAKREF}
  if (TRAIIHelper<T>.Weak) then
  begin
    Self.InternalWeakPackComparer;
  end
  else
    {$ENDIF}
    Self.InternalPackComparer;
end;
{$WARNINGS ON}

{$IFDEF WEAKREF}
procedure TList<T>.InternalWeakPack(const IsEmpty: TEmptyFunc);
var
  R, LastCount: NativeInt;
  Item, TopItem, DestItem: PItem;
  Equals: TMethod;
  _Self: TList<T>;
begin
  Equals.Data := PPointer(@IsEmpty)^;
  Equals.Code := PPointer(PNativeUInt(Equals.Data)^ + 3 * SizeOf(Pointer))^;

  _Self := Self;
  with _Self do
  begin
    Item := Pointer(FItems);
    Dec(Item);
    TopItem := Item + FCount.Native;
  end;

  repeat
    if (Item = TopItem) then
      Exit;
    Inc(Item);
  until (TEquals(Equals.Code)(Equals.Data, Item^, Default(T)));

  DestItem := Item;
  Inc(TopItem);
  repeat
    Inc(Item);
    if (Item = TopItem) then
      Break;
  until (not TEquals(Equals.Code)(Equals.Data, Item^, Default(T)));

  if (Item <> TopItem) then
    repeat
      DestItem^ := Item^;
      Inc(DestItem);
      repeat
        Inc(Item);
        if (Item = TopItem) then
          Break;
      until (not TEquals(Equals.Code)(Equals.Data, Item^, Default(T)));
    until (Item = TopItem);

  _Self := Self;
  with _Self do
  begin
    LastCount := FCount.Native;
    R := NativeInt(DestItem) - NativeInt(FItems);
    case SizeOf(T) of
      0, 1: FCount.Native := R;
      2: FCount.Native := R shr 1;
      4: FCount.Native := R shr 2;
      8: FCount.Native := R shr 3;
      16: FCount.Native := R shr 4;
      32: FCount.Native := R shr 5;
      64: FCount.Native := R shr 6;
      128: FCount.Native := R shr 7;
      256: FCount.Native := R shr 8;
    else
      FCount.Native := Round(R * (1 / SizeOf(T)));
    end;
    System.FinalizeArray(@FItems[FCount.Native], TypeInfo(T), LastCount - FCount.Native);
  end;
end;
{$ENDIF}

procedure TList<T>.Pack(const IsEmpty: TEmptyFunc);
var
  R, i: NativeInt;
  Item, TopItem, DestItem: PItem;
  Equals: TMethod;
  _Self: TList<T>;
begin
  {$IFDEF WEAKREF}
  if (TRAIIHelper<T>.Weak) then
  begin
    InternalWeakPack(IsEmpty);
  end
  else
    {$ENDIF}
  begin
    Equals.Data := PPointer(@IsEmpty)^;
    Equals.Code := PPointer(PNativeUInt(Equals.Data)^ + 3 * SizeOf(Pointer))^;

    _Self := Self;
    with _Self do
    begin
      Item := Pointer(FItems);
      Dec(Item);
      TopItem := Item + FCount.Native;
    end;

    repeat
      if (Item = TopItem) then
        Exit;
      Inc(Item);
    until (TEquals(Equals.Code)(Equals.Data, Item^, Default(T)));

    DestItem := Item;
    Inc(TopItem);
    repeat
      Inc(Item);
      if (Item = TopItem) then
        Break;
    until (not TEquals(Equals.Code)(Equals.Data, Item^, Default(T)));

    if (Item <> TopItem) then
      repeat
      // DestItem^ := Item^;
        case SizeOf(T) of
          1: TRAIIHelper.T1(Pointer(DestItem)^) := TRAIIHelper.T1(Pointer(Item)^);
          2: TRAIIHelper.T2(Pointer(DestItem)^) := TRAIIHelper.T2(Pointer(Item)^);
          3: TRAIIHelper.T3(Pointer(DestItem)^) := TRAIIHelper.T3(Pointer(Item)^);
          4: TRAIIHelper.T4(Pointer(DestItem)^) := TRAIIHelper.T4(Pointer(Item)^);
          5: TRAIIHelper.T5(Pointer(DestItem)^) := TRAIIHelper.T5(Pointer(Item)^);
          6: TRAIIHelper.T6(Pointer(DestItem)^) := TRAIIHelper.T6(Pointer(Item)^);
          7: TRAIIHelper.T7(Pointer(DestItem)^) := TRAIIHelper.T7(Pointer(Item)^);
          8: TRAIIHelper.T8(Pointer(DestItem)^) := TRAIIHelper.T8(Pointer(Item)^);
          9: TRAIIHelper.T9(Pointer(DestItem)^) := TRAIIHelper.T9(Pointer(Item)^);
          10: TRAIIHelper.T10(Pointer(DestItem)^) := TRAIIHelper.T10(Pointer(Item)^);
          11: TRAIIHelper.T11(Pointer(DestItem)^) := TRAIIHelper.T11(Pointer(Item)^);
          12: TRAIIHelper.T12(Pointer(DestItem)^) := TRAIIHelper.T12(Pointer(Item)^);
          13: TRAIIHelper.T13(Pointer(DestItem)^) := TRAIIHelper.T13(Pointer(Item)^);
          14: TRAIIHelper.T14(Pointer(DestItem)^) := TRAIIHelper.T14(Pointer(Item)^);
          15: TRAIIHelper.T15(Pointer(DestItem)^) := TRAIIHelper.T15(Pointer(Item)^);
          16: TRAIIHelper.T16(Pointer(DestItem)^) := TRAIIHelper.T16(Pointer(Item)^);
          17: TRAIIHelper.T17(Pointer(DestItem)^) := TRAIIHelper.T17(Pointer(Item)^);
          18: TRAIIHelper.T18(Pointer(DestItem)^) := TRAIIHelper.T18(Pointer(Item)^);
          19: TRAIIHelper.T19(Pointer(DestItem)^) := TRAIIHelper.T19(Pointer(Item)^);
          20: TRAIIHelper.T20(Pointer(DestItem)^) := TRAIIHelper.T20(Pointer(Item)^);
          21: TRAIIHelper.T21(Pointer(DestItem)^) := TRAIIHelper.T21(Pointer(Item)^);
          22: TRAIIHelper.T22(Pointer(DestItem)^) := TRAIIHelper.T22(Pointer(Item)^);
          23: TRAIIHelper.T23(Pointer(DestItem)^) := TRAIIHelper.T23(Pointer(Item)^);
          24: TRAIIHelper.T24(Pointer(DestItem)^) := TRAIIHelper.T24(Pointer(Item)^);
          25: TRAIIHelper.T25(Pointer(DestItem)^) := TRAIIHelper.T25(Pointer(Item)^);
          26: TRAIIHelper.T26(Pointer(DestItem)^) := TRAIIHelper.T26(Pointer(Item)^);
          27: TRAIIHelper.T27(Pointer(DestItem)^) := TRAIIHelper.T27(Pointer(Item)^);
          28: TRAIIHelper.T28(Pointer(DestItem)^) := TRAIIHelper.T28(Pointer(Item)^);
          29: TRAIIHelper.T29(Pointer(DestItem)^) := TRAIIHelper.T29(Pointer(Item)^);
          30: TRAIIHelper.T30(Pointer(DestItem)^) := TRAIIHelper.T30(Pointer(Item)^);
          31: TRAIIHelper.T31(Pointer(DestItem)^) := TRAIIHelper.T31(Pointer(Item)^);
          32: TRAIIHelper.T32(Pointer(DestItem)^) := TRAIIHelper.T32(Pointer(Item)^);
          33: TRAIIHelper.T33(Pointer(DestItem)^) := TRAIIHelper.T33(Pointer(Item)^);
          34: TRAIIHelper.T34(Pointer(DestItem)^) := TRAIIHelper.T34(Pointer(Item)^);
          35: TRAIIHelper.T35(Pointer(DestItem)^) := TRAIIHelper.T35(Pointer(Item)^);
          36: TRAIIHelper.T36(Pointer(DestItem)^) := TRAIIHelper.T36(Pointer(Item)^);
          37: TRAIIHelper.T37(Pointer(DestItem)^) := TRAIIHelper.T37(Pointer(Item)^);
          38: TRAIIHelper.T38(Pointer(DestItem)^) := TRAIIHelper.T38(Pointer(Item)^);
          39: TRAIIHelper.T39(Pointer(DestItem)^) := TRAIIHelper.T39(Pointer(Item)^);
          40: TRAIIHelper.T40(Pointer(DestItem)^) := TRAIIHelper.T40(Pointer(Item)^);
        else
          for i := 1 to SizeOf(T) div SizeOf(NativeUInt) do
          begin
            NativeUInt(Pointer(DestItem)^) := NativeUInt(Pointer(Item)^);
            Inc(NativeInt(Item), SizeOf(NativeUInt));
            Inc(NativeInt(DestItem), SizeOf(NativeUInt));
          end;

          case SizeOf(T) and (SizeOf(NativeUInt) - 1) of
            1: TRAIIHelper.T1(Pointer(DestItem)^) := TRAIIHelper.T1(Pointer(Item)^);
            2: TRAIIHelper.T2(Pointer(DestItem)^) := TRAIIHelper.T2(Pointer(Item)^);
            3: TRAIIHelper.T3(Pointer(DestItem)^) := TRAIIHelper.T3(Pointer(Item)^);
            {$IFDEF LARGEINT}
            4: TRAIIHelper.T4(Pointer(DestItem)^) := TRAIIHelper.T4(Pointer(Item)^);
            5: TRAIIHelper.T5(Pointer(DestItem)^) := TRAIIHelper.T5(Pointer(Item)^);
            6: TRAIIHelper.T6(Pointer(DestItem)^) := TRAIIHelper.T6(Pointer(Item)^);
            7: TRAIIHelper.T7(Pointer(DestItem)^) := TRAIIHelper.T7(Pointer(Item)^);
            {$ENDIF}
          end;

          Dec(NativeInt(DestItem), (SizeOf(T) div SizeOf(NativeUInt)) * SizeOf(NativeUInt));
          Dec(NativeInt(Item), (SizeOf(T) div SizeOf(NativeUInt)) * SizeOf(NativeUInt));
        end;
        Inc(DestItem);
        repeat
          Inc(Item);
          if (Item = TopItem) then
            Break;
        until (not TEquals(Equals.Code)(Equals.Data, Item^, Default(T)));
      until (Item = TopItem);

    _Self := Self;
    with _Self do
    begin
      R := NativeInt(DestItem) - NativeInt(FItems);
      case SizeOf(T) of
        0, 1: FCount.Native := R;
        2: FCount.Native := R shr 1;
        4: FCount.Native := R shr 2;
        8: FCount.Native := R shr 3;
        16: FCount.Native := R shr 4;
        32: FCount.Native := R shr 5;
        64: FCount.Native := R shr 6;
        128: FCount.Native := R shr 7;
        256: FCount.Native := R shr 8;
      else
        FCount.Native := Round(R * (1 / SizeOf(T)));
      end;
    end;
  end;
end;

{$IFDEF WEAKREF}
procedure TList<T>.InternalWeakPackComparer;
var
  R, LastCount: NativeInt;
  Item, TopItem, DestItem: PItem;
  Compare: TMethod;
  _Self: TList<T>;
begin
  Compare.Data := Pointer(FComparer);
  Compare.Code := PPointer(PNativeUInt(Compare.Data)^ + 3 * SizeOf(Pointer))^;

  _Self := Self;
  with _Self do
  begin
    Item := Pointer(FItems);
    Dec(Item);
    TopItem := Item + FCount.Native;
  end;

  repeat
    if (Item = TopItem) then
      Exit;
    Inc(Item);
  until (TCompare(Compare.Code)(Compare.Data, Item^, Default(T)) = 0);

  DestItem := Item;
  Inc(TopItem);
  repeat
    Inc(Item);
    if (Item = TopItem) then
      Break;
  until (TCompare(Compare.Code)(Compare.Data, Item^, Default(T)) <> 0);

  if (Item <> TopItem) then
    repeat
      DestItem^ := Item^;
      Inc(DestItem);
      repeat
        Inc(Item);
        if (Item = TopItem) then
          Break;
      until (TCompare(Compare.Code)(Compare.Data, Item^, Default(T)) <> 0);
    until (Item = TopItem);

  _Self := Self;
  with _Self do
  begin
    LastCount := FCount.Native;
    R := NativeInt(DestItem) - NativeInt(FItems);
    case SizeOf(T) of
      0, 1: FCount.Native := R;
      2: FCount.Native := R shr 1;
      4: FCount.Native := R shr 2;
      8: FCount.Native := R shr 3;
      16: FCount.Native := R shr 4;
      32: FCount.Native := R shr 5;
      64: FCount.Native := R shr 6;
      128: FCount.Native := R shr 7;
      256: FCount.Native := R shr 8;
    else
      FCount.Native := Round(R * (1 / SizeOf(T)));
    end;
    System.FinalizeArray(@FItems[FCount.Native], TypeInfo(T), LastCount - FCount.Native);
  end;
end;
{$ENDIF}

procedure TList<T>.InternalPackComparer;
var
  R, i: NativeInt;
  Item, TopItem, DestItem: PItem;
  Compare: TMethod;
  _Self: TList<T>;
begin
  Compare.Data := Pointer(FComparer);
  Compare.Code := PPointer(PNativeUInt(Compare.Data)^ + 3 * SizeOf(Pointer))^;

  _Self := Self;
  with _Self do
  begin
    Item := Pointer(FItems);
    Dec(Item);
    TopItem := Item + FCount.Native;
  end;

  repeat
    if (Item = TopItem) then
      Exit;
    Inc(Item);
  until (TCompare(Compare.Code)(Compare.Data, Item^, Default(T)) = 0);

  DestItem := Item;
  Inc(TopItem);
  repeat
    Inc(Item);
    if (Item = TopItem) then
      Break;
  until (TCompare(Compare.Code)(Compare.Data, Item^, Default(T)) <> 0);

  if (Item <> TopItem) then
    repeat
    // DestItem^ := Item^;
      case SizeOf(T) of
        1: TRAIIHelper.T1(Pointer(DestItem)^) := TRAIIHelper.T1(Pointer(Item)^);
        2: TRAIIHelper.T2(Pointer(DestItem)^) := TRAIIHelper.T2(Pointer(Item)^);
        3: TRAIIHelper.T3(Pointer(DestItem)^) := TRAIIHelper.T3(Pointer(Item)^);
        4: TRAIIHelper.T4(Pointer(DestItem)^) := TRAIIHelper.T4(Pointer(Item)^);
        5: TRAIIHelper.T5(Pointer(DestItem)^) := TRAIIHelper.T5(Pointer(Item)^);
        6: TRAIIHelper.T6(Pointer(DestItem)^) := TRAIIHelper.T6(Pointer(Item)^);
        7: TRAIIHelper.T7(Pointer(DestItem)^) := TRAIIHelper.T7(Pointer(Item)^);
        8: TRAIIHelper.T8(Pointer(DestItem)^) := TRAIIHelper.T8(Pointer(Item)^);
        9: TRAIIHelper.T9(Pointer(DestItem)^) := TRAIIHelper.T9(Pointer(Item)^);
        10: TRAIIHelper.T10(Pointer(DestItem)^) := TRAIIHelper.T10(Pointer(Item)^);
        11: TRAIIHelper.T11(Pointer(DestItem)^) := TRAIIHelper.T11(Pointer(Item)^);
        12: TRAIIHelper.T12(Pointer(DestItem)^) := TRAIIHelper.T12(Pointer(Item)^);
        13: TRAIIHelper.T13(Pointer(DestItem)^) := TRAIIHelper.T13(Pointer(Item)^);
        14: TRAIIHelper.T14(Pointer(DestItem)^) := TRAIIHelper.T14(Pointer(Item)^);
        15: TRAIIHelper.T15(Pointer(DestItem)^) := TRAIIHelper.T15(Pointer(Item)^);
        16: TRAIIHelper.T16(Pointer(DestItem)^) := TRAIIHelper.T16(Pointer(Item)^);
        17: TRAIIHelper.T17(Pointer(DestItem)^) := TRAIIHelper.T17(Pointer(Item)^);
        18: TRAIIHelper.T18(Pointer(DestItem)^) := TRAIIHelper.T18(Pointer(Item)^);
        19: TRAIIHelper.T19(Pointer(DestItem)^) := TRAIIHelper.T19(Pointer(Item)^);
        20: TRAIIHelper.T20(Pointer(DestItem)^) := TRAIIHelper.T20(Pointer(Item)^);
        21: TRAIIHelper.T21(Pointer(DestItem)^) := TRAIIHelper.T21(Pointer(Item)^);
        22: TRAIIHelper.T22(Pointer(DestItem)^) := TRAIIHelper.T22(Pointer(Item)^);
        23: TRAIIHelper.T23(Pointer(DestItem)^) := TRAIIHelper.T23(Pointer(Item)^);
        24: TRAIIHelper.T24(Pointer(DestItem)^) := TRAIIHelper.T24(Pointer(Item)^);
        25: TRAIIHelper.T25(Pointer(DestItem)^) := TRAIIHelper.T25(Pointer(Item)^);
        26: TRAIIHelper.T26(Pointer(DestItem)^) := TRAIIHelper.T26(Pointer(Item)^);
        27: TRAIIHelper.T27(Pointer(DestItem)^) := TRAIIHelper.T27(Pointer(Item)^);
        28: TRAIIHelper.T28(Pointer(DestItem)^) := TRAIIHelper.T28(Pointer(Item)^);
        29: TRAIIHelper.T29(Pointer(DestItem)^) := TRAIIHelper.T29(Pointer(Item)^);
        30: TRAIIHelper.T30(Pointer(DestItem)^) := TRAIIHelper.T30(Pointer(Item)^);
        31: TRAIIHelper.T31(Pointer(DestItem)^) := TRAIIHelper.T31(Pointer(Item)^);
        32: TRAIIHelper.T32(Pointer(DestItem)^) := TRAIIHelper.T32(Pointer(Item)^);
        33: TRAIIHelper.T33(Pointer(DestItem)^) := TRAIIHelper.T33(Pointer(Item)^);
        34: TRAIIHelper.T34(Pointer(DestItem)^) := TRAIIHelper.T34(Pointer(Item)^);
        35: TRAIIHelper.T35(Pointer(DestItem)^) := TRAIIHelper.T35(Pointer(Item)^);
        36: TRAIIHelper.T36(Pointer(DestItem)^) := TRAIIHelper.T36(Pointer(Item)^);
        37: TRAIIHelper.T37(Pointer(DestItem)^) := TRAIIHelper.T37(Pointer(Item)^);
        38: TRAIIHelper.T38(Pointer(DestItem)^) := TRAIIHelper.T38(Pointer(Item)^);
        39: TRAIIHelper.T39(Pointer(DestItem)^) := TRAIIHelper.T39(Pointer(Item)^);
        40: TRAIIHelper.T40(Pointer(DestItem)^) := TRAIIHelper.T40(Pointer(Item)^);
      else
        for i := 1 to SizeOf(T) div SizeOf(NativeUInt) do
        begin
          NativeUInt(Pointer(DestItem)^) := NativeUInt(Pointer(Item)^);
          Inc(NativeInt(Item), SizeOf(NativeUInt));
          Inc(NativeInt(DestItem), SizeOf(NativeUInt));
        end;

        case SizeOf(T) and (SizeOf(NativeUInt) - 1) of
          1: TRAIIHelper.T1(Pointer(DestItem)^) := TRAIIHelper.T1(Pointer(Item)^);
          2: TRAIIHelper.T2(Pointer(DestItem)^) := TRAIIHelper.T2(Pointer(Item)^);
          3: TRAIIHelper.T3(Pointer(DestItem)^) := TRAIIHelper.T3(Pointer(Item)^);
          {$IFDEF LARGEINT}
          4: TRAIIHelper.T4(Pointer(DestItem)^) := TRAIIHelper.T4(Pointer(Item)^);
          5: TRAIIHelper.T5(Pointer(DestItem)^) := TRAIIHelper.T5(Pointer(Item)^);
          6: TRAIIHelper.T6(Pointer(DestItem)^) := TRAIIHelper.T6(Pointer(Item)^);
          7: TRAIIHelper.T7(Pointer(DestItem)^) := TRAIIHelper.T7(Pointer(Item)^);
          {$ENDIF}
        end;

        Dec(NativeInt(DestItem), (SizeOf(T) div SizeOf(NativeUInt)) * SizeOf(NativeUInt));
        Dec(NativeInt(Item), (SizeOf(T) div SizeOf(NativeUInt)) * SizeOf(NativeUInt));
      end;

      Inc(DestItem);
      repeat
        Inc(Item);
        if (Item = TopItem) then
          Break;
      until (TCompare(Compare.Code)(Compare.Data, Item^, Default(T)) <> 0);
    until (Item = TopItem);

  _Self := Self;
  with _Self do
  begin
    R := NativeInt(DestItem) - NativeInt(FItems);
    case SizeOf(T) of
      0, 1: FCount.Native := R;
      2: FCount.Native := R shr 1;
      4: FCount.Native := R shr 2;
      8: FCount.Native := R shr 3;
      16: FCount.Native := R shr 4;
      32: FCount.Native := R shr 5;
      64: FCount.Native := R shr 6;
      128: FCount.Native := R shr 7;
      256: FCount.Native := R shr 8;
    else
      FCount.Native := Round(R * (1 / SizeOf(T)));
    end;
  end;
end;

{ TStack<T> }

constructor TStack<T>.Create;
begin
  inherited Create;
end;

procedure TStack<T>.Push(const Value: T);
var
  Count, Null: NativeInt;
  Item: ^TRAIIHelper.TData16;
begin
  Count := FCount.Native;
  if (Count <> FCapacity.Native) and (not Assigned(FInternalNotify)) then
  begin
    Inc(Count);
    FCount.Native := Count;
    Dec(Count);
    Item := Pointer(@FItems[Count]);

    if (System.IsManagedType(T)) then
    begin
      if (GetTypeKind(T) = tkVariant) then
      begin
        Item.Integers[0] := 0;
      end
      else if (SizeOf(T) <= 16) then
      begin
        Null := 0;
        {$IFDEF SMALLINT}
        if (SizeOf(T) >= SizeOf(Integer) * 1) then
          Item.Integers[0] := Null;
        if (SizeOf(T) >= SizeOf(Integer) * 2) then
          Item.Integers[1] := Null;
        if (SizeOf(T) >= SizeOf(Integer) * 3) then
          Item.Integers[2] := Null;
        if (SizeOf(T) = SizeOf(Integer) * 4) then
          Item.Integers[3] := Null;
        {$ELSE .LARGEINT}
        if (SizeOf(T) >= SizeOf(Int64) * 1) then
          Item.Int64s[0] := Null;
        if (SizeOf(T) = SizeOf(Int64) * 2) then
          Item.Int64s[1] := Null;
        case SizeOf(T) of
          4..7: Item.Integers[0] := Null;
          12..15: Item.Integers[2] := Null;
        end;
        {$ENDIF}
        case SizeOf(T) of
          2, 3: Item.Words[0] := 0;
          6, 7: Item.Words[2] := 0;
          10, 11: Item.Words[4] := 0;
          14, 15: Item.Words[6] := 0;
        end;
        case SizeOf(T) of
          1: Item.Bytes[1 - 1] := 0;
          3: Item.Bytes[3 - 1] := 0;
          5: Item.Bytes[5 - 1] := 0;
          7: Item.Bytes[7 - 1] := 0;
          9: Item.Bytes[9 - 1] := 0;
          11: Item.Bytes[11 - 1] := 0;
          13: Item.Bytes[13 - 1] := 0;
          15: Item.Bytes[15 - 1] := 0;
        end;
      end
      else
      begin
        TRAIIHelper<T>.Init(Pointer(Item));
      end;
    end;

    PItem(Item)^ := Value;
    Exit;
  end
  else
  begin
    Self.InternalPush(Value);
  end;
end;

constructor TStack<T>.Create(const Collection: TEnumerable<T>);
var
  Item: T;
begin
  Create;
  for Item in Collection do
    Push(Item);
end;

procedure TStack<T>.InternalPush(const Value: T);
var
  Count, Null: NativeInt;
  Item: ^TRAIIHelper.TData16;
begin
  Count := FCount.Native;
  repeat
    if (Count <> FCapacity.Native) then
    begin
      FCount.Native := Count + 1;
      Item := Pointer(@FItems[Count]);

      if (System.IsManagedType(T)) then
      begin
        if (GetTypeKind(T) = tkVariant) then
        begin
          Item.Integers[0] := 0;
        end
        else if (SizeOf(T) <= 16) then
        begin
          Null := 0;
          {$IFDEF SMALLINT}
          if (SizeOf(T) >= SizeOf(Integer) * 1) then
            Item.Integers[0] := Null;
          if (SizeOf(T) >= SizeOf(Integer) * 2) then
            Item.Integers[1] := Null;
          if (SizeOf(T) >= SizeOf(Integer) * 3) then
            Item.Integers[2] := Null;
          if (SizeOf(T) = SizeOf(Integer) * 4) then
            Item.Integers[3] := Null;
          {$ELSE .LARGEINT}
          if (SizeOf(T) >= SizeOf(Int64) * 1) then
            Item.Int64s[0] := Null;
          if (SizeOf(T) = SizeOf(Int64) * 2) then
            Item.Int64s[1] := Null;
          case SizeOf(T) of
            4..7: Item.Integers[0] := Null;
            12..15: Item.Integers[2] := Null;
          end;
          {$ENDIF}
          case SizeOf(T) of
            2, 3: Item.Words[0] := 0;
            6, 7: Item.Words[2] := 0;
            10, 11: Item.Words[4] := 0;
            14, 15: Item.Words[6] := 0;
          end;
          case SizeOf(T) of
            1: Item.Bytes[1 - 1] := 0;
            3: Item.Bytes[3 - 1] := 0;
            5: Item.Bytes[5 - 1] := 0;
            7: Item.Bytes[7 - 1] := 0;
            9: Item.Bytes[9 - 1] := 0;
            11: Item.Bytes[11 - 1] := 0;
            13: Item.Bytes[13 - 1] := 0;
            15: Item.Bytes[15 - 1] := 0;
          end;
        end
        else
        begin
          TRAIIHelper<T>.Init(Pointer(Item));
        end;
      end;

      PItem(Item)^ := Value;
      if Assigned(FInternalNotify) then
        FInternalNotify(Self, Value, cnAdded);
      Exit;
    end
    else
    begin
      Self.Grow;
    end;
  until (False);
end;

function TStack<T>.InternalPop(const Action: TCollectionNotification): T;
var
  Count: NativeInt;
  Item: PItem;
  VType: Integer;
begin
  Count := FCount.Native;
  if (Count <> 0) then
  begin
    Dec(Count);
    FCount.Native := Count;
    Item := @FItems[Count];
    Result := Item^;

    if Assigned(FInternalNotify) then
      Self.FInternalNotify(Self, Item^, Action);

    case GetTypeKind(T) of
      {$IFDEF AUTOREFCOUNT}
      tkClass,
        {$ENDIF}
      tkWString, tkLString, tkUString, tkInterface, tkDynArray:
        begin
          if (PNativeInt(Item)^ <> 0) then
            case GetTypeKind(T) of
              {$IFDEF AUTOREFCOUNT}
              tkClass:
                begin
                  TRAIIHelper.RefObjClear(Item);
                end;
              {$ENDIF}
              {$IFDEF MSWINDOWS}
              tkWString:
                begin
                  TRAIIHelper.WStrClear(Item);
                end;
              {$ELSE}
              tkWString,
                {$ENDIF}
              tkLString, tkUString:
                begin
                  TRAIIHelper.ULStrClear(Item);
                end;
              tkInterface:
                begin
                  IInterface(PPointer(Item)^)._Release;
                end;
              tkDynArray:
                begin
                  TRAIIHelper.DynArrayClear(Item, TypeInfo(T));
                end;
            end;
        end;
      {$IFDEF WEAKINSTREF}
      tkMethod:
        begin
          if (PMethod(Item).Data <> nil) then
            TRAIIHelper.WeakMethodClear(@PMethod(Item).Data);
        end;
      {$ENDIF}
      tkVariant:
        begin
          VType := PVarData(Item).VType;
          if (VType and TRAIIHelper.varDeepData <> 0) then
            case VType of
              varBoolean, varUnknown + 1..varUInt64: ;
            else
              System.VarClear(PVariant(Item)^);
            end;
        end;
    else
      TRAIIHelper<T>.Clear(Item);
    end;

    Exit;
  end
  else
  begin
    raise Self.EmptyException;
  end;
end;

function TStack<T>.Pop: T;
var
  Count: NativeInt;
  Item: PItem;
  VType: Integer;
begin
  Count := FCount.Native;
  if (Count <> 0) and (not Assigned(FInternalNotify)) then
  begin
    Dec(Count);
    FCount.Native := Count;
    Item := @FItems[Count];
    Result := Item^;

    case GetTypeKind(T) of
      {$IFDEF AUTOREFCOUNT}
      tkClass,
        {$ENDIF}
      tkWString, tkLString, tkUString, tkInterface, tkDynArray:
        begin
          if (PNativeInt(Item)^ <> 0) then
            case GetTypeKind(T) of
              {$IFDEF AUTOREFCOUNT}
              tkClass:
                begin
                  TRAIIHelper.RefObjClear(Item);
                end;
              {$ENDIF}
              {$IFDEF MSWINDOWS}
              tkWString:
                begin
                  TRAIIHelper.WStrClear(Item);
                end;
              {$ELSE}
              tkWString,
                {$ENDIF}
              tkLString, tkUString:
                begin
                  TRAIIHelper.ULStrClear(Item);
                end;
              tkInterface:
                begin
                  IInterface(PPointer(Item)^)._Release;
                end;
              tkDynArray:
                begin
                  TRAIIHelper.DynArrayClear(Item, TypeInfo(T));
                end;
            end;
        end;
      {$IFDEF WEAKINSTREF}
      tkMethod:
        begin
          if (PMethod(Item).Data <> nil) then
            TRAIIHelper.WeakMethodClear(@PMethod(Item).Data);
        end;
      {$ENDIF}
      tkVariant:
        begin
          VType := PVarData(Item).VType;
          if (VType and TRAIIHelper.varDeepData <> 0) then
            case VType of
              varBoolean, varUnknown + 1..varUInt64: ;
            else
              System.VarClear(PVariant(Item)^);
            end;
        end;
    else
      TRAIIHelper<T>.Clear(Item);
    end;

    Exit;
  end
  else
  begin
    Result := Self.InternalPop(cnRemoved);
  end;
end;

function TStack<T>.Extract: T;
var
  Count: NativeInt;
  Item: PItem;
  VType: Integer;
begin
  Count := FCount.Native;
  if (Count <> 0) and (not Assigned(FInternalNotify)) then
  begin
    Dec(Count);
    FCount.Native := Count;
    Item := @FItems[Count];
    Result := Item^;

    case GetTypeKind(T) of
      {$IFDEF AUTOREFCOUNT}
      tkClass,
        {$ENDIF}
      tkWString, tkLString, tkUString, tkInterface, tkDynArray:
        begin
          if (PNativeInt(Item)^ <> 0) then
            case GetTypeKind(T) of
              {$IFDEF AUTOREFCOUNT}
              tkClass:
                begin
                  TRAIIHelper.RefObjClear(Item);
                end;
              {$ENDIF}
              {$IFDEF MSWINDOWS}
              tkWString:
                begin
                  TRAIIHelper.WStrClear(Item);
                end;
              {$ELSE}
              tkWString,
                {$ENDIF}
              tkLString, tkUString:
                begin
                  TRAIIHelper.ULStrClear(Item);
                end;
              tkInterface:
                begin
                  IInterface(PPointer(Item)^)._Release;
                end;
              tkDynArray:
                begin
                  TRAIIHelper.DynArrayClear(Item, TypeInfo(T));
                end;
            end;
        end;
      {$IFDEF WEAKINSTREF}
      tkMethod:
        begin
          if (PMethod(Item).Data <> nil) then
            TRAIIHelper.WeakMethodClear(@PMethod(Item).Data);
        end;
      {$ENDIF}
      tkVariant:
        begin
          VType := PVarData(Item).VType;
          if (VType and TRAIIHelper.varDeepData <> 0) then
            case VType of
              varBoolean, varUnknown + 1..varUInt64: ;
            else
              System.VarClear(PVariant(Item)^);
            end;
        end;
    else
      TRAIIHelper<T>.Clear(Item);
    end;

    Exit;
  end
  else
  begin
    Result := Self.InternalPop(cnExtracted);
  end;
end;

function TStack<T>.Peek: T;
var
  Count: NativeInt;
begin
  Count := FCount.Native;
  if (Count <> 0) then
  begin
    Result := FItems[Count - 1];
    Exit;
  end
  else
  begin
    raise Self.EmptyException;
  end;
end;

{ TQueue<T> }

constructor TQueue<T>.Create;
begin
  inherited Create;
end;

procedure TQueue<T>.Enqueue(const Value: T);
var
  Count, Null: NativeInt;
  Item: ^TRAIIHelper.TData16;
begin
  Count := FCount.Native;
  if (Count <> FCapacity.Native) and (not Assigned(FInternalNotify)) then
  begin
    FCount.Native := Count + 1;
    Count := FHead;
    repeat
      if (Count <> FCapacity.Native) then
      begin
        Inc(Count);
        FHead := Count;
        Dec(Count);
        Item := Pointer(@FItems[Count]);

        if (System.IsManagedType(T)) then
        begin
          if (GetTypeKind(T) = tkVariant) then
          begin
            Item.Integers[0] := 0;
          end
          else if (SizeOf(T) <= 16) then
          begin
            Null := 0;
            {$IFDEF SMALLINT}
            if (SizeOf(T) >= SizeOf(Integer) * 1) then
              Item.Integers[0] := Null;
            if (SizeOf(T) >= SizeOf(Integer) * 2) then
              Item.Integers[1] := Null;
            if (SizeOf(T) >= SizeOf(Integer) * 3) then
              Item.Integers[2] := Null;
            if (SizeOf(T) = SizeOf(Integer) * 4) then
              Item.Integers[3] := Null;
            {$ELSE .LARGEINT}
            if (SizeOf(T) >= SizeOf(Int64) * 1) then
              Item.Int64s[0] := Null;
            if (SizeOf(T) = SizeOf(Int64) * 2) then
              Item.Int64s[1] := Null;
            case SizeOf(T) of
              4..7: Item.Integers[0] := Null;
              12..15: Item.Integers[2] := Null;
            end;
            {$ENDIF}
            case SizeOf(T) of
              2, 3: Item.Words[0] := 0;
              6, 7: Item.Words[2] := 0;
              10, 11: Item.Words[4] := 0;
              14, 15: Item.Words[6] := 0;
            end;
            case SizeOf(T) of
              1: Item.Bytes[1 - 1] := 0;
              3: Item.Bytes[3 - 1] := 0;
              5: Item.Bytes[5 - 1] := 0;
              7: Item.Bytes[7 - 1] := 0;
              9: Item.Bytes[9 - 1] := 0;
              11: Item.Bytes[11 - 1] := 0;
              13: Item.Bytes[13 - 1] := 0;
              15: Item.Bytes[15 - 1] := 0;
            end;
          end
          else
          begin
            TRAIIHelper<T>.Init(Pointer(Item));
          end;
        end;

        PItem(Item)^ := Value;
        Exit;
      end
      else
      begin
        Count := 0;
      end;
    until (False);
  end
  else
  begin
    Self.InternalEnqueue(Value);
  end;
end;

constructor TQueue<T>.Create(const Collection: TEnumerable<T>);
var
  Item: T;
begin
  Create;
  for Item in Collection do
    Enqueue(Item);
end;

procedure TQueue<T>.InternalEnqueue(const Value: T);
var
  Count, Null: NativeInt;
  Item: ^TRAIIHelper.TData16;
begin
  Count := FCount.Native;
  repeat
    if (Count <> FCapacity.Native) then
    begin
      FCount.Native := Count + 1;
      Count := FHead;
      repeat
        if (Count <> FCapacity.Native) then
        begin
          Inc(Count);
          FHead := Count;
          Dec(Count);
          Item := Pointer(@FItems[Count]);

          if (System.IsManagedType(T)) then
          begin
            if (GetTypeKind(T) = tkVariant) then
            begin
              Item.Integers[0] := 0;
            end
            else if (SizeOf(T) <= 16) then
            begin
              Null := 0;
              {$IFDEF SMALLINT}
              if (SizeOf(T) >= SizeOf(Integer) * 1) then
                Item.Integers[0] := Null;
              if (SizeOf(T) >= SizeOf(Integer) * 2) then
                Item.Integers[1] := Null;
              if (SizeOf(T) >= SizeOf(Integer) * 3) then
                Item.Integers[2] := Null;
              if (SizeOf(T) = SizeOf(Integer) * 4) then
                Item.Integers[3] := Null;
              {$ELSE .LARGEINT}
              if (SizeOf(T) >= SizeOf(Int64) * 1) then
                Item.Int64s[0] := Null;
              if (SizeOf(T) = SizeOf(Int64) * 2) then
                Item.Int64s[1] := Null;
              case SizeOf(T) of
                4..7: Item.Integers[0] := Null;
                12..15: Item.Integers[2] := Null;
              end;
              {$ENDIF}
              case SizeOf(T) of
                2, 3: Item.Words[0] := 0;
                6, 7: Item.Words[2] := 0;
                10, 11: Item.Words[4] := 0;
                14, 15: Item.Words[6] := 0;
              end;
              case SizeOf(T) of
                1: Item.Bytes[1 - 1] := 0;
                3: Item.Bytes[3 - 1] := 0;
                5: Item.Bytes[5 - 1] := 0;
                7: Item.Bytes[7 - 1] := 0;
                9: Item.Bytes[9 - 1] := 0;
                11: Item.Bytes[11 - 1] := 0;
                13: Item.Bytes[13 - 1] := 0;
                15: Item.Bytes[15 - 1] := 0;
              end;
            end
            else
            begin
              TRAIIHelper<T>.Init(Pointer(Item));
            end;
          end;

          PItem(Item)^ := Value;
          if Assigned(FInternalNotify) then
            FInternalNotify(Self, Value, cnAdded);
          Exit;
        end
        else
        begin
          Count := 0;
        end;
      until (False);
    end
    else
    begin
      Self.Grow;
    end;
  until (False);
end;

function TQueue<T>.InternalDequeue(const Action: TCollectionNotification): T;
var
  Count: NativeInt;
  Item: PItem;
  VType: Integer;
begin
  Count := FCount.Native;
  if (Count <> 0) then
  begin
    FCount.Native := Count - 1;
    Count := FTail;
    Item := @FItems[Count];
    Inc(Count);
    repeat
      if (Count <> FCapacity.Native) then
      begin
        FTail := Count;
        Result := Item^;

        Self.FInternalNotify(Self, Item^, Action);

        case GetTypeKind(T) of
          {$IFDEF AUTOREFCOUNT}
          tkClass,
            {$ENDIF}
          tkWString, tkLString, tkUString, tkInterface, tkDynArray:
            begin
              if (PNativeInt(Item)^ <> 0) then
                case GetTypeKind(T) of
                  {$IFDEF AUTOREFCOUNT}
                  tkClass:
                    begin
                      TRAIIHelper.RefObjClear(Item);
                    end;
                  {$ENDIF}
                  {$IFDEF MSWINDOWS}
                  tkWString:
                    begin
                      TRAIIHelper.WStrClear(Item);
                    end;
                  {$ELSE}
                  tkWString,
                    {$ENDIF}
                  tkLString, tkUString:
                    begin
                      TRAIIHelper.ULStrClear(Item);
                    end;
                  tkInterface:
                    begin
                      IInterface(PPointer(Item)^)._Release;
                    end;
                  tkDynArray:
                    begin
                      TRAIIHelper.DynArrayClear(Item, TypeInfo(T));
                    end;
                end;
            end;
          {$IFDEF WEAKINSTREF}
          tkMethod:
            begin
              if (PMethod(Item).Data <> nil) then
                TRAIIHelper.WeakMethodClear(@PMethod(Item).Data);
            end;
          {$ENDIF}
          tkVariant:
            begin
              VType := PVarData(Item).VType;
              if (VType and TRAIIHelper.varDeepData <> 0) then
                case VType of
                  varBoolean, varUnknown + 1..varUInt64: ;
                else
                  System.VarClear(PVariant(Item)^);
                end;
            end;
        else
          TRAIIHelper<T>.Clear(Item);
        end;

        Exit;
      end
      else
      begin
        Count := 0;
      end;
    until (False);
  end
  else
  begin
    raise Self.EmptyException;
  end;
end;

function TQueue<T>.Dequeue: T;
var
  Count: NativeInt;
  Item: PItem;
  VType: Integer;
begin
  Count := FCount.Native;
  if (Count <> 0) and (not Assigned(FInternalNotify)) then
  begin
    FCount.Native := Count - 1;
    Count := FTail;
    Item := @FItems[Count];
    Inc(Count);
    repeat
      if (Count <> FCapacity.Native) then
      begin
        FTail := Count;
        Result := Item^;

        case GetTypeKind(T) of
          {$IFDEF AUTOREFCOUNT}
          tkClass,
            {$ENDIF}
          tkWString, tkLString, tkUString, tkInterface, tkDynArray:
            begin
              if (PNativeInt(Item)^ <> 0) then
                case GetTypeKind(T) of
                  {$IFDEF AUTOREFCOUNT}
                  tkClass:
                    begin
                      TRAIIHelper.RefObjClear(Item);
                    end;
                  {$ENDIF}
                  {$IFDEF MSWINDOWS}
                  tkWString:
                    begin
                      TRAIIHelper.WStrClear(Item);
                    end;
                  {$ELSE}
                  tkWString,
                    {$ENDIF}
                  tkLString, tkUString:
                    begin
                      TRAIIHelper.ULStrClear(Item);
                    end;
                  tkInterface:
                    begin
                      IInterface(PPointer(Item)^)._Release;
                    end;
                  tkDynArray:
                    begin
                      TRAIIHelper.DynArrayClear(Item, TypeInfo(T));
                    end;
                end;
            end;
          {$IFDEF WEAKINSTREF}
          tkMethod:
            begin
              if (PMethod(Item).Data <> nil) then
                TRAIIHelper.WeakMethodClear(@PMethod(Item).Data);
            end;
          {$ENDIF}
          tkVariant:
            begin
              VType := PVarData(Item).VType;
              if (VType and TRAIIHelper.varDeepData <> 0) then
                case VType of
                  varBoolean, varUnknown + 1..varUInt64: ;
                else
                  System.VarClear(PVariant(Item)^);
                end;
            end;
        else
          TRAIIHelper<T>.Clear(Item);
        end;

        Exit;
      end
      else
      begin
        Count := 0;
      end;
    until (False);
  end
  else
  begin
    Result := Self.InternalDequeue(cnRemoved);
  end;
end;

function TQueue<T>.Extract: T;
var
  Count: NativeInt;
  Item: PItem;
  VType: Integer;
begin
  Count := FCount.Native;
  if (Count <> 0) and (not Assigned(FInternalNotify)) then
  begin
    FCount.Native := Count - 1;
    Count := FTail;
    Item := @FItems[Count];
    Inc(Count);
    repeat
      if (Count <> FCapacity.Native) then
      begin
        FTail := Count;
        Result := Item^;

        case GetTypeKind(T) of
          {$IFDEF AUTOREFCOUNT}
          tkClass,
            {$ENDIF}
          tkWString, tkLString, tkUString, tkInterface, tkDynArray:
            begin
              if (PNativeInt(Item)^ <> 0) then
                case GetTypeKind(T) of
                  {$IFDEF AUTOREFCOUNT}
                  tkClass:
                    begin
                      TRAIIHelper.RefObjClear(Item);
                    end;
                  {$ENDIF}
                  {$IFDEF MSWINDOWS}
                  tkWString:
                    begin
                      TRAIIHelper.WStrClear(Item);
                    end;
                  {$ELSE}
                  tkWString,
                    {$ENDIF}
                  tkLString, tkUString:
                    begin
                      TRAIIHelper.ULStrClear(Item);
                    end;
                  tkInterface:
                    begin
                      IInterface(PPointer(Item)^)._Release;
                    end;
                  tkDynArray:
                    begin
                      TRAIIHelper.DynArrayClear(Item, TypeInfo(T));
                    end;
                end;
            end;
          {$IFDEF WEAKINSTREF}
          tkMethod:
            begin
              if (PMethod(Item).Data <> nil) then
                TRAIIHelper.WeakMethodClear(@PMethod(Item).Data);
            end;
          {$ENDIF}
          tkVariant:
            begin
              VType := PVarData(Item).VType;
              if (VType and TRAIIHelper.varDeepData <> 0) then
                case VType of
                  varBoolean, varUnknown + 1..varUInt64: ;
                else
                  System.VarClear(PVariant(Item)^);
                end;
            end;
        else
          TRAIIHelper<T>.Clear(Item);
        end;

        Exit;
      end
      else
      begin
        Count := 0;
      end;
    until (False);
  end
  else
  begin
    Result := Self.InternalDequeue(cnExtracted);
  end;
end;

function TQueue<T>.Peek: T;
begin
  if (FCount.Native <> 0) then
  begin
    Result := FItems[FTail];
    Exit;
  end
  else
  begin
    raise Self.EmptyException;
  end;
end;

{ TThreadList<T> }

procedure TThreadList<T>.UnlockList;
begin
  TMonitor.Exit(FLock);
end;

procedure TThreadList<T>.Add(const Item: T);
begin
  LockList;
  try
    if (Duplicates = dupAccept) or
      (FList.IndexOf(Item) = -1) then
      FList.Add(Item)
    else if Duplicates = dupError then
      raise EListError.CreateFmt(SDuplicateItem, [FList.ItemValue(Item)]);
  finally
    UnlockList;
  end;
end;

procedure TThreadList<T>.Clear;
begin
  LockList;
  try
    FList.Clear;
  finally
    UnlockList;
  end;
end;

constructor TThreadList<T>.Create;
begin
  inherited Create;
  FLock := TObject.Create;
  FList := TList<T>.Create;
  FDuplicates := dupIgnore;
end;

destructor TThreadList<T>.Destroy;
begin
  LockList; // Make sure nobody else is inside the list.
  try
    FList.Free;
    inherited Destroy;
  finally
    UnlockList;
    FLock.Free;
  end;
end;

function TThreadList<T>.LockList: TList<T>;
begin
  TMonitor.Enter(FLock);
  Result := FList;
end;

procedure TThreadList<T>.Remove(const Item: T);
begin
  RemoveItem(Item, TDirection.FromBeginning);
end;

procedure TThreadList<T>.RemoveItem(const Item: T; Direction: TDirection);
begin
  LockList;
  try
    FList.RemoveItem(Item, Direction);
  finally
    UnlockList;
  end;
end;

{ TThreadedQueue<T> }

constructor TThreadedQueue<T>.Create(AQueueDepth: Integer = 10; PushTimeout: LongWord = INFINITE; PopTimeout: LongWord
  = INFINITE);
begin
  inherited Create;
  SetLength(FQueue, AQueueDepth);
  FQueueLock := TObject.Create;
  FQueueNotEmpty := TObject.Create;
  FQueueNotFull := TObject.Create;
  FPushTimeout := PushTimeout;
  FPopTimeout := PopTimeout;
end;

destructor TThreadedQueue<T>.Destroy;
begin
  DoShutDown;
  FQueueNotFull.Free;
  FQueueNotEmpty.Free;
  FQueueLock.Free;
  inherited;
end;

procedure TThreadedQueue<T>.Grow(ADelta: Integer);
begin
  TMonitor.Enter(FQueueLock);
  try
    SetLength(FQueue, Length(FQueue) + ADelta);
  finally
    TMonitor.Exit(FQueueLock);
  end;
  TMonitor.PulseAll(FQueueNotFull);
end;

function TThreadedQueue<T>.PopItem: T;
var
  LQueueSize: Integer;
begin
  PopItem(LQueueSize, Result);
end;

function TThreadedQueue<T>.PopItem(var AQueueSize: Integer; var AItem: T): TWaitResult;
begin
  AItem := Default(T);
  TMonitor.Enter(FQueueLock);
  try
    Result := wrSignaled;
    while (Result = wrSignaled) and (FQueueSize = 0) and not FShutDown do
      if not TMonitor.Wait(FQueueNotEmpty, FQueueLock, FPopTimeout) then
        Result := wrTimeout;

    if (FShutDown and (FQueueSize = 0)) or (Result <> wrSignaled) then
      Exit;

    AItem := FQueue[FQueueOffset];

    FQueue[FQueueOffset] := Default(T);

    Dec(FQueueSize);
    Inc(FQueueOffset);
    Inc(FTotalItemsPopped);

    if FQueueOffset = Length(FQueue) then
      FQueueOffset := 0;

  finally
    AQueueSize := FQueueSize;
    TMonitor.Exit(FQueueLock);
  end;

  TMonitor.Pulse(FQueueNotFull);
end;

function TThreadedQueue<T>.PopItem(var AItem: T): TWaitResult;
var
  LQueueSize: Integer;
begin
  Result := PopItem(LQueueSize, AItem);
end;

function TThreadedQueue<T>.PopItem(var AQueueSize: Integer): T;
begin
  PopItem(AQueueSize, Result);
end;

function TThreadedQueue<T>.PushItem(const AItem: T): TWaitResult;
var
  LQueueSize: Integer;
begin
  Result := PushItem(AItem, LQueueSize);
end;

function TThreadedQueue<T>.PushItem(const AItem: T; var AQueueSize: Integer): TWaitResult;
begin
  TMonitor.Enter(FQueueLock);
  try
    Result := wrSignaled;
    while (Result = wrSignaled) and (FQueueSize = Length(FQueue)) and not FShutDown do
      if not TMonitor.Wait(FQueueNotFull, FQueueLock, FPushTimeout) then
        Result := wrTimeout;

    if FShutDown or (Result <> wrSignaled) then
      Exit;

    FQueue[(FQueueOffset + FQueueSize) mod Length(FQueue)] := AItem;
    Inc(FQueueSize);
    Inc(FTotalItemsPushed);

  finally
    AQueueSize := FQueueSize;
    TMonitor.Exit(FQueueLock);
  end;

  TMonitor.Pulse(FQueueNotEmpty);
end;

procedure TThreadedQueue<T>.DoShutDown;
begin
  TMonitor.Enter(FQueueLock);
  try
    FShutDown := True;
  finally
    TMonitor.Exit(FQueueLock);
  end;
  TMonitor.PulseAll(FQueueNotFull);
  TMonitor.PulseAll(FQueueNotEmpty);
end;

{ TObjectList<T> }

constructor TObjectList<T>.Create(AOwnsObjects: Boolean);
begin
  // AM: Must either call the setter or call SetNotifyMethods directly otherwise
  // pointers won't be set correctly
  OwnsObjects := AOwnsObjects;
  inherited Create;
end;

constructor TObjectList<T>.Create(const AComparer: IComparer<T>; AOwnsObjects: Boolean);
begin
  OwnsObjects := AOwnsObjects;
  inherited Create(AComparer);
end;

constructor TObjectList<T>.Create(const Collection: TEnumerable<T>; AOwnsObjects: Boolean);
begin
  OwnsObjects := AOwnsObjects;
  inherited Create(Collection);
end;

procedure TObjectList<T>.SetOwnsObjects(const Value: Boolean);
begin
  if (FOwnsObjects <> Value) then
  begin
    FOwnsObjects := Value;
    SetNotifyMethods;
  end;
end;

procedure TObjectList<T>.DisposeNotifyCaller(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
begin
  Self.Notify(Item, Action);
  if (Action = cnRemoved) then
    Item. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TObjectList<T>.DisposeNotifyEvent(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
begin
  Self.FOnNotify(Sender, Item, Action);
  if (Action = cnRemoved) then
    Item. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TObjectList<T>.DisposeOnly(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
begin
  if (Action = cnRemoved) then
    Item. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TObjectList<T>.SetNotifyMethods;
var
  VMTNotify: procedure(const Item: T; Action: TCollectionNotification) of object;
begin
  if (not FOwnsObjects) then
  begin
    inherited;
    Exit;
  end;

  TMethod(FInternalNotify).Data := Pointer(Self);
  VMTNotify := Self.Notify;
  if (TMethod(VMTNotify).Code <> @TCustomList<T>.Notify) then
  begin
    // AM: Fix for descendant classes with custom notify method.
    TMethod(FInternalNotify).Code := @TObjectList<T>.DisposeNotifyCaller;
  end
  else if (Assigned(Self.FOnNotify)) then
  begin
    TMethod(FInternalNotify).Code := @TObjectList<T>.DisposeNotifyEvent;
  end
  else
  begin
    TMethod(FInternalNotify).Code := @TObjectList<T>.DisposeOnly;
  end;
end;

{ TObjectStack<T> }

constructor TObjectStack<T>.Create(AOwnsObjects: Boolean);
begin
  // AM: Must either call the setter or call SetNotifyMethods directly otherwise
  // pointers won't be set correctly
  OwnsObjects := AOwnsObjects;
  inherited Create;
end;

constructor TObjectStack<T>.Create(const Collection: TEnumerable<T>; AOwnsObjects: Boolean);
begin
  OwnsObjects := AOwnsObjects;
  inherited Create(Collection);
end;

procedure TObjectStack<T>.SetOwnsObjects(const Value: Boolean);
begin
  if (FOwnsObjects <> Value) then
  begin
    FOwnsObjects := Value;
    SetNotifyMethods;
  end;
end;

procedure TObjectStack<T>.DisposeNotifyCaller(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
begin
  Self.Notify(Item, Action);
  if (Action = cnRemoved) then
    Item. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TObjectStack<T>.DisposeNotifyEvent(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
begin
  Self.FOnNotify(Sender, Item, Action);
  if (Action = cnRemoved) then
    Item. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TObjectStack<T>.DisposeOnly(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
begin
  if (Action = cnRemoved) then
    Item. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TObjectStack<T>.SetNotifyMethods;
var
  VMTNotify: procedure(const Item: T; Action: TCollectionNotification) of object;
begin
  if (not FOwnsObjects) then
  begin
    inherited;
    Exit;
  end;

  TMethod(FInternalNotify).Data := Pointer(Self);
  VMTNotify := Self.Notify;
  if (TMethod(VMTNotify).Code <> @TCustomList<T>.Notify) then
  begin
    // AM: Fix for descendant classes with custom notify method.
    TMethod(FInternalNotify).Code := @TObjectStack<T>.DisposeNotifyCaller;
  end
  else if (Assigned(Self.FOnNotify)) then
  begin
    TMethod(FInternalNotify).Code := @TObjectStack<T>.DisposeNotifyEvent;
  end
  else
  begin
    TMethod(FInternalNotify).Code := @TObjectStack<T>.DisposeOnly;
  end;
end;

{ TObjectQueue<T> }

constructor TObjectQueue<T>.Create(AOwnsObjects: Boolean);
begin
  // AM: Must either call the setter or call SetNotifyMethods directly otherwise
  // pointers won't be set correctly
  OwnsObjects := AOwnsObjects;
  inherited Create;
end;

constructor TObjectQueue<T>.Create(const Collection: TEnumerable<T>; AOwnsObjects: Boolean);
begin
  OwnsObjects := AOwnsObjects;
  inherited Create(Collection);
end;

procedure TObjectQueue<T>.Dequeue;
begin
  inherited Dequeue;
end;

procedure TObjectQueue<T>.SetOwnsObjects(const Value: Boolean);
begin
  if (FOwnsObjects <> Value) then
  begin
    FOwnsObjects := Value;
    SetNotifyMethods;
  end;
end;

procedure TObjectQueue<T>.DisposeNotifyCaller(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
begin
  Self.Notify(Item, Action);
  if (Action = cnRemoved) then
    Item. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TObjectQueue<T>.DisposeNotifyEvent(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
begin
  Self.FOnNotify(Sender, Item, Action);
  if (Action = cnRemoved) then
    Item. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TObjectQueue<T>.DisposeOnly(Sender: TObject; const Item: TObject; Action: TCollectionNotification);
begin
  if (Action = cnRemoved) then
    Item. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TObjectQueue<T>.SetNotifyMethods;
var
  VMTNotify: procedure(const Item: T; Action: TCollectionNotification) of object;
begin
  if (not FOwnsObjects) then
  begin
    inherited;
    Exit;
  end;

  TMethod(FInternalNotify).Data := Pointer(Self);
  VMTNotify := Self.Notify;
  if (TMethod(VMTNotify).Code <> @TCustomList<T>.Notify) then
  begin
    // AM: Fix for descendant classes with custom notify method.
    TMethod(FInternalNotify).Code := @TObjectQueue<T>.DisposeNotifyCaller;
  end
  else if (Assigned(Self.FOnNotify)) then
  begin
    TMethod(FInternalNotify).Code := @TObjectQueue<T>.DisposeNotifyEvent;
  end
  else
  begin
    TMethod(FInternalNotify).Code := @TObjectQueue<T>.DisposeOnly;
  end;
end;

{ TObjectDictionary<TKey,TValue> }

constructor TObjectDictionary<TKey, TValue>.Create(Ownerships: TDictionaryOwnerships;
  ACapacity: Integer = 0);
begin
  Create(Ownerships, ACapacity, nil);
end;

constructor TObjectDictionary<TKey, TValue>.Create(Ownerships: TDictionaryOwnerships;
  const AComparer: IEqualityComparer<TKey>);
begin
  Create(Ownerships, 0, AComparer);
end;

constructor TObjectDictionary<TKey, TValue>.Create(Ownerships: TDictionaryOwnerships;
  ACapacity: Integer; const AComparer: IEqualityComparer<TKey>);
begin
  FOwnerships := Ownerships;
  // AM: Although creating a TObjectDictionary without any ownership is pointless
  // (because a TDictionary<TKey, TValue> would do the same), it shouldn't be forbidden
  //if (Ownerships = []) then
  //  raise EInvalidCast.CreateRes(Pointer(@SInvalidCast));

  if (doOwnsKeys in Ownerships) then
  begin
    if (TypeInfo(TKey) = nil) or (PTypeInfo(TypeInfo(TKey))^.Kind <> tkClass) then
      raise EInvalidCast.CreateRes(Pointer(@SInvalidCast));
  end;

  if (doOwnsValues in Ownerships) then
  begin
    if (TypeInfo(TValue) = nil) or (PTypeInfo(TypeInfo(TValue))^.Kind <> tkClass) then
      raise EInvalidCast.CreateRes(Pointer(@SInvalidCast));
  end;

  inherited Create(ACapacity, AComparer);
end;

procedure TObjectDictionary<TKey, TValue>.DisposeKeyEvent(Sender: TObject;
  const Key: TObject; Action: TCollectionNotification);
begin
  TOnKeyNotify(TMethod(FOnKeyNotify).Code)(TMethod(FOnKeyNotify).Data, Self, Key, Action);
  if (Action = cnRemoved) then
    Key. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TObjectDictionary<TKey, TValue>.DisposeKeyOnly(Sender: TObject;
  const Key: TObject; Action: TCollectionNotification);
begin
  if (Action = cnRemoved) then
    Key. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TObjectDictionary<TKey, TValue>.DisposeValueEvent(Sender: TObject;
  const Value: TObject; Action: TCollectionNotification);
begin
  TOnValueNotify(TMethod(FOnValueNotify).Code)(TMethod(FOnValueNotify).Data, Self, Value, Action);
  if (Action = cnRemoved) then
    Value. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TObjectDictionary<TKey, TValue>.DisposeKeyNotifyCaller(Sender: TObject;
  const Key: TKey; Action: TCollectionNotification);
begin
  Self.KeyNotify(Key, Action);
  // Key is guaranteed to be a class when FInternalKeyNotify = DisposeKeyNotifyCaller (See SetNotifyMethods)
  if (Action = cnRemoved) then
    TObject(Pointer(@Key)^). {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TObjectDictionary<TKey, TValue>.DisposeValueNotifyCaller(Sender: TObject;
  const Value: TValue; Action: TCollectionNotification);
begin
  Self.ValueNotify(Value, Action);
  // Value is guaranteed to be a class when FInternalKeyNotify = DisposeKeyNotifyCaller (See SetNotifyMethods)
  if (Action = cnRemoved) then
    TObject(Pointer(@Value)^). {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TObjectDictionary<TKey, TValue>.DisposeValueOnly(Sender: TObject;
  const Value: TObject; Action: TCollectionNotification);
begin
  if (Action = cnRemoved) then
    Value. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TObjectDictionary<TKey, TValue>.DisposeItemNotifyKeyCaller(const Item: TItem;
  Action: TCollectionNotification);
begin
  Self.KeyNotify(Item.Key, Action);
end;

procedure TObjectDictionary<TKey, TValue>.DisposeItemNotifyKeyEvent(const Item: TItem;
  Action: TCollectionNotification);
begin
  FOnKeyNotify(Self, Item.Key, Action);
  if (Action = cnRemoved) then
    TObject(Pointer(@Item.Key)^).Free;
end;

procedure TObjectDictionary<TKey, TValue>.DisposeItemNotifyKeyOnly(const Item: TItem;
  Action: TCollectionNotification);
begin
  if (Action = cnRemoved) then
    TObject(Pointer(@Item.Key)^).Free;
end;

procedure TObjectDictionary<TKey, TValue>.DisposeItemNotifyValueCaller(const Item: TItem;
  Action: TCollectionNotification);
begin
  Self.ValueNotify(Item.Value, Action);
end;

procedure TObjectDictionary<TKey, TValue>.DisposeItemNotifyValueEvent(const Item: TItem;
  Action: TCollectionNotification);
begin
  FOnValueNotify(Self, Item.Value, Action);
  if (Action = cnRemoved) then
    TObject(Pointer(@Item.Value)^).Free;
end;

procedure TObjectDictionary<TKey, TValue>.DisposeItemNotifyValueOnly(const Item: TItem;
  Action: TCollectionNotification);
begin
  if (Action = cnRemoved) then
    TObject(Pointer(@Item.Value)^).Free;
end;

procedure TObjectDictionary<TKey, TValue>.SetNotifyMethods;
var
  VMTKeyNotify: procedure(const Key: TKey; Action: TCollectionNotification) of object;
  VMTValueNotify: procedure(const Value: TValue; Action: TCollectionNotification) of object;
begin
  // FInternalKeyNotify
  TMethod(FInternalKeyNotify).Data := Pointer(Self);
  VMTKeyNotify := Self.KeyNotify;
  if (TMethod(VMTKeyNotify).Code <> @TCustomDictionary<TKey, TValue>.KeyNotify) then
  begin
    if (doOwnsKeys in FOwnerships) then
      // AM: Fix: when doOwnsKeys, need to free keys in descendant classes with overriden notify method
      TMethod(FInternalKeyNotify).Code := @TObjectDictionary<TKey, TValue>.DisposeKeyNotifyCaller
    else
      TMethod(FInternalKeyNotify).Code := @TCustomDictionary<TKey, TValue>.KeyNotifyCaller;
  end
  else if (doOwnsKeys in FOwnerships) then
  begin
    if (Assigned(Self.FOnKeyNotify)) then
    begin
      TMethod(FInternalKeyNotify).Code := @TObjectDictionary<TKey, TValue>.DisposeValueEvent;
    end
    else
    begin
      TMethod(FInternalKeyNotify).Code := @TObjectDictionary<TKey, TValue>.DisposeValueOnly;
    end;
  end
  else
  begin
    TMethod(FInternalKeyNotify) := TMethod(Self.FOnKeyNotify);
  end;

  // FInternalValueNotify
  TMethod(FInternalValueNotify).Data := Pointer(Self);
  VMTValueNotify := Self.ValueNotify;
  if (TMethod(VMTValueNotify).Code <> @TCustomDictionary<TKey, TValue>.ValueNotify) then
  begin
    if (doOwnsValues in FOwnerships) then
      // AM: Fix: when doOwnsValues, need to free keys in descendant classes with overriden notify method
      TMethod(FInternalValueNotify).Code := @TObjectDictionary<TKey, TValue>.DisposeValueNotifyCaller
    else
      TMethod(FInternalValueNotify).Code := @TCustomDictionary<TKey, TValue>.ValueNotifyCaller;
  end
  else if (doOwnsValues in FOwnerships) then
  begin
    if (Assigned(Self.FOnValueNotify)) then
    begin
      TMethod(FInternalValueNotify).Code := @TObjectDictionary<TKey, TValue>.DisposeValueEvent;
    end
    else
    begin
      TMethod(FInternalValueNotify).Code := @TObjectDictionary<TKey, TValue>.DisposeValueOnly;
    end;
  end
  else
  begin
    TMethod(FInternalValueNotify) := TMethod(Self.FOnValueNotify);
  end;

  // FInternalItemNotify
  TMethod(FInternalItemNotify).Data := Self;
  if (TMethod(VMTKeyNotify).Code <> @TCustomDictionary<TKey, TValue>.KeyNotify) and
    (TMethod(VMTValueNotify).Code <> @TCustomDictionary<TKey, TValue>.ValueNotify) then
      // Both KeyNotify() and ValueNotify() are overriden
  begin
    // AM: Fix: when doOwnsKeys or doOwnsValues in descendant classes with overriden notify method
    if (doOwnsKeys in FOwnerships) or (doOwnsValues in FOwnerships) then
      TMethod(FInternalItemNotify).Code := @TObjectDictionary<TKey, TValue>.ItemNotifyEvents
    else
      TMethod(FInternalItemNotify).Code := @TCustomDictionary<TKey, TValue>.ItemNotifyCaller;
  end
  else if (Assigned(FInternalKeyNotify)) and (Assigned(FInternalValueNotify)) then
  begin
    TMethod(FInternalItemNotify).Code := @TCustomDictionary<TKey, TValue>.ItemNotifyEvents;
  end
  else if (Assigned(FInternalKeyNotify)) then
  begin
    if (TMethod(VMTKeyNotify).Code <> @TCustomDictionary<TKey, TValue>.KeyNotify) then
    begin
      TMethod(FInternalItemNotify).Code := @TObjectDictionary<TKey, TValue>.DisposeItemNotifyKeyCaller;
    end
    else if (Assigned(Self.FOnKeyNotify)) then
    begin
      TMethod(FInternalItemNotify).Code := @TObjectDictionary<TKey, TValue>.DisposeItemNotifyKeyEvent;
    end
    else
    begin
      TMethod(FInternalItemNotify).Code := @TObjectDictionary<TKey, TValue>.DisposeItemNotifyKeyOnly;
    end;
  end
  else
  // if (Assigned(FInternalValueNotify)) then
  begin
    if (TMethod(VMTValueNotify).Code <> @TCustomDictionary<TKey, TValue>.ValueNotify) then
    begin
      TMethod(FInternalItemNotify).Code := @TObjectDictionary<TKey, TValue>.DisposeItemNotifyValueCaller;
    end
    else if (Assigned(Self.FOnValueNotify)) then
    begin
      TMethod(FInternalItemNotify).Code := @TObjectDictionary<TKey, TValue>.DisposeItemNotifyValueEvent;
    end
    else
    begin
      TMethod(FInternalItemNotify).Code := @TObjectDictionary<TKey, TValue>.DisposeItemNotifyValueOnly;
    end;
  end;
end;

{ TRapidObjectDictionary<TKey,TValue> }

constructor TRapidObjectDictionary<TKey, TValue>.Create(Ownerships: TDictionaryOwnerships;
  ACapacity: Integer);
begin
  FOwnerships := Ownerships;
  if (Ownerships = []) then
    raise EInvalidCast.CreateRes(Pointer(@SInvalidCast));

  if (doOwnsKeys in Ownerships) then
  begin
    if (TypeInfo(TKey) = nil) or (PTypeInfo(TypeInfo(TKey))^.Kind <> tkClass) then
      raise EInvalidCast.CreateRes(Pointer(@SInvalidCast));
  end;

  if (doOwnsValues in Ownerships) then
  begin
    if (TypeInfo(TValue) = nil) or (PTypeInfo(TypeInfo(TValue))^.Kind <> tkClass) then
      raise EInvalidCast.CreateRes(Pointer(@SInvalidCast));
  end;

  inherited Create(ACapacity);
end;

procedure TRapidObjectDictionary<TKey, TValue>.DisposeKeyEvent(Sender: TObject;
  const Key: TObject; Action: TCollectionNotification);
begin
  TOnKeyNotify(TMethod(FOnKeyNotify).Code)(TMethod(FOnKeyNotify).Data, Self, Key, Action);
  if (Action = cnRemoved) then
    Key. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TRapidObjectDictionary<TKey, TValue>.DisposeKeyOnly(Sender: TObject;
  const Key: TObject; Action: TCollectionNotification);
begin
  if (Action = cnRemoved) then
    Key. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TRapidObjectDictionary<TKey, TValue>.DisposeValueEvent(Sender: TObject;
  const Value: TObject; Action: TCollectionNotification);
begin
  TOnValueNotify(TMethod(FOnValueNotify).Code)(TMethod(FOnValueNotify).Data, Self, Value, Action);
  if (Action = cnRemoved) then
    Value. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TRapidObjectDictionary<TKey, TValue>.DisposeValueOnly(Sender: TObject;
  const Value: TObject; Action: TCollectionNotification);
begin
  if (Action = cnRemoved) then
    Value. {$IFDEF NEXTGEN}DisposeOf{$ELSE}Free{$ENDIF};
end;

procedure TRapidObjectDictionary<TKey, TValue>.DisposeItemNotifyKeyCaller(const Item: TItem;
  Action: TCollectionNotification);
begin
  Self.KeyNotify(Item.Key, Action);
end;

procedure TRapidObjectDictionary<TKey, TValue>.DisposeItemNotifyKeyEvent(const Item: TItem;
  Action: TCollectionNotification);
begin
  FOnKeyNotify(Self, Item.Key, Action);
  if (Action = cnRemoved) then
    TObject(Pointer(@Item.Key)^).Free;
end;

procedure TRapidObjectDictionary<TKey, TValue>.DisposeItemNotifyKeyOnly(const Item: TItem;
  Action: TCollectionNotification);
begin
  if (Action = cnRemoved) then
    TObject(Pointer(@Item.Key)^).Free;
end;

procedure TRapidObjectDictionary<TKey, TValue>.DisposeItemNotifyValueCaller(const Item: TItem;
  Action: TCollectionNotification);
begin
  Self.ValueNotify(Item.Value, Action);
end;

procedure TRapidObjectDictionary<TKey, TValue>.DisposeItemNotifyValueEvent(const Item: TItem;
  Action: TCollectionNotification);
begin
  FOnValueNotify(Self, Item.Value, Action);
  if (Action = cnRemoved) then
    TObject(Pointer(@Item.Value)^).Free;
end;

procedure TRapidObjectDictionary<TKey, TValue>.DisposeItemNotifyValueOnly(const Item: TItem;
  Action: TCollectionNotification);
begin
  if (Action = cnRemoved) then
    TObject(Pointer(@Item.Value)^).Free;
end;

procedure TRapidObjectDictionary<TKey, TValue>.SetNotifyMethods;
var
  VMTKeyNotify: procedure(const Key: TKey; Action: TCollectionNotification) of object;
  VMTValueNotify: procedure(const Value: TValue; Action: TCollectionNotification) of object;
begin
  // FInternalKeyNotify
  TMethod(FInternalKeyNotify).Data := Pointer(Self);
  VMTKeyNotify := Self.KeyNotify;
  if (TMethod(VMTKeyNotify).Code <> @TCustomDictionary<TKey, TValue>.KeyNotify) then
  begin
    TMethod(FInternalKeyNotify).Code := @TCustomDictionary<TKey, TValue>.KeyNotifyCaller;
  end
  else if (doOwnsKeys in FOwnerships) then
  begin
    if (Assigned(Self.FOnKeyNotify)) then
    begin
      TMethod(FInternalKeyNotify).Code := @TRapidObjectDictionary<TKey, TValue>.DisposeValueEvent;
    end
    else
    begin
      TMethod(FInternalKeyNotify).Code := @TRapidObjectDictionary<TKey, TValue>.DisposeValueOnly;
    end;
  end
  else
  begin
    TMethod(FInternalKeyNotify) := TMethod(Self.FOnKeyNotify);
  end;

  // FInternalValueNotify
  TMethod(FInternalValueNotify).Data := Pointer(Self);
  VMTValueNotify := Self.ValueNotify;
  if (TMethod(VMTValueNotify).Code <> @TCustomDictionary<TKey, TValue>.ValueNotify) then
  begin
    TMethod(FInternalValueNotify).Code := @TCustomDictionary<TKey, TValue>.ValueNotifyCaller;
  end
  else if (doOwnsValues in FOwnerships) then
  begin
    if (Assigned(Self.FOnValueNotify)) then
    begin
      TMethod(FInternalValueNotify).Code := @TRapidObjectDictionary<TKey, TValue>.DisposeValueEvent;
    end
    else
    begin
      TMethod(FInternalValueNotify).Code := @TRapidObjectDictionary<TKey, TValue>.DisposeValueOnly;
    end;
  end
  else
  begin
    TMethod(FInternalValueNotify) := TMethod(Self.FOnValueNotify);
  end;

  // FInternalItemNotify
  TMethod(FInternalItemNotify).Data := Self;
  if (TMethod(VMTKeyNotify).Code <> @TCustomDictionary<TKey, TValue>.KeyNotify) and
    (TMethod(VMTValueNotify).Code <> @TCustomDictionary<TKey, TValue>.ValueNotify) then
  begin
    TMethod(FInternalItemNotify).Code := @TCustomDictionary<TKey, TValue>.ItemNotifyCaller;
  end
  else if (Assigned(FInternalKeyNotify)) and (Assigned(FInternalValueNotify)) then
  begin
    TMethod(FInternalItemNotify).Code := @TCustomDictionary<TKey, TValue>.ItemNotifyEvents;
  end
  else if (Assigned(FInternalKeyNotify)) then
  begin
    if (TMethod(VMTKeyNotify).Code <> @TCustomDictionary<TKey, TValue>.KeyNotify) then
    begin
      TMethod(FInternalItemNotify).Code := @TRapidObjectDictionary<TKey, TValue>.DisposeItemNotifyKeyCaller;
    end
    else if (Assigned(Self.FOnKeyNotify)) then
    begin
      TMethod(FInternalItemNotify).Code := @TRapidObjectDictionary<TKey, TValue>.DisposeItemNotifyKeyEvent;
    end
    else
    begin
      TMethod(FInternalItemNotify).Code := @TRapidObjectDictionary<TKey, TValue>.DisposeItemNotifyKeyOnly;
    end;
  end
  else
  // if (Assigned(FInternalValueNotify)) then
  begin
    if (TMethod(VMTValueNotify).Code <> @TCustomDictionary<TKey, TValue>.ValueNotify) then
    begin
      TMethod(FInternalItemNotify).Code := @TRapidObjectDictionary<TKey, TValue>.DisposeItemNotifyValueCaller;
    end
    else if (Assigned(Self.FOnValueNotify)) then
    begin
      TMethod(FInternalItemNotify).Code := @TRapidObjectDictionary<TKey, TValue>.DisposeItemNotifyValueEvent;
    end
    else
    begin
      TMethod(FInternalItemNotify).Code := @TRapidObjectDictionary<TKey, TValue>.DisposeItemNotifyValueOnly;
    end;
  end;
end;

initialization
  {$IF CompilerVersion < 31}
  TOSTime.Initialize;
  TCustomObject.CreateIntfTables;
  TLiteCustomObject.CreateIntfTables;
  {$IFEND}
end.


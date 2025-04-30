# Rapid.Generics.v2

## What is this?

This is a modified fork of [Rapid.Generics](https://github.com/d-mozulyov/Rapid.Generics/) with improvements and fixes.

Github repository: https://github.com/Alexandre-Atozed/Rapid.Generics.v2

## Why v2?

The original library could not be used in a real application due to several issues:
* It contained a few bugs
* No unit tests
* The author doesn't seem to maintain it

## What is different in v2?

### ✅ Unit Tests
* 185 new unit tests added for `TDictionary<>`, `TList<>`, `TObjectList<>`, `TQueue<>`, and `TStack<>` classes
* All tests run memory leak free. Tested with FastMM4 in FullDebugMode
* All tests can also use standard System.Generics.Collections data structures, just disabling a directive (undefine TEST_RAPIDGENERICS), making it easy to compare unexpected behavior  
* New tests added to the performance test (benchmark) application  

### 🔧 General Changes
* `{$DEFINE HAS_INLINE}` allows enabling/disabling `inline` for easier debugging
* Exception handling refactored using functions similar to Delphi 12 RTL with better error messages
* Local variables renamed for clarity (e.g., distinguishing them from properties like `Count`)
* Unused code removed
* Warnings silenced (most via `{$WARNINGS OFF}` when the compiler cannot detect variable initialization inside a `case` statement)
* Fixed AV during inteface clean up (Creating dictionaries/lists with interfaces would cause AV when destroying)
* Fixed destruction of objects owned by TObjectList<>, TObjectStack<>, TObjectQueue<> when a descendant class overrides Notify() method

### 📌 TArray Improvements
* Implemented missing methods: `IndexOf<T>` and `Contains<T>`
* Fixed `TArray.InternalSearch` when the array is empty

### 📌 TDictionary<> Improvements
* Implemented missing method: `TryAdd`

### 📌 TList<> Improvements
* Implemented missing methods: `ExtractAt()` and `IsEmpty()`
* Fixed `TList<>.InternalDelete` method for managed types, which fixed memory leaks when adding records with managed types to lists
* Sorting:
  * Now exclusively uses **QuickSort** for sorting
  * QuickSort corner cases fixed, preventing infinite loops due to improper index bounds during pivot selection
  * Removed `RadixSort` and `Insertion` routines (both failed basic unit tests). Plans to revisit this topic in the near future
  * Fixed `SortDescending()` methods

## 📌 Compatibility
This has been tested with:
* Delphi 10, 10.1, 10.2, 10.3, 10.4, 11, 12 (x86 and x64)
* Not tested with any version of Lazarus/FPC yet
* Other compiler versions will be tested in the near future

## 📌 Dependencies
* No external dependencies
* Unit test project requires [DUnitX](https://github.com/VSoftTechnologies/DUnitX/tree/master) framework
* Checking memory leaks require FastMM4 (included in the 3rd party folder)

## 📌 How to Use
1. Include `Rapid.Generics.pas` in your project.  
2. Replace `System.Generics.Collections` and `System.Generics.Defaults` with `Rapid.Generics` in your `uses` sections.  

## 📌 TRapidDictionary/TRapidObjectDictionary
Rapid "inline" `TDictionary` / `TObjectDictionary` equivalents with default hash codes and comparers.
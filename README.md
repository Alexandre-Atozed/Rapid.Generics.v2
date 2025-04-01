# Rapid.Generics.v2

## What is this?

This is a modified fork of [Rapid.Generics](https://github.com/d-mozulyov/Rapid.Generics/) with improvements and fixes.

## Why v2?

The original library could not be used in a real application due to several issues:
* It contained a few bugs
* No unit tests
* The author doesn't seem to maintain it

## What is different in v2?

### ✅ Unit Tests
* 115 new unit tests added for `TDictionary<>`, `TList<>`, `TQueue<>`, and `TStack<>` classes  
* New tests added to the performance test application  

### 🔧 General Changes
* `{$DEFINE HAS_INLINE}` allows enabling/disabling `inline` for easier debugging
* Exception handling refactored using functions similar to Delphi 12 RTL with better error messages
* Local variables renamed for clarity (e.g., distinguishing them from properties like `Count`)
* Unused code removed
* Warnings silenced (most via `{$WARNINGS OFF}` when the compiler cannot detect variable initialization inside a `case` statement)

### 📌 TArray Improvements
* Implemented missing methods: `IndexOf<T>` and `Contains<T>`
* Fixed `TArray.InternalSearch` when the array is empty

### 📌 TDictionary<> Improvements
* Implemented missing method: `TryAdd`

### 📌 TList<> Improvements
* Implemented missing method: `ExtractAt()`
* Fixed `TList<>.InternalDelete` method for managed types
* Sorting:
  * Now exclusively uses **QuickSort**  
  * Removed `RadixSort` and `Insertion` routines (both failed basic unit tests)
  * Fixed `SortDescending()` methods

## 📌 Compatibility
This has been tested with:
* Delphi 10.3, 10.4, 11, 12
* Not tested with any version of Lazarus/FPC yet
* Other compiler versions will be tested in the near future

## 📌 How to Use
1. Include `Rapid.Generics.pas` in your project.  
2. Replace `Generics.Collections` and `Generics.Defaults` with `Rapid.Generics` in your `uses` sections.  

## 📌 TRapidDictionary/TRapidObjectDictionary
Rapid "inline" `TDictionary` / `TObjectDictionary` equivalents with default hash codes and comparers.



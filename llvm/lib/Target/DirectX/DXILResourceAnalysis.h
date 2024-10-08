//===- DXILResourceAnalysis.h   - DXIL Resource analysis-------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file This file contains Analysis for information about DXIL resources.
///
//===----------------------------------------------------------------------===//

#ifndef LLVM_TARGET_DIRECTX_DXILRESOURCEANALYSIS_H
#define LLVM_TARGET_DIRECTX_DXILRESOURCEANALYSIS_H

#include "DXILResource.h"
#include "llvm/IR/PassManager.h"
#include "llvm/Pass.h"
#include <memory>

namespace llvm {
/// Analysis pass that exposes the \c DXILResource for a module.
class DXILResourceMDAnalysis
    : public AnalysisInfoMixin<DXILResourceMDAnalysis> {
  friend AnalysisInfoMixin<DXILResourceMDAnalysis>;
  static AnalysisKey Key;

public:
  typedef dxil::Resources Result;
  dxil::Resources run(Module &M, ModuleAnalysisManager &AM);
};

/// Printer pass for the \c DXILResourceMDAnalysis results.
class DXILResourceMDPrinterPass
    : public PassInfoMixin<DXILResourceMDPrinterPass> {
  raw_ostream &OS;

public:
  explicit DXILResourceMDPrinterPass(raw_ostream &OS) : OS(OS) {}
  PreservedAnalyses run(Module &M, ModuleAnalysisManager &AM);
  static bool isRequired() { return true; }
};

/// The legacy pass manager's analysis pass to compute DXIL resource
/// information.
class DXILResourceMDWrapper : public ModulePass {
  dxil::Resources Resources;

public:
  static char ID; // Pass identification, replacement for typeid

  DXILResourceMDWrapper();

  dxil::Resources &getDXILResource() { return Resources; }
  const dxil::Resources &getDXILResource() const { return Resources; }

  /// Calculate the DXILResource for the module.
  bool runOnModule(Module &M) override;

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesAll();
  }

  void print(raw_ostream &O, const Module *M = nullptr) const override;
};
} // namespace llvm

#endif // LLVM_TARGET_DIRECTX_DXILRESOURCEANALYSIS_H

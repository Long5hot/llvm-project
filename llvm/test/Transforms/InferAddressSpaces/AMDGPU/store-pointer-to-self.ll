; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt -S -mtriple=amdgcn-amd-amdhsa -passes=infer-address-spaces %s | FileCheck %s

; Make sure memory instructions where the pointer appears in both a
; pointer and value operand work correctly.

declare void @user(ptr)

; Make sure only the pointer operand use of the store is replaced
define void @store_flat_pointer_to_self() {
; CHECK-LABEL: define void @store_flat_pointer_to_self() {
; CHECK-NEXT:    [[ALLOCA:%.*]] = alloca ptr, align 8, addrspace(5)
; CHECK-NEXT:    [[FLAT:%.*]] = addrspacecast ptr addrspace(5) [[ALLOCA]] to ptr
; CHECK-NEXT:    store ptr [[FLAT]], ptr addrspace(5) [[ALLOCA]], align 8
; CHECK-NEXT:    call void @user(ptr [[FLAT]])
; CHECK-NEXT:    ret void
;
  %alloca = alloca ptr, align 8, addrspace(5)
  %flat = addrspacecast ptr addrspace(5) %alloca to ptr
  store ptr %flat, ptr %flat, align 8
  call void @user(ptr %flat)
  ret void
}

; FIXME: Should be able to optimize the pointer operand to flat.
define ptr @atomicrmw_xchg_flat_pointer_to_self() {
; CHECK-LABEL: define ptr @atomicrmw_xchg_flat_pointer_to_self() {
; CHECK-NEXT:    [[ALLOCA:%.*]] = alloca ptr, align 8, addrspace(5)
; CHECK-NEXT:    [[FLAT:%.*]] = addrspacecast ptr addrspace(5) [[ALLOCA]] to ptr
; CHECK-NEXT:    [[XCHG:%.*]] = atomicrmw xchg ptr [[FLAT]], ptr [[FLAT]] seq_cst, align 8
; CHECK-NEXT:    call void @user(ptr [[FLAT]])
; CHECK-NEXT:    ret ptr [[XCHG]]
;
  %alloca = alloca ptr, align 8, addrspace(5)
  %flat = addrspacecast ptr addrspace(5) %alloca to ptr
  %xchg = atomicrmw xchg ptr %flat, ptr %flat seq_cst, align 8
  call void @user(ptr %flat)
  ret ptr %xchg
}

define { ptr, i1 } @cmpxchg_flat_pointer_new_to_self(ptr %cmp) {
; CHECK-LABEL: define { ptr, i1 } @cmpxchg_flat_pointer_new_to_self(
; CHECK-SAME: ptr [[CMP:%.*]]) {
; CHECK-NEXT:    [[ALLOCA:%.*]] = alloca ptr, align 8, addrspace(5)
; CHECK-NEXT:    [[FLAT:%.*]] = addrspacecast ptr addrspace(5) [[ALLOCA]] to ptr
; CHECK-NEXT:    [[CMPX:%.*]] = cmpxchg ptr [[FLAT]], ptr [[CMP]], ptr [[FLAT]] seq_cst seq_cst, align 8
; CHECK-NEXT:    call void @user(ptr [[FLAT]])
; CHECK-NEXT:    ret { ptr, i1 } [[CMPX]]
;
  %alloca = alloca ptr, align 8, addrspace(5)
  %flat = addrspacecast ptr addrspace(5) %alloca to ptr
  %cmpx = cmpxchg ptr %flat, ptr %cmp, ptr %flat seq_cst seq_cst, align 8
  call void @user(ptr %flat)
  ret { ptr, i1 } %cmpx
}

define { ptr, i1 } @cmpxchg_flat_pointer_cmp_to_self(ptr %new) {
; CHECK-LABEL: define { ptr, i1 } @cmpxchg_flat_pointer_cmp_to_self(
; CHECK-SAME: ptr [[NEW:%.*]]) {
; CHECK-NEXT:    [[ALLOCA:%.*]] = alloca ptr, align 8, addrspace(5)
; CHECK-NEXT:    [[FLAT:%.*]] = addrspacecast ptr addrspace(5) [[ALLOCA]] to ptr
; CHECK-NEXT:    [[CMPX:%.*]] = cmpxchg ptr [[FLAT]], ptr [[FLAT]], ptr [[NEW]] seq_cst seq_cst, align 8
; CHECK-NEXT:    call void @user(ptr [[FLAT]])
; CHECK-NEXT:    ret { ptr, i1 } [[CMPX]]
;
  %alloca = alloca ptr, align 8, addrspace(5)
  %flat = addrspacecast ptr addrspace(5) %alloca to ptr
  %cmpx = cmpxchg ptr %flat, ptr %flat, ptr %new seq_cst seq_cst, align 8
  call void @user(ptr %flat)
  ret { ptr, i1 } %cmpx
}

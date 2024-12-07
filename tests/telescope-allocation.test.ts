import { describe, test, expect, beforeEach } from 'vitest';

// Simulated contract state
let allocations: any[] = [];
let nextAllocationId = 0;

// Helper function to simulate contract calls
const simulateContractCall = (functionName: string, args: any[], sender: string) => {
  if (functionName === 'request-allocation') {
    const [telescopeId, startTime, duration] = args;
    const allocationId = nextAllocationId++;
    allocations.push({ id: allocationId, researcher: sender, telescopeId, startTime, duration, status: 'pending' });
    return { success: true, value: allocationId };
  }
  if (functionName === 'approve-allocation') {
    const [allocationId] = args;
    const allocation = allocations.find(a => a.id === allocationId);
    if (allocation) {
      allocation.status = 'approved';
      return { success: true, value: true };
    }
    return { success: false, error: 'Allocation not found' };
  }
  if (functionName === 'get-allocation') {
    const [allocationId] = args;
    const allocation = allocations.find(a => a.id === allocationId);
    return allocation ? { success: true, value: allocation } : { success: false, error: 'Allocation not found' };
  }
  return { success: false, error: 'Function not found' };
};

describe('Telescope Allocation Contract', () => {
  const researcher1 = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
  const researcher2 = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
  const admin = 'ST3AM1A56AK2C1XAFJ4115ZSV26EB49BVQ10MGCS0';
  
  beforeEach(() => {
    allocations = [];
    nextAllocationId = 0;
  });
  
  test('researchers can request telescope time', () => {
    const result = simulateContractCall(
        'request-allocation',
        [1, 1625097600, 3600],
        researcher1
    );
    
    expect(result.success).toBe(true);
    expect(result.value).toBe(0);
    
    const allocationResult = simulateContractCall('get-allocation', [0], admin);
    expect(allocationResult.success).toBe(true);
    expect(allocationResult.value).toEqual({
      id: 0,
      researcher: researcher1,
      telescopeId: 1,
      startTime: 1625097600,
      duration: 3600,
      status: 'pending'
    });
  });
  
  test('admin can approve telescope time requests', () => {
    simulateContractCall('request-allocation', [1, 1625097600, 3600], researcher1);
    
    const approveResult = simulateContractCall('approve-allocation', [0], admin);
    expect(approveResult.success).toBe(true);
    expect(approveResult.value).toBe(true);
    
    const allocationResult = simulateContractCall('get-allocation', [0], admin);
    expect(allocationResult.success).toBe(true);
    expect(allocationResult.value.status).toBe('approved');
  });
  
  test('approving non-existent allocation fails', () => {
    const result = simulateContractCall('approve-allocation', [999], admin);
    
    expect(result.success).toBe(false);
    expect(result.error).toBe('Allocation not found');
  });
  
  test('getting non-existent allocation fails', () => {
    const result = simulateContractCall('get-allocation', [999], admin);
    
    expect(result.success).toBe(false);
    expect(result.error).toBe('Allocation not found');
  });
  
  test('multiple researchers can request telescope time', () => {
    const result1 = simulateContractCall('request-allocation', [1, 1625097600, 3600], researcher1);
    const result2 = simulateContractCall('request-allocation', [2, 1625184000, 7200], researcher2);
    
    expect(result1.success).toBe(true);
    expect(result1.value).toBe(0);
    expect(result2.success).toBe(true);
    expect(result2.value).toBe(1);
    
    const allocation1 = simulateContractCall('get-allocation', [0], admin);
    const allocation2 = simulateContractCall('get-allocation', [1], admin);
    
    expect(allocation1.success).toBe(true);
    expect(allocation1.value.researcher).toBe(researcher1);
    expect(allocation2.success).toBe(true);
    expect(allocation2.value.researcher).toBe(researcher2);
  });
});


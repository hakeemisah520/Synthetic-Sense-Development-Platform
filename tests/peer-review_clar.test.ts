import { describe, test, expect, beforeEach } from 'vitest';

// Simulated contract state
let reviews: any[] = [];
let nextReviewId = 0;

// Helper function to simulate contract calls
const simulateContractCall = (functionName: string, args: any[], sender: string) => {
  if (functionName === 'submit-review') {
    const [discoveryId, rating, comment] = args;
    if (rating > 5) return { success: false, error: 'Invalid rating' };
    const reviewId = nextReviewId++;
    reviews.push({ id: reviewId, reviewer: sender, discoveryId, rating, comment, status: 'submitted' });
    return { success: true, value: reviewId };
  }
  if (functionName === 'approve-review') {
    const [reviewId] = args;
    const review = reviews.find(r => r.id === reviewId);
    if (review) {
      review.status = 'approved';
      return { success: true, value: true };
    }
    return { success: false, error: 'Review not found' };
  }
  if (functionName === 'get-review') {
    const [reviewId] = args;
    const review = reviews.find(r => r.id === reviewId);
    return review ? { success: true, value: review } : { success: false, error: 'Review not found' };
  }
  return { success: false, error: 'Function not found' };
};

describe('Peer Review Contract', () => {
  const researcher1 = 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM';
  const researcher2 = 'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG';
  const admin = 'ST3AM1A56AK2C1XAFJ4115ZSV26EB49BVQ10MGCS0';
  
  beforeEach(() => {
    reviews = [];
    nextReviewId = 0;
  });
  
  test('researchers can submit reviews', () => {
    const result = simulateContractCall(
        'submit-review',
        [0, 4, 'Excellent discovery with strong evidence'],
        researcher1
    );
    
    expect(result.success).toBe(true);
    expect(result.value).toBe(0);
    
    const reviewResult = simulateContractCall('get-review', [0], admin);
    expect(reviewResult.success).toBe(true);
    expect(reviewResult.value).toEqual({
      id: 0,
      reviewer: researcher1,
      discoveryId: 0,
      rating: 4,
      comment: 'Excellent discovery with strong evidence',
      status: 'submitted'
    });
  });
  
  test('admin can approve reviews', () => {
    simulateContractCall(
        'submit-review',
        [0, 4, 'Excellent discovery with strong evidence'],
        researcher1
    );
    
    const approveResult = simulateContractCall('approve-review', [0], admin);
    expect(approveResult.success).toBe(true);
    expect(approveResult.value).toBe(true);
    
    const reviewResult = simulateContractCall('get-review', [0], admin);
    expect(reviewResult.success).toBe(true);
    expect(reviewResult.value.status).toBe('approved');
  });
  
  test('submitting review with invalid rating fails', () => {
    const result = simulateContractCall(
        'submit-review',
        [0, 6, 'Invalid rating'],
        researcher1
    );
    
    expect(result.success).toBe(false);
    expect(result.error).toBe('Invalid rating');
  });
  
  test('approving non-existent review fails', () => {
    const result = simulateContractCall('approve-review', [999], admin);
    
    expect(result.success).toBe(false);
    expect(result.error).toBe('Review not found');
  });
  
  test('getting non-existent review fails', () => {
    const result = simulateContractCall('get-review', [999], admin);
    
    expect(result.success).toBe(false);
    expect(result.error).toBe('Review not found');
  });
});


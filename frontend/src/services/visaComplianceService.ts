export type VisaComplianceSummary = {
  expiring: {
    days90: number;
    days60: number;
    days30: number;
  };
  restrictions: {
    restrictedAssignments: number;
    outOfPolicyAssignments: number;
  };
  pendingApplications: number;
  successfulRenewals: number;
  rejectedRenewals: number;
  upcomingAlerts: Array<{
    employeeId: number;
    name: string;
    visaType: string;
    expiryDate: string;
  }>;
};

const MOCK_SUMMARY: VisaComplianceSummary = {
  expiring: {
    days90: 12,
    days60: 6,
    days30: 3,
  },
  restrictions: {
    restrictedAssignments: 4,
    outOfPolicyAssignments: 1,
  },
  pendingApplications: 5,
  successfulRenewals: 28,
  rejectedRenewals: 2,
  upcomingAlerts: [
    {
      employeeId: 101,
      name: 'Nguyen Thi Mai',
      visaType: '特定技能',
      expiryDate: '2025-02-15',
    },
    {
      employeeId: 203,
      name: 'Carlos Ramirez',
      visaType: '技術・人文知識・国際業務',
      expiryDate: '2025-03-22',
    },
    {
      employeeId: 317,
      name: 'Sopheap Chheang',
      visaType: '技能実習',
      expiryDate: '2025-01-28',
    },
  ],
};

export const fetchVisaComplianceSummary = async (): Promise<VisaComplianceSummary> => {
  await new Promise((resolve) => setTimeout(resolve, 150));
  return MOCK_SUMMARY;
};

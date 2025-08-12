import { z } from "zod";

// Zod schema that mirrors the JSON Schema for AAR data
export const ExecutiveSummaryZ = z.object({
  problem: z.string().min(10, "Problem statement must be at least 10 characters"),
  solution: z.string().min(10, "Solution description must be at least 10 characters"),
  outcome: z.string().min(10, "Outcome description must be at least 10 characters")
});

export const PhaseZ = z.object({
  name: z.string().min(1, "Phase name is required"),
  duration: z.string().min(1, "Duration is required"),
  description: z.string().min(5, "Description must be at least 5 characters"),
  status: z.enum(["Not Started", "In Progress", "Completed", "Blocked", "Cancelled"])
});

export const OutcomesZ = z.object({
  success_metrics: z.array(z.string()).default([]),
  challenges_overcome: z.array(z.string()).default([])
});

export const ActionItemZ = z.object({
  task: z.string().min(1, "Task description is required"),
  owner: z.string().min(1, "Owner is required"),
  due_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "Due date must be in YYYY-MM-DD format"),
  status: z.enum(["Not Started", "In Progress", "Completed", "Blocked"])
});

export const FollowUpZ = z.object({
  action_items: z.array(ActionItemZ).default([])
});

export const ReferenceZ = z.object({
  title: z.string().min(1, "Title is required"),
  url: z.string().url("Must be a valid URL"),
  type: z.enum(["Documentation", "Code", "Design", "Research", "Other"])
});

export const AARZ = z.object({
  schema_version: z.literal("1.0.0"),
  title: z.string().min(5, "Title must be at least 5 characters"),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "Date must be in YYYY-MM-DD format"),
  type: z.enum(["Infrastructure", "CI", "Monitoring", "Documentation", "Feature", "Security"]),
  priority: z.enum(["Critical", "High", "Medium", "Low"]),
  executive_summary: ExecutiveSummaryZ,
  phases: z.array(PhaseZ).min(1, "At least one phase is required"),
  outcomes: OutcomesZ,
  follow_up: FollowUpZ.optional(),
  lessons_learned: z.array(z.string()).optional(),
  references: z.array(ReferenceZ).optional()
});

export type AAR = z.infer<typeof AARZ>;
export type ExecutiveSummary = z.infer<typeof ExecutiveSummaryZ>;
export type Phase = z.infer<typeof PhaseZ>;
export type Outcomes = z.infer<typeof OutcomesZ>;
export type ActionItem = z.infer<typeof ActionItemZ>;
export type FollowUp = z.infer<typeof FollowUpZ>;
export type Reference = z.infer<typeof ReferenceZ>;

// Default AAR structure for form initialization
export const createDefaultAAR = (): Partial<AAR> => ({
  schema_version: "1.0.0",
  type: "Infrastructure",
  priority: "Medium",
  date: new Date().toISOString().split('T')[0],
  executive_summary: {
    problem: "",
    solution: "",
    outcome: ""
  },
  phases: [{
    name: "Planning",
    duration: "1 week",
    description: "",
    status: "Not Started"
  }],
  outcomes: {
    success_metrics: [],
    challenges_overcome: []
  },
  follow_up: {
    action_items: []
  },
  lessons_learned: [],
  references: []
});

// Validation helpers
export const validateAAR = (data: unknown): { success: true; data: AAR } | { success: false; error: z.ZodError } => {
  const result = AARZ.safeParse(data);
  return result.success ? { success: true, data: result.data } : { success: false, error: result.error };
};

export const formatValidationErrors = (error: z.ZodError): Record<string, string> => {
  const formatted: Record<string, string> = {};
  error.issues.forEach(err => {
    const path = err.path.join('.');
    formatted[path] = err.message;
  });
  return formatted;
};

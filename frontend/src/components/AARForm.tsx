import React, { useState } from 'react';

interface ExecutiveSummary {
  problem: string;
  solution: string;
  outcome: string;
}

interface Phase {
  name: string;
  duration: string;
  description: string;
  status: 'Not Started' | 'In Progress' | 'Completed' | 'Blocked' | 'Cancelled';
}

interface AARData {
  title: string;
  date: string;
  type: 'Infrastructure' | 'CI' | 'Monitoring' | 'Documentation' | 'Feature' | 'Security';
  priority: 'Critical' | 'High' | 'Medium' | 'Low';
  executive_summary: ExecutiveSummary;
  phases?: Phase[];
  success_metrics?: string[];
  lessons_learned?: string[];
}

interface Props {
  onSubmit?: (data: AARData) => void;
  onCancel?: () => void;
}

const AARForm: React.FC<Props> = ({ onSubmit, onCancel }) => {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitStatus, setSubmitStatus] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  // Form state
  const [formData, setFormData] = useState<AARData>({
    title: '',
    date: new Date().toISOString().split('T')[0],
    type: 'Infrastructure',
    priority: 'Medium',
    executive_summary: {
      problem: '',
      solution: '',
      outcome: ''
    },
    phases: [],
    success_metrics: [],
    lessons_learned: []
  });

  const [errors, setErrors] = useState<Record<string, string>>({});

  const validateForm = (): boolean => {
    const newErrors: Record<string, string> = {};

    if (!formData.title || formData.title.length < 5) {
      newErrors.title = 'Title must be at least 5 characters';
    }

    if (!formData.date) {
      newErrors.date = 'Date is required';
    }

    if (!formData.executive_summary.problem) {
      newErrors.problem = 'Problem description is required';
    }

    if (!formData.executive_summary.solution) {
      newErrors.solution = 'Solution description is required';
    }

    if (!formData.executive_summary.outcome) {
      newErrors.outcome = 'Outcome description is required';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!validateForm()) {
      return;
    }

    setIsSubmitting(true);
    setSubmitStatus(null);

    try {
      if (onSubmit) {
        await onSubmit(formData);
      } else {
        // Default: Submit to API or handle locally
        // TODO: Integrate with AAR API endpoint
        setSubmitStatus({
          type: 'success',
          message: 'AAR data captured successfully! (Development mode)'
        });
      }
    } catch (error) {
      setSubmitStatus({
        type: 'error',
        message: error instanceof Error ? error.message : 'Failed to create AAR'
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  const updateFormData = (field: string, value: any) => {
    setFormData(prev => ({
      ...prev,
      [field]: value
    }));
    // Clear error when field is updated
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }));
    }
  };

  const updateExecutiveSummary = (field: keyof ExecutiveSummary, value: string) => {
    setFormData(prev => ({
      ...prev,
      executive_summary: {
        ...prev.executive_summary,
        [field]: value
      }
    }));
    // Clear error when field is updated
    if (errors[field]) {
      setErrors(prev => ({ ...prev, [field]: '' }));
    }
  };

  const addPhase = () => {
    const newPhase: Phase = {
      name: '',
      duration: '',
      description: '',
      status: 'Not Started'
    };
    setFormData(prev => ({
      ...prev,
      phases: [...(prev.phases || []), newPhase]
    }));
  };

  const updatePhase = (index: number, field: keyof Phase, value: string) => {
    setFormData(prev => ({
      ...prev,
      phases: prev.phases?.map((phase, i) =>
        i === index ? { ...phase, [field]: value } : phase
      ) || []
    }));
  };

  const removePhase = (index: number) => {
    setFormData(prev => ({
      ...prev,
      phases: prev.phases?.filter((_, i) => i !== index) || []
    }));
  };

  const addSuccessMetric = () => {
    setFormData(prev => ({
      ...prev,
      success_metrics: [...(prev.success_metrics || []), '']
    }));
  };

  const updateSuccessMetric = (index: number, value: string) => {
    setFormData(prev => ({
      ...prev,
      success_metrics: prev.success_metrics?.map((metric, i) =>
        i === index ? value : metric
      ) || []
    }));
  };

  const removeSuccessMetric = (index: number) => {
    setFormData(prev => ({
      ...prev,
      success_metrics: prev.success_metrics?.filter((_, i) => i !== index) || []
    }));
  };

  const addLesson = () => {
    setFormData(prev => ({
      ...prev,
      lessons_learned: [...(prev.lessons_learned || []), '']
    }));
  };

  const updateLesson = (index: number, value: string) => {
    setFormData(prev => ({
      ...prev,
      lessons_learned: prev.lessons_learned?.map((lesson, i) =>
        i === index ? value : lesson
      ) || []
    }));
  };

  const removeLesson = (index: number) => {
    setFormData(prev => ({
      ...prev,
      lessons_learned: prev.lessons_learned?.filter((_, i) => i !== index) || []
    }));
  };

  return (
    <div className="max-w-4xl mx-auto bg-white shadow-lg rounded-lg">
      <div className="px-6 py-4 border-b border-gray-200">
        <h2 className="text-2xl font-bold text-gray-900">Create After Action Report</h2>
        <p className="text-gray-600 mt-1">
          Document project outcomes, lessons learned, and follow-up actions
        </p>
      </div>

      <form onSubmit={handleSubmit} className="p-6 space-y-6">
        {/* Basic Information */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Title *
            </label>
            <input
              type="text"
              value={formData.title}
              onChange={(e) => updateFormData('title', e.target.value)}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="Initiative or project name"
            />
            {errors.title && (
              <p className="text-red-600 text-sm mt-1">{errors.title}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Date *
            </label>
            <input
              type="date"
              value={formData.date}
              onChange={(e) => updateFormData('date', e.target.value)}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            {errors.date && (
              <p className="text-red-600 text-sm mt-1">{errors.date}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Type *
            </label>
            <select
              value={formData.type}
              onChange={(e) => updateFormData('type', e.target.value as AARData['type'])}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="Infrastructure">Infrastructure</option>
              <option value="CI">CI/CD</option>
              <option value="Monitoring">Monitoring</option>
              <option value="Documentation">Documentation</option>
              <option value="Feature">Feature</option>
              <option value="Security">Security</option>
            </select>
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Priority *
            </label>
            <select
              value={formData.priority}
              onChange={(e) => updateFormData('priority', e.target.value as AARData['priority'])}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              <option value="Critical">Critical</option>
              <option value="High">High</option>
              <option value="Medium">Medium</option>
              <option value="Low">Low</option>
            </select>
          </div>
        </div>

        {/* Executive Summary */}
        <div className="space-y-4">
          <h3 className="text-lg font-semibold text-gray-900">Executive Summary *</h3>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Problem *
            </label>
            <textarea
              value={formData.executive_summary.problem}
              onChange={(e) => updateExecutiveSummary('problem', e.target.value)}
              rows={3}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="What problem was being addressed?"
            />
            {errors.problem && (
              <p className="text-red-600 text-sm mt-1">{errors.problem}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Solution *
            </label>
            <textarea
              value={formData.executive_summary.solution}
              onChange={(e) => updateExecutiveSummary('solution', e.target.value)}
              rows={3}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="What approach was taken to solve the problem?"
            />
            {errors.solution && (
              <p className="text-red-600 text-sm mt-1">{errors.solution}</p>
            )}
          </div>

          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Outcome *
            </label>
            <textarea
              value={formData.executive_summary.outcome}
              onChange={(e) => updateExecutiveSummary('outcome', e.target.value)}
              rows={3}
              className="w-full border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
              placeholder="What was the final result and impact?"
            />
            {errors.outcome && (
              <p className="text-red-600 text-sm mt-1">{errors.outcome}</p>
            )}
          </div>
        </div>

        {/* Project Phases */}
        <div className="space-y-4">
          <div className="flex justify-between items-center">
            <h3 className="text-lg font-semibold text-gray-900">Project Phases</h3>
            <button
              type="button"
              onClick={addPhase}
              className="bg-blue-600 text-white px-3 py-1 rounded text-sm hover:bg-blue-700"
            >
              Add Phase
            </button>
          </div>

          {formData.phases?.map((phase, index) => (
            <div key={index} className="border border-gray-200 rounded p-4 space-y-3">
              <div className="flex justify-between items-start">
                <h4 className="font-medium text-gray-900">Phase {index + 1}</h4>
                <button
                  type="button"
                  onClick={() => removePhase(index)}
                  className="text-red-600 hover:text-red-700 text-sm"
                >
                  Remove
                </button>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Name</label>
                  <input
                    type="text"
                    value={phase.name}
                    onChange={(e) => updatePhase(index, 'name', e.target.value)}
                    className="w-full border border-gray-300 rounded px-2 py-1 text-sm"
                    placeholder="Phase name"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Duration</label>
                  <input
                    type="text"
                    value={phase.duration}
                    onChange={(e) => updatePhase(index, 'duration', e.target.value)}
                    className="w-full border border-gray-300 rounded px-2 py-1 text-sm"
                    placeholder="e.g., 2 weeks"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Status</label>
                  <select
                    value={phase.status}
                    onChange={(e) => updatePhase(index, 'status', e.target.value)}
                    className="w-full border border-gray-300 rounded px-2 py-1 text-sm"
                  >
                    <option value="Not Started">Not Started</option>
                    <option value="In Progress">In Progress</option>
                    <option value="Completed">Completed</option>
                    <option value="Blocked">Blocked</option>
                    <option value="Cancelled">Cancelled</option>
                  </select>
                </div>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Description</label>
                <textarea
                  value={phase.description}
                  onChange={(e) => updatePhase(index, 'description', e.target.value)}
                  rows={2}
                  className="w-full border border-gray-300 rounded px-2 py-1 text-sm"
                  placeholder="What was accomplished in this phase?"
                />
              </div>
            </div>
          ))}
        </div>

        {/* Success Metrics */}
        <div className="space-y-4">
          <div className="flex justify-between items-center">
            <h3 className="text-lg font-semibold text-gray-900">Success Metrics</h3>
            <button
              type="button"
              onClick={addSuccessMetric}
              className="bg-green-600 text-white px-3 py-1 rounded text-sm hover:bg-green-700"
            >
              Add Metric
            </button>
          </div>

          {formData.success_metrics?.map((metric, index) => (
            <div key={index} className="flex gap-2 items-center">
              <input
                type="text"
                value={metric}
                onChange={(e) => updateSuccessMetric(index, e.target.value)}
                className="flex-1 border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="e.g., Reduced deployment time by 50%"
              />
              <button
                type="button"
                onClick={() => removeSuccessMetric(index)}
                className="text-red-600 hover:text-red-700 px-2"
              >
                Remove
              </button>
            </div>
          ))}
        </div>

        {/* Lessons Learned */}
        <div className="space-y-4">
          <div className="flex justify-between items-center">
            <h3 className="text-lg font-semibold text-gray-900">Lessons Learned</h3>
            <button
              type="button"
              onClick={addLesson}
              className="bg-purple-600 text-white px-3 py-1 rounded text-sm hover:bg-purple-700"
            >
              Add Lesson
            </button>
          </div>

          {formData.lessons_learned?.map((lesson, index) => (
            <div key={index} className="flex gap-2 items-center">
              <input
                type="text"
                value={lesson}
                onChange={(e) => updateLesson(index, e.target.value)}
                className="flex-1 border border-gray-300 rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-blue-500"
                placeholder="Key insight or lesson learned"
              />
              <button
                type="button"
                onClick={() => removeLesson(index)}
                className="text-red-600 hover:text-red-700 px-2"
              >
                Remove
              </button>
            </div>
          ))}
        </div>

        {/* Status Messages */}
        {submitStatus && (
          <div className={`p-4 rounded-md ${
            submitStatus.type === 'success'
              ? 'bg-green-50 border border-green-200 text-green-800'
              : 'bg-red-50 border border-red-200 text-red-800'
          }`}>
            {submitStatus.message}
          </div>
        )}

        {/* Action Buttons */}
        <div className="flex justify-end space-x-3 pt-6 border-t border-gray-200">
          {onCancel && (
            <button
              type="button"
              onClick={onCancel}
              className="px-4 py-2 text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 transition-colors"
            >
              Cancel
            </button>
          )}
          <button
            type="submit"
            disabled={isSubmitting}
            className="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 disabled:bg-gray-400 transition-colors"
          >
            {isSubmitting ? 'Creating AAR...' : 'Create AAR'}
          </button>
        </div>
      </form>
    </div>
  );
};

export default AARForm;

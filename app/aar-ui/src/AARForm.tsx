import React, { useState } from 'react';
import { useForm, useFieldArray, Controller } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { AARZ, createDefaultAAR, formatValidationErrors, type AAR } from '../lib/aar.zod';

interface AARFormProps {
  onSubmit?: (data: AAR) => void;
  initialData?: Partial<AAR>;
}

const AARForm: React.FC<AARFormProps> = ({ onSubmit, initialData }) => {
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitStatus, setSubmitStatus] = useState<{ type: 'success' | 'error'; message: string } | null>(null);

  const form = useForm<AAR>({
    resolver: zodResolver(AARZ),
    defaultValues: {
      ...createDefaultAAR(),
      ...initialData
    }
  });

  const { fields: phases, append: addPhase, remove: removePhase } = useFieldArray({
    control: form.control,
    name: "phases"
  });

  const { fields: successMetrics, append: addSuccessMetric, remove: removeSuccessMetric } = useFieldArray({
    control: form.control,
    name: "outcomes.success_metrics"
  });

  const { fields: challenges, append: addChallenge, remove: removeChallenge } = useFieldArray({
    control: form.control,
    name: "outcomes.challenges_overcome"
  });

  const { fields: actionItems, append: addActionItem, remove: removeActionItem } = useFieldArray({
    control: form.control,
    name: "follow_up.action_items"
  });

  const { fields: lessonsLearned, append: addLesson, remove: removeLesson } = useFieldArray({
    control: form.control,
    name: "lessons_learned"
  });

  const { fields: references, append: addReference, remove: removeReference } = useFieldArray({
    control: form.control,
    name: "references"
  });

  const handleSubmit = async (data: AAR) => {
    if (onSubmit) {
      onSubmit(data);
      return;
    }

    setIsSubmitting(true);
    setSubmitStatus(null);

    try {
      const response = await fetch('/api/aar/submit', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
      });

      const result = await response.json();

      if (result.success) {
        setSubmitStatus({ type: 'success', message: 'AAR submitted successfully! Rendering pipeline triggered.' });
        form.reset(createDefaultAAR());
      } else {
        setSubmitStatus({ type: 'error', message: result.error || 'Failed to submit AAR' });
      }
    } catch (error) {
      setSubmitStatus({ type: 'error', message: 'Network error occurred while submitting AAR' });
    } finally {
      setIsSubmitting(false);
    }
  };

  const inputClasses = "w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent";
  const labelClasses = "block text-sm font-medium text-gray-700 mb-1";
  const buttonClasses = "px-4 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed";
  const secondaryButtonClasses = "px-3 py-1 bg-gray-500 text-white text-sm rounded hover:bg-gray-600 focus:outline-none focus:ring-2 focus:ring-gray-400";
  const dangerButtonClasses = "px-3 py-1 bg-red-500 text-white text-sm rounded hover:bg-red-600 focus:outline-none focus:ring-2 focus:ring-red-400";

  return (
    <div className="max-w-4xl mx-auto p-6 bg-white">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Create After Action Report (AAR)</h1>
        <p className="text-gray-600">Document project outcomes, lessons learned, and follow-up actions.</p>
      </div>

      {submitStatus && (
        <div className={`mb-6 p-4 rounded-md ${submitStatus.type === 'success' ? 'bg-green-50 text-green-800 border border-green-200' : 'bg-red-50 text-red-800 border border-red-200'}`}>
          {submitStatus.message}
        </div>
      )}

      <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-8">

        {/* Basic Information */}
        <section className="bg-gray-50 p-6 rounded-lg">
          <h2 className="text-xl font-semibold mb-4">Basic Information</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className={labelClasses}>Title *</label>
              <input
                {...form.register('title')}
                className={inputClasses}
                placeholder="e.g., Phase 2 Terminal Output Compliance"
              />
              {form.formState.errors.title && (
                <p className="mt-1 text-sm text-red-600">{form.formState.errors.title.message}</p>
              )}
            </div>

            <div>
              <label className={labelClasses}>Date *</label>
              <input
                type="date"
                {...form.register('date')}
                className={inputClasses}
              />
              {form.formState.errors.date && (
                <p className="mt-1 text-sm text-red-600">{form.formState.errors.date.message}</p>
              )}
            </div>

            <div>
              <label className={labelClasses}>Type *</label>
              <select {...form.register('type')} className={inputClasses}>
                <option value="Infrastructure">Infrastructure</option>
                <option value="CI">CI</option>
                <option value="Monitoring">Monitoring</option>
                <option value="Documentation">Documentation</option>
                <option value="Feature">Feature</option>
                <option value="Security">Security</option>
              </select>
            </div>

            <div>
              <label className={labelClasses}>Priority *</label>
              <select {...form.register('priority')} className={inputClasses}>
                <option value="Critical">Critical</option>
                <option value="High">High</option>
                <option value="Medium">Medium</option>
                <option value="Low">Low</option>
              </select>
            </div>
          </div>
        </section>

        {/* Executive Summary */}
        <section className="bg-blue-50 p-6 rounded-lg">
          <h2 className="text-xl font-semibold mb-4">Executive Summary</h2>
          <div className="space-y-4">
            <div>
              <label className={labelClasses}>Problem Statement *</label>
              <textarea
                {...form.register('executive_summary.problem')}
                rows={3}
                className={inputClasses}
                placeholder="What problem was this initiative addressing?"
              />
              {form.formState.errors.executive_summary?.problem && (
                <p className="mt-1 text-sm text-red-600">{form.formState.errors.executive_summary.problem.message}</p>
              )}
            </div>

            <div>
              <label className={labelClasses}>Solution Approach *</label>
              <textarea
                {...form.register('executive_summary.solution')}
                rows={3}
                className={inputClasses}
                placeholder="How did you approach solving this problem?"
              />
              {form.formState.errors.executive_summary?.solution && (
                <p className="mt-1 text-sm text-red-600">{form.formState.errors.executive_summary.solution.message}</p>
              )}
            </div>

            <div>
              <label className={labelClasses}>Outcome *</label>
              <textarea
                {...form.register('executive_summary.outcome')}
                rows={3}
                className={inputClasses}
                placeholder="What was the final result and impact?"
              />
              {form.formState.errors.executive_summary?.outcome && (
                <p className="mt-1 text-sm text-red-600">{form.formState.errors.executive_summary.outcome.message}</p>
              )}
            </div>
          </div>
        </section>

        {/* Project Phases */}
        <section className="bg-green-50 p-6 rounded-lg">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-semibold">Project Phases</h2>
            <button
              type="button"
              onClick={() => addPhase({ name: "", duration: "", description: "", status: "Not Started" })}
              className={secondaryButtonClasses}
            >
              Add Phase
            </button>
          </div>

          {phases.map((phase, index) => (
            <div key={phase.id} className="mb-4 p-4 bg-white rounded border">
              <div className="flex justify-between items-center mb-3">
                <h3 className="font-medium">Phase {index + 1}</h3>
                <button
                  type="button"
                  onClick={() => removePhase(index)}
                  className={dangerButtonClasses}
                >
                  Remove
                </button>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                <div>
                  <label className={labelClasses}>Name *</label>
                  <input
                    {...form.register(`phases.${index}.name`)}
                    className={inputClasses}
                    placeholder="e.g., Planning"
                  />
                </div>

                <div>
                  <label className={labelClasses}>Duration *</label>
                  <input
                    {...form.register(`phases.${index}.duration`)}
                    className={inputClasses}
                    placeholder="e.g., 2 weeks"
                  />
                </div>

                <div>
                  <label className={labelClasses}>Status *</label>
                  <select {...form.register(`phases.${index}.status`)} className={inputClasses}>
                    <option value="Not Started">Not Started</option>
                    <option value="In Progress">In Progress</option>
                    <option value="Completed">Completed</option>
                    <option value="Blocked">Blocked</option>
                    <option value="Cancelled">Cancelled</option>
                  </select>
                </div>
              </div>

              <div className="mt-3">
                <label className={labelClasses}>Description *</label>
                <textarea
                  {...form.register(`phases.${index}.description`)}
                  rows={2}
                  className={inputClasses}
                  placeholder="Describe what happened in this phase"
                />
              </div>
            </div>
          ))}
        </section>

        {/* Outcomes */}
        <section className="bg-yellow-50 p-6 rounded-lg">
          <h2 className="text-xl font-semibold mb-4">Outcomes</h2>

          <div className="mb-6">
            <div className="flex justify-between items-center mb-3">
              <h3 className="font-medium">Success Metrics</h3>
              <button
                type="button"
                onClick={() => addSuccessMetric("")}
                className={secondaryButtonClasses}
              >
                Add Metric
              </button>
            </div>

            {successMetrics.map((metric, index) => (
              <div key={metric.id} className="flex gap-2 mb-2">
                <input
                  {...form.register(`outcomes.success_metrics.${index}`)}
                  className={inputClasses}
                  placeholder="e.g., Reduced build time by 40%"
                />
                <button
                  type="button"
                  onClick={() => removeSuccessMetric(index)}
                  className={dangerButtonClasses}
                >
                  Remove
                </button>
              </div>
            ))}
          </div>

          <div>
            <div className="flex justify-between items-center mb-3">
              <h3 className="font-medium">Challenges Overcome</h3>
              <button
                type="button"
                onClick={() => addChallenge("")}
                className={secondaryButtonClasses}
              >
                Add Challenge
              </button>
            </div>

            {challenges.map((challenge, index) => (
              <div key={challenge.id} className="flex gap-2 mb-2">
                <input
                  {...form.register(`outcomes.challenges_overcome.${index}`)}
                  className={inputClasses}
                  placeholder="e.g., Legacy system integration complexity"
                />
                <button
                  type="button"
                  onClick={() => removeChallenge(index)}
                  className={dangerButtonClasses}
                >
                  Remove
                </button>
              </div>
            ))}
          </div>
        </section>

        {/* Submit Button */}
        <div className="flex justify-end">
          <button
            type="submit"
            disabled={isSubmitting}
            className={buttonClasses}
          >
            {isSubmitting ? 'Submitting...' : 'Submit AAR'}
          </button>
        </div>
      </form>
    </div>
  );
};

export default AARForm;
